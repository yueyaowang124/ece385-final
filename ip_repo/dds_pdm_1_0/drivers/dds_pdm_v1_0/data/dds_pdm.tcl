

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "dds_pdm" "NUM_INSTANCES" "DEVICE_ID"  "C_dds_pdm_BASEADDR" "C_dds_pdm_HIGHADDR"
}
