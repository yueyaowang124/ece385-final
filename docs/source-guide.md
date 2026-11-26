# Final Source Guide

The archived final commit is `a28930babf5440e1bf36bfb2f001f685ab2b1327` (`final`).

## Hardware

Open `synthesizer/synthesizer.xpr` in Vivado. The project targets `xc7s50csga324-1` and selects `mb_usb_hdmi_top` as the synthesis top.

The final renderer is `synthesizer/synthesizer.srcs/sources_1/imports/hdl/piano_display2.sv`. The project also references source files in `ip_repo/` and `src/`; preserve these paths when working with the archive.

## Firmware

The final application is `synthesizer/workspace/synthesizer/src/main_piano_usb_hdmi.c`. Do not confuse it with the earlier same-name file in `src/c/`.

The Vitis platform and generated BSP provide hardware-dependent headers such as `xparameters.h`. A standalone copy of the C application is not sufficient to rebuild the software.

## Graphics assets

The final renderer uses palette-indexed ROMs. Each COE image and its palette module must be kept together. The course submission ZIP and the final Git commit contain different fish image/palette data; confirm the intended pair before replacing either file.

## Reproduction status

These paths document the archived implementation. They are not a validated clean-build procedure. Exact Vivado/Vitis versions and end-to-end build instructions remain to be documented after a successful rebuild.
