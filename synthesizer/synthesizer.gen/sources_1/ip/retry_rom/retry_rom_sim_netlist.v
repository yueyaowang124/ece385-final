// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sun May  3 22:14:46 2026
// Host        : Usuallll running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/ece385/final/ece385-final/synthesizer/synthesizer.gen/sources_1/ip/retry_rom/retry_rom_sim_netlist.v
// Design      : retry_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s50csga324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "retry_rom,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module retry_rom
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
  (* C_INIT_FILE = "retry_rom.mem" *) 
  (* C_INIT_FILE_NAME = "retry_rom.mif" *) 
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
  retry_rom_blk_mem_gen_v8_4_5 U0
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
wLwIXD13
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
