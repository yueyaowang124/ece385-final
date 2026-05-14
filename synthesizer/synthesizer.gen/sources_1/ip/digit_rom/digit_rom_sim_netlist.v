// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sun May  3 17:51:05 2026
// Host        : Usuallll running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/ece385/final/ece385-final/synthesizer/synthesizer.gen/sources_1/ip/digit_rom/digit_rom_sim_netlist.v
// Design      : digit_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s50csga324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "digit_rom,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module digit_rom
   (clka,
    ena,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [12:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [3:0]douta;

  wire [12:0]addra;
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
  wire [12:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [12:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "13" *) 
  (* C_ADDRB_WIDTH = "13" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.300549 mW" *) 
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
  (* C_INIT_FILE = "digit_rom.mem" *) 
  (* C_INIT_FILE_NAME = "digit_rom.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "5760" *) 
  (* C_READ_DEPTH_B = "5760" *) 
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
  (* C_WRITE_DEPTH_A = "5760" *) 
  (* C_WRITE_DEPTH_B = "5760" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "4" *) 
  (* C_WRITE_WIDTH_B = "4" *) 
  (* C_XDEVICEFAMILY = "spartan7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  digit_rom_blk_mem_gen_v8_4_5 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[12:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[12:0]),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 25440)
`pragma protect data_block
KGxHbd/O5RbHIQ+VXN961u9d/E2gU2ua8pLEwS46E9ejKI7Tdo7eYHsv9KaxVHQRTLZrctt6jOfe
U4tDM2COBDAvbRMkxGdhDuvT9wmueRFebstydBV7yTq5fVEIqCHom/Wfd5NCxlwXULiniMgs4teU
RcOAZiUFnhRAoa12GqzMesA3HL1xTRrIUAzOTQvz8NGo8K/nVDaSdb0VRoiKoAG4Al9FsR1jLrjT
UINIGAI2dykBN7kax4V/Hd7DklUrtIxbiLLgmBPOIq54OaMDlxJMlP/pa40cqVdM/D1XNX0uee7b
AcMcY38FjF13rx7sAWRDhoj816BlCnhksv2vPceiTxsonTP6+nH3vFq/6WtrjNgTIe5D+ypZPIlP
Say/ThRlqUzdrTtnVZ20aNtZf9JVOPatPxiKTapOvhtwmNZ/ShIdYYVlcT487ymZrEczaw0NtbGQ
fu72CKQck+opy8tpNbGLLuIlETDKeDhn8J5TVLT02/W6SswtxvTfmI4XkmdUWvgFjIRSbhh8Twta
Osa3XYEKrjrEzMe+luNlNCGRJDhzuHH8gcrqUL9KYmPW4+iWNMi+BsujxFqZs+qDsaBzFc7paLSd
0q38VFvk6CDw0G4JWG+gVjwN9D22W9mJF4Rvk/mKfxY4liLfxZxJ32nKOIlbs9eIwJWmlViE3JRI
IS0QQbtXebjVwf4BQS28GEPs1/yU3meVBsRrJlDFRwGw62K0ggwJHq1gpw/2Q8dt0NaNwNQtQ69G
lh/GNzVu/DPT7/IQNtTQ4g8fJYtreb0EMDIXMQRMSEKbuZNiOMiWbUGx5fGPOU48bJdF77vU8pP+
aajd86gP/WZdDh76PD5yUU1tvoFnDx0DJcNHDjQ4mV+MyMbnsL7ShryLpzZi9+GaHPJEO5njhQZZ
ckp3JR/W/tR3qdLpjDL7BsTO8mbtwsIn4ICAxq5YzkNpngHYuk70IE6cl947JS+8l+ekugSzGx/X
Yyv8t8OMsslx16lZAIjBbLE2GoCNUDJ5V2b7mu21vVd46mr02JYPnsLdfWLXOSppnSjP/SEzX2j0
W1JlutJ4/TIlD/d89ZZPnSzPdphdpf8vCoQhIlK6EZvEYtbdcKqRs2nj+0Np/3Nh6FKnb905M6yV
BV9dgrXR40ilRoEQqq33zQLAuWqYU34+WCJqtYkuNUb5+fUarEkUbDQyz8AVWxU5ihucAox+GA+C
/cgPFI9IQLZnSihzZwBE4dUIZXn3z9at223fx95sarVf96NPa64ocX8/XSZFUQCBqjpzBqOCYQxI
GXwPzPWfm1G3lQJVgyqVjju4E36tyiAw8k4x+oo8+6M65pmC8HtLwu1Sia9MHLJPneiKBERptDw3
fNIkt9j3aeYs0OLr6uZZ8x3Xv3Cd63blPyRIH/v16op2q5DcL0QG+gVvo3uwzQ6OcvUpW/qvKIqV
SeN8Dz6Y18cPci/6ZlV+ob0pYDOkgIHQsL3XloBRyeXGYfxqq1+vuYw+/sdDg2uzq0KnoZJGPe9D
TQ4rlFYJyouPEeqNZcEcaihyVdQHoe7m7QFqih8a0ispuPjC7UO34AcPxKYx7ekKQUXrgJYDnE8J
edcppmbaVK0V1jkONyWGA2nMBvtA8k7SwHb+0MwgsbNOKycVMLrU3VgtSvRlJ9BP71kDsIE+cMSf
sUVwpT6Wqh+4UAcMRYKKlGDwO6ojACd/gVPk9WnahUiovEOXj7+nK7pZxUDWMFIF/yul+n7htpNy
xoX0j+q4JERatvyB8bS/JVbQI/V06nGS03vTdFRZiKKBAD3pkg0qZjpKDqLGIfchrGHGGIIY/2/O
bmsP25/mK8/XYoh9Ig0sQuo0+KwoqC3uw1Jb5SfoiRBaaAFsQqP81hJzuMYKKlPsJZmKNvwV++yn
klA63aC/ZuLTyOz9QzcELyU6fFIh5fzL1HU5Ol9ANfGlFlY32UXIbb1Bn03b/YCCm03Acx1BNIHG
93EgoCeZzHwuOxzJW5LSHoasMJUbtE1gZRAQik6Epyy6ezc11yOqYWndZv07V90mS+o9KqB7MDic
fJyc5GKieOaaJEPGeXK3r8kNiNoZecI36heVkU/bxZFtDgTOd4usW0f1NEmnyX3GuSlT4ZKS4Hgj
R143e16mlJ4si6zGHiZmvebMJyzd8kNNhKJizjCS2OKFXvb7OlUAJYbHvPmKw6y+GoStggq6t3EF
g+6bxD+dfsZHmbtG4xvGkTu3+L2cETzPDzjNboCb93mNqav1OUZsL+FZMcBB9/0UJ6xd+Q5NzkzG
DizQiM+X349GnwOpq4mnsbGWulcVi4pCaDbWw5M4193FecNqII3MVDLlsCR+pmxoULK5c9jtmKjj
+8rgoyAap2wGe4bKEYITHh5ijwnJbRdB+GKBCtEQhbyvtWM2X7k9yg2htJKuGdgSRiQhy944Vwi/
0ExY2ALHD++dL9prsiS0iUyTg9m7opXnYpZlDBQ/PRLqVmjRidayhALu+l0O0Aq6BbDHejNSoXHB
ybp90e5NvNSwyHwYG+SqumMbbzJE2NTBqim7v2aR5BE4XTa8zS+x9TCQ8pS2u2CrpY2xgP7rBpcu
8/VHVoWglrxOPNYeaIuTz4+3niffdacGDWee10vJHa/xMsONzJW2vkBRr7tiSUU0J6sCsm4zXp84
b/Yr72Kt3NV0nOqs6A1n5WSxGFi5ViI9UGy3N7kgFEdF/P3XAe/nO8Wvf7QRcwUxlQcwDECFbe23
GkIOndZwqdJZpygm41ggVWAxlRMjU7qz2dM1SbI7fIanBkhGjAxEf12/59N1csZMds05+3oYbi02
K5PVIyS7dKfR9hP3IETIahhw7OWuV+VGyocsf1J/TsGUzhbg5nin/nK4RM12hN1OmItkMzMdRpUP
/JM220flT4JZpjFvJnXvy5m3BhyXOXHnnVg+6fgxZnVZUVbddH4hmb1gGCiKtS0cGVfNU7vTIas3
OdxpiouffYQUmF+oPnajoKnrfLionTrpr0vM0Saa9QPkise8vOj8Nr5m4Ycszo+aZ/i9vxzp5PQa
EgqhcIecv7GAE7+zdAzmww3yPMtN73eERuvOH8H83IZPOeAKOxJBd53GQSk+gJoq+ERF8EwGwb1m
t3HbhDfvDftUE+6uFFGpQQaMt3AVkzegpm1UrFUcJYt0MIRBG+TZXeKu/Kt2a2happ3kcNIRxAAb
bA7PCZYsN9kgYrjsJgJ/IJ8LKL2E5chyulSAyaS0KShma9emMeZWKSCxHu1+GrJ8uQab48vHL5OT
cmfDBtVXorLN8WZqld8OidrkpNxtBTaACz70rnlVoAaju0UysIBZzAiyuvYuyJVOyerr2pzQ9ihX
3K/3mhCVGk6oOuesCfgLjGK07DOpU0HGsmZJdSDA4L1uH2jMSpeE4I9yv3u+95bGqoogvibPqEXi
d6ChDWaggtjTAKlkfH7kZTQSPpicO+4xKmw2zA3EQAPRSZowFuy2ITY6Ln5CAQlSeD2ADNrAbQUW
CrkQ6QpiKi/fFqarFrIjo9+YK3KYTYZKAJGKlljcjncAInwf/afFKNblHIdl1gGRhvaz0yd+EWqh
iHXefKATEbcigizzxGdGmKviIrgDSOpEfASiWWFrqZepqZxkOOQOpDDvyXpjggN6diSQTJ4++bn6
9reuqzkpf1SobQ/ViSjV7T6QuhtcijWdSc079cs8gieLecVhHYj26ydpkV54PeC0YH1jfol/2Do+
WDsUZuuatUsSVIgewQWERDBKibFdcNDFSKRPuZj2oXJlfot3QXCgD3ZixtdHjgp1fgCs3/Ogw0Qs
o82SBFwOC8y+p5u19GTOvpgM6GNnClhF3ueN6q3GEz1P0L3kttmjbM1JcL5s3SKSyuVrjq4AX22Y
XJd9deT5/fguHIjgd06mGwFx9BDFtpdrhoolcK31GovNJvIGxt7qpDg91xcAkG/t9rEuavqKVYVb
AIxomJ8+DwR2rrgeE2q5iPYkcjqKtdpBjSSxmcxUFjMYsQuhqzv1wcZAm0ot707VzQtyuEmf5ayz
XEXehpuBtXJ5qjJsy4HdG2yUg49oMO2FLf3tjM8Y3kljE25grsAFQGS7Hehcsu3GAdtzIkO25J3j
Y/3UVmpewwx4FmmbcUHcx4kJsCTk1s9Sxub7vt7wZSehRMset7Z/peGIIFyWZdvBCS9AKoQnoxSK
EE3PQCpWjERIge+Jn73ztpbn5iP9Gr9tX/q9A0lK1sF6kfTs+AxihPPYpS5d+ZwB0g4aV2T/X9n9
5kzTx1QUeSVUnSzZ1zHLDl06on80SskudV7LT07w0/6jsFw5Tzv9+OeHsOrV65urxK+q3NVPLMu5
ZuLa9CyITUVBPZXrdEDAw7/jdsp74GtKHm1iVk0d7AuAU6+2FYvyd48z8kBUh2+i4aTXlUZEmGHx
3crx2XSCOp101BkVP1bl6YRZXoLCCfzpS3oId51WTtn6GubmSBoVSPG5M7YsBRxIroFx0vZpsWk/
W12DjD7MZXg993KKD7qOlbpf/rGDF1EuWLZf35n4F4kaZxn14UWg3rpCYG7TB5xgPgWd0vyNa8w9
ulJftcw/gAPERgcFDEfOhS8jqP9zjdFez1G8i+hW+5a9ydIganViF0iKsL22zwPZ27KFVFQhXcBv
ofE5hhnySz/9FO2iQxr1EFv8/3/a36+kxxJedNcQSawijbWx2DJqikOUCgvXyphVj8oh2IHGN+Go
meiIKQIzdEur6elcYdNL+MPQzkx7doiRThjsAzZeHspLEsNs6YFFBN50qYMLnLDxW/WwM3Pc4VTG
IEC0TAsbzzgmn0pIWGXKNTio7hW3rvP9+ahGKLM8ewK1R8MYqkF9gdfwEPldiBoptYOXT9DsH2mR
dLGF8Y11Pzq3BXBwM7RYa+6SLGtUUwtAcrri9t0FWrbEv5n4/CczD9h/6EvnC6wlDRU6CeSpJFkg
ZdsrNAPxfZqVn5HHvNGASsYvrlXwTDEeaEtD8BX3XOQUTtIvY/YyUJfzwfLm+FRqNsRysYlRp6vQ
qvpIf373xxDCDuwxNvhEhstisIQpaMxxi3J//kr6RN4o1z5dG+TyehVG9ji5mqzguRJWLenwthf4
S7F9GGNxGnuoaYIzGhx4mliyttroFSRiPy0tR1iuybeIqiuxfCDkE4kzTCwzVVnnIAVhEVechAVd
NmhUFRClc0cOYshqWUEXXD4lgqbnfMOantYBz7mx9NHiW7jrueqV4/cDDB+iH8AWIulApmdKsHei
fJ74mJqTYkaEc9PIGrCEXPBF9R/YdL3kFXllHIZT/PLXaLxn/82cmWETdVszCeErH5WbipN3l3UU
zDvcg7M70FJ6rKBgc0QUS5a2s1ovVRXbgdTmwyljRYQU5T3rMZSH6ActlyY9DGxhZZ5hcpkJDf/K
lZTNLHdrC/vah5ti8OcNSub+P0OPPQBbJuJJmgRaHhGvbQqdycqHMsAUX9VVO4yzfJKqDeCRrqj9
AtbWE6g3NJUqnvQX8MSAJI6NVIxNONXVXMKSIUyKXiRAtLD4Rfzoq125HiO0zHugTB48rK+JTh92
CNXLaSdXTkFMVSfOi/zuSp3/CTk4cSJlNI72wynOEw9ZWYSMeRRyRaBk6CH9uPnT+mIIQbcFTjHz
ahNqvq6p7U41ZoMiE2AAuMT9yuvQuzetgVEQlX0zLF2FGQrDjjUAHD5jwS8AnAjXrRJD26aeNRWS
T7wFv2p5NXq0AcyeaIJSEYlQeMwicPuPnwUaqBG9TfGDFlsSKyMDO6QLxBSqA6aGYnMxsYsMAJpC
4HOpbSn+VS3lkUoqsbZ/aTpMRXXFHxfoR9NBktrz+QjijHBfphM2Hs0tcFQADjPHAMsBDeq/hU6L
3zKu026fxrSfVrmuHZ0EiFPF5bs7BH/Lu+3iyTYztv1CuVnZg36UIQcmlLVFqPXn46I+aLDyWqeL
TDxsxFXbO5r8htAImLWA9snle0rFMqh2lpQPN/X/LIIT5fsiUtR1pcyYIl82Etry4gJbIXKwTnfL
+fZSheNhq3K5rD7QvKx+SmxygX6VIpnFkTFoL72WvraEc6rBzSG82WEA2A836bd2r4VXwPSbpeek
iiz2MdCbGMsU/ZsFyciBdwLlpB5ZEda6GH7o39Ao89A5ZC400Dg4+OGUJbYxi0Ytt7IvvmXoZmp/
a93UTDnFmYdeFEQSoU2d/GKNd9XTmD/wwGb3EquOcnE0ZZp8+3sSHrYErL/XuQCGySEawwef4zzs
1YM7IJvzILwGrpsb1et2oo5vURIS32MsEY4VVgDIqIP0tJg6oqiZKm4M/CGLgNB8Tgt0Zy3iX9x9
wDWGqVNNjtpikZMaoyYdjcMO3MIXOdxyczQpMQ7bg/jLjRGnrtJPZZ10bOrzGOj//POldp5U9PJu
fJWxnEAKfSetr9GeZB43kUjUOWlJF9j9+251wq/XvBV6FCdwzQw7+gxAWyeVhUCZ4ifphwxrCbIm
SeWhiPSKUX6Wgu/pnFZ2sSf6E96hkPE6I7HeyShBz8GEsoanVsNtdEeQVM5gHoZB+R8/B/wSzLcQ
TMt88pT+XZazXzQhjX5kioVa0h6Za0w9uMVba6A1PAYa95vqaMZabfGXYuxDJIJtcc7yqjmVEZFZ
SKJee/ZzRC23EUC5/8PVOSTsrqLYrcAOfSZXAB+rM6/NgSmo+WCny6a0aoBqnco+u0MZJd9eeFMo
mSri4l3+oVij/CIqWrj7r0apRZU8JspFPYZ+kZLvga5cl/uO+thX2IilGyiO7JyTbtqBTeLMo/Bt
/P4FTIcSUoz7vyaOmHoPfeuTiez9U5O6xz/IcrIC+NnVkV8RuNLvGbc9f5iBdOmsGmMrSnZEJ1Is
SvhygBu31YtnNCj7xS8g1U9L93pvlEqeS0Gi6LfaWcg3vCmp4nTgpMzFrWX3NuVUuB3OYcxQPc0U
0EJBpxRfaIhifmgjsSdh9klu3Hvnf88c24ozkjqS7OhQGmsjjI/4nlT3jQdQin1UwzLIH9F7dSjM
roceb+auBOKUf3rRH1eqH2LPHXzmwH8qfonflpa3NaJgN+JQeR4lZeeEb/3KBVj27mMopyDOceyy
LUYF+20U0P79jXFeRB0VACvz5jT2KknM6Ux6rmHLf8tzKNVuIZKhZvzvP1qfP0n3PphCtrRDTepO
FlHf6o7+Hn9gws3RlTxlao/NzrZ8RWdj8hXKBSJIg8XinFrfUyj8lcvKUTmrcZgBeWEdM5objIaC
6HjJpPfM/0d+iMSueBh90hhPgBrpfB6mujff1prMmJw/VV1pfdYRrIiz2B+uY3CE3yNyYNocROaG
gzStIfEKZndDC+UyZu8a78GYCto0Svcx0w+SzwkuQsBjGLoBXXDVwHF7WZEcNbv1y1Y2BBD3tE6O
mYiPAPdOW8nBkm7NfxDLtKipLq+MRS88qpBtIBAkFaygqSg5oqPIZnVe1YuViUiySqNHoGAmNRyy
9A33yWJEED/aQU1uhYofzl5MO191D+JFgQv1X8Z9wodTagdJWTxQyIgFcoYRgTkKQHLLTWj0riR5
cSWptD/bxNgwxHehIlSsazhLfL2WccOEQ7STfXEXLXCUwV2y6vHik35Pblt9ANeC8rDLK/Jv1X/q
/ILjlsFnp/azXdHmqmMeSmfEhIKYH3vYtTpKRYzDWgaDsg0U4y+Kn08aDyor/11d3IhD7sibpJji
bEWU+Mn8NeDHuBt+XYM+zSV6sLoMNc+CmQQ7EKXZtE3PBZXnik78PkV0pG0A6jtvhFm8ZYZdAtJV
Nty47Qa5rlN1XGwDaGhegLgUlk/zAxt2SyJiUIJmSuTE2Qki0BC+/1lUMjKNiaxoKXdIZKC3tdEu
P2E0n3XBIMsjATMrH7bI/X2MC1kqTuKK3xzE1g1kQXMRzXe5e3TDJyUrxd2eM4vTyT/YaZGX+2ON
YkGhswxlEo2w5vaLw7vjGUU2JhKKjv3s0Z6kf5bNoNtnZ3KeXWCG9GQ9iU+YH5EbCtlqmJaVX+DT
zg7krIM0ScYUDhrWDZSoYj6TYQEKOJWBimO3VdtZ2/ISZuvtLSY+U48PpWw4bDyb9p1ChvRI2msg
9KmwA5ZV0TEvu7BUxi1xiyaonB7kNka2u76E0Tc9duaPAZ7ttRUTpPzodDF++p7NEeTRb1oVTqXL
/GmA94GVL1ygSTqKUOVzd1l47fAqPXOUWN5XwypsKdFeG/odrLBy8JyU+1e+3oxmDb3j/EhzJ0RS
QHGAXVo4qPXA0sUQjSbnN/87wiOokNl9vYc8n1lUUPmYVEzbsJ89f3g4Gf7aCVZJagfKKp1mrv5x
ECkRGsYAeqV2O+viuoXZQJQyAC/4Cu/GQ+X0cKZQuZVe6jcvKQ7gO9uTfxbYF7jqS7thzkyVE1WY
f+wMRxA53ZDEHlvw5QL7xZPj11qAMAU4kLkokHfzocZr0C/qyS0fW8eiJAamfqSX4ZxLsS7QjT50
CaitWcQ4i43V7Sh2O/rkWXrxYIIuPKJp+u23BhRRMqEFkeLXd1FYO0RIikVeSj4RgyX5clX9IYiJ
E52wm+/DsjG+8KSXqh6tpZwXIbRH7aOhLkqPQGO5XoATdGwzFUrritRwf9/fL6ZOkQv3B0stn3m9
awfvNyzLBSmGEDsQaFX3yraA8AM7x2fH6fHhFLDUPXHsuwqAllv+r1BdmrHHYoJn+CpIrcheQuGa
Xjz7AfCgtjXMU/DOEBlfE3hMd7rmDzdzAfNXvT2FJAu8Xvv9N2KK5VMUiCPepi93JsQPT3iU8Bol
YxcZHublLqFX4hZ6bvhHKCQ/nB66nSJS6bSkf0yOt/vbmsvR7IJAuFmgopNtCMZOh3U7qNa22IX2
Os/E17S7HFG9bKI2cMvytiaKjcgjwBEfChNigkPnRhpVxsfMDRrfE03LAnLAgdL557QYXfwdjKpD
E28aM6+A88RlxfTERxTIPUu2vXoLqv3jvkdkgO7zxYSeEeaEhUEJt0WmmLG9KUUDlyHc1TDAPnlV
z+DIWumEDu7bE3kwVClI4F2uPSdWbx7VQr9SqNlmnzI6VhAlSKVww44W9jaRm2bQo3WAaG3R5Np0
pFSA4a73FRlgUMHmLNn7OFOgW7mcGEBuDTNdENkeVTS0GxSG1nnWhbe76I3Duj90DKmy+JUI81Ex
YhEuhOeJRFKVQMYSl/VVdPndBSZTWHiQOQWEKHP2+jBCrB/wbRlGsmtgyvdlylCrh0zGLYsBZE09
jPpoL0SiPT95W97W3XzXdC2pawLT3R3ue7pP24LbKEUgLfZqRMclseXnBPfRqt9c5fH5wph22r7M
wWDsxwajKV6zAwb0fFF+U79ZBruh/7pdSzAnudPX+nzo7FtlxLpzqJ9kRoTgSn8WyE3pnllQE4n7
oT5wPYrqAP4JsQznpV2ntEq+gQVZvrQpq9rOvkjDEocjawsCVk8w1QcjXTc4/kY8p8QNwKQ+4bZm
DXPED9rV6ONRSU/v+wW6XBHjEtZEJ5kje2Gryn2J/SmvrQYXvd8ElMCy7bgB3lcrBdtVPC9MKpXi
QSjExkI8ssVYiRgxsOU7JQN3E28fX/6CSQITXKZPa6vJuCkJOgp/mpuumPyLDxDnLVOi3zVprBOK
LCky3ms24iJBc5iSAc4ylrkXJgZt/h8xUJufWbdpWsaQsQu0T/8Y4TuDZbic2VnKulUgrrcTIBE6
6xqHPHvJ8Zv5FCSeBEAdyd0M2RYu0zxxwO8W6cg1pAMINVx9AlswIHj3WEdLNCPBrOxoc55qdfjD
gtji2samkdC+Jqpw3//w/99lLnMbVlnoktd0hs2/eq+21QDtqXpnRgpPkTOtXJhnvEvNbh0L2udJ
PAx0rirsKkzLBirITdjkOSd/BbQJKnFwpjc3wX5tlny6B0f+qBgS9iMxcHRUxvX9zchkpUk2XLpo
s5lxyWT5EHvycBuvVZpm2vtTU5rIwcPxsXvu/BsOzauReEDkTgE6FRqojNg/aC7zgt3gEJzx2R9Y
jjVbtRexJniVGn0a5kAlxH0gyGqob/zCopdSY4CbwDUir6waCpFbz2VbxfCzszIyexAfdve7WtrR
DJr1mqwAIXd9bgT0skS8ITELusHflwzWu5mZOcveJnSas7mF+IS+rPIwprUKHmVWAtnV2Q2qIME8
+0s80GBXTVkDVMYHTOBlxb5OtAUMI5EgiVNtMDLslcLTuQI3XYFhakdUtr0/W+NZcmTkB3u4Tq/v
jOIYAHkzeVHqkGIyW3arFmfqODpbj3KIfXPnw8ZFFygCY7HLYOn4lduVq4SXElLyJafU9hH4R5bW
iPF9QA85LlnMFhVm4C3cxkN+xegcV1WZyOON4pqd/b8fpS4JBRJz5Elz+AuIQ+JCy1l6uTIpSGWH
z9E1Ne8J5+72CZyZjlkcdeSqfCidLqQSeNsIhOQGk2Xd4aDjy3kZARUxMc0+QNKLxl4NH/VUIqp5
grBD7HzAfXDG1QPHlniVaEbaNlRjyCdcQpU0w/AclvlFaDEW7MJNxELvVa1we1uVfptI/Gp8zlpd
ARVNQ0QU1GweQDWQ1MHSs3Qfu2VJj5R4z6Q+OpUcxU4HSh3KnHmS8EFTItzJAL1royAe7oIkMTHl
Ex0lmTQB4F1nJHkUppJ+Kyl+puhvHf4e3W3m2tUY/3jZLFU3MON3DPGr3jOgSrPaSEiEJwbyQoHi
shMTREjAh3HyRCq19AFLUNK1xI1cbrnWOgdnX/E3mq9+RM9nh5cwGOKrozgeYvzwcWMJurLWQccU
DMzafRupfmquuY55P0u7SK25omqrwL7uKoW/n+pQ27n1GYxWn9V66/RABlOh0ZZJP9AwNGax3t+1
bFcCPctC3gu2rXnlQKmXy0Way3EMaFHuMKG3Cui3PAr2kKz2v8hKonCFfvH8cOPKoZ5UwvNw/zbA
PohlKlyaIDJTATaby8ABFTziRr3uLWeq9bDgw0QBHn7Y1U1/aqEHSVD+kTtOASjdOReTHY1QYrCK
b0MFt7CqbI0q+66ER/8w+z76NuHkzNZfdXPvjlLAACOWG4IQb1KSfxq3464kuXfp9EDtUfttERfG
mcKZMJmEcnt6gt09cKZZRBiA94OXzz+UE8YbeTxs+7PJMbhrFeOkrRlVFIp8GptoYrYJi7ELtKj2
IbK52Nl6Uqp9JttVY9c5IDUT/TIAKLTj0Jftn019Twug6DaxHIRJ3iSZ7A2O4NSehT8Q5L4zffn1
+H4vQZlxuso/DLlSr9wxEP2DLnpxJyLooRn8/dwG2jHdadg6onGIM8VjHzdqiyOZ79/1terF+IFk
LhEw+tyxmAHS9PCeogtB8VwoF+a9z+EsCv5nbivA4dfuiEIjFyK22ztiBaeUH5TLMwzsCiGVzlGs
TS1/TlmMSXquuT8VHlCzAfvL4rPNWrtKpAy3kDtjcb9WZ+YqhT4p8JlVWBuiqL/VwCjYSHZoLI0o
zFGo+Etl2sM5vj0BGqgcBl3QabsckJHfo8CTYt7x9GTcI1i3hkdwRFs3j9nSNa9hdTD27qgC5iVa
FRqVbyif8zO+TY19QoIIFaEGNAoSPT/dzSPaRl1b6PibNABAbTMfKi4xIivNtxEkor8QH8wqxm5Z
9AensLrRZpU0zqTu1cHoUWzoPCvqeeLmh7HpmRdSveSEhSwZsRPQViubfpU9LoWUMT7fvmInYW5s
lTjxpYPLW8F9U3gnnpM5hHa1FeWTm6b8wi0JuQ/zAGDkt3d9PV0oxdSa+oOWZz6QLsi6EsK6Vyc+
qBChThNcrwRW6zNHScyitQUxFH3/3TQqG0zbPofEPCVQvJ37Z7cyzTWnkHk32SYeRlaR/cMmK6ul
pata5d9PudtC/yzIODSA1wIsS8GdPkPlECmFOLDp6ezxiOIHb+uOBNUlHPcGpIqzqc0c8F1Vdenr
TfckWvU+apzR06Ja4eUsKEoouqKKCKlS3qTPgY2k99N4/zhl+WUfDUz05eQr0dJiKS2k3z5JaOtq
q9355dZLxNBL8JeJAKoswqTnQLhYF44c85reUicW5WhRivxq6+MUDYAMjUcB0liEC/ffgURzjVDW
6/Pp0WSpszv2D1oA05EOSGAeodnoo6v6srtxwolQsLgtuA5A5JaRF76dvBZ4NDNtNIv/wsoAo4Up
Q7lRg276z8pmwV85zCWvQpbmjNY0ObVHVgR+YT+YplFaq5/cjkVkgiV+5JYOrqefqxVAb1QmXl4C
+C1NXqHzohDb1+4c4/ETcolVucOR7usevp59PPQjDS+bTgozNU9YXwiR1pac2EuguG94cpsLwzvv
Aj798FFF/grG1EvVjksisbN1/zUVfTf0fJaVHMrKLwaSwnhD5rJQnMIKG/hfY4JnGYemV0GDP72S
aSmGp7tKRbzYbbz/lVcF1XlphtF9VPZka/6D/1Y6Qzl3UUSlxID1mo/kmMV0Xr1SSDAKKY2/Vdt+
OJx8x5swe11FOaAP7w39zO77ij3t4ECIcHmiVtgkGEBbVH6SXh9pWIr3SRye2wAhiFsdPMgIdjju
DIDntUpjMSMNQG4TSdi0uavnqkqEVuGH9qkeTUjD5tA6RCDdaZs3ooQV5FbNWcukEnF67c35t9W8
QcVBCx7IykShcEFmq4GJRaplLCOR73pT3FBsucJCycQUNVi75cKTdfHrFT1jhGPsoh797LBtJqnp
Mbpc8lFbw9417Z6/JM/3/6U8xe5NkVImjzIz0CtIvVaNeigxfNJq3uZ7zdCOnJ1IKLBaSKC8/AFh
dLK+uA4mGWOqdNsK5/C4MjTwLzoCjWev8gyp7BeFkCrafWy1adzjjcB+JQu0jMwTfz2R8aHvcYff
kFvmpf8ynpKtTf+ajUE7acguztrpyW7DeMkEJob9bLsK77n34gUBALgpM1qWIT1R+bEIdWSrAnLP
u4npeePguccUQMFy4fTkGXxnNyB81/s77hvxWwQ6M574O8olcgHor8PX2z5WeyzPFV7Op0944YsX
ZjaYprRYqsX4Nhkx0XU6L0mJbBZX38D/T3I0cdqR5KI5FE4rcPA7eq+F0Bl9RhgA7ubQfLhF7/fn
kzYrZme3zEpLf64GJ9aPC1fc5aflLd/rOhODnlYwusPaA0HiteecMH/r/+g4BYMnjwpk+ygmUPbx
1kDh7TxkkCcA+e7JR9VMOjcVLVf3wc7BbA+m1XZLFioVJyTR9a0ZBy5Bj9MgcCwg3GjnXtZ4UC6R
YrIVQTxD1ZLXbBFg5kiHzn1qljpL3lapet1C16r7RYLagRp7+rS/dkQhx6QsXhCkPK3ihDcVd6Pm
kk90OxzsavnPbhv/LLzmZPi+6pRtm1RmRNDGVOzsAuYNN/Y6r3wdqC5iNCH2uZ/MTQW6gdGJ5uk7
ZjBDt5WjAaEIyoSXLNoWPTtww3PgXor5h3A4L7OtVDHz0LxVxUuEa7cGb+ru6R18weJmp6VpMssk
cvYy3r5RcdO85k7oXfwgH9ejTG59TR56UQI9ePSkiB/vG6pQfLXCeuiVnDqBfpOlyGlUqUyVeDOf
CTsZQQKDOJHrJQkcXALMhAPDL91zv4Hs3MOizaa5bFPto+P99uq6L6u+j244Cj9Na9/sk9+avjx0
9BcSaFLzkgOFHF8krzk4MmvCSDu+OQ0lq+Ux4JIvG7XIbFxumkY9bynihRBIbp3enElM6mJs9+oh
WdhKUFtpzuUzcCJyiuLPHt3Irji3BzF7HV6rU6gZgdg16hmyHShd5StxC13u0CfevoEID1SsDxtE
dS4oQcqbL7WYomkHHPvtxNIJF3mxbwKh5vOsNzaDUlvtKYKwpf+cNWtWpEbH9clUfdf8pcm1jeiG
5Ss2KbNd+UuD1LbRhTK4YFfZ67clU0lD+c7mbXAvbfkT4VgLM+KfA3GGS2EkDW4zy97YLAbrau13
a8nWHPKoh62uPvtlNZHJN+YVsZJy2NgVntuVXh3hzIp0/69kqstOEzbdojhKKrUO3k4y3DpluPpX
3XwWuo/H/Y0JuoqWva+GJBvfLZ+/ZkIS8RVFZ55xeZwE4oMJ1iNrpgDVVOVYsKZKuvYqo+h35v+K
zWvWnQn5nXfI+/pQas+tiRE+82sRZoq5uTs1pzq10pNrciQNMpa+w48/6v/XGwnwQt7Dk0SqK4uI
lQstX3icxHMZ5jjarLS70wNLYJLcL/3zUlETrlbJM1fOCnOwucJFDkYHeV0PBl58WDmuqAftGm92
iJ7C/Wq9+IP38OBCR61LBoFzh0o8Is2CEQ5AArrxYORrom6vEGxa24U66QpgsNN/m2jrsGBtf47x
V/kz+rfFd4mK/pbQpDAeTj1jbEjmZmRHDQCYXfl2z5g0TO2rtPnSfZEBh19I4RnQxwioa1Nhh7AV
Es7/oXB32FUzlpwCl1/meI5Xqk2bZRrmOew4qbb0hNqJmeXtKsrjlVFYvLMCJ1plC9YIYiTsD7gF
O4ygE5RFDDqkUDiYgxG2m+TeE4SuIzxHEWVuZjCLFqV99lyo3LMOmVFjoMh4p9eGtSd411/UF6Qi
tBP5h0AILiTmSsstfcAB7KSIh3dECSOrkh4ZRiXLZuz1cSRVPtRYtMP8pVeZTpYYSLlHqWXKYkOa
0NwrB7l1gN/38J3R5JNdmlv2HBqmRrvSTzw5y1oF/ZwrZyasHibbtdV7JOUywxbatLodTFVYHHmv
WPbkAJE7qbXeA9tqMCO0C1uUHAW99B9hRNi8jRiJvuMxoeax1nVDpb7AV5Yfmnp/Cf33G/uo3Bef
P2RoVF+fgK1QUT+NvGmydRYW7cJ9UZ48JqA1BsR3hw63BbtqPQ4h8MwOxKtXyBdz9YZ6w4v8xfwE
hXoUCbuVy/ZcB/e3DTJcIBde9gyz0keZXhlkLgdqQL+MpN83ix5wRuW36jvqUcs016CN3HhZZZe5
KoH/+aQJwT5J2ui3t4zxoS3HE6ZHEDEyg/vFMdl7P+hhOD5+rIFogxB6nV6CVDSj25FQ+p+Zl1yK
ovdiA9Pp+5lL0YI4u5lxS+89XghscwcDLpdvewiBM6cCpOJHzxAQZZ5xpSmWEdukJW9dyjs4YXw9
L0GRZYMQ+d2Dt3WP8kXNNbUjWQw5lJXvvDZFg2xBz5QrGygQN0QArxHW9LsIfQA6wFMGBbHCTZI+
hRqDjeuw83vNO19m3qkFGY5Q9FO7bWAQ8TbLmd7cKIWXl7m3kpo2ssHK+5e61dJaMx4LbzH3Zxlm
zszeZF2RBieyxlck9bmKlXCaD+lkFk/LesYkOR3scXbeS8v3niry9x59gy51K8MOXkkCrAxoxv0V
Uqrdv+QcR69O3ZusqQrh5/AUK2Wpd+oVTWjoNjoaZqYgkAGAP3t//EDUC+TlH6v0IaG38hzQTtnq
6K92qpCm2CSxJ9A82WPkW4vYRBeVsOrqhkU87+FFOuEWjzJMtQ+lXVbDnuChOVeS8/oKG6sXCfbQ
uPY09BgO9JOUzMTuMrgYY2uQYjuDhceTYX1F4tFv4y5viiRupdoJ2cv1an3LdV1EB4wgVD1Tv6TV
cUIV/2JQdp3chUxczsdnMzcbHe6USr68YXGPS+Mp/mkTkhNBIvGy/MNGl26QYwVL0Je424kS0773
AUwvLC8kHI0PGh9AuYoy0iSmVCgk9MquPF4uoI5z3bDP6tEgS/8FAmxggpp4WDezwlHDXxU3SRaR
SlcO7VtDTBebfxAC34PIyFHNWIvQBTo2wfw2Fo5Aq60erPTgII/Uk15GO7Du0Lf/FT31snUtLc6N
nI3ngagf8ADUyokqDT5SEc/6ecaSyKNMWvmLngu4i0zh3PjoV6jbGQHJZcbclNQaEtqjy7lRu63+
pYwxjqFsIQwiN9aVD/x8xXU5HDdmJQCyFQ1azgRhFJNYDaC0A343bjv3LPZBeDYL5kJpQaML4obU
EZuTOt1+4jgPExcXH7uJ9Qq1L5DgRPlnbtHi/ngY4HMzfsnx1ZZWknWz5N1V0LD6L+Tzoelj/6vY
IV68appeQCRcrLculO9Q8xuz2KZuxnahW8fipk9050H/Pu/71/3VbNjvYiHhevjH1ZIudKtiHzDU
mUshrvhykbZvzCmIivGFvSbbsVQsyRnmyOcmlTDIkVFZ8zS1rCAvqXlrDvh+kA9qU+aytXmn6mC0
3AmzOzdEYwJP3CyEBl4kEGx+5ZJN/mOWnEEc4p/yuZq/X0fnVdhvhtgsdC0JBmY2U0PyQ1wVCuKt
TNA9qeXPbr1TomWvWcxRcv+j9wjYvItv8D8Iwt5uQvZiZfLUyyLa+dbmqGA41spV7MjYPJNBGdix
5IeCzapSE7ywP3s3KxGpjw/6P9zGnK0N1u+tHdd3v23+TeqsF0QQFV23KQUvH56vTvW6+U0mVwf4
YOMIimQ5H5qvRvqRgtnqXDNpe/tpv+X7rim5REpGEqPFh9KXatjHo6iUKylVT1+DRwnq6NgNOx57
9lHeAQRKALCqMQWFfjFTN2EAup8AQv9gN9YkU6rZFa0c9caFZzL+xs8hTUXVgrYQdsj8U5bTHpy1
vyKldZR0NxGtLGUtXo+adT54inFAY95gcfXNfdoC0nSeMO6a3uM7gl9Ec4wIT5sX5yGY+UN3g4Kl
lWVZwCXQeCGsMqIF1a8m7H8iiAQQ2mIE9snL1XHiiba9eQ0I3qVrzd7o9Nm7IlHLZVcz+Aqo+xnm
7ZqhFKmZO6YxrR9NSiLk3tztNDCw5gY95PF08MQZIqsqjYiRwUlNizRJhTexTd24m+h4ApZdyHHu
b6LUJPNZmjjlbT/QX3bVkVKn8TExCqztlJQP9nZUBPW5GxCRqU6TfPi3h3UbvKQrKB07Mm/ORqob
nDDA80r2/SOO25glhs/lzXeJU55wUSxjmYGF3k0thHwsF4KNbYs60fac33wZZOvJxikpYi2MZkGM
clt8xQCGGnrhXpaHQ8S+zGrLYIJEWvPOEOg5iK/AJ55ezt53BScCm+ngWzJwgveXYffOx4kaxg0w
ro603Tt+qLhlYfIkPmpgzdAK6HNpROB3e7RFaoxvkORNKczRTGJldaT8eV+QYEwVima3WbtCTNYf
QK3BV4pXQiqssuBGwg1UQtEafcMFswTci27LltwVShPMVolJWr08v/FTLhDC/fXAyCuw9lC9Ajhy
RSv49vDsKIawWOv9Nhgemk5yzBTNW931wlZK72jCg1pnPWOCMP9+rbb2ELu7Vmrh5wcAOK6xpvU4
IxQb2pWXmtkPg/KpmIhjToDaKt/UlgCVsyVU/ramhlSIsKb+Gjo83X4GGLvcZAWOT0Yl8y2ZsX3K
nsWhsuHDOvbxP2pzWajafZSSrGIHUe+q1QO3jlXh5J61ZhB3NibhDBM5Aqzc2d2RKJDngHpxnJEA
g6CmL7yGgHHYi8gtb3JhZjPmgDQhaUC9y9u6ZbDznc0LjHxxnQcvgOjGOJHfzx66pdYc7tQy7YKM
TZtJ3D/nDLEXKUSU9fuelsbkJbvOpXM/i7jQDzsJQmOWUBm26Phmca86oRN5zGvI4weTnOp6KEtX
s6inopU0S+IZQUzObUkKHiyuZBkg5z6BL3gPZiuw0UmIBTfjfpxIIe7jsDTtJWEq13QbPzRxzKTS
stKieE9YuPkiO6OPLdBaR+dhMLjW4XusSvAAv2+D81uCtjYN0lJHpobppvJKJxv1bamuOyfeqmcM
Zyb8gKucX8NNItm1RZpi4kgpFGF2SVV1cy37zZ+OIdt8GTOwZL6Zbb5bNjBamTDUMlA49wbtsp/e
Y0RC1JIotJQAppq0UJ2CoVAQRBGHGbhN38I4K4xnFCiVK/a9QVUDPYJIxSITDON4VPIuBqRaPr/e
cM9lbja+EQV5ZZ2FaOkZSBv0RiMaOUd6Sq8QIXtWnxjSpciBerqRpfouOW/X7YLGZ4n1n4Ca8R1t
Jjm9BroCTY9Sb5Ad2bNVLUwDqNVxEDmVfOJFW8S/gkM0p2xBxYO3DhasgxCzXkgNp0DFjabWqjF7
DblZloHxzQNxN/QiD0kXfXfZUduIZxQ+yNf1A7o9sE/o1/n6H53kFs6lzooTAb4diSe21gCZuIZw
fufFHrAl8xKyQz6z2wjBbpOdAFOuq+x7zmmnvzVeprd0c33RucdiWNjv9rwUG/r4UftCaW0FPP5M
SukwwzpYlmXkxtiO5KtrvhylKZ3NE2jgPoiJslXKGDT3QDfulzq779GVHXg0389QVDWVM6S/i5+S
utjuTH+fIiqzF0GmnsS+f8Nja4ogEO/as+2wWDrw+tB+W1Y9DiZ0mlPPzvjeWfp9ckLyhsk/IhiM
4wHqrwQlmn/50r+38ZXRSHepnl+ql1EA4b6zxRnkEu5H8fe1q6ZKdZaEtLeR3RtQcLl6qB02VrE7
vLQbxePmahK9zwtUNKKwNLlgE1ALUVVB6MfRcNeXlcTqY3NDw3Rnpx51j2BZj2GMjh3hmF1wS7w0
umLbk1N5e6jd/I968KTj5G4uB/rgKNgHZESu5FQps66kvejbzDYUpKRfTAY7CQKoCLA6McsabO61
/jtJIMkfK67MQ/VVb/UgZ5ZBMXz4uYmlphzVppkqMDDGdgs2xMZy5RptGrpc/airjixrgYk6YbTY
TgBxkZoZMtgh7LOqFQgGeyGcd5bFhacnF/RKg+qurudqEAvz13YtshoLw5bT4iKyGnIOjBMfZ+oD
TL37hDr7eoJB8HOfFLmLND+Xzg9cIMQXX0KwU6oACmniiSrAI8sSeod0VCUXEx9gK+dhYCISA4QI
W6yTI63j60p6oxKwHoA6uZXpQFzUTZYVYUZRiXFyAzXSLI8q2LW9LJwvo64rhHtfe8vQD0s01O/B
YI+CFmUlbbUewPE3mb/wbYiVu7cQA5w5kfEzhrSVQZYbQj9fKQNzzWXTZ7pLinMYKdvJbJ4YaBmg
80qnd7wNawb1KbJwMF4KBAXR4pAXkxISU2VfMZA9lyrP2XgitDRbPjJc27fTb6GoLS2S1Cucszik
ki3NZbCt+ezM4FCLqMao2BMcf4i9SsgD7tydLmwCEGrNdbf22MIROMs9D3JpC/ml6BVPax+EU+PU
EErkOB9rU8ZFunsBq45mfXeDzVfoUCayojqBNYUBuBajjiEa1Mvhpm3PMvpR/RJQzYP1RufS63aY
SyHUU9mo4R4Kvychxv76AaEDPs59zPJnNbKyKq0BZq9RinLdfZZ8dlpZPdOLBqWPiFLVI7RWTu7D
JH76Enp0uve1+UAEcuPPQDwwfvh/EJgN+wZqxufb1kvWMgaPoVGG6kGUi5SUP9H5zIHb6hWj9qQz
XBdWJOFYisTVJqCFo2MGgWxSPbHMEsXfevc7zfrwplE7+0TKlVaIRITZkELMsPDseKvqGV5EjwbJ
DEFF8khQEmLMSXmvj3aA7mzwmkKhgwpllpOQHWseyAhFtu7jC7tok/F7xL3DRLY/oYk1hMMgoaNU
GrkIJyU4ifxfUG8V584TyF4q6v7VcIt3HZZuzSB/8b57pyg7hzYM7Rvj0jmUOw2G5gqnLxMxmK61
PFl2VP8cV4cx/umE1biY8WeNyzV9/ChqhaEJ0hkVYHNKi5SKOPJoHtdyUWSWq0rC8b+G+0b8vVFp
dLzj4hrO2P5UJjjiL2BRWhFl2NC0kYNzevTv9yQr69d9KFixFIs5llkooHQByAkhVlf70mJcoDbe
U0SDDRzQv4SMirb5C2ZLVWlJfe0AX9K4VKI3nQ1SMNpjd9uxKDh93FA4oclsI1Q5XRJcxN5hMesc
meMqKdOtqBSePNlF8MMfGwV4uSFWeBcMr6qcs+Dl+Em6cq9pRlvox7zG0h6j5JBE63veOkOtUrVX
lB0LnjDoJpjoH0DhiPedc5cHa/Zz8YliOgzuuiV/ZUsbjNrZa4LMTY1JEuhbHUYhPGG/p+AFQemg
8H0HLPiVxTaJYt6juVLOZicQrN+i8tCaWDZjEXEa01Njk+eMvren4RzCJkw+EBxp+dNt8qMfh5ei
WJbye5ktjHPkOeevxy2v3biqS7rYLLv8ioxuxqoXeomCfX1edGD6ayDeRUkgymCyfeI//b3I5mOq
TXPl+wp10PXKCd/8Q9LrAYe1cDXULyBNJvigf9X8l37FCtMz92YxpZuuksmerBJITu98QvHy228v
vkj8a6A79qQHio37mZawc13ZH7fXYusy6Yxs4AEsO7YEOT8eUOZQ2cIauznkvWc5J5nDLTzus7TT
nqGaqcBgpZhcyf2tUi3HHZjKtBqpd4vyrx3Uy9zI2rk8nOMasuPFySrzcYSVDmv/ASeljK+mAOQX
hdGIVRhpFnKNIAXD5Y8KDERpKnOr0+P0rPCIhk/r0HjNgJHbjeUznSVVimiBT/cWtFyRu47+K2Vl
X+iC3T52dzbzEgFgZ71keZMFIQGv6IWrePAa6KCmyU8Z2WWy5Ma94RlTBvfrpkhG6iP3SrvaitXy
2YC+YAjJ+/vUJ0dQNqlgNq/4LT9XBsxQAtvec/KuSqtR4tx3G9S+j5EeDa0ncieAeRCcpdu5DExw
Nmw3jp3KNN0QNNju1fFe/sSh2FIo16rl4qajRTSY6AOFQPMgcn6Y8E0FIZLF6/T/K7s7rGOKvgUz
hmU4Y7+ftZbQcPGZNZpe2gXAHhYcTKVa4/MnqWRBoMy4uYBFfow0YeFdCrsj2X819zH2IEaAVL3E
XKsKD3YZf9/jbGVxLyPa/xnolyDp3BPgWDgd0yuaONxAGWgYk9uSAV0cgdEY7KQ6ppc/iqaTRycR
t+3cjKbk87YL1eU6xIPJ20vq4pp8eehFsKC4p+Jz/Z8Eb5jK1Biyz7hE9yKziCPXKCulRNLiP//8
8qd5L8nhq8TuxnkDI+1cAjS16P7eayZnlvdng1ARLn1MqxJUb/u+pAobVjtpFiutqBmEgRgcHBf7
FwGmd1Tn+lq2eKPyvw3u18EEDa9s+wICC7U259ec1lHw/9Gpq1eGlOvBhZh6KE6xih+kNuqidCHy
XmxaqzVZf8CCYQ7TfDq0hUR1SSRIOLfxmS0WmgGeFiiRbwOSXt+dktAW4sPMwGghYsit8FtMk3XU
uGT58zpZpPLFGPTRvzl+1rYHo7P+mAPXYi6Z/dwrfJy61JUxuOeR0iZhGVvwiNaybekSPrn+drtk
l4gCgrdOCzt0FzSt0aICYjoyZVZ6TMFLbRIf+ZzxmTbos7XWWOOtQsGNJnjRWHHBjTGNW0n01MAB
+79cepzbrCL7tk9VyEGIfCzyaFk50+f0NH2hZcMIT4cNhAhD6xv7P7gOu4AT3pDlXyagnWv7HLj3
c+KWP2Pe5yZUI+aZW0D4Ql76lxRWNs1lLnbmxlpA5wUpGLQpU9MXaQr/yVtX79j62BkCfHPLzjTn
ayvnFAuvISkpLP2goaYranEU9i0AsLcgx61aYgT0B56aQPnlYW4NeBnCgBpWeqFth9eg9seXEr3g
3piaZjnqpS0F5t/Z6uXQxwvFZuZMdjSNL9dCytqp4Lcnsh+m42uDkbQ9BGZKlELLqJsN72ZE8sOy
N6SlxE9z/7t6yb5Pdb3qzhM+thL+r1JKFRxyN4YCjqKXh7dQXxAGnk5nrVMkaQOPL78HjXIwFudA
t8urjS8Tl8LzBe0FIFX++5O5rpJnJJrLyBKsrkGI7TycyCnW5dyjAfq1ctOvYOT7av5j+YryC/pU
nUnVPfqG7SPgjhfS4ye8qdR3TQOBzUHCJnDPS0Dl4mvy5J6kO3uHW32OVJd3BFrZPeQaINneVK7U
2aShNF9rclvy9TcCX4Uh/Lk7fbOStoXKcjyKKW6Tx+6Fhx4fvUq3NVACvsqd9IWnXQyBM7OLnXFH
Gx9AUmxGmivEUs8qv/j2FsrkrQRafJcICrseIeNSBgD1BEE3lwvJwn3elTRzmuwUjbVaYk0LmE5R
RBoUaaPbIRE7iyExrAaCviWOBly/NN2W4N5XyPd2irZTbZEjECyJXlV9TnbHWYTlbvMw/NL4ZwS3
JrtRy52e5bWDLmrO7qQLldRMEsvVV9v0m0lDFOt0mDMN/X9RZwhMH2fNjI/MfkxMig1xr39D7oQr
xD0TBjGPSB4QTS4b/5NJo/TeE2DphNtzedbdFZ9YPu4ROqZylVe1x+SSr5ymwwCMb0NVRfDVhrg1
yORBLSurKNu3INO+ZDYGQuM0eZD2HZR3s7xDqBaT1g4H5GfwhynMm4qMHcWgJhBdVSnkeJLCrUsV
sWPpPoXBhaENgi07j4+0f6FlpDm6E7U+uqe0Zdnrt5MaHA6uJEHlfB3T6L5i4A7avfp9c4cS5O8e
MmTO9zX0Z+8f0+xDz1Z+rU52NyPQWxQMr0xrYpLdshnH6VZ7rTg2oiXUbyMht1+T+vOCtp56D7Vq
GScbYjyc3XV2JhY/WOPgv+IabCrsj+qbEEJZRYjyl4WSc88rz5wlpAwlceJmsRY5PphfhS1ZaMVN
yjKYYIH7+nJHHLOu/x4I5csMlZQ5NdWgkk0WrUMptXWiaeMpz1G2FaPcfRLlYz1+8iaSsELIJT44
7Q/8Y2RQ0maAAAJDqrJF819xOPQlp+3TQrYOZi2rWXL1P5kbP3GPDdmDlFDX3FZJS7PUetgNfINy
juhiZUrsyTW5zd0ghvlaDPH4xQrkUT0Q+NlHs1UJHVh1KN8FcNXKLHmmN6t6JXC7McJCDSbxAewp
zA9WH273Le6zCgbXPPTtp0TFnTZNkFa4TbFXeOO0JSjrw8n9ISlQ6ikzNgjdPChsKB0YgYdTWKsK
56/WQZW8BmnIeFqpf1X2Amd6DhAdzjpMvu1ZDmLCNDDx1LVWadRu8XPIxh+OeTrOW7EZSCPQDudi
m8nr7nx2StcnYsGzfXDYr3J6Ai8kgAgwN8WslgT//tN8/PwGC9iX2JjxuTEBpHN5BvfrS7VBFK6l
95dFOm0zGadZvOSncuhKO8b82KaadPIjIPWfKa49NFnVHZUU3o3zWmi6idJhwMTvNj5ix+uFuqzq
RcNs1dnBk1/FHt0w5fST3ysddLKT1I8ska+TCUvPKdfw9rbel6Oyoyk7IaXu7GOVCz6qfKQLF+Ih
7xBYm1yVL9RakzNM+6DdZQGqP4Ol1/7g5ftXhu/nl08OwI/qp9LozsqEgJJBkBYYRp7VGdVT63Ux
iVav6iC7Zpb2q6GfDp4qMtPU5q4HHizNQH87HhjgeDBmOLO92WATT/i2ri4Mo85fVVibkmH0pBGp
ms1rLLokDUtyLveXtPxm4XjnWaY0oVhCkiiBKQzDOf8iUPIvTs4dHvMmmOlVVSI8hdKY/I4gJ5BA
ruZDGthnM/53h/mEm3INwl4D5lUWQX9zwMApEko5AF5ZajeGiaKjVKtxcMZUmb/yAVfok2+fzCMe
q2bfumHOqg4ePmdu0Qtrm96lTxtLS7MY6cZZJAflyclY2SuPpp0zUSrpGVa4o7QU+BrRDZhqvTkr
E/abeWs7rlPIC8+y9/v7E6xquAfgfC8ZlmiqWd/MpStaMMS0iR7Jsp4ToIuKAgPeL8ZlJaOkscuo
HS7bI39MkL9PyGYV8xwhWzSEObb7YX/RSLQFoQ2H9BjRtv6eMnQC8iW1ZZtNuhmZjwLmBbTVhrLk
pg4QEFfjFvjFfGR2BYhPrt5xY80LTcHGOgV0ibnNbjczNnaxzxUPEZ+clfLB2NXLAblm+5FbWMiw
RnL4jUq/x6BEn+m/hlf6uzTxWI51zAs+RfXMWho7agCW7OhaOYnxnjE+CLT+Y7HdJ8BINQB9vKYa
2X/fbIuIh+LjJ8+RIssXmF+Pkt5n46iNVP4WsMF+Ow+XsDENjns/YktQMv4FymVGzl8sZutulCnb
vN8U/4Kz4fAVUv5qz/qvajDchi7iE1eEvQ1HzBNGKiBvySvY1zNFLnjZnpSG34JFDDZcN7I7/Rjb
GTe66CojMQlLmC9uJHhx4idOKLeVGJ+t5mN5Z9zd0CbVNehHh+VwgYwEin0C5kIph3CzZLcn6nf6
9Ji518BHwNUZ4MdPAzh2aM4QzZUHK/zqrcisxOZdOSR5SC+27WV4wW1gARyebuEzOMcte6ZUcd5I
NTKvh/HjTKp2F16zcWILCSOTxPX3gGRN+6KHa+SrNajTv9cpN/mL/mewAQeHAhB+f35YejO8Bk1b
LYFuwvpgIlgs3IwJFmlIT1LVaDFS4OU3aDI8iBqIWwIIY9ASdDr7bhVIt/O2/D0FH1R9wxaqa2in
m8+UTylphw6Tx4iHd0ux2kIrnPkZMrFLZkzxyjlNTL/Zd47dbMpqDGhg0UTLKcdd8bdP4o9XuGWq
4hm/ODO6Vo+BdLqYC0Mdfsl7lqHdXayCleXCYIgwdTJCDvZC1K4QIy2cwA2XxTCD4n+yCK5vj4AB
EHeT9W9C7Bi/TQw3K8pBEbeQSd3WRzjN3ZNoBGyi9DY5vXUTlk7rfZb1MYvDxWycnBQ2/aJA6b2H
wMSVVRj/q5SnFIqFJfm32pO12YgMViGmVniHKcs4svCnO2oE1V2cIohhEFYrWFN0udoSvio6n9JB
OCiMYi9urWW/5n05f4HzoROLnUoI4esgtiYlQonqtGaiA2KFo+XITZuMESaoMeFlN5DfSUMuB9oR
ZCYgHz9MZMLp53c+bMi6c95DfDUxt8LefZ4Fin1CIeQdLmw51C36hBzxwoU02r2mE/7Gt468IIQh
PSIbjRxUkjq3j7kfqqhzcxZk0VCB3YDUHjUW4r7sZnL6ZEfGHhVFfF3+zTZ7rT0agGWq2PxWrHnV
lXT7ASFgRXzZW0VLSEWpJqzO7dg1LOtK+9nTJyEiIzG/IBBOQmNiBLkOu7k0zXJM9/84oZL5XHjX
+PDzDv5gQbn6eCuvRbMGEVXH5LlBQcMb6GPXuyCW6InvxeG9Xwk1Zax+sCPssZi8V10M0ENbwfT6
ojpPmUihbRNRaSq5KgpqMhCeb9PC++kXF13GSrYZuuHPW4c86EY/Yu3yDRLEb7FqH0HqtzA6AveP
rbCDXItfB3+3HZ8frrwUfD5HP9lufIfWpF0R8TcyspXTZ+m5n9dnIcQaFbBjUoki69lEGITMAkRs
rRvyA3Argt3cD6KXWiZiE0GnSUw8VEjqcmh3gfojWawEX68egXqRLD7USKrzuqIpGy3Zdi5hftsX
MPS+DGOdAg03SAA4GWCtEjw2aRXXmIcOHHpqWcUCwKWjP4a3ibVuEoVKrq9IqKLoYR0DmTtWOZlk
Yy6ig7AfAOto0h/jRSZvyR1BF6mBytteEzqZb/gdtDuFs9A1P72YbVf07c5lx9vAAYggTZPf7qdW
iIUEZUeloBCIVrf0JFKMpuBiVx0iRnB7GP9zNv3J4Flu/ta/Y6llNokQl4F7LyJ7sb0V4xg0UWae
6BF1HdJgOrCdsMgSHF10JA1+qr19aTBeYtkn4pYs8p5oj2/dM3bspoDEYR28cZEIfTQWE2h/acQJ
LFNReLh72nRSzFTlYBRbiE/cRni3/N0miI/zzlxe9VPOMIpQAp/DCeBDRb05MNufJiZp+e1egrvY
IgaG+x0nEX84BQoNLSN1tLf+wbwpTNHgQ+S7oCLU7QJQ+Zeq0IOFVohVkSA6Z3x2hiUt9mN4VElv
veIkUYIdkcfkVG6xtBE6Y6V3Xz6dQnqLapYinWlqgjosxg0cjxRuTXb0WxtSAMsMCZAkA0EBA5XL
1+8MQWeqSIHLKqcwfDBxJpnWOaPZNjHqxB4IUv7zYmVRqSwV73TijrZidKgmauh/9eNgnR6vfSZN
D8hb3KV0/p5oIPR7JdYH6rZSiae1kMMqq+0X6siSlisXcNwt4SLRoQPAv+AfWyhl76S2LDyii4lc
dEL1J5lpIRZWdK7beAEvM6gH+sGE1YocLMraez0J4837W032lhReH3I6aYbvz+WCqm2X/ts7waeV
K5Cp0g3FQ+EHbLJMs5bvQo2WDSWajsz2b712DV75ZeaM2U4/UztVC84IxFkJQRJ0IvOSDMWZUnI2
OIFuYae5JTpZgLQm+npfijYR0pR9lSGKZc/zC9BuJlPUrZYE9OHH1ZJSi2fSAlPT2k5g3xHD+ZQT
vil++lhbAMQuUtknujO8UKkmc+YxkfIdnivagmsCBNGkTuPHlZyr+fNrNE4RGZeG4dOqkHTF4T5Q
7jE2EMbJdgjYHsG8Q7ZJhb9saB80JPC8/7wlp3iHeSZMLhEQKGYtbBZpWt0MjlAG3cX9PbaRoPBQ
daHu9L1WedtkNyqoB8JVUf4BSdikpsRcv/fJIIkOurCYwWonG+wcvCfTnRMEu5JyRj/wmXAe/hCY
R4tDVcAHm7koB04h2svEb0p/5rFLfu2X4ajuCX+tBgOv717X75mUihWbxP93E4JvIRWms0NchFgA
SveZALj2HS4C7VK1InbezAXLhCQyARd5x3qp3D03utXsBzzlRcGKxuqrIf9Y6iouc296j/S973OQ
Qm2nUGtu9M0T1WHSR+l8g83B0xiqeP6Gp2UlZl57Sht8hhHBsXYbrx3q7a5g0TsLuFqopvNy0jQ9
7tWgXo1VP/l8/skF71IBldVDbDXbVu8AqciSGDQtXRpIGKWC4j8J3rSVioh0tqUBFXfhFYv79m5b
WY6avBKDmyxSVXHAjgmOE14lnuku+NPsvXqhqHrkhfFSKjT2Jpwg6VNLTDkfw4aPFgibPclvLQxR
TYlg2dZXbEpiWhzFqOzJLJNihoMkU4TRixS+U8JUBkD+fPonNqtc9YDTF9N3sWGtsNIHoyHZeaZY
6PYaGiYFmoo8UXofWjnG9rOee4cwQ4UeRDalPhj1WbnUjV/jRg+RUXaWKn07ryB2Gt91rw0oH6bd
cqax3CS1MzzKFWDbo8eDJVl11+QElp3XthY4y/no5vrRwg6tA7vhN9wiED88PaHxPKOB4LWJ8Irx
qm4igJuJZwsorhu+/+R9vKYgaZ+RrMQHIRbOdw8SY1bwaWPakfLLdY2lQY8HWGNHSBfX7WwuXtpp
GGEmybuQMrP3IsjXeJvHVwZJKfYX1y+T5W/t/Hu0wfer8N8b7GYnzIdycJgRFFpYHqu5HnK1xtBt
KQ0/QFDUosQWPVzrv8mLeOJxTSMtVqUM26SYi4XHp1thbky2FTPPT6jjAjCKFhm0EzK2IYtCofdz
Rv59jPAzYbk2cptw5i768a81tqjZ8Td6PaXpixSNdbnCfyq8vJwt5oNuXpYf7r3bBjGLKO5v/j38
KhcBxmBGpnSYOX2xVNC5ypaRjbmwKCb/a0Of4/f0p8U+OyPUzvHza5QBKWT1Sd3WrdYNbkl30lLr
JPyZjPBcdnUleOIWd+bCyvflVM3gU+YJqc0QahMkcWFoYhprw6Bznz9wcAgag3NN3e2/8rkWbkr2
IWW24myXVjHbWwBHia7WUVwfSNkVO9HDnvfQtykUbG1XWGj3MbKNztVfR45gqKPCx+Uin65JQP//
m1DnIhegsf3rV3VJMfRP7o7FOWc+mFD/xYlkV+Owrxh3ZHK5Mr4AB9zXW9lMdp0mjE6hcyV9YpC8
fHv00oXVuQNwjcEa41GStnRcOdFQ9MLG9UFw3AniM+1QOhJY0VVYJhpDjAHb8TDcYsiIEqvV1C4G
UTVI5rp3qSPrxtzwTorT+G7ugavfabGX3aChP+67zyy4X8l7MilWrrJ5QGV075L8P2LUvozhRNuZ
ueBuLK1CAK9zJ6Qi6p7sCLPQf8sBtO+DdqTIPyf+zXRdZYhaZ+TSCleQSOoXE2jugBUva3am4FDJ
NKEtguIYDqfkjOoTY8fmnSSJ3DKUZOw1pQ6++OFSk+yv6QAKx0w9tb25JOAcx6o6QXEzuQ2+78eH
Q5h45p6U9w41SFxVjG2NIWI+6Zxus1exjAwSBe2pTSqGeKEy1VBbSouh5MysbUlXrxbNR3Yi5+Wc
FgnamLpoG+3g+W8/SBap8RvoTcGVX8Gk8zHYaKis46F5yHNppqlT5LYDkfJDlNSjYFLs7Plrtrq0
g/yxh8lfF71jzKnvBfEgsYZYEjK778GC+NFJ/3oX1xhfybUJEkcMEO7uuTPq/0q01s81ZNau8bpZ
QSnCtF6DMQxcpBHahCR5katHFxNfrSktpzbKF0eiJ2tSjbdvbtkln0kCLXy0TGtrC0scbHD1OwX4
dBH8FNddalR7OrJ3NFcbHWr9r1zw0O8EuVfuTFuGC7n+8q7SpF/Tp69kS9yzKyUnOC4yRjbrHudo
8TtmYgYqMF6bAWaAPWQPWtEL7KOevrtIaqmsXynpD2eSKMc2Cgn2jqM4aAartj4cq89/U6fyf4kq
EOhfkwiVYfcZ55lQIVpXPqvYMTfJ8jiUUN7AMiXX4uS8XTX5ONdCHbi5W6J4vK8SK5DPbyvUhKww
JPapAAaj8EthJ7SjkDOw65mozImiZ8PKVq+b2ZoJ9fY16k5VNRwCBpSVW8H9YCNVYYmCMsJIffPD
xNPX1gDP63hqX4/NP71w7gUGER8MgD0qCR7dsjh6CbNPf2lqDlxP/Ymz0LaOWMxttFhNaEooW1sc
9omp5Rs/I6NZVuQoPIKmte6kWq3xUbudSobpFgUT1iyVDYUH3oI7vTB2b4fpi81EDIpnbESbvb3D
nAsfY0HFTpM+/8p31p5taOz9hnZyFUCuQtaEQ0N/0lnPp16Q4DCr39aIDBVeT3OC1dCrUKMLk9eG
Upg+whYCE1ixZASTb9/jxcJcGniZXyQqy51J8NZxt+1jEzvDR5nL/5PIRmWbzUWtGwFErdKgQ+IL
zj/4Xyyj9QyjiHgBxoRqYzkkVDlsboF59x5uG4I3nws2qAAydkbIjrzQtEli+8gUXtMxIfZcTj/q
0hT1za882/gl5Rcoiz1viKOHcvL/myIMvqFM0rthqpzev6PptKiiXRtxoUmQhT6eCNlIXJCsuqaD
/tWoHV0vGPFibfnzaD/2+4qEAUXEXp5k8j9MYYlpG5rj35UEDFw/LRZKSGoiPRbgtawQ/uSiNEfC
H71L4YQj/JwuTTv8h9Puy9jhbMVcA50XGlrjGYTa7JeHxG/EqtKAuWtvMkWNxQFdiyZsj5SdyQud
sNBCrD8499qzYwaUPxAcmKId70VhyJfmADh4jMYmL1XtfmpbR+0zZtPm9cKr1mZE+PuxjA9QMTO/
0bWmWHuY1yzgrW73EER0zsxXgiPPtfPqGiiMxTpEV6RUX7LeGikBuVxBT4/ZHRnV4Stp4qj5R1MY
faIbQc3ah9EU05Pwoz+3SJqaVdbCirw2WGSF04os2S6vl3uA7U4B1CDe/XnjnOhSz1GRPt+ZChAr
lvm9t807Xt1LLdoT/ymwULPwY4r5lVn5wZ6hqVdVXgkZzd3yJ1D0j4O5C8ltHOnByYedTFmgv/L+
Hd1v7wmqtH2cm/mZXyleuJ18cOShkDlPy9u6sfwJQdp6GTFg9gbZR3mgn53UT4G+QEp63kJHiBz3
1I8BeMAjyGZGATOTzdyq1Sa5VwYQnbf2zKxAhQRjaTdO6noZYz0zq8LZecJtJjhbmJgJhHwzKDSD
J0PwkFIvBRoax0pgj6LC7CM9mZdirrSeO7bakxE1lxDtLT9Ko6yDZywSJOWIbMT8yCrvLis/NOC1
zChnpnp4Cq5eVBCXt1/RW/TR9DLiXOg/hVUNaF2GAiojBlfVNqMFyUKHYNyvY+d/7A1OEq2suSwm
gahdIW6okRzwVx9udMwGBvR9ZqcgZYy+fLgR52hK6T2oDTNCLu5rYl0Kfnz00P3wWGEYf1/5iNOf
XTpEQmEDZvu5Jb+Th4sMbsBYIN3OzGxaD7unyIlC/0PSgBD52LqPUHlCQtdcQYlZ+9oEO+GcYiaV
OwiYLaH9pXXVOC9lryaBwGUBIdaozsrNEpnITiSLq0JHILs+LfzhTMyrpkTMDQdYfAxxZLjs4+Jp
cYJOpzeQPo7rGup463mPrhPbKg4UyB8xHYf7RotUDHqbG4J28bzWREgr3yK+MwcX2DwX/MY5A7gV
F/U4LXm4kXCwTv7G7xUPYAW9YYFFbHTKNlGysEc9WEibWbGtBLooclY56/WzT1INUtZ2s/YVS1qA
T8Etz73VQuKrNtl7qdunoCW852Ie9z8MX/8atTzZepU/9CMsTxIbUzZA6bJOQr7eIIFpz5j0bzuw
gnO6qnlYf4uFyKb5wYZFEedvHtHuNoov9DN7tL1W+m6AFKM3Wc/esrpKkgUEVyT98aiZvK/Wzc7g
1dZ5B/hdB/zPI1W15fmIhzkHM5bInKffNqAsq8lICphb4GySRT47jrogJ5OOYdtx5FqM6WLelM9t
dRic9TRq+dfSHuK7YGf3LbCLR7ZK0G5yAZNnzvKZ6CspfHI4QrcybnIhmFzG8a8vBs/uwqAnePRL
DOWyDaQ5tGgdRXF4nqkE1xztprur5Jkse8FYktpxYKXodAYObm5PxcbiaQi9XRArbxXvyUVbY6vV
bGRPxfxv8EGt1xjtUcGi2+PJTFOCwbKffVEa4PNqwXSJC5lkj1M2qdWbCjvTFUvj1eEaiTxS/1LK
PzGts3q/Xl2Msjww2xTpHryzjTFxoFqESuHt9FhDagkQQfI1EusBZ0iqn0BLng+ycZln4Wuyykpr
qmSqhtccBXwtVY2W8wLaWHeZeq69LsqN/SCQcgYQOy1MO/Fa6aoSRTDsEZMZe/kTU81MlMzpQv2p
rRYFWl2U1XQlraVbTYrMI2MXeZvL/dV94nmSY9bONoSxrheu8Lyf1FKuCBpU2bSWw3BsSc34deui
v7vkLDBQdW1HPERiOq+bB1hMKcPlX4rufwoHkQOu6MnSvkK++7g0Ztq77Ivyr5PrF4sT6+W/sCfR
3FdPq5/PNgFuQd2iV3z1aakQ4N93Cm71SI0TuZhQfeiC2jdlER0mv5rFK4wsmH05r3SkZQ1GTjTu
vzqi0mprj219sJJpSBMwGwMyH39s7iqf13nqJMrTI/+52POXDHhOZ3uWf/YHHxaSdE23NvbQixjS
UuvREn3KuU1uOB6pU+xAu8obUtmss1nOu/IZXPjczSSu85TuFnUYpIaiQ275KWd3v6BAMXHwBvK7
7LHBwoRXONmSYc07pBFyH1v5UOh5yYNe9EiMBQABNo6ottaltKZLMoXJwaG7D4DV1GAdaV/6zvg9
1ZM9CqAxMpI0MlIy48dfG7uKhLKVnqD+znv+vv+NKzoi6seJcZsliZUKXsPUeZWTcRvvhYW65YNJ
P9YrEddSHP6B3NK35hEkv/NyiighN17iHIKcAA3rBEqObxvI+c4hsZM57zs4KbcQ3XetncvVxut7
srOFTAhWP04zmG+ZDSQwZ5k0T2uAQmRoJE4p3TQB5x2c9ontFWo7nGfziTwv/HBAzRpZFWXBAy1O
VeD7i2XCdcmickJG1X6YqnPV6hG1OTGm67UtU1pRfTEbPLGaQXKTd8M4wScAOt8axFmTpCHMbSYC
iqHa4lK0s8bqhNEWdo3MkwsMrH9vvSBEDhkANEGpkzA3A1pYnq5JA3BLv3d/AJgLhodhDujgA0ZM
hmyEFnuXPKDg+1RhcXqSc+/4EMQGQzVlaOvqu8LesQtj+DbShtEQP3N4e70nmSwFQ860t3Uu9jy/
JLjZ0Y359myoxZ/wFOPWm/N8kF1EyI1Cj1wUrUrGuTCAKYirEieb99egBfP6Gx/9vkERtwxv8BLZ
0HUL6L/UkSznfomURLnTuVHyg4XGjsIFVLhIAgicbKSbRK6KJonM4RtRJ22LaW9ns57nXH3itHC9
MUOfoE+Wq+ih1vQ9psYxekKI78BeHa4/520jpeA0+LXpMdtkIUJ3760kjGKxP8+fTL+z7TtYPJ3I
3QQecFhd82joJ2ZEtbUsgZQfO5D78owZmlKZ/WY10O+CBcqLW5MYm0tG3ZIzDi+XuA273l+4tPOc
GC4egww00czfvPIzVJUIDwM7bY0n39cZl1E8KIjvMqw07uJfu76hyjCckzyNvpF46S0W+DnEmjP+
t9/EVxBlie++hA9ZpW20e2Pvbrp646iZxALavug4xioM16ffCf5VwuKcKAOkFZkjWhdmwDoi+5lM
Rj19/lk5S6rINV4RIIewWmsGoqjzqfO5TAhXdHxjO5LI7Pan0tfFXHAFEqrraBIuJCohhvPnmAAc
gXyfeNzQiinCjEkVv7wE5D0L+0JefnJdATGvXnwh+aftVm0g1DiDXQ4UKcJ16Z2b2DXgYyfvtCBN
ksW6xFn+L0uv8urq3rvDZFSz8u5GpwFhkZcEJB6ujddO9D7sDr89aYIYVqpblHAp+HbrcA8dZb9A
D02NRha1xBKbuq01PDHcHDNPouTRwmRGJSRelxvTp0RS5BOXZugY5Fiah68f5EXssrIBuxBDGIjN
YEPiL85Nbo56EYluDTWbgpCRKQgMcbQa5d04nszhNe6Y7NKnue1HHF1XSRZEKHS5SpefFT5tB6CX
KTqwYjZgNOko9YEEL16YKilYpu7UBYvgasvTVojdjt6ZfWbGvGeZ73eDAweqFTD0Xqs6xQZuAC3Z
Mbp+o4Xyw0zDmwfEOuRvwhenOYNGGUTzYpH0r0CAT1m+bEH2UTyXTr/VgyQn9FCPcRPYWSaaOBIp
fZlHf5poy4JbiUH/jtPWnBvuiYkcPYtGVhtMiTIxy65aMT5ImeKmxGoVMNpUfjqz60fSgs23aKeV
rK1w8kqor4YdfyBH7vOR6x3TQsO1znvTt398YGsws9yDw2rl55/3PkdKD2nFHDNsNuRo4VVf9JB4
uDa2uodcMOiKhOPf90cMThBEKjtMbRKUP1CRwkI8eXU1OWzF0NF9zZsJnXyYuaX/wj0ahAIuCaB5
WMG5TTi/r+1Q67oubhcwyQVTPSR5RFJdhtdX/jAi+waY/8bsk8HAWIH8ugHqBV9hiaKzlKgU+hzR
Z+3Z+g8DBUFJ0MLlSFSCU4ChjiB/G0MjNz9zyF7VUwJP+gLk1wHQE4nckk31SlAQ8WycGMPgLEOB
P6eX9EcyK5MB2Hmv9P5rFocEAtRpHHN6vlinP5L66cG8b916w70WtqDb4pHx7D5IblKi/l8E8rWr
mkbT4CuEsrvhYLkbUIK7kFxDDdH0rjkPp846v19hVGd4FT9Uvl26bGyGpRbrM7qCdZCatzud4KSe
vSLpCsR8AfVSUzVm8ho15qUyzZiZYmKv8qyYFS9Ss4ZfnW9MdeXge6OLSQFGcQstapK0//4KvbEk
r5i/4N5NJnopWNfgGVx04qHvcZOyXQ4+K0loOdyfn4aL4jlGIal142moCLGAll6SqfYjlzIDKqkK
eMYqGghBsQe/RoRkJtp6j5AMxTyX2ZNey+jrICPGQIXfBIXqt/d5QrI6CI3GMRgNyjZvi4nzYj2m
d47GRrYPNrn5ad+XtMG+WPxDnDAl4qiwsQ+wFt7yJgIglxr9HM0TnSkegJlyHVLy02p8NiN25/Sm
FcJwAUFVqhLUfM2WCVyuDUl14tVXkMPyKC/OXYItVDThgtK2s63rKqAlx6oHCG40I6ApF8dR0scm
3dXtAwcMJZTSq6+7bNrrYvkQc+D7HHS/LxpYrLkMCgcon3f1xAbQxsu2kbZwz5I2zRn5O5HuS5IN
XjMjSjiQtZgY4KW9nQrpJ7zYPUHbmxEOOUMRoGye0jr29VXSq7zBVvp3jbdOL4G6TyerN2jEev89
oT6wYER8D3VK60fu7Kb51/4HPgbQ5cbVV8wJUYv05W4BzMOifZS0wkElvpHgF0FT+WVtmAGFTiFS
ga+lErncFLeyrxXw7/qcCneVbKWEkfCIPGFEZs1bmZsWT0GDxrBGb1wqSFSxBi7obfHeyyu6kX43
IgWzsdFlJRNaNmqqcsZhU33ar6UQHUFPiEN6kkOZkbU1cAyG8PJ0Wbp+UbbrYMSaoIWylSi4scWp
16dOIhITywQiRU+lak3Y/p0IFqPoZCDqGw9O6bfPtkrmJCsS2u+M7ih1GhJuBcsM7waIt+KB7WUi
u06u0GHAJ45/uoB8+XLYfL+g6WA6hPhsC+Vy1cnMDIzZzBH7pqgr/zOUKkXRhrJKLoKpQXcvXK4p
ypAhxRj8WvdJCd8c1Rd+W4iLVrzguJHL0Rc0cgbBn940KcaSaQGpdbbqWIHGpk5f4MZ8cA/O++o4
1/UsxbQslE5OrFyflNb8YfGp6O8X/D8pWcbw33qXoaT2b65nCpYCw7zwZQdHrCmZzu60OyhMu3AU
nU/GGg5cCue4ybWb8V/5rJE1
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
