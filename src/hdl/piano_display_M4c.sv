//=============================================================================
// piano_display_M4c.sv  --  M4b + 修正下落滑入 + 侧栏简化
//
// 改动:
//   - tile y 编码改成 (y_top + 40), 范围 -40..471 → 9-bit 0..511
//     让 tile 可以从 y<0 滑入屏幕 (HDL 用 signed 比较)
//   - 侧栏简化: 只保留 3 颗大星 + 进度条, 删掉 score bar
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
    // 几何
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

    localparam logic [9:0] TILE_AREA_Y0 = 10'd30;
    localparam logic [9:0] TILE_AREA_Y1 = 10'd160;
    localparam logic [9:0] M1_COL_W     = 10'd140;
    localparam logic [9:0] M1_COL_X0    = 10'd40;

    localparam logic [9:0] G_AREA_X0    = 10'd0;
    localparam logic [9:0] G_AREA_X1    = 10'd480;
    localparam logic [9:0] G_COL_W      = 10'd120;
    localparam logic [9:0] G_KEYPAD_Y0  = 10'd400;
    localparam logic [9:0] G_KEYPAD_Y1  = 10'd440;
    localparam logic [9:0] SB_X0        = 10'd480;
    localparam logic [9:0] SB_X1        = 10'd640;
    localparam logic [9:0] TILE_H       = 10'd40;

    // 三星 (M4c: 加大)
    localparam logic [9:0] STAR1_CX     = 10'd520;
    localparam logic [9:0] STAR2_CX     = 10'd560;
    localparam logic [9:0] STAR3_CX     = 10'd600;
    localparam logic [9:0] STAR_CY      = 10'd45;
    localparam logic [9:0] STAR_R       = 10'd20;

    // 进度条 (下移, 加宽)
    localparam logic [9:0] PROG_Y0      = 10'd100;
    localparam logic [9:0] PROG_Y1      = 10'd125;
    localparam logic [9:0] PROG_X0      = 10'd490;
    localparam logic [9:0] PROG_X1      = 10'd630;
    localparam logic [9:0] PROG_W       = PROG_X1 - PROG_X0;

    // SELECT 屏卡片
    localparam logic [9:0] CARD_X0      = 10'd80;
    localparam logic [9:0] CARD_X1      = 10'd400;
    localparam logic [9:0] CARD1_Y0     = 10'd80;
    localparam logic [9:0] CARD1_Y1     = 10'd160;
    localparam logic [9:0] CARD2_Y0     = 10'd180;
    localparam logic [9:0] CARD2_Y1     = 10'd260;
    localparam logic [9:0] CARD3_Y0     = 10'd280;
    localparam logic [9:0] CARD3_Y1     = 10'd360;

    localparam logic [9:0] DIG_X0       = 10'd215;
    localparam logic [9:0] DIG_X1       = 10'd265;
    localparam logic [9:0] DIG_Y0       = 10'd190;
    localparam logic [9:0] DIG_Y1       = 10'd260;

    localparam logic [9:0] BIG_CX       = 10'd240;
    localparam logic [9:0] BIG_CY       = 10'd220;

    // ================================================================
    // 状态解码
    // ================================================================
    logic [2:0] game_st;
    logic [1:0] sel_song;
    logic [1:0] cd_val;
    logic [6:0] song_progress;
    assign game_st       = auto_keymask[2:0];
    assign sel_song      = auto_keymask[4:3];
    assign cd_val        = auto_keymask[6:5];
    assign song_progress = auto_keymask[14:8];

    logic state_manual, state_auto, state_select, state_countdown;
    logic state_playing, state_paused, state_win, state_lose;
    assign state_manual    = (game_st == 3'd0);
    assign state_auto      = (game_st == 3'd1);
    assign state_select    = (game_st == 3'd2);
    assign state_countdown = (game_st == 3'd3);
    assign state_playing   = (game_st == 3'd4);
    assign state_paused    = (game_st == 3'd5);
    assign state_win       = (game_st == 3'd6);
    assign state_lose      = (game_st == 3'd7);

    // ================================================================
    // 钢琴模式 几何
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
    // tile 解码 (M4c: y 加 offset)
    // ================================================================
    logic [1:0] t0_col, t1_col;
    logic [8:0] t0_y_raw,   t1_y_raw;
    logic       t0_act, t1_act;
    logic [1:0] t0_state, t1_state;
    assign t0_col   = tile_word_lo[15:14];
    assign t0_y_raw = tile_word_lo[13:5];
    assign t0_act   = tile_word_lo[4];
    assign t0_state = tile_word_lo[2:1];
    assign t1_col   = tile_word_lo[31:30];
    assign t1_y_raw = tile_word_lo[29:21];
    assign t1_act   = tile_word_lo[20];
    assign t1_state = tile_word_lo[17:16];

    // 真实 y_top (signed) = encoded - 40
    logic signed [10:0] t0_y_real, t1_y_real;
    assign t0_y_real = $signed({2'b00, t0_y_raw}) - 11'sd40;
    assign t1_y_real = $signed({2'b00, t1_y_raw}) - 11'sd40;

    logic signed [10:0] dy_signed;
    assign dy_signed = $signed({1'b0, DrawY});

    // 钢琴模式 tile (M1, 沿用 unsigned)
    logic [9:0] m1_x_rel;
    logic [2:0] m1_cur_col;
    logic       m1_in_x, m1_in_y;
    assign m1_in_x   = (DrawX >= M1_COL_X0) && (DrawX < (M1_COL_X0 + 4*M1_COL_W));
    assign m1_x_rel  = m1_in_x ? (DrawX - M1_COL_X0) : 10'd0;
    assign m1_cur_col= m1_in_x ? m1_x_rel[9:0] / M1_COL_W : 3'd4;
    assign m1_in_y   = (DrawY >= TILE_AREA_Y0) && (DrawY < TILE_AREA_Y1);

    logic m1_on_t0, m1_on_t1, m1_on_any_tile;
    assign m1_on_t0 = t0_act && m1_in_x && m1_in_y && (m1_cur_col == {1'b0, t0_col})
                       && (dy_signed >= t0_y_real) && (dy_signed < (t0_y_real + 11'sd40));
    assign m1_on_t1 = t1_act && m1_in_x && m1_in_y && (m1_cur_col == {1'b0, t1_col})
                       && (dy_signed >= t1_y_real) && (dy_signed < (t1_y_real + 11'sd40));
    assign m1_on_any_tile = m1_on_t0 | m1_on_t1;

    logic [9:0] m1_col_local_x;
    logic       m1_on_col_border;
    assign m1_col_local_x   = m1_in_x ? (m1_x_rel - m1_cur_col * M1_COL_W) : 10'd0;
    assign m1_on_col_border = m1_in_x && m1_in_y &&
                              ((m1_col_local_x < 10'd1) || (m1_col_local_x >= (M1_COL_W - 10'd1)));

    // 游戏模式 tile (M4c: signed compare for slide-in)
    logic [9:0] g_x_rel;
    logic [2:0] g_cur_col;
    logic       g_in_area_x;
    assign g_in_area_x = (DrawX >= G_AREA_X0) && (DrawX < G_AREA_X1);
    assign g_x_rel     = g_in_area_x ? (DrawX - G_AREA_X0) : 10'd0;
    assign g_cur_col   = g_in_area_x ? g_x_rel[9:0] / G_COL_W : 3'd4;

    logic g_on_t0, g_on_t1, g_on_any_tile;
    assign g_on_t0 = t0_act && g_in_area_x && (g_cur_col == {1'b0, t0_col})
                      && (dy_signed >= t0_y_real)
                      && (dy_signed < (t0_y_real + 11'sd40));
    assign g_on_t1 = t1_act && g_in_area_x && (g_cur_col == {1'b0, t1_col})
                      && (dy_signed >= t1_y_real)
                      && (dy_signed < (t1_y_real + 11'sd40));
    assign g_on_any_tile = g_on_t0 | g_on_t1;

    logic [1:0] cur_tile_state;
    always_comb begin
        cur_tile_state = 2'd0;
        if      (g_on_t0) cur_tile_state = t0_state;
        else if (g_on_t1) cur_tile_state = t1_state;
    end

    logic [7:0] tile_r, tile_g, tile_b;
    always_comb begin
        unique case (cur_tile_state)
            2'd0: begin tile_r = 8'hC0; tile_g = 8'hC0; tile_b = 8'hFF; end
            2'd1: begin tile_r = 8'h40; tile_g = 8'hFF; tile_b = 8'h60; end
            2'd2: begin tile_r = 8'hFF; tile_g = 8'hD0; tile_b = 8'h30; end
            2'd3: begin tile_r = 8'h40; tile_g = 8'h40; tile_b = 8'h40; end
            default: begin tile_r = 8'hC0; tile_g = 8'hC0; tile_b = 8'hFF; end
        endcase
    end

    logic [9:0] g_col_local_x;
    logic       g_on_col_border;
    assign g_col_local_x   = g_in_area_x ? (g_x_rel - g_cur_col * G_COL_W) : 10'd0;
    assign g_on_col_border = g_in_area_x && (g_col_local_x < 10'd1);

    logic g_in_keypad_y, g_in_keypad;
    assign g_in_keypad_y = (DrawY >= G_KEYPAD_Y0) && (DrawY < G_KEYPAD_Y1);
    assign g_in_keypad   = g_in_area_x && g_in_keypad_y;
    logic g_on_keypad_border;
    assign g_on_keypad_border = g_in_keypad &&
                                ((DrawY < G_KEYPAD_Y0 + 10'd2) ||
                                 (DrawY >= G_KEYPAD_Y1 - 10'd2) ||
                                 (g_col_local_x < 10'd2) ||
                                 (g_col_local_x >= (G_COL_W - 10'd2)));

    logic g_key_lit;
    assign g_key_lit = (g_cur_col < 3'd4) ? keymask[g_cur_col] : 1'b0;
    logic g_col_flash;
    assign g_col_flash = (g_cur_col < 3'd4) ? keymask[12 + g_cur_col] : 1'b0;
    logic g_in_floor;
    assign g_in_floor = g_in_area_x && (DrawY >= 10'd440);

    // 三星
    logic [7:0] score_offset;
    assign score_offset = keymask[11:4];
    logic star1_filled, star2_filled, star3_filled;
    assign star1_filled = (score_offset >= 8'd133);
    assign star2_filled = (score_offset >= 8'd143);
    assign star3_filled = (score_offset >= 8'd153);

    function automatic logic in_diamond(input logic [9:0] cx, input logic [9:0] cy,
                                          input logic [9:0] r);
        logic [9:0] adx, ady_;
        begin
            adx  = (DrawX > cx) ? (DrawX - cx) : (cx - DrawX);
            ady_ = (DrawY > cy) ? (DrawY - cy) : (cy - DrawY);
            in_diamond = (adx + ady_) < r;
        end
    endfunction

    logic in_star1_shape, in_star2_shape, in_star3_shape;
    logic in_star1_inner, in_star2_inner, in_star3_inner;
    assign in_star1_shape = in_diamond(STAR1_CX, STAR_CY, STAR_R);
    assign in_star2_shape = in_diamond(STAR2_CX, STAR_CY, STAR_R);
    assign in_star3_shape = in_diamond(STAR3_CX, STAR_CY, STAR_R);
    assign in_star1_inner = in_diamond(STAR1_CX, STAR_CY, STAR_R - 10'd4);
    assign in_star2_inner = in_diamond(STAR2_CX, STAR_CY, STAR_R - 10'd4);
    assign in_star3_inner = in_diamond(STAR3_CX, STAR_CY, STAR_R - 10'd4);

    // 进度条
    logic [9:0] prog_w;
    assign prog_w = (song_progress * PROG_W) / 10'd127;
    logic in_prog_box, in_prog_fill;
    assign in_prog_box  = (DrawX >= PROG_X0) && (DrawX < PROG_X1) &&
                          (DrawY >= PROG_Y0) && (DrawY < PROG_Y1);
    assign in_prog_fill = in_prog_box && (DrawX < (PROG_X0 + prog_w));

    logic in_sidebar;
    assign in_sidebar = (DrawX >= SB_X0) && (DrawX < SB_X1);
    logic on_main_split;
    assign on_main_split = (DrawX >= G_AREA_X1 - 10'd1) && (DrawX < G_AREA_X1 + 10'd1);

    // SELECT 屏
    logic in_card1, in_card2, in_card3;
    assign in_card1 = (DrawX >= CARD_X0) && (DrawX < CARD_X1) &&
                       (DrawY >= CARD1_Y0) && (DrawY < CARD1_Y1);
    assign in_card2 = (DrawX >= CARD_X0) && (DrawX < CARD_X1) &&
                       (DrawY >= CARD2_Y0) && (DrawY < CARD2_Y1);
    assign in_card3 = (DrawX >= CARD_X0) && (DrawX < CARD_X1) &&
                       (DrawY >= CARD3_Y0) && (DrawY < CARD3_Y1);

    function automatic logic on_card_border_fn(input logic [9:0] cy0, input logic [9:0] cy1);
        on_card_border_fn = (DrawX < CARD_X0 + 10'd3) || (DrawX >= CARD_X1 - 10'd3) ||
                            (DrawY < cy0 + 10'd3)     || (DrawY >= cy1 - 10'd3);
    endfunction

    logic on_card1_border, on_card2_border, on_card3_border;
    assign on_card1_border = in_card1 && on_card_border_fn(CARD1_Y0, CARD1_Y1);
    assign on_card2_border = in_card2 && on_card_border_fn(CARD2_Y0, CARD2_Y1);
    assign on_card3_border = in_card3 && on_card_border_fn(CARD3_Y0, CARD3_Y1);

    function automatic logic in_card_star(input logic [9:0] cx, input logic [9:0] cy,
                                            input logic [9:0] r);
        logic [9:0] adx, ady_;
        begin
            adx  = (DrawX > cx) ? (DrawX - cx) : (cx - DrawX);
            ady_ = (DrawY > cy) ? (DrawY - cy) : (cy - DrawY);
            in_card_star = (adx + ady_) < r;
        end
    endfunction

    logic in_c1_star;
    logic in_c2_star_a, in_c2_star_b;
    logic in_c3_star_a, in_c3_star_b, in_c3_star_c;
    assign in_c1_star    = in_card_star(10'd360, 10'd120, 10'd10);
    assign in_c2_star_a  = in_card_star(10'd340, 10'd220, 10'd10);
    assign in_c2_star_b  = in_card_star(10'd370, 10'd220, 10'd10);
    assign in_c3_star_a  = in_card_star(10'd320, 10'd320, 10'd10);
    assign in_c3_star_b  = in_card_star(10'd350, 10'd320, 10'd10);
    assign in_c3_star_c  = in_card_star(10'd380, 10'd320, 10'd10);

    // COUNTDOWN 数字
    logic in_dig_area;
    assign in_dig_area = (DrawX >= DIG_X0) && (DrawX < DIG_X1) &&
                          (DrawY >= DIG_Y0) && (DrawY < DIG_Y1);
    logic [3:0] dpx, dpy;
    assign dpx = in_dig_area ? ((DrawX - DIG_X0) / 10'd10) : 4'd15;
    assign dpy = in_dig_area ? ((DrawY - DIG_Y0) / 10'd10) : 4'd15;

    logic dig_lit;
    always_comb begin
        dig_lit = 1'b0;
        if (in_dig_area && state_countdown) begin
            unique case (cd_val)
                2'd1: begin
                    if      (dpy == 4'd0) dig_lit = (dpx == 4'd2);
                    else if (dpy == 4'd1) dig_lit = (dpx == 4'd1) || (dpx == 4'd2);
                    else if (dpy == 4'd6) dig_lit = (dpx <= 4'd4);
                    else                  dig_lit = (dpx == 4'd2);
                end
                2'd2: begin
                    if      (dpy == 4'd0)                       dig_lit = (dpx <= 4'd4);
                    else if (dpy == 4'd1 || dpy == 4'd2)        dig_lit = (dpx == 4'd4);
                    else if (dpy == 4'd3)                       dig_lit = (dpx <= 4'd4);
                    else if (dpy == 4'd4 || dpy == 4'd5)        dig_lit = (dpx == 4'd0);
                    else if (dpy == 4'd6)                       dig_lit = (dpx <= 4'd4);
                end
                2'd3: begin
                    if      (dpy == 4'd0)                       dig_lit = (dpx <= 4'd4);
                    else if (dpy == 4'd1 || dpy == 4'd2)        dig_lit = (dpx == 4'd4);
                    else if (dpy == 4'd3)                       dig_lit = (dpx >= 4'd1) && (dpx <= 4'd4);
                    else if (dpy == 4'd4 || dpy == 4'd5)        dig_lit = (dpx == 4'd4);
                    else if (dpy == 4'd6)                       dig_lit = (dpx <= 4'd4);
                end
                default: dig_lit = 1'b0;
            endcase
        end
    end

    // WIN/LOSE 大星 / 大 X
    logic in_big_star1, in_big_star2, in_big_star3;
    assign in_big_star1 = in_diamond(10'd140, 10'd180, 10'd35);
    assign in_big_star2 = in_diamond(10'd240, 10'd180, 10'd35);
    assign in_big_star3 = in_diamond(10'd340, 10'd180, 10'd35);
    logic in_big_star1_inner, in_big_star2_inner, in_big_star3_inner;
    assign in_big_star1_inner = in_diamond(10'd140, 10'd180, 10'd30);
    assign in_big_star2_inner = in_diamond(10'd240, 10'd180, 10'd30);
    assign in_big_star3_inner = in_diamond(10'd340, 10'd180, 10'd30);

    logic [9:0] x_dx, x_dy;
    assign x_dx = (DrawX > BIG_CX) ? (DrawX - BIG_CX) : (BIG_CX - DrawX);
    assign x_dy = (DrawY > BIG_CY) ? (DrawY - BIG_CY) : (BIG_CY - DrawY);
    logic [9:0] diag_diff1;
    assign diag_diff1 = (x_dx > x_dy) ? (x_dx - x_dy) : (x_dy - x_dx);
    logic [10:0] sum_xy, sum_target, sum_diff;
    assign sum_xy     = {1'b0, DrawX} + {1'b0, DrawY};
    assign sum_target = {1'b0, BIG_CX} + {1'b0, BIG_CY};
    assign sum_diff = (sum_xy > sum_target) ? (sum_xy - sum_target) : (sum_target - sum_xy);

    logic in_big_x_diag1, in_big_x_diag2, in_big_x;
    assign in_big_x_diag1 = (diag_diff1 < 10'd6) && (x_dx < 10'd60) && (x_dy < 10'd60);
    assign in_big_x_diag2 = (sum_diff < 11'd6) && (x_dx < 10'd60) && (x_dy < 10'd60);
    assign in_big_x = in_big_x_diag1 || in_big_x_diag2;

    logic dim_overlay;
    assign dim_overlay = state_paused;

    logic [7:0] r_pre, g_pre, b_pre;

    always_comb begin
        r_pre = 8'h05; g_pre = 8'h05; b_pre = 8'h10;

        if (state_manual || state_auto) begin
            if (m1_on_any_tile) begin
                r_pre = 8'hC0; g_pre = 8'hC0; b_pre = 8'hFF;
            end
            else if (m1_in_y && m1_in_x && m1_on_col_border) begin
                r_pre = 8'h40; g_pre = 8'h40; b_pre = 8'h60;
            end
            else if (m1_in_y && m1_in_x) begin
                r_pre = 8'h10; g_pre = 8'h10; b_pre = 8'h30;
            end
            else if (in_wave_fill) begin
                if (draw_line) begin r_pre = icon_line_r; g_pre = icon_line_g; b_pre = icon_line_b; end
                else            begin r_pre = icon_bg_r;   g_pre = icon_bg_g;   b_pre = icon_bg_b;   end
            end
            else if (in_oct_fill) begin
                if (oct_box_active)       begin r_pre = 8'hFF; g_pre = 8'hD0; b_pre = 8'h30; end
                else if (oct_box == 4'd4) begin r_pre = 8'h60; g_pre = 8'h60; b_pre = 8'h80; end
                else                      begin r_pre = 8'h30; g_pre = 8'h30; b_pre = 8'h40; end
            end
            else if (black_hit) begin
                if      (keymask[black_semi])      begin r_pre = 8'hFF; g_pre = 8'hA0; b_pre = 8'h00; end
                else if (auto_keymask[black_semi]) begin r_pre = 8'h00; g_pre = 8'hE8; b_pre = 8'hD0; end
                else                               begin r_pre = 8'h10; g_pre = 8'h10; b_pre = 8'h10; end
            end
            else if (in_key_x && in_key_y) begin
                if ((x_in_white < BORDER_W) || (x_in_white >= (KEY_W - BORDER_W)))
                                                   begin r_pre = 8'h00; g_pre = 8'h00; b_pre = 8'h00; end
                else if (white_n < 4'd14 && keymask[white_semi])
                                                   begin r_pre = 8'hFF; g_pre = 8'hD0; b_pre = 8'h30; end
                else if (white_n < 4'd14 && auto_keymask[white_semi])
                                                   begin r_pre = 8'h00; g_pre = 8'hE8; b_pre = 8'hD0; end
                else                               begin r_pre = 8'hFF; g_pre = 8'hFF; b_pre = 8'hFF; end
            end
            else if (in_key_y)                     begin r_pre = 8'h20; g_pre = 8'h20; b_pre = 8'h20; end
            else if ((DrawY >= DIVIDER_Y0) && (DrawY < KEY_AREA_Y0))
                                                   begin r_pre = 8'h40; g_pre = 8'h40; b_pre = 8'h60; end
            else                                   begin r_pre = 8'h00; g_pre = 8'h00; b_pre = 8'h00; end

        end else if (state_select) begin
            r_pre = 8'h08; g_pre = 8'h08; b_pre = 8'h18;
            if (in_card1) begin
                if (on_card1_border) begin
                    if (sel_song == 2'd0) begin r_pre = 8'hFF; g_pre = 8'hD0; b_pre = 8'h30; end
                    else                   begin r_pre = 8'h40; g_pre = 8'h40; b_pre = 8'h50; end
                end else begin
                    r_pre = 8'h20; g_pre = 8'h60; b_pre = 8'h30;
                end
                if (in_c1_star) begin r_pre = 8'hFF; g_pre = 8'hE0; b_pre = 8'h40; end
            end
            if (in_card2) begin
                if (on_card2_border) begin
                    if (sel_song == 2'd1) begin r_pre = 8'hFF; g_pre = 8'hD0; b_pre = 8'h30; end
                    else                   begin r_pre = 8'h40; g_pre = 8'h40; b_pre = 8'h50; end
                end else begin
                    r_pre = 8'h60; g_pre = 8'h50; b_pre = 8'h20;
                end
                if (in_c2_star_a || in_c2_star_b)
                    begin r_pre = 8'hFF; g_pre = 8'hE0; b_pre = 8'h40; end
            end
            if (in_card3) begin
                if (on_card3_border) begin
                    if (sel_song == 2'd2) begin r_pre = 8'hFF; g_pre = 8'hD0; b_pre = 8'h30; end
                    else                   begin r_pre = 8'h40; g_pre = 8'h40; b_pre = 8'h50; end
                end else begin
                    r_pre = 8'h60; g_pre = 8'h25; b_pre = 8'h25;
                end
                if (in_c3_star_a || in_c3_star_b || in_c3_star_c)
                    begin r_pre = 8'hFF; g_pre = 8'hE0; b_pre = 8'h40; end
            end
            if (in_sidebar) begin r_pre = 8'h0E; g_pre = 8'h0E; b_pre = 8'h18; end
            if (on_main_split) begin r_pre = 8'h40; g_pre = 8'h40; b_pre = 8'h60; end

        end else begin
            r_pre = 8'h05; g_pre = 8'h05; b_pre = 8'h10;
            if (g_in_area_x && (DrawY < G_KEYPAD_Y0 || DrawY >= 10'd440)) begin
                r_pre = 8'h08; g_pre = 8'h08; b_pre = 8'h20;
            end
            if (g_on_col_border)
                begin r_pre = 8'h30; g_pre = 8'h30; b_pre = 8'h50; end
            if (g_in_keypad) begin
                if (g_on_keypad_border)              begin r_pre = 8'h60; g_pre = 8'h60; b_pre = 8'h80; end
                else if (g_col_flash)                begin r_pre = 8'hFF; g_pre = 8'h30; b_pre = 8'h30; end
                else if (g_key_lit)                  begin r_pre = 8'h80; g_pre = 8'hFF; b_pre = 8'hFF; end
                else                                 begin r_pre = 8'h18; g_pre = 8'h18; b_pre = 8'h28; end
            end
            if (g_in_floor && !g_in_keypad)
                begin r_pre = 8'h10; g_pre = 8'h10; b_pre = 8'h18; end
            if (g_on_any_tile)
                begin r_pre = tile_r; g_pre = tile_g; b_pre = tile_b; end
            if (on_main_split)
                begin r_pre = 8'h40; g_pre = 8'h40; b_pre = 8'h60; end

            if (in_sidebar) begin
                r_pre = 8'h10; g_pre = 8'h10; b_pre = 8'h18;
                if (in_star1_shape) begin
                    if (star1_filled) begin
                        if (in_star1_inner) begin r_pre = 8'hFF; g_pre = 8'hE0; b_pre = 8'h40; end
                        else                begin r_pre = 8'hC0; g_pre = 8'h90; b_pre = 8'h20; end
                    end else begin
                        if (in_star1_inner) begin r_pre = 8'h22; g_pre = 8'h22; b_pre = 8'h28; end
                        else                begin r_pre = 8'h45; g_pre = 8'h45; b_pre = 8'h50; end
                    end
                end
                if (in_star2_shape) begin
                    if (star2_filled) begin
                        if (in_star2_inner) begin r_pre = 8'hFF; g_pre = 8'hE0; b_pre = 8'h40; end
                        else                begin r_pre = 8'hC0; g_pre = 8'h90; b_pre = 8'h20; end
                    end else begin
                        if (in_star2_inner) begin r_pre = 8'h22; g_pre = 8'h22; b_pre = 8'h28; end
                        else                begin r_pre = 8'h45; g_pre = 8'h45; b_pre = 8'h50; end
                    end
                end
                if (in_star3_shape) begin
                    if (star3_filled) begin
                        if (in_star3_inner) begin r_pre = 8'hFF; g_pre = 8'hE0; b_pre = 8'h40; end
                        else                begin r_pre = 8'hC0; g_pre = 8'h90; b_pre = 8'h20; end
                    end else begin
                        if (in_star3_inner) begin r_pre = 8'h22; g_pre = 8'h22; b_pre = 8'h28; end
                        else                begin r_pre = 8'h45; g_pre = 8'h45; b_pre = 8'h50; end
                    end
                end
                if (in_prog_box && !in_prog_fill)
                    begin r_pre = 8'h25; g_pre = 8'h25; b_pre = 8'h35; end
                if (in_prog_fill)
                    begin r_pre = 8'h60; g_pre = 8'h80; b_pre = 8'hFF; end
            end

            if (state_countdown && dig_lit)
                begin r_pre = 8'hFF; g_pre = 8'hFF; b_pre = 8'hFF; end

            if (state_win) begin
                if (g_in_area_x && DrawY < G_KEYPAD_Y0) begin
                    r_pre = (r_pre >> 1);
                    g_pre = (g_pre >> 1) + 8'h60;
                    b_pre = (b_pre >> 1);
                end
                if (in_big_star1) begin
                    if (star1_filled) begin
                        if (in_big_star1_inner) begin r_pre = 8'hFF; g_pre = 8'hE0; b_pre = 8'h40; end
                        else                    begin r_pre = 8'hC0; g_pre = 8'h90; b_pre = 8'h20; end
                    end else begin
                        if (in_big_star1_inner) begin r_pre = 8'h22; g_pre = 8'h22; b_pre = 8'h28; end
                        else                    begin r_pre = 8'h45; g_pre = 8'h45; b_pre = 8'h50; end
                    end
                end
                if (in_big_star2) begin
                    if (star2_filled) begin
                        if (in_big_star2_inner) begin r_pre = 8'hFF; g_pre = 8'hE0; b_pre = 8'h40; end
                        else                    begin r_pre = 8'hC0; g_pre = 8'h90; b_pre = 8'h20; end
                    end else begin
                        if (in_big_star2_inner) begin r_pre = 8'h22; g_pre = 8'h22; b_pre = 8'h28; end
                        else                    begin r_pre = 8'h45; g_pre = 8'h45; b_pre = 8'h50; end
                    end
                end
                if (in_big_star3) begin
                    if (star3_filled) begin
                        if (in_big_star3_inner) begin r_pre = 8'hFF; g_pre = 8'hE0; b_pre = 8'h40; end
                        else                    begin r_pre = 8'hC0; g_pre = 8'h90; b_pre = 8'h20; end
                    end else begin
                        if (in_big_star3_inner) begin r_pre = 8'h22; g_pre = 8'h22; b_pre = 8'h28; end
                        else                    begin r_pre = 8'h45; g_pre = 8'h45; b_pre = 8'h50; end
                    end
                end
            end

            if (state_lose) begin
                if (g_in_area_x && DrawY < G_KEYPAD_Y0) begin
                    r_pre = (r_pre >> 1) + 8'h50;
                    g_pre = (g_pre >> 1);
                    b_pre = (b_pre >> 1);
                end
                if (in_big_x)
                    begin r_pre = 8'hFF; g_pre = 8'h40; b_pre = 8'h40; end
            end
        end
    end

    always_comb begin
        if (dim_overlay) begin
            R = r_pre >> 1;
            G = g_pre >> 1;
            B = b_pre >> 1;
        end else begin
            R = r_pre;
            G = g_pre;
            B = b_pre;
        end
    end

endmodule
