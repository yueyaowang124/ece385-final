// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sun May  3 17:54:39 2026
// Host        : Usuallll running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/ece385/final/ece385-final/synthesizer/synthesizer.gen/sources_1/ip/win_rom/win_rom_sim_netlist.v
// Design      : win_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s50csga324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "win_rom,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module win_rom
   (clka,
    ena,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [14:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [3:0]douta;

  wire [14:0]addra;
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
  wire [14:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [14:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "15" *) 
  (* C_ADDRB_WIDTH = "15" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "5" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     4.541179 mW" *) 
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
  (* C_INIT_FILE = "win_rom.mem" *) 
  (* C_INIT_FILE_NAME = "win_rom.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "16800" *) 
  (* C_READ_DEPTH_B = "16800" *) 
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
  (* C_WRITE_DEPTH_A = "16800" *) 
  (* C_WRITE_DEPTH_B = "16800" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "4" *) 
  (* C_WRITE_WIDTH_B = "4" *) 
  (* C_XDEVICEFAMILY = "spartan7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  win_rom_blk_mem_gen_v8_4_5 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[14:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[14:0]),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 62640)
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
