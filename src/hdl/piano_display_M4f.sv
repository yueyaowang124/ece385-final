//=============================================================================
// piano_display_M4f.sv  --  M4e + 全套 sprite (digit/star/win/lose)
//
// 5 个 BRAM:
//   tile_rom   120w × 160h × 4-bit (4 帧 NORMAL/HIT/PERFECT/MISSED, 19200 entries)
//   digit_rom  24w  × 240h × 4-bit (10 帧 1-9 然后 0,             5760 entries)
//   star_rom   40w  × 80h  × 4-bit (2 帧 filled/empty,             3200 entries)
//   win_rom    140w × 120h × 4-bit (1 帧 trophy,                  16800 entries)
//   lose_rom   140w × 120h × 4-bit (1 帧 broken heart,            16800 entries)
//
// 5 个 palette: tile_palette / digit_palette / star_palette / win_palette / lose_palette
//   (都是外部 module, 假定 idx 0 = 透明 #FFBBFF)
//
// 数字 sprite frame 映射 (画布上 0 在 9 后面):
//   digit value: 1 2 3 4 5 6 7 8 9 0
//   frame idx:   0 1 2 3 4 5 6 7 8 9
//   公式: frame = (digit == 0) ? 9 : (digit - 1)
//
// 显示位置:
//   COUNTDOWN: digit 4x scale (96×96) at game center (192..288, 180..276)
//   sidebar SCORE: 2 digit 2x scale (48×48), x=510..606, y=120..168
//   sidebar 3 stars: 40×40 native, y=10..50
//   WIN: 3 big stars 2x scale (80×80) at y=70..150,
//        + win sprite 140×120 at center (170..310, 180..300)
//   LOSE: lose sprite 140×120 at center (170..310, 180..300)
//=============================================================================
module piano_display (
    input  logic        clk_25MHz,
    input  logic [9:0]  DrawX,
    input  logic [9:0]  DrawY,
    input  logic [23:0] keymask,
    input  logic [23:0] auto_keymask,
    input  logic [3:0]  octave_idx,
    input  logic [2:0]  wave_idx,
    input  logic [31:0] tile_word_lo,
    input  logic [31:0] tile_word_hi,
    output logic [7:0]  R,
    output logic [7:0]  G,
    output logic [7:0]  B
);
    // ================================================================
    // 几何常量
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

    localparam logic [9:0] CARD_X0      = 10'd80;
    localparam logic [9:0] CARD_X1      = 10'd400;
    localparam logic [9:0] CARD1_Y0     = 10'd80;
    localparam logic [9:0] CARD1_Y1     = 10'd160;
    localparam logic [9:0] CARD2_Y0     = 10'd180;
    localparam logic [9:0] CARD2_Y1     = 10'd260;
    localparam logic [9:0] CARD3_Y0     = 10'd280;
    localparam logic [9:0] CARD3_Y1     = 10'd360;

    // ===== Sprite 显示位置 =====
    // 侧栏 3 颗小星 (40x40 native): y=10..50
    localparam logic [9:0] SB_STAR_Y0   = 10'd10;
    localparam logic [9:0] SB_STAR1_X0  = 10'd485;
    localparam logic [9:0] SB_STAR2_X0  = 10'd540;
    localparam logic [9:0] SB_STAR3_X0  = 10'd595;
    localparam logic [9:0] SB_STAR_W    = 10'd40;

    // 进度条 (沿用)
    localparam logic [9:0] PROG_Y0      = 10'd70;
    localparam logic [9:0] PROG_Y1      = 10'd90;
    localparam logic [9:0] PROG_X0      = 10'd490;
    localparam logic [9:0] PROG_X1      = 10'd630;
    localparam logic [9:0] PROG_W       = PROG_X1 - PROG_X0;

    // 侧栏 SCORE 数字 (2 digit, 2x scale = 48x48), y=120..168
    localparam logic [9:0] SCORE_Y0     = 10'd120;
    localparam logic [9:0] SCORE_TEN_X0 = 10'd520;   // 十位
    localparam logic [9:0] SCORE_ONE_X0 = 10'd572;   // 个位
    localparam logic [9:0] SCORE_DIG_W  = 10'd48;    // 24*2 scale
    localparam logic [9:0] SCORE_DIG_H  = 10'd48;

    // COUNTDOWN 大数字 (1 digit, 4x scale = 96x96)
    localparam logic [9:0] CD_X0        = 10'd192;
    localparam logic [9:0] CD_Y0        = 10'd180;
    localparam logic [9:0] CD_W         = 10'd96;
    localparam logic [9:0] CD_H         = 10'd96;

    // WIN 屏 3 颗大星 (2x scale, 80x80)
    localparam logic [9:0] BIG_STAR_Y0  = 10'd70;
    localparam logic [9:0] BIG_STAR1_X0 = 10'd80;
    localparam logic [9:0] BIG_STAR2_X0 = 10'd200;
    localparam logic [9:0] BIG_STAR3_X0 = 10'd320;
    localparam logic [9:0] BIG_STAR_W   = 10'd80;

    // WIN sprite 居中 (140x120 native)
    localparam logic [9:0] WIN_X0       = 10'd170;
    localparam logic [9:0] WIN_Y0       = 10'd180;
    localparam logic [9:0] WIN_W        = 10'd140;
    localparam logic [9:0] WIN_H        = 10'd120;

    // LOSE sprite 居中 (140x120 native)
    localparam logic [9:0] LOSE_X0      = 10'd170;
    localparam logic [9:0] LOSE_Y0      = 10'd180;
    localparam logic [9:0] LOSE_W       = 10'd140;
    localparam logic [9:0] LOSE_H       = 10'd120;

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

    logic in_game_ui;
    assign in_game_ui = !state_manual && !state_auto;

    // ================================================================
    // tile 解码 (M4d 沿用)
    // ================================================================
    logic [1:0] t0_col, t1_col, t2_col, t3_col;
    logic [8:0] t0_y_raw, t1_y_raw, t2_y_raw, t3_y_raw;
    logic       t0_act, t1_act, t2_act, t3_act;
    logic [1:0] t0_state, t1_state, t2_state, t3_state;
    assign t0_col   = tile_word_lo[15:14]; assign t0_y_raw = tile_word_lo[13:5];
    assign t0_act   = tile_word_lo[4];     assign t0_state = tile_word_lo[2:1];
    assign t1_col   = tile_word_lo[31:30]; assign t1_y_raw = tile_word_lo[29:21];
    assign t1_act   = tile_word_lo[20];    assign t1_state = tile_word_lo[17:16];
    assign t2_col   = tile_word_hi[15:14]; assign t2_y_raw = tile_word_hi[13:5];
    assign t2_act   = tile_word_hi[4];     assign t2_state = tile_word_hi[2:1];
    assign t3_col   = tile_word_hi[31:30]; assign t3_y_raw = tile_word_hi[29:21];
    assign t3_act   = tile_word_hi[20];    assign t3_state = tile_word_hi[17:16];

    logic signed [10:0] t0_y_real, t1_y_real, t2_y_real, t3_y_real;
    assign t0_y_real = $signed({2'b00, t0_y_raw}) - 11'sd40;
    assign t1_y_real = $signed({2'b00, t1_y_raw}) - 11'sd40;
    assign t2_y_real = $signed({2'b00, t2_y_raw}) - 11'sd40;
    assign t3_y_real = $signed({2'b00, t3_y_raw}) - 11'sd40;
    logic signed [10:0] dy_signed;
    assign dy_signed = $signed({1'b0, DrawY});

    // ================================================================
    // 钢琴模式 tile
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
                       && (dy_signed >= t0_y_real) && (dy_signed < (t0_y_real + 11'sd40));
    assign m1_on_t1 = t1_act && m1_in_x && m1_in_y && (m1_cur_col == {1'b0, t1_col})
                       && (dy_signed >= t1_y_real) && (dy_signed < (t1_y_real + 11'sd40));
    assign m1_on_any_tile = m1_on_t0 | m1_on_t1;
    logic [9:0] m1_col_local_x;
    logic       m1_on_col_border;
    assign m1_col_local_x   = m1_in_x ? (m1_x_rel - m1_cur_col * M1_COL_W) : 10'd0;
    assign m1_on_col_border = m1_in_x && m1_in_y &&
                              ((m1_col_local_x < 10'd1) || (m1_col_local_x >= (M1_COL_W - 10'd1)));

    // ================================================================
    // 游戏 tile 几何
    // ================================================================
    logic [9:0] g_x_rel;
    logic [2:0] g_cur_col;
    logic       g_in_area_x;
    assign g_in_area_x = (DrawX >= G_AREA_X0) && (DrawX < G_AREA_X1);
    assign g_x_rel     = g_in_area_x ? (DrawX - G_AREA_X0) : 10'd0;
    assign g_cur_col   = g_in_area_x ? g_x_rel[9:0] / G_COL_W : 3'd4;
    logic g_on_t0, g_on_t1, g_on_t2, g_on_t3, g_on_any_tile;
    assign g_on_t0 = t0_act && g_in_area_x && (g_cur_col == {1'b0, t0_col})
                      && (dy_signed >= t0_y_real) && (dy_signed < (t0_y_real + 11'sd40));
    assign g_on_t1 = t1_act && g_in_area_x && (g_cur_col == {1'b0, t1_col})
                      && (dy_signed >= t1_y_real) && (dy_signed < (t1_y_real + 11'sd40));
    assign g_on_t2 = t2_act && g_in_area_x && (g_cur_col == {1'b0, t2_col})
                      && (dy_signed >= t2_y_real) && (dy_signed < (t2_y_real + 11'sd40));
    assign g_on_t3 = t3_act && g_in_area_x && (g_cur_col == {1'b0, t3_col})
                      && (dy_signed >= t3_y_real) && (dy_signed < (t3_y_real + 11'sd40));
    assign g_on_any_tile = g_on_t0 | g_on_t1 | g_on_t2 | g_on_t3;

    logic [1:0] cur_tile_state;
    always_comb begin
        cur_tile_state = 2'd0;
        if      (g_on_t0) cur_tile_state = t0_state;
        else if (g_on_t1) cur_tile_state = t1_state;
        else if (g_on_t2) cur_tile_state = t2_state;
        else if (g_on_t3) cur_tile_state = t3_state;
    end
    logic signed [10:0] cur_tile_y_top;
    always_comb begin
        cur_tile_y_top = 11'sd0;
        if      (g_on_t0) cur_tile_y_top = t0_y_real;
        else if (g_on_t1) cur_tile_y_top = t1_y_real;
        else if (g_on_t2) cur_tile_y_top = t2_y_real;
        else if (g_on_t3) cur_tile_y_top = t3_y_real;
    end
    logic [9:0] g_col_local_x;
    assign g_col_local_x = g_in_area_x ? (g_x_rel - g_cur_col * G_COL_W) : 10'd0;
    logic [9:0] tile_local_y;
    assign tile_local_y = g_on_any_tile ? (DrawY - cur_tile_y_top[9:0]) : 10'd0;

    // tile ROM 地址
    logic [14:0] state_offset;
    always_comb begin
        unique case (cur_tile_state)
            2'd0: state_offset = 15'd0;
            2'd1: state_offset = 15'd4800;
            2'd2: state_offset = 15'd9600;
            2'd3: state_offset = 15'd14400;
            default: state_offset = 15'd0;
        endcase
    end
    logic [14:0] tile_local_y_15, g_col_local_x_15;
    assign tile_local_y_15  = {5'd0, tile_local_y};
    assign g_col_local_x_15 = {5'd0, g_col_local_x};
    logic [14:0] tile_addr;
    assign tile_addr = state_offset + tile_local_y_15 * 15'd120 + g_col_local_x_15;

    // ================================================================
    // SCORE 数字: 解 keymask 求 abs(score), 2-digit
    // ================================================================
    logic [7:0] score_offset;     // = score+128
    assign score_offset = keymask[11:4];
    logic signed [8:0] score_signed;
    assign score_signed = $signed({1'b0, score_offset}) - 9'sd128;
    logic [7:0] abs_score;
    assign abs_score = score_signed < 0 ? (8'd0 - score_offset + 8'd128) :
                                          (score_offset - 8'd128);
    logic [3:0] score_tens, score_ones;
    assign score_tens = abs_score / 8'd10;        // 0..9 (实际 0..3)
    assign score_ones = abs_score % 8'd10;        // 0..9
    logic score_negative;
    assign score_negative = (score_offset < 8'd128);

    // 数字 frame 映射: digit_value → ROM frame_idx
    function automatic [3:0] digit_to_frame(input [3:0] d);
        if (d == 4'd0) digit_to_frame = 4'd9;     // 0 在最后一帧
        else           digit_to_frame = d - 4'd1; // 1..9 → frame 0..8
    endfunction

    // ================================================================
    // 数字 sprite 区域计算 (combinational)
    // 同一帧屏幕上最多 1 处显示数字 (countdown 或 score, 二选一)
    // 用优先级: countdown > score (score 在 sidebar)
    // ================================================================

    // === COUNTDOWN 数字 (4x scale, 单数字) ===
    logic in_cd_region;
    logic [9:0] cd_local_x_screen, cd_local_y_screen;  // screen-local (0..95)
    logic [4:0] cd_local_x_rom, cd_local_y_rom;        // ROM-native (0..23)
    assign in_cd_region = state_countdown &&
                          (DrawX >= CD_X0) && (DrawX < CD_X0 + CD_W) &&
                          (DrawY >= CD_Y0) && (DrawY < CD_Y0 + CD_H);
    assign cd_local_x_screen = in_cd_region ? (DrawX - CD_X0) : 10'd0;
    assign cd_local_y_screen = in_cd_region ? (DrawY - CD_Y0) : 10'd0;
    assign cd_local_x_rom = cd_local_x_screen[9:2];   // /4
    assign cd_local_y_rom = cd_local_y_screen[9:2];

    logic [3:0] cd_frame;
    always_comb begin
        unique case (cd_val)
            2'd1:    cd_frame = digit_to_frame(4'd1);  // 1 → frame 0
            2'd2:    cd_frame = digit_to_frame(4'd2);  // 2 → frame 1
            2'd3:    cd_frame = digit_to_frame(4'd3);  // 3 → frame 2
            default: cd_frame = 4'd0;
        endcase
    end

    // === SCORE 数字 (2x scale, 2 digit) ===
    logic in_score_tens_region, in_score_ones_region;
    logic [9:0] sc_t_x, sc_t_y, sc_o_x, sc_o_y;
    logic [4:0] sc_t_rx, sc_t_ry, sc_o_rx, sc_o_ry;
    assign in_score_tens_region = in_game_ui &&
                                  (DrawX >= SCORE_TEN_X0) && (DrawX < SCORE_TEN_X0 + SCORE_DIG_W) &&
                                  (DrawY >= SCORE_Y0)     && (DrawY < SCORE_Y0 + SCORE_DIG_H);
    assign in_score_ones_region = in_game_ui &&
                                  (DrawX >= SCORE_ONE_X0) && (DrawX < SCORE_ONE_X0 + SCORE_DIG_W) &&
                                  (DrawY >= SCORE_Y0)     && (DrawY < SCORE_Y0 + SCORE_DIG_H);
    assign sc_t_x = in_score_tens_region ? (DrawX - SCORE_TEN_X0) : 10'd0;
    assign sc_t_y = in_score_tens_region ? (DrawY - SCORE_Y0)     : 10'd0;
    assign sc_o_x = in_score_ones_region ? (DrawX - SCORE_ONE_X0) : 10'd0;
    assign sc_o_y = in_score_ones_region ? (DrawY - SCORE_Y0)     : 10'd0;
    assign sc_t_rx = sc_t_x[9:1];   // /2
    assign sc_t_ry = sc_t_y[9:1];
    assign sc_o_rx = sc_o_x[9:1];
    assign sc_o_ry = sc_o_y[9:1];

    // 总的数字 ROM 地址 (优先级: countdown > score-tens > score-ones)
    logic [12:0] digit_addr;
    logic        in_digit_region;
    always_comb begin
        digit_addr = 13'd0;
        in_digit_region = 1'b0;
        if (in_cd_region) begin
            in_digit_region = 1'b1;
            digit_addr = ({9'd0, cd_frame} * 13'd576)
                       + ({8'd0, cd_local_y_rom} * 13'd24)
                       + {8'd0, cd_local_x_rom};
        end else if (in_score_tens_region) begin
            in_digit_region = 1'b1;
            digit_addr = ({9'd0, digit_to_frame(score_tens)} * 13'd576)
                       + ({8'd0, sc_t_ry} * 13'd24)
                       + {8'd0, sc_t_rx};
        end else if (in_score_ones_region) begin
            in_digit_region = 1'b1;
            digit_addr = ({9'd0, digit_to_frame(score_ones)} * 13'd576)
                       + ({8'd0, sc_o_ry} * 13'd24)
                       + {8'd0, sc_o_rx};
        end
    end

    // ================================================================
    // STAR sprite (40x40 per frame, 2 frames)
    //   frame 0 = filled (gold)
    //   frame 1 = empty  (gray)
    // 应用: 侧栏 3 颗 (40x40 native), WIN 屏 3 颗 (80x80 = 2x scale)
    // ================================================================

    // 三星阈值
    logic star1_filled, star2_filled, star3_filled;
    assign star1_filled = (score_offset >= 8'd133);   // score >= 5
    assign star2_filled = (score_offset >= 8'd143);   // score >= 15
    assign star3_filled = (score_offset >= 8'd153);   // score >= 25

    // 侧栏 3 小星
    logic in_sb_star1, in_sb_star2, in_sb_star3;
    assign in_sb_star1 = in_game_ui &&
                         (DrawX >= SB_STAR1_X0) && (DrawX < SB_STAR1_X0 + SB_STAR_W) &&
                         (DrawY >= SB_STAR_Y0)  && (DrawY < SB_STAR_Y0 + SB_STAR_W);
    assign in_sb_star2 = in_game_ui &&
                         (DrawX >= SB_STAR2_X0) && (DrawX < SB_STAR2_X0 + SB_STAR_W) &&
                         (DrawY >= SB_STAR_Y0)  && (DrawY < SB_STAR_Y0 + SB_STAR_W);
    assign in_sb_star3 = in_game_ui &&
                         (DrawX >= SB_STAR3_X0) && (DrawX < SB_STAR3_X0 + SB_STAR_W) &&
                         (DrawY >= SB_STAR_Y0)  && (DrawY < SB_STAR_Y0 + SB_STAR_W);

    // WIN 大星 (80x80 = 2x scale)
    logic in_big_star1, in_big_star2, in_big_star3;
    assign in_big_star1 = state_win &&
                          (DrawX >= BIG_STAR1_X0) && (DrawX < BIG_STAR1_X0 + BIG_STAR_W) &&
                          (DrawY >= BIG_STAR_Y0)  && (DrawY < BIG_STAR_Y0 + BIG_STAR_W);
    assign in_big_star2 = state_win &&
                          (DrawX >= BIG_STAR2_X0) && (DrawX < BIG_STAR2_X0 + BIG_STAR_W) &&
                          (DrawY >= BIG_STAR_Y0)  && (DrawY < BIG_STAR_Y0 + BIG_STAR_W);
    assign in_big_star3 = state_win &&
                          (DrawX >= BIG_STAR3_X0) && (DrawX < BIG_STAR3_X0 + BIG_STAR_W) &&
                          (DrawY >= BIG_STAR_Y0)  && (DrawY < BIG_STAR_Y0 + BIG_STAR_W);

    // 计算 star ROM 地址 (优先级: WIN 大星 > 侧栏小星)
    // frame: filled=0, empty=1
    logic [11:0] star_addr;
    logic        in_star_region;
    logic        star_filled_now;
    always_comb begin
        star_addr = 12'd0;
        in_star_region = 1'b0;
        star_filled_now = 1'b0;

        if (in_big_star1) begin
            in_star_region  = 1'b1; star_filled_now = star1_filled;
            // 2x scale, /2 to native
            star_addr = (star_filled_now ? 12'd0 : 12'd1600)
                      + (((DrawY - BIG_STAR_Y0) >> 1) * 12'd40)
                      + ((DrawX - BIG_STAR1_X0) >> 1);
        end else if (in_big_star2) begin
            in_star_region  = 1'b1; star_filled_now = star2_filled;
            star_addr = (star_filled_now ? 12'd0 : 12'd1600)
                      + (((DrawY - BIG_STAR_Y0) >> 1) * 12'd40)
                      + ((DrawX - BIG_STAR2_X0) >> 1);
        end else if (in_big_star3) begin
            in_star_region  = 1'b1; star_filled_now = star3_filled;
            star_addr = (star_filled_now ? 12'd0 : 12'd1600)
                      + (((DrawY - BIG_STAR_Y0) >> 1) * 12'd40)
                      + ((DrawX - BIG_STAR3_X0) >> 1);
        end else if (in_sb_star1) begin
            in_star_region  = 1'b1; star_filled_now = star1_filled;
            star_addr = (star_filled_now ? 12'd0 : 12'd1600)
                      + ((DrawY - SB_STAR_Y0) * 12'd40)
                      + (DrawX - SB_STAR1_X0);
        end else if (in_sb_star2) begin
            in_star_region  = 1'b1; star_filled_now = star2_filled;
            star_addr = (star_filled_now ? 12'd0 : 12'd1600)
                      + ((DrawY - SB_STAR_Y0) * 12'd40)
                      + (DrawX - SB_STAR2_X0);
        end else if (in_sb_star3) begin
            in_star_region  = 1'b1; star_filled_now = star3_filled;
            star_addr = (star_filled_now ? 12'd0 : 12'd1600)
                      + ((DrawY - SB_STAR_Y0) * 12'd40)
                      + (DrawX - SB_STAR3_X0);
        end
    end

    // ================================================================
    // WIN sprite 区域 (140x120 native, 居中)
    // ================================================================
    logic in_win_region;
    assign in_win_region = state_win &&
                           (DrawX >= WIN_X0) && (DrawX < WIN_X0 + WIN_W) &&
                           (DrawY >= WIN_Y0) && (DrawY < WIN_Y0 + WIN_H);
    logic [13:0] win_addr;
    assign win_addr = in_win_region ?
                      ((DrawY - WIN_Y0) * 14'd140 + (DrawX - WIN_X0)) : 14'd0;

    // ================================================================
    // LOSE sprite 区域 (140x120 native, 居中)
    // ================================================================
    logic in_lose_region;
    assign in_lose_region = state_lose &&
                            (DrawX >= LOSE_X0) && (DrawX < LOSE_X0 + LOSE_W) &&
                            (DrawY >= LOSE_Y0) && (DrawY < LOSE_Y0 + LOSE_H);
    logic [13:0] lose_addr;
    assign lose_addr = in_lose_region ?
                       ((DrawY - LOSE_Y0) * 14'd140 + (DrawX - LOSE_X0)) : 14'd0;

    // ================================================================
    // BRAM 实例化 (5 个 ROM, 都 1-cycle 延迟)
    // ================================================================
    logic [3:0] tile_idx, digit_idx, star_idx, win_idx, lose_idx;
    tile_rom  tile_rom_i  (.clka(clk_25MHz), .ena(1'b1), .addra(tile_addr),  .douta(tile_idx));
    digit_rom digit_rom_i (.clka(clk_25MHz), .ena(1'b1), .addra(digit_addr), .douta(digit_idx));
    star_rom  star_rom_i  (.clka(clk_25MHz), .ena(1'b1), .addra(star_addr),  .douta(star_idx));
    win_rom   win_rom_i   (.clka(clk_25MHz), .ena(1'b1), .addra(win_addr),   .douta(win_idx));
    lose_rom  lose_rom_i  (.clka(clk_25MHz), .ena(1'b1), .addra(lose_addr),  .douta(lose_idx));

    // Palette 实例化
    logic [3:0] tile_r4, tile_g4, tile_b4;
    logic [3:0] digit_r4, digit_g4, digit_b4;
    logic [3:0] star_r4, star_g4, star_b4;
    logic [3:0] win_r4, win_g4, win_b4;
    logic [3:0] lose_r4, lose_g4, lose_b4;
    tile_palette  tile_pal_i  (.index(tile_idx),  .red(tile_r4),  .green(tile_g4),  .blue(tile_b4));
    digit_palette digit_pal_i (.index(digit_idx), .red(digit_r4), .green(digit_g4), .blue(digit_b4));
    star_palette  star_pal_i  (.index(star_idx),  .red(star_r4),  .green(star_g4),  .blue(star_b4));
    win_palette   win_pal_i   (.index(win_idx),   .red(win_r4),   .green(win_g4),   .blue(win_b4));
    lose_palette  lose_pal_i  (.index(lose_idx),  .red(lose_r4),  .green(lose_g4),  .blue(lose_b4));

    // 4-bit → 8-bit
    logic [7:0] tile_r, tile_g, tile_b;
    logic [7:0] digit_r, digit_g, digit_b;
    logic [7:0] star_r, star_g, star_b;
    logic [7:0] win_r, win_g, win_b;
    logic [7:0] lose_r, lose_g, lose_b;
    assign {tile_r,  tile_g,  tile_b}  = {tile_r4, tile_r4,  tile_g4, tile_g4,  tile_b4, tile_b4};
    assign {digit_r, digit_g, digit_b} = {digit_r4,digit_r4, digit_g4,digit_g4, digit_b4,digit_b4};
    assign {star_r,  star_g,  star_b}  = {star_r4, star_r4,  star_g4, star_g4,  star_b4, star_b4};
    assign {win_r,   win_g,   win_b}   = {win_r4,  win_r4,   win_g4,  win_g4,   win_b4,  win_b4};
    assign {lose_r,  lose_g,  lose_b}  = {lose_r4, lose_r4,  lose_g4, lose_g4,  lose_b4, lose_b4};

    // 透明 (idx 0)
    logic tile_trans, digit_trans, star_trans, win_trans, lose_trans;
    assign tile_trans  = (tile_idx  == 4'h0);
    assign digit_trans = (digit_idx == 4'h0);
    assign star_trans  = (star_idx  == 4'h0);
    assign win_trans   = (win_idx   == 4'h0);
    assign lose_trans  = (lose_idx  == 4'h0);

    // ================================================================
    // 钢琴模式 / 八度 / 波形 icon / 黑白键 (M4d 沿用)
    // ================================================================
    logic [9:0] x_rel; logic [3:0] white_n; logic [5:0] x_in_white;
    logic in_key_x, in_key_y;
    assign in_key_x   = (DrawX >= KEY_LEFT) && (DrawX < KEY_RIGHT);
    assign in_key_y   = (DrawY >= KEY_AREA_Y0);
    assign x_rel      = in_key_x ? (DrawX - KEY_LEFT) : 10'd0;
    assign white_n    = in_key_x ? x_rel[9:0] / KEY_W : 4'd15;
    assign x_in_white = in_key_x ? x_rel[9:0] - (white_n * KEY_W) : 6'd0;

    logic [4:0] white_semi;
    always_comb begin
        unique case (white_n)
            4'd0:white_semi=5'd0;  4'd1:white_semi=5'd2;  4'd2:white_semi=5'd4;
            4'd3:white_semi=5'd5;  4'd4:white_semi=5'd7;  4'd5:white_semi=5'd9;
            4'd6:white_semi=5'd11; 4'd7:white_semi=5'd12; 4'd8:white_semi=5'd14;
            4'd9:white_semi=5'd16; 4'd10:white_semi=5'd17;4'd11:white_semi=5'd19;
            4'd12:white_semi=5'd21;4'd13:white_semi=5'd23;
            default: white_semi=5'd31;
        endcase
    end

    logic black_hit; logic [4:0] black_semi; logic in_black_y;
    assign in_black_y = (DrawY >= KEY_AREA_Y0) && (DrawY < KEY_AREA_Y0 + BLACK_KEY_H);
    always_comb begin
        black_hit=1'b0; black_semi=5'd0;
        if (in_black_y) begin
            if      ((DrawX >= 10'd80  - BLACK_HALF_W) && (DrawX < 10'd80  + BLACK_HALF_W)) begin black_hit=1'b1; black_semi=5'd1;  end
            else if ((DrawX >= 10'd120 - BLACK_HALF_W) && (DrawX < 10'd120 + BLACK_HALF_W)) begin black_hit=1'b1; black_semi=5'd3;  end
            else if ((DrawX >= 10'd200 - BLACK_HALF_W) && (DrawX < 10'd200 + BLACK_HALF_W)) begin black_hit=1'b1; black_semi=5'd6;  end
            else if ((DrawX >= 10'd240 - BLACK_HALF_W) && (DrawX < 10'd240 + BLACK_HALF_W)) begin black_hit=1'b1; black_semi=5'd8;  end
            else if ((DrawX >= 10'd280 - BLACK_HALF_W) && (DrawX < 10'd280 + BLACK_HALF_W)) begin black_hit=1'b1; black_semi=5'd10; end
            else if ((DrawX >= 10'd360 - BLACK_HALF_W) && (DrawX < 10'd360 + BLACK_HALF_W)) begin black_hit=1'b1; black_semi=5'd13; end
            else if ((DrawX >= 10'd400 - BLACK_HALF_W) && (DrawX < 10'd400 + BLACK_HALF_W)) begin black_hit=1'b1; black_semi=5'd15; end
            else if ((DrawX >= 10'd480 - BLACK_HALF_W) && (DrawX < 10'd480 + BLACK_HALF_W)) begin black_hit=1'b1; black_semi=5'd18; end
            else if ((DrawX >= 10'd520 - BLACK_HALF_W) && (DrawX < 10'd520 + BLACK_HALF_W)) begin black_hit=1'b1; black_semi=5'd20; end
            else if ((DrawX >= 10'd560 - BLACK_HALF_W) && (DrawX < 10'd560 + BLACK_HALF_W)) begin black_hit=1'b1; black_semi=5'd22; end
        end
    end

    logic in_oct_y, in_oct_x;
    logic [9:0] oct_x_rel; logic [3:0] oct_box;
    logic in_oct_fill, oct_box_active;
    assign in_oct_y       = (DrawY >= OCT_Y0) && (DrawY < OCT_Y1);
    assign in_oct_x       = (DrawX >= OCT_X0) && (DrawX < (OCT_X0 + 9*OCT_BOX_W));
    assign oct_x_rel      = in_oct_x ? (DrawX - OCT_X0) : 10'd0;
    assign oct_box        = in_oct_x ? oct_x_rel[9:0] / OCT_BOX_W : 4'd15;
    assign in_oct_fill    = in_oct_y && in_oct_x &&
                            ((oct_x_rel - oct_box * OCT_BOX_W) < OCT_BOX_FILL);
    assign oct_box_active = (oct_box == octave_idx);

    logic in_wave_y, in_wave_x;
    logic [9:0] wave_x_rel; logic [2:0] wave_box;
    logic [9:0] wave_local_x, wave_local_y;
    assign in_wave_y    = (DrawY >= WAVE_Y0) && (DrawY < WAVE_Y1);
    assign in_wave_x    = (DrawX >= WAVE_X0) && (DrawX < (WAVE_X0 + 6*WAVE_BOX_W));
    assign wave_x_rel   = in_wave_x ? (DrawX - WAVE_X0) : 10'd0;
    assign wave_box     = in_wave_x ? wave_x_rel[9:0] / WAVE_BOX_W : 3'd7;
    assign wave_local_x = in_wave_x ? (wave_x_rel - wave_box * WAVE_BOX_W) : 10'd0;
    assign wave_local_y = in_wave_y ? (DrawY - WAVE_Y0) : 10'd0;
    logic in_wave_fill;
    assign in_wave_fill = in_wave_y && in_wave_x && (wave_local_x < WAVE_FILL_W);
    logic [4:0] w_x, w_y; logic in_canvas;
    assign in_canvas = in_wave_fill && (wave_local_x >= 10'd4) && (wave_local_x < 10'd34)
                                    && (wave_local_y >= 10'd2) && (wave_local_y < 10'd22);
    assign w_x = in_canvas ? (wave_local_x - 10'd4) : 5'd0;
    assign w_y = in_canvas ? (wave_local_y - 10'd2) : 5'd0;
    logic [4:0] ref_y;
    always_comb begin
        ref_y = 5'd10;
        case (wave_box)
            3'd0: begin
                if      (w_x < 5'd2)  ref_y=5'd10;
                else if (w_x < 5'd14) ref_y=5'd4;
                else if (w_x < 5'd16) ref_y=5'd10;
                else if (w_x < 5'd28) ref_y=5'd16;
                else                  ref_y=5'd10;
            end
            3'd1: begin
                if (w_x < 5'd15) ref_y = 5'd17 - w_x;
                else             ref_y = 5'd3  + (w_x - 5'd15);
            end
            default: ref_y = 5'd10;
        endcase
    end
    logic [4:0] dy_local; logic draw_line;
    assign dy_local = (w_y > ref_y) ? (w_y - ref_y) : (ref_y - w_y);
    assign draw_line = in_canvas && (dy_local <= 5'd1);
    logic [7:0] icon_bg_r, icon_bg_g, icon_bg_b, icon_line_r, icon_line_g, icon_line_b;
    logic wave_active;
    assign wave_active = ({1'b0, wave_box} == wave_idx);
    always_comb begin
        if (wave_active) begin
            icon_bg_r=8'h40; icon_bg_g=8'h30; icon_bg_b=8'h60;
            icon_line_r=8'hFF; icon_line_g=8'hD0; icon_line_b=8'h30;
        end else begin
            icon_bg_r=8'h18; icon_bg_g=8'h18; icon_bg_b=8'h20;
            icon_line_r=8'h80; icon_line_g=8'h80; icon_line_b=8'h80;
        end
    end

    // 列分隔线 / keypad / 进度条 / 侧栏
    logic g_on_col_border;
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
    logic g_key_lit, g_col_flash, g_in_floor;
    assign g_key_lit = (g_cur_col < 3'd4) ? keymask[g_cur_col] : 1'b0;
    assign g_col_flash = (g_cur_col < 3'd4) ? keymask[12 + g_cur_col] : 1'b0;
    assign g_in_floor = g_in_area_x && (DrawY >= 10'd440);

    logic in_sidebar;
    assign in_sidebar = (DrawX >= SB_X0) && (DrawX < SB_X1);
    logic on_main_split;
    assign on_main_split = (DrawX >= G_AREA_X1 - 10'd1) && (DrawX < G_AREA_X1 + 10'd1);

    logic [9:0] prog_w_pixels;
    assign prog_w_pixels = (song_progress * PROG_W) / 10'd127;
    logic in_prog_box, in_prog_fill;
    assign in_prog_box  = (DrawX >= PROG_X0) && (DrawX < PROG_X1) &&
                          (DrawY >= PROG_Y0) && (DrawY < PROG_Y1);
    assign in_prog_fill = in_prog_box && (DrawX < (PROG_X0 + prog_w_pixels));

    // SELECT 卡片
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
    logic in_c1_star, in_c2_star_a, in_c2_star_b;
    logic in_c3_star_a, in_c3_star_b, in_c3_star_c;
    assign in_c1_star    = in_card_star(10'd360, 10'd120, 10'd10);
    assign in_c2_star_a  = in_card_star(10'd340, 10'd220, 10'd10);
    assign in_c2_star_b  = in_card_star(10'd370, 10'd220, 10'd10);
    assign in_c3_star_a  = in_card_star(10'd320, 10'd320, 10'd10);
    assign in_c3_star_b  = in_card_star(10'd350, 10'd320, 10'd10);
    assign in_c3_star_c  = in_card_star(10'd380, 10'd320, 10'd10);

    logic dim_overlay;
    assign dim_overlay = state_paused;

    // ================================================================
    // 计算 "non-sprite" 像素颜色 (combinational)
    // ================================================================
    logic [7:0] ns_r, ns_g, ns_b;
    always_comb begin
        ns_r = 8'h05; ns_g = 8'h05; ns_b = 8'h10;

        if (state_manual || state_auto) begin
            // 钢琴模式
            if (m1_on_any_tile)             begin ns_r=8'hC0; ns_g=8'hC0; ns_b=8'hFF; end
            else if (m1_in_y && m1_in_x && m1_on_col_border)
                                            begin ns_r=8'h40; ns_g=8'h40; ns_b=8'h60; end
            else if (m1_in_y && m1_in_x)    begin ns_r=8'h10; ns_g=8'h10; ns_b=8'h30; end
            else if (in_wave_fill) begin
                if (draw_line) begin ns_r=icon_line_r; ns_g=icon_line_g; ns_b=icon_line_b; end
                else            begin ns_r=icon_bg_r;   ns_g=icon_bg_g;   ns_b=icon_bg_b;   end
            end
            else if (in_oct_fill) begin
                if (oct_box_active)       begin ns_r=8'hFF; ns_g=8'hD0; ns_b=8'h30; end
                else if (oct_box == 4'd4) begin ns_r=8'h60; ns_g=8'h60; ns_b=8'h80; end
                else                      begin ns_r=8'h30; ns_g=8'h30; ns_b=8'h40; end
            end
            else if (black_hit) begin
                if      (keymask[black_semi])      begin ns_r=8'hFF; ns_g=8'hA0; ns_b=8'h00; end
                else if (auto_keymask[black_semi]) begin ns_r=8'h00; ns_g=8'hE8; ns_b=8'hD0; end
                else                               begin ns_r=8'h10; ns_g=8'h10; ns_b=8'h10; end
            end
            else if (in_key_x && in_key_y) begin
                if ((x_in_white < BORDER_W) || (x_in_white >= (KEY_W - BORDER_W)))
                                                   begin ns_r=8'h00; ns_g=8'h00; ns_b=8'h00; end
                else if (white_n < 4'd14 && keymask[white_semi])
                                                   begin ns_r=8'hFF; ns_g=8'hD0; ns_b=8'h30; end
                else if (white_n < 4'd14 && auto_keymask[white_semi])
                                                   begin ns_r=8'h00; ns_g=8'hE8; ns_b=8'hD0; end
                else                               begin ns_r=8'hFF; ns_g=8'hFF; ns_b=8'hFF; end
            end
            else if (in_key_y)                     begin ns_r=8'h20; ns_g=8'h20; ns_b=8'h20; end
            else if ((DrawY >= DIVIDER_Y0) && (DrawY < KEY_AREA_Y0))
                                                   begin ns_r=8'h40; ns_g=8'h40; ns_b=8'h60; end
            else                                   begin ns_r=8'h00; ns_g=8'h00; ns_b=8'h00; end

        end else if (state_select) begin
            // SELECT
            ns_r=8'h08; ns_g=8'h08; ns_b=8'h18;
            if (in_card1) begin
                if (on_card1_border) begin
                    if (sel_song == 2'd0) begin ns_r=8'hFF; ns_g=8'hD0; ns_b=8'h30; end
                    else                   begin ns_r=8'h40; ns_g=8'h40; ns_b=8'h50; end
                end else                  begin ns_r=8'h20; ns_g=8'h60; ns_b=8'h30; end
                if (in_c1_star)            begin ns_r=8'hFF; ns_g=8'hE0; ns_b=8'h40; end
            end
            if (in_card2) begin
                if (on_card2_border) begin
                    if (sel_song == 2'd1) begin ns_r=8'hFF; ns_g=8'hD0; ns_b=8'h30; end
                    else                   begin ns_r=8'h40; ns_g=8'h40; ns_b=8'h50; end
                end else                  begin ns_r=8'h60; ns_g=8'h50; ns_b=8'h20; end
                if (in_c2_star_a || in_c2_star_b)
                                           begin ns_r=8'hFF; ns_g=8'hE0; ns_b=8'h40; end
            end
            if (in_card3) begin
                if (on_card3_border) begin
                    if (sel_song == 2'd2) begin ns_r=8'hFF; ns_g=8'hD0; ns_b=8'h30; end
                    else                   begin ns_r=8'h40; ns_g=8'h40; ns_b=8'h50; end
                end else                  begin ns_r=8'h60; ns_g=8'h25; ns_b=8'h25; end
                if (in_c3_star_a || in_c3_star_b || in_c3_star_c)
                                           begin ns_r=8'hFF; ns_g=8'hE0; ns_b=8'h40; end
            end
            if (in_sidebar) begin ns_r=8'h0E; ns_g=8'h0E; ns_b=8'h18; end
            if (on_main_split) begin ns_r=8'h40; ns_g=8'h40; ns_b=8'h60; end

        end else begin
            // COUNTDOWN / PLAYING / PAUSED / WIN / LOSE
            ns_r=8'h05; ns_g=8'h05; ns_b=8'h10;
            if (g_in_area_x && (DrawY < G_KEYPAD_Y0 || DrawY >= 10'd440))
                                              begin ns_r=8'h08; ns_g=8'h08; ns_b=8'h20; end
            if (g_on_col_border)              begin ns_r=8'h30; ns_g=8'h30; ns_b=8'h50; end
            if (g_in_keypad) begin
                if (g_on_keypad_border)       begin ns_r=8'h60; ns_g=8'h60; ns_b=8'h80; end
                else if (g_col_flash)         begin ns_r=8'hFF; ns_g=8'h30; ns_b=8'h30; end
                else if (g_key_lit)           begin ns_r=8'h80; ns_g=8'hFF; ns_b=8'hFF; end
                else                          begin ns_r=8'h18; ns_g=8'h18; ns_b=8'h28; end
            end
            if (g_in_floor && !g_in_keypad)   begin ns_r=8'h10; ns_g=8'h10; ns_b=8'h18; end
            if (on_main_split)                begin ns_r=8'h40; ns_g=8'h40; ns_b=8'h60; end

            if (in_sidebar) begin
                ns_r=8'h10; ns_g=8'h10; ns_b=8'h18;
                if (in_prog_box && !in_prog_fill)
                                              begin ns_r=8'h25; ns_g=8'h25; ns_b=8'h35; end
                if (in_prog_fill)             begin ns_r=8'h60; ns_g=8'h80; ns_b=8'hFF; end
            end

            // WIN/LOSE 背景色调
            if (state_win && g_in_area_x && DrawY < G_KEYPAD_Y0) begin
                ns_r = (ns_r >> 1);
                ns_g = (ns_g >> 1) + 8'h60;
                ns_b = (ns_b >> 1);
            end
            if (state_lose && g_in_area_x && DrawY < G_KEYPAD_Y0) begin
                ns_r = (ns_r >> 1) + 8'h50;
                ns_g = (ns_g >> 1);
                ns_b = (ns_b >> 1);
            end
        end
    end

    // ================================================================
    // 把所有信号 register 1 cycle 跟 BRAM 输出对齐
    // ================================================================
    logic [7:0] ns_r_d, ns_g_d, ns_b_d;
    logic       g_on_any_tile_d;
    logic       in_digit_region_d;
    logic       in_star_region_d;
    logic       in_win_region_d;
    logic       in_lose_region_d;
    logic       dim_overlay_d;
    always_ff @(posedge clk_25MHz) begin
        ns_r_d            <= ns_r;
        ns_g_d            <= ns_g;
        ns_b_d            <= ns_b;
        g_on_any_tile_d   <= g_on_any_tile && (state_playing || state_paused || state_countdown);
        in_digit_region_d <= in_digit_region;
        in_star_region_d  <= in_star_region;
        in_win_region_d   <= in_win_region;
        in_lose_region_d  <= in_lose_region;
        dim_overlay_d     <= dim_overlay;
    end

    // ================================================================
    // 最终 mux (优先级: lose > win > star > digit > tile > non-sprite)
    // 透明 idx 0 时回退到下一层 (ns_*)
    // ================================================================
    logic [7:0] r_pre, g_pre, b_pre;
    always_comb begin
        if (in_lose_region_d && !lose_trans) begin
            r_pre = lose_r; g_pre = lose_g; b_pre = lose_b;
        end else if (in_win_region_d && !win_trans) begin
            r_pre = win_r; g_pre = win_g; b_pre = win_b;
        end else if (in_star_region_d && !star_trans) begin
            r_pre = star_r; g_pre = star_g; b_pre = star_b;
        end else if (in_digit_region_d && !digit_trans) begin
            r_pre = digit_r; g_pre = digit_g; b_pre = digit_b;
        end else if (g_on_any_tile_d && !tile_trans) begin
            r_pre = tile_r; g_pre = tile_g; b_pre = tile_b;
        end else begin
            r_pre = ns_r_d; g_pre = ns_g_d; b_pre = ns_b_d;
        end
    end

    always_comb begin
        if (dim_overlay_d) begin
            R = r_pre >> 1; G = g_pre >> 1; B = b_pre >> 1;
        end else begin
            R = r_pre; G = g_pre; B = b_pre;
        end
    end

endmodule
