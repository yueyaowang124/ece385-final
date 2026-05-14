// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sun May  3 17:55:47 2026
// Host        : Usuallll running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/ece385/final/ece385-final/synthesizer/synthesizer.gen/sources_1/ip/lose_rom/lose_rom_sim_netlist.v
// Design      : lose_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s50csga324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "lose_rom,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module lose_rom
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
  (* C_INIT_FILE = "lose_rom.mem" *) 
  (* C_INIT_FILE_NAME = "lose_rom.mif" *) 
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
  lose_rom_blk_mem_gen_v8_4_5 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 62672)
`pragma protect data_block
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
FDiptkz8ZtMiyHDeWgCmmat0sb34ZRs8TT9rpcY=
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
