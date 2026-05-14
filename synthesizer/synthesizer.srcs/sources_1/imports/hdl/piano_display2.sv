//=============================================================================
// piano_display_M4f.sv  --  M4e + ??? sprite (digit/star/win/lose)
//
// 5 ?? BRAM:
//   tile_rom   120w ?? 160h ?? 4-bit (4 ? NORMAL/HIT/PERFECT/MISSED, 19200 entries)
//   digit_rom  24w  ?? 240h ?? 4-bit (10 ? 1-9 ??? 0,             5760 entries)
//   star_rom   40w  ?? 80h  ?? 4-bit (2 ? filled/empty,             3200 entries)
//   win_rom    140w ?? 120h ?? 4-bit (1 ? trophy,                  16800 entries)
//   lose_rom   140w ?? 120h ?? 4-bit (1 ? broken heart,            16800 entries)
//
// 5 ?? palette: tile_palette / digit_palette / star_palette / win_palette / lose_palette
//   (?????? module, ??? idx 0 = ??? #FFBBFF)
//
// ???? sprite frame ??? (?????? 0 ?? 9 ????):
//   digit value: 1 2 3 4 5 6 7 8 9 0
//   frame idx:   0 1 2 3 4 5 6 7 8 9
//   ???: frame = (digit == 0) ? 9 : (digit - 1)
//
// ???????:
//   COUNTDOWN: digit 4x scale (96??96) at game center (192..288, 180..276)
//   sidebar SCORE: 2 digit 2x scale (48??48), x=510..606, y=120..168
//   sidebar 3 stars: 40??40 native, y=10..50
//   WIN: 3 big stars 2x scale (80??80) at y=70..150,
//        + win sprite 140??120 at center (170..310, 180..300)
//   LOSE: lose sprite 140??120 at center (170..310, 180..300)
//=============================================================================
module piano_display (
    input  logic        clk_25MHz,
    input  logic [9:0]  DrawX,
    input  logic [9:0]  DrawY,
    input  logic [31:0] keymask,
    input  logic [31:0] auto_keymask,
    input  logic [3:0]  octave_idx,
    input  logic [2:0]  wave_idx,
    input  logic [31:0] tile_word_lo,
    input  logic [31:0] tile_word_hi,
    output logic [7:0]  R,
    output logic [7:0]  G,
    output logic [7:0]  B
);
    // ================================================================
    // ????????
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
    localparam logic [9:0] G_KEYPAD_Y0  = 10'd360;
    localparam logic [9:0] G_KEYPAD_Y1  = 10'd400;
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

    // ===== ???? (???????) ??????? =====
    // 3 ?????? (30x30 each, y=55..85)
    localparam logic [9:0] SB_STAR_Y0   = 10'd55;
    localparam logic [9:0] SB_STAR_W    = 10'd40;
    localparam logic [9:0] SB_STAR1_X0  = 10'd495;
    localparam logic [9:0] SB_STAR2_X0  = 10'd535;
    localparam logic [9:0] SB_STAR3_X0  = 10'd575;
    
    // ?????? (????, ????????)
    localparam logic [9:0] PROG_X0      = 10'd495;
    localparam logic [9:0] PROG_X1      = 10'd595;
    localparam logic [9:0] PROG_Y0      = 10'd215;
    localparam logic [9:0] PROG_Y1      = 10'd232;
    localparam logic [9:0] PROG_W       = PROG_X1 - PROG_X0;
    
    // SCORE ???? 3 ?? (2x scale = 48x48), y=160..208
    localparam logic [9:0] SCORE_Y0     = 10'd160;
    localparam logic [9:0] SCORE_DIG_W  = 10'd48;
    localparam logic [9:0] SCORE_DIG_H  = 10'd48;
    localparam logic [9:0] SCORE_HUN_X0 = 10'd484;  // hundreds digit
    localparam logic [9:0] SCORE_TEN_X0 = 10'd532;
    localparam logic [9:0] SCORE_ONE_X0 = 10'd580;
    
    // COUNTDOWN ?????? (4x scale = 96x96, ???????????)
    localparam logic [9:0] CD_X0        = 10'd192;
    localparam logic [9:0] CD_Y0        = 10'd140;
    localparam logic [9:0] CD_W         = 10'd96;
    localparam logic [9:0] CD_H         = 10'd96;
    
    // WIN ?? 3 ???? (2x scale, 80x80) ???
    localparam logic [9:0] BIG_STAR_Y0  = 10'd60;
    localparam logic [9:0] BIG_STAR1_X0 = 10'd80;
    localparam logic [9:0] BIG_STAR2_X0 = 10'd200;
    localparam logic [9:0] BIG_STAR3_X0 = 10'd320;
    localparam logic [9:0] BIG_STAR_W   = 10'd80;
    
    // WIN/LOSE sprite ????
    localparam logic [9:0] WIN_X0       = 10'd170;
    localparam logic [9:0] WIN_Y0       = 10'd160;
    localparam logic [9:0] WIN_W        = 10'd140;
    localparam logic [9:0] WIN_H        = 10'd120;
    localparam logic [9:0] LOSE_X0      = 10'd170;
    localparam logic [9:0] LOSE_Y0      = 10'd160;
    localparam logic [9:0] LOSE_W       = 10'd140;
    localparam logic [9:0] LOSE_H       = 10'd120;


    localparam logic [9:0] ICON_Y0   = 10'd235;
    localparam logic [9:0] ICON_W    = 10'd32;
    localparam logic [9:0] PAUSE_X0  = 10'd490;
    localparam logic [9:0] CONT_X0   = 10'd540;
    localparam logic [9:0] RETRY_X0  = 10'd590;

    localparam logic [9:0] BEST_Y0     = 10'd330;
    localparam logic [9:0] BEST_HUN_X0 = 10'd484;   // hundreds digit
    localparam logic [9:0] BEST_TEN_X0 = 10'd532;
    localparam logic [9:0] BEST_ONE_X0 = 10'd580;
    
    
    localparam logic [9:0] T_COMBO_X0 = 10'd490;
    localparam logic [9:0] T_COMBO_Y0 = 10'd440;

    localparam logic [9:0] WAVE_W = 10'd40;
    localparam logic [9:0] WAVE_H = 10'd20;

    logic [9:0] wave_x [0:6];
    logic [9:0] wave_y [0:6];

