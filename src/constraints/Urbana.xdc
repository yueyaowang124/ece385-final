
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {Clk}]


set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS25} [get_ports {reset_rtl_0}]

set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {uart_rtl_0_txd}]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {uart_rtl_0_rxd}]


set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {usb_spi_miso}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {usb_spi_mosi}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {usb_spi_sclk}]
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33} [get_ports {usb_spi_ss}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {gpio_usb_rst_tri_o}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {gpio_usb_int_tri_i}]

set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports {spkl}]
set_property -dict {PACKAGE_PIN B14 IOSTANDARD LVCMOS33} [get_ports {spkr}]

set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS25} [get_ports {hex_gridA[0]}]
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS25} [get_ports {hex_gridA[1]}]
set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVCMOS25} [get_ports {hex_gridA[2]}]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS25} [get_ports {hex_gridA[3]}]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS25} [get_ports {hex_segA[0]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS25} [get_ports {hex_segA[1]}]
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS25} [get_ports {hex_segA[2]}]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS25} [get_ports {hex_segA[3]}]
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS25} [get_ports {hex_segA[4]}]
set_property -dict {PACKAGE_PIN D6 IOSTANDARD LVCMOS25} [get_ports {hex_segA[5]}]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS25} [get_ports {hex_segA[6]}]
set_property -dict {PACKAGE_PIN B5 IOSTANDARD LVCMOS25} [get_ports {hex_segA[7]}]

set_property -dict {PACKAGE_PIN E4 IOSTANDARD LVCMOS25} [get_ports {hex_gridB[0]}]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS25} [get_ports {hex_gridB[1]}]
set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS25} [get_ports {hex_gridB[2]}]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS25} [get_ports {hex_gridB[3]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS25} [get_ports {hex_segB[0]}]
set_property -dict {PACKAGE_PIN G5 IOSTANDARD LVCMOS25} [get_ports {hex_segB[1]}]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS25} [get_ports {hex_segB[2]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS25} [get_ports {hex_segB[3]}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS25} [get_ports {hex_segB[4]}]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS25} [get_ports {hex_segB[5]}]
set_property -dict {PACKAGE_PIN E5 IOSTANDARD LVCMOS25} [get_ports {hex_segB[6]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS25} [get_ports {hex_segB[7]}]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.Config.SPI_buswidth 4 [current_design]