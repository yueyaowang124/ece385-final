//=============================================================================
// main_M2.c  --  M1 + tile 下落 + 游戏模式 layout 切换
//
// 新增内容 (相对 M1):
//   - Tab 键 (0x2B) 进入/退出游戏模式
//   - 游戏模式下 tile 自动下落 + 周期 spawn (M2 演示用)
//   - tile_word_lo[3] 作为 game_active 标志位, HDL 据此切换 UI
//   - 游戏模式时 keymask[3:0] 直接反映 ASDF 按下状态 (用于按键指示框高亮),
//     不再驱动手动钢琴 (避免按 ASDF 出钢琴音)
//
// 注意: 硬件 tile 槽只有 2 个, 所以 MAX_TILES = 2.
//       M3 加更多 GPIO 后可以扩到 8.
//=============================================================================

#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xgpio.h"
#include <unistd.h>

#undef TRUE
#undef FALSE
#include "project_config.h"

#define DDS_BASE        0x44A00000
#define REG_PHASE_0     0x00
#define REG_PHASE_1     0x04
#define REG_PHASE_2     0x08
#define REG_PHASE_3     0x0C
#define REG_ENABLE      0x10
#define REG_WAVE_SEL    0x14
#define REG_VOLUME      0x18

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
#ifndef XPAR_GPIO_TILES_LO_DEVICE_ID
  #define XPAR_GPIO_TILES_LO_DEVICE_ID XPAR_AXI_GPIO_TILES_LO_DEVICE_ID
#endif

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

#define KC_LBRACKET  0x2F
#define KC_RBRACKET  0x30
#define KC_SPACE     0x2C
#define KC_TAB       0x2B   // ===== M2: 游戏模式开关 =====
#define KC_CAPSLOCK  0x39
#define KC_MINUS     0x2D
#define KC_EQUAL     0x2E
#define KC_F1  0x3A
#define KC_F2  0x3B
#define KC_F3  0x3C
#define KC_F4  0x3D
#define KC_F5  0x3E
#define KC_F6  0x3F

// ===== M2: ASDF 的 HID code =====
#define KC_A   0x04
#define KC_S   0x16
#define KC_D   0x07
#define KC_F   0x09

static const char *WAVE_NAMES[8] = {
    "Square","Triangle","Sawtooth","Sine","Organ","Vibrato","---","---"
};

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
    uint32_t auto_mask;
} PeppaNote;

static const PeppaNote SCORE[] = {
    {NOTE_G5, NOTE_G4, NOTE_C4, 2, 0x080081},
    {NOTE_E5, REST,    REST,    1, 0x010000},
    {NOTE_C5, REST,    REST,    1, 0x001000},
    {NOTE_D5, NOTE_B4, NOTE_G4, 2, 0x004880},
    {NOTE_G5, NOTE_G4, NOTE_G3, 2, 0x080080},
    {NOTE_G4, REST,    NOTE_G3, 1, 0x000080},
    {NOTE_B4, REST,    REST,    1, 0x000800},
    {NOTE_D5, NOTE_B4, NOTE_G4, 1, 0x004880},
    {NOTE_F5, REST,    REST,    1, 0x020000},
    {NOTE_E5, NOTE_C5, NOTE_C4, 2, 0x011001},
    {NOTE_C5, NOTE_G4, NOTE_C4, 2, 0x001081},
    {NOTE_E5, NOTE_C5, NOTE_C4, 3, 0x011001},
    {NOTE_E5, REST,    REST,    1, 0x010000},
    {NOTE_G5, NOTE_G4, NOTE_C4, 2, 0x080081},
    {REST,    REST,    REST,    2, 0x000000},
};
#define SCORE_LEN (sizeof(SCORE)/sizeof(PeppaNote))

//------------------------------------------------------
// 全局状态
//------------------------------------------------------
static XGpio gpio_keymask, gpio_autokey, gpio_octave, gpio_wave;
static XGpio gpio_tiles_lo;

