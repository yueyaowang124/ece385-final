// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sun May  3 22:12:39 2026
// Host        : Usuallll running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/ece385/final/ece385-final/synthesizer/synthesizer.gen/sources_1/ip/continue_rom/continue_rom_sim_netlist.v
// Design      : continue_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s50csga324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "continue_rom,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module continue_rom
   (clka,
    ena,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [9:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [3:0]douta;

  wire [9:0]addra;
  wire clka;
  wire [3:0]douta;
  wire ena;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [3:0]NLW_U0_doutb_UNCONNECTED;
  wire [9:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [9:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "10" *) 
  (* C_ADDRB_WIDTH = "10" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "0" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     1.105199 mW" *) 
  (* C_FAMILY = "spartan7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "continue_rom.mem" *) 
  (* C_INIT_FILE_NAME = "continue_rom.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "1024" *) 
  (* C_READ_DEPTH_B = "1024" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "4" *) 
  (* C_READ_WIDTH_B = "4" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "1024" *) 
  (* C_WRITE_DEPTH_B = "1024" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "4" *) 
  (* C_WRITE_WIDTH_B = "4" *) 
  (* C_XDEVICEFAMILY = "spartan7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  continue_rom_blk_mem_gen_v8_4_5 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina({1'b0,1'b0,1'b0,1'b0}),
        .dinb({1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[3:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[9:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[9:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[3:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(1'b0),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
VHPlDkoDlWlBfBMvPBmGYmaek3s9hXXhjF28kllYPnaNm3TSnzzpXHWHc8Ye9/2L2yiQfJ1hTWou
Ia/zeQ8h9/dtr6QB5YkyW4wlb/LbMgXb+DGIXPSllNl0IMsRQIcQDbcQm1bO/nlhb+2pjxiuaQrl
DbvxoDwPs7z3LunRxsg=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
lmIhoX8hXuc7tNV1sXY1K2/gXL7Y7Hq73qQF7+x03UWWTRd3uhGmVQtOMVbhIW+66UkWUHiD26zL
fzqGor8bgSNGpSFyS11k4TwLQT4OfAMGO8C9Qmmh4+VENBnpS9TW+wHzCv8oUwht7xYtYRZvOvYK
F3fMppz2sBkUd1lciw98ZE/UmNkhqBuMfIYF43j45DEJ55PBhOZNg91Ls4v3qBHyBAaYPFFoMry3
d5Fw1PZyFQSEOSSpwgyds2aN0g6oIwl7zm0LJrM9VDAOxBUE50hk+oHr4jj8J8UhHQJnlEHm1Idm
rvxKygNKRvfSpa90NYxZJFYgqnrMYg+19+9aZA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
VkyCjO2onoeZWEoYQ/4ue7X5mkHyTYVW9xjdoTsGS4GdP/Q64VaCZL/jr6R8DVDXPMnH7tRMrDpo
jpYBnyzSgOkfgqM+96ioC2fDyAaG4gYgGLmrBR6qK3/mxXwAZZX+GJ9R/eWXkc9h8xN+gsSSX6/M
jIQCgeT6q7PB4dWT6KY=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Iub91V+TnhVlZCSLu6iKmFjix71y6/l83OPTs8uewWvkE7WcqYxEKi9fonXEkzAtWzuKwEUqnOlN
VBsNJqPUdKcd22q523mrdt89mpdosWD+hvZdO7ELhJniY5u9h49FFkubpN2JiUTcIcKEYxVNlds4
wyvaYUqbPVH5v2ooJwDdimS4GVn9HerCOgPwfshvQDNlMTxLcYju4v8BHMc5Rub9Q/ihvpQU74v2
ouZ9XIwA+C6pBLwvaqS8jE7HXOokgqJilaX/W/t+KEgiFry/txRTMU9WMD7tCN7lcfjCydmS3Lq+
3u6Hsr0S8BwNjcaDpZDnBTygUJd4JSqREnk33w==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
U46EWFmKmpZGaWfyL+dokyQtJtaOYsa7HCW/+fdtw9/yHKTWFpmqKBZngBj5rPkNhtTDDCJkqsYj
tUXg1j4tgIBaCQn9B0q/aG+B3gPLrudp9hLL25mVbsfiTzdekiV2hJMmhuMoavKKPJHC6zyW7kZi
80er82OQy8h+Df/fe6TRjH9xEt3/b80tRKUMbxkLfnnkAyyf1KfOhB6/uyI4mwXuQR+DsAbzybKR
YtXpOiW72tGrXTFlzcwbHamWZefqsilVpBw6V5dh33vYKGx50xwWpj76maAkpQrOpB7zufeldJe4
W1UOEN84AZdRTLkVSxamWo/wp8nP9fiGS/ItRw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
qczgIJYpE/SzErzK7eWJBGcDFEzDLm8cKbwJbPXuM6YnJxx44W+E60R3war7K2QGFAkOoCDUtDC7
SghJGF32btaDLzeKm0tQ669sBtQmMIaBrlt7I9QBkNM8zN9GL92qxNC9o3UVWMOYy5BmH8nUPgcE
O6lRubeltlrTuDe7UJQ2nEPHcXjpUJJ8dxktyW+LovBy1OxW8g4GRAsmEJsoOEg0HuDdWcc4IshJ
PvwPJ7LblELAKsdkSt65y9VaklaEm7MlH4ImlgIa74TgRmutLUbWxM1QYhGE5rAzFhGU5i3RJOdx
L3N7GGGvLMW2z9NSHbIFX+/eNII9fNJ9nZbgLA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Ti1NUgDv8YPk90APMwfu/mRr38QYwAxZfv0T6zQ89YS55t2EquEGVqrEafYX6rTydLOw8le1Oucv
f2oERpSSSTih/ScZneSZmuPE/Zh2BU1Ajv0j+/+0uEWXU+5lLPbDJjnapTmJXih1MYPf0SHpZZmE
BKj2IEBI9MPZlh6bxpa5BWJnyPdAvHf+UNaMXU9+pmbtrzUVebql4mFJu45Z3+ehmFY4FBW3zXMF
44C4TlHACLwL3vHVMCVfeKhgdVDbpE+/IFhTStz7mZ9h9RKGanQcs6YDVM1R+2RKA1QT1fX4FiQc
1V+FGmrm1ujxmFGXwpfNKByVlfCY0oWhRJCYYQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
HuEXFK0NXt09xU2yxxjng1OLsT+ZEM4EhqBgpr9D2ljw2vDaMBrqEsRQTc2B9soDq3ewDduHJXBd
OGYxkPnoN6LhjULtB2nTgjcH6NxA4puZ1ZNcndDndVBo8rTW5W1OqHq6InAG0CqPpTIkuqz3ECPl
EysI++MCDfH6tIzlekxJFIJ1McJsTq5rFuLzMMcrmkBxgcayDpOcCFuzZzCczxmt/cCCIKmDybwT
OQXmOcLJoYLP4sFu6R9c6xO8i6p++crv2N3eIxZHKbek9xBBZqQM9EYuEtsbkqAs9XZpa16i5njR
BDFxTKcP6r7JgFALJE89AZhBbate5JXWp0v4ECZD18aEL17CipwcWPutNMdG1apzSPP5y59n7rMG
yxBPz1gKHc3Emkl4WcO0hjICxqmO6dMXoY8JvBSf6ry2l0sH9Ihr3Bq5WWmlhPHnoaNr5jl//vNe
KfToWtn97eoVSt1LnmXXnSpdigbHr0UIg8AdkpdkuNRaWdVicDdgSo49

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
mokwst2bn6UxD6V9UdIgCIG1QQ/d0FiJqYGOTI2eHPV6YElaLjnJ8DnQmZnGS95o3x93FDOoa58C
RwYsX1fVoVtXkj1LuZq0k7q9vEe4T8xMjpkeYtIHY9k0Xhy1Lq/xRlfzGAf9fvf9e+f4r7aR/Sb/
uCZxxugG5niTwLENY1n3NthYL0jvo8Fmdw4Qg0nTCGWlVCws+09K0g9/lx6I9EcuHHemcHO3fOZG
lMc4NaPNozKwnyDMoWUkwiVxyFEPFaQLNYqzjvR+CqrWfhFLo96JWhL+eaDoNuZoBVYQtNH5ZwBL
BoO27Pw10lgcReGlZBz3BLO7T4ddynCx0+eSnw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PiP7AjOQqqouyQMoBQqgWIDhUSViq94rIvGiIJ/UKMDspM/yXw1caE8AhWHTjYckC4yLpPAz5P6s
1Z6flzDPrzVwg4e59X2cc4IMCHhedna0rDO804njcc6amRDTeLsMLTkWfvomB4xwszm2AgT+PRnB
WHd09ZUDVFjiBXT+Oa9AicgGJHrX3w823yBPuAa704kje/SzgtiDpcTU1eLmLhLW7LpEd9KIHd9s
ER7Uk9Orws0Kq9PMTqMX4hMn5K5mFakOeOURiEbUjdv5RiIJ2g/PlQXSItM8fHsBTQa6fOaJwQTI
vHwK3a8ZBHpfT1YH+n7wNiNUZwD4SFXm1QVx4g==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Ul5ZfTHJwMctaNhYRortUZizYMPYRef7uYqPSuMkxsArnxI/cjGh+KRMwzV86hyp/6TXSJIjm5ec
2wX2UONdPN+DOJ84jYC4JbgJQrPnTj7ioD8uLX/WlyPcQzyF5keqFgj5eR5s13FskVWCuAWf5m9w
mhFEKFjVXDAr7gVgAJh/hL8P6Psrnf+LGfiM8JhnDepsHEYykGlpD3fzru2BGgqHWqPqFMcnyVGl
vysaIXiJz/eYKvO8RGcgd3DJAM/wPm9A0m/DWcmSnczOgTjoqkHcBg2H5uJMLvufzmjImi6LYEqq
v04ESDEN31cSUzqUYcayvMFOnI/WNsWbFIa5+Q==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 18848)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
