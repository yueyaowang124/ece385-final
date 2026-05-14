//=============================================================================
// main_M3.c
//   M2 + 击打判定 + 评分 + 命中音 / 蜂鸣
//
// 新增内容 (相对 M2):
//   - tile 加 state 字段 (NORMAL/HIT/PERFECT/MISSED), 击中后变色继续掉落
//   - tile 不再在 y > 460 时despawn, 改在 y_top > 500 (出屏幕)
//   - ASDF 按下: 在该列找最低 NORMAL tile, 按 中心距 判定:
//        距离 <= 4   PERFECT  +2  voice0 出对应音
//        距离 <= 25  GOOD     +1  voice0 出对应音
//        无 / 太远   WRONG    -1  voice1 蜂鸣 + 列闪红
//   - 每帧检查 NORMAL tile 是否过 MISS 线, 自动 MISSED -1
//   - score 在 keymask[11:4] 显示 (HDL 解码画进度条)
//
// keymask 在游戏模式编码:
//   [3:0]   ASDF 当前按下
//   [11:4]  score+128 (-128..+127)
//   [15:12] column flash (1 bit/列, 错音红闪剩余帧>0 时为 1)
//
// 默认每列对应的音 (后续 M4 会换成曲谱里 tile 自带的 note):
//   A -> C4   S -> E4   D -> G4   F -> C5
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
#define KC_TAB       0x2B
#define KC_CAPSLOCK  0x39
#define KC_MINUS     0x2D
#define KC_EQUAL     0x2E
#define KC_F1  0x3A
#define KC_F2  0x3B
#define KC_F3  0x3C
#define KC_F4  0x3D
#define KC_F5  0x3E
#define KC_F6  0x3F

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

static const PeppaNote SCORE_PEPPA[] = {
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
#define PEPPA_LEN (sizeof(SCORE_PEPPA)/sizeof(PeppaNote))

//------------------------------------------------------
// 全局
//------------------------------------------------------
static XGpio gpio_keymask, gpio_autokey, gpio_octave, gpio_wave;
static XGpio gpio_tiles_lo;

static int          octave_shift = 0;
static unsigned int wave_idx     = 3;
static int          auto_mode    = 0;
static int          volume       = 10;

#define VOLUME_MAX 10
#define VOLUME_MIN  0

//------------------------------------------------------
// 游戏状态
//------------------------------------------------------
#define MAX_TILES        2
#define TILE_HEIGHT_PX  40
#define TILE_FALL_PX     2     // 每帧下落像素
#define SPAWN_INTERVAL  60     // 60 帧 = 1 秒 spawn 一次
#define TILE_OFFSCREEN_Y 500   // y_top 超此值 -> 回收槽

#define KEYPAD_Y0       400
#define KEYPAD_Y1       440
#define KEYPAD_CENTER   420
#define PERFECT_DIST     4    // 中心距 ≤ 4 算 PERFECT
#define GOOD_DIST       25    // 中心距 ≤ 25 算 GOOD
#define MISS_AT_CENTER 460    // tile 中心 > 460 还没击中 -> MISS

typedef enum {
    T_NORMAL  = 0,
    T_HIT     = 1,
    T_PERFECT = 2,
    T_MISSED  = 3
} tile_state_t;

typedef struct {
    int active;
    int col;
    int y_top;
    tile_state_t state;
} tile_t;

static tile_t   tiles[MAX_TILES];
static int      game_running    = 0;
static unsigned spawn_timer     = 0;
static int      next_spawn_col  = 0;
static int      score           = 0;
static unsigned col_flash[4]    = {0};   // 每列错音红闪剩余帧
static unsigned hit_note_left   = 0;     // voice 0 命中音剩余帧
static unsigned wrong_buzz_left = 0;     // voice 1 蜂鸣剩余帧

// 每列对应的"基础音" (M3 用列固定音, M4 改成 tile 自带)
// A=C4(11236), S=E4(14152), D=G4(16838), F=C5(22473)
static const unsigned int COL_NOTE[4] = { 11236, 14152, 16838, 22473 };

// 蜂鸣音: 110 Hz 方波, phase_inc = 110*42.95 ≈ 4724
#define BUZZ_PHASE_INC  4724

#define HIT_NOTE_FRAMES   12      // 200 ms
#define BUZZ_FRAMES       9       // 150 ms
#define COL_FLASH_FRAMES  12      // 200 ms

//------------------------------------------------------
// DDS
//------------------------------------------------------
static inline void set_voice(int v, unsigned int inc) { Xil_Out32(DDS_BASE + v * 4, inc); }
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
// tile 编码
//   t0 (低 16 bit): [15:14] col, [13:5] y, [4] active, [2:1] state
//                   [3] = game_active 标志 (额外加)
//                   [0] = 0 (reserved)
//   t1 (高 16 bit, 即原始 bit [31:16]):
//                   [15:14] col, [13:5] y, [4] active, [1:0] state
//                   [3:2] = 0 (reserved)
//   注意: t0 和 t1 的 state 位置不同 (t0 用 [2:1], t1 用 [1:0]),
//        因为 t1 左移 16 后 state 落在 word 的 [17:16].
//------------------------------------------------------
static inline unsigned int clamp_y9(int y) {
    if (y < 0) return 0;
    if (y > 511) return 511;
    return (unsigned int)y;
}

static inline unsigned int pack_t0(int col, int y, int act, int state) {
    return ((col   & 3u)     << 14) |
           ((clamp_y9(y))    << 5)  |
           ((act   & 1u)     << 4)  |
           ((state & 3u)     << 1);
}

static inline unsigned int pack_t1(int col, int y, int act, int state) {
    return ((col   & 3u)     << 14) |
           ((clamp_y9(y))    << 5)  |
           ((act   & 1u)     << 4)  |
           ((state & 3u)     << 0);
}

static void push_tile_state(int game_active) {
    unsigned int t0 = pack_t0(tiles[0].col, tiles[0].y_top,
                               tiles[0].active, (int)tiles[0].state);
    unsigned int t1 = pack_t1(tiles[1].col, tiles[1].y_top,
                               tiles[1].active, (int)tiles[1].state);
    unsigned int word = ((t1 & 0xFFFFu) << 16) | (t0 & 0xFFFFu);
    if (game_active) word |= (1u << 3);
    XGpio_DiscreteWrite(&gpio_tiles_lo, 1, word);
}

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
    tiles[idx].y_top  = -40;
    tiles[idx].state  = T_NORMAL;
}

