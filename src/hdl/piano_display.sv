//=============================================================================
// piano_display.sv  --  Week 2 Day 4: HDMI 钢琴 UI (2 octaves, black keys, octave indicator)
//
// 显示布局 (640x480):
//   y = 0..29   : 音域指示条 (9 个小方块, 当前音域高亮)
//   y = 30..159 : 上半屏 (黑色, 给 Day 5 falling notes 留)
//   y = 160..179: 分隔条 (灰)
//   y = 180..359: 键盘上半部分 (白键 + 黑键重叠)
//   y = 360..479: 键盘下半部分 (只有白键, 黑键已结束)
//
// 键盘 x 布局:
//   KEY_LEFT = 40, 14 个白键每个 40px 宽, 共 560px, 尾部 40px 空白
//   黑键宽 24px, 居中在相邻白键的交界上
//   2 个八度共 14 白 + 10 黑 = 24 个半音, 对应 keymask[23:0]
//
// 键位对应:
//   bit 0  = C4 (白), bit 1  = C#4 (黑), bit 2  = D4 (白), bit 3  = D#4 (黑)
//   bit 4  = E4 (白), bit 5  = F4 (白),  bit 6  = F#4 (黑), bit 7  = G4 (白)
//   bit 8  = G#4(黑), bit 9  = A4 (白),  bit 10 = A#4(黑),  bit 11 = B4 (白)
//   bit 12 = C5 (白), ... 依此类推
//
// octave_idx = 0..8, 4=无偏移, 0=下移4, 8=上移4
//=============================================================================
module piano_display (
    input  logic [9:0]  DrawX,
    input  logic [9:0]  DrawY,
    input  logic [23:0] keymask,
    input  logic [3:0]  octave_idx,  // 0..8, 4=center
    output logic [7:0]  R,
    output logic [7:0]  G,
    output logic [7:0]  B
);

    // ---- 常量 ----
    localparam logic [9:0] KEY_LEFT     = 10'd40;
    localparam logic [9:0] KEY_RIGHT    = 10'd600;   // 40 + 14*40
    localparam logic [9:0] KEY_W        = 10'd40;
    localparam logic [9:0] KEY_AREA_Y0  = 10'd180;
    localparam logic [9:0] DIVIDER_Y0   = 10'd160;
    localparam logic [9:0] BLACK_KEY_H  = 10'd180;   // 黑键从 y=180 到 360
    localparam logic [9:0] BLACK_HALF_W = 10'd12;    // 黑键宽 24, 左右各 12
    localparam logic [9:0] BORDER_W     = 10'd2;

    // 音域指示条
    localparam logic [9:0] OCT_Y0       = 10'd6;
    localparam logic [9:0] OCT_Y1       = 10'd22;    // 高 16px
    localparam logic [9:0] OCT_X0       = 10'd240;   // 9 个 16px 方块 + 8 个 2px 间距 = 160
    localparam logic [9:0] OCT_BOX_W    = 10'd18;    // 方块 + 间距
    localparam logic [9:0] OCT_BOX_FILL = 10'd16;    // 方块本体宽度

    // ---- 白键 ----
    logic [9:0] x_rel;
    logic [3:0] white_n;         // 0..13
    logic [5:0] x_in_white;      // 0..39
    logic in_key_x, in_key_y;

    assign in_key_x    = (DrawX >= KEY_LEFT) && (DrawX < KEY_RIGHT);
    assign in_key_y    = (DrawY >= KEY_AREA_Y0);
    assign x_rel       = in_key_x ? (DrawX - KEY_LEFT) : 10'd0;
    assign white_n     = in_key_x ? x_rel[9:0] / KEY_W : 4'd15;
    assign x_in_white  = in_key_x ? x_rel[9:0] - (white_n * KEY_W) : 6'd0;

    // 白键序号 → 半音 (C=0, D=2, E=4, F=5, G=7, A=9, B=11 模式)
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
            default: white_semi = 5'd31;  // 无效
        endcase
    end

    // ---- 黑键 ----
    // 10 个黑键的 x 中心坐标 (绝对) 和对应的半音
    // 80,120,(skip),200,240,280,(skip),360,400,(skip),480,520,560
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

    // ---- 音域指示条 (顶部 9 个方块) ----
    logic in_oct_y, in_oct_x;
    logic [9:0] oct_x_rel;
    logic [3:0] oct_box;
    logic in_oct_fill, oct_box_active;

    assign in_oct_y        = (DrawY >= OCT_Y0) && (DrawY < OCT_Y1);
    assign in_oct_x        = (DrawX >= OCT_X0) && (DrawX < (OCT_X0 + 9*OCT_BOX_W));
    assign oct_x_rel       = in_oct_x ? (DrawX - OCT_X0) : 10'd0;
    assign oct_box         = in_oct_x ? oct_x_rel[9:0] / OCT_BOX_W : 4'd15;
    assign in_oct_fill     = in_oct_y && in_oct_x &&
                             ((oct_x_rel - oct_box * OCT_BOX_W) < OCT_BOX_FILL);
    assign oct_box_active  = (oct_box == octave_idx);

    // ---- 最终颜色 ----
    always_comb begin
        if (in_oct_fill) begin
            // 音域指示格
            if (oct_box_active) begin
                R = 8'hFF; G = 8'hD0; B = 8'h30;   // 当前音域: 黄
            end else if (oct_box == 4'd4) begin
                R = 8'h60; G = 8'h60; B = 8'h80;   // 中心格 (shift=0) 稍亮
            end else begin
                R = 8'h30; G = 8'h30; B = 8'h40;   // 其他格: 暗蓝灰
            end
        end
        else if (black_hit) begin
            // 黑键覆盖在白键上方
            if (keymask[black_semi]) begin
                R = 8'hFF; G = 8'hA0; B = 8'h00;   // 按下: 橙
            end else begin
                R = 8'h10; G = 8'h10; B = 8'h10;   // 正常: 近黑
            end
        end
        else if (in_key_x && in_key_y) begin
            // 白键
            if ((x_in_white < BORDER_W) || (x_in_white >= (KEY_W - BORDER_W))) begin
                R = 8'h00; G = 8'h00; B = 8'h00;   // 键间黑边
            end
            else if (white_n < 4'd14 && keymask[white_semi]) begin
                R = 8'hFF; G = 8'hD0; B = 8'h30;   // 按下: 黄
            end
            else begin
                R = 8'hFF; G = 8'hFF; B = 8'hFF;   // 正常: 白
            end
        end
        else if (in_key_y) begin
            // 键区两侧 margin
            R = 8'h20; G = 8'h20; B = 8'h20;
        end
        else if ((DrawY >= DIVIDER_Y0) && (DrawY < KEY_AREA_Y0)) begin
            // 分隔条
            R = 8'h40; G = 8'h40; B = 8'h40;
        end
        else begin
            // 上半屏 (黑, 给 Day 5 falling notes 用)
            R = 8'h00; G = 8'h00; B = 8'h00;
        end
    end

endmodule
