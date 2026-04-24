#==============================================================================
# pins.xdc  --  Week 2 Day 4  HDMI piano (top = mb_usb_hdmi_top)
# Board: Urbana  (Spartan-7 XC7S50)
#==============================================================================

# ---- 100 MHz 时钟 (Urbana N15) ----
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {Clk}]
# BD 内的 clk_wiz 会自动加 create_clock, 这里不要再手动加, 否则会冲突

# ---- Bank / 配置 ----
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.Config.SPI_buswidth 4 [current_design]

# ---- Reset 按钮 (btn[0] = 中间那个按键) ----
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS25} [get_ports {reset_rtl_0}]

#==============================================================================
# USB HID (MAX3421E)  <-- 这 6 行从你 Day 1-3 能跑 USB 的那份 XDC 里抄
#   端口名必须和 top 里一致, pin 号照你 working 的那份照抄, 不要改.
#==============================================================================
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports usb_spi_sclk]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports usb_spi_mosi]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports usb_spi_miso]
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33} [get_ports {usb_spi_ss[0]}]

set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {gpio_usb_rst_tri_o[0]}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {gpio_usb_int_tri_i[0]}]

#==============================================================================
# UART  (Urbana USB-UART bridge)
#==============================================================================
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {uart_rtl_0_rxd}]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {uart_rtl_0_txd}]

#==============================================================================
# HDMI (TMDS 差分)
#==============================================================================
set_property -dict {PACKAGE_PIN V17 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_clk_n}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_clk_p}]

set_property -dict {PACKAGE_PIN U18 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_data_n[0]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_data_n[1]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_data_n[2]}]

set_property -dict {PACKAGE_PIN U17 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_data_p[0]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_data_p[1]}]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_data_p[2]}]

#==============================================================================
# 7-Segment display 0  →  hex_segB / hex_gridB  (显示 keymask 低 8 bits)
#==============================================================================
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS25} [get_ports {hex_gridB[0]}]
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS25} [get_ports {hex_gridB[1]}]
set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVCMOS25} [get_ports {hex_gridB[2]}]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS25} [get_ports {hex_gridB[3]}]

set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS25} [get_ports {hex_segB[0]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS25} [get_ports {hex_segB[1]}]
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS25} [get_ports {hex_segB[2]}]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS25} [get_ports {hex_segB[3]}]
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS25} [get_ports {hex_segB[4]}]
set_property -dict {PACKAGE_PIN D6 IOSTANDARD LVCMOS25} [get_ports {hex_segB[5]}]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS25} [get_ports {hex_segB[6]}]
set_property -dict {PACKAGE_PIN B5 IOSTANDARD LVCMOS25} [get_ports {hex_segB[7]}]

#==============================================================================
# 7-Segment display 1  →  hex_segA / hex_gridA  (显示 keymask 高 8 bits)
#==============================================================================
set_property -dict {PACKAGE_PIN E4 IOSTANDARD LVCMOS25} [get_ports {hex_gridA[0]}]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS25} [get_ports {hex_gridA[1]}]
set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS25} [get_ports {hex_gridA[2]}]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS25} [get_ports {hex_gridA[3]}]

set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS25} [get_ports {hex_segA[0]}]
set_property -dict {PACKAGE_PIN G5 IOSTANDARD LVCMOS25} [get_ports {hex_segA[1]}]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS25} [get_ports {hex_segA[2]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS25} [get_ports {hex_segA[3]}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS25} [get_ports {hex_segA[4]}]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS25} [get_ports {hex_segA[5]}]
set_property -dict {PACKAGE_PIN E5 IOSTANDARD LVCMOS25} [get_ports {hex_segA[6]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS25} [get_ports {hex_segA[7]}]

#==============================================================================
# PDM 音频 (Lab 6 XDC 原来叫 spkl / spkr)
#==============================================================================
set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports {audio_pdm_out}]
set_property -dict {PACKAGE_PIN B14 IOSTANDARD LVCMOS33} [get_ports {audio_pdm_r}]
