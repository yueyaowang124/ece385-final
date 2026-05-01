module piano_display (
    input  logic [9:0]  DrawX,
    input  logic [9:0]  DrawY,
    input  logic [23:0] keymask,       // bit[i]=1 → 手动按键高亮（橙色）
    input  logic [23:0] auto_keymask,  // bit[i]=1 → 自动演奏高亮（青色）
    input  logic [3:0]  octave_idx,
    input  logic [2:0]  wave_idx,
    output logic [7:0]  R,
    output logic [7:0]  G,
    output logic [7:0]  B
);
    // ================================================================
    // 布局参数
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
    localparam logic [9:0] WAVE_BOX_H   = WAVE_Y1 - WAVE_Y0;  // 24

    // ================================================================
    // 键盘区域几何
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

    // ================================================================
    // 八度指示器
    // ================================================================
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

    // ================================================================
    // 波形图标区域
    // ================================================================
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

    // 画布坐标：w_x=0..29, w_y=0..19，中心y=10，振幅=7（范围3..17）
    logic [4:0] w_x;
    logic [4:0] w_y;
    logic       in_canvas;
    assign in_canvas = in_wave_fill && (wave_local_x >= 10'd4) && (wave_local_x < 10'd34)
                                    && (wave_local_y >= 10'd2) && (wave_local_y < 10'd22);
    assign w_x = in_canvas ? (wave_local_x - 10'd4) : 5'd0;
    assign w_y = in_canvas ? (wave_local_y - 10'd2) : 5'd0;

    // ================================================================
    // 波形参考线计算
    // 每个 box 对应 dds.sv 中的 wave_sel：
    //   box 0 = Square    (wave_sel=0)
    //   box 1 = Triangle  (wave_sel=1)
    //   box 2 = Sawtooth  (wave_sel=2)
    //   box 3 = Sine      (wave_sel=3)  ← 真正的正弦曲线
    //   box 4 = Organ     (wave_sel=4)  ← 正弦+谐波（有ripple）
    //   box 5 = Vibrato   (wave_sel=5)  ← AM调制（幅度从小变大再变小）
    // ================================================================
    logic [4:0] ref_y;
    always_comb begin
        ref_y = 5'd10;
        case (wave_box)

            // 0: 方波 — 高段水平线 + 低段水平线，中间垂直跳变
            3'd0: begin
                if      (w_x < 5'd2)  ref_y = 5'd10;   // 过渡区
                else if (w_x < 5'd14) ref_y = 5'd4;    // 高电平
                else if (w_x < 5'd16) ref_y = 5'd10;   // 跳变区
                else if (w_x < 5'd28) ref_y = 5'd16;   // 低电平
                else                  ref_y = 5'd10;   // 过渡区
            end

            // 1: 三角波 — 一个完整/\周期
            3'd1: begin
                if (w_x < 5'd15)
                    ref_y = 5'd17 - w_x;           // 下降：17→3 (step≈1)
                else
                    ref_y = 5'd3  + (w_x - 5'd15); // 上升：3→17
            end

            // 2: 锯齿波 — 斜线下降 + 急速垂直回升（多点覆盖垂直段）
            3'd2: begin
                if (w_x <= 5'd24)
                    // 线性从y=3下降到y=17：每步约0.58像素
                    ref_y = 5'd3 + (w_x * 5'd14 / 5'd24);
                else begin
                    // 垂直跳变段：x=25→y=17, x=26→y=14, x=27→y=10, x=28→y=6, x=29→y=3
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

            // 3: 正弦波 — 用查表的方式给出精确正弦曲线坐标
            // 基于 Python 计算: y = 10 - round(7*sin(2π*x/29))，范围3..17
            3'd3: begin
                unique case (w_x)
                    5'd0:  ref_y = 5'd10;
                    5'd1:  ref_y = 5'd8;
                    5'd2:  ref_y = 5'd7;
                    5'd3:  ref_y = 5'd6;
                    5'd4:  ref_y = 5'd5;
                    5'd5:  ref_y = 5'd4;
                    5'd6:  ref_y = 5'd3;
                    5'd7:  ref_y = 5'd3;
                    5'd8:  ref_y = 5'd3;
                    5'd9:  ref_y = 5'd3;
                    5'd10: ref_y = 5'd4;
                    5'd11: ref_y = 5'd5;
                    5'd12: ref_y = 5'd6;
                    5'd13: ref_y = 5'd8;
                    5'd14: ref_y = 5'd9;
                    5'd15: ref_y = 5'd11;
                    5'd16: ref_y = 5'd12;
                    5'd17: ref_y = 5'd14;
                    5'd18: ref_y = 5'd15;
                    5'd19: ref_y = 5'd16;
                    5'd20: ref_y = 5'd17;
                    5'd21: ref_y = 5'd17;
                    5'd22: ref_y = 5'd17;
                    5'd23: ref_y = 5'd17;
                    5'd24: ref_y = 5'd16;
                    5'd25: ref_y = 5'd15;
                    5'd26: ref_y = 5'd14;
                    5'd27: ref_y = 5'd13;
                    5'd28: ref_y = 5'd12;
                    5'd29: ref_y = 5'd10;
                    default: ref_y = 5'd10;
                endcase
            end

            // 4: 风琴波 — 正弦+三次谐波叠加，曲线有明显"肩部"凸起
            // 基于 Python: y = 10 - round(7*(sin+0.4*sin3)/1.4)
            3'd4: begin
                unique case (w_x)
                    5'd0:  ref_y = 5'd10;
                    5'd1:  ref_y = 5'd8;
                    5'd2:  ref_y = 5'd6;
                    5'd3:  ref_y = 5'd5;
                    5'd4:  ref_y = 5'd5;
                    5'd5:  ref_y = 5'd6;
                    5'd6:  ref_y = 5'd7;
                    5'd7:  ref_y = 5'd7;
                    5'd8:  ref_y = 5'd7;
                    5'd9:  ref_y = 5'd6;
                    5'd10: ref_y = 5'd5;
                    5'd11: ref_y = 5'd5;
                    5'd12: ref_y = 5'd5;
                    5'd13: ref_y = 5'd7;
                    5'd14: ref_y = 5'd9;
                    5'd15: ref_y = 5'd11;
                    5'd16: ref_y = 5'd13;
                    5'd17: ref_y = 5'd15;
                    5'd18: ref_y = 5'd15;
                    5'd19: ref_y = 5'd15;
                    5'd20: ref_y = 5'd14;
                    5'd21: ref_y = 5'd13;
                    5'd22: ref_y = 5'd13;
                    5'd23: ref_y = 5'd13;
                    5'd24: ref_y = 5'd14;
                    5'd25: ref_y = 5'd15;
                    5'd26: ref_y = 5'd15;
                    5'd27: ref_y = 5'd14;
                    5'd28: ref_y = 5'd12;
                    5'd29: ref_y = 5'd10;
                    default: ref_y = 5'd10;
                endcase
            end

            // 5: 颤音波 — AM调制：两个正弦周期，幅度由包络线调制
            // 左半部分幅度小，右半部分幅度大
            // 基于 Python: y = 10 - round(7*am_env*sin(4π*x/29))
            3'd5: begin
                unique case (w_x)
                    5'd0:  ref_y = 5'd10;
                    5'd1:  ref_y = 5'd8;
                    5'd2:  ref_y = 5'd7;
                    5'd3:  ref_y = 5'd6;
                    5'd4:  ref_y = 5'd5;
                    5'd5:  ref_y = 5'd6;
                    5'd6:  ref_y = 5'd7;
                    5'd7:  ref_y = 5'd9;
                    5'd8:  ref_y = 5'd12;
                    5'd9:  ref_y = 5'd14;
                    5'd10: ref_y = 5'd16;
                    5'd11: ref_y = 5'd17;
                    5'd12: ref_y = 5'd16;
                    5'd13: ref_y = 5'd14;
                    5'd14: ref_y = 5'd12;
                    5'd15: ref_y = 5'd8;
                    5'd16: ref_y = 5'd6;
                    5'd17: ref_y = 5'd4;
                    5'd18: ref_y = 5'd3;
                    5'd19: ref_y = 5'd4;
                    5'd20: ref_y = 5'd6;
                    5'd21: ref_y = 5'd8;
                    5'd22: ref_y = 5'd11;
                    5'd23: ref_y = 5'd13;
                    5'd24: ref_y = 5'd14;
                    5'd25: ref_y = 5'd15;
                    5'd26: ref_y = 5'd14;
                    5'd27: ref_y = 5'd13;
                    5'd28: ref_y = 5'd12;
                    5'd29: ref_y = 5'd10;
                    default: ref_y = 5'd10;
                endcase
            end

            default: ref_y = 5'd10;
        endcase
    end

    logic [4:0] dy;
    assign dy = (w_y > ref_y) ? (w_y - ref_y) : (ref_y - w_y);
    assign draw_line = in_canvas && (dy <= 5'd1);
    logic draw_line;

    // ================================================================
    // 波形图标颜色
    // ================================================================
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
    // 最终颜色输出
    // 优先级：波形图标 > 八度指示 > 黑键 > 白键 > 背景
    // 按键颜色：
    //   手动按键   → 橙色  FF D0 30  (keymask)
    //   自动演奏   → 青色  00 E8 D0  (auto_keymask)
    // ================================================================
    always_comb begin
        if (in_wave_fill) begin
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
            if      (keymask[black_semi])      begin R = 8'hFF; G = 8'hA0; B = 8'h00; end  // 手动：橙
            else if (auto_keymask[black_semi]) begin R = 8'h00; G = 8'hE8; B = 8'hD0; end  // 自动：青
            else                               begin R = 8'h10; G = 8'h10; B = 8'h10; end  // 黑键默认
        end
        else if (in_key_x && in_key_y) begin
            if ((x_in_white < BORDER_W) || (x_in_white >= (KEY_W - BORDER_W)))
                                               begin R = 8'h00; G = 8'h00; B = 8'h00; end  // 边框
            else if (white_n < 4'd14 && keymask[white_semi])
                                               begin R = 8'hFF; G = 8'hD0; B = 8'h30; end  // 手动：橙
            else if (white_n < 4'd14 && auto_keymask[white_semi])
                                               begin R = 8'h00; G = 8'hE8; B = 8'hD0; end  // 自动：青
            else                               begin R = 8'hFF; G = 8'hFF; B = 8'hFF; end  // 白键默认
        end
        else if (in_key_y)                     begin R = 8'h20; G = 8'h20; B = 8'h20; end
        else if ((DrawY >= DIVIDER_Y0) && (DrawY < KEY_AREA_Y0))
                                               begin R = 8'h40; G = 8'h40; B = 8'h40; end
        else                                   begin R = 8'h00; G = 8'h00; B = 8'h00; end
    end

endmodule