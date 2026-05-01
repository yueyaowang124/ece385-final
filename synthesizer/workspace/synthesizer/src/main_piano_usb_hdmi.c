//=============================================================================
// main_piano_final.c  --  手动演奏 + 自动演奏 + 音量控制（完整融合版）
//
// 功能：
//   手动模式：
//     Z X C V B N M = 下八度白键，S D G H J = 下八度黑键
//     Q W E R T Y U = 上八度白键，2 3 5 6 7 = 上八度黑键
//     [ ] = 八度下移/上移，Space = 八度复位
//     F1~F6 = 波形切换（Square/Triangle/Sawtooth/Sine/Organ/Vibrato）
//     - / = = 音量减/增（每次 ±10%，共 10 档，范围 0~10）
//     CapsLock = 切换到自动模式
//
//   自动模式（小猪佩奇）：
//     - 循环播放三声道旋律，使用方波
//     - 画面上对应琴键显示青色（与手动橙色区分）
//     - CapsLock = 切换回手动模式
//
// 音量控制：
//     写入 DDS_BASE+0x18（slv_reg6，硬件真实幅度缩放）
//     范围 0~10，每档约 10%，默认 10（满量）
//     切换模式后音量保持不变
//
// 硬件依赖：
//   gpio_keymask  → piano_display.keymask     (手动按键，橙色)
//   gpio_autokey  → piano_display.auto_keymask (自动按键，青色)  ← 新增
//   gpio_octave   → piano_display.octave_idx
//   gpio_wave     → piano_display.wave_idx
//=============================================================================

#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xgpio.h"
#include <unistd.h>

#undef TRUE
#undef FALSE
#include "project_config.h"

//------------------------------------------------------
// 硬件地址
//------------------------------------------------------
#define DDS_BASE        0x44A00000
#define REG_PHASE_0     0x00
#define REG_PHASE_1     0x04
#define REG_PHASE_2     0x08
#define REG_PHASE_3     0x0C
#define REG_ENABLE      0x10
#define REG_WAVE_SEL    0x14
#define REG_VOLUME      0x18    // slv_reg6：音量 0~10

//------------------------------------------------------
// Device ID 适配（Vivado命名有时带axi_前缀）
//------------------------------------------------------
#ifndef XPAR_GPIO_KEYMASK_DEVICE_ID
  #define XPAR_GPIO_KEYMASK_DEVICE_ID  XPAR_AXI_GPIO_KEYMASK_DEVICE_ID
#endif
#ifndef XPAR_GPIO_AUTOKEY_DEVICE_ID
  #define XPAR_GPIO_AUTOKEY_DEVICE_ID  XPAR_AXI_GPIO_AUTOKEY_DEVICE_ID
#endif
#ifndef XPAR_GPIO_OCTAVE_DEVICE_ID
  #define XPAR_GPIO_OCTAVE_DEVICE_ID   XPAR_AXI_GPIO_OCTAVE_DEVICE_ID
#endif
#ifndef XPAR_GPIO_WAVE_DEVICE_ID
  #define XPAR_GPIO_WAVE_DEVICE_ID     XPAR_AXI_GPIO_WAVE_DEVICE_ID
#endif

//------------------------------------------------------
// 音符频率表（72个半音，C2~B7）
//------------------------------------------------------
#define TABLE_SIZE  72
#define C4_INDEX    24

static const unsigned int PHASE_INC_TABLE[TABLE_SIZE] = {
    2809,  2976,  3153,  3340,  3539,  3750,  3973,  4209,
    4460,  4725,  5006,  5304,  5618,  5952,  6305,  6679,
    7076,  7497,  7943,  8416,  8917,  9448,  10011, 10608,
    11236, 11903, 12607, 13357, 14152, 14999, 15895, 16838,
    17838, 18897, 20021, 21213, 22473, 23806, 25215, 26714,
    28304, 29998, 31791, 33676, 35676, 37795, 40044, 42426,
    44947, 47616, 50430, 53428, 56608, 59975, 63582, 67352,
    71353, 75591, 80089, 84853, 89894, 95232, 100861,106855,
    113215,119950,127164,134703,142705,151182,160178,169706
};

