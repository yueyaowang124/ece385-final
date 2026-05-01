//=============================================================================
// piano_display_v2.sv  --  在原 piano_display 基础上加一个波形切换 HUD
//
// 相对 v1 的改动：
//   - 新增 input wave_idx[2:0]    (0..5, 选中的波形)
//   - 屏幕顶部右侧画 6 个小波形图标, 当前选中的被高亮
//
// 布局 (640x480)：
//   y = 0..29   : 顶条 — 左侧 9 格是音域, 右侧 6 个 40×24 的波形 icon
//   y = 30..159 : 上半屏 (给 Day 5 falling notes 留)
//   y = 160..179: 分隔条 (灰)
//   y = 180..359: 键盘上半部分 (白键 + 黑键重叠)
//   y = 360..479: 键盘下半部分 (只有白键)
//
// 波形 icon 坐标：
//   ICON_X0 = 400, 每个 ICON_W = 38 (含 2px 间距), 共 6 个
//   波形图通过在 icon 框内按 DrawX/DrawY 计算一个线图来画
//=============================================================================
module piano_display (
    input  logic [9:0]  DrawX,
    input  logic [9:0]  DrawY,
    input  logic [23:0] keymask,
    input  logic [3:0]  octave_idx,
    input  logic [2:0]  wave_idx,      // ← 新增
    output logic [7:0]  R,
    output logic [7:0]  G,
    output logic [7:0]  B
);

    // ---- 常量 (沿用 v1) ----
    localparam logic [9:0] KEY_LEFT     = 10'd40;
    localparam logic [9:0] KEY_RIGHT    = 10'd600;
    localparam logic [9:0] KEY_W        = 10'd40;
    localparam logic [9:0] KEY_AREA_Y0  = 10'd180;
    localparam logic [9:0] DIVIDER_Y0   = 10'd160;
    localparam logic [9:0] BLACK_KEY_H  = 10'd180;
    localparam logic [9:0] BLACK_HALF_W = 10'd12;
    localparam logic [9:0] BORDER_W     = 10'd2;

    // 音域指示条 (保持在左侧)
    localparam logic [9:0] OCT_Y0       = 10'd6;
    localparam logic [9:0] OCT_Y1       = 10'd22;
    localparam logic [9:0] OCT_X0       = 10'd40;     // ← 往左挪一点, 给波形 icon 腾位置
    localparam logic [9:0] OCT_BOX_W    = 10'd18;
    localparam logic [9:0] OCT_BOX_FILL = 10'd16;

    // 波形 icon 区 (右侧)
    localparam logic [9:0] WAVE_Y0      = 10'd4;
    localparam logic [9:0] WAVE_Y1      = 10'd28;     // 高 24px
    localparam logic [9:0] WAVE_X0      = 10'd372;    // 6 × 40 = 240 px, 靠右排
    localparam logic [9:0] WAVE_BOX_W   = 10'd40;     // 每个 icon 占 40
    localparam logic [9:0] WAVE_FILL_W  = 10'd38;     // icon 本体 38px (留 2px 间距)
    localparam logic [9:0] WAVE_BOX_H   = WAVE_Y1 - WAVE_Y0;  // 24

    //====================== 白键 / 黑键计算 (同 v1) ======================
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

    //====================== 音域指示条 (同 v1, 只是挪了 OCT_X0) ======================
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
    logic [2:0] wave_box;          // 0..5
    logic [9:0] wave_local_x;      // 0..39  (在当前 icon 内的 x)
    logic [9:0] wave_local_y;      // 0..23  (在 icon 内的 y)

    assign in_wave_y    = (DrawY >= WAVE_Y0) && (DrawY < WAVE_Y1);
    assign in_wave_x    = (DrawX >= WAVE_X0) && (DrawX < (WAVE_X0 + 6*WAVE_BOX_W));
    assign wave_x_rel   = in_wave_x ? (DrawX - WAVE_X0) : 10'd0;
    assign wave_box     = in_wave_x ? wave_x_rel[9:0] / WAVE_BOX_W : 3'd7;
    assign wave_local_x = in_wave_x ? (wave_x_rel - wave_box * WAVE_BOX_W) : 10'd0;
    assign wave_local_y = in_wave_y ? (DrawY - WAVE_Y0) : 10'd0;

    logic in_wave_fill;   // 在 icon 矩形内 (不含右边 2px 间距)
    assign in_wave_fill = in_wave_y && in_wave_x && (wave_local_x < WAVE_FILL_W);

    // 每个 icon 里画一段小波形 —— 根据 wave_box 选不同形状
    // icon 内 "画笔线" 的 y 坐标 (描粗 2px)
    // 统一：x 从 4..34 是波形本体 (30px 宽), y = 2..22 是画布 (20px 高), 中心 y = 12
    logic [4:0]  w_x;          // 0..29  (在 icon 画布内的 x)
    logic [4:0]  w_y;          // 0..19
    logic        in_canvas;
    assign in_canvas = in_wave_fill && (wave_local_x >= 10'd4) && (wave_local_x < 10'd34)
                                    && (wave_local_y >= 10'd2) && (wave_local_y < 10'd22);
    assign w_x = in_canvas ? (wave_local_x - 10'd4) : 5'd0;
    assign w_y = in_canvas ? (wave_local_y - 10'd2) : 5'd0;

    // 参考 y (画笔应该在哪一行) —— 每种波形不同
    logic [4:0] ref_y;
    logic       draw_line;
    always_comb begin
        ref_y = 5'd10;
        case (wave_box)
            // Square: 半个周期在高位, 半个在低位
            3'd0: ref_y = (w_x < 5'd15) ? 5'd3 : 5'd16;
            // Triangle: / \ (上升 15px, 下降 15px)
            3'd1: ref_y = (w_x < 5'd15)
                         ? (5'd18 - w_x)                  // 下降成上升 18..3
                         : (5'd3 + (w_x - 5'd15));        // 上升 3..18
            // Sawtooth: 一路从下往上, 然后直角掉下
            3'd2: ref_y = (w_x < 5'd29) ? (5'd18 - (w_x * 5'd15) / 5'd28) : 5'd18;
            // Sine: 用 sin 近似 (硬编码 5 个转折点)
            //   点 (0,10) → (7,3) → (15,10) → (22,17) → (29,10)
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
            // Organ: sine + 2 个小圆顶 (顶部加点小装饰)
            3'd4: begin
                // 主 sine 曲线
                if      (w_x < 5'd4)  ref_y = 5'd10 - w_x;
                else if (w_x < 5'd8)  ref_y = 5'd6  - (w_x - 5'd4) * 5'd1;  // 6..3
                else if (w_x < 5'd12) ref_y = 5'd3  + (w_x - 5'd8)  * 5'd1;
                else if (w_x < 5'd16) ref_y = 5'd7  + (w_x - 5'd12) * 5'd1;
                else if (w_x < 5'd20) ref_y = 5'd11 + (w_x - 5'd16) * 5'd1;
                else if (w_x < 5'd24) ref_y = 5'd15 + (w_x - 5'd20);
                else if (w_x < 5'd28) ref_y = 5'd18 - (w_x - 5'd24);
                else                  ref_y = 5'd14 - (w_x - 5'd28);
            end
            // Vibrato: 中间一段 sine 振幅逐渐变化
            3'd5: begin
                // 简单几个节点拼出一个起伏更大的波
                if      (w_x < 5'd7)  ref_y = 5'd10 - w_x;
                else if (w_x < 5'd14) ref_y = 5'd3  + (w_x - 5'd7);
                else if (w_x < 5'd21) ref_y = 5'd10 + (w_x - 5'd14);
                else                  ref_y = 5'd17 - (w_x - 5'd21);
            end
            default: ref_y = 5'd10;
        endcase
    end

    // 判断当前像素是不是在 "描粗 2px" 的线上
    logic [4:0] dy;
    assign dy = (w_y > ref_y) ? (w_y - ref_y) : (ref_y - w_y);
    assign draw_line = in_canvas && (dy <= 5'd1);

    //====================== 最终颜色 ======================
    logic [7:0] icon_bg_r, icon_bg_g, icon_bg_b;
    logic [7:0] icon_line_r, icon_line_g, icon_line_b;
    logic       wave_active;
    assign wave_active = ({1'b0, wave_box} == wave_idx);
    always_comb begin
        if (wave_active) begin
            icon_bg_r = 8'h40; icon_bg_g = 8'h30; icon_bg_b = 8'h60;      // 选中: 深紫底
            icon_line_r = 8'hFF; icon_line_g = 8'hD0; icon_line_b = 8'h30; // 黄线
        end else begin
            icon_bg_r = 8'h18; icon_bg_g = 8'h18; icon_bg_b = 8'h20;      // 未选中: 深灰
            icon_line_r = 8'h80; icon_line_g = 8'h80; icon_line_b = 8'h80; // 灰线
        end
    end

    always_comb begin
        // --- 顶部 HUD: 波形 icon 优先级最高 ---
        if (in_wave_fill) begin
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
