# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: D:\ece385\final\ece385-final\synthesizer\workspace\synthesizer_system\_ide\scripts\debugger_synthesizer-default.tcl
# 
# 
# Usage with xsct:
# In an external shell use the below command and launch symbol server.
# symbol_server.bat -S -s tcp::1534
# To debug using xsct, launch xsct and run below command
# source D:\ece385\final\ece385-final\synthesizer\workspace\synthesizer_system\_ide\scripts\debugger_synthesizer-default.tcl
# 
connect -path [list tcp::1534 tcp:localhost:3121]
targets -set -filter {jtag_cable_name =~ "RealDigital Boo 8874042400A4A" && level==0 && jtag_device_ctx=="jsn2-0362f093-0"}
fpga -file D:/ece385/final/ece385-final/synthesizer/workspace/synthesizer/_ide/bitstream/synthesizer_top.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw D:/ece385/final/ece385-final/synthesizer/workspace/mb_platform/export/mb_platform/hw/synthesizer_top.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow D:/ece385/final/ece385-final/synthesizer/workspace/synthesizer/Debug/synthesizer.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con
