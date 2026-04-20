//=============================================================================
// main_piano.c  -  Week 1 Day 1：16 拨码开关当 16 个琴键
//
// 功能：
//   - 轮询 AXI_GPIO 上的 SW[0:15]
//   - 拨起任意一个 switch，通过 DDS 播出对应的音高
//   - 多个开关同时拨 → 播最低位那个（Day 2 换成硬件 mixer 做和弦）
//   - 全部拨下 → 静音
//
// 硬件映射（16 键覆盖 C4..D6，两个八度 C 大调）：
//   SW[0]=C4   SW[1]=D4   SW[2]=E4   SW[3]=F4
//   SW[4]=G4   SW[5]=A4   SW[6]=B4   SW[7]=C5
//   SW[8]=D5   SW[9]=E5   SW[10]=F5  SW[11]=G5
//   SW[12]=A5  SW[13]=B5  SW[14]=C6  SW[15]=D6
//
// 寄存器：
//   DDS  0x44A00000:  +0x00 phase_inc,  +0x08 enable
//   GPIO 0x40000000:  +0x00 GPIO_DATA (读 SW[15:0])
//   ↑ GPIO 地址以 Address Editor 实际分配为准，下面 GPIO_BASE 可能要改
//=============================================================================
#include "xparameters.h"
#include "xil_io.h"

//------------------------------------------------------
// 硬件基地址
//------------------------------------------------------
// DDS 用硬编码（你之前 xparameters 宏名字总是变）
#define DDS_BASE        0x44A00000
#define REG_PHASE_INC   0x00
#define REG_ENABLE      0x08

// AXI GPIO：优先用 xparameters 宏，如果宏名不同把下面的 fallback 也改掉
#ifdef XPAR_AXI_GPIO_0_BASEADDR
  #define GPIO_BASE  XPAR_AXI_GPIO_0_BASEADDR
#elif defined(XPAR_GPIO_0_BASEADDR)
  #define GPIO_BASE  XPAR_GPIO_0_BASEADDR
#else
  // 如果编译时宏没找到，手动填 Address Editor 里看到的那个值
  #define GPIO_BASE  0x40000000
#endif
#define REG_GPIO_DATA   0x00

//------------------------------------------------------
// phase_inc 查表：inc = f * 2^32 / 100_000_000
//------------------------------------------------------
#define INC_SILENCE  0
static const unsigned int PHASE_INC_TABLE[16] = {
    11236,  // SW[0]  C4   261.6 Hz
    12607,  // SW[1]  D4   293.7 Hz
    14157,  // SW[2]  E4   329.6 Hz
    14999,  // SW[3]  F4   349.2 Hz
    16838,  // SW[4]  G4   392.0 Hz
    18897,  // SW[5]  A4   440.0 Hz
    21213,  // SW[6]  B4   493.9 Hz
    22473,  // SW[7]  C5   523.3 Hz
    25215,  // SW[8]  D5   587.3 Hz
    28314,  // SW[9]  E5   659.3 Hz
    29998,  // SW[10] F5   698.5 Hz
    33676,  // SW[11] G5   784.0 Hz
    37795,  // SW[12] A5   880.0 Hz
    42426,  // SW[13] B5   987.8 Hz
    44947,  // SW[14] C6  1046.5 Hz
    50430   // SW[15] D6  1174.7 Hz
};

//------------------------------------------------------
// 小工具
//------------------------------------------------------
static inline unsigned int read_switches(void) {
    // AXI GPIO DATA 寄存器：低 16 bit 就是 SW[15:0]
    return Xil_In32(GPIO_BASE + REG_GPIO_DATA) & 0xFFFF;
}

static inline void set_dds(unsigned int inc) {
    Xil_Out32(DDS_BASE + REG_PHASE_INC, inc);
}

// 找最低置位的 switch index；全 0 返回 -1
static int lowest_set_bit(unsigned int v) {
    if (v == 0) return -1;
    int i;
    for (i = 0; i < 16; i++) {
        if (v & (1u << i)) return i;
    }
    return -1;
}

// 忙等延迟：~50ns / loop @ 100 MHz
static void delay_us(int us) {
    volatile int i;
    for (i = 0; i < us * 20; i++) {
        asm volatile ("nop");
    }
}

//------------------------------------------------------
// main
//------------------------------------------------------
int main(void) {
    // 上电先使能 DDS 但不发声
    Xil_Out32(DDS_BASE + REG_ENABLE, 1);
    set_dds(INC_SILENCE);

    // 上电"欢迎音"：A4 响 300ms，证明板子活着
    set_dds(18897);
    delay_us(300000);
    set_dds(INC_SILENCE);

    unsigned int last_inc = INC_SILENCE;

    while (1) {
        unsigned int sw = read_switches();
        int key = lowest_set_bit(sw);

        unsigned int inc = (key < 0) ? INC_SILENCE : PHASE_INC_TABLE[key];

        // 只在音高变化时写寄存器，避免 click 噪声
        if (inc != last_inc) {
            set_dds(inc);
            last_inc = inc;
        }

        // ~1 ms 轮询间隔，绰绰有余
        delay_us(1000);
    }
    return 0;
}
