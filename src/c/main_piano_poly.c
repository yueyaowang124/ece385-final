//=============================================================================
// main_piano_poly.c  -  Week 2 Day 2：4 声道复音 piano
//
// 功能：
//   - 轮询 SW[0:15]（通过 AXI GPIO）
//   - 找出最多 4 个拨起的开关，分别放到 4 个 DDS 声道
//   - 多开关同时拨 → 真·硬件复音（不是软件混音）
//
// 寄存器 (新版 dds_pdm / dds_mixer_axi IP)：
//   0x00  phase_inc_0  voice 0
//   0x04  phase_inc_1  voice 1
//   0x08  phase_inc_2  voice 2
//   0x0C  phase_inc_3  voice 3
//   0x10  enable       bit0 = master enable
//
// 键位：
//   SW[0]=C4  SW[1]=D4  SW[2]=E4  SW[3]=F4
//   SW[4]=G4  SW[5]=A4  SW[6]=B4  SW[7]=C5
//   SW[8]=D5  SW[9]=E5  SW[10]=F5 SW[11]=G5
//   SW[12]=A5 SW[13]=B5 SW[14]=C6 SW[15]=D6
//
//   中检现场演示："按 SW[0] + SW[2] + SW[4]" → 听到 C major 和弦 (CEG)
//=============================================================================
#include "xparameters.h"
#include "xil_io.h"

//------------------------------------------------------
// 硬件基地址
//------------------------------------------------------
#define DDS_BASE        0x44A00000
#define REG_PHASE_0     0x00
#define REG_PHASE_1     0x04
#define REG_PHASE_2     0x08
#define REG_PHASE_3     0x0C
#define REG_ENABLE      0x10

#ifdef XPAR_AXI_GPIO_0_BASEADDR
  #define GPIO_BASE  XPAR_AXI_GPIO_0_BASEADDR
#elif defined(XPAR_GPIO_0_BASEADDR)
  #define GPIO_BASE  XPAR_GPIO_0_BASEADDR
#else
  #define GPIO_BASE  0x40000000
#endif

//------------------------------------------------------
// phase_inc 查表 (f * 2^32 / 100_000_000)
//------------------------------------------------------
#define INC_SILENCE  0
static const unsigned int PHASE_INC_TABLE[16] = {
    11236,  // C4
    12607,  // D4
    14157,  // E4
    14999,  // F4
    16838,  // G4
    18897,  // A4
    21213,  // B4
    22473,  // C5
    25215,  // D5
    28314,  // E5
    29998,  // F5
    33676,  // G5
    37795,  // A5
    42426,  // B5
    44947,  // C6
    50430   // D6
};

//------------------------------------------------------
// I/O
//------------------------------------------------------
static inline unsigned int read_switches(void) {
    return Xil_In32(GPIO_BASE) & 0xFFFF;
}

static inline void set_voice(int v, unsigned int inc) {
    Xil_Out32(DDS_BASE + (v * 4), inc);  // 0x00, 0x04, 0x08, 0x0C
}

static void delay_us(int us) {
    volatile int i;
    for (i = 0; i < us * 20; i++) asm volatile ("nop");
}

//------------------------------------------------------
// 把 16-bit switch mask → 4 个 phase_inc (最多前 4 个置位)
//------------------------------------------------------
static void dispatch_voices(unsigned int sw, unsigned int out[4]) {
    int count = 0;
    for (int i = 0; i < 16 && count < 4; i++) {
        if (sw & (1u << i)) {
            out[count++] = PHASE_INC_TABLE[i];
        }
    }
    // 其余声道静音
    while (count < 4) out[count++] = INC_SILENCE;
}

//------------------------------------------------------
// main
//------------------------------------------------------
int main(void) {
    // 静音初始化
    set_voice(0, INC_SILENCE);
    set_voice(1, INC_SILENCE);
    set_voice(2, INC_SILENCE);
    set_voice(3, INC_SILENCE);
    Xil_Out32(DDS_BASE + REG_ENABLE, 1);   // master enable

    // 上电小演示：C-E-G 同时响 500ms（证明硬件 mixer 工作）
    set_voice(0, PHASE_INC_TABLE[0]);  // C4
    set_voice(1, PHASE_INC_TABLE[2]);  // E4
    set_voice(2, PHASE_INC_TABLE[4]);  // G4
    delay_us(500000);
    set_voice(0, INC_SILENCE);
    set_voice(1, INC_SILENCE);
    set_voice(2, INC_SILENCE);

    unsigned int last[4] = {0, 0, 0, 0};

    while (1) {
        unsigned int sw = read_switches();
        unsigned int voices[4];
        dispatch_voices(sw, voices);

        for (int i = 0; i < 4; i++) {
            if (voices[i] != last[i]) {
                set_voice(i, voices[i]);
                last[i] = voices[i];
            }
        }

        delay_us(1000);
    }
    return 0;
}