//------------------------------------------------------
// 键码映射（手动演奏）
//------------------------------------------------------
typedef struct { signed char semi; signed char bit; } key_info_t;

static const key_info_t KEY_INFO[256] = {
    [0x1D] = { 0,  0}, [0x1B] = { 2,  2}, [0x06] = { 4,  4}, [0x19] = { 5,  5},
    [0x05] = { 7,  7}, [0x11] = { 9,  9}, [0x10] = {11, 11},
    [0x16] = { 1,  1}, [0x07] = { 3,  3}, [0x0A] = { 6,  6}, [0x0B] = { 8,  8},
    [0x0D] = {10, 10},
    [0x14] = {12, 12}, [0x1A] = {14, 14}, [0x08] = {16, 16}, [0x15] = {17, 17},
    [0x17] = {19, 19}, [0x1C] = {21, 21}, [0x18] = {23, 23},
    [0x1F] = {13, 13}, [0x20] = {15, 15}, [0x22] = {18, 18}, [0x23] = {20, 20},
    [0x24] = {22, 22},
};

// 特殊键 HID 码
#define KC_LBRACKET  0x2F
#define KC_RBRACKET  0x30
#define KC_SPACE     0x2C
#define KC_CAPSLOCK  0x39
#define KC_MINUS     0x2D   // '-' 键：音量减
#define KC_EQUAL     0x2E   // '=' 键：音量加
#define KC_F1  0x3A
#define KC_F2  0x3B
#define KC_F3  0x3C
#define KC_F4  0x3D
#define KC_F5  0x3E
#define KC_F6  0x3F

static const char *WAVE_NAMES[8] = {
    "Square","Triangle","Sawtooth","Sine","Organ","Vibrato","---","---"
};

//------------------------------------------------------
// 小猪佩奇乐谱
// auto_mask：每个音符对应的 keymask（piano_display用）
// 映射规则：semi=0对应bit0(C4), semi=7对应bit7(G4), ...
//------------------------------------------------------
#define REST      0
#define NOTE_G3   8419
#define NOTE_C4   11236
#define NOTE_D4   12608
#define NOTE_E4   14157
#define NOTE_F4   15000
#define NOTE_G4   16838
#define NOTE_B4   21213
#define NOTE_C5   22473
#define NOTE_D5   25215
#define NOTE_E5   28314
#define NOTE_F5   30000
#define NOTE_G5   33676
#define NOTE_A5   37794
#define NOTE_B5   42426
#define NOTE_C6   44946

#define TICK_MS    125
#define MUTE_RATIO 30

typedef struct {
    uint32_t ch0, ch1, ch2;
    uint32_t ticks;
    uint32_t auto_mask;  // 对应 piano_display.auto_keymask
} PeppaNote;

// auto_mask 根据音符semi计算：G5=bit19, G4=bit7, C4=bit0, 等
// G3超出范围（semi=-5），不点亮
static const PeppaNote SCORE[] = {
    {NOTE_G5, NOTE_G4, NOTE_C4, 2, 0x080081},  // G5(19)+G4(7)+C4(0)
    {NOTE_E5, REST,    REST,    1, 0x010000},  // E5(16)
    {NOTE_C5, REST,    REST,    1, 0x001000},  // C5(12)
    {NOTE_D5, NOTE_B4, NOTE_G4, 2, 0x004880},  // D5(14)+B4(11)+G4(7)
    {NOTE_G5, NOTE_G4, NOTE_G3, 2, 0x080080},  // G5(19)+G4(7)，G3超范围
    {NOTE_G4, REST,    NOTE_G3, 1, 0x000080},  // G4(7)
    {NOTE_B4, REST,    REST,    1, 0x000800},  // B4(11)
    {NOTE_D5, NOTE_B4, NOTE_G4, 1, 0x004880},  // D5(14)+B4(11)+G4(7)
    {NOTE_F5, REST,    REST,    1, 0x020000},  // F5(17)
    {NOTE_E5, NOTE_C5, NOTE_C4, 2, 0x011001},  // E5(16)+C5(12)+C4(0)
    {NOTE_C5, NOTE_G4, NOTE_C4, 2, 0x001081},  // C5(12)+G4(7)+C4(0)
    {NOTE_E5, NOTE_C5, NOTE_C4, 3, 0x011001},  // E5(16)+C5(12)+C4(0)
    {NOTE_E5, REST,    REST,    1, 0x010000},  // E5(16)
    {NOTE_G5, NOTE_G4, NOTE_C4, 2, 0x080081},  // G5(19)+G4(7)+C4(0)
    {REST,    REST,    REST,    2, 0x000000},  // 休止
};
#define SCORE_LEN (sizeof(SCORE)/sizeof(PeppaNote))

