// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sun May  3 22:13:20 2026
// Host        : Usuallll running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/ece385/final/ece385-final/synthesizer/synthesizer.gen/sources_1/ip/pause_rom/pause_rom_sim_netlist.v
// Design      : pause_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s50csga324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "pause_rom,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module pause_rom
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
  (* C_INIT_FILE = "pause_rom.mem" *) 
  (* C_INIT_FILE_NAME = "pause_rom.mif" *) 
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
  pause_rom_blk_mem_gen_v8_4_5 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 18816)
`pragma protect data_block
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
tUXbGUHc
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
