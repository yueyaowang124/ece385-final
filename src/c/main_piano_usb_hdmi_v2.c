//=============================================================================
// main_piano_usb_hdmi_v2.c  --  HDMI 钢琴 + 黑键 + 音域切换 + 6 波形切换
//
// 相对 v1 的改动:
//   - 新增 XGpio gpio_wave (3-bit output, Device ID = XPAR_GPIO_WAVE_DEVICE_ID)
//     驱动 BD 里新加的 AXI GPIO, 连到 dds_mixer.wave_sel 和 piano_display.wave_idx
//   - 键盘新增 F1..F6 边沿触发, 切换波形
//       F1 = Square   (0)
//       F2 = Triangle (1)
//       F3 = Sawtooth (2)
//       F4 = Sine     (3)
//       F5 = Organ    (4)
//       F6 = Vibrato  (5)
//   - 启动时把 wave_idx 初始化为 Sine (3) 而不是 Square, 听着舒服些
//
// 依赖 BD 改动: 新增一个 3-bit All-Output AXI GPIO, 名字 gpio_wave
//               External 端口名 gpio_wave, 会在 xparameters.h 里生成
//               XPAR_GPIO_WAVE_DEVICE_ID 或 XPAR_AXI_GPIO_WAVE_DEVICE_ID
//=============================================================================

#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xgpio.h"

// Xilinx BSP 里 (xil_types.h / xil_io.h) 定义过 TRUE/FALSE 宏,
// project_config.h -> GenericTypeDefs.h 里会再定义一次 -> redefinition 错误.
// 先 undef 掉 Xilinx 的版本, 让 USB driver 的版本生效.
#undef TRUE
#undef FALSE
#include "project_config.h"

#define DDS_BASE        0x44A00000
#define REG_ENABLE      0x10
#define REG_WAVE_SEL    0x14    // slv_reg5 -> dds_mixer.wave_sel (需要 IP 补丁)

// ---- Device ID 适配 (Vivado 有时叫 gpio_xxx, 有时叫 axi_gpio_xxx) ----
#ifndef XPAR_GPIO_KEYMASK_DEVICE_ID
  #define XPAR_GPIO_KEYMASK_DEVICE_ID  XPAR_AXI_GPIO_KEYMASK_DEVICE_ID
#endif
#ifndef XPAR_GPIO_OCTAVE_DEVICE_ID
  #define XPAR_GPIO_OCTAVE_DEVICE_ID   XPAR_AXI_GPIO_OCTAVE_DEVICE_ID
#endif
#ifndef XPAR_GPIO_WAVE_DEVICE_ID
  #define XPAR_GPIO_WAVE_DEVICE_ID     XPAR_AXI_GPIO_WAVE_DEVICE_ID
#endif

//------------------------------------------------------
// 半音 -> phase_inc 查表 (同 v1)
//------------------------------------------------------
#define TABLE_SIZE  72
#define C4_INDEX    24

static const unsigned int PHASE_INC_TABLE[TABLE_SIZE] = {
    2809, 2976, 3153, 3340, 3539, 3750, 3973, 4209,
    4460, 4725, 5006, 5304, 5618, 5952, 6305, 6679,
    7076, 7497, 7943, 8416, 8917, 9448, 10011, 10608,
    11236, 11903, 12607, 13357, 14152, 14999, 15895, 16838,
    17838, 18897, 20021, 21213, 22473, 23806, 25215, 26714,
    28304, 29998, 31791, 33676, 35676, 37795, 40044, 42426,
    44947, 47616, 50430, 53428, 56608, 59975, 63582, 67352,
    71353, 75591, 80089, 84853, 89894, 95232, 100861, 106855,
    113215, 119950, 127164, 134703, 142705, 151182, 160178, 169706
};

typedef struct {
    signed char semi;
    signed char bit;
} key_info_t;