///////////////////////////////////////////my position
    always_comb begin
        wave_x[0] = 10'd40;   wave_y[0] = 10'd260;
        wave_x[1] = 10'd70;   wave_y[1] = 10'd300;
        wave_x[2] = 10'd190;   wave_y[2] = 10'd450;
        wave_x[3] = 10'd360;   wave_y[3] = 10'd260;
        wave_x[4] = 10'd300;   wave_y[4] = 10'd320;
        wave_x[5] = 10'd400;   wave_y[5] = 10'd300;
        wave_x[6] = 10'd390;   wave_y[6] = 10'd460;
    end


    // ================================================================
    // ??????
    // ================================================================
    logic [2:0] game_st;
    logic [1:0] sel_song;
    logic [1:0] cd_val;
    logic [6:0] song_progress;
    logic [1:0] stars_from_c;     // ?????????????? C ???????????????
    assign game_st       = auto_keymask[2:0];
    assign sel_song      = auto_keymask[4:3];
    assign cd_val        = auto_keymask[6:5];
    assign song_progress = auto_keymask[14:8];
    // ??????? .c ????(final_stars & 3) << 15[cite: 11]
    assign stars_from_c  = auto_keymask[16:15];
    
    logic [9:0] combo_val;
    assign combo_val = auto_keymask[28:19];

    logic [3:0] combo_hundreds;
    logic [3:0] combo_tens;
    logic [3:0] combo_ones;
    assign combo_hundreds = combo_val / 100;
    assign combo_tens     = (combo_val / 10) % 10;
    assign combo_ones     = combo_val % 10;

    // combo animation
    logic [9:0] combo_prev;
    logic [4:0] combo_anim_cnt;
    logic       combo_milestone_anim;

    wire frame_tick = (DrawX == 10'd0) && (DrawY == 10'd0);
    wire combo_changed = (combo_val != combo_prev);
    wire combo_is_milestone = (combo_val != 10'd0) && (combo_ones == 4'd0);

    wire combo_anim_active = (combo_anim_cnt != 5'd0);
    wire combo_scale2 = combo_anim_active;
    wire combo_scale3 = 0;

    wire wave_transparent =(wave_r4 == 4'hF) &&(wave_g4 == 4'h0) && (wave_b4 == 4'hF);
    

    always_ff @(posedge clk_25MHz) begin
        if (frame_tick) begin
            combo_prev <= combo_val;

            if (combo_changed && combo_val != 10'd0) begin
                combo_anim_cnt <= 5'd12;
                combo_milestone_anim <= combo_is_milestone;
            end else if (combo_anim_cnt != 5'd0) begin
                combo_anim_cnt <= combo_anim_cnt - 5'd1;
            end else begin
                combo_milestone_anim <= 1'b0;
            end
        end
    end


    logic [23:0] wave_anim_cnt;
    logic        wave_frame;

    always_ff @(posedge clk_25MHz) begin
        if (wave_anim_cnt >= 24'd6_000_000) begin
            wave_anim_cnt <= 24'd0;
            wave_frame <= ~wave_frame;
        end else begin
            wave_anim_cnt <= wave_anim_cnt + 24'd1;
        end
    end

    logic        in_wave_sprite;
    logic [5:0]  wave_sprite_local_x;
    logic [5:0]  wave_sprite_local_y;

    always_comb begin
        in_wave_sprite       = 1'b0;
        wave_sprite_local_x  = 6'd0;
        wave_sprite_local_y  = 6'd0;

        for (int i = 0; i < 7; i++) begin
            if (!in_wave_sprite && (state_playing || state_paused || state_countdown) &&
                DrawX >= wave_x[i] &&
                DrawX <  wave_x[i] + WAVE_W &&
                DrawY >= wave_y[i] &&
                DrawY <  wave_y[i] + WAVE_H) begin

                in_wave_sprite      = 1'b1;
                wave_sprite_local_x = DrawX - wave_x[i];
                wave_sprite_local_y = DrawY - wave_y[i];
            end
        end
    end

    assign wave_addr =
        ((wave_frame ? (wave_sprite_local_y + 6'd20) : wave_sprite_local_y) * 11'd40)
        + wave_sprite_local_x;


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
    assign in_game_ui = !state_manual && !state_auto && !state_select;

    // ================================================================
    // tile ???? (M4d ????)
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
    logic t0_long, t1_long, t2_long, t3_long;
    assign t0_long = tile_word_lo[0];
    assign t1_long = tile_word_lo[18];
    assign t2_long = tile_word_hi[0];
    assign t3_long = tile_word_hi[18];

    logic signed [10:0] t0_y_real, t1_y_real, t2_y_real, t3_y_real;
    assign t0_y_real = $signed({2'b00, t0_y_raw}) - 11'sd40;
    assign t1_y_real = $signed({2'b00, t1_y_raw}) - 11'sd40;
    assign t2_y_real = $signed({2'b00, t2_y_raw}) - 11'sd40;
    assign t3_y_real = $signed({2'b00, t3_y_raw}) - 11'sd40;
    logic signed [10:0] dy_signed;
    assign dy_signed = $signed({1'b0, DrawY});

    // ================================================================
    // ?????? tile
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
    // ??? tile ????
    // ================================================================
    logic [9:0] g_x_rel;
    logic [2:0] g_cur_col;
    logic       g_in_area_x;
    assign g_in_area_x = (DrawX >= G_AREA_X0) && (DrawX < G_AREA_X1);
    assign g_x_rel     = g_in_area_x ? (DrawX - G_AREA_X0) : 10'd0;
    assign g_cur_col   = g_in_area_x ? g_x_rel[9:0] / G_COL_W : 3'd4;
    logic g_on_t0, g_on_t1, g_on_t2, g_on_t3, g_on_any_tile;
    logic signed [10:0] t0_h, t1_h, t2_h, t3_h;
    assign t0_h = t0_long ? 11'sd120 : 11'sd40;
    assign t1_h = t1_long ? 11'sd120 : 11'sd40;
    assign t2_h = t2_long ? 11'sd120 : 11'sd40;
    assign t3_h = t3_long ? 11'sd120 : 11'sd40;
    // t0 (lo style, bit 3)
    assign t0_hold = tile_word_lo[3];
    
    // t1 (hi style, bit 19 = 16+3)
    assign t1_hold = tile_word_lo[19];
    
    // t2 (lo style, bit 3)
    assign t2_hold = tile_word_hi[3];
    
    // t3 (hi style, bit 19 = 16+3)
    assign t3_hold = tile_word_hi[19];
    
    // ? tile  hold ?? ( cur_tile_state ?????)
    logic cur_tile_hold;
    always_comb begin
        cur_tile_hold = 1'b0;
        if      (g_on_t0) cur_tile_hold = t0_hold;
        else if (g_on_t1) cur_tile_hold = t1_hold;
        else if (g_on_t2) cur_tile_hold = t2_hold;
        else if (g_on_t3) cur_tile_hold = t3_hold;
    end
    
    // ??? _d ??
    logic cur_tile_hold_d;
    always_ff @(posedge clk_25MHz) cur_tile_hold_d <= cur_tile_hold;
    assign g_on_t0 = t0_act && g_in_area_x && (g_cur_col == {1'b0, t0_col})
                  && (dy_signed >= t0_y_real) && (dy_signed < (t0_y_real + t0_h));
    assign g_on_t1 = t1_act && g_in_area_x && (g_cur_col == {1'b0, t1_col})
                      && (dy_signed >= t1_y_real) && (dy_signed < (t1_y_real + t1_h));
    assign g_on_t2 = t2_act && g_in_area_x && (g_cur_col == {1'b0, t2_col})
                      && (dy_signed >= t2_y_real) && (dy_signed < (t2_y_real + t2_h));
    assign g_on_t3 = t3_act && g_in_area_x && (g_cur_col == {1'b0, t3_col})
                      && (dy_signed >= t3_y_real) && (dy_signed < (t3_y_real + t3_h));
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
    logic [9:0] tile_local_y_wrapped;
    always_comb begin
        if (tile_local_y < 10'd40) tile_local_y_wrapped = tile_local_y;
        else if (tile_local_y < 10'd80) tile_local_y_wrapped = tile_local_y - 10'd40;
        else tile_local_y_wrapped = tile_local_y - 10'd80;  // 80..119
    end
    // tile ROM ???
    logic [14:0] state_offset;
    //  ?:  tile state ? ROM ?
    always_comb begin
        unique case (cur_tile_state)
            2'd0: state_offset = 15'd0;       // T_NORMAL
            2'd1: state_offset = 15'd4800;    // T_HIT (GOOD)
            2'd2: state_offset = 15'd9600;    // T_PERFECT
            2'd3: state_offset = 15'd14400;   // T_MISSED
            default: state_offset = 15'd0;
        endcase
    end
    
    logic below_keypad;
    assign below_keypad = (DrawY > 10'd380);   // KEYPAD_CENTER
    // NOTE: a duplicate always_comb that drove r_pre/g_pre/b_pre lived
    // here previously; it conflicted with the final mux at the bottom of
    // the module and caused multi-driver DRC errors on r_pre/g_pre/b_pre.
    // The green-tint behavior for tile state 1/2 below keypad is folded
    // into the final mux at the end of this module via cur_tile_state_d
    // and below_keypad_d (registered to match the rest of the mux inputs).
    logic [14:0] tile_local_y_15, g_col_local_x_15;
    assign tile_local_y_15  = {5'd0, tile_local_y};
    assign g_col_local_x_15 = {5'd0, g_col_local_x};
    logic [14:0] tile_addr;
    assign tile_addr = state_offset + tile_local_y_wrapped * 15'd120 + g_col_local_x_15;

    // ================================================================
    // SCORE decode: keymask[13:4] = score 0..999 direct (no offset)
    // ================================================================
    logic [9:0] score_val;
    assign score_val = keymask[13:4];
    logic [3:0] score_huns, score_tens, score_ones;
    assign score_huns = score_val / 10'd100;
    assign score_tens = (score_val % 10'd100) / 10'd10;
    assign score_ones = score_val % 10'd10;
    
    

    // digit frame lookup: digit_value -> ROM frame_idx
    function automatic [3:0] digit_to_frame(input [3:0] d);
        if (d == 4'd0) digit_to_frame = 4'd9;     // 0 uses last frame
        else           digit_to_frame = d - 4'd1; // 1..9 -> frame 0..8
    endfunction

    // keymask[27:18] = best score 0..999 direct
    logic [9:0] best_score_disp;
    assign best_score_disp = keymask[27:18];

    logic new_best;
    logic infinite_mode;
    assign new_best      = auto_keymask[17];
    assign infinite_mode = auto_keymask[18];

    // auto-select picker state  [19]=open  [23:20]=highlighted
    logic        auto_sel_active;
    logic [3:0]  auto_sel_idx;
    assign auto_sel_active = auto_keymask[19];
    assign auto_sel_idx    = auto_keymask[23:20];

    logic [3:0] best_huns, best_tens, best_ones;
    assign best_huns = best_score_disp / 10'd100;
    assign best_tens = (best_score_disp % 10'd100) / 10'd10;
    assign best_ones = best_score_disp % 10'd10;

    // SELECT keymask: [9:0]=Peppa, [19:10]=Twinkle, [29:20]=Harry (10-bit each)
    logic [9:0] sel_best0, sel_best1, sel_best2;
    logic [3:0] sel_best0_huns, sel_best0_tens, sel_best0_ones;
    logic [3:0] sel_best1_huns, sel_best1_tens, sel_best1_ones;
    logic [3:0] sel_best2_huns, sel_best2_tens, sel_best2_ones;
    assign sel_best0 = keymask[9:0];
    assign sel_best1 = keymask[19:10];
    assign sel_best2 = keymask[29:20];
    assign sel_best0_huns = sel_best0 / 10'd100;
    assign sel_best0_tens = (sel_best0 % 10'd100) / 10'd10;
    assign sel_best0_ones = sel_best0 % 10'd10;
    assign sel_best1_huns = sel_best1 / 10'd100;
    assign sel_best1_tens = (sel_best1 % 10'd100) / 10'd10;
    assign sel_best1_ones = sel_best1 % 10'd10;
    assign sel_best2_huns = sel_best2 / 10'd100;
    assign sel_best2_tens = (sel_best2 % 10'd100) / 10'd10;
    assign sel_best2_ones = sel_best2 % 10'd10;


    // ================================================================
    // ???? sprite ??????? (combinational)
    // ??????????? 1 ????????? (countdown ?? score, ????)
    // ???????: countdown > score (score ?? sidebar)
    // ================================================================

    // === COUNTDOWN ???? (4x scale, ??????) ===
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
            2'd1:    cd_frame = digit_to_frame(4'd1);  // 1 ?? frame 0
            2'd2:    cd_frame = digit_to_frame(4'd2);  // 2 ?? frame 1
            2'd3:    cd_frame = digit_to_frame(4'd3);  // 3 ?? frame 2
            default: cd_frame = 4'd0;
        endcase
    end

    // === SCORE ???? (2x scale, 2 digit) ===
    // === SCORE digit regions (3 digits: hundreds / tens / ones) ===
    logic in_score_huns_region, in_score_tens_region, in_score_ones_region;
    logic [9:0] sc_h_x, sc_h_y, sc_t_x, sc_t_y, sc_o_x, sc_o_y;
    logic [4:0] sc_h_rx, sc_h_ry, sc_t_rx, sc_t_ry, sc_o_rx, sc_o_ry;
    assign in_score_huns_region = in_game_ui &&
                                  (DrawX >= SCORE_HUN_X0) && (DrawX < SCORE_HUN_X0 + SCORE_DIG_W) &&
                                  (DrawY >= SCORE_Y0)     && (DrawY < SCORE_Y0 + SCORE_DIG_H);
    assign in_score_tens_region = in_game_ui &&
                                  (DrawX >= SCORE_TEN_X0) && (DrawX < SCORE_TEN_X0 + SCORE_DIG_W) &&
                                  (DrawY >= SCORE_Y0)     && (DrawY < SCORE_Y0 + SCORE_DIG_H);
    assign in_score_ones_region = in_game_ui &&
                                  (DrawX >= SCORE_ONE_X0) && (DrawX < SCORE_ONE_X0 + SCORE_DIG_W) &&
                                  (DrawY >= SCORE_Y0)     && (DrawY < SCORE_Y0 + SCORE_DIG_H);
    assign sc_h_x = in_score_huns_region ? (DrawX - SCORE_HUN_X0) : 10'd0;
    assign sc_h_y = in_score_huns_region ? (DrawY - SCORE_Y0)     : 10'd0;
    assign sc_t_x = in_score_tens_region ? (DrawX - SCORE_TEN_X0) : 10'd0;
    assign sc_t_y = in_score_tens_region ? (DrawY - SCORE_Y0)     : 10'd0;
    assign sc_o_x = in_score_ones_region ? (DrawX - SCORE_ONE_X0) : 10'd0;
    assign sc_o_y = in_score_ones_region ? (DrawY - SCORE_Y0)     : 10'd0;
    assign sc_h_rx = sc_h_x[9:1];   // /2 for 2x scale
    assign sc_h_ry = sc_h_y[9:1];
    assign sc_t_rx = sc_t_x[9:1];
    assign sc_t_ry = sc_t_y[9:1];
    assign sc_o_rx = sc_o_x[9:1];
    assign sc_o_ry = sc_o_y[9:1];


    


    localparam logic [9:0] T_NB_X0 = 10'd150;
    localparam logic [9:0] T_NB_Y0 = 10'd285;

    localparam logic [9:0] T_INF_X0 = 10'd490;
    localparam logic [9:0] T_INF_Y0 = 10'd270;


    // ??????? ROM ??? (?????: countdown > score-tens > score-ones)
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

        end else if (in_score_huns_region) begin
            in_digit_region = 1'b1;
            digit_addr = ({9'd0, digit_to_frame(score_huns)} * 13'd576)
                    + ({8'd0, sc_h_ry} * 13'd24)
                    + {8'd0, sc_h_rx};

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

        end else if (in_best_huns_region) begin
            in_digit_region = 1'b1;
            digit_addr = ({9'd0, digit_to_frame(best_huns)} * 13'd576)
                    + ({8'd0, best_h_ry} * 13'd24)
                    + {8'd0, best_h_rx};

        end else if (in_best_tens_region) begin
            in_digit_region = 1'b1;
            digit_addr = ({9'd0, digit_to_frame(best_tens)} * 13'd576)
                    + ({8'd0, best_t_ry} * 13'd24)
                    + {8'd0, best_t_rx};

        end else if (in_best_ones_region) begin
            in_digit_region = 1'b1;
            digit_addr = ({9'd0, digit_to_frame(best_ones)} * 13'd576)
                    + ({8'd0, best_o_ry} * 13'd24)
                    + {8'd0, best_o_rx};
        end
    end

    // ================================================================
    // STAR sprite (40x40 per frame, 2 frames)
    //   frame 0 = filled (gold)
    //   frame 1 = empty  (gray)
    // ???: ???? 3 ?? (40x40 native), WIN ?? 3 ?? (80x80 = 2x scale)
    // ================================================================

    // ???????
    logic star1_filled, star2_filled, star3_filled;
    assign star1_filled = (stars_from_c >= 2'd1); // ????????? >= 1?????????[cite: 11]
    assign star2_filled = (stars_from_c >= 2'd2); // ????????? >= 2?????????[cite: 11]
    assign star3_filled = (stars_from_c >= 2'd3); // ????????? == 3??????????[cite: 11]

    // ???? 3 ????
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

    // WIN ???? (80x80 = 2x scale)
    logic in_big_star1, in_big_star2, in_big_star3;
    
    logic [9:0] bs1_cx, bs2_cx, bs3_cx, bsc_cy;

    assign bs1_cx = BIG_STAR1_X0 + 10'd40;
    assign bs2_cx = BIG_STAR2_X0 + 10'd40;
    assign bs3_cx = BIG_STAR3_X0 + 10'd40;
    assign bsc_cy = BIG_STAR_Y0  + 10'd40;

    assign in_big_star1 = state_win && star1_vis_r &&
                        (DrawX >= bs1_cx - {4'd0, star1_crop_r}) &&
                        (DrawX <  bs1_cx + {4'd0, star1_crop_r}) &&
                        (DrawY >= bsc_cy - {4'd0, star1_crop_r}) &&
                        (DrawY <  bsc_cy + {4'd0, star1_crop_r});

    assign in_big_star2 = state_win && star2_vis_r &&
                        (DrawX >= bs2_cx - {4'd0, star2_crop_r}) &&
                        (DrawX <  bs2_cx + {4'd0, star2_crop_r}) &&
                        (DrawY >= bsc_cy - {4'd0, star2_crop_r}) &&
                        (DrawY <  bsc_cy + {4'd0, star2_crop_r});

    assign in_big_star3 = state_win && star3_vis_r &&
                        (DrawX >= bs3_cx - {4'd0, star3_crop_r}) &&
                        (DrawX <  bs3_cx + {4'd0, star3_crop_r}) &&
                        (DrawY >= bsc_cy - {4'd0, star3_crop_r}) &&
                        (DrawY <  bsc_cy + {4'd0, star3_crop_r});

    // Rotated ROM lookup per star (packed {valid[12], addr[11:0]})
    logic [12:0] bs1_rinfo, bs2_rinfo, bs3_rinfo;
    assign bs1_rinfo = san_rotate_addr(DrawX, DrawY, BIG_STAR1_X0, BIG_STAR_Y0, star1_spin_f, star1_filled);
    assign bs2_rinfo = san_rotate_addr(DrawX, DrawY, BIG_STAR2_X0, BIG_STAR_Y0, star2_spin_f, star2_filled);
    assign bs3_rinfo = san_rotate_addr(DrawX, DrawY, BIG_STAR3_X0, BIG_STAR_Y0, star3_spin_f, star3_filled);


    // ================================================================
    // BIG STAR ANIMATION  pop-out (grow) then spin on WIN screen
    // ================================================================
    // 20 fps tick: every 1,250,000 clocks @ 25 MHz
    logic [20:0] san_clk_cnt;
    logic        san_tick;

    always_ff @(posedge clk_25MHz) begin
        if (san_clk_cnt == 21'd1249999) begin
            san_clk_cnt <= 21'd0;
            san_tick <= 1'b1;
        end else begin
            san_clk_cnt <= san_clk_cnt + 21'd1;
            san_tick <= 1'b0;
        end
    end

    logic state_win_d_san;

    always_ff @(posedge clk_25MHz) begin
        state_win_d_san <= state_win;
    end

    logic win_entry_san;
    assign win_entry_san = state_win & ~state_win_d_san;

    typedef enum logic [3:0] {
        SAN_IDLE,
        SAN_GROW1, SAN_SPIN1,
        SAN_GROW2, SAN_SPIN2,
        SAN_GROW3, SAN_SPIN3,
        SAN_DONE
    } san_st_t;

    san_st_t san_st;

    logic [4:0] san_sub;
    logic [5:0] star1_crop_r, star2_crop_r, star3_crop_r;
    logic       star1_vis_r,  star2_vis_r,  star3_vis_r;
    logic [2:0] star1_spin_f, star2_spin_f, star3_spin_f;


    always_ff @(posedge clk_25MHz) begin
    if (!state_win) begin
        san_st <= SAN_IDLE;
        san_sub <= 5'd0;
        star1_crop_r <= 6'd0;
        star2_crop_r <= 6'd0;
        star3_crop_r <= 6'd0;
        star1_vis_r <= 1'b0;
        star2_vis_r <= 1'b0;
        star3_vis_r <= 1'b0;
        star1_spin_f <= 3'd0;
        star2_spin_f <= 3'd0;
        star3_spin_f <= 3'd0;
    end else if (win_entry_san) begin
        san_st <= SAN_GROW1;
        san_sub <= 5'd0;
        star1_crop_r <= 6'd0;
        star2_crop_r <= 6'd0;
        star3_crop_r <= 6'd0;
        star1_vis_r <= 1'b1;
        star2_vis_r <= 1'b0;
        star3_vis_r <= 1'b0;
        star1_spin_f <= 3'd0;
        star2_spin_f <= 3'd0;
        star3_spin_f <= 3'd0;
    end else if (san_tick) begin
        case (san_st)
            SAN_IDLE: begin
                san_st <= SAN_GROW1;
                star1_vis_r <= 1'b1;
                san_sub <= 5'd0;
            end

            SAN_GROW1: begin
                if (star1_crop_r < 6'd40) star1_crop_r <= star1_crop_r + 6'd8;
                else begin san_st <= SAN_SPIN1; san_sub <= 5'd0; end
            end

            SAN_SPIN1: begin
                star1_spin_f <= star1_spin_f + 3'd1;
                san_sub <= san_sub + 5'd1;
                if (san_sub >= 5'd7) begin
                    san_st <= SAN_GROW2;
                    star2_vis_r <= 1'b1;
                end
            end

            SAN_GROW2: begin
                if (star2_crop_r < 6'd40) star2_crop_r <= star2_crop_r + 6'd8;
                else begin san_st <= SAN_SPIN2; san_sub <= 5'd0; end
            end

            SAN_SPIN2: begin
                star2_spin_f <= star2_spin_f + 3'd1;
                san_sub <= san_sub + 5'd1;
                if (san_sub >= 5'd7) begin
                    san_st <= SAN_GROW3;
                    star3_vis_r <= 1'b1;
                end
            end

            SAN_GROW3: begin
                if (star3_crop_r < 6'd40) star3_crop_r <= star3_crop_r + 6'd8;
                else begin san_st <= SAN_SPIN3; san_sub <= 5'd0; end
            end

            SAN_SPIN3: begin
                star3_spin_f <= star3_spin_f + 3'd1;
                san_sub <= san_sub + 5'd1;
                if (san_sub >= 5'd7) begin
                    san_st <= SAN_DONE;
                end
            end

            SAN_DONE: begin
                star1_crop_r <= 6'd40;
                star2_crop_r <= 6'd40;
                star3_crop_r <= 6'd40;
                star1_vis_r <= 1'b1;
                star2_vis_r <= 1'b1;
                star3_vis_r <= 1'b1;
            end
        endcase
    end
end


    // ???? star ROM ??? (?????: WIN ???? > ????????)
    // frame: filled=0, empty=1
    logic [11:0] star_addr;
    logic        in_star_region;
    logic        star_filled_now;
    always_comb begin
        star_addr = 12'd0;
        in_star_region = 1'b0;
        star_filled_now = 1'b0;

        if (in_big_star1) begin
            in_star_region  = bs1_rinfo[12];
            star_filled_now = star1_filled;
            star_addr       = bs1_rinfo[11:0];
        end else if (in_big_star2) begin
            in_star_region  = bs2_rinfo[12];
            star_filled_now = star2_filled;
            star_addr       = bs2_rinfo[11:0];
        end else if (in_big_star3) begin
            in_star_region  = bs3_rinfo[12];
            star_filled_now = star3_filled;
            star_addr       = bs3_rinfo[11:0];
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
    // WIN sprite ???? (140x120 native, ????)
    // ================================================================
    logic in_win_region;
    assign in_win_region = state_win &&
                           (DrawX >= WIN_X0) && (DrawX < WIN_X0 + WIN_W) &&
                           (DrawY >= WIN_Y0) && (DrawY < WIN_Y0 + WIN_H);
    logic [13:0] win_addr;
    assign win_addr = in_win_region ?
                      ((DrawY - WIN_Y0) * 14'd140 + (DrawX - WIN_X0)) : 14'd0;

    // ================================================================
    // LOSE sprite ???? (140x120 native, ????)
    // ================================================================
    logic in_lose_region;
    assign in_lose_region = state_lose &&
                            (DrawX >= LOSE_X0) && (DrawX < LOSE_X0 + LOSE_W) &&
                            (DrawY >= LOSE_Y0) && (DrawY < LOSE_Y0 + LOSE_H);
    logic [13:0] lose_addr;
    assign lose_addr = in_lose_region ?
                       ((DrawY - LOSE_Y0) * 14'd140 + (DrawX - LOSE_X0)) : 14'd0;

    // ===== M4g ????: icons ???? =====
    // ???????? 3 ????? (32??32 each, ????????), y=275..307

    // === BEST SCORE digit regions (3 digits: hundreds / tens / ones) ===
    logic in_best_huns_region, in_best_tens_region, in_best_ones_region;
    logic [9:0] best_h_x, best_h_y, best_t_x, best_t_y, best_o_x, best_o_y;
    logic [4:0] best_h_rx, best_h_ry, best_t_rx, best_t_ry, best_o_rx, best_o_ry;
    assign in_best_huns_region = (state_win || state_playing || state_paused) &&
                                (DrawX >= BEST_HUN_X0) && (DrawX < BEST_HUN_X0 + SCORE_DIG_W) &&
                                (DrawY >= BEST_Y0)     && (DrawY < BEST_Y0 + SCORE_DIG_H);
    assign in_best_tens_region = (state_win || state_playing || state_paused) &&
                                (DrawX >= BEST_TEN_X0) && (DrawX < BEST_TEN_X0 + SCORE_DIG_W) &&
                                (DrawY >= BEST_Y0)     && (DrawY < BEST_Y0 + SCORE_DIG_H);
    assign in_best_ones_region = (state_win || state_playing || state_paused) &&
                                (DrawX >= BEST_ONE_X0) && (DrawX < BEST_ONE_X0 + SCORE_DIG_W) &&
                                (DrawY >= BEST_Y0)     && (DrawY < BEST_Y0 + SCORE_DIG_H);

    assign best_h_x = in_best_huns_region ? (DrawX - BEST_HUN_X0) : 10'd0;
    assign best_h_y = in_best_huns_region ? (DrawY - BEST_Y0)     : 10'd0;
    assign best_t_x = in_best_tens_region ? (DrawX - BEST_TEN_X0) : 10'd0;
    assign best_t_y = in_best_tens_region ? (DrawY - BEST_Y0)     : 10'd0;
    assign best_o_x = in_best_ones_region ? (DrawX - BEST_ONE_X0) : 10'd0;
    assign best_o_y = in_best_ones_region ? (DrawY - BEST_Y0)     : 10'd0;

    assign best_h_rx = best_h_x[9:1];
    assign best_h_ry = best_h_y[9:1];
    assign best_t_rx = best_t_x[9:1];
    assign best_t_ry = best_t_y[9:1];
    assign best_o_rx = best_o_x[9:1];
    assign best_o_ry = best_o_y[9:1];
    
    // ?????????????????:
    //   PLAYING: ??? pause (????? P)
    //   PAUSED:  ??? continue (????? P ???)
    //   WIN/LOSE: ??? retry (????? R ????)
    //   ??????: ???????
    logic show_pause, show_continue, show_retry;
    assign show_pause    = state_playing;
    assign show_continue = state_paused;
    assign show_retry    = state_win || state_lose;
    
    logic in_pause_region, in_continue_region, in_retry_region;
    assign in_pause_region = show_pause &&
                              (DrawX >= PAUSE_X0) && (DrawX < PAUSE_X0 + ICON_W) &&
                              (DrawY >= ICON_Y0)  && (DrawY < ICON_Y0 + ICON_W);
    assign in_continue_region = show_continue &&
                                 (DrawX >= CONT_X0) && (DrawX < CONT_X0 + ICON_W) &&
                                 (DrawY >= ICON_Y0) && (DrawY < ICON_Y0 + ICON_W);
    assign in_retry_region = show_retry &&
                              (DrawX >= RETRY_X0) && (DrawX < RETRY_X0 + ICON_W) &&
                              (DrawY >= ICON_Y0)  && (DrawY < ICON_Y0 + ICON_W);
    
    assign pause_addr    = in_pause_region    ? (((DrawY - ICON_Y0) * 10'd32) + (DrawX - PAUSE_X0)) : 10'd0;
    assign continue_addr = in_continue_region ? (((DrawY - ICON_Y0) * 10'd32) + (DrawX - CONT_X0))  : 10'd0;
    assign retry_addr    = in_retry_region    ? (((DrawY - ICON_Y0) * 10'd32) + (DrawX - RETRY_X0)) : 10'd0;
    
    // ================================================================
    // BRAM ????? (5 ?? ROM, ?? 1-cycle ???)
    // ================================================================
    logic [3:0] tile_idx, digit_idx, star_idx, win_idx, lose_idx;
    tile_rom  tile_rom_i  (.clka(clk_25MHz), .ena(1'b1), .addra(tile_addr),  .douta(tile_idx));
    digit_rom digit_rom_i (.clka(clk_25MHz), .ena(1'b1), .addra(digit_addr), .douta(digit_idx));
    star_rom  star_rom_i  (.clka(clk_25MHz), .ena(1'b1), .addra(star_addr),  .douta(star_idx));
    win_rom   win_rom_i   (.clka(clk_25MHz), .ena(1'b1), .addra(win_addr),   .douta(win_idx));
    lose_rom  lose_rom_i  (.clka(clk_25MHz), .ena(1'b1), .addra(lose_addr),  .douta(lose_idx));

    logic [3:0]  wave_idx_sprite;
    logic [10:0] wave_addr;

    wave_rom wave_rom_inst (
        .clka   (clk_25MHz),
        .ena(1'b1),
        .addra (wave_addr),
        .douta       (wave_idx_sprite)
    );

    logic [3:0] wave_r4;
    logic [3:0] wave_g4;
    logic [3:0] wave_b4;

    wave_palette wave_pal_i (
        .index (wave_idx_sprite),
        .red   (wave_r4),
        .green (wave_g4),
        .blue  (wave_b4)
    );

    logic [7:0] wave_r;
    logic [7:0] wave_g;
    logic [7:0] wave_b;

    assign wave_r = {wave_r4, wave_r4};
    assign wave_g = {wave_g4, wave_g4};
    assign wave_b = {wave_b4, wave_b4};

    // ===== M4g ????: ??????? =====
    logic [3:0] bg_idx;
    logic [18:0] bg_addr;          // depth 307200 ?? 19 bit
    assign bg_addr = DrawY * 19'd640 + {9'd0, DrawX};
    bg_rom bg_rom_i (.clka(clk_25MHz), .ena(1'b1), .addra(bg_addr), .douta(bg_idx));
    
    logic [3:0] bg_r4, bg_g4, bg_b4;
    bg_palette bg_pal_i (.index(bg_idx), .red(bg_r4), .green(bg_g4), .blue(bg_b4));
    
    logic [7:0] bg_r, bg_g, bg_b;
    assign {bg_r, bg_g, bg_b} = {bg_r4, bg_r4, bg_g4, bg_g4, bg_b4, bg_b4};
        // ===== M4g ????: pause / continue / retry icons =====
    logic [3:0] pause_idx, continue_idx, retry_idx;
    logic [9:0] pause_addr, continue_addr, retry_addr;   // depth=1024 ?? 10 bit
    pause_rom    pause_rom_i    (.clka(clk_25MHz), .ena(1'b1), .addra(pause_addr),    .douta(pause_idx));
    continue_rom continue_rom_i (.clka(clk_25MHz), .ena(1'b1), .addra(continue_addr), .douta(continue_idx));
    retry_rom    retry_rom_i    (.clka(clk_25MHz), .ena(1'b1), .addra(retry_addr),    .douta(retry_idx));
    
    logic [3:0] pause_r4, pause_g4, pause_b4;
    logic [3:0] continue_r4, continue_g4, continue_b4;
    logic [3:0] retry_r4, retry_g4, retry_b4;
    pause_palette    pause_pal_i    (.index(pause_idx),    .red(pause_r4),    .green(pause_g4),    .blue(pause_b4));
    continue_palette continue_pal_i (.index(continue_idx), .red(continue_r4), .green(continue_g4), .blue(continue_b4));
    retry_palette    retry_pal_i    (.index(retry_idx),    .red(retry_r4),    .green(retry_g4),    .blue(retry_b4));
    
    logic [7:0] pause_r, pause_g, pause_b;
    logic [7:0] continue_r, continue_g, continue_b;
    logic [7:0] retry_r, retry_g, retry_b;
    assign {pause_r, pause_g, pause_b}       = {pause_r4, pause_r4, pause_g4, pause_g4, pause_b4, pause_b4};
    assign {continue_r, continue_g, continue_b} = {continue_r4, continue_r4, continue_g4, continue_g4, continue_b4, continue_b4};
    assign {retry_r, retry_g, retry_b}       = {retry_r4, retry_r4, retry_g4, retry_g4, retry_b4, retry_b4};
    

    // Palette ?????
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

    // 4-bit ?? 8-bit
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

    // ??? (idx 0)
    logic tile_trans, digit_trans, star_trans, win_trans, lose_trans;
    logic pause_trans, continue_trans, retry_trans;
    // ??? = ??? RGB ?????? #FF00FF (4-bit: F, 0, F)
    assign tile_trans     = (tile_r4 == 4'hF) && (tile_g4 == 4'h0) && (tile_b4 == 4'hF);
    assign digit_trans    = (digit_r4 == 4'hF) && (digit_g4 == 4'h0) && (digit_b4 == 4'hF);
    assign star_trans     = (star_r4 == 4'hF) && (star_g4 == 4'h0) && (star_b4 == 4'hF);
    assign win_trans      = (win_r4 == 4'hF) && (win_g4 == 4'h0) && (win_b4 == 4'hF);
    assign lose_trans     = (lose_r4 == 4'hF) && (lose_g4 == 4'h0) && (lose_b4 == 4'hF);
    assign pause_trans    = (pause_r4 == 4'hF) && (pause_g4 == 4'h0) && (pause_b4 == 4'hF);
    assign continue_trans = (continue_r4 == 4'hF) && (continue_g4 == 4'h0) && (continue_b4 == 4'hF);
    assign retry_trans    = (retry_r4 == 4'hF) && (retry_g4 == 4'h0) && (retry_b4 == 4'hF);

    // ================================================================
    // ?????? / ??? / ???? icon / ???? (M4d ????)
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
    // ================================================================
    // ???????????? (??????)
    // ================================================================
    logic [4:0] ref_y;
    always_comb begin
        ref_y = 5'd10;
        case (wave_box)

            // 0: ???? - ??????? + ?????????????????
            3'd0: begin
                if      (w_x < 5'd2)  ref_y = 5'd10;   // ??????
                else if (w_x < 5'd14) ref_y = 5'd4;    // ????
                else if (w_x < 5'd16) ref_y = 5'd10;   // ??????
                else if (w_x < 5'd28) ref_y = 5'd16;   // ????
                else                  ref_y = 5'd10;   // ??????
            end

            // 1: ????? - ???????/\????
            3'd1: begin
                if (w_x < 5'd15)
                    ref_y = 5'd17 - w_x;           // ?????17??3 (step??1)
                else
                    ref_y = 5'd3  + (w_x - 5'd15); // ??????3??17
            end

            // 2: ???? - ??????? + ??????????
            3'd2: begin
                if (w_x <= 5'd24)
                    // ?????y=3?????y=17??????0.58????
                    ref_y = 5'd3 + (w_x * 5'd14 / 5'd24);
                else begin
                    // ??????????x=25??y=17, x=26??y=14, x=27??y=10, x=28??y=6, x=29??y=3
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

            // 3: ?????
            3'd3: begin
                unique case (w_x)
                    5'd0:  ref_y = 5'd10; 5'd1:  ref_y = 5'd8;  5'd2:  ref_y = 5'd7;
                    5'd3:  ref_y = 5'd6;  5'd4:  ref_y = 5'd5;  5'd5:  ref_y = 5'd4;
                    5'd6:  ref_y = 5'd3;  5'd7:  ref_y = 5'd3;  5'd8:  ref_y = 5'd3;
                    5'd9:  ref_y = 5'd3;  5'd10: ref_y = 5'd4;  5'd11: ref_y = 5'd5;
                    5'd12: ref_y = 5'd6;  5'd13: ref_y = 5'd8;  5'd14: ref_y = 5'd9;
                    5'd15: ref_y = 5'd11; 5'd16: ref_y = 5'd12; 5'd17: ref_y = 5'd14;
                    5'd18: ref_y = 5'd15; 5'd19: ref_y = 5'd16; 5'd20: ref_y = 5'd17;
                    5'd21: ref_y = 5'd17; 5'd22: ref_y = 5'd17; 5'd23: ref_y = 5'd17;
                    5'd24: ref_y = 5'd16; 5'd25: ref_y = 5'd15; 5'd26: ref_y = 5'd14;
                    5'd27: ref_y = 5'd13; 5'd28: ref_y = 5'd12; 5'd29: ref_y = 5'd10;
                    default: ref_y = 5'd10;
                endcase
            end

            // 4: ?????
            3'd4: begin
                unique case (w_x)
                    5'd0:  ref_y = 5'd10; 5'd1:  ref_y = 5'd8;  5'd2:  ref_y = 5'd6;
                    5'd3:  ref_y = 5'd5;  5'd4:  ref_y = 5'd5;  5'd5:  ref_y = 5'd6;
                    5'd6:  ref_y = 5'd7;  5'd7:  ref_y = 5'd7;  5'd8:  ref_y = 5'd7;
                    5'd9:  ref_y = 5'd6;  5'd10: ref_y = 5'd5;  5'd11: ref_y = 5'd5;
                    5'd12: ref_y = 5'd5;  5'd13: ref_y = 5'd7;  5'd14: ref_y = 5'd9;
                    5'd15: ref_y = 5'd11; 5'd16: ref_y = 5'd13; 5'd17: ref_y = 5'd15;
                    5'd18: ref_y = 5'd15; 5'd19: ref_y = 5'd15; 5'd20: ref_y = 5'd14;
                    5'd21: ref_y = 5'd13; 5'd22: ref_y = 5'd13; 5'd23: ref_y = 5'd13;
                    5'd24: ref_y = 5'd14; 5'd25: ref_y = 5'd15; 5'd26: ref_y = 5'd15;
                    5'd27: ref_y = 5'd14; 5'd28: ref_y = 5'd12; 5'd29: ref_y = 5'd10;
                    default: ref_y = 5'd10;
                endcase
            end

            // 5: ??????
            3'd5: begin
                unique case (w_x)
                    5'd0:  ref_y = 5'd10; 5'd1:  ref_y = 5'd8;  5'd2:  ref_y = 5'd7;
                    5'd3:  ref_y = 5'd6;  5'd4:  ref_y = 5'd5;  5'd5:  ref_y = 5'd6;
                    5'd6:  ref_y = 5'd7;  5'd7:  ref_y = 5'd9;  5'd8:  ref_y = 5'd12;
                    5'd9:  ref_y = 5'd14; 5'd10: ref_y = 5'd16; 5'd11: ref_y = 5'd17;
                    5'd12: ref_y = 5'd16; 5'd13: ref_y = 5'd14; 5'd14: ref_y = 5'd12;
                    5'd15: ref_y = 5'd8;  5'd16: ref_y = 5'd6;  5'd17: ref_y = 5'd4;
                    5'd18: ref_y = 5'd3;  5'd19: ref_y = 5'd4;  5'd20: ref_y = 5'd6;
                    5'd21: ref_y = 5'd8;  5'd22: ref_y = 5'd11; 5'd23: ref_y = 5'd13;
                    5'd24: ref_y = 5'd14; 5'd25: ref_y = 5'd15; 5'd26: ref_y = 5'd14;
                    5'd27: ref_y = 5'd13; 5'd28: ref_y = 5'd12; 5'd29: ref_y = 5'd10;
                    default: ref_y = 5'd10;
                endcase
            end

            default: ref_y = 5'd10;
        endcase
    end

    // ??????????????????????????????????????
    logic [4:0] dy_local;
    logic draw_line;
    assign dy_local = (w_y > ref_y) ? (w_y - ref_y) : (ref_y - w_y);
    assign draw_line = in_canvas && (dy_local <= 5'd1);

    // ================================================================
    // ????????????
    // ================================================================
    logic [7:0] icon_bg_r, icon_bg_g, icon_bg_b, icon_line_r, icon_line_g, icon_line_b;
    logic wave_active;
    assign wave_active = ({1'b0, wave_box} == wave_idx);
    
    always_comb begin
        if (wave_active) begin
            icon_bg_r=8'hFF; icon_bg_g=8'h8E; icon_bg_b=8'h4C;
            icon_line_r=8'hFF; icon_line_g=8'hEE; icon_line_b=8'hA8;
        end else begin
            icon_bg_r=8'h59; icon_bg_g=8'h42; icon_bg_b=8'h14;
            icon_line_r=8'hFF; icon_line_g=8'hC8; icon_line_b=8'h5D;
        end
    end

    // ??????? / keypad / ?????? / ????
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
    assign g_col_flash = (g_cur_col < 3'd4) ? keymask[14 + g_cur_col] : 1'b0;
    assign g_in_floor = g_in_area_x && (DrawY >= 10'd400);

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

    // SELECT ???
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
    // Rotated star_rom address for animated big star
    // Returns {1'b_valid, 12'b_addr};  valid=0 ¡ú outside sprite
    function automatic [12:0] san_rotate_addr(
        input logic [9:0] DrawX, DrawY, sx0, sy0,
        input logic [2:0] spin_f,
        input logic       filled
    );
        logic [5:0]      cr, rr;
        logic signed [6:0]  ddx, ddy;
        logic signed [9:0]  cv, sv;
        logic signed [16:0] rx_fp, ry_fp;
        logic signed [8:0]  cr2, rr2;
        begin
            cr  = (DrawX - sx0) >> 1;
            rr  = (DrawY - sy0) >> 1;
            ddx = $signed({1'b0, cr}) - 7'sd20;
            ddy = $signed({1'b0, rr}) - 7'sd20;
            case (spin_f)
                3'd0: begin cv= 10'sd256; sv=  10'sd0;   end
                3'd1: begin cv= 10'sd181; sv=  10'sd181; end
                3'd2: begin cv=  10'sd0;  sv=  10'sd256; end
                3'd3: begin cv=-10'sd181; sv=  10'sd181; end
                3'd4: begin cv=-10'sd256; sv=  10'sd0;   end
                3'd5: begin cv=-10'sd181; sv= -10'sd181; end
                3'd6: begin cv=  10'sd0;  sv= -10'sd256; end
                default: begin cv= 10'sd181; sv= -10'sd181; end
            endcase
            rx_fp = ddx * cv - ddy * sv;
            ry_fp = ddx * sv + ddy * cv;
            cr2 = (rx_fp >>> 8) + 9'sd20;
            rr2 = (ry_fp >>> 8) + 9'sd20;
            if (!cr2[8] && !rr2[8] && cr2 < 9'sd40 && rr2 < 9'sd40)
                san_rotate_addr = {1'b1,
                    (filled ? 12'd0 : 12'd1600) + rr2[5:0] * 12'd40 + cr2[5:0]};
            else
                san_rotate_addr = 13'd0;
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
    // Font ROM (8x16 ASCII, combinational) - ???????
    // ================================================================
    logic [10:0] font_addr;
    logic [7:0]  font_data;
    font_rom font_inst (.addr(font_addr), .data(font_data));
    
    // === ?????????? ===
    
    // 1. "PAUSED" ???? (2x scale: 16w*6=96 ?? 32h), ???????
    localparam logic [9:0] T_PA_X0  = 10'd192;
    localparam logic [9:0] T_PA_Y0  = 10'd200;
    // 2. "PRESS P TO CONTINUE"
    localparam logic [9:0] T_PP_X0 = 10'd110;
    localparam logic [9:0] T_PP_Y0 = 10'd240;
    
    // 3. "PRESS R TO RETRY" (1x: 8*7=56w ?? 16h), WIN/LOSE ???
    localparam logic [9:0] T_PR_X0  = 10'd110;
    localparam logic [9:0] T_PR_Y0  = 10'd320;
    
    // 4. "[Tab] GAME MODE" (1x: 8*9=72w ?? 16h), ????????
    localparam logic [9:0] T_TB_X0  = 10'd220;
    localparam logic [9:0] T_TB_Y0  = 10'd6;
    // 5. "VOL."
    localparam logic [9:0] T_VO_X0  = 10'd650;
    localparam logic [9:0] T_VO_Y0  = 10'd150;
    //6. "Peppa"
    localparam logic [9:0] T_PEP_X0  = 10'd100;
    localparam logic [9:0] T_PEP_Y0  = 10'd100;
    //7. "Little Star"
    localparam logic [9:0] T_LS_X0  = 10'd100;
    localparam logic [9:0] T_LS_Y0  = 10'd205;
    //8. "Harry Potter"
    localparam logic [9:0] T_HP_X0  = 10'd100;
    localparam logic [9:0] T_HP_Y0  = 10'd310;

    //12. "Choose a song to play!"
    localparam logic [9:0] T_CHOOSE_X0 = 10'd144;
    localparam logic [9:0] T_CHOOSE_Y0 = 10'd30;

    // SELECT ???????????: best score:xx (1x font, 13 chars = 104 px)
    localparam logic [9:0] T_BS_X0 = 10'd500;
    localparam logic [9:0] T_BS1_Y0 = T_PEP_Y0;
    localparam logic [9:0] T_BS2_Y0 = T_LS_Y0;
    localparam logic [9:0] T_BS3_Y0 = T_HP_Y0;

    // ===== Auto-Select Song Grid =====
    // 4 cols x 128px, 2 rows x 64px, origin (40,30)
    localparam logic [9:0] AS_X0        = 10'd40;
    localparam logic [9:0] AS_Y0        = 10'd30;
    localparam logic [9:0] AS_X1        = 10'd552;   // 40+4*128
    localparam logic [9:0] AS_Y1        = 10'd158;   // 30+2*64
    localparam logic [3:0] AS_NUM_SONGS = 4'd8;       // Harry Mario Nokia Summer Imperial GOT Cantina Mii

    logic        in_as_grid;
    logic [9:0]  as_x_rel, as_y_rel;
    logic [1:0]  as_col;
    logic        as_row;
    logic [2:0]  as_idx;
    logic [6:0]  as_x_in_cell;
    logic [5:0]  as_y_in_cell;
    logic        as_cell_valid;
    logic        as_cell_sel;
    logic        as_cell_border;

    assign in_as_grid    = state_manual &&          // ?? manual ??????????
                           (DrawX >= AS_X0) && (DrawX < AS_X1) &&
                           (DrawY >= AS_Y0) && (DrawY < AS_Y1);
    assign as_x_rel      = DrawX - AS_X0;
    assign as_y_rel      = DrawY - AS_Y0;
    assign as_col        = as_x_rel[8:7];
    assign as_row        = as_y_rel[6];
    assign as_idx        = {as_row, as_col};
    assign as_x_in_cell  = as_x_rel[6:0];
    assign as_y_in_cell  = as_y_rel[5:0];
    assign as_cell_valid = ({1'b0, as_idx} < AS_NUM_SONGS);
    assign as_cell_sel   = as_cell_valid && (as_idx == auto_sel_idx[2:0]);
    assign as_cell_border= as_cell_valid && (
                             (as_x_in_cell==7'd0)   || (as_x_in_cell==7'd127) ||
                             (as_y_in_cell==6'd0)   || (as_y_in_cell==6'd63) );

    // text inside cell: 8px/char x 16px tall, left+4, vertically centred
    logic        in_as_text;
    logic [3:0]  as_char_idx;
    logic [2:0]  as_pix_x;
    logic [3:0]  as_pix_y;
    logic [6:0]  as_tx_rel;

    assign as_tx_rel   = as_x_in_cell - 7'd4;
    assign in_as_text  = in_as_grid && as_cell_valid &&
                         (as_x_in_cell >= 7'd4) && (as_x_in_cell < 7'd124) &&
                         (as_y_in_cell >= 6'd24) && (as_y_in_cell < 6'd40);
    logic [5:0] as_y_offset;
    assign as_y_offset = as_y_in_cell - 6'd24;
    assign as_char_idx = as_tx_rel[6:3];
    assign as_pix_x    = as_tx_rel[2:0];
    assign as_pix_y    = as_y_offset[3:0];
    
    /// === ?????????? ===
    logic in_t_paused, in_t_press_p, in_t_press_r;
    logic in_t_tab_mode, in_t_vol;
    logic in_t_peppa, in_t_little_star, in_t_harry_potter;

    logic in_t_choose;
    
    logic in_t_new_best;
    logic in_t_infinite;
    logic in_t_best1, in_t_best2, in_t_best3;
    
    logic in_t_combo;

    assign in_t_new_best =(state_win) && new_best &&
                        (DrawX >= T_NB_X0) && (DrawX < T_NB_X0 + 10'd144) &&
                        (DrawY >= T_NB_Y0) && (DrawY < T_NB_Y0 + 10'd32);

    assign in_t_infinite = state_playing && infinite_mode &&
                        (DrawX >= T_INF_X0) && (DrawX < T_INF_X0 + 10'd128) &&
                        (DrawY >= T_INF_Y0) && (DrawY < T_INF_Y0 + 10'd32);
                        
                        
    assign in_t_combo =
    (state_playing || state_paused) &&
    (
        combo_scale3 ?
        (
            (DrawX >= T_COMBO_X0) &&
            (DrawX <  T_COMBO_X0 + 10'd216) &&   // 9 chars * 8 * 3
            (DrawY >= T_COMBO_Y0 - 10'd16) &&
            (DrawY <  T_COMBO_Y0 + 10'd32)
        ) :
        combo_scale2 ?
        (
            (DrawX >= T_COMBO_X0) &&
            (DrawX <  T_COMBO_X0 + 10'd144) &&   // 9 chars * 8 * 2
            (DrawY >= T_COMBO_Y0 - 10'd8) &&
            (DrawY <  T_COMBO_Y0 + 10'd24)
        ) :
        (
            (DrawX >= T_COMBO_X0) &&
            (DrawX <  T_COMBO_X0 + 10'd72) &&
            (DrawY >= T_COMBO_Y0) &&
            (DrawY <  T_COMBO_Y0 + 10'd16)
        )
    );


    assign in_t_best1 = state_select &&
                        (DrawX >= T_BS_X0) && (DrawX < T_BS_X0 + 10'd112) &&
                        (DrawY >= T_BS1_Y0) && (DrawY < T_BS1_Y0 + 10'd16);
    assign in_t_best2 = state_select &&
                        (DrawX >= T_BS_X0) && (DrawX < T_BS_X0 + 10'd112) &&
                        (DrawY >= T_BS2_Y0) && (DrawY < T_BS2_Y0 + 10'd16);
    assign in_t_best3 = state_select &&
                        (DrawX >= T_BS_X0) && (DrawX < T_BS_X0 + 10'd112) &&
                        (DrawY >= T_BS3_Y0) && (DrawY < T_BS3_Y0 + 10'd16);

    function automatic [6:0] str_new_best(input [3:0] i);
        case (i)
            4'd0: str_new_best = 7'h4E; // N
            4'd1: str_new_best = 7'h45; // E
            4'd2: str_new_best = 7'h57; // W
            4'd3: str_new_best = 7'h20; // space
            4'd4: str_new_best = 7'h42; // B
            4'd5: str_new_best = 7'h45; // E
            4'd6: str_new_best = 7'h53; // S
            4'd7: str_new_best = 7'h54; // T
            4'd8: str_new_best = 7'h21; // !
            default: str_new_best = 7'h20;
        endcase
    endfunction

    function automatic [6:0] str_infinite(input [3:0] i);
        case (i)
            4'd0: str_infinite = 7'h49; // I
            4'd1: str_infinite = 7'h4E; // N
            4'd2: str_infinite = 7'h46; // F
            4'd3: str_infinite = 7'h49; // I
            4'd4: str_infinite = 7'h4E; // N
            4'd5: str_infinite = 7'h49; // I
            4'd6: str_infinite = 7'h54; // T
            4'd7: str_infinite = 7'h45; // E
            default: str_infinite = 7'h20;
        endcase
    endfunction
    
    function automatic [6:0] str_combo(
        input [3:0] i,
        input [3:0] huns,
        input [3:0] tens,
        input [3:0] ones
    );
    begin
        case (i)
            4'd0: str_combo = 7'h43; // C
            4'd1: str_combo = 7'h4F; // O
            4'd2: str_combo = 7'h4D; // M
            4'd3: str_combo = 7'h42; // B
            4'd4: str_combo = 7'h4F; // O
            4'd5: str_combo = 7'h3A; // :
            4'd6: str_combo = 7'h30 + huns;
            4'd7: str_combo = 7'h30 + tens;
            4'd8: str_combo = 7'h30 + ones;
            default: str_combo = 7'h20;
        endcase
    end
    endfunction

    // === ??????? ===
    
    // 1. PAUSED (2x, ??96, ???????)
    assign in_t_paused = state_paused && 
                         (DrawX >= T_PA_X0) && (DrawX < T_PA_X0 + 10'd96) &&
                         (DrawY >= T_PA_Y0) && (DrawY < T_PA_Y0 + 10'd32);
    
    // 2. PRESS P TO CONTINUE (2x, ??304, ???????)
    assign in_t_press_p = state_paused && 
                          (DrawX >= T_PP_X0) && (DrawX < T_PP_X0 + 10'd304) &&
                          (DrawY >= T_PP_Y0) && (DrawY < T_PP_Y0 + 10'd32);
    
    // 3. PRESS R TO RETRY (2x, ??256, ????????)
    assign in_t_press_r = (state_win || state_lose) && 
                          (DrawX >= T_PR_X0) && (DrawX < T_PR_X0 + 10'd256) &&
                          (DrawY >= T_PR_Y0) && (DrawY < T_PR_Y0 + 10'd32);
    
    // 4. [Tab] GAME MODE (1x, ??120, ???/????????)
    assign in_t_tab_mode = state_manual && 
                           (DrawX >= T_TB_X0) && (DrawX < T_TB_X0 + 10'd120) &&
                           (DrawY >= T_TB_Y0) && (DrawY < T_TB_Y0 + 10'd16);
    
    // 5. VOL. (1x, ??32, ??????UI)
    assign in_t_vol = state_manual && 
                      (DrawX >= T_VO_X0) && (DrawX < T_VO_X0 + 10'd32) &&
                      (DrawY >= T_VO_Y0) && (DrawY < T_VO_Y0 + 10'd16);
    
    // ----------------------------------------------------
    // ?????????????? (state_select) ?????? (??? 2x ????)
    // ----------------------------------------------------
    
    // 6. Peppa (??80)
    assign in_t_peppa = state_select && 
                        (DrawX >= T_PEP_X0) && (DrawX < T_PEP_X0 + 10'd80) &&
                        (DrawY >= T_PEP_Y0) && (DrawY < T_PEP_Y0 + 10'd32);
    
    // 7. Little Star (??176)
    assign in_t_little_star = state_select && 
                              (DrawX >= T_LS_X0) && (DrawX < T_LS_X0 + 10'd176) &&
                              (DrawY >= T_LS_Y0) && (DrawY < T_LS_Y0 + 10'd32);
    
    // 8. Harry Potter (??192)
    assign in_t_harry_potter = state_select && 
                               (DrawX >= T_HP_X0) && (DrawX < T_HP_X0 + 10'd192) &&
                               (DrawY >= T_HP_Y0) && (DrawY < T_HP_Y0 + 10'd32);

    //12. Choose a song to play
    assign in_t_choose = state_select && 
                         (DrawX >= T_CHOOSE_X0) && (DrawX < T_CHOOSE_X0 + 10'd352) &&
                         (DrawY >= T_CHOOSE_Y0) && (DrawY < T_CHOOSE_Y0 + 10'd32);
    
    // === ????? ASCII ?? ===
    function automatic [6:0] str_paused(input [2:0] i);
        case (i)
            3'd0: str_paused = 7'h50; 3'd1: str_paused = 7'h41;
            3'd2: str_paused = 7'h55; 3'd3: str_paused = 7'h53;
            3'd4: str_paused = 7'h45; 3'd5: str_paused = 7'h44;
            default: str_paused = 7'h20;
        endcase
    endfunction

    function automatic [6:0] str_vol(input [1:0] i);
        case (i)
            2'd0: str_vol = 7'h56; // V
            2'd1: str_vol = 7'h4F; // O
            2'd2: str_vol = 7'h4C; // L
            2'd3: str_vol = 7'h2E; // .
            default: str_vol = 7'h20;
        endcase
    endfunction

    function automatic [6:0] str_press_p(input [4:0] i);
        case (i)
            5'd0:  str_press_p = 7'h50; // P
            5'd1:  str_press_p = 7'h52; // R
            5'd2:  str_press_p = 7'h45; // E
            5'd3:  str_press_p = 7'h53; // S
            5'd4:  str_press_p = 7'h53; // S
            5'd5:  str_press_p = 7'h20; // ???
            5'd6:  str_press_p = 7'h50; // P
            5'd7:  str_press_p = 7'h20; // ???
            5'd8:  str_press_p = 7'h54; // T
            5'd9:  str_press_p = 7'h4F; // O
            5'd10: str_press_p = 7'h20; // ???
            5'd11: str_press_p = 7'h43; // C
            5'd12: str_press_p = 7'h4F; // O
            5'd13: str_press_p = 7'h4E; // N
            5'd14: str_press_p = 7'h54; // T
            5'd15: str_press_p = 7'h49; // I
            5'd16: str_press_p = 7'h4E; // N
            5'd17: str_press_p = 7'h55; // U
            5'd18: str_press_p = 7'h45; // E
            default: str_press_p = 7'h20;
        endcase
    endfunction

    function automatic [6:0] str_press_r_retry(input [3:0] i);
        case (i)
            4'd0:  str_press_r_retry = 7'h50; // P
            4'd1:  str_press_r_retry = 7'h52; // R
            4'd2:  str_press_r_retry = 7'h45; // E
            4'd3:  str_press_r_retry = 7'h53; // S
            4'd4:  str_press_r_retry = 7'h53; // S
            4'd5:  str_press_r_retry = 7'h20; // ???
            4'd6:  str_press_r_retry = 7'h52; // R
            4'd7:  str_press_r_retry = 7'h20; // ???
            4'd8:  str_press_r_retry = 7'h54; // T
            4'd9:  str_press_r_retry = 7'h4F; // O
            4'd10: str_press_r_retry = 7'h20; // ???
            4'd11: str_press_r_retry = 7'h52; // R
            4'd12: str_press_r_retry = 7'h45; // E
            4'd13: str_press_r_retry = 7'h54; // T
            4'd14: str_press_r_retry = 7'h52; // R
            4'd15: str_press_r_retry = 7'h59; // Y
            default: str_press_r_retry = 7'h20;
        endcase
    endfunction

    function automatic [6:0] str_paren_p(input [1:0] i);
        case (i)
            2'd0:  str_paren_p = 7'h28; // (
            2'd1:  str_paren_p = 7'h50; // P
            2'd2:  str_paren_p = 7'h29; // )
            default: str_paren_p = 7'h20; // ???
        endcase
    endfunction

    function automatic [6:0] str_tab_mode(input [3:0] i);
        case (i)
            4'd0:  str_tab_mode = 7'h5B; // [
            4'd1:  str_tab_mode = 7'h54; // T
            4'd2:  str_tab_mode = 7'h61; // a
            4'd3:  str_tab_mode = 7'h62; // b
            4'd4:  str_tab_mode = 7'h5D; // ]
            4'd5:  str_tab_mode = 7'h20; // ???
            4'd6:  str_tab_mode = 7'h47; // G
            4'd7:  str_tab_mode = 7'h41; // A
            4'd8:  str_tab_mode = 7'h4D; // M
            4'd9:  str_tab_mode = 7'h45; // E
            4'd10: str_tab_mode = 7'h20; // ???
            4'd11: str_tab_mode = 7'h4D; // M
            4'd12: str_tab_mode = 7'h4F; // O
            4'd13: str_tab_mode = 7'h44; // D
            4'd14: str_tab_mode = 7'h45; // E
            default: str_tab_mode = 7'h20;
        endcase
    endfunction

    function automatic [6:0] str_little_star(input [3:0] i);
        case (i)
            4'd0:  str_little_star = 7'h4C; // L
            4'd1:  str_little_star = 7'h69; // i
            4'd2:  str_little_star = 7'h74; // t
            4'd3:  str_little_star = 7'h74; // t
            4'd4:  str_little_star = 7'h6C; // l
            4'd5:  str_little_star = 7'h65; // e
            4'd6:  str_little_star = 7'h20; // ???
            4'd7:  str_little_star = 7'h53; // S
            4'd8:  str_little_star = 7'h74; // t
            4'd9:  str_little_star = 7'h61; // a
            4'd10: str_little_star = 7'h72; // r
            default: str_little_star = 7'h20;
        endcase
    endfunction

    function automatic [6:0] str_peppa(input [2:0] i);
        case (i)
            3'd0:  str_peppa = 7'h50; // P
            3'd1:  str_peppa = 7'h65; // e
            3'd2:  str_peppa = 7'h70; // p
            3'd3:  str_peppa = 7'h70; // p
            3'd4:  str_peppa = 7'h61; // a
            default: str_peppa = 7'h20;
        endcase
    endfunction

    function automatic [6:0] str_harry_potter(input [3:0] i);
        case (i)
            4'd0:  str_harry_potter = 7'h48; // H
            4'd1:  str_harry_potter = 7'h61; // a
            4'd2:  str_harry_potter = 7'h72; // r
            4'd3:  str_harry_potter = 7'h72; // r
            4'd4:  str_harry_potter = 7'h79; // y
            4'd5:  str_harry_potter = 7'h20; // ???
            4'd6:  str_harry_potter = 7'h50; // P
            4'd7:  str_harry_potter = 7'h6F; // o
            4'd8:  str_harry_potter = 7'h74; // t
            4'd9:  str_harry_potter = 7'h74; // t
            4'd10: str_harry_potter = 7'h65; // e
            4'd11: str_harry_potter = 7'h72; // r
            default: str_harry_potter = 7'h20;
        endcase
    endfunction


    function automatic [6:0] digit_ascii(input [3:0] d);
        // ??????????????? d ????? 0~9??
        // ??? C ????????????????? ASCII >??=??? ????????
        if (d <= 4'd9) digit_ascii = 7'h30 + {3'b000, d};
        else           digit_ascii = 7'h30;
    endfunction

    // "best score:XXX" - 14 chars (indices 0-13)
    function automatic [6:0] str_best_score(input [3:0] i, input [3:0] huns, input [3:0] tens, input [3:0] ones);
        case (i)
            4'd0:  str_best_score = 7'h62; // b
            4'd1:  str_best_score = 7'h65; // e
            4'd2:  str_best_score = 7'h73; // s
            4'd3:  str_best_score = 7'h74; // t
            4'd4:  str_best_score = 7'h20; // space
            4'd5:  str_best_score = 7'h73; // s
            4'd6:  str_best_score = 7'h63; // c
            4'd7:  str_best_score = 7'h6F; // o
            4'd8:  str_best_score = 7'h72; // r
            4'd9:  str_best_score = 7'h65; // e
            4'd10: str_best_score = 7'h3A; // :
            4'd11: str_best_score = digit_ascii(huns); // hundreds
            4'd12: str_best_score = digit_ascii(tens);
            4'd13: str_best_score = digit_ascii(ones);
            default: str_best_score = 7'h20;
        endcase
    endfunction
    
    function automatic [6:0] str_choose(input [4:0] i);
        case (i)
            5'd0: str_choose = 7'h43;  // C
            5'd1: str_choose = 7'h68;  // h
            5'd2: str_choose = 7'h6F;  // o
            5'd3: str_choose = 7'h6F;  // o
            5'd4: str_choose = 7'h73;  // s
            5'd5: str_choose = 7'h65;  // e
            5'd6: str_choose = 7'h20;  // (???)
            5'd7: str_choose = 7'h61;  // a
            5'd8: str_choose = 7'h20;  // (???)
            5'd9: str_choose = 7'h73;  // s
            5'd10: str_choose = 7'h6F; // o
            5'd11: str_choose = 7'h6E; // n
            5'd12: str_choose = 7'h67; // g
            5'd13: str_choose = 7'h20; // (???)
            5'd14: str_choose = 7'h74; // t
            5'd15: str_choose = 7'h6F; // o
            5'd16: str_choose = 7'h20; // (???)
            5'd17: str_choose = 7'h70; // p
            5'd18: str_choose = 7'h6C; // l
            5'd19: str_choose = 7'h61; // a
            5'd20: str_choose = 7'h79; // y
            5'd21: str_choose = 7'h21; // !
            default: str_choose = 7'h20;
        endcase
    endfunction
    
    function automatic [6:0] str_as_name(input [2:0] song, input [3:0] ch);
        case (song)
            3'd0: case (ch)  // "Harry Potter"
                4'd0: str_as_name = 7'h48; // H
                4'd1: str_as_name = 7'h61; // a
                4'd2: str_as_name = 7'h72; // r
                4'd3: str_as_name = 7'h72; // r
                4'd4: str_as_name = 7'h79; // y
                4'd5: str_as_name = 7'h20; // (space)
                4'd6: str_as_name = 7'h50; // P
                4'd7: str_as_name = 7'h6F; // o
                4'd8: str_as_name = 7'h74; // t
                4'd9: str_as_name = 7'h74; // t
                4'd10: str_as_name= 7'h65; // e
                4'd11: str_as_name= 7'h72; // r
                default: str_as_name = 7'h20;
            endcase
            3'd1: case (ch)  // "Super Mario"
                4'd0: str_as_name = 7'h53; // S
                4'd1: str_as_name = 7'h75; // u
                4'd2: str_as_name = 7'h70; // p
                4'd3: str_as_name = 7'h65; // e
                4'd4: str_as_name = 7'h72; // r
                4'd5: str_as_name = 7'h20; // (space)
                4'd6: str_as_name = 7'h4D; // M
                4'd7: str_as_name = 7'h61; // a
                4'd8: str_as_name = 7'h72; // r
                4'd9: str_as_name = 7'h69; // i
                4'd10: str_as_name= 7'h6F; // o
                default: str_as_name = 7'h20;
            endcase
            3'd2: case (ch)  // "NOKIA"
                4'd0: str_as_name = 7'h4E; // N
                4'd1: str_as_name = 7'h4F; // O
                4'd2: str_as_name = 7'h4B; // K
                4'd3: str_as_name = 7'h49; // I
                4'd4: str_as_name = 7'h41; // A
                default: str_as_name = 7'h20;
            endcase
            3'd3: case (ch)  // "Farewell Letter"
                4'd0:  str_as_name = 7'h46; // F
                4'd1:  str_as_name = 7'h61; // a
                4'd2:  str_as_name = 7'h72; // r
                4'd3:  str_as_name = 7'h65; // e
                4'd4:  str_as_name = 7'h77; // w
                4'd5:  str_as_name = 7'h65; // e
                4'd6:  str_as_name = 7'h6C; // l
                4'd7:  str_as_name = 7'h6C; // l
                4'd8:  str_as_name = 7'h20; // (space)
                4'd9:  str_as_name = 7'h4C; // L
                4'd10: str_as_name = 7'h65; // e
                4'd11: str_as_name = 7'h74; // t
                4'd12: str_as_name = 7'h74; // t
                4'd13: str_as_name = 7'h65; // e
                4'd14: str_as_name = 7'h72; // r
                default: str_as_name = 7'h20;
            endcase
            3'd4: case (ch)  // "Imperial March"
                4'd0: str_as_name = 7'h49; // I
                4'd1: str_as_name = 7'h6D; // m
                4'd2: str_as_name = 7'h70; // p
                4'd3: str_as_name = 7'h65; // e
                4'd4: str_as_name = 7'h72; // r
                4'd5: str_as_name = 7'h69; // i
                4'd6: str_as_name = 7'h61; // a
                4'd7: str_as_name = 7'h6C; // l
                4'd8: str_as_name = 7'h20; // (space)
                4'd9: str_as_name = 7'h4D; // M
                4'd10: str_as_name= 7'h61; // a
                4'd11: str_as_name= 7'h72; // r
                4'd12: str_as_name= 7'h63; // c
                4'd13: str_as_name= 7'h68; // h
                default: str_as_name = 7'h20;
            endcase
            3'd5: case (ch)  // "Game of Thrones"
                4'd0: str_as_name = 7'h47; // G
                4'd1: str_as_name = 7'h61; // a
                4'd2: str_as_name = 7'h6D; // m
                4'd3: str_as_name = 7'h65; // e
                4'd4: str_as_name = 7'h20; // (space)
                4'd5: str_as_name = 7'h6F; // o
                4'd6: str_as_name = 7'h66; // f
                4'd7: str_as_name = 7'h20; // (space)
                4'd8: str_as_name = 7'h54; // T
                4'd9: str_as_name = 7'h68; // h
                4'd10: str_as_name= 7'h72; // r
                4'd11: str_as_name= 7'h6F; // o
                4'd12: str_as_name= 7'h6E; // n
                4'd13: str_as_name= 7'h65; // e
                4'd14: str_as_name= 7'h73; // s
                default: str_as_name = 7'h20;
            endcase
            3'd6: case (ch)  // "Cantina Band"
                4'd0: str_as_name = 7'h43; // C
                4'd1: str_as_name = 7'h61; // a
                4'd2: str_as_name = 7'h6E; // n
                4'd3: str_as_name = 7'h74; // t
                4'd4: str_as_name = 7'h69; // i
                4'd5: str_as_name = 7'h6E; // n
                4'd6: str_as_name = 7'h61; // a
                4'd7: str_as_name = 7'h20; // (space)
                4'd8: str_as_name = 7'h42; // B
                4'd9: str_as_name = 7'h61; // a
                4'd10: str_as_name= 7'h6E; // n
                4'd11: str_as_name= 7'h64; // d
                default: str_as_name = 7'h20;
            endcase
            3'd7: case (ch)  // "Mii Channel"
                4'd0: str_as_name = 7'h4D; // M
                4'd1: str_as_name = 7'h69; // i
                4'd2: str_as_name = 7'h69; // i
                4'd3: str_as_name = 7'h20; // (space)
                4'd4: str_as_name = 7'h43; // C
                4'd5: str_as_name = 7'h68; // h
                4'd6: str_as_name = 7'h61; // a
                4'd7: str_as_name = 7'h6E; // n
                4'd8: str_as_name = 7'h6E; // n
                4'd9: str_as_name = 7'h65; // e
                4'd10: str_as_name= 7'h6C; // l
                default: str_as_name = 7'h20;
            endcase
            default: str_as_name = 7'h20;
        endcase
    endfunction

        // === ???????? font ???? (priority mux) ===
    logic [6:0] cur_ascii;
    logic [3:0] cur_pixel_y;
    logic [2:0] cur_pixel_x;
    logic       in_any_text;

    always_comb begin
        in_any_text = 1'b0;
        cur_ascii   = 7'h20;
        cur_pixel_x = 3'd0;
        cur_pixel_y = 4'd0;

        // Auto-select grid song names (highest priority)
        if (in_as_text) begin
            in_any_text = 1'b1;
            cur_ascii   = str_as_name(as_idx, as_char_idx);
            cur_pixel_x = as_pix_x;
            cur_pixel_y = as_pix_y;

        end else if (in_t_new_best) begin
            in_any_text = 1'b1;
            cur_ascii   = str_new_best((DrawX - T_NB_X0) >> 4);
            cur_pixel_x = ((DrawX - T_NB_X0) >> 1) & 3'd7;
            cur_pixel_y = ((DrawY - T_NB_Y0) >> 1) & 4'd15;

        end else if (in_t_infinite) begin
            in_any_text = 1'b1;
            cur_ascii   = str_infinite((DrawX - T_INF_X0) >> 4);
            cur_pixel_x = ((DrawX - T_INF_X0) >> 1) & 3'd7;
            cur_pixel_y = ((DrawY - T_INF_Y0) >> 1) & 4'd15;
        end else if (in_t_combo) begin
            in_any_text = 1'b1;

            if (combo_scale3) begin
                cur_ascii = str_combo(
                    (DrawX - T_COMBO_X0) / 10'd24,
                    combo_hundreds,
                    combo_tens,
                    combo_ones
                );
                cur_pixel_x = ((DrawX - T_COMBO_X0) / 10'd3) & 3'd7;
                cur_pixel_y = ((DrawY - (T_COMBO_Y0 - 10'd16)) / 10'd3) & 4'd15;
            end else if (combo_scale2) begin
                cur_ascii = str_combo(
                    (DrawX - T_COMBO_X0) >> 4,
                    combo_hundreds,
                    combo_tens,
                    combo_ones
                );
                cur_pixel_x = ((DrawX - T_COMBO_X0) >> 1) & 3'd7;
                cur_pixel_y = ((DrawY - (T_COMBO_Y0 - 10'd8)) >> 1) & 4'd15;
            end else begin
                cur_ascii = str_combo(
                    (DrawX - T_COMBO_X0) >> 3,
                    combo_hundreds,
                    combo_tens,
                    combo_ones
                );
                cur_pixel_x = (DrawX - T_COMBO_X0) & 3'd7;
                cur_pixel_y = (DrawY - T_COMBO_Y0) & 4'd15;
            end

        end else if (in_t_paused) begin
            in_any_text = 1'b1;
            cur_ascii   = str_paused((DrawX - T_PA_X0) >> 4);
            cur_pixel_x = ((DrawX - T_PA_X0) >> 1) & 3'd7;
            cur_pixel_y = ((DrawY - T_PA_Y0) >> 1) & 4'd15;
            
        end else if (in_t_press_p) begin
            in_any_text = 1'b1;
            cur_ascii   = str_press_p((DrawX - T_PP_X0) >> 4);
            cur_pixel_x = ((DrawX - T_PP_X0) >> 1) & 3'd7;
            cur_pixel_y = ((DrawY - T_PP_Y0) >> 1) & 4'd15;
            
        end else if (in_t_press_r) begin
            in_any_text = 1'b1;
            cur_ascii   = str_press_r_retry((DrawX - T_PR_X0) >> 4);
            cur_pixel_x = ((DrawX - T_PR_X0) >> 1) & 3'd7;
            cur_pixel_y = ((DrawY - T_PR_Y0) >> 1) & 4'd15;
            
        end else if (in_t_best1) begin
            in_any_text = 1'b1;
            cur_ascii   = str_best_score((DrawX - T_BS_X0) >> 3, sel_best0_huns, sel_best0_tens, sel_best0_ones);
            cur_pixel_x = (DrawX - T_BS_X0) & 3'd7;
            cur_pixel_y = (DrawY - T_BS1_Y0) & 4'd15;

        end else if (in_t_best2) begin
            in_any_text = 1'b1;
            cur_ascii   = str_best_score((DrawX - T_BS_X0) >> 3, sel_best1_huns, sel_best1_tens, sel_best1_ones);
            cur_pixel_x = (DrawX - T_BS_X0) & 3'd7;
            cur_pixel_y = (DrawY - T_BS2_Y0) & 4'd15;

        end else if (in_t_best3) begin
            in_any_text = 1'b1;
            cur_ascii   = str_best_score((DrawX - T_BS_X0) >> 3, sel_best2_huns, sel_best2_tens, sel_best2_ones);
            cur_pixel_x = (DrawX - T_BS_X0) & 3'd7;
            cur_pixel_y = (DrawY - T_BS3_Y0) & 4'd15;

        end else if (in_t_peppa) begin
            in_any_text = 1'b1;
            cur_ascii   = str_peppa((DrawX - T_PEP_X0) >> 4);
            cur_pixel_x = ((DrawX - T_PEP_X0) >> 1) & 3'd7;
            cur_pixel_y = ((DrawY - T_PEP_Y0) >> 1) & 4'd15;
            
        end else if (in_t_little_star) begin
            in_any_text = 1'b1;
            cur_ascii   = str_little_star((DrawX - T_LS_X0) >> 4);
            cur_pixel_x = ((DrawX - T_LS_X0) >> 1) & 3'd7;
            cur_pixel_y = ((DrawY - T_LS_Y0) >> 1) & 4'd15;
            
        end else if (in_t_harry_potter) begin
            in_any_text = 1'b1;
            cur_ascii   = str_harry_potter((DrawX - T_HP_X0) >> 4);
            cur_pixel_x = ((DrawX - T_HP_X0) >> 1) & 3'd7;
            cur_pixel_y = ((DrawY - T_HP_Y0) >> 1) & 4'd15;
            
        end else if (in_t_choose) begin
            in_any_text = 1'b1;
            cur_ascii   = str_choose((DrawX - T_CHOOSE_X0) >> 4);
            cur_pixel_x = ((DrawX - T_CHOOSE_X0) >> 1) & 3'd7;
            cur_pixel_y = ((DrawY - T_CHOOSE_Y0) >> 1) & 4'd15;

        // ----------------------------------------------------
        // ?? 1x ????????? ??
        // ?????????(DrawX - X0) >> 3  (???? 8)
        // ?????? X??(DrawX - X0) & 3'd7
        // ?????? Y??(DrawY - Y0) & 4'd15
        // ----------------------------------------------------
        end else if (in_t_tab_mode) begin
            in_any_text = 1'b1;
            cur_ascii   = str_tab_mode((DrawX - T_TB_X0) >> 3);
            cur_pixel_x = (DrawX - T_TB_X0) & 3'd7;
            cur_pixel_y = (DrawY - T_TB_Y0) & 4'd15;

        end else if (in_t_vol) begin
            in_any_text = 1'b1;
            cur_ascii   = str_vol((DrawX - T_VO_X0) >> 3);
            cur_pixel_x = (DrawX - T_VO_X0) & 3'd7;
            cur_pixel_y = (DrawY - T_VO_Y0) & 4'd15;

        end
    end
    assign font_addr = {cur_ascii, cur_pixel_y};
    logic font_lit_combo;
    assign font_lit_combo = in_any_text && font_data[3'd7 - cur_pixel_x];
    
// ================================================================
    // ?????? "non-sprite" ?????? (combinational)
    // ================================================================
    logic [7:0] ns_r, ns_g, ns_b;

    always_comb begin
        // ??????????????
        ns_r = 8'h5A; ns_g = 8'h8A; ns_b = 8'hC0;

        if (state_manual || state_auto) begin
            // ?? ?????????????? ??
            
            // Auto-select grid background
            if      (in_as_grid && !as_cell_valid)    begin ns_r=8'h5A; ns_g=8'h8A; ns_b=8'hC0; end
            else if (in_as_grid && as_cell_border)     begin ns_r=8'h59; ns_g=8'h42; ns_b=8'h14; end
            else if (in_as_grid && as_cell_sel)        begin ns_r=8'hFF; ns_g=8'h8E; ns_b=8'h4C; end
            else if (in_as_grid)                       begin ns_r=8'hE0; ns_g=8'hAE; ns_b=8'h40; end

            else if (m1_on_any_tile)             begin ns_r=8'hFF; ns_g=8'hEE; ns_b=8'hDE; end // ?????Tile?????
            else if (m1_in_y && m1_in_x && m1_on_col_border)
                                            begin ns_r=8'h59; ns_g=8'h42; ns_b=8'h14; end // ????????????
            else if (m1_in_y && m1_in_x)    begin ns_r=8'hE0; ns_g=8'hAE; ns_b=8'h40; end // ?????????????
            
            else if (in_wave_fill) begin
                if (draw_line) begin ns_r=icon_line_r; ns_g=icon_line_g; ns_b=icon_line_b; end
                else           begin ns_r=icon_bg_r;   ns_g=icon_bg_g;   ns_b=icon_bg_b;   end
            end
            else if (in_oct_fill) begin
                if (oct_box_active)       begin ns_r=8'hFF; ns_g=8'h8E; ns_b=8'h4C; end // ??????????????
                else if (oct_box == 4'd4) begin ns_r=8'h59; ns_g=8'h42; ns_b=8'h14; end // ??????????
                else                      begin ns_r=8'h87; ns_g=8'h63; ns_b=8'h1B; end // ???????????
            end
            else if (black_hit) begin
                if      (keymask[black_semi])      begin ns_r=8'hFF; ns_g=8'h8E; ns_b=8'h4C; end // ????????????????
                else if ((game_st==3'd1) && auto_keymask[black_semi]) begin ns_r=8'h3E; ns_g=8'h51; ns_b=8'h65; end // ???????????????
                else                               begin ns_r=8'h87; ns_g=8'h63; ns_b=8'h1B; end // ????????????
            end
            else if (in_key_x && in_key_y) begin
                if ((x_in_white < BORDER_W) || (x_in_white >= (KEY_W - BORDER_W)))
                                                   begin ns_r=8'h59; ns_g=8'h42; ns_b=8'h14; end // ????????????
                else if (white_n < 4'd14 && keymask[white_semi])
                                                   begin ns_r=8'hFF; ns_g=8'h8E; ns_b=8'h4C; end // ????????????????
                else if (white_n < 4'd14 && (game_st==3'd1) && auto_keymask[white_semi])
                                                   begin ns_r=8'h3E; ns_g=8'h51; ns_b=8'h65; end // ???????????????
                else                               begin ns_r=8'hFF; ns_g=8'hEE; ns_b=8'hDE; end // ???????????????
            end
            else if (in_key_y)                     begin ns_r=8'h3E; ns_g=8'h51; ns_b=8'h65; end // ????????????????
            else if ((DrawY >= DIVIDER_Y0) && (DrawY < KEY_AREA_Y0))
                                                   begin ns_r=8'hFF; ns_g=8'hC8; ns_b=8'h5D; end // ???????????????
            else                                   begin ns_r=8'hFF; ns_g=8'hC8; ns_b=8'h5D; end // ??????????????????

        end else if (state_select) begin
            // ?? ????????????? ??
            
            ns_r=8'h3E; ns_g=8'h51; ns_b=8'h65; // ?????????????

            // ??????? 1
            if (in_card1) begin
                if (on_card1_border) begin
                    if (sel_song == 2'd0) begin ns_r=8'hFF; ns_g=8'h8E; ns_b=8'h4C; end // ????????????
                    else                  begin ns_r=8'h59; ns_g=8'h42; ns_b=8'h14; end // ????????????
                end else                  begin ns_r=8'hFF; ns_g=8'hEE; ns_b=8'hDE; end // ???????????
                
                if (in_c1_star)           begin ns_r=8'hFF; ns_g=8'h8E; ns_b=8'h4C; end // ?????????
            end
            
            // ??????? 2
            if (in_card2) begin
                if (on_card2_border) begin
                    if (sel_song == 2'd1) begin ns_r=8'hFF; ns_g=8'h8E; ns_b=8'h4C; end
                    else                  begin ns_r=8'h59; ns_g=8'h42; ns_b=8'h14; end
                end else                  begin ns_r=8'hFF; ns_g=8'hEE; ns_b=8'hDE; end
                
                if (in_c2_star_a || in_c2_star_b)
                                          begin ns_r=8'hFF; ns_g=8'h8E; ns_b=8'h4C; end
            end
            
            // ??????? 3
            if (in_card3) begin
                if (on_card3_border) begin
                    if (sel_song == 2'd2) begin ns_r=8'hFF; ns_g=8'h8E; ns_b=8'h4C; end
                    else                  begin ns_r=8'h59; ns_g=8'h42; ns_b=8'h14; end
                end else                  begin ns_r=8'hFF; ns_g=8'hEE; ns_b=8'hDE; end
                
                if (in_c3_star_a || in_c3_star_b || in_c3_star_c)
                                          begin ns_r=8'hFF; ns_g=8'h8E; ns_b=8'h4C; end
            end
            
            // ??????????????
            if (in_sidebar) begin ns_r=8'h59; ns_g=8'h42; ns_b=8'h14; end    // ???????????????????????????
            if (on_main_split) begin ns_r=8'h59; ns_g=8'h42; ns_b=8'h14; end // ???????????

        end else begin
            // COUNTDOWN / PLAYING / PAUSED / WIN / LOSE
            // ??????????? bg_rom
            ns_r = bg_r; ns_g = bg_g; ns_b = bg_b;
        
            // tile ??????? (??????, ???? tile ????)
            if (g_on_col_border && DrawY < G_KEYPAD_Y0)
                                              begin ns_r=ns_r >> 1; ns_g=ns_g >> 1; ns_b=ns_b; end
        
            // ???????
            if (g_in_keypad) begin
                if (g_on_keypad_border)       begin ns_r=8'h60; ns_g=8'h60; ns_b=8'h80; end
                else if (g_col_flash)         begin ns_r=8'hFF; ns_g=8'h30; ns_b=8'h30; end
                else if (g_key_lit)           begin ns_r=8'h80; ns_g=8'hFF; ns_b=8'hFF; end
                // ???? border / flash / lit ?, ??? bg (???????)
            end
        
            if (on_main_split)                begin ns_r=8'h40; ns_g=8'h40; ns_b=8'h60; end

        
            // WIN/LOSE ?????? (????, ?? bg ????)
            if (state_win && DrawY < G_KEYPAD_Y0) begin
                ns_r = (ns_r - (ns_r >> 2));
                ns_g = (ns_g - (ns_g >> 2));
                ns_b = (ns_b - (ns_b >> 2)) + 8'h30;
            end
            if (state_lose && DrawY < G_KEYPAD_Y0) begin
                ns_r = (ns_r - (ns_r >> 2)) + 8'h28;
                ns_g = (ns_g - (ns_g >> 2)) + 8'h10;
                ns_b = (ns_b - (ns_b >> 2));
            end
        end
    end

    // ================================================================
    // ????????? register 1 cycle ?? BRAM ???????
    // ================================================================
    logic [7:0] ns_r_d, ns_g_d, ns_b_d;
    logic       g_on_any_tile_d;
    logic       in_digit_region_d;
    logic       in_star_region_d;
    logic       in_win_region_d;
    logic       in_lose_region_d;
    logic       dim_overlay_d;
    logic in_pause_region_d, in_continue_region_d, in_retry_region_d;
    logic font_lit_d;
    logic select_card_text_d;
    logic in_as_text_d, as_cell_sel_d;
    logic in_t_paused_d;
    logic state_select_d;
    logic in_t_infinite_d;
    logic [1:0] cur_tile_state_d;
    logic       below_keypad_d;
    logic in_t_combo_d;
    logic combo_anim_active_d;
    logic combo_milestone_anim_d;

    logic in_wave_sprite_d;

    always_ff @(posedge clk_25MHz) begin
        ns_r_d            <= ns_r;
        ns_g_d            <= ns_g;
        ns_b_d            <= ns_b;
        g_on_any_tile_d   <= g_on_any_tile && (state_playing || state_paused || state_countdown);
        in_digit_region_d <= in_digit_region;
        in_star_region_d  <= in_star_region;
        in_win_region_d   <= in_win_region;
        in_lose_region_d  <= in_lose_region;
        in_pause_region_d    <= in_pause_region;
        in_continue_region_d <= in_continue_region;
        in_retry_region_d    <= in_retry_region;
        dim_overlay_d     <= dim_overlay;
        font_lit_d    <= font_lit_combo;
        // ?????????????????/??????????? best score ?????????????
        select_card_text_d <= in_t_peppa || in_t_little_star || in_t_harry_potter;
        in_t_infinite_d<=in_t_infinite;
        in_t_combo_d <= in_t_combo;
        combo_anim_active_d <= combo_anim_active;
        combo_milestone_anim_d <= combo_milestone_anim;

        in_wave_sprite_d <= in_wave_sprite;

        in_t_paused_d <= in_t_paused;
        state_select_d <= state_select;
        cur_tile_state_d <= cur_tile_state;
        below_keypad_d   <= below_keypad;
        in_as_text_d  <= in_as_text;
        as_cell_sel_d <= as_cell_sel;
    end

    // ================================================================
    // ???? mux (?????: lose > win > star > digit > tile > non-sprite)
    // ??? idx 0 ??????????? (ns_*)
    // ================================================================
    logic [7:0] r_pre, g_pre, b_pre;

    always_comb begin
        if (font_lit_d) begin
            if (in_t_combo_d && combo_milestone_anim_d) begin
                r_pre = 8'hF2;
                g_pre = 8'h9A;
                b_pre = 8'hFF;
            end else if (in_t_combo_d && combo_anim_active_d) begin
                r_pre = 8'h80;
                g_pre = 8'hFF;
                b_pre = 8'hFF;
            end else if (in_as_text_d) begin
                r_pre = 8'h59;
                g_pre = 8'h42;
                b_pre = 8'h14;
            end else if (state_select_d) begin
                if (select_card_text_d) begin
                    r_pre = 8'h59;
                    g_pre = 8'h42;
                    b_pre = 8'h14;
                end else begin
                    r_pre = 8'hFF;
                    g_pre = 8'hEE;
                    b_pre = 8'hDE;
                end
            end else begin
                if (in_t_infinite_d) begin
                    r_pre = 8'h59;
                    g_pre = 8'h42;
                    b_pre = 8'h14;
                end else begin
                    r_pre = 8'hFF;
                    g_pre = 8'hEE;
                    b_pre = 8'hA8;
                end
            end

        end else if (in_pause_region_d && !pause_trans) begin
            r_pre = pause_r;
            g_pre = pause_g;
            b_pre = pause_b;

        end else if (in_continue_region_d && !continue_trans) begin
            r_pre = continue_r;
            g_pre = continue_g;
            b_pre = continue_b;

        end else if (in_retry_region_d && !retry_trans) begin
            r_pre = retry_r;
            g_pre = retry_g;
            b_pre = retry_b;

        end else if (in_lose_region_d && !lose_trans) begin
            r_pre = lose_r;
            g_pre = lose_g;
            b_pre = lose_b;

        end else if (in_win_region_d && !win_trans) begin
            r_pre = win_r;
            g_pre = win_g;
            b_pre = win_b;

        end else if (in_star_region_d && !star_trans) begin
            r_pre = star_r;
            g_pre = star_g;
            b_pre = star_b;

        end else if (in_digit_region_d && !digit_trans) begin
            r_pre = digit_r;
            g_pre = digit_g;
            b_pre = digit_b;

        end else if (g_on_any_tile_d && !tile_trans) begin
            if (cur_tile_hold_d && below_keypad_d) begin
                r_pre = 8'h40;
                g_pre = 8'h8E;
                b_pre = 8'h81;
            end else begin
                r_pre = tile_r;
                g_pre = tile_g;
                b_pre = tile_b;
            end

        end else if (in_wave_sprite_d && !wave_transparent) begin
            r_pre = wave_r;
            g_pre = wave_g;
            b_pre = wave_b;

        end else begin
            r_pre = ns_r_d;
            g_pre = ns_g_d;
            b_pre = ns_b_d;
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