static void clear_all_tiles(void) {
    for (int i = 0; i < MAX_TILES; i++) {
        tiles[i].active = 0;
        tiles[i].state  = T_NORMAL;
    }
}

// 找该列最靠下 (y 最大) 且 NORMAL 的 tile, 没有返回 -1
static int find_target_tile(int col) {
    int best = -1;
    int best_y = -1000;
    for (int i = 0; i < MAX_TILES; i++) {
        if (!tiles[i].active || tiles[i].state != T_NORMAL) continue;
        if (tiles[i].col != col) continue;
        if (tiles[i].y_top > best_y) {
            best = i;
            best_y = tiles[i].y_top;
        }
    }
    return best;
}

// 处理一次列击键: 返回 0=GOOD, 1=PERFECT, -1=WRONG
static int handle_hit(int col) {
    int idx = find_target_tile(col);
    if (idx < 0) return -1;     // 该列没有 NORMAL tile
    int center = tiles[idx].y_top + TILE_HEIGHT_PX / 2;
    int dist = center - KEYPAD_CENTER;
    if (dist < 0) dist = -dist;
    if (dist > GOOD_DIST) return -1;  // 太远 (太早) 也算 WRONG
    if (dist <= PERFECT_DIST) {
        tiles[idx].state = T_PERFECT;
        return 1;
    }
    tiles[idx].state = T_HIT;
    return 0;
}

//------------------------------------------------------
// 边沿检测
//------------------------------------------------------
static int check_capslock_edge(const BOOT_KBD_REPORT *rep) {
    static BYTE prev_keys[6] = {0};
    int fired = 0;
    for (int i = 0; i < 6; i++) {
        if (rep->keycode[i] == KC_CAPSLOCK &&
            !was_pressed(KC_CAPSLOCK, prev_keys)) { fired = 1; break; }
    }
    for (int i = 0; i < 6; i++) prev_keys[i] = rep->keycode[i];
    return fired;
}
static int check_tab_edge(const BOOT_KBD_REPORT *rep) {
    static BYTE prev_keys[6] = {0};
    int fired = 0;
    for (int i = 0; i < 6; i++) {
        if (rep->keycode[i] == KC_TAB &&
            !was_pressed(KC_TAB, prev_keys)) { fired = 1; break; }
    }
    for (int i = 0; i < 6; i++) prev_keys[i] = rep->keycode[i];
    return fired;
}

