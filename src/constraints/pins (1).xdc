#=============================================================================
# pins.xdc  -  Constraints for Week 1 Audio Test on Urbana Board
#
# Physical pins extracted from Urbana.xdc reference.
#
# Ports (must match the external port names in your block design wrapper):
#   clk_100MHz        <- 100 MHz oscillator (N15)
#   reset_rtl         <- BTN[0] reset button (J2, active HIGH when pressed)
#   uart_rtl_0_rxd    <- USB-UART RXD (A16)
#   uart_rtl_0_txd    <- USB-UART TXD (B16)
#   audio_pdm_out     <- left speaker / headphone (SPKL, B13)
#   audio_pdm_r       <- right speaker / headphone (SPKR, B14)  [optional]
#
# IMPORTANT: After generating the HDL wrapper, open
# <project>.srcs/sources_1/bd/mb_block/hdl/mb_block_wrapper.v
# and confirm the module port names match EXACTLY. If not, either:
#   (a) rename the external ports in your block design to match this file, or
#   (b) rename the ports below to match the wrapper.
#=============================================================================

#=============================================================================
# Bank voltages and bitstream config
#=============================================================================
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.Config.SPI_buswidth 4 [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLUP [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

#=============================================================================
# 100 MHz System Clock (single-ended oscillator)
#=============================================================================
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {clk_100MHz}]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} \
    -add [get_ports {clk_100MHz}]

#=============================================================================
# Reset: use BTN[0] at J2 (active HIGH when pressed)
#=============================================================================
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS25} [get_ports {reset_rtl}]

#=============================================================================
# UART (USB-UART bridge on board)
#=============================================================================
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {uart_rtl_0_rxd}]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {uart_rtl_0_txd}]

#=============================================================================
# Audio Out (3.5mm jack)  --  PDM / PWM one-bit stream
#   SPKL = B13 (left channel)
#   SPKR = B14 (right channel)
# We drive both with the same mono signal so both earbuds play sound.
#=============================================================================
set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports {audio_pdm_out}]
set_property -dict {PACKAGE_PIN B14 IOSTANDARD LVCMOS33} [get_ports {audio_pdm_r}]

#=============================================================================
# (Optional) LED[0] on C13 as a "design alive" indicator.
# Only uncomment if you expose a 'led_alive' external port in your BD.
#=============================================================================
# set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports {led_alive}]
#=============================================================================
# 16 on-board slide switches SW[0:15] as piano keys
#=============================================================================
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS25} [get_ports {SW[0]}]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS25} [get_ports {SW[1]}]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS25} [get_ports {SW[2]}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS25} [get_ports {SW[3]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS25} [get_ports {SW[4]}]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS25} [get_ports {SW[5]}]
set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS25} [get_ports {SW[6]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS25} [get_ports {SW[7]}]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS25} [get_ports {SW[8]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS25} [get_ports {SW[9]}]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS25} [get_ports {SW[10]}]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS25} [get_ports {SW[11]}]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS25} [get_ports {SW[12]}]
set_property -dict {PACKAGE_PIN A7 IOSTANDARD LVCMOS25} [get_ports {SW[13]}]
set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS25} [get_ports {SW[14]}]
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS25} [get_ports {SW[15]}]