static const key_info_t KEY_INFO[256] = {
    // 下八度 白键 Z X C V B N M
    [0x1D] = { 0,  0}, [0x1B] = { 2,  2}, [0x06] = { 4,  4}, [0x19] = { 5,  5},
    [0x05] = { 7,  7}, [0x11] = { 9,  9}, [0x10] = {11, 11},
    // 下八度 黑键 S D G H J
    [0x16] = { 1,  1}, [0x07] = { 3,  3}, [0x0A] = { 6,  6}, [0x0B] = { 8,  8},
    [0x0D] = {10, 10},
    // 上八度 白键 Q W E R T Y U
    [0x14] = {12, 12}, [0x1A] = {14, 14}, [0x08] = {16, 16}, [0x15] = {17, 17},
    [0x17] = {19, 19}, [0x1C] = {21, 21}, [0x18] = {23, 23},
    // 上八度 黑键 2 3 5 6 7
    [0x1F] = {13, 13}, [0x20] = {15, 15}, [0x22] = {18, 18}, [0x23] = {20, 20},
    [0x24] = {22, 22},
};

// 特殊键
#define KC_LBRACKET  0x2F   // [
#define KC_RBRACKET  0x30   // ]
#define KC_SPACE     0x2C

// F1..F6 (HID usage code)
#define KC_F1  0x3A
#define KC_F2  0x3B
#define KC_F3  0x3C
#define KC_F4  0x3D
#define KC_F5  0x3E
#define KC_F6  0x3F

static const char* WAVE_NAMES[8] = {
    "Square",   "Triangle", "Sawtooth", "Sine",
    "Organ",    "Vibrato",  "---",      "---"
};

//------------------------------------------------------
// 状态
//------------------------------------------------------
static int octave_shift = 0;
static unsigned int wave_idx = 3;   // 默认 Sine

static inline void set_voice(int v, unsigned int inc) { Xil_Out32(DDS_BASE + v*4, inc); }
static inline void set_enable(unsigned int en)        { Xil_Out32(DDS_BASE + REG_ENABLE, en); }
static inline void set_wave_dds(unsigned int sel)     { Xil_Out32(DDS_BASE + REG_WAVE_SEL, sel & 0x7); }
static void silence_all(void) { set_voice(0,0); set_voice(1,0); set_voice(2,0); set_voice(3,0); }
static void delay_ms(int ms)  { volatile int i; for (i=0; i<ms*20000; i++) asm volatile ("nop"); }

static unsigned int inc_for_semi(signed char base_semi) {
    int idx = C4_INDEX + base_semi + octave_shift * 12;
    if (idx < 0 || idx >= TABLE_SIZE) return 0;
    return PHASE_INC_TABLE[idx];
}

static int was_pressed(BYTE target, const BYTE *prev) {
    for (int i = 0; i < 6; i++) if (prev[i] == target) return 1;
    return 0;
}

