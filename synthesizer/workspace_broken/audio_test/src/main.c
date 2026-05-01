//=============================================================================
// main_piano_usb_hdmi.c  --  Week 2 Day 4: USB 钢琴 + HDMI + 黑键 + 音域切换
//
// 键盘布局 (可直接贴在键盘上当参考):
//
//    2   3       5   6   7         <- 上八度黑键 (C#5 D#5 F#5 G#5 A#5)
//   Q   W   E   R   T   Y   U      <- 上八度白键 (C5 D5 E5 F5 G5 A5 B5)
//      S   D       G   H   J       <- 下八度黑键 (C#4 D#4 F#4 G#4 A#4)
//   Z   X   C   V   B   N   M      <- 下八度白键 (C4 D4 E4 F4 G4 A4 B4)
//
//   [  向下切八度,  ]  向上切八度,  Space  归零
//   音域范围 -4..+4 (覆盖 C0~C8, 几乎整个 88 键钢琴的范围)
//
// GPIO 映射:
//   gpio_keymask : 24-bit output, bit N = 第 N 个半音是否按下
//   gpio_octave  : 4-bit  output, 0..8 (4=无偏移, MB 写 octave_shift+4)
//=============================================================================

#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "project_config.h"

#define DDS_BASE        0x44A00000
#define REG_ENABLE      0x10

#ifndef XPAR_GPIO_KEYMASK_DEVICE_ID
  #define XPAR_GPIO_KEYMASK_DEVICE_ID  XPAR_AXI_GPIO_KEYMASK_DEVICE_ID
#endif
#ifndef XPAR_GPIO_OCTAVE_DEVICE_ID
  #define XPAR_GPIO_OCTAVE_DEVICE_ID   XPAR_AXI_GPIO_OCTAVE_DEVICE_ID
#endif

//------------------------------------------------------
// 半音 → phase_inc 查表
//   index 0  = C2  (65.41 Hz)
//   index 24 = C4  (261.63 Hz, 中央C)
//   index 71 = B7  (3951 Hz)
// phase_inc = freq * 2^32 / 100_000_000
//------------------------------------------------------
#define TABLE_SIZE  72
#define C4_INDEX    24

static const unsigned int PHASE_INC_TABLE[TABLE_SIZE] = {
    2809, 2976, 3153, 3340, 3539, 3750, 3973, 4209,    //  0..7:  C2..G2
    4460, 4725, 5006, 5304, 5618, 5952, 6305, 6679,    //  8..15: G#2..D#3
    7076, 7497, 7943, 8416, 8917, 9448, 10011, 10608,  // 16..23: E3..B3
    11236, 11903, 12607, 13357, 14152, 14999, 15895, 16838, // 24..31: C4..G4
    17838, 18897, 20021, 21213, 22473, 23806, 25215, 26714, // 32..39: G#4..D#5
    28304, 29998, 31791, 33676, 35676, 37795, 40044, 42426, // 40..47: E5..B5
    44947, 47616, 50430, 53428, 56608, 59975, 63582, 67352, // 48..55: C6..G6
    71353, 75591, 80089, 84853, 89894, 95232, 100861, 106855, // 56..63: G#6..D#7
    113215, 119950, 127164, 134703, 142705, 151182, 160178, 169706 // 64..71: E7..B7
};

//------------------------------------------------------
// keycode → {相对 C4 半音, keymask bit 位置}
//   semi 0  = C4, semi 23 = B5 (显示范围内的 24 个半音)
//   bit  同 semi (keymask bit N ↔ 屏幕上第 N 个半音)
//------------------------------------------------------
typedef struct {
    signed char semi;   // -128 表示不是音键
    signed char bit;    // 0..23
} key_info_t;

#define NO_KEY  (key_info_t){ -128, -1 }

static const key_info_t KEY_INFO[256] = {
    // 下八度 白键 (Z X C V B N M)
    [0x1D] = { 0,  0}, [0x1B] = { 2,  2}, [0x06] = { 4,  4}, [0x19] = { 5,  5},
    [0x05] = { 7,  7}, [0x11] = { 9,  9}, [0x10] = {11, 11},
    // 下八度 黑键 (S D G H J)
    [0x16] = { 1,  1}, [0x07] = { 3,  3}, [0x0A] = { 6,  6}, [0x0B] = { 8,  8},
    [0x0D] = {10, 10},
    // 上八度 白键 (Q W E R T Y U)
    [0x14] = {12, 12}, [0x1A] = {14, 14}, [0x08] = {16, 16}, [0x15] = {17, 17},
    [0x17] = {19, 19}, [0x1C] = {21, 21}, [0x18] = {23, 23},
    // 上八度 黑键 (2 3 5 6 7)
    [0x1F] = {13, 13}, [0x20] = {15, 15}, [0x22] = {18, 18}, [0x23] = {20, 20},
    [0x24] = {22, 22},
};

// 特殊键
#define KC_LBRACKET  0x2F   // [
#define KC_RBRACKET  0x30   // ]
#define KC_SPACE     0x2C   // Space

//------------------------------------------------------
// 状态
//------------------------------------------------------
static int octave_shift = 0;   // -4..+4

static inline void set_voice(int v, unsigned int inc) { Xil_Out32(DDS_BASE + v*4, inc); }
static inline void set_enable(unsigned int en)        { Xil_Out32(DDS_BASE + REG_ENABLE, en); }
static void silence_all(void) { set_voice(0,0); set_voice(1,0); set_voice(2,0); set_voice(3,0); }
static void delay_ms(int ms)  { volatile int i; for (i=0; i<ms*20000; i++) asm volatile ("nop"); }

