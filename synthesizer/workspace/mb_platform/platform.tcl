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
-hw {D:\ece385\final\ece385-final\synthesizer\mb_usb_hdmi_top.xsa}\
-proc {microblaze_0} -os {standalone} -out {D:/ece385/final/ece385-final/synthesizer/workspace}

platform write
platform generate -domains 
platform active {mb_platform}
platform generate
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/synthesizer_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/synthesizer_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/synthesizer_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/synthesizer_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
