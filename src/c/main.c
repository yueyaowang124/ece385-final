//=============================================================================
// main.c  -  Week 1 audio test program
//
// Writes a phase increment to the dds_pdm IP's AXI registers to make
// the 3.5mm audio jack play a 440 Hz square wave (note A4).
//
// REG MAP (offsets):
//   0x00 : phase_increment  (uint32)
//   0x04 : reserved (wave_select for future use)
//   0x08 : enable           (bit 0)
//   0x0C : reserved (volume for future use)
//=============================================================================
#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "sleep.h"

// NOTE: replace this with whatever name shows up in xparameters.h after you
// generate your hardware. It will look something like:
//   XPAR_DDS_PDM_V1_0_0_S00_AXI_BASEADDR
//   XPAR_DDS_PDM_0_BASEADDR
// Search xparameters.h for "DDS" to find the right macro.
#define DDS_BASE   XPAR_DDS_PDM_0_S00_AXI_BASEADDR

#define REG_PHASE_INC  0x00
#define REG_WAVE_SEL   0x04
#define REG_ENABLE     0x08
#define REG_VOLUME     0x0C

// At 100 MHz clock, phase_inc = f * 2^32 / 1e8
// 440 Hz  (A4) = 18897
// 261.6Hz (C4) = 11236
// 329.6Hz (E4) = 14157
// 392.0Hz (G4) = 16838
#define INC_A4   18897
#define INC_C4   11236
#define INC_E4   14157
#define INC_G4   16838

int main(void) {
    xil_printf("\r\n=== Week 1 Audio Test ===\r\n");
    xil_printf("DDS_BASE = 0x%08X\r\n", DDS_BASE);

    // Step 1: just play A4 forever. Plug in headphones, you should hear it.
    Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_A4);
    Xil_Out32(DDS_BASE + REG_ENABLE,    1);
    xil_printf("Playing A4 (440 Hz)...\r\n");

    // Step 2 (optional): cycle through C-E-G-A every second to confirm
    // frequency control works.
    while (1) {
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_C4); sleep(1);
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_E4); sleep(1);
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_G4); sleep(1);
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_A4); sleep(1);
    }
    return 0;
}