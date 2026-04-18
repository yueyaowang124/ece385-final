
`timescale 1 ns / 1 ps

	module dds_pdm_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface dds_pdm
		parameter integer C_dds_pdm_DATA_WIDTH	= 32,
		parameter integer C_dds_pdm_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface dds_pdm
		input wire  dds_pdm_aclk,
		input wire  dds_pdm_aresetn,
		input wire [C_dds_pdm_ADDR_WIDTH-1 : 0] dds_pdm_awaddr,
		input wire [2 : 0] dds_pdm_awprot,
		input wire  dds_pdm_awvalid,
		output wire  dds_pdm_awready,
		input wire [C_dds_pdm_DATA_WIDTH-1 : 0] dds_pdm_wdata,
		input wire [(C_dds_pdm_DATA_WIDTH/8)-1 : 0] dds_pdm_wstrb,
		input wire  dds_pdm_wvalid,
		output wire  dds_pdm_wready,
		output wire [1 : 0] dds_pdm_bresp,
		output wire  dds_pdm_bvalid,
		input wire  dds_pdm_bready,
		input wire [C_dds_pdm_ADDR_WIDTH-1 : 0] dds_pdm_araddr,
		input wire [2 : 0] dds_pdm_arprot,
		input wire  dds_pdm_arvalid,
		output wire  dds_pdm_arready,
		output wire [C_dds_pdm_DATA_WIDTH-1 : 0] dds_pdm_rdata,
		output wire [1 : 0] dds_pdm_rresp,
		output wire  dds_pdm_rvalid,
		input wire  dds_pdm_rready,
		output wire audio_pdm_out
	);
// Instantiation of Axi Bus Interface dds_pdm
	dds_pdm_v1_0_dds_pdm # ( 
		.C_S_AXI_DATA_WIDTH(C_dds_pdm_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_dds_pdm_ADDR_WIDTH)
	) dds_pdm_v1_0_dds_pdm_inst (
		.S_AXI_ACLK(dds_pdm_aclk),
		.S_AXI_ARESETN(dds_pdm_aresetn),
		.S_AXI_AWADDR(dds_pdm_awaddr),
		.S_AXI_AWPROT(dds_pdm_awprot),
		.S_AXI_AWVALID(dds_pdm_awvalid),
		.S_AXI_AWREADY(dds_pdm_awready),
		.S_AXI_WDATA(dds_pdm_wdata),
		.S_AXI_WSTRB(dds_pdm_wstrb),
		.S_AXI_WVALID(dds_pdm_wvalid),
		.S_AXI_WREADY(dds_pdm_wready),
		.S_AXI_BRESP(dds_pdm_bresp),
		.S_AXI_BVALID(dds_pdm_bvalid),
		.S_AXI_BREADY(dds_pdm_bready),
		.S_AXI_ARADDR(dds_pdm_araddr),
		.S_AXI_ARPROT(dds_pdm_arprot),
		.S_AXI_ARVALID(dds_pdm_arvalid),
		.S_AXI_ARREADY(dds_pdm_arready),
		.S_AXI_RDATA(dds_pdm_rdata),
		.S_AXI_RRESP(dds_pdm_rresp),
		.S_AXI_RVALID(dds_pdm_rvalid),
		.S_AXI_RREADY(dds_pdm_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
