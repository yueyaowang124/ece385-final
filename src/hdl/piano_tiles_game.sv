//=============================================================================
// piano_tiles_game.sv  —  钢琴块游戏核心逻辑
//
// 屏幕: 640×480, 60Hz
// 轨道: 4列 (A/S/D/F)，每列宽160px
// 钢琴块: 匀速下落 3px/frame (=180px/s)
// 弹奏区: y=380~480（警戒线y=380，死亡线y=480）
// 判定: 块底边 y_bot ∈ [380,480] 时按键有效
//
// 计分: hit=+1, miss=-1，积分范围用饱和计数 -5~+5
// 胜利条件: score==5
// 失败条件: 已发生足够多miss使score无法到达5（或曲子播完score<5）
//
// 乐谱: 小猪佩奇，15个音符，映射到 S/D/F 三列（A列始终空）
// 同时最多2个钢琴块
//=============================================================================
module piano_tiles_game (
    input  logic        clk,           // 100MHz
    input  logic        reset_n,       // 低电平复位
    input  logic        game_start,    // 脉冲：开始游戏（来自按钮或GPIO）
    input  logic        vsync,         // 60Hz帧同步（用于计时）

    // 玩家按键（来自AXI GPIO，电平信号，1=按下）
    input  logic        key_a,         // 最左列（实际未用，预留）
    input  logic        key_s,
    input  logic        key_d,
    input  logic        key_f,

    // 渲染输出（给 piano_tiles_display.sv）
    // 每列各1个活跃块（简化：每列同时最多1块）
    output logic [9:0]  tile_y_top [0:3],   // 4列块的顶部y
    output logic [9:0]  tile_y_bot [0:3],   // 4列块的底部y
    output logic [1:0]  tile_state [0:3],   // 00=下落 01=hit绿 10=miss红 11=无效
    output logic        tile_valid  [0:3],  // 该列是否有块

    // 分数（有符号4位，-8~+7，实际使用-5~+5）
    output logic signed [3:0] score,

    // 游戏状态
    output logic        game_over,     // 1=游戏结束
    output logic        game_win,      // 1=胜利（score==5）

    // DDS音效控制（直接输出phase_inc，由顶层接到DDS IP）
    output logic [31:0] dds_phase_0,   // 声道0 phase_inc
    output logic [31:0] dds_phase_1,   // 声道1 phase_inc（错误蜂鸣用）
    output logic        dds_enable     // DDS使能
);

    // ================================================================
    // 参数
    // ================================================================
    localparam logic [9:0] THRESH_Y   = 10'd380;  // 弹奏区上边界（可按键）
    localparam logic [9:0] DEAD_Y     = 10'd480;  // 死亡线（块消失）
    localparam logic [9:0] TILE_SPEED = 10'd3;    // 每帧下落像素
    localparam logic [9:0] SCREEN_H   = 10'd480;

    // 错误蜂鸣音频率（440Hz的A4）
    localparam logic [31:0] BEEP_PHASE = 32'd18897;

    // 每帧计数器（vsync边沿=1帧）
    // 生成节奏计时器：TICK_MS=125ms，60fps → 每tick=7.5帧 ≈ 8帧
    // 精确值: 125ms * 60fps = 7.5 → 用分数计数器避免累积误差
    // 方案: 每帧加10，每tick阈值=75 (10*7.5=75)
    localparam integer TICK_ACCUM_INC  = 10;
    localparam integer TICK_ACCUM_MAX  = 75;

    // 钢琴块生成高度（像素）= ticks * 7.5 * 3 = ticks * 22.5 ≈ ticks * 22
    // 用定点: height = ticks * 225 / 10
    // 但硬件乘法不方便，直接查表
    function automatic logic [9:0] ticks_to_height(input logic [2:0] t);
        case (t)
            3'd1: return 10'd23;
            3'd2: return 10'd45;
            3'd3: return 10'd68;
            default: return 10'd23;
        endcase
    endfunction

    // ================================================================
    // 乐谱数据（15个音符）
    // 每音符: 4列phase_inc + ticks
    // 列0=A(空), 列1=S, 列2=D, 列3=F
    // ================================================================
    localparam integer SCORE_LEN = 15;

    // phase_inc：0=此列无块
    logic [31:0] score_lane [0:SCORE_LEN-1][0:3];
    logic [2:0]  score_ticks[0:SCORE_LEN-1];

    initial begin
        // note 0: G5+G4 → S+F
        score_lane[0][0]=0; score_lane[0][1]=32'd16838; score_lane[0][2]=0; score_lane[0][3]=32'd33676;
        score_ticks[0]=3'd2;
        // note 1: E5 → D
        score_lane[1][0]=0; score_lane[1][1]=0; score_lane[1][2]=32'd28314; score_lane[1][3]=0;
        score_ticks[1]=3'd1;
        // note 2: C5 → D
        score_lane[2][0]=0; score_lane[2][1]=0; score_lane[2][2]=32'd22473; score_lane[2][3]=0;
        score_ticks[2]=3'd1;
        // note 3: D5+B4 → S+F
        score_lane[3][0]=0; score_lane[3][1]=32'd21213; score_lane[3][2]=0; score_lane[3][3]=32'd25215;
        score_ticks[3]=3'd2;
        // note 4: G5+G4 → S+F
        score_lane[4][0]=0; score_lane[4][1]=32'd16838; score_lane[4][2]=0; score_lane[4][3]=32'd33676;
        score_ticks[4]=3'd2;
        // note 5: G4+low → S+F (G3超范围用G4代替F列)
        score_lane[5][0]=0; score_lane[5][1]=32'd8419; score_lane[5][2]=0; score_lane[5][3]=32'd16838;
        score_ticks[5]=3'd1;
        // note 6: B4 → D
        score_lane[6][0]=0; score_lane[6][1]=0; score_lane[6][2]=32'd21213; score_lane[6][3]=0;
        score_ticks[6]=3'd1;
        // note 7: D5+B4 → S+F
        score_lane[7][0]=0; score_lane[7][1]=32'd21213; score_lane[7][2]=0; score_lane[7][3]=32'd25215;
        score_ticks[7]=3'd1;
        // note 8: F5 → D
        score_lane[8][0]=0; score_lane[8][1]=0; score_lane[8][2]=32'd30000; score_lane[8][3]=0;
        score_ticks[8]=3'd1;
        // note 9: E5+C5 → S+F
        score_lane[9][0]=0; score_lane[9][1]=32'd22473; score_lane[9][2]=0; score_lane[9][3]=32'd28314;
        score_ticks[9]=3'd2;
        // note 10: C5+G4 → S+F
        score_lane[10][0]=0; score_lane[10][1]=32'd16838; score_lane[10][2]=0; score_lane[10][3]=32'd22473;
        score_ticks[10]=3'd2;
        // note 11: E5+C5 → S+F (3ticks)
        score_lane[11][0]=0; score_lane[11][1]=32'd22473; score_lane[11][2]=0; score_lane[11][3]=32'd28314;
        score_ticks[11]=3'd3;
        // note 12: E5 → D
        score_lane[12][0]=0; score_lane[12][1]=0; score_lane[12][2]=32'd28314; score_lane[12][3]=0;
        score_ticks[12]=3'd1;
        // note 13: G5+G4 → S+F
        score_lane[13][0]=0; score_lane[13][1]=32'd16838; score_lane[13][2]=0; score_lane[13][3]=32'd33676;
        score_ticks[13]=3'd2;
        // note 14: REST
        score_lane[14][0]=0; score_lane[14][1]=0; score_lane[14][2]=0; score_lane[14][3]=0;
        score_ticks[14]=3'd2;
    end

    // ================================================================
    // 游戏状态机
    // ================================================================
    typedef enum logic [1:0] {
        ST_IDLE    = 2'd0,
        ST_PLAYING = 2'd1,
        ST_RESULT  = 2'd2
    } game_state_t;

    game_state_t state;

    // ================================================================
    // 钢琴块结构（每列1个槽）
    // ================================================================
    logic [9:0]  t_top   [0:3];  // 块顶部y
    logic [9:0]  t_bot   [0:3];  // 块底部y
    logic [31:0] t_phase [0:3];  // 对应DDS phase_inc
    logic [1:0]  t_state [0:3];  // 00=下落 01=hit 10=miss 11=空
    logic        t_valid [0:3];  // 是否有效

    localparam logic [1:0] TS_FALLING = 2'd0;
    localparam logic [1:0] TS_HIT     = 2'd1;
    localparam logic [1:0] TS_MISS    = 2'd2;
    localparam logic [1:0] TS_EMPTY   = 2'd3;

    // 当前音符索引
    logic [3:0] note_idx;

    // 节奏计时器（分数累加避免误差）
    logic [7:0]  tick_accum;     // 每帧加10，≥75时=一个tick
    logic [15:0] tick_remain;    // 当前音符剩余tick（×10以保持精度）

    // vsync上升沿检测
    logic vsync_r;
    logic vsync_rise;
    always_ff @(posedge clk) vsync_r <= vsync;
    assign vsync_rise = vsync && !vsync_r;

    // 按键上升沿（边沿检测）
    logic key_a_r, key_s_r, key_d_r, key_f_r;
    logic edge_a, edge_s, edge_d, edge_f;
    always_ff @(posedge clk) begin
        key_a_r <= key_a; key_s_r <= key_s;
        key_d_r <= key_d; key_f_r <= key_f;
    end
    assign edge_a = key_a && !key_a_r;
    assign edge_s = key_s && !key_s_r;
    assign edge_d = key_d && !key_d_r;
    assign edge_f = key_f && !key_f_r;

    // 分数（有符号，-5~+5）
    logic signed [3:0] score_r;
    assign score = score_r;

    // 反馈闪烁计时（hit/miss后保持绿/红N帧）
    logic [5:0] flash_cnt [0:3];
    localparam FLASH_FRAMES = 6'd30;  // 保持30帧=0.5s

    // DDS音效
    logic [31:0] dds_ph0, dds_ph1;
    logic        dds_en;
    assign dds_phase_0 = dds_ph0;
    assign dds_phase_1 = dds_ph1;
    assign dds_enable  = dds_en;

    // 渲染输出连线
    genvar gi;
    generate
        for (gi = 0; gi < 4; gi++) begin : tile_out
            assign tile_y_top[gi] = t_top[gi];
            assign tile_y_bot[gi] = t_bot[gi];
            assign tile_state[gi] = t_state[gi];
            assign tile_valid[gi] = t_valid[gi];
        end
    endgenerate

    assign game_over = (state == ST_RESULT);
    assign game_win  = (state == ST_RESULT) && (score_r == 4'sd5);

    // ================================================================
    // 生成新的一组钢琴块（从乐谱读取当前note_idx对应的音符）
    // ================================================================
    task automatic spawn_note(input logic [3:0] idx);
        int c;
        for (c = 0; c < 4; c++) begin
            if (score_lane[idx][c] != 32'd0) begin
                t_top[c]   <= 10'd0;    // 从屏幕顶部生成
                t_bot[c]   <= ticks_to_height(score_ticks[idx]);
                t_phase[c] <= score_lane[idx][c];
                t_state[c] <= TS_FALLING;
                t_valid[c] <= 1'b1;
                flash_cnt[c] <= 6'd0;
            end
            // 若该列无音符，不覆盖现有块（可能上一个还未消失）
        end
    endtask

    // ================================================================
    // 判定按键：col=哪列，edge=是否有新按下
    // ================================================================
    task automatic judge_key(input int col, input logic edge_press);
        if (edge_press) begin
            if (t_valid[col] && t_state[col] == TS_FALLING &&
                t_bot[col] >= THRESH_Y) begin
                // 在弹奏区内按下 → HIT
                t_state[col]  <= TS_HIT;
                flash_cnt[col] <= FLASH_FRAMES;
                // 发声：用该列的phase_inc
                dds_ph0 <= t_phase[col];
                dds_ph1 <= 32'd0;
                dds_en  <= 1'b1;
                // 加分（饱和到+5）
                if (score_r < 4'sd5)
                    score_r <= score_r + 4'sd1;
            end else begin
                // 按错（无块 或 块未到达 或 已经hit）→ MISS
                dds_ph0 <= BEEP_PHASE;  // 错误蜂鸣
                dds_ph1 <= 32'd0;
                dds_en  <= 1'b1;
                // 轨道闪红（用 TS_MISS 在已有块上标记，或单独闪列）
                if (t_valid[col])
                    t_state[col] <= TS_MISS;
                flash_cnt[col] <= FLASH_FRAMES;
                // 减分（饱和到-5）
                if (score_r > -4'sd5)
                    score_r <= score_r - 4'sd1;
            end
        end
    endtask

    // ================================================================
    // 主状态机
    // ================================================================
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            state    <= ST_IDLE;
            score_r  <= 4'sd0;
            note_idx <= 4'd0;
            tick_accum   <= 8'd0;
            tick_remain  <= 16'd0;
            dds_ph0  <= 32'd0;
            dds_ph1  <= 32'd0;
            dds_en   <= 1'b0;
            for (int i = 0; i < 4; i++) begin
                t_top[i]   <= 10'd0;
                t_bot[i]   <= 10'd0;
                t_phase[i] <= 32'd0;
                t_state[i] <= TS_EMPTY;
                t_valid[i] <= 1'b0;
                flash_cnt[i] <= 6'd0;
            end
        end else begin

            // 每帧处理
            if (vsync_rise) begin
                // 关闭DDS（只持续1帧的触发，之后由phase_inc=0静音）
                // 实际：按下时打开，放开时关闭，这里简化：
                // 音效持续整个hit/miss flash期间
                // （若需更精确，可在flash_cnt==0时清phase）

                case (state)
                // ---------------------------------------------------
                ST_IDLE: begin
                    if (game_start) begin
                        state    <= ST_PLAYING;
                        score_r  <= 4'sd0;
                        note_idx <= 4'd0;
                        tick_accum  <= 8'd0;
                        tick_remain <= {score_ticks[0], 13'd0};  // ticks * 8192（简化）
                        // 实际用: tick_remain = ticks * TICK_ACCUM_MAX
                        tick_remain <= score_ticks[0] * TICK_ACCUM_MAX;
                        spawn_note(4'd0);
                    end
                end

                // ---------------------------------------------------
                ST_PLAYING: begin
                    // --- 1. 移动所有有效块 ---
                    for (int c = 0; c < 4; c++) begin
                        if (t_valid[c]) begin
                            // 下落
                            if (t_state[c] == TS_FALLING || t_state[c] == TS_HIT) begin
                                if (t_top[c] + TILE_SPEED < SCREEN_H)
                                    t_top[c] <= t_top[c] + TILE_SPEED;
                                else
                                    t_top[c] <= SCREEN_H;

                                if (t_bot[c] + TILE_SPEED < SCREEN_H)
                                    t_bot[c] <= t_bot[c] + TILE_SPEED;
                                else
                                    t_bot[c] <= SCREEN_H;
                            end

                            // 块超出死亡线：判定miss（如果还是FALLING）
                            if (t_bot[c] >= DEAD_Y) begin
                                if (t_state[c] == TS_FALLING) begin
                                    // 玩家没按 → miss
                                    t_state[c]    <= TS_MISS;
                                    flash_cnt[c]  <= FLASH_FRAMES;
                                    dds_ph0       <= BEEP_PHASE;
                                    dds_en        <= 1'b1;
                                    if (score_r > -4'sd5)
                                        score_r <= score_r - 4'sd1;
                                end else begin
                                    // 已hit或已处理，直接无效
                                    t_valid[c] <= 1'b0;
                                    t_state[c] <= TS_EMPTY;
                                end
                            end

                            // flash计时
                            if (flash_cnt[c] > 6'd0) begin
                                flash_cnt[c] <= flash_cnt[c] - 6'd1;
                                if (flash_cnt[c] == 6'd1) begin
                                    // flash结束
                                    t_valid[c] <= 1'b0;
                                    t_state[c] <= TS_EMPTY;
                                    // 清DDS音效（若是最后一个活跃列）
                                    dds_ph0 <= 32'd0;
                                    dds_en  <= 1'b0;
                                end
                            end
                        end
                    end

                    // --- 2. 节奏计时，生成新块 ---
                    if (note_idx < SCORE_LEN) begin
                        if (tick_accum + TICK_ACCUM_INC >= TICK_ACCUM_MAX) begin
                            // 一个tick结束
                            tick_accum <= tick_accum + TICK_ACCUM_INC - TICK_ACCUM_MAX;
                            if (tick_remain > 0)
                                tick_remain <= tick_remain - 1;
                            else begin
                                // 当前音符结束，生成下一个
                                if (note_idx + 1 < SCORE_LEN) begin
                                    note_idx    <= note_idx + 4'd1;
                                    tick_remain <= score_ticks[note_idx + 1] - 1;
                                    spawn_note(note_idx + 4'd1);
                                end else begin
                                    note_idx <= SCORE_LEN;  // 乐谱播完
                                end
                            end
                        end else begin
                            tick_accum <= tick_accum + TICK_ACCUM_INC;
                        end
                    end else begin
                        // 乐谱播完，等所有块消失后结束
                        logic all_done;
                        all_done = 1'b1;
                        for (int c = 0; c < 4; c++)
                            if (t_valid[c]) all_done = 1'b0;
                        if (all_done)
                            state <= ST_RESULT;
                    end

                    // --- 3. 按键判定 ---
                    judge_key(0, edge_a);
                    judge_key(1, edge_s);
                    judge_key(2, edge_d);
                    judge_key(3, edge_f);

                    // --- 4. 提前胜利判断 ---
                    if (score_r == 4'sd5)
                        state <= ST_RESULT;
                end

                // ---------------------------------------------------
                ST_RESULT: begin
                    // 保持结果显示，等待重新开始
                    dds_ph0 <= 32'd0;
                    dds_en  <= 1'b0;
                    if (game_start) begin
                        state    <= ST_IDLE;
                        score_r  <= 4'sd0;
                        note_idx <= 4'd0;
                        for (int c = 0; c < 4; c++) begin
                            t_valid[c] <= 1'b0;
                            t_state[c] <= TS_EMPTY;
                        end
                    end
                end

                endcase
            end // vsync_rise
        end
    end

endmodule