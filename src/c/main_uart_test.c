//=============================================================================
// main_uart_test.c  -  混合诊断
//
// 先开 A4，确保有声音 → 然后才尝试 printf
// 这样能区分"printf 卡死"和"printf 输出但没看到"两种情况
//=============================================================================
#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"

#define DDS_HARDCODED_BASE   0x44A00000

int main(void) {
    // === Phase 1: 立刻开 A4，不依赖任何 printf ===
    Xil_Out32(DDS_HARDCODED_BASE + 0x00, 18897);  // A4 phase inc
    Xil_Out32(DDS_HARDCODED_BASE + 0x08, 1);       // enable

    // 此时耳机里应该已经在响 A4 了

    // === Phase 2: 尝试 printf ===
    // 如果 UART 完全卡死，这一行会 hang，但 A4 还在响（PDM 是纯硬件）
    // 如果 UART 工作但 STDOUT 没设对，这一行会立刻返回但没东西出现
    xil_printf("\r\nIf you see this, UART works!\r\n");

    // === Phase 3: 切换音调验证 printf 之后 CPU 还活着 ===
    // 如果上面 printf 卡死了，这里永远到不了 → 一直是 A4
    // 如果 printf 没卡，这里会切到一个明显不同的音 (200 Hz, 比 A4 低很多)
    Xil_Out32(DDS_HARDCODED_BASE + 0x00, 8590);   // 200 Hz, 低音

    xil_printf("Now playing 200 Hz...\r\n");

    while (1) { }
    return 0;
}
