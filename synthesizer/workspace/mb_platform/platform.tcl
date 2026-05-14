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
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains standalone_domain 
platform generate -domains standalone_domain 
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains standalone_domain 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
bsp reload
bsp setlib -name xilffs -ver 4.8
bsp write
bsp reload
catch {bsp regenerate}
platform generate -domains standalone_domain 
platform clean
platform generate
bsp reload
bsp write
platform generate -domains 
platform clean
platform generate
bsp write
platform generate -domains 
platform clean
platform generate
bsp reload
platform clean
platform generate
platform clean
platform generate
bsp removelib -name xilffs
bsp write
bsp reload
catch {bsp regenerate}
bsp setlib -name xilffs -ver 4.8
bsp write
bsp reload
catch {bsp regenerate}
platform generate -domains standalone_domain 
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
bsp config use_lfn "0"
bsp config use_strfunc "0"
bsp config use_chmod "false"
bsp config use_mkfs "false"
bsp write
bsp reload
catch {bsp regenerate}
platform generate -domains standalone_domain 
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
bsp config enable_multi_partition "false"
bsp config fs_interface "1"
bsp config use_chmod "false"
bsp config use_lfn "0"
bsp config use_strfunc "1"
bsp write
bsp reload
catch {bsp regenerate}
platform generate -domains standalone_domain 
platform clean
platform generate
platform clean
platform generate
platform active {mb_platform}
bsp reload
bsp config fs_interface "1"
bsp config use_lfn "0"
bsp config use_strfunc "1"
bsp write
platform generate -domains 
catch {bsp regenerate}
bsp reload
catch {bsp regenerate}
bsp removelib -name xilffs
bsp setlib -name xilffs -ver 4.8
bsp write
bsp reload
catch {bsp regenerate}
bsp write
platform generate -domains standalone_domain 
platform active {mb_platform}
bsp reload
bsp write
platform generate -domains 
platform clean
bsp config use_strfunc "0"
bsp write
bsp reload
catch {bsp regenerate}
platform generate
bsp reload
platform generate -domains standalone_domain 
bsp write
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform active {mb_platform}
bsp reload
platform generate -domains standalone_domain 
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
bsp removelib -name xilffs
bsp write
bsp reload
catch {bsp regenerate}
platform generate -domains standalone_domain 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
bsp reload
bsp write
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform clean
platform generate
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform clean
platform generate
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform clean
platform generate
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
platform active {mb_platform}
platform config -updatehw {D:/ece385/final/ece385-final/synthesizer/mb_usb_hdmi_top.xsa}
platform generate -domains 
