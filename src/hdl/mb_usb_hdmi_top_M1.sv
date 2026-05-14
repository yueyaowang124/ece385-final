//-------------------------------------------------------------------------
//    mb_usb_hdmi_top_M1.sv
//
//    在你最新版 (有 auto_keymask) 的基础上加 falling tiles M1:
//      - 新增 logic [31:0] tile_word_lo
//      - mb_block_wrapper 新增端口 .gpio_tiles_lo_tri_o
//      - piano_display 新增端口 .tile_word_lo
//-------------------------------------------------------------------------

module mb_usb_hdmi_top(
    input  logic Clk,
    input  logic reset_rtl_0,

    //USB
    input  logic [0:0] gpio_usb_int_tri_i,
    output logic [0:0] gpio_usb_rst_tri_o,
    input  logic       usb_spi_miso,
    output logic       usb_spi_mosi,
    output logic       usb_spi_sclk,
    output logic [0:0] usb_spi_ss,

    //UART
    input  logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,

    //Switches
    input  logic [15:0] SW,

    //Audio
    output logic audio_pdm_out,
    output logic audio_pdm_r,

    //HDMI
    output logic       hdmi_tmds_clk_n,
    output logic       hdmi_tmds_clk_p,
    output logic [2:0] hdmi_tmds_data_n,
    output logic [2:0] hdmi_tmds_data_p,

    //HEX
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB
);

    logic [23:0] keymask;
    logic [23:0] auto_keymask;
    logic [3:0]  octave_idx;
    logic [2:0]  wave_idx;
    logic [31:0] tile_word_lo;       // ← M1 新增: 2 个 tile 状态

    logic        clk_25MHz, clk_125MHz;
    logic        locked;
    logic [9:0]  drawX, drawY;

    logic        hsync, vsync, vde;
    logic [3:0]  red, green, blue;
    logic [7:0]  r_pix, g_pix, b_pix;
    logic        reset_ah;

    assign reset_ah = reset_rtl_0;

    hex_driver HexA (
        .clk(clk_25MHz),
        .reset(reset_ah),
        .in({4'h0, 4'h0, keymask[15:12], keymask[11:8]}),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );
    hex_driver HexB (
        .clk(clk_25MHz),
        .reset(reset_ah),
        .in({4'h0, 4'h0, keymask[7:4], keymask[3:0]}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );

    mb_block_wrapper mb_block_i (
        .SW_tri_i               (SW),
        .audio_pdm_out          (audio_pdm_out),
        .audio_pdm_r            (audio_pdm_r),
        .clk_100MHz             (Clk),
        .gpio_usb_int_tri_i     (gpio_usb_int_tri_i),
        .gpio_usb_rst_tri_o     (gpio_usb_rst_tri_o),
        .gpio_wave_tri_o        (wave_idx),
        .gpio_autokey_tri_o     (auto_keymask),
        .gpio_tiles_lo_tri_o    (tile_word_lo),    // ← M1 新增
        .keymask_tri_o          (keymask),
        .octave_tri_o           (octave_idx),
        .reset_rtl              (reset_ah),
        .uart_rtl_0_rxd         (uart_rtl_0_rxd),
        .uart_rtl_0_txd         (uart_rtl_0_txd),
        .usb_spi_miso           (usb_spi_miso),
        .usb_spi_mosi           (usb_spi_mosi),
        .usb_spi_sclk           (usb_spi_sclk),
        .usb_spi_ss             (usb_spi_ss)
    );

    clk_wiz_0 clk_wiz (
        .clk_out1 (clk_25MHz),
        .clk_out2 (clk_125MHz),
        .reset    (reset_ah),
        .locked   (locked),
        .clk_in1  (Clk)
    );

    vga_controller vga (
        .pixel_clk     (clk_25MHz),
        .reset         (reset_ah),
        .hs            (hsync),
        .vs            (vsync),
        .active_nblank (vde),
        .drawX         (drawX),
        .drawY         (drawY)
    );

    piano_display piano_inst (
        .DrawX         (drawX),
        .DrawY         (drawY),
        .keymask       (keymask),
        .auto_keymask  (auto_keymask),
        .octave_idx    (octave_idx),
        .wave_idx      (wave_idx),
        .tile_word_lo  (tile_word_lo),     // ← M1 新增
        .R             (r_pix),
        .G             (g_pix),
        .B             (b_pix)
    );

    assign red   = r_pix[7:4];
    assign green = g_pix[7:4];
    assign blue  = b_pix[7:4];

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
