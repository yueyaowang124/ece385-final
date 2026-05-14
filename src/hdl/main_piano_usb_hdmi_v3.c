//=============================================================================
// main_piano_usb_hdmi_v3.c
//   v2 + AUTOPLAY 模式 (小猪佩奇主题曲)
//
// 新增:
//   - ESC (0x29) 键: 手动 <-> 自动 切换
//       * 手动模式下按 ESC -> 进入自动演奏
//       * 自动演奏中按 ESC -> 立即取消, 回到手动
//       * 自动演奏完成也会自动回到手动
//   - 自动演奏期间:
//       * 停手动键盘处理 (不吃用户按键)
//       * 仍调 MAX3421E_Task() / USB_Task() 维持 USB 不掉线
//       * HDMI keymask 显示当前正在响的琴键 (和手动模式一致)
//   - 曲谱用 "相对 C4 的半音数" 表示, 方便改音符
//       NOTE_C4 = 0, NOTE_D4 = 2, ..., NOTE_C5 = 12
//       负数代表 C4 以下, REST = 特殊常量 -128
//
// 依赖: 和 v2 完全一样 (gpio_keymask + gpio_octave + gpio_wave + DDS IP)
//=============================================================================

#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xgpio.h"

// Xilinx BSP 里 (xil_types.h / xil_io.h) 定义过 TRUE/FALSE 宏,
// project_config.h -> GenericTypeDefs.h 里会再定义一次 -> redefinition 错误.
#undef TRUE
#undef FALSE
#include "project_config.h"

#define DDS_BASE        0x44A00000
#define REG_ENABLE      0x10
#define REG_WAVE_SEL    0x14

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
// 半音 -> phase_inc 查表
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
#define KC_ESC       0x29   // ★ NEW: autoplay 切换键

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
static unsigned int wave_idx = 3;

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
// 绝对半音 (不受 octave_shift 影响) -> phase_inc   [autoplay 用]
static unsigned int inc_for_abs_semi(signed char semi_from_c4) {
    int idx = C4_INDEX + semi_from_c4;
    if (idx < 0 || idx >= TABLE_SIZE) return 0;
    return PHASE_INC_TABLE[idx];
}

static int was_pressed(BYTE target, const BYTE *prev) {
    for (int i = 0; i < 6; i++) if (prev[i] == target) return 1;
    return 0;
}
static int is_pressed_now(BYTE target, const BOOT_KBD_REPORT *rep) {
    for (int i = 0; i < 6; i++) if (rep->keycode[i] == target) return 1;
    return 0;
}

//============================================================================
// AUTOPLAY: 小猪佩奇主题曲
//============================================================================
// 相对 C4 的半音数
#define N_REST  (-128)   // 特殊常量: 休止
#define N_C4      0
#define N_Cs4     1
#define N_D4      2
#define N_Ds4     3
#define N_E4      4
#define N_F4      5
#define N_Fs4     6
#define N_G4      7
#define N_Gs4     8
#define N_A4      9
#define N_As4    10
#define N_B4     11
#define N_C5     12
#define N_Cs5    13
#define N_D5     14
#define N_Ds5    15
#define N_E5     16
#define N_F5     17
#define N_Fs5    18
#define N_G5     19

typedef struct {
    signed char mel;   // 主旋律半音 (相对 C4), N_REST 表示休止
    signed char acc;   // 伴奏半音
    unsigned short ticks;  // 持续节拍
} peppa_note_t;

#define TICK_MS  150

// 小猪佩奇主题曲片段 (队友的 10 音版, 用相对半音重写)
// 主旋律 = E5 G5 E5 C5 G4 _ G4 A4 B4 C5
// 伴奏   = C4 持续
static const peppa_note_t PEPPA_SONG[] = {
    { N_E5, N_C4, 2 }, { N_G5, N_C4, 2 }, { N_E5, N_C4, 2 }, { N_C5, N_C4, 2 },
    { N_G4, N_C4, 2 }, { N_REST, N_C4, 2 }, { N_G4, N_C4, 2 }, { N_A4, N_C4, 2 },
    { N_B4, N_C4, 2 }, { N_C5, N_C4, 4 },
};
#define PEPPA_LEN (sizeof(PEPPA_SONG)/sizeof(PEPPA_SONG[0]))

// 把 autoplay 的 "正在响的音" 画到 HDMI keymask 上
// 只有落在 [0..23] 的半音会被点亮, 其他就不亮 (显示不了)
static unsigned int mask_for_autoplay(signed char mel, signed char acc) {
    unsigned int m = 0;
    if (mel != N_REST && mel >= 0 && mel <= 23) m |= (1u << mel);
    if (acc != N_REST && acc >= 0 && acc <= 23) m |= (1u << acc);
    return m;
}

// 延迟 ms 毫秒, 期间:
//   - 继续跑 USB 任务
//   - 如果检测到 ESC, 返回 1 (被取消)
//   - 否则返回 0
static int autoplay_delay_ms(int ms) {
    const int CHUNK = 8;   // 每 8 ms 一次轮询
    int remaining = ms;
    while (remaining > 0) {
        MAX3421E_Task();
        USB_Task();
        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BOOT_KBD_REPORT k;
            if (kbdPoll(&k) == 0) {
                if (is_pressed_now(KC_ESC, &k)) return 1;
            }
        }
        int step = remaining > CHUNK ? CHUNK : remaining;
        delay_ms(step);
        remaining -= step;
    }
    return 0;
}