//------------------------------------------------------
// 全局状态
//------------------------------------------------------
static XGpio gpio_keymask, gpio_autokey, gpio_octave, gpio_wave;

static int          octave_shift = 0;
static unsigned int wave_idx     = 3;   // 默认 Sine
static int          auto_mode    = 0;   // 0=手动 1=自动
static int          volume       = 10;  // 音量 0~10，默认满量

#define VOLUME_MAX 10
#define VOLUME_MIN  0

//------------------------------------------------------
// DDS 辅助
//------------------------------------------------------
static inline void set_voice(int v, unsigned int inc) {
    Xil_Out32(DDS_BASE + v * 4, inc);
}
static inline void set_enable(unsigned int en)      { Xil_Out32(DDS_BASE + REG_ENABLE,   en); }
static inline void set_wave_dds(unsigned int sel)   { Xil_Out32(DDS_BASE + REG_WAVE_SEL, sel & 0x7); }
static inline void set_volume_hw(int vol) {
    if (vol < VOLUME_MIN) vol = VOLUME_MIN;
    if (vol > VOLUME_MAX) vol = VOLUME_MAX;
    Xil_Out32(DDS_BASE + REG_VOLUME, (uint32_t)vol);
}
static void silence_all(void) {
    set_voice(0,0); set_voice(1,0); set_voice(2,0); set_voice(3,0);
}
static void delay_ms(int ms) {
    volatile int i;
    for (i = 0; i < ms * 20000; i++) asm volatile ("nop");
}

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
// CapsLock 边沿检测（跨调用静态 prev）
//------------------------------------------------------
static int check_capslock_edge(const BOOT_KBD_REPORT *rep) {
    static BYTE prev_keys[6] = {0};
    int fired = 0;
    for (int i = 0; i < 6; i++) {
        if (rep->keycode[i] == KC_CAPSLOCK &&
            !was_pressed(KC_CAPSLOCK, prev_keys)) {
            fired = 1; break;
        }
    }
    for (int i = 0; i < 6; i++) prev_keys[i] = rep->keycode[i];
    return fired;
}

