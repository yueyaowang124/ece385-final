//=============================================================================
// main_piano_usb.c  -  Week 2 Day 3：USB 键盘弹钢琴（复音）
//
// 数据流：
//   USB 键盘 → MAX3421E → SPI → MicroBlaze → kbdPoll() 解析 BOOT_KBD_REPORT
//   → 查表 keycode_to_phase_inc → 写 DDS 4 个声道 phase_inc 寄存器
//   → dds_mixer 求和 → audio_pdm → 3.5mm 耳机
//
// 键位（USB HID Usage Codes）：
//   Lower octave (bottom row):
//     A(0x04)=C4  S(0x16)=D4  D(0x07)=E4  F(0x09)=F4
//     G(0x0A)=G4  H(0x0B)=A4  J(0x0D)=B4  K(0x0E)=C5
//
//   Upper octave (top row):
//     Q(0x14)=D5  W(0x1A)=E5  E(0x08)=F5  R(0x15)=G5
//     T(0x17)=A5  Y(0x1C)=B5  U(0x18)=C6  I(0x0C)=D6
//
//   USB boot keyboard 协议一次最多报 6 个同时按下的键；
//   我们取前 4 个分到 4 个 DDS 声道（跟之前 switch 版本一致）。
//=============================================================================
#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "project_config.h"    // 包含 MAX3421E/HID/transfer 等所有 USB 头

//------------------------------------------------------
// 硬件基地址
//------------------------------------------------------
#define DDS_BASE        0x44A00000
#define REG_PHASE_0     0x00
#define REG_PHASE_1     0x04
#define REG_PHASE_2     0x08
#define REG_PHASE_3     0x0C
#define REG_ENABLE      0x10

//------------------------------------------------------
// keycode → phase_inc 查表（USB HID code 0x00..0xFF）
// 其他键默认 0 = 静音
//------------------------------------------------------
static const unsigned int KEYCODE_TO_PHASE_INC[256] = {
    // ===== Lower octave: A S D F G H J K =====
    [0x04] = 11236,  // A → C4  (261.6 Hz)
    [0x16] = 12607,  // S → D4  (293.7 Hz)
    [0x07] = 14157,  // D → E4  (329.6 Hz)
    [0x09] = 14999,  // F → F4  (349.2 Hz)
    [0x0A] = 16838,  // G → G4  (392.0 Hz)
    [0x0B] = 18897,  // H → A4  (440.0 Hz)
    [0x0D] = 21213,  // J → B4  (493.9 Hz)
    [0x0E] = 22473,  // K → C5  (523.3 Hz)

    // ===== Upper octave: Q W E R T Y U I =====
    [0x14] = 25215,  // Q → D5  (587.3 Hz)
    [0x1A] = 28314,  // W → E5  (659.3 Hz)
    [0x08] = 29998,  // E → F5  (698.5 Hz)
    [0x15] = 33676,  // R → G5  (784.0 Hz)
    [0x17] = 37795,  // T → A5  (880.0 Hz)
    [0x1C] = 42426,  // Y → B5  (987.8 Hz)
    [0x18] = 44947,  // U → C6  (1046.5 Hz)
    [0x0C] = 50430,  // I → D6  (1174.7 Hz)
};

//------------------------------------------------------
// DDS helpers
//------------------------------------------------------
static inline void set_voice(int v, unsigned int inc) {
    Xil_Out32(DDS_BASE + (v * 4), inc);
}
static inline void set_enable(unsigned int en) {
    Xil_Out32(DDS_BASE + REG_ENABLE, en);
}

static void silence_all(void) {
    set_voice(0, 0);
    set_voice(1, 0);
    set_voice(2, 0);
    set_voice(3, 0);
}

static void delay_ms(int ms) {
    volatile int i;
    for (i = 0; i < ms * 20000; i++) asm volatile ("nop");
}

//------------------------------------------------------
// 把 HID report 映射到 4 个声道
//   boot keyboard report: report.keycode[6]
//   同时按下的最多 4 个音映射到 voice 0..3
//------------------------------------------------------
static void dispatch_keys(const BOOT_KBD_REPORT* rep, unsigned int voices[4]) {
    int vcount = 0;
    voices[0] = voices[1] = voices[2] = voices[3] = 0;

    for (int i = 0; i < 6 && vcount < 4; i++) {
        BYTE kc = rep->keycode[i];
        if (kc == 0) continue;                    // 空槽位
        unsigned int inc = KEYCODE_TO_PHASE_INC[kc];
        if (inc == 0) continue;                   // 不在我们映射表里的键（比如 modifier）
        voices[vcount++] = inc;
    }
}

//------------------------------------------------------
// main
//------------------------------------------------------
int main(void) {
    xil_printf("\r\n=== USB Piano boot ===\r\n");

    // 先把 DDS 关掉静音，免得初始化期间乱响
    silence_all();
    set_enable(1);

    // 上电欢迎音：A4 响 200ms，证明 DDS 链路活着
    set_voice(0, 18897);   // A4
    delay_ms(200);
    set_voice(0, 0);

    // USB stack 初始化
    HID_init();
    USB_init();
    MAX3421E_init();       // 这里面有 printf"Initializing SPI"，能看到就说明 SPI init OK
    xil_printf("USB init done, waiting for keyboard...\r\n");

    BOOT_KBD_REPORT kbd;
    unsigned int last_voices[4] = {0};

    while (1) {
        // USB 状态机：driver 扫 MAX3421E 中断 + 推进 enumeration
        MAX3421E_Task();
        USB_Task();

        // 只有当 USB 成功枚举键盘之后才轮询键码
        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BYTE rc = kbdPoll(&kbd);

            if (rc == 0) {  // 0 = success，报告结构体里是当前按下的键
                unsigned int v[4];
                dispatch_keys(&kbd, v);

                // 只在有变化时写 DDS，避免 click 和不必要的 AXI 流量
                for (int i = 0; i < 4; i++) {
                    if (v[i] != last_voices[i]) {
                        set_voice(i, v[i]);
                        last_voices[i] = v[i];
                    }
                }
            }
            // rc != 0 通常是 NAK（键盘没按任何键），保持当前 DDS 状态不变
        } else {
            // 键盘未连上或未枚举完成 → 静音
            if (last_voices[0] | last_voices[1] | last_voices[2] | last_voices[3]) {
                silence_all();
                last_voices[0] = last_voices[1] = last_voices[2] = last_voices[3] = 0;
            }
        }
    }

    return 0;
}
