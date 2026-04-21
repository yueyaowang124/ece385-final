#=============================================================================
# merged_pins.xdc - Combined Constraints for Audio and USB/HDMI
#=============================================================================

#-----------------------------------------------------------------------------
# 系统时钟与基本 IO (来自 pins.xdc)
#-----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports Clk]
create_clock -period 10.000 -name clk_100 -waveform {0.000 5.000} [get_ports Clk]

set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS25} [get_ports reset_rtl_0]

# UART (注意：pins.xdc 与 mb_usb_hdmi_top.xdc 的 A16/B16 定义略有不同，以 pins.xdc 为准)
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports uart_rtl_0_rxd]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports uart_rtl_0_txd]

#-----------------------------------------------------------------------------
# USB 物理接口 (MAX3421E SPI 连接)
#-----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {gpio_usb_int_tri_i[0]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports usb_spi_sclk]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports usb_spi_mosi]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports usb_spi_miso]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports usb_spi_ss]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {gpio_usb_rst_tri_o[0]}]

#-----------------------------------------------------------------------------
# 音频 PDM 输出 (来自 pins.xdc)
#-----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports audio_pdm_out]
set_property -dict {PACKAGE_PIN B14 IOSTANDARD LVCMOS33} [get_ports audio_pdm_r]

#-----------------------------------------------------------------------------
# HDMI 信号 (来自 mb_usb_hdmi_top.xdc)
#-----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN V17   IOSTANDARD TMDS_33 } [get_ports {hdmi_tmds_clk_n}]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD TMDS_33 } [get_ports {hdmi_tmds_clk_p}]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD TMDS_33 } [get_ports {hdmi_tmds_data_n[0]}]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD TMDS_33 } [get_ports {hdmi_tmds_data_n[1]}]
set_property -dict { PACKAGE_PIN T18   IOSTANDARD TMDS_33 } [get_ports {hdmi_tmds_data_n[2]}]
set_property -dict { PACKAGE_PIN U17   IOSTANDARD TMDS_33 } [get_ports {hdmi_tmds_data_p[0]}]
set_property -dict { PACKAGE_PIN R16   IOSTANDARD TMDS_33 } [get_ports {hdmi_tmds_data_p[1]}]
set_property -dict { PACKAGE_PIN R18   IOSTANDARD TMDS_33 } [get_ports {hdmi_tmds_data_p[2]}]

#-----------------------------------------------------------------------------
# 七段数码管 (来自 mb_usb_hdmi_top.xdc)
#-----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS25} [get_ports {hex_gridA[0]}]
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS25} [get_ports {hex_gridA[1]}]
set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVCMOS25} [get_ports {hex_gridA[2]}]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS25} [get_ports {hex_gridA[3]}]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS25} [get_ports {hex_segA[0]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS25} [get_ports {hex_segA[1]}]
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS25} [get_ports {hex_segA[2]}]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS25} [get_ports {hex_segA[3]}]
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS25} [get_ports {hex_segA[4]}]
set_property -dict {PACKAGE_PIN D8 IOSTANDARD LVCMOS25} [get_ports {hex_segA[5]}]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS25} [get_ports {hex_segA[6]}]
set_property -dict {PACKAGE_PIN C8 IOSTANDARD LVCMOS25} [get_ports {hex_segA[7]}]

#-----------------------------------------------------------------------------
# 板载开关 SW[0:15] (来自 pins.xdc)
#-----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[0]}]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[1]}]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[2]}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[3]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[4]}]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[5]}]
set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[6]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[7]}]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[8]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[9]}]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[10]}]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[11]}]
set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[12]}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[13]}]
set_property -dict {PACKAGE_PIN A1 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[14]}]
set_property -dict {PACKAGE_PIN A2 IOSTANDARD LVCMOS25} [get_ports {SW_tri_i[15]}]

#-----------------------------------------------------------------------------
# Bitstream 属性 (来自 pins.xdc)
#-----------------------------------------------------------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.Config.SPI_buswidth 4 [current_design]
set_property BITSTREAM.CONFIG.UNUSED_PIN Pullup [current_design]