//------------------------------------------------------
// 手动模式：处理一次 HID 报告
//------------------------------------------------------
static void process_manual(const BOOT_KBD_REPORT *rep,
                            unsigned int voices[4],
                            unsigned int *pmask)
{
    static BYTE prev[6] = {0};
    BYTE curr[6];
    for (int i = 0; i < 6; i++) curr[i] = rep->keycode[i];

    for (int i = 0; i < 6; i++) {
        BYTE kc = curr[i];
        if (kc == 0 || was_pressed(kc, prev)) continue;

        if (kc == KC_LBRACKET && octave_shift > -4) {
            octave_shift--;
            xil_printf("octave=%d\r\n", octave_shift);
            XGpio_DiscreteWrite(&gpio_octave, 1, octave_shift + 4);
        }
        else if (kc == KC_RBRACKET && octave_shift < 4) {
            octave_shift++;
            xil_printf("octave=%d\r\n", octave_shift);
            XGpio_DiscreteWrite(&gpio_octave, 1, octave_shift + 4);
        }
        else if (kc == KC_SPACE) {
            octave_shift = 0;
            xil_printf("octave reset\r\n");
            XGpio_DiscreteWrite(&gpio_octave, 1, 4);
        }
        // 音量控制：每次约10%（共10档）
        else if (kc == KC_MINUS && volume > VOLUME_MIN) {
            volume--;
            set_volume_hw(volume);
            xil_printf("volume -> %d/10 (%d%%)\r\n", volume, volume * 10);
        }
        else if (kc == KC_EQUAL && volume < VOLUME_MAX) {
            volume++;
            set_volume_hw(volume);
            xil_printf("volume -> %d/10 (%d%%)\r\n", volume, volume * 10);
        }
        // 波形切换
        else if (kc == KC_F1) { wave_idx = 0; goto wave_changed; }
        else if (kc == KC_F2) { wave_idx = 1; goto wave_changed; }
        else if (kc == KC_F3) { wave_idx = 2; goto wave_changed; }
        else if (kc == KC_F4) { wave_idx = 3; goto wave_changed; }
        else if (kc == KC_F5) { wave_idx = 4; goto wave_changed; }
        else if (kc == KC_F6) { wave_idx = 5; goto wave_changed; }
        continue;
wave_changed:
        xil_printf("wave -> %s\r\n", WAVE_NAMES[wave_idx]);
        set_wave_dds(wave_idx);
        XGpio_DiscreteWrite(&gpio_wave, 1, wave_idx);
    }
    for (int i = 0; i < 6; i++) prev[i] = curr[i];

    // 建立 voices + keymask
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
// 自动模式：演奏单个音符，期间可被 CapsLock 中断
// 返回 1 = CapsLock 触发退出
//------------------------------------------------------
static int play_note_interruptible(const PeppaNote *note) {
    uint32_t total_ms = note->ticks * TICK_MS;
    uint32_t duty_ms  = total_ms * (100 - MUTE_RATIO) / 100;
    uint32_t pause_ms = total_ms - duty_ms;

    // 写三声道频率 + 更新显示 keymask（青色）
    Xil_Out32(DDS_BASE + REG_PHASE_0, note->ch0);
    Xil_Out32(DDS_BASE + REG_PHASE_1, note->ch1);
    Xil_Out32(DDS_BASE + REG_PHASE_2, note->ch2);
    XGpio_DiscreteWrite(&gpio_autokey, 1, note->auto_mask);   // ← 点亮对应琴键（青色）

    uint32_t elapsed = 0;
    while (elapsed < duty_ms) {
        uint32_t step = (duty_ms - elapsed > 20) ? 20 : (duty_ms - elapsed);
        usleep(step * 1000);
        elapsed += step;
        MAX3421E_Task(); USB_Task();
        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BOOT_KBD_REPORT tmp;
            if (kbdPoll(&tmp) == 0 && check_capslock_edge(&tmp)) return 1;
        }
    }

    // 静音段：清除频率 + 清除 keymask
    Xil_Out32(DDS_BASE + REG_PHASE_0, 0);
    Xil_Out32(DDS_BASE + REG_PHASE_1, 0);
    Xil_Out32(DDS_BASE + REG_PHASE_2, 0);
    XGpio_DiscreteWrite(&gpio_autokey, 1, 0);   // ← 熄灭琴键

    elapsed = 0;
    while (elapsed < pause_ms) {
        uint32_t step = (pause_ms - elapsed > 20) ? 20 : (pause_ms - elapsed);
        usleep(step * 1000);
        elapsed += step;
        MAX3421E_Task(); USB_Task();
        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BOOT_KBD_REPORT tmp;
            if (kbdPoll(&tmp) == 0 && check_capslock_edge(&tmp)) return 1;
        }
    }
    return 0;
}

//------------------------------------------------------
// 自动模式主循环（返回1=CapsLock退出）
//------------------------------------------------------
static int run_auto_mode(void) {
    xil_printf("=== AUTO mode: Peppa Pig ===\r\n");
    // 自动模式固定方波，不改变 wave_idx（切回手动时恢复）
    set_wave_dds(0);
    XGpio_DiscreteWrite(&gpio_wave, 1, 0);

    while (1) {
        for (int i = 0; i < (int)SCORE_LEN; i++) {
            if (play_note_interruptible(&SCORE[i])) {
                silence_all();
                XGpio_DiscreteWrite(&gpio_autokey, 1, 0);
                return 1;
            }
        }
        // 曲间停顿，继续检测 CapsLock
        usleep(2000000);
        MAX3421E_Task(); USB_Task();
        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BOOT_KBD_REPORT tmp;
            if (kbdPoll(&tmp) == 0 && check_capslock_edge(&tmp)) {
                silence_all();
                XGpio_DiscreteWrite(&gpio_autokey, 1, 0);
                return 1;
            }
        }
    }
}