// ASDF 边沿检测: 返回 4 bit 上升沿 mask
static unsigned check_asdf_edge(const BOOT_KBD_REPORT *rep) {
    static unsigned prev = 0;
    unsigned now = 0;
    if (is_pressed_now(KC_A, rep)) now |= 0x1;
    if (is_pressed_now(KC_S, rep)) now |= 0x2;
    if (is_pressed_now(KC_D, rep)) now |= 0x4;
    if (is_pressed_now(KC_F, rep)) now |= 0x8;
    unsigned edge = now & ~prev;
    prev = now;
    return edge;
}

static unsigned int build_asdf_mask(const BOOT_KBD_REPORT *rep) {
    unsigned int m = 0;
    if (is_pressed_now(KC_A, rep)) m |= 0x1;
    if (is_pressed_now(KC_S, rep)) m |= 0x2;
    if (is_pressed_now(KC_D, rep)) m |= 0x4;
    if (is_pressed_now(KC_F, rep)) m |= 0x8;
    return m;
}

//------------------------------------------------------
// 一帧游戏更新
//------------------------------------------------------
static void update_game_frame(void) {
    // 1. tile 下落
    for (int i = 0; i < MAX_TILES; i++) {
        if (!tiles[i].active) continue;
        tiles[i].y_top += TILE_FALL_PX;
        if (tiles[i].y_top >= TILE_OFFSCREEN_Y) {
            tiles[i].active = 0;
            tiles[i].state  = T_NORMAL;
        }
    }
    // 2. 检查 NORMAL tile 是否过 MISS 线
    for (int i = 0; i < MAX_TILES; i++) {
        if (!tiles[i].active || tiles[i].state != T_NORMAL) continue;
        int center = tiles[i].y_top + TILE_HEIGHT_PX / 2;
        if (center > MISS_AT_CENTER) {
            tiles[i].state = T_MISSED;
            score--;
            xil_printf("[MISS] col=%d score=%d\r\n", tiles[i].col, score);
        }
    }
    // 3. 周期 spawn
    spawn_timer++;
    if (spawn_timer >= SPAWN_INTERVAL) {
        spawn_timer = 0;
        spawn_tile(next_spawn_col);
        next_spawn_col = (next_spawn_col + 1) & 3;
    }
    // 4. 列闪红倒计时
    for (int c = 0; c < 4; c++) if (col_flash[c] > 0) col_flash[c]--;
    // 5. 命中音 / 蜂鸣 倒计时
    if (hit_note_left > 0) {
        hit_note_left--;
        if (hit_note_left == 0) set_voice(0, 0);
    }
    if (wrong_buzz_left > 0) {
        wrong_buzz_left--;
        if (wrong_buzz_left == 0) set_voice(1, 0);
    }
}

// 处理 ASDF 上升沿
static void process_asdf_press(unsigned edge) {
    for (int c = 0; c < 4; c++) {
        if (!(edge & (1u << c))) continue;
        int res = handle_hit(c);
        if (res == 1) {
            score += 2;
            set_voice(0, COL_NOTE[c]);
            hit_note_left = HIT_NOTE_FRAMES;
            xil_printf("[PERFECT] col=%d score=%d\r\n", c, score);
        } else if (res == 0) {
            score += 1;
            set_voice(0, COL_NOTE[c]);
            hit_note_left = HIT_NOTE_FRAMES;
            xil_printf("[GOOD] col=%d score=%d\r\n", c, score);
        } else {
            score--;
            col_flash[c]    = COL_FLASH_FRAMES;
            wrong_buzz_left = BUZZ_FRAMES;
            set_voice(1, BUZZ_PHASE_INC);
            xil_printf("[WRONG] col=%d score=%d\r\n", c, score);
        }
    }
}

// 把当前游戏状态打包到 keymask
static unsigned int build_game_keymask(const BOOT_KBD_REPORT *rep) {
    unsigned int km = 0;
    km |= build_asdf_mask(rep) & 0xF;                       // [3:0]
    int s = score + 128;
    if (s < 0)   s = 0;
    if (s > 255) s = 255;
    km |= ((unsigned)s & 0xFF) << 4;                        // [11:4]
    for (int c = 0; c < 4; c++) {
        if (col_flash[c] > 0) km |= (1u << (12 + c));       // [15:12]
    }
    return km;
}

