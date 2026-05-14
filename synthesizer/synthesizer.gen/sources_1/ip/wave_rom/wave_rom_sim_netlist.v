// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Fri May  8 00:18:31 2026
// Host        : Usuallll running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/ece385/final/ece385-final/synthesizer/synthesizer.gen/sources_1/ip/wave_rom/wave_rom_sim_netlist.v
// Design      : wave_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s50csga324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "wave_rom,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module wave_rom
   (clka,
    ena,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [10:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [3:0]douta;

  wire [10:0]addra;
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
  wire [10:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [10:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "11" *) 
  (* C_ADDRB_WIDTH = "11" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     1.1108 mW" *) 
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
  (* C_INIT_FILE = "wave_rom.mem" *) 
  (* C_INIT_FILE_NAME = "wave_rom.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "1600" *) 
  (* C_READ_DEPTH_B = "1600" *) 
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
  (* C_WRITE_DEPTH_A = "1600" *) 
  (* C_WRITE_DEPTH_B = "1600" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "4" *) 
  (* C_WRITE_WIDTH_B = "4" *) 
  (* C_XDEVICEFAMILY = "spartan7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  wave_rom_blk_mem_gen_v8_4_5 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[10:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[10:0]),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 18144)
`pragma protect data_block
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
QNRNPm/PFwUTS64vagOyLKeD
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
