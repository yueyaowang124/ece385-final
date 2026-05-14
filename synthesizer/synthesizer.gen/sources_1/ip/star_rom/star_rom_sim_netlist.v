// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sun May  3 17:52:46 2026
// Host        : Usuallll running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/ece385/final/ece385-final/synthesizer/synthesizer.gen/sources_1/ip/star_rom/star_rom_sim_netlist.v
// Design      : star_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s50csga324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "star_rom,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module star_rom
   (clka,
    ena,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [11:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [3:0]douta;

  wire [11:0]addra;
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
  wire [11:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [11:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "12" *) 
  (* C_ADDRB_WIDTH = "12" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     1.1848 mW" *) 
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
  (* C_INIT_FILE = "star_rom.mem" *) 
  (* C_INIT_FILE_NAME = "star_rom.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "3200" *) 
  (* C_READ_DEPTH_B = "3200" *) 
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
  (* C_WRITE_DEPTH_A = "3200" *) 
  (* C_WRITE_DEPTH_B = "3200" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "4" *) 
  (* C_WRITE_WIDTH_B = "4" *) 
  (* C_XDEVICEFAMILY = "spartan7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  star_rom_blk_mem_gen_v8_4_5 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[11:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[11:0]),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 17632)
`pragma protect data_block
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
7PlB72DtdkAVFquDFdPkagpaRA==
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