// 根据当前 octave_shift 查出半音的 phase_inc
static unsigned int inc_for_semi(signed char base_semi) {
    int idx = C4_INDEX + base_semi + octave_shift * 12;
    if (idx < 0 || idx >= TABLE_SIZE) return 0;
    return PHASE_INC_TABLE[idx];
}

// 上一帧的 keycode 里是否包含 target (用于做 edge-trigger)
static int was_pressed(BYTE target, const BYTE *prev) {
    for (int i = 0; i < 6; i++) if (prev[i] == target) return 1;
    return 0;
}

//------------------------------------------------------
// 处理一次 HID report
//   1. 边沿检测 [ ] Space, 更新 octave_shift
//   2. 建立 voices[4] (前 4 个按下的音键)
//   3. 建立 mask (所有按下的音键的位图)
//------------------------------------------------------
static void process_report(const BOOT_KBD_REPORT *rep,
                           unsigned int voices[4],
                           unsigned int *pmask)
{
    static BYTE prev[6] = {0};
    BYTE curr[6];
    for (int i = 0; i < 6; i++) curr[i] = rep->keycode[i];

    // --- 边沿检测: 只在"从没按 → 按"的瞬间改 octave_shift ---
    for (int i = 0; i < 6; i++) {
        BYTE kc = curr[i];
        if (kc == 0) continue;
        if (was_pressed(kc, prev)) continue;

        if (kc == KC_LBRACKET && octave_shift > -4) { octave_shift--; xil_printf("octave=%d\r\n", octave_shift); }
        else if (kc == KC_RBRACKET && octave_shift <  4) { octave_shift++; xil_printf("octave=%d\r\n", octave_shift); }
        else if (kc == KC_SPACE) { octave_shift = 0; xil_printf("octave reset\r\n"); }
    }
    for (int i = 0; i < 6; i++) prev[i] = curr[i];

    // --- 建立 voices + mask ---
    voices[0] = voices[1] = voices[2] = voices[3] = 0;
    unsigned int mask = 0;
    int vcount = 0;

    for (int i = 0; i < 6; i++) {
        BYTE kc = curr[i];
        if (kc == 0) continue;
        key_info_t info = KEY_INFO[kc];
        if (info.bit < 0) continue;
        unsigned int inc = inc_for_semi(info.semi);
        if (inc == 0) continue;
        mask |= (1u << info.bit);
        if (vcount < 4) voices[vcount++] = inc;
    }
    *pmask = mask;
}

//------------------------------------------------------
// main
//------------------------------------------------------
int main(void) {
    xil_printf("\r\n=== USB Piano (2 octaves + black keys + octave shift) ===\r\n");

    // 初始化两个 AXI GPIO
    XGpio gpio_keymask, gpio_octave;
    if (XGpio_Initialize(&gpio_keymask, XPAR_GPIO_KEYMASK_DEVICE_ID) != XST_SUCCESS)
        xil_printf("keymask GPIO init FAIL\r\n");
    if (XGpio_Initialize(&gpio_octave,  XPAR_GPIO_OCTAVE_DEVICE_ID)  != XST_SUCCESS)
        xil_printf("octave GPIO init FAIL\r\n");
    XGpio_SetDataDirection(&gpio_keymask, 1, 0x00000000);
    XGpio_SetDataDirection(&gpio_octave,  1, 0x00000000);
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
    XGpio_DiscreteWrite(&gpio_octave,  1, 4);   // 初始 shift=0 → 写 4

    // DDS
    silence_all();
    set_enable(1);

    // 上电自检: 点亮所有键 200ms + A4
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0x00FFFFFF);
    set_voice(0, 18897);  // A4
    delay_ms(200);
    set_voice(0, 0);
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);

    // USB 初始化
    HID_init();
    USB_init();
    MAX3421E_init();
    xil_printf("USB init done, waiting for keyboard...\r\n");

    BOOT_KBD_REPORT kbd;
    unsigned int last_voices[4] = {0};
    unsigned int last_mask  = 0;
    int last_shift = octave_shift;

    while (1) {
        MAX3421E_Task();
        USB_Task();

        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BYTE rc = kbdPoll(&kbd);
            if (rc == 0) {
                unsigned int v[4], m;
                process_report(&kbd, v, &m);

                // 写 DDS (有变化就写 — 音域变化也会让 v[i] 变)
                for (int i = 0; i < 4; i++) {
                    if (v[i] != last_voices[i]) {
                        set_voice(i, v[i]);
                        last_voices[i] = v[i];
                    }
                }
                // 写 keymask
                if (m != last_mask) {
                    XGpio_DiscreteWrite(&gpio_keymask, 1, m);
                    last_mask = m;
                }
                // 写 octave GPIO (只在变化时写)
                if (octave_shift != last_shift) {
                    XGpio_DiscreteWrite(&gpio_octave, 1, octave_shift + 4);
                    last_shift = octave_shift;
                }
            }
        } else {
            // 键盘没枚举 → 静音 + 清空高亮
            if (last_voices[0]|last_voices[1]|last_voices[2]|last_voices[3]) {
                silence_all();
                last_voices[0]=last_voices[1]=last_voices[2]=last_voices[3]=0;
            }
            if (last_mask != 0) {
                XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
                last_mask = 0;
            }
        }
    }
    return 0;
}