static int          octave_shift = 0;
static unsigned int wave_idx     = 3;
static int          auto_mode    = 0;
static int          volume       = 10;

#define VOLUME_MAX 10
#define VOLUME_MIN  0

// ===== M2: 游戏状态 =====
#define MAX_TILES  2     // 当前 1 个 GPIO = 2 槽

typedef struct {
    int active;
    int col;        // 0..3
    int y_top;      // -40..480
} tile_t;

static tile_t tiles[MAX_TILES];
static int    game_running   = 0;
static unsigned spawn_timer  = 0;
static int    next_spawn_col = 0;

// 几何参数 (与 HDL 保持一致)
#define TILE_FALL_Y0    0       // tile 出生位置 (将以 -40 起步, 渐入顶部)
#define TILE_FLOOR_Y    480     // tile 出屏幕
#define TILE_FALL_PX    2       // 每帧下落 2 px
#define SPAWN_INTERVAL  35      // 35 帧 ≈ 0.6 秒 spawn 一个

//------------------------------------------------------
// DDS / 通用辅助
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

static int is_pressed_now(BYTE target, const BOOT_KBD_REPORT *rep) {
    for (int i = 0; i < 6; i++) if (rep->keycode[i] == target) return 1;
    return 0;
}

//------------------------------------------------------
// M2: tile 打包 + 写 GPIO
//------------------------------------------------------
static inline unsigned int pack_tile(unsigned int col, unsigned int y, unsigned int act) {
    unsigned int yc = (y > 511) ? 511 : (unsigned int)y;
    return ((col & 3u) << 14) | ((yc & 0x1FFu) << 5) | ((act & 1u) << 4);
}

// 把 tiles[] + game_active 标志 一起写到硬件
static void push_tile_state(int game_active) {
    unsigned int t0 = pack_tile(tiles[0].col,
                                 (tiles[0].y_top < 0) ? 0 : (unsigned)tiles[0].y_top,
                                 tiles[0].active);
    unsigned int t1 = pack_tile(tiles[1].col,
                                 (tiles[1].y_top < 0) ? 0 : (unsigned)tiles[1].y_top,
                                 tiles[1].active);
    unsigned int word = ((t1 & 0xFFFFu) << 16) | (t0 & 0xFFFFu);
    if (game_active) word |= (1u << 3);   // 占用 t0 的 reserved bit[3]
    XGpio_DiscreteWrite(&gpio_tiles_lo, 1, word);
}

// 找一个空 tile 槽, 没空位返回 -1
static int find_free_tile_slot(void) {
    for (int i = 0; i < MAX_TILES; i++) {
        if (!tiles[i].active) return i;
    }
    return -1;
}

static void spawn_tile(int col) {
    int idx = find_free_tile_slot();
    if (idx < 0) return;
    tiles[idx].active = 1;
    tiles[idx].col    = col;
    tiles[idx].y_top  = -40;       // 顶部外, 渐入屏幕
}

static void clear_all_tiles(void) {
    for (int i = 0; i < MAX_TILES; i++) tiles[i].active = 0;
}

// 一帧游戏更新: tile 下落 + 周期 spawn
static void update_game_frame(void) {
    // 1. tile 下落
    for (int i = 0; i < MAX_TILES; i++) {
        if (!tiles[i].active) continue;
        tiles[i].y_top += TILE_FALL_PX;
        if (tiles[i].y_top >= TILE_FLOOR_Y) {
            tiles[i].active = 0;     // 出屏幕回收槽
        }
    }
    // 2. 周期 spawn
    spawn_timer++;
    if (spawn_timer >= SPAWN_INTERVAL) {
        spawn_timer = 0;
        spawn_tile(next_spawn_col);
        next_spawn_col = (next_spawn_col + 1) & 3;   // 0->1->2->3->0
    }
}

//------------------------------------------------------
// 边沿检测: CapsLock / Tab
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

