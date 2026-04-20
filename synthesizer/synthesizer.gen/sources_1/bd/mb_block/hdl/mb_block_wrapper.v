//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
//Date        : Sat Apr 18 23:56:10 2026
//Host        : Usuallll running 64-bit major release  (build 9200)
//Command     : generate_target mb_block_wrapper.bd
//Design      : mb_block_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module mb_block_wrapper
   (SW_tri_i,
    audio_pdm_out,
    audio_pdm_r,
    clk_100MHz,
    reset_rtl,
    uart_rtl_0_rxd,
    uart_rtl_0_txd);
  input [15:0]SW_tri_i;
  output audio_pdm_out;
  output audio_pdm_r;
  input clk_100MHz;
  input reset_rtl;
  input uart_rtl_0_rxd;
  output uart_rtl_0_txd;

  wire [15:0]SW_tri_i;
  wire audio_pdm_out;
  wire audio_pdm_r;
  wire clk_100MHz;
  wire reset_rtl;
  wire uart_rtl_0_rxd;
  wire uart_rtl_0_txd;

  mb_block mb_block_i
       (.SW_tri_i(SW_tri_i),
        .audio_pdm_out(audio_pdm_out),
        .audio_pdm_r(audio_pdm_r),
        .clk_100MHz(clk_100MHz),
        .reset_rtl(reset_rtl),
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd));
endmodule
