//-------------------------------------------------------------------------
//    mb_usb_hdmi_top.sv   (Week 2 Day 4 v2: 2 octaves + black keys + octave shift)
//
//    相对 Lab 6 原版的改动:
//      - 删除 ball / color_mapper / keycode gpio
//      - 新增 audio_pdm_out 输出
//      - 新增 keymask (24-bit) 从 BD 传过来, 驱动 piano_display
//      - 新增 octave (4-bit)  从 BD 传过来, 驱动 piano_display 的指示条
//      - HEX 显示 keymask 低 16 bits (方便调试看哪些 bit 被按了)
//-------------------------------------------------------------------------

module mb_usb_hdmi_top(
    input  logic Clk,
    input  logic reset_rtl_0,

    //USB
    input  logic [0:0] gpio_usb_int_tri_i,
    output logic       gpio_usb_rst_tri_o,
    input  logic       usb_spi_miso,
    output logic       usb_spi_mosi,
    output logic       usb_spi_sclk,
    output logic       usb_spi_ss,

    //UART
    input  logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,

    //Audio
    output logic audio_pdm_out,

    //HDMI
    output logic       hdmi_tmds_clk_n,
    output logic       hdmi_tmds_clk_p,
    output logic [2:0] hdmi_tmds_data_n,
    output logic [2:0] hdmi_tmds_data_p,

    //HEX 显示 (调试: 显示 keymask 的低 16 bits)
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB
);

    //---------------- 内部信号 ----------------
    logic [23:0] keymask;               // 24-bit: 每个半音的按下状态
    logic [3:0]  octave_idx;            // 4-bit: 音域指示 (0..8, 4=中心)

    logic        clk_25MHz, clk_125MHz;
    logic        locked;
    logic [9:0]  drawX, drawY;

    logic        hsync, vsync, vde;
    logic [3:0]  red, green, blue;
    logic [7:0]  r_pix, g_pix, b_pix;
    logic        reset_ah;

    assign reset_ah = reset_rtl_0;

    //---------------- HEX 显示 keymask 的 16 bits (调试) ----------------
    // HexA: keymask[15:0] 的高 8 bits (= keymask[15:8])
    // HexB: keymask[15:0] 的低 8 bits (= keymask[7:0])
    // 高 8 bits (keymask[23:16]) 不显示; 用 xil_printf 看或者靠屏幕
    hex_driver HexA (
        .clk(Clk),
        .reset(reset_ah),
        .in({4'h0, 4'h0, keymask[15:12], keymask[11:8]}),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );

    hex_driver HexB (
        .clk(Clk),
        .reset(reset_ah),
        .in({4'h0, 4'h0, keymask[7:4], keymask[3:0]}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );

    //---------------- MicroBlaze BD 实例 ----------------
    // 注意: 这里模块名要和你 BD wrapper 文件 (mb_block_wrapper.v) 里的 module 名一致.
    //       你的 BD 叫 mb_block, 所以 wrapper 模块名是 mb_block_wrapper.
    //       打开 Sources → Design Sources → mb_block_wrapper.v 看第一行 module 名确认一下.
    //
    // 前提: BD 里必须有这两个 AXI GPIO, 都 Make External 过:
    //   gpio_keymask (24-bit, all outputs) → keymask_tri_o[23:0]
    //   gpio_octave  ( 4-bit, all outputs) → octave_tri_o[3:0]
    // 以及 audio_pdm_out Make External.
    mb_block_wrapper mb_block_i (
        .clk_100MHz         (Clk),
        .reset_rtl_0        (~reset_ah),
        .gpio_usb_int_tri_i (gpio_usb_int_tri_i),
        .gpio_usb_rst_tri_o (gpio_usb_rst_tri_o),
        .usb_spi_miso       (usb_spi_miso),
        .usb_spi_mosi       (usb_spi_mosi),
        .usb_spi_sclk       (usb_spi_sclk),
        .usb_spi_ss         (usb_spi_ss),
        .uart_rtl_0_rxd     (uart_rtl_0_rxd),
        .uart_rtl_0_txd     (uart_rtl_0_txd),
        .keymask_tri_o      (keymask),        // 24-bit
        .octave_tri_o       (octave_idx),     // 4-bit
        .audio_pdm_out      (audio_pdm_out)
    );

    //---------------- HDMI 时钟 ----------------
    clk_wiz_0 clk_wiz (
        .clk_out1 (clk_25MHz),
        .clk_out2 (clk_125MHz),
        .reset    (reset_ah),
        .locked   (locked),
        .clk_in1  (Clk)
    );

    //---------------- VGA Sync ----------------
    vga_controller vga (
        .pixel_clk     (clk_25MHz),
        .reset         (reset_ah),
        .hs            (hsync),
        .vs            (vsync),
        .active_nblank (vde),
        .drawX         (drawX),
        .drawY         (drawY)
    );

    //---------------- 钢琴 UI ----------------
    piano_display piano_inst (
        .DrawX      (drawX),
        .DrawY      (drawY),
        .keymask    (keymask),
        .octave_idx (octave_idx),
        .R          (r_pix),
        .G          (g_pix),
        .B          (b_pix)
    );

    // 8-bit → 4-bit (hdmi_tx_0 吃 4-bit)
    assign red   = r_pix[7:4];
    assign green = g_pix[7:4];
    assign blue  = b_pix[7:4];

    //---------------- HDMI TX ----------------
    hdmi_tx_0 vga_to_hdmi (
        .pix_clk        (clk_25MHz),
        .pix_clkx5      (clk_125MHz),
        .pix_clk_locked (locked),
        .rst            (reset_ah),

        .red            (red),
        .green          (green),
        .blue           (blue),
        .hsync          (hsync),
        .vsync          (vsync),
        .vde            (vde),

        .aux0_din       (4'b0),
        .aux1_din       (4'b0),
        .aux2_din       (4'b0),
        .ade            (1'b0),

        .TMDS_CLK_P     (hdmi_tmds_clk_p),
        .TMDS_CLK_N     (hdmi_tmds_clk_n),
        .TMDS_DATA_P    (hdmi_tmds_data_p),
        .TMDS_DATA_N    (hdmi_tmds_data_n)
    );

endmodule