//------------------------------------------------------
// 手动模式
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
            volume--; set_volume_hw(volume);
            xil_printf("volume -> %d/10\r\n", volume);
        }
        else if (kc == KC_EQUAL && volume < VOLUME_MAX) {
            volume++; set_volume_hw(volume);
            xil_printf("volume -> %d/10\r\n", volume);
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
// 自动模式
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
        usleep(step * 1000); elapsed += step;
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
        usleep(step * 1000); elapsed += step;
        MAX3421E_Task(); USB_Task();
        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BOOT_KBD_REPORT tmp;
            if (kbdPoll(&tmp) == 0 && check_capslock_edge(&tmp)) return 1;
        }
    }
    return 0;
}

static int run_auto_mode(void) {
    xil_printf("=== AUTO mode ===\r\n");
    set_wave_dds(0);
    XGpio_DiscreteWrite(&gpio_wave, 1, 0);

    while (1) {
        for (int i = 0; i < (int)PEPPA_LEN; i++) {
            if (play_note_interruptible(&SCORE_PEPPA[i])) {
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
    xil_printf("\r\n=== USB Piano + M3 Rhythm Game ===\r\n");
    xil_printf("Tab:      enter / exit GAME mode\r\n");
    xil_printf("CapsLock: enter AUTO mode (Peppa Pig)\r\n");
    xil_printf("Game:     A S D F = 4 columns\r\n");
    xil_printf("          PERFECT +2, GOOD +1, WRONG/MISS -1\r\n\r\n");

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
    xil_printf("USB init done\r\n");

    BOOT_KBD_REPORT kbd;
    unsigned int last_voices[4] = {0};
    unsigned int last_mask      = 0;

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
            xil_printf("=== MANUAL mode ===\r\n");
            continue;
        }

        MAX3421E_Task(); USB_Task();

        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BYTE rc = kbdPoll(&kbd);
            if (rc == 0) {
                if (check_tab_edge(&kbd)) {
                    game_running = !game_running;
                    silence_all();
                    last_voices[0]=last_voices[1]=last_voices[2]=last_voices[3]=0;
                    if (game_running) {
                        clear_all_tiles();
                        spawn_timer = 0;
                        next_spawn_col = 0;
                        score = 0;
                        for (int c = 0; c < 4; c++) col_flash[c] = 0;
                        hit_note_left = 0;
                        wrong_buzz_left = 0;
                        spawn_tile(0);
                        push_tile_state(1);
                        // 写一次初始 keymask (含 score=0 → score+128=0x80)
                        XGpio_DiscreteWrite(&gpio_keymask, 1, (0x80u << 4));
                        last_mask = (0x80u << 4);
                        xil_printf("=== GAME mode === score=0\r\n");
                    } else {
                        clear_all_tiles();
                        push_tile_state(0);
                        XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
                        last_mask = 0;
                        xil_printf("=== MANUAL mode ===\r\n");
                    }
                    continue;
                }

                if (check_capslock_edge(&kbd)) {
                    auto_mode = 1;
                    if (game_running) {
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
                    // ===== 游戏模式 =====
                    unsigned edge = check_asdf_edge(&kbd);
                    if (edge) process_asdf_press(edge);

                    unsigned int km = build_game_keymask(&kbd);
                    if (km != last_mask) {
                        XGpio_DiscreteWrite(&gpio_keymask, 1, km);
                        last_mask = km;
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

        // 游戏帧推进
        if (game_running) {
            update_game_frame();
            push_tile_state(1);
            // 每帧也要刷一次 keymask, 因为 col_flash 倒计时到 0 时要清掉
            // 但只在 USB_RUNNING 时才能拿到最新 ASDF, 这里复刷一份 (用上次的 ASDF)
            unsigned int km = (last_mask & 0xFu) |
                              ((((unsigned)(score + 128)) & 0xFFu) << 4);
            for (int c = 0; c < 4; c++) {
                if (col_flash[c] > 0) km |= (1u << (12 + c));
            }
            if (km != last_mask) {
                XGpio_DiscreteWrite(&gpio_keymask, 1, km);
                last_mask = km;
            }
            usleep(16000);
        }
    }
    return 0;
}
