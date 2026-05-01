#================================================================
# dds_pdm.tcl  --  Driver TCL script for the dds_pdm AXI IP.
# Called by Vitis during BSP generation. We don't do anything fancy,
# just generate the standard xparameters.h entries (automatic).
#================================================================

proc generate {drv_handle} {
    ::hsi::utils::define_include_file $drv_handle "xparameters.h" "dds_pdm" \
        "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR"
}