//------------------------------------------------------
// main
//------------------------------------------------------
int main(void) {
    xil_printf("\r\n=== USB Piano Final (Auto+Manual+Volume) ===\r\n");
    xil_printf("Volume:   - = -10%%,  = = +10%%  (range 0~10, default 10)\r\n");
    xil_printf("Waveform: F1=Square F2=Triangle F3=Saw F4=Sine F5=Organ F6=Vibrato\r\n");
    xil_printf("Octave:   [ = down,  ] = up,  Space = reset\r\n");
    xil_printf("CapsLock: toggle Manual / Auto(Peppa Pig) mode\r\n\r\n");

    // GPIO 初始化
    if (XGpio_Initialize(&gpio_keymask, XPAR_GPIO_KEYMASK_DEVICE_ID) != XST_SUCCESS)
        xil_printf("WARN: keymask GPIO init failed\r\n");
    if (XGpio_Initialize(&gpio_autokey, XPAR_GPIO_AUTOKEY_DEVICE_ID) != XST_SUCCESS)
        xil_printf("WARN: autokey GPIO init failed\r\n");
    if (XGpio_Initialize(&gpio_octave,  XPAR_GPIO_OCTAVE_DEVICE_ID)  != XST_SUCCESS)
        xil_printf("WARN: octave GPIO init failed\r\n");
    if (XGpio_Initialize(&gpio_wave,    XPAR_GPIO_WAVE_DEVICE_ID)    != XST_SUCCESS)
        xil_printf("WARN: wave GPIO init failed\r\n");

    XGpio_SetDataDirection(&gpio_keymask, 1, 0);
    XGpio_SetDataDirection(&gpio_autokey, 1, 0);
    XGpio_SetDataDirection(&gpio_octave,  1, 0);
    XGpio_SetDataDirection(&gpio_wave,    1, 0);

    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
    XGpio_DiscreteWrite(&gpio_autokey, 1, 0);
    XGpio_DiscreteWrite(&gpio_octave,  1, 4);        // shift=0 → 写4
    XGpio_DiscreteWrite(&gpio_wave,    1, wave_idx); // Sine

    // DDS 初始化
    silence_all();
    set_enable(1);
    set_wave_dds(wave_idx);
    set_volume_hw(volume);   // 上电写满量

    // 上电自检：A4 200ms
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0x00FFFFFF);
    set_voice(0, 18897);
    delay_ms(200);
    set_voice(0, 0);
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);

    // USB 初始化
    HID_init(); USB_init(); MAX3421E_init();
    xil_printf("USB init done. Volume=%d/10\r\n", volume);

    BOOT_KBD_REPORT kbd;
    unsigned int last_voices[4] = {0};
    unsigned int last_mask      = 0;

    // ============================================================
    // 主循环
    // ============================================================
    while (1) {

        if (auto_mode) {
            run_auto_mode();
            auto_mode = 0;

            // 切回手动模式：恢复波形和音量，清除自动 keymask
            set_wave_dds(wave_idx);
            set_volume_hw(volume);
            XGpio_DiscreteWrite(&gpio_wave,    1, wave_idx);
            XGpio_DiscreteWrite(&gpio_autokey, 1, 0);
            silence_all();
            last_voices[0]=last_voices[1]=last_voices[2]=last_voices[3]=0;
            last_mask = 0;
            XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
            xil_printf("=== MANUAL mode === vol=%d/10\r\n", volume);

        } else {
            MAX3421E_Task(); USB_Task();

            if (GetUsbTaskState() == USB_STATE_RUNNING) {
                BYTE rc = kbdPoll(&kbd);
                if (rc == 0) {
                    // CapsLock 优先检测
                    if (check_capslock_edge(&kbd)) {
                        auto_mode = 1;
                        silence_all();
                        last_voices[0]=last_voices[1]=last_voices[2]=last_voices[3]=0;
                        last_mask = 0;
                        XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
                        xil_printf("=== AUTO mode ===\r\n");
                        continue;
                    }

                    // 正常手动处理
                    unsigned int v[4], m;
                    process_manual(&kbd, v, &m);

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
                }
            } else {
                // 键盘未连接 → 静音
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
    }
    return 0;
}
