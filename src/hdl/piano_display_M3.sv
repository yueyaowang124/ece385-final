//=============================================================================
// piano_display_M3.sv  --  M2 + 击打判定 UI
//
// 改动 (相对 M2):
//   - 删掉黄色虚线警戒线
//   - tile 不再被 y=380 截断, 一直渲染到 y=480 (穿过按键框, 掉出屏幕)
//   - 新增 tile state 解码 (NORMAL / HIT / PERFECT / MISSED, 各不同颜色)
//   - 按键框颜色根据 column flash (keymask[15:12]) 显示红色"错音"反馈
//   - 侧栏顶部加分数进度条 (从 keymask[11:4] 读 score+128)
//
// 游戏模式 (game_active=1) 下 keymask 编码 (24 bits):
//   [3:0]   ASDF 当前按下状态 (4 bits)
//   [11:4]  score + 128 (8 bits, 范围 -128..+127)
//   [15:12] column flash mask (4 bits, 1=该列正在错音闪红)
//   [23:16] reserved
//
// tile_word_lo 编码 (32 bits):
//   t0 [15:0]:
//     [15:14] col       [13:5] y_top      [4] active
//     [3]     game_active   [2:1] state    [0] reserved
//   t1 [31:16]:
//     [31:30] col       [29:21] y_top     [20] active
//     [19:18] reserved  [17:16] state
//
// tile state (2-bit):
//   00 = NORMAL   (浅紫, 可被击中)
//   01 = HIT      (绿色, 已击中, 仍在掉落)
//   10 = PERFECT  (金色, 完美命中)
//   11 = MISSED   (暗灰, 已错过, 仍在掉落)
//=============================================================================
module piano_display (
    input  logic [9:0]  DrawX,
    input  logic [9:0]  DrawY,
    input  logic [23:0] keymask,
    input  logic [23:0] auto_keymask,
    input  logic [3:0]  octave_idx,
    input  logic [2:0]  wave_idx,
    input  logic [31:0] tile_word_lo,
    output logic [7:0]  R,
    output logic [7:0]  G,
    output logic [7:0]  B
);
    // ================================================================
    // 钢琴 UI 几何 (沿用 M1)
    // ================================================================
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

    // M1 钢琴模式 tile 区
    localparam logic [9:0] TILE_AREA_Y0 = 10'd30;
    localparam logic [9:0] TILE_AREA_Y1 = 10'd160;
    localparam logic [9:0] M1_COL_W     = 10'd140;
    localparam logic [9:0] M1_COL_X0    = 10'd40;

    // ================================================================
    // 游戏 UI 几何
    // ================================================================
    localparam logic [9:0] G_AREA_X0    = 10'd0;
    localparam logic [9:0] G_AREA_X1    = 10'd480;
    localparam logic [9:0] G_COL_W      = 10'd120;
    localparam logic [9:0] G_KEYPAD_Y0  = 10'd400;
    localparam logic [9:0] G_KEYPAD_Y1  = 10'd440;

    localparam logic [9:0] SB_X0        = 10'd480;
    localparam logic [9:0] SB_X1        = 10'd640;

    localparam logic [9:0] TILE_H       = 10'd40;

    // 分数条
    localparam logic [9:0] SCORE_BAR_Y0 = 10'd16;
    localparam logic [9:0] SCORE_BAR_Y1 = 10'd36;
    localparam logic [9:0] SCORE_BAR_X0 = 10'd490;
    localparam logic [9:0] SCORE_BAR_X1 = 10'd630;
    localparam logic [9:0] SCORE_BAR_W  = SCORE_BAR_X1 - SCORE_BAR_X0;  // 140

    // ================================================================
    // 全局: game_active
    // ================================================================
    logic game_active;
    assign game_active = tile_word_lo[3];

    // ================================================================
    // 钢琴模式几何 (沿用)
    // ================================================================
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

    // 八度
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

    // 波形 icon
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

    logic [4:0] w_x;
    logic [4:0] w_y;
    logic       in_canvas;
    assign in_canvas = in_wave_fill && (wave_local_x >= 10'd4) && (wave_local_x < 10'd34)
                                    && (wave_local_y >= 10'd2) && (wave_local_y < 10'd22);
    assign w_x = in_canvas ? (wave_local_x - 10'd4) : 5'd0;
    assign w_y = in_canvas ? (wave_local_y - 10'd2) : 5'd0;

    logic [4:0] ref_y;
    always_comb begin
        ref_y = 5'd10;
        case (wave_box)
            3'd0: begin
                if      (w_x < 5'd2)  ref_y = 5'd10;
                else if (w_x < 5'd14) ref_y = 5'd4;
                else if (w_x < 5'd16) ref_y = 5'd10;
                else if (w_x < 5'd28) ref_y = 5'd16;
                else                  ref_y = 5'd10;
            end
            3'd1: begin
                if (w_x < 5'd15) ref_y = 5'd17 - w_x;
                else             ref_y = 5'd3  + (w_x - 5'd15);
            end
            3'd2: begin
                if (w_x <= 5'd24) ref_y = 5'd3 + (w_x * 5'd14 / 5'd24);
                else begin
                    unique case (w_x)
                        5'd25: ref_y = 5'd17;
                        5'd26: ref_y = 5'd14;
                        5'd27: ref_y = 5'd10;
                        5'd28: ref_y = 5'd6;
                        5'd29: ref_y = 5'd3;
                        default: ref_y = 5'd10;
                    endcase
                end
            end
            3'd3: begin
                unique case (w_x)
                    5'd0:  ref_y = 5'd10; 5'd1:  ref_y = 5'd8;
                    5'd2:  ref_y = 5'd7;  5'd3:  ref_y = 5'd6;
                    5'd4:  ref_y = 5'd5;  5'd5:  ref_y = 5'd4;
                    5'd6:  ref_y = 5'd3;  5'd7:  ref_y = 5'd3;
                    5'd8:  ref_y = 5'd3;  5'd9:  ref_y = 5'd3;
                    5'd10: ref_y = 5'd4;  5'd11: ref_y = 5'd5;
                    5'd12: ref_y = 5'd6;  5'd13: ref_y = 5'd8;
                    5'd14: ref_y = 5'd9;  5'd15: ref_y = 5'd11;
                    5'd16: ref_y = 5'd12; 5'd17: ref_y = 5'd14;
                    5'd18: ref_y = 5'd15; 5'd19: ref_y = 5'd16;
                    5'd20: ref_y = 5'd17; 5'd21: ref_y = 5'd17;
                    5'd22: ref_y = 5'd17; 5'd23: ref_y = 5'd17;
                    5'd24: ref_y = 5'd16; 5'd25: ref_y = 5'd15;
                    5'd26: ref_y = 5'd14; 5'd27: ref_y = 5'd13;
                    5'd28: ref_y = 5'd12; 5'd29: ref_y = 5'd10;
                    default: ref_y = 5'd10;
                endcase
            end
            3'd4: begin
                unique case (w_x)
                    5'd0:  ref_y = 5'd10; 5'd1:  ref_y = 5'd8;
                    5'd2:  ref_y = 5'd6;  5'd3:  ref_y = 5'd5;
                    5'd4:  ref_y = 5'd5;  5'd5:  ref_y = 5'd6;
                    5'd6:  ref_y = 5'd7;  5'd7:  ref_y = 5'd7;
                    5'd8:  ref_y = 5'd7;  5'd9:  ref_y = 5'd6;
                    5'd10: ref_y = 5'd5;  5'd11: ref_y = 5'd5;
                    5'd12: ref_y = 5'd5;  5'd13: ref_y = 5'd7;
                    5'd14: ref_y = 5'd9;  5'd15: ref_y = 5'd11;
                    5'd16: ref_y = 5'd13; 5'd17: ref_y = 5'd15;
                    5'd18: ref_y = 5'd15; 5'd19: ref_y = 5'd15;
                    5'd20: ref_y = 5'd14; 5'd21: ref_y = 5'd13;
                    5'd22: ref_y = 5'd13; 5'd23: ref_y = 5'd13;
                    5'd24: ref_y = 5'd14; 5'd25: ref_y = 5'd15;
                    5'd26: ref_y = 5'd15; 5'd27: ref_y = 5'd14;
                    5'd28: ref_y = 5'd12; 5'd29: ref_y = 5'd10;
                    default: ref_y = 5'd10;
                endcase
            end
            3'd5: begin
                unique case (w_x)
                    5'd0:  ref_y = 5'd10; 5'd1:  ref_y = 5'd8;
                    5'd2:  ref_y = 5'd7;  5'd3:  ref_y = 5'd6;
                    5'd4:  ref_y = 5'd5;  5'd5:  ref_y = 5'd6;
                    5'd6:  ref_y = 5'd7;  5'd7:  ref_y = 5'd9;
                    5'd8:  ref_y = 5'd12; 5'd9:  ref_y = 5'd14;
                    5'd10: ref_y = 5'd16; 5'd11: ref_y = 5'd17;
                    5'd12: ref_y = 5'd16; 5'd13: ref_y = 5'd14;
                    5'd14: ref_y = 5'd12; 5'd15: ref_y = 5'd8;
                    5'd16: ref_y = 5'd6;  5'd17: ref_y = 5'd4;
                    5'd18: ref_y = 5'd3;  5'd19: ref_y = 5'd4;
                    5'd20: ref_y = 5'd6;  5'd21: ref_y = 5'd8;
                    5'd22: ref_y = 5'd11; 5'd23: ref_y = 5'd13;
                    5'd24: ref_y = 5'd14; 5'd25: ref_y = 5'd15;
                    5'd26: ref_y = 5'd14; 5'd27: ref_y = 5'd13;
                    5'd28: ref_y = 5'd12; 5'd29: ref_y = 5'd10;
                    default: ref_y = 5'd10;
                endcase
            end
            default: ref_y = 5'd10;
        endcase
    end

    logic [4:0] dy;
    logic       draw_line;
    assign dy = (w_y > ref_y) ? (w_y - ref_y) : (ref_y - w_y);
    assign draw_line = in_canvas && (dy <= 5'd1);

    logic [7:0] icon_bg_r, icon_bg_g, icon_bg_b;
    logic [7:0] icon_line_r, icon_line_g, icon_line_b;
    logic       wave_active;
    assign wave_active = ({1'b0, wave_box} == wave_idx);
    always_comb begin
        if (wave_active) begin
            icon_bg_r   = 8'h40; icon_bg_g   = 8'h30; icon_bg_b   = 8'h60;
            icon_line_r = 8'hFF; icon_line_g = 8'hD0; icon_line_b = 8'h30;
        end else begin
            icon_bg_r   = 8'h18; icon_bg_g   = 8'h18; icon_bg_b   = 8'h20;
            icon_line_r = 8'h80; icon_line_g = 8'h80; icon_line_b = 8'h80;
        end
    end

    // ================================================================
    // tile 解码 (含 state)
    // ================================================================
    logic [1:0] t0_col, t1_col;
    logic [8:0] t0_y,   t1_y;
    logic       t0_act, t1_act;
    logic [1:0] t0_state, t1_state;
    assign t0_col   = tile_word_lo[15:14];
    assign t0_y     = tile_word_lo[13:5];
    assign t0_act   = tile_word_lo[4];
    assign t0_state = tile_word_lo[2:1];
    assign t1_col   = tile_word_lo[31:30];
    assign t1_y     = tile_word_lo[29:21];
    assign t1_act   = tile_word_lo[20];
    assign t1_state = tile_word_lo[17:16];

    // ================================================================
    // 钢琴模式 (game_active=0) tile 几何
    // ================================================================
    logic [9:0] m1_x_rel;
    logic [2:0] m1_cur_col;
    logic       m1_in_x, m1_in_y;
    assign m1_in_x   = (DrawX >= M1_COL_X0) && (DrawX < (M1_COL_X0 + 4*M1_COL_W));
    assign m1_x_rel  = m1_in_x ? (DrawX - M1_COL_X0) : 10'd0;
    assign m1_cur_col= m1_in_x ? m1_x_rel[9:0] / M1_COL_W : 3'd4;
    assign m1_in_y   = (DrawY >= TILE_AREA_Y0) && (DrawY < TILE_AREA_Y1);

    logic m1_on_t0, m1_on_t1, m1_on_any_tile;
    assign m1_on_t0 = t0_act && m1_in_x && m1_in_y && (m1_cur_col == {1'b0, t0_col})
                       && (DrawY >= t0_y) && (DrawY < (t0_y + TILE_H));
    assign m1_on_t1 = t1_act && m1_in_x && m1_in_y && (m1_cur_col == {1'b0, t1_col})
                       && (DrawY >= t1_y) && (DrawY < (t1_y + TILE_H));
    assign m1_on_any_tile = m1_on_t0 | m1_on_t1;

    logic [9:0] m1_col_local_x;
    logic       m1_on_col_border;
    assign m1_col_local_x   = m1_in_x ? (m1_x_rel - m1_cur_col * M1_COL_W) : 10'd0;
    assign m1_on_col_border = m1_in_x && m1_in_y &&
                              ((m1_col_local_x < 10'd1) || (m1_col_local_x >= (M1_COL_W - 10'd1)));

    // ================================================================
    // 游戏模式 tile 几何 (不再受 g_in_fall_y 限制, 整个游戏区都可以画)
    // ================================================================
    logic [9:0] g_x_rel;
    logic [2:0] g_cur_col;
    logic       g_in_area_x;
    assign g_in_area_x = (DrawX >= G_AREA_X0) && (DrawX < G_AREA_X1);
    assign g_x_rel     = g_in_area_x ? (DrawX - G_AREA_X0) : 10'd0;
    assign g_cur_col   = g_in_area_x ? g_x_rel[9:0] / G_COL_W : 3'd4;

    logic g_on_t0, g_on_t1, g_on_any_tile;
    assign g_on_t0 = t0_act && g_in_area_x && (g_cur_col == {1'b0, t0_col})
                      && (DrawY >= t0_y) && (DrawY < (t0_y + TILE_H));
    assign g_on_t1 = t1_act && g_in_area_x && (g_cur_col == {1'b0, t1_col})
                      && (DrawY >= t1_y) && (DrawY < (t1_y + TILE_H));
    assign g_on_any_tile = g_on_t0 | g_on_t1;

    // 当前像素属于哪个 tile (用于颜色选择)
    logic [1:0] cur_tile_state;
    always_comb begin
        cur_tile_state = 2'd0;
        if      (g_on_t0) cur_tile_state = t0_state;
        else if (g_on_t1) cur_tile_state = t1_state;
    end

    // tile 颜色按 state
    logic [7:0] tile_r, tile_g, tile_b;
    always_comb begin
        unique case (cur_tile_state)
            2'd0: begin tile_r = 8'hC0; tile_g = 8'hC0; tile_b = 8'hFF; end // NORMAL: 浅紫
            2'd1: begin tile_r = 8'h40; tile_g = 8'hFF; tile_b = 8'h60; end // HIT: 绿
            2'd2: begin tile_r = 8'hFF; tile_g = 8'hD0; tile_b = 8'h30; end // PERFECT: 金
            2'd3: begin tile_r = 8'h40; tile_g = 8'h40; tile_b = 8'h40; end // MISSED: 暗灰
            default: begin tile_r = 8'hC0; tile_g = 8'hC0; tile_b = 8'hFF; end
        endcase
    end

    // 列分隔线 (整列高度)
    logic [9:0] g_col_local_x;
    logic       g_on_col_border;
    assign g_col_local_x   = g_in_area_x ? (g_x_rel - g_cur_col * G_COL_W) : 10'd0;
    assign g_on_col_border = g_in_area_x && (g_col_local_x < 10'd1);

    // 按键框
    logic g_in_keypad_y, g_in_keypad;
    assign g_in_keypad_y = (DrawY >= G_KEYPAD_Y0) && (DrawY < G_KEYPAD_Y1);
    assign g_in_keypad   = g_in_area_x && g_in_keypad_y;
    logic g_on_keypad_border;
    assign g_on_keypad_border = g_in_keypad &&
                                ((DrawY < G_KEYPAD_Y0 + 10'd2) ||
                                 (DrawY >= G_KEYPAD_Y1 - 10'd2) ||
                                 (g_col_local_x < 10'd2) ||
                                 (g_col_local_x >= (G_COL_W - 10'd2)));

    // ASDF 按下指示 (keymask[3:0])
    logic g_key_lit;
    assign g_key_lit = (g_cur_col < 3'd4) ? keymask[g_cur_col] : 1'b0;

    // 错音闪红 (keymask[15:12])
    logic g_col_flash;
    assign g_col_flash = (g_cur_col < 3'd4) ? keymask[12 + g_cur_col] : 1'b0;

    // 地板
    logic g_in_floor;
    assign g_in_floor = g_in_area_x && (DrawY >= 10'd440);

    // ================================================================
    // 侧栏
    // ================================================================
    logic in_sidebar;
    assign in_sidebar = (DrawX >= SB_X0) && (DrawX < SB_X1);

    // 分数: keymask[11:4] = score+128 (range -128..+127, 实际游戏 -10..+20)
    //   score < 0  -> 空条 (但整框红色描边)
    //   score = 0  -> 空条 (普通描边)
    //   score 1..9 -> 黄色填充条, 长度 = score * 7px
    //   score >= 10 -> 绿色填充条
    //   score >= 20 -> 满条 (140 px)
    logic [7:0] score_offset;
    assign score_offset = keymask[11:4];

    logic score_negative;
    assign score_negative = (score_offset < 8'd128);

    logic [9:0] score_bar_w;
    always_comb begin
        if (score_offset < 8'd128)        score_bar_w = 10'd0;       // 负分: 空条
        else if (score_offset > 8'd148)   score_bar_w = SCORE_BAR_W; // > 20 满
        else                              score_bar_w = (score_offset - 8'd128) * 10'd7;
    end

    logic in_score_bar_box;
    logic in_score_bar_fill;
    assign in_score_bar_box  = in_sidebar &&
                                (DrawX >= SCORE_BAR_X0) && (DrawX < SCORE_BAR_X1) &&
                                (DrawY >= SCORE_BAR_Y0) && (DrawY < SCORE_BAR_Y1);
    assign in_score_bar_fill = in_score_bar_box &&
                                (DrawX < SCORE_BAR_X0 + score_bar_w);

    // 填充色: 1..9 黄, >=10 绿
    logic [7:0] score_r, score_g, score_b;
    always_comb begin
        if (score_offset < 8'd138)      begin score_r = 8'hFF; score_g = 8'hD0; score_b = 8'h30; end
        else                            begin score_r = 8'h40; score_g = 8'hFF; score_b = 8'h60; end
    end

    // 侧栏分隔横线
    logic sb_divider;
    assign sb_divider = in_sidebar && ((DrawY == 10'd44) || (DrawY == 10'd200) || (DrawY == 10'd320));

    logic on_main_split;
    assign on_main_split = (DrawX >= G_AREA_X1 - 10'd1) && (DrawX < G_AREA_X1 + 10'd1);

    // ================================================================
    // 最终颜色
    // ================================================================
    always_comb begin
        if (game_active) begin
            //=========== 游戏模式 ===========
            R = 8'h05; G = 8'h05; B = 8'h10;     // 默认黑底

            // 游戏区背景 (整个 0..480 x 都是)
            if (g_in_area_x && (DrawY < G_KEYPAD_Y0 || DrawY >= 10'd440)) begin
                R = 8'h08; G = 8'h08; B = 8'h20;
            end

            // 列分隔线 (从顶到底)
            if (g_on_col_border)
                begin R = 8'h30; G = 8'h30; B = 8'h50; end

            // 按键框
            if (g_in_keypad) begin
                if (g_on_keypad_border)              begin R = 8'h60; G = 8'h60; B = 8'h80; end
                else if (g_col_flash)                begin R = 8'hFF; G = 8'h30; B = 8'h30; end // 错音红闪
                else if (g_key_lit)                  begin R = 8'h80; G = 8'hFF; B = 8'hFF; end // 按下青色
                else                                 begin R = 8'h18; G = 8'h18; B = 8'h28; end
            end

            // 地板
            if (g_in_floor && !g_in_keypad)
                begin R = 8'h10; G = 8'h10; B = 8'h18; end

            // tile (优先级最高, 覆盖按键框和地板, 让 tile 穿过去)
            if (g_on_any_tile)
                begin R = tile_r; G = tile_g; B = tile_b; end

            // 主区/侧栏分隔
            if (on_main_split)
                begin R = 8'h40; G = 8'h40; B = 8'h60; end

            // 侧栏
            if (in_sidebar) begin
                R = 8'h10; G = 8'h10; B = 8'h18;
                if (sb_divider) begin R = 8'h40; G = 8'h40; B = 8'h60; end
                // 分数条空白部分: 负分时红色高亮提醒, 否则深灰
                if (in_score_bar_box && !in_score_bar_fill) begin
                    if (score_negative) begin R = 8'h60; G = 8'h10; B = 8'h10; end
                    else                begin R = 8'h25; G = 8'h25; B = 8'h35; end
                end
                if (in_score_bar_fill)
                    begin R = score_r; G = score_g; B = score_b; end
            end

        end else begin
            //=========== 钢琴模式 (M1 沿用) ===========
            if (m1_on_any_tile) begin
                R = 8'hC0; G = 8'hC0; B = 8'hFF;
            end
            else if (m1_in_y && m1_in_x && m1_on_col_border) begin
                R = 8'h40; G = 8'h40; B = 8'h60;
            end
            else if (m1_in_y && m1_in_x) begin
                R = 8'h10; G = 8'h10; B = 8'h30;
            end
            else if (in_wave_fill) begin
                if (draw_line)
                    begin R = icon_line_r; G = icon_line_g; B = icon_line_b; end
                else
                    begin R = icon_bg_r;   G = icon_bg_g;   B = icon_bg_b;   end
            end
            else if (in_oct_fill) begin
                if (oct_box_active)       begin R = 8'hFF; G = 8'hD0; B = 8'h30; end
                else if (oct_box == 4'd4) begin R = 8'h60; G = 8'h60; B = 8'h80; end
                else                      begin R = 8'h30; G = 8'h30; B = 8'h40; end
            end
            else if (black_hit) begin
                if      (keymask[black_semi])      begin R = 8'hFF; G = 8'hA0; B = 8'h00; end
                else if (auto_keymask[black_semi]) begin R = 8'h00; G = 8'hE8; B = 8'hD0; end
                else                               begin R = 8'h10; G = 8'h10; B = 8'h10; end
            end
            else if (in_key_x && in_key_y) begin
                if ((x_in_white < BORDER_W) || (x_in_white >= (KEY_W - BORDER_W)))
                                                   begin R = 8'h00; G = 8'h00; B = 8'h00; end
                else if (white_n < 4'd14 && keymask[white_semi])
                                                   begin R = 8'hFF; G = 8'hD0; B = 8'h30; end
                else if (white_n < 4'd14 && auto_keymask[white_semi])
                                                   begin R = 8'h00; G = 8'hE8; B = 8'hD0; end
                else                               begin R = 8'hFF; G = 8'hFF; B = 8'hFF; end
            end
            else if (in_key_y)                     begin R = 8'h20; G = 8'h20; B = 8'h20; end
            else if ((DrawY >= DIVIDER_Y0) && (DrawY < KEY_AREA_Y0))
                                                   begin R = 8'h40; G = 8'h40; B = 8'h60; end
            else                                   begin R = 8'h00; G = 8'h00; B = 8'h00; end
        end
    end

endmodule
