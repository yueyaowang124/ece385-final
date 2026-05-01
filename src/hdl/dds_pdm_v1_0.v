`timescale 1 ns / 1 ps
//=============================================================================
// dds_pdm_v1_0.sv  (原 .v 改为 .sv，与其他 SystemVerilog 源文件统一)
//=============================================================================
module dds_pdm_v1_0 #
(
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 5
)
(
    output wire audio_pdm_out,

    input  wire  s00_axi_aclk,
    input  wire  s00_axi_aresetn,
    input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input  wire [2 : 0] s00_axi_awprot,
    input  wire  s00_axi_awvalid,
    output wire  s00_axi_awready,
    input  wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input  wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input  wire  s00_axi_wvalid,
    output wire  s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire  s00_axi_bvalid,
    input  wire  s00_axi_bready,
    input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input  wire [2 : 0] s00_axi_arprot,
    input  wire  s00_axi_arvalid,
    output wire  s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire  s00_axi_rvalid,
    input  wire  s00_axi_rready
);

    // 内部信号：从 AXI slave 寄存器引出
    wire [31:0] w_phase_inc_0;
    wire [31:0] w_phase_inc_1;
    wire [31:0] w_phase_inc_2;
    wire [31:0] w_phase_inc_3;
    wire [31:0] w_enable;
    wire [31:0] w_wave_sel;

    // AXI Slave 寄存器模块
    dds_pdm_v1_0_S00_AXI #(
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) dds_pdm_v1_0_S00_AXI_inst (
        .reg0_phase_inc_0 (w_phase_inc_0),
        .reg1_phase_inc_1 (w_phase_inc_1),
        .reg2_phase_inc_2 (w_phase_inc_2),
        .reg3_phase_inc_3 (w_phase_inc_3),
        .reg4_enable      (w_enable),
        .reg5_wave_sel    (w_wave_sel),

        .S_AXI_ACLK    (s00_axi_aclk),
        .S_AXI_ARESETN (s00_axi_aresetn),
        .S_AXI_AWADDR  (s00_axi_awaddr),
        .S_AXI_AWPROT  (s00_axi_awprot),
        .S_AXI_AWVALID (s00_axi_awvalid),
        .S_AXI_AWREADY (s00_axi_awready),
        .S_AXI_WDATA   (s00_axi_wdata),
        .S_AXI_WSTRB   (s00_axi_wstrb),
        .S_AXI_WVALID  (s00_axi_wvalid),
        .S_AXI_WREADY  (s00_axi_wready),
        .S_AXI_BRESP   (s00_axi_bresp),
        .S_AXI_BVALID  (s00_axi_bvalid),
        .S_AXI_BREADY  (s00_axi_bready),
        .S_AXI_ARADDR  (s00_axi_araddr),
        .S_AXI_ARPROT  (s00_axi_arprot),
        .S_AXI_ARVALID (s00_axi_arvalid),
        .S_AXI_ARREADY (s00_axi_arready),
        .S_AXI_RDATA   (s00_axi_rdata),
        .S_AXI_RRESP   (s00_axi_rresp),
        .S_AXI_RVALID  (s00_axi_rvalid),
        .S_AXI_RREADY  (s00_axi_rready)
    );

    // DDS Mixer（含4路振荡器 + PDM输出）
    dds_mixer mixer_inst (
        .clk         (s00_axi_aclk),
        .reset_n     (s00_axi_aresetn),
        .phase_inc_0 (w_phase_inc_0),
        .phase_inc_1 (w_phase_inc_1),
        .phase_inc_2 (w_phase_inc_2),
        .phase_inc_3 (w_phase_inc_3),
        .enable      (w_enable[0]),
        .wave_sel    (w_wave_sel[2:0]),
        .pdm_out     (audio_pdm_out)
    );

endmodule