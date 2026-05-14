//=============================================================================
// piano_tiles_display.sv  —  钢琴块游戏VGA渲染
//
// 屏幕: 640×480
// 4列轨道，每列宽160px，含2px边框
// 警戒线: y=380，黄色水平线（高4px）
// 钢琴块颜色:
//   正常下落: 深灰背景，白色块
//   HIT:      绿色块 (00 E0 60)
//   MISS:     红色块 (E0 20 00)
//   无块时列闪红: 用 lane_flash[col] 信号
//
// 分数显示: 左上角，简单数字（用小点阵字体）
// 轨道标签: A S D F 在底部（y=455~475）
//=============================================================================
module piano_tiles_display (
    input  logic [9:0]  DrawX,
    input  logic [9:0]  DrawY,

    // 4列块数据（来自 piano_tiles_game）
    input  logic [9:0]  tile_y_top [0:3],
    input  logic [9:0]  tile_y_bot [0:3],
    input  logic [1:0]  tile_state [0:3],  // 00=下落 01=HIT 10=MISS 11=空
    input  logic        tile_valid [0:3],

    // 游戏状态
    input  logic signed [3:0] score,
    input  logic        game_over,
    input  logic        game_win,

    output logic [7:0]  R,
    output logic [7:0]  G,
    output logic [7:0]  B
);

    // ================================================================
    // 布局参数
    // ================================================================
    localparam logic [9:0] COL_W      = 10'd160;
    localparam logic [9:0] BORDER_W   = 10'd2;
    localparam logic [9:0] THRESH_Y   = 10'd380;  // 警戒线y
    localparam logic [9:0] THRESH_H   = 10'd4;    // 警戒线高度
    localparam logic [9:0] LABEL_Y0   = 10'd450;  // 键名标签y
    localparam logic [9:0] LABEL_Y1   = 10'd475;

    // ================================================================
    // 当前像素属于哪一列
    // ================================================================
    logic [1:0] col_idx;
    logic [9:0] x_in_col;    // 列内x坐标
    assign col_idx  = DrawX[9:0] / COL_W;
    assign x_in_col = DrawX - col_idx * COL_W;

    // ================================================================
    // 判断是否在某列的钢琴块内
    // ================================================================
    logic in_tile;
    logic [1:0] tile_st;
    always_comb begin
        in_tile = 1'b0;
        tile_st = 2'd3;
        if (col_idx < 2'd3 || DrawX < 10'd640) begin  // 防止越界
            if (tile_valid[col_idx] &&
                DrawY >= tile_y_top[col_idx] &&
                DrawY <  tile_y_bot[col_idx]) begin
                in_tile = 1'b1;
                tile_st = tile_state[col_idx];
            end
        end
    end

    // ================================================================
    // 是否在边框
    // ================================================================
    logic in_border;
    assign in_border = (x_in_col < BORDER_W) || (x_in_col >= COL_W - BORDER_W);

    // ================================================================
    // 是否在警戒线
    // ================================================================
    logic in_thresh;
    assign in_thresh = (DrawY >= THRESH_Y) && (DrawY < THRESH_Y + THRESH_H);

    // ================================================================
    // 是否在标签区（底部标签A S D F）
    // 用简单的固定颜色块 + 每列一个标识色
    // ================================================================
    logic in_label;
    assign in_label = (DrawY >= LABEL_Y0) && (DrawY < LABEL_Y1);

    // ================================================================
    // 分数显示（左上角，20×20区域，7段式数字）
    // 用简单LUT显示 -5~5
    // ================================================================
    // 为简洁，用颜色块表示分数：
    //   左上角10个小格子，绿=得分，红=失分
    logic [3:0] score_abs;
    logic       score_neg;
    logic [9:0] score_bar_x, score_bar_y;
    logic       in_score_area;

    assign score_neg = (score < 0);
    assign score_abs = score_neg ? (-score) : score;
    assign in_score_area = (DrawX < 10'd120) && (DrawY < 10'd20);
    assign score_bar_x   = DrawX / 10'd12;   // 10格，每格12px
    assign score_bar_y   = DrawY;

    // ================================================================
    // 胜利/失败横幅（中央，纯色大块）
    // ================================================================
    logic in_banner;
    assign in_banner = game_over &&
                       (DrawX >= 10'd160) && (DrawX < 10'd480) &&
                       (DrawY >= 10'd180) && (DrawY < 10'd300);

    // ================================================================
    // 颜色输出
    // ================================================================
    always_comb begin
        R = 8'h10; G = 8'h10; B = 8'h10;  // 默认深灰背景

        if (in_banner) begin
            // 游戏结束横幅
            if (game_win) begin
                // 胜利：金色
                R = 8'hFF; G = 8'hD0; B = 8'h00;
            end else begin
                // 失败：暗红
                R = 8'hC0; G = 8'h20; B = 8'h10;
            end
        end
        else if (in_score_area) begin
            // 分数条：绿格=得分，红格=失分，灰格=空
            if (score_bar_x < 10) begin
                if (!score_neg && score_bar_x < score_abs) begin
                    // 正分
                    R = 8'h20; G = 8'hC0; B = 8'h40;
                end else if (score_neg && (9 - score_bar_x) < score_abs) begin
                    // 负分
                    R = 8'hC0; G = 8'h20; B = 8'h10;
                end else begin
                    R = 8'h30; G = 8'h30; B = 8'h30;
                end
            end
        end
        else if (in_thresh) begin
            // 警戒线：明黄色
            R = 8'hFF; G = 8'hE0; B = 8'h00;
        end
        else if (in_border) begin
            // 列边框：深色分割线
            R = 8'h40; G = 8'h40; B = 8'h50;
        end
        else if (in_tile) begin
            // 钢琴块
            case (tile_st)
                2'd0: begin R = 8'hEE; G = 8'hEE; B = 8'hEE; end  // 下落：亮白
                2'd1: begin R = 8'h00; G = 8'hE0; B = 8'h60; end  // HIT：绿
                2'd2: begin R = 8'hE0; G = 8'h20; B = 8'h00; end  // MISS：红
                default: begin R = 8'h10; G = 8'h10; B = 8'h10; end
            endcase
        end
        else if (in_label) begin
            // 键名标签背景（比背景略亮）
            case (col_idx)
                2'd0: begin R = 8'h30; G = 8'h30; B = 8'h50; end  // A列：蓝紫
                2'd1: begin R = 8'h30; G = 8'h50; B = 8'h30; end  // S列：绿
                2'd2: begin R = 8'h50; G = 8'h30; B = 8'h30; end  // D列：红
                2'd3: begin R = 8'h50; G = 8'h50; B = 8'h20; end  // F列：黄
                default: begin R = 8'h20; G = 8'h20; B = 8'h20; end
            endcase
        end
        else begin
            // 普通背景：根据列稍有变化
            case (col_idx)
                2'd0: begin R = 8'h12; G = 8'h12; B = 8'h18; end
                2'd1: begin R = 8'h12; G = 8'h18; B = 8'h12; end
                2'd2: begin R = 8'h18; G = 8'h12; B = 8'h12; end
                2'd3: begin R = 8'h18; G = 8'h18; B = 8'h10; end
                default: begin R = 8'h10; G = 8'h10; B = 8'h10; end
            endcase
        end
    end

endmodule