// 执行一首自动演奏, 返回 0=正常结束, 1=被 ESC 打断
static int play_peppa_auto(XGpio *g_keymask) {
    xil_printf("[autoplay] Peppa Pig start, press ESC to cancel\r\n");
    silence_all();

    for (unsigned int i = 0; i < PEPPA_LEN; i++) {
        signed char mel = PEPPA_SONG[i].mel;
        signed char acc = PEPPA_SONG[i].acc;

        unsigned int mel_inc = (mel == N_REST) ? 0 : inc_for_abs_semi(mel);
        unsigned int acc_inc = (acc == N_REST) ? 0 : inc_for_abs_semi(acc);

        set_voice(0, mel_inc);
        set_voice(1, acc_inc);
        set_voice(2, 0);
        set_voice(3, 0);
        XGpio_DiscreteWrite(g_keymask, 1, mask_for_autoplay(mel, acc));

        int note_ms = PEPPA_SONG[i].ticks * TICK_MS;
        // 90% 时间发声 + 10% 断音 (staccato, 更有节奏感)
        int on_ms  = note_ms * 9 / 10;
        int off_ms = note_ms - on_ms;

        if (autoplay_delay_ms(on_ms)) {
            silence_all();
            XGpio_DiscreteWrite(g_keymask, 1, 0);
            xil_printf("[autoplay] cancelled\r\n");
            return 1;
        }
        // staccato 间隙
        silence_all();
        XGpio_DiscreteWrite(g_keymask, 1, 0);
        if (autoplay_delay_ms(off_ms)) {
            xil_printf("[autoplay] cancelled\r\n");
            return 1;
        }
    }

    silence_all();
    XGpio_DiscreteWrite(g_keymask, 1, 0);
    xil_printf("[autoplay] done\r\n");
    return 0;
}

//============================================================================
// 手动键盘处理 (和 v2 相同, 外加: 返回是否检测到 ESC 上升沿)
//============================================================================
static int process_report(const BOOT_KBD_REPORT *rep,
                           unsigned int voices[4],
                           unsigned int *pmask)
{
    static BYTE prev[6] = {0};
    BYTE curr[6];
    int esc_edge = 0;
    for (int i = 0; i < 6; i++) curr[i] = rep->keycode[i];

    for (int i = 0; i < 6; i++) {
        BYTE kc = curr[i];
        if (kc == 0) continue;
        if (was_pressed(kc, prev)) continue;

        // ★ ESC 上升沿 -> 切换到 autoplay
        if      (kc == KC_ESC) { esc_edge = 1; }
        // 音域
        else if (kc == KC_LBRACKET && octave_shift > -4) { octave_shift--; xil_printf("octave=%d\r\n", octave_shift); }
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
    return esc_edge;
}

//============================================================================
// main
//============================================================================
int main(void) {
    xil_printf("\r\n=== USB Piano v3 (manual + autoplay Peppa Pig) ===\r\n");
    xil_printf("Waveform keys: F1=Square F2=Triangle F3=Saw F4=Sine F5=Organ F6=Vibrato\r\n");
    xil_printf("Octave keys:  [ = down,  ] = up,  Space = reset\r\n");
    xil_printf("AUTOPLAY:     ESC to start / cancel Peppa Pig\r\n\r\n");

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
    XGpio_DiscreteWrite(&gpio_octave,  1, 4);
    XGpio_DiscreteWrite(&gpio_wave,    1, wave_idx);
    set_wave_dds(wave_idx);

    silence_all();
    set_enable(1);

    // 上电自检
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0x00FFFFFF);
    set_voice(0, 18897);  // A4
    delay_ms(200);
    set_voice(0, 0);
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);

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
                int esc_edge = process_report(&kbd, v, &m);

                // ★ 检测到 ESC -> 阻塞式播放小猪佩奇
                if (esc_edge) {
                    // 先把手动状态清零 (防止 autoplay 结束回来后还以为按着键)
                    silence_all();
                    for (int i = 0; i < 4; i++) last_voices[i] = 0;
                    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
                    last_mask = 0;

                    play_peppa_auto(&gpio_keymask);

                    // autoplay 结束, 刷新一下 display 状态回归正常
                    continue;  // 跳回 while 头部, 重新采一次 kbd
                }

                // 正常手动模式: 写 DDS
                for (int i = 0; i < 4; i++) {
                    if (v[i] != last_voices[i]) {
                        set_voice(i, v[i]);
                        last_voices[i] = v[i];
                    }
                }
                if (m != last_mask) {
                    XGpio_DiscreteWrite(&gpio_keymask, 1, m);
                    last_mask = m;
                }
                if (octave_shift != last_shift) {
                    XGpio_DiscreteWrite(&gpio_octave, 1, octave_shift + 4);
                    last_shift = octave_shift;
                }
                if (wave_idx != last_wave) {
                    XGpio_DiscreteWrite(&gpio_wave, 1, wave_idx & 0x7);
                    set_wave_dds(wave_idx);
                    last_wave = wave_idx;
                }
            }
        } else {
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
