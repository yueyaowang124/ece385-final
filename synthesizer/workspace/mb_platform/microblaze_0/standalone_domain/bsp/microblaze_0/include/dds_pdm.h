/*****************************************************************************
 * dds_pdm.h  --  Minimal driver header for the dds_pdm AXI IP.
 *
 * We don't actually need a software driver (we just use Xil_In32/Xil_Out32
 * directly in main.c). This file exists only so the Vitis BSP build has
 * something to compile for the drivers/dds_pdm_v1_0/ folder.
 *
 * Register offsets (matches the AXI4-Lite slave register map):
 *   0x00 : phase_increment  (uint32)
 *   0x04 : wave_select      (reserved)
 *   0x08 : enable           (bit 0)
 *   0x0C : volume           (reserved)
 *****************************************************************************/
#ifndef DDS_PDM_H
#define DDS_PDM_H

#include "xil_io.h"
#include "xil_types.h"

#define DDS_PDM_REG_PHASE_INC_OFFSET  0x00
#define DDS_PDM_REG_WAVE_SEL_OFFSET   0x04
#define DDS_PDM_REG_ENABLE_OFFSET     0x08
#define DDS_PDM_REG_VOLUME_OFFSET     0x0C

#define DDS_PDM_mWriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

#define DDS_PDM_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

#endif /* DDS_PDM_H */