static int check_tab_edge(const BOOT_KBD_REPORT *rep) {
    static BYTE prev_keys[6] = {0};
    int fired = 0;
    for (int i = 0; i < 6; i++) {
        if (rep->keycode[i] == KC_TAB &&
            !was_pressed(KC_TAB, prev_keys)) {
            fired = 1; break;
        }
    }
    for (int i = 0; i < 6; i++) prev_keys[i] = rep->keycode[i];
    return fired;
}

//------------------------------------------------------
// 游戏模式: 把 ASDF 当前按下状态打包到 keymask[3:0]
// (复用现有 keymask GPIO, HDL 在 game_active=1 时把 bit0..3 当 ASDF 指示灯)
//------------------------------------------------------
static unsigned int build_asdf_mask(const BOOT_KBD_REPORT *rep) {
    unsigned int m = 0;
    if (is_pressed_now(KC_A, rep)) m |= (1u << 0);
    if (is_pressed_now(KC_S, rep)) m |= (1u << 1);
    if (is_pressed_now(KC_D, rep)) m |= (1u << 2);
    if (is_pressed_now(KC_F, rep)) m |= (1u << 3);
    return m;
}

//------------------------------------------------------
// 手动模式: 处理 HID 报告
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
// 自动模式 (沿用)
//------------------------------------------------------
static int play_note_interruptible(const PeppaNote *note) {
    uint32_t total_ms = note->ticks * TICK_MS;
    uint32_t duty_ms  = total_ms * (100 - MUTE_RATIO) / 100;
    uint32_t pause_ms = total_ms - duty_ms;

    Xil_Out32(DDS_BASE + REG_PHASE_0, note->ch0);
    Xil_Out32(DDS_BASE + REG_PHASE_1, note->ch1);
    Xil_Out32(DDS_BASE + REG_PHASE_2, note->ch2);
    XGpio_DiscreteWrite(&gpio_autokey, 1, note->auto_mask);

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

    Xil_Out32(DDS_BASE + REG_PHASE_0, 0);
    Xil_Out32(DDS_BASE + REG_PHASE_1, 0);
    Xil_Out32(DDS_BASE + REG_PHASE_2, 0);
    XGpio_DiscreteWrite(&gpio_autokey, 1, 0);

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

static int run_auto_mode(void) {
    xil_printf("=== AUTO mode: Peppa Pig ===\r\n");
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
    xil_printf("\r\n=== USB Piano + M2 Falling Game ===\r\n");
    xil_printf("Volume:   - / =\r\n");
    xil_printf("Waveform: F1..F6\r\n");
    xil_printf("Octave:   [ ] Space\r\n");
    xil_printf("CapsLock: Manual / Auto\r\n");
    xil_printf("Tab:      enter / exit GAME mode (M2 demo: tiles fall)\r\n\r\n");

    if (XGpio_Initialize(&gpio_keymask, XPAR_GPIO_KEYMASK_DEVICE_ID) != XST_SUCCESS)
        xil_printf("WARN: keymask GPIO init failed\r\n");
    if (XGpio_Initialize(&gpio_autokey, XPAR_GPIO_AUTOKEY_DEVICE_ID) != XST_SUCCESS)
        xil_printf("WARN: autokey GPIO init failed\r\n");
    if (XGpio_Initialize(&gpio_octave,  XPAR_GPIO_OCTAVE_DEVICE_ID)  != XST_SUCCESS)
        xil_printf("WARN: octave GPIO init failed\r\n");
    if (XGpio_Initialize(&gpio_wave,    XPAR_GPIO_WAVE_DEVICE_ID)    != XST_SUCCESS)
        xil_printf("WARN: wave GPIO init failed\r\n");
    if (XGpio_Initialize(&gpio_tiles_lo, XPAR_GPIO_TILES_LO_DEVICE_ID) != XST_SUCCESS)
        xil_printf("WARN: tiles_lo GPIO init failed\r\n");

    XGpio_SetDataDirection(&gpio_keymask,  1, 0);
    XGpio_SetDataDirection(&gpio_autokey,  1, 0);
    XGpio_SetDataDirection(&gpio_octave,   1, 0);
    XGpio_SetDataDirection(&gpio_wave,     1, 0);
    XGpio_SetDataDirection(&gpio_tiles_lo, 1, 0);

    XGpio_DiscreteWrite(&gpio_keymask,  1, 0);
    XGpio_DiscreteWrite(&gpio_autokey,  1, 0);
    XGpio_DiscreteWrite(&gpio_octave,   1, 4);
    XGpio_DiscreteWrite(&gpio_wave,     1, wave_idx);
    XGpio_DiscreteWrite(&gpio_tiles_lo, 1, 0);

    silence_all();
    set_enable(1);
    set_wave_dds(wave_idx);
    set_volume_hw(volume);

    XGpio_DiscreteWrite(&gpio_keymask, 1, 0x00FFFFFF);
    set_voice(0, 18897);
    delay_ms(200);
    set_voice(0, 0);
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);

    HID_init(); USB_init(); MAX3421E_init();
    xil_printf("USB init done. Volume=%d/10\r\n", volume);

    BOOT_KBD_REPORT kbd;
    unsigned int last_voices[4] = {0};
    unsigned int last_mask      = 0;

    // tiles 初始化
    clear_all_tiles();
    push_tile_state(0);

    while (1) {
        if (auto_mode) {
            run_auto_mode();
            auto_mode = 0;

            set_wave_dds(wave_idx);
            set_volume_hw(volume);
            XGpio_DiscreteWrite(&gpio_wave,    1, wave_idx);
            XGpio_DiscreteWrite(&gpio_autokey, 1, 0);
            silence_all();
            last_voices[0]=last_voices[1]=last_voices[2]=last_voices[3]=0;
            last_mask = 0;
            XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
            xil_printf("=== MANUAL mode === vol=%d/10\r\n", volume);
            continue;
        }

        MAX3421E_Task(); USB_Task();

        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BYTE rc = kbdPoll(&kbd);
            if (rc == 0) {
                // ============== Tab: 切换游戏模式 ==============
                if (check_tab_edge(&kbd)) {
                    game_running = !game_running;
                    silence_all();
                    last_voices[0]=last_voices[1]=last_voices[2]=last_voices[3]=0;

                    if (game_running) {
                        clear_all_tiles();
                        spawn_timer = 0;
                        next_spawn_col = 0;
                        spawn_tile(0);
                        last_mask = 0;
                        XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
                        push_tile_state(1);
                        xil_printf("=== GAME mode ===\r\n");
                    } else {
                        clear_all_tiles();
                        push_tile_state(0);
                        last_mask = 0;
                        XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
                        xil_printf("=== MANUAL mode ===\r\n");
                    }
                    continue;
                }

                // ============== CapsLock: 自动模式 ==============
                if (check_capslock_edge(&kbd)) {
                    auto_mode = 1;
                    if (game_running) {
                        // 退出游戏模式
                        game_running = 0;
                        clear_all_tiles();
                        push_tile_state(0);
                    }
                    silence_all();
                    last_voices[0]=last_voices[1]=last_voices[2]=last_voices[3]=0;
                    last_mask = 0;
                    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
                    xil_printf("=== AUTO mode ===\r\n");
                    continue;
                }

                if (game_running) {
                    // ===== 游戏模式: 不弹钢琴, 只把 ASDF 写到 keymask =====
                    unsigned int asdf = build_asdf_mask(&kbd);
                    if (asdf != last_mask) {
                        XGpio_DiscreteWrite(&gpio_keymask, 1, asdf);
                        last_mask = asdf;
                    }
                } else {
                    // ===== 手动模式 =====
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

        // ============== 游戏帧推进 (~60Hz) ==============
        if (game_running) {
            update_game_frame();
            push_tile_state(1);
            usleep(16000);     // 16ms ≈ 60Hz
        }
    }
    return 0;
}
