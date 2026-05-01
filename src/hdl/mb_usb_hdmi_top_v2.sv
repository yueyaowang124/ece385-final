//-------------------------------------------------------------------------
//    mb_usb_hdmi_top_v2.sv  --  Day 4 v2 + 波形切换
//
//    相对 v1 的改动:
//      - 新增 wave_idx[2:0] 内部信号 (从 BD 新加的 gpio_wave 拉出来)
//      - piano_display 新增 .wave_idx 端口
//      - BD wrapper 端口新增 .gpio_wave_tri_o[2:0]
//
//    BD 修改步骤 (写在文件注释里, 方便查):
//      1. 加一个 AXI GPIO, 名字 gpio_wave
//         - 3-bit, All Outputs, Default=0
//         - AXI 地址自动分配 (记下来写到 xparameters.h 里)
//      2. Run Connection Automation, Master = M_AXI_DP (MB)
//      3. 把 gpio_wave 的 GPIO 端口 External, 命名 gpio_wave
//      4. Validate + Generate Output Products + Create HDL Wrapper (强制重生)
//      5. 验证 mb_block_wrapper.v 里出现了 gpio_wave_tri_o[2:0] 端口
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

    //Switches (保留, 可以不接任何逻辑, 只是 BD 端口还在)
    input  logic [15:0] SW,

    //Audio (立体声双声道 PDM)
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

    //---------------- 内部信号 ----------------
    logic [23:0] keymask;
    logic [3:0]  octave_idx;
    logic [2:0]  wave_idx;        // ← 新增 (来自 BD 新加的 gpio_wave)

    logic        clk_25MHz, clk_125MHz;
    logic        locked;
    logic [9:0]  drawX, drawY;

    logic        hsync, vsync, vde;
    logic [3:0]  red, green, blue;
    logic [7:0]  r_pix, g_pix, b_pix;
    logic        reset_ah;

    assign reset_ah = reset_rtl_0;

    //---------------- HEX 显示 keymask ----------------
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

    //---------------- MicroBlaze BD 实例 ----------------
    // 端口注意:
    //   gpio_wave_tri_o 是 BD 里新加的 AXI GPIO -> External 端口名叫 gpio_wave
    //   BD 自动生成的 wrapper 端口名可能是 gpio_wave_tri_o[2:0], 如果不一样照抄即可
    mb_block_wrapper mb_block_i (
        .SW_tri_i           (SW),
        .audio_pdm_out      (audio_pdm_out),
        .audio_pdm_r        (audio_pdm_r),
        .clk_100MHz         (Clk),
        .gpio_usb_int_tri_i (gpio_usb_int_tri_i),
        .gpio_usb_rst_tri_o (gpio_usb_rst_tri_o),
        .gpio_wave_tri_o    (wave_idx),               // ← 新增: 3-bit
        .keymask_tri_o      (keymask),
        .octave_tri_o       (octave_idx),
        .reset_rtl          (~reset_ah),
        .uart_rtl_0_rxd     (uart_rtl_0_rxd),
        .uart_rtl_0_txd     (uart_rtl_0_txd),
        .usb_spi_miso       (usb_spi_miso),
        .usb_spi_mosi       (usb_spi_mosi),
        .usb_spi_sclk       (usb_spi_sclk),
        .usb_spi_ss         (usb_spi_ss)
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

    //---------------- 钢琴 UI (升级) ----------------
    piano_display piano_inst (
        .DrawX      (drawX),
        .DrawY      (drawY),
        .keymask    (keymask),
        .octave_idx (octave_idx),
        .wave_idx   (wave_idx),       // ← 新增
        .R          (r_pix),
        .G          (g_pix),
        .B          (b_pix)
    );

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