//------------------------------------------------------
// 处理一次 HID report:
//   1. 边沿检测 [ ] Space -> 改 octave_shift
//   2. 边沿检测 F1..F6    -> 改 wave_idx
//   3. 建 voices[4] + mask
//------------------------------------------------------
static void process_report(const BOOT_KBD_REPORT *rep,
                           unsigned int voices[4],
                           unsigned int *pmask)
{
    static BYTE prev[6] = {0};
    BYTE curr[6];
    for (int i = 0; i < 6; i++) curr[i] = rep->keycode[i];

    // --- 边沿检测 ---
    for (int i = 0; i < 6; i++) {
        BYTE kc = curr[i];
        if (kc == 0) continue;
        if (was_pressed(kc, prev)) continue;

        // 音域
        if      (kc == KC_LBRACKET && octave_shift > -4) { octave_shift--; xil_printf("octave=%d\r\n", octave_shift); }
        else if (kc == KC_RBRACKET && octave_shift <  4) { octave_shift++; xil_printf("octave=%d\r\n", octave_shift); }
        else if (kc == KC_SPACE)                         { octave_shift = 0; xil_printf("octave reset\r\n"); }
        // 波形
        else if (kc == KC_F1) { wave_idx = 0; xil_printf("wave -> %s\r\n", WAVE_NAMES[0]); }
        else if (kc == KC_F2) { wave_idx = 1; xil_printf("wave -> %s\r\n", WAVE_NAMES[1]); }
        else if (kc == KC_F3) { wave_idx = 2; xil_printf("wave -> %s\r\n", WAVE_NAMES[2]); }
        else if (kc == KC_F4) { wave_idx = 3; xil_printf("wave -> %s\r\n", WAVE_NAMES[3]); }
        else if (kc == KC_F5) { wave_idx = 4; xil_printf("wave -> %s\r\n", WAVE_NAMES[4]); }
        else if (kc == KC_F6) { wave_idx = 5; xil_printf("wave -> %s\r\n", WAVE_NAMES[5]); }
    }
    for (int i = 0; i < 6; i++) prev[i] = curr[i];

    // --- 建 voices + mask ---
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
    xil_printf("\r\n=== USB Piano v2 (2 oct + black keys + octave shift + 6 waveforms) ===\r\n");
    xil_printf("Waveform keys: F1=Square F2=Triangle F3=Saw F4=Sine F5=Organ F6=Vibrato\r\n");
    xil_printf("Octave keys:  [ = down,  ] = up,  Space = reset\r\n\r\n");

    // ---- 三个 AXI GPIO ----
    XGpio gpio_keymask, gpio_octave, gpio_wave;
    if (XGpio_Initialize(&gpio_keymask, XPAR_GPIO_KEYMASK_DEVICE_ID) != XST_SUCCESS)
        xil_printf("keymask GPIO init FAIL\r\n");
    if (XGpio_Initialize(&gpio_octave,  XPAR_GPIO_OCTAVE_DEVICE_ID)  != XST_SUCCESS)
        xil_printf("octave GPIO init FAIL\r\n");
    if (XGpio_Initialize(&gpio_wave,    XPAR_GPIO_WAVE_DEVICE_ID)    != XST_SUCCESS)
        xil_printf("wave GPIO init FAIL\r\n");
    XGpio_SetDataDirection(&gpio_keymask, 1, 0x00000000);
    XGpio_SetDataDirection(&gpio_octave,  1, 0x00000000);
    XGpio_SetDataDirection(&gpio_wave,    1, 0x00000000);
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
    XGpio_DiscreteWrite(&gpio_octave,  1, 4);          // shift=0 -> 写 4
    XGpio_DiscreteWrite(&gpio_wave,    1, wave_idx);   // 初始 Sine -> display
    set_wave_dds(wave_idx);                            // 初始 Sine -> DDS

    // ---- DDS ----
    silence_all();
    set_enable(1);

    // ---- 上电自检 ----
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0x00FFFFFF);
    set_voice(0, 18897);  // A4
    delay_ms(200);
    set_voice(0, 0);
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);

    // ---- USB 初始化 ----
    HID_init();
    USB_init();
    MAX3421E_init();
    xil_printf("USB init done, waiting for keyboard...\r\n");

    BOOT_KBD_REPORT kbd;
    unsigned int last_voices[4] = {0};
    unsigned int last_mask = 0;
    int last_shift = octave_shift;
    unsigned int last_wave = wave_idx;

    while (1) {
        MAX3421E_Task();
        USB_Task();

        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BYTE rc = kbdPoll(&kbd);
            if (rc == 0) {
                unsigned int v[4], m;
                process_report(&kbd, v, &m);

                // 写 DDS 声道
                for (int i = 0; i < 4; i++) {
                    if (v[i] != last_voices[i]) {
                        set_voice(i, v[i]);
                        last_voices[i] = v[i];
                    }
                }
                // keymask
                if (m != last_mask) {
                    XGpio_DiscreteWrite(&gpio_keymask, 1, m);
                    last_mask = m;
                }
                // octave
                if (octave_shift != last_shift) {
                    XGpio_DiscreteWrite(&gpio_octave, 1, octave_shift + 4);
                    last_shift = octave_shift;
                }
                // wave (同时写 display-GPIO 和 DDS-slv_reg5)
                if (wave_idx != last_wave) {
                    XGpio_DiscreteWrite(&gpio_wave, 1, wave_idx & 0x7);
                    set_wave_dds(wave_idx);
                    last_wave = wave_idx;
                }
            }
        } else {
            // 键盘没枚举 -> 静音 + 清空高亮
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
