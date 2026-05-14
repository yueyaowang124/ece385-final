//=============================================================================
// piano_display_v3.sv  --  v2 + falling tiles 静态渲染 (M1)
//
// 相对 v2 的改动:
//   - 新增 input tile_word_lo[31:0]
//   - 解码 2 个 tile (每个 16 bits):
//       [15:14] col      (0..3)
//       [13: 5] y_top    (0..511)
//       [4]     active   (1 = 显示, 0 = 隐藏)
//       [3:0]   reserved (将来用于 hit/perfect 闪烁)
//   - 在 tile 区域 (y < KEY_AREA_Y0) 上绘制方块
//
// 渲染优先级: tile > 顶部 HUD > 钢琴
//   tile 区域 = (DrawY >= TILE_AREA_Y0) && (DrawY < TILE_AREA_Y1)
//   不会覆盖键盘 (y >= 180), 不会覆盖顶部 HUD (y < 30)
//
// 4 列定位 (与键盘宽度 40-600 对齐):
//   Col 0 (A): x = 40..180   (140 px wide)
//   Col 1 (S): x = 180..320
//   Col 2 (D): x = 320..460
//   Col 3 (F): x = 460..600
//=============================================================================
module piano_display (
    input  logic [9:0]  DrawX,
    input  logic [9:0]  DrawY,
    input  logic [23:0] keymask,
    input  logic [3:0]  octave_idx,
    input  logic [2:0]  wave_idx,
    input  logic [31:0] tile_word_lo,      // ← M1 新增
    output logic [7:0]  R,
    output logic [7:0]  G,
    output logic [7:0]  B
);

    // ---- 常量 (沿用 v2) ----
    localparam logic [9:0] KEY_LEFT     = 10'd40;
    localparam logic [9:0] KEY_RIGHT    = 10'd600;
    localparam logic [9:0] KEY_W        = 10'd40;
    localparam logic [9:0] KEY_AREA_Y0  = 10'd180;
    localparam logic [9:0] DIVIDER_Y0   = 10'd160;
    localparam logic [9:0] BLACK_KEY_H  = 10'd180;
    localparam logic [9:0] BLACK_HALF_W = 10'd12;
    localparam logic [9:0] BORDER_W     = 10'd2;

    localparam logic [9:0] OCT_Y0       = 10'd6;
    localparam logic [9:0] OCT_Y1       = 10'd22;
    localparam logic [9:0] OCT_X0       = 10'd40;
    localparam logic [9:0] OCT_BOX_W    = 10'd18;
    localparam logic [9:0] OCT_BOX_FILL = 10'd16;

    localparam logic [9:0] WAVE_Y0      = 10'd4;
    localparam logic [9:0] WAVE_Y1      = 10'd28;
    localparam logic [9:0] WAVE_X0      = 10'd372;
    localparam logic [9:0] WAVE_BOX_W   = 10'd40;
    localparam logic [9:0] WAVE_FILL_W  = 10'd38;

    // ---- M1 新增: tile 区域 ----
    localparam logic [9:0] TILE_AREA_Y0 = 10'd30;     // 紧接 HUD 下方
    localparam logic [9:0] TILE_AREA_Y1 = 10'd160;    // 到 divider 上面
    localparam logic [9:0] TILE_H       = 10'd40;     // 每个 tile 高 40px
    localparam logic [9:0] COL_W        = 10'd140;    // 每列 140px 宽
    localparam logic [9:0] COL_X0       = 10'd40;     // 第 0 列起点

    //====================== 白键 / 黑键计算 (同 v2) ======================
    logic [9:0] x_rel;
    logic [3:0] white_n;
    logic [5:0] x_in_white;
    logic in_key_x, in_key_y;
    assign in_key_x   = (DrawX >= KEY_LEFT) && (DrawX < KEY_RIGHT);
    assign in_key_y   = (DrawY >= KEY_AREA_Y0);
    assign x_rel      = in_key_x ? (DrawX - KEY_LEFT) : 10'd0;
    assign white_n    = in_key_x ? x_rel[9:0] / KEY_W : 4'd15;
    assign x_in_white = in_key_x ? x_rel[9:0] - (white_n * KEY_W) : 6'd0;

    logic [4:0] white_semi;
    always_comb begin
        unique case (white_n)
            4'd0:    white_semi = 5'd0;
            4'd1:    white_semi = 5'd2;
            4'd2:    white_semi = 5'd4;
            4'd3:    white_semi = 5'd5;
            4'd4:    white_semi = 5'd7;
            4'd5:    white_semi = 5'd9;
            4'd6:    white_semi = 5'd11;
            4'd7:    white_semi = 5'd12;
            4'd8:    white_semi = 5'd14;
            4'd9:    white_semi = 5'd16;
            4'd10:   white_semi = 5'd17;
            4'd11:   white_semi = 5'd19;
            4'd12:   white_semi = 5'd21;
            4'd13:   white_semi = 5'd23;
            default: white_semi = 5'd31;
        endcase
    end

    logic black_hit;
    logic [4:0] black_semi;
    logic in_black_y;
    assign in_black_y = (DrawY >= KEY_AREA_Y0) && (DrawY < KEY_AREA_Y0 + BLACK_KEY_H);
    always_comb begin
        black_hit  = 1'b0;
        black_semi = 5'd0;
        if (in_black_y) begin
            if      ((DrawX >= 10'd80  - BLACK_HALF_W) && (DrawX < 10'd80  + BLACK_HALF_W)) begin black_hit = 1'b1; black_semi = 5'd1;  end
            else if ((DrawX >= 10'd120 - BLACK_HALF_W) && (DrawX < 10'd120 + BLACK_HALF_W)) begin black_hit = 1'b1; black_semi = 5'd3;  end
            else if ((DrawX >= 10'd200 - BLACK_HALF_W) && (DrawX < 10'd200 + BLACK_HALF_W)) begin black_hit = 1'b1; black_semi = 5'd6;  end
            else if ((DrawX >= 10'd240 - BLACK_HALF_W) && (DrawX < 10'd240 + BLACK_HALF_W)) begin black_hit = 1'b1; black_semi = 5'd8;  end
            else if ((DrawX >= 10'd280 - BLACK_HALF_W) && (DrawX < 10'd280 + BLACK_HALF_W)) begin black_hit = 1'b1; black_semi = 5'd10; end
            else if ((DrawX >= 10'd360 - BLACK_HALF_W) && (DrawX < 10'd360 + BLACK_HALF_W)) begin black_hit = 1'b1; black_semi = 5'd13; end
            else if ((DrawX >= 10'd400 - BLACK_HALF_W) && (DrawX < 10'd400 + BLACK_HALF_W)) begin black_hit = 1'b1; black_semi = 5'd15; end
            else if ((DrawX >= 10'd480 - BLACK_HALF_W) && (DrawX < 10'd480 + BLACK_HALF_W)) begin black_hit = 1'b1; black_semi = 5'd18; end
            else if ((DrawX >= 10'd520 - BLACK_HALF_W) && (DrawX < 10'd520 + BLACK_HALF_W)) begin black_hit = 1'b1; black_semi = 5'd20; end
            else if ((DrawX >= 10'd560 - BLACK_HALF_W) && (DrawX < 10'd560 + BLACK_HALF_W)) begin black_hit = 1'b1; black_semi = 5'd22; end
        end
    end

    //====================== 音域指示条 ======================
    logic in_oct_y, in_oct_x;
    logic [9:0] oct_x_rel;
    logic [3:0] oct_box;
    logic in_oct_fill, oct_box_active;
    assign in_oct_y       = (DrawY >= OCT_Y0) && (DrawY < OCT_Y1);
    assign in_oct_x       = (DrawX >= OCT_X0) && (DrawX < (OCT_X0 + 9*OCT_BOX_W));
    assign oct_x_rel      = in_oct_x ? (DrawX - OCT_X0) : 10'd0;
    assign oct_box        = in_oct_x ? oct_x_rel[9:0] / OCT_BOX_W : 4'd15;
    assign in_oct_fill    = in_oct_y && in_oct_x &&
                            ((oct_x_rel - oct_box * OCT_BOX_W) < OCT_BOX_FILL);
    assign oct_box_active = (oct_box == octave_idx);

    //====================== 波形 icon HUD ======================
    logic in_wave_y, in_wave_x;
    logic [9:0] wave_x_rel;
    logic [2:0] wave_box;
    logic [9:0] wave_local_x;
    logic [9:0] wave_local_y;

    assign in_wave_y    = (DrawY >= WAVE_Y0) && (DrawY < WAVE_Y1);
    assign in_wave_x    = (DrawX >= WAVE_X0) && (DrawX < (WAVE_X0 + 6*WAVE_BOX_W));
    assign wave_x_rel   = in_wave_x ? (DrawX - WAVE_X0) : 10'd0;
    assign wave_box     = in_wave_x ? wave_x_rel[9:0] / WAVE_BOX_W : 3'd7;
    assign wave_local_x = in_wave_x ? (wave_x_rel - wave_box * WAVE_BOX_W) : 10'd0;
    assign wave_local_y = in_wave_y ? (DrawY - WAVE_Y0) : 10'd0;

    logic in_wave_fill;
    assign in_wave_fill = in_wave_y && in_wave_x && (wave_local_x < WAVE_FILL_W);

    logic [4:0]  w_x;
    logic [4:0]  w_y;
    logic        in_canvas;
    assign in_canvas = in_wave_fill && (wave_local_x >= 10'd4) && (wave_local_x < 10'd34)
                                    && (wave_local_y >= 10'd2) && (wave_local_y < 10'd22);
    assign w_x = in_canvas ? (wave_local_x - 10'd4) : 5'd0;
    assign w_y = in_canvas ? (wave_local_y - 10'd2) : 5'd0;

    logic [4:0] ref_y;
    logic       draw_line;
    always_comb begin
        ref_y = 5'd10;
        case (wave_box)
            3'd0: ref_y = (w_x < 5'd15) ? 5'd3 : 5'd16;
            3'd1: ref_y = (w_x < 5'd15) ? (5'd18 - w_x) : (5'd3 + (w_x - 5'd15));
            3'd2: ref_y = (w_x < 5'd29) ? (5'd18 - (w_x * 5'd15) / 5'd28) : 5'd18;
            3'd3: begin
                if      (w_x < 5'd4)  ref_y = 5'd10 - w_x * 5'd2;
                else if (w_x < 5'd8)  ref_y = 5'd6  - (w_x - 5'd4);
                else if (w_x < 5'd12) ref_y = 5'd3  + (w_x - 5'd8);
                else if (w_x < 5'd16) ref_y = 5'd7  + (w_x - 5'd12);
                else if (w_x < 5'd20) ref_y = 5'd11 + (w_x - 5'd16);
                else if (w_x < 5'd24) ref_y = 5'd15 + (w_x - 5'd20);
                else if (w_x < 5'd28) ref_y = 5'd18 - (w_x - 5'd24);
                else                  ref_y = 5'd14 - (w_x - 5'd28);
            end
            3'd4: begin
                if      (w_x < 5'd4)  ref_y = 5'd10 - w_x;
                else if (w_x < 5'd8)  ref_y = 5'd6  - (w_x - 5'd4);
                else if (w_x < 5'd12) ref_y = 5'd3  + (w_x - 5'd8);
                else if (w_x < 5'd16) ref_y = 5'd7  + (w_x - 5'd12);
                else if (w_x < 5'd20) ref_y = 5'd11 + (w_x - 5'd16);
                else if (w_x < 5'd24) ref_y = 5'd15 + (w_x - 5'd20);
                else if (w_x < 5'd28) ref_y = 5'd18 - (w_x - 5'd24);
                else                  ref_y = 5'd14 - (w_x - 5'd28);
            end
            3'd5: begin
                if      (w_x < 5'd7)  ref_y = 5'd10 - w_x;
                else if (w_x < 5'd14) ref_y = 5'd3  + (w_x - 5'd7);
                else if (w_x < 5'd21) ref_y = 5'd10 + (w_x - 5'd14);
                else                  ref_y = 5'd17 - (w_x - 5'd21);
            end
            default: ref_y = 5'd10;
        endcase
    end

    logic [4:0] dy;
    assign dy = (w_y > ref_y) ? (w_y - ref_y) : (ref_y - w_y);
    assign draw_line = in_canvas && (dy <= 5'd1);

    logic [7:0] icon_bg_r, icon_bg_g, icon_bg_b;
    logic [7:0] icon_line_r, icon_line_g, icon_line_b;
    logic       wave_active;
    assign wave_active = ({1'b0, wave_box} == wave_idx);
    always_comb begin
        if (wave_active) begin
            icon_bg_r = 8'h40; icon_bg_g = 8'h30; icon_bg_b = 8'h60;
            icon_line_r = 8'hFF; icon_line_g = 8'hD0; icon_line_b = 8'h30;
        end else begin
            icon_bg_r = 8'h18; icon_bg_g = 8'h18; icon_bg_b = 8'h20;
            icon_line_r = 8'h80; icon_line_g = 8'h80; icon_line_b = 8'h80;
        end
    end

    //====================== M1 新增: tile 渲染 ======================
    // 解码 2 个 tile
    logic [1:0] t0_col, t1_col;
    logic [8:0] t0_y,   t1_y;
    logic       t0_act, t1_act;
    assign {t0_col, t0_y, t0_act} = {tile_word_lo[15:14], tile_word_lo[13:5], tile_word_lo[4]};
    assign {t1_col, t1_y, t1_act} = {tile_word_lo[31:30], tile_word_lo[29:21], tile_word_lo[20]};

    // 当前像素属于哪一列? 0..3, 不在 tile 区返回 4 (无效)
    logic [9:0] tile_x_rel;
    logic [2:0] cur_col;        // 0..3 有效, 4 = 无效
    logic       in_tile_x;
    assign in_tile_x  = (DrawX >= COL_X0) && (DrawX < (COL_X0 + 4*COL_W));
    assign tile_x_rel = in_tile_x ? (DrawX - COL_X0) : 10'd0;
    assign cur_col    = in_tile_x ? tile_x_rel[9:0] / COL_W : 3'd4;

    logic in_tile_y;
    assign in_tile_y = (DrawY >= TILE_AREA_Y0) && (DrawY < TILE_AREA_Y1);

    // 是否落在 tile 0 / tile 1 上?
    logic on_tile0, on_tile1;
    assign on_tile0 = t0_act && in_tile_x && in_tile_y &&
                       (cur_col == {1'b0, t0_col}) &&
                       (DrawY >= t0_y) && (DrawY < (t0_y + TILE_H));
    assign on_tile1 = t1_act && in_tile_x && in_tile_y &&
                       (cur_col == {1'b0, t1_col}) &&
                       (DrawY >= t1_y) && (DrawY < (t1_y + TILE_H));
    logic on_any_tile;
    assign on_any_tile = on_tile0 | on_tile1;

    // 列分隔线 (在 tile 区内画一条竖线区分 4 列, 视觉提示)
    logic on_col_border;
    assign on_col_border = in_tile_x && in_tile_y &&
                           ((tile_x_rel % COL_W == 10'd0) || (tile_x_rel % COL_W == 10'd139));

    //====================== 最终颜色 ======================
    always_comb begin
        // 优先级: tile 区 > 顶部 HUD > 钢琴
        if (on_any_tile) begin
            // tile 浅紫色
            R = 8'hC0; G = 8'hC0; B = 8'hFF;
        end
        else if (in_tile_y && on_col_border) begin
            // 列分隔线 (淡灰)
            R = 8'h40; G = 8'h40; B = 8'h60;
        end
        else if (in_tile_y && in_tile_x) begin
            // tile 区背景 (深蓝)
            R = 8'h10; G = 8'h10; B = 8'h30;
        end
        // --- 以下是 v2 原有的逻辑 ---
        else if (in_wave_fill) begin
            if (draw_line) begin
                R = icon_line_r; G = icon_line_g; B = icon_line_b;
            end else begin
                R = icon_bg_r; G = icon_bg_g; B = icon_bg_b;
            end
        end
        else if (in_oct_fill) begin
            if (oct_box_active)          begin R = 8'hFF; G = 8'hD0; B = 8'h30; end
            else if (oct_box == 4'd4)    begin R = 8'h60; G = 8'h60; B = 8'h80; end
            else                         begin R = 8'h30; G = 8'h30; B = 8'h40; end
        end
        else if (black_hit) begin
            if (keymask[black_semi])     begin R = 8'hFF; G = 8'hA0; B = 8'h00; end
            else                         begin R = 8'h10; G = 8'h10; B = 8'h10; end
        end
        else if (in_key_x && in_key_y) begin
            if ((x_in_white < BORDER_W) || (x_in_white >= (KEY_W - BORDER_W)))
                                         begin R = 8'h00; G = 8'h00; B = 8'h00; end
            else if (white_n < 4'd14 && keymask[white_semi])
                                         begin R = 8'hFF; G = 8'hD0; B = 8'h30; end
            else                         begin R = 8'hFF; G = 8'hFF; B = 8'hFF; end
        end
        else if (in_key_y)               begin R = 8'h20; G = 8'h20; B = 8'h20; end
        else if ((DrawY >= DIVIDER_Y0) && (DrawY < KEY_AREA_Y0))
                                         begin R = 8'h40; G = 8'h40; B = 8'h40; end
        else                             begin R = 8'h00; G = 8'h00; B = 8'h00; end
    end

endmodule
