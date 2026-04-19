//=============================================================================
// main_demo.c  -  Week 1 音频 demo（不依赖 UART）
//
// 演示效果：
//   1. 上电立即播 A4 (440 Hz) 持续 2 秒
//   2. 循环播 C-E-G-A (C major 琶音) 每音 0.5 秒
//   3. 按 BTN[0] 会重置 → 从头开始
//
// 中检展示点：
//   - 有音（证明 FPGA bitstream + PDM 硬件工作）
//   - 音高变化（证明 MicroBlaze 在跑 C 代码）
//   - 音调准确（C-E-G-A 和弦，证明 phase_inc 计算正确）
//=============================================================================
#include "xparameters.h"
#include "xil_io.h"

#define DDS_BASE    0x44A00000  // dds_pdm_0 base (from Address Editor)

#define REG_PHASE_INC  0x00
#define REG_ENABLE     0x08

// 相位增量 = f * 2^32 / 100_000_000
#define INC_SILENCE    0
#define INC_C4         11236   // 261.6 Hz
#define INC_E4         14157   // 329.6 Hz
#define INC_G4         16838   // 392.0 Hz
#define INC_A4         18897   // 440.0 Hz
#define INC_C5         22473   // 523.3 Hz
#define INC_E5         28314   // 659.3 Hz
#define INC_G5         33676   // 784.0 Hz
#define INC_A5         37795   // 880.0 Hz

// 忙等延迟：100 MHz 下，一次循环大约 3-5 条指令
// 每个 count 约等于 30-50 ns
static void delay_ms(int ms) {
    volatile int i;
    // 大约 ~2e6 count/s，所以 ms 数要乘 20000
    for (i = 0; i < ms * 20000; i++) {
        asm volatile ("nop");  // 防止编译器优化掉
    }
}

int main(void) {
    // 使能 DDS
    Xil_Out32(DDS_BASE + REG_ENABLE, 1);

    // === Phase 1: A4 持续 2 秒 ===
    Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_A4);
    delay_ms(2000);

    // === Phase 2: 循环 C major 琶音 ===
    while (1) {
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_C4); delay_ms(500);
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_E4); delay_ms(500);
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_G4); delay_ms(500);
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_A4); delay_ms(500);

        // 高八度再来一次，做"转调"效果
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_C5); delay_ms(500);
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_E5); delay_ms(500);
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_G5); delay_ms(500);
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_A5); delay_ms(500);

        // 回低八度
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_A4); delay_ms(500);
        Xil_Out32(DDS_BASE + REG_PHASE_INC, INC_SILENCE); delay_ms(200);
    }
    return 0;
}
