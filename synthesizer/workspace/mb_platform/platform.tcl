# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct D:\ece385\final\ece385-final\synthesizer\workspace\mb_platform\platform.tcl
# 
# OR launch xsct and run below command.
# source D:\ece385\final\ece385-final\synthesizer\workspace\mb_platform\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {mb_platform}\
-hw {D:\ece385\final\ece385-final\synthesizer\mb_block_wrapper.xsa}\
-proc {microblaze_0} -os {standalone} -out {D:/ece385/final/ece385-final/synthesizer/workspace}

platform write
platform generate -domains 
platform active {mb_platform}
platform clean
platform clean
platform clean
platform clean
platform clean
platform clean
platform generate
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_block_wrapper.xsa}
platform clean
platform active {mb_platform}
platform clean
platform generate
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_block_wrapper.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_block_wrapper.xsa}
platform generate -domains 
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_block_wrapper.xsa}
platform generate -domains 
platform clean
platform generate
platform active {mb_platform}
bsp reload
bsp config stdout "axi_uartlite_0"
bsp config stdin "axi_uartlite_0"
bsp write
bsp reload
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_block_wrapper.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_block_wrapper.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_block_wrapper.xsa}
