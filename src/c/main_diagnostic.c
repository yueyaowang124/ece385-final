//=============================================================================
// main_diagnostic.c  -  Minimal diagnostic program
//
// 这个版本完全不用 UART，也不用 sleep()，只做最基本的事：
//   1. 用硬编码的基址写 DDS 寄存器
//   2. 死循环
//
// 如果这个版本能听到 A4：
//   → MB 在跑、AXI 写能到 DDS、PDM 到引脚正常
//   → 原版 main.c 的问题出在 UART 或 printf
//
// 如果这个版本也听不到 A4 (还是白噪)：
//   → MB 根本没运行，或 AXI 写没生效
//   → 问题在 BD 接线 / reset / 地址映射
//=============================================================================
#include "xparameters.h"
#include "xil_io.h"

// 注意：这里用的是"硬编码地址"，不依赖 XPAR 宏名
// 从你的 Address Editor 截图看到 dds_pdm_0 基址是 0x44A0_0000
#define DDS_HARDCODED_BASE   0x44A00000

int main(void) {
    // 写相位增量：A4 = 440 Hz at 100 MHz clock
    // phase_inc = 440 * 2^32 / 1e8 = 18897
    Xil_Out32(DDS_HARDCODED_BASE + 0x00, 18897);

    // 使能
    Xil_Out32(DDS_HARDCODED_BASE + 0x08, 1);

    // 死循环
    while (1) {
        // 什么都不做，让 DDS 持续输出 A4
    }

    return 0;
}
