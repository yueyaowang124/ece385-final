//=============================================================================
// main_M4b.c  --  完整状态机 (IDLE / SELECT / COUNTDOWN / PLAYING / PAUSED /
//                                WIN / LOSE)
//
// 流程:
//   MANUAL ──Tab──► SELECT ──F7/F8/F9──► COUNTDOWN(3s) ──auto──► PLAYING
//   PLAYING ──P──► PAUSED ──P──► PLAYING
//   PLAYING ──score>=25──► WIN
//   PLAYING ──score<=-10──► LOSE
//   PLAYING ──Tab──► SELECT (放弃)
//   WIN/LOSE ──R──► COUNTDOWN (重玩同曲)
//   WIN/LOSE ──Tab──► SELECT (换曲)
//   *任何状态* ──CapsLock──► AUTO (自动演奏)
//
// auto_keymask 编码:
//   [2:0]   game_state (0..7)
//   [4:3]   selected_song (0..2)
//   [6:5]   countdown_val (3, 2, 1, 0)
//   [14:8]  song progress (0..127)
//
// keymask 编码 (PLAYING 时):
//   [3:0]   ASDF 当前按下
//   [11:4]  score+128
//   [15:12] column flash
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
#define KC_F7  0x40
#define KC_F8  0x41
#define KC_F9  0x42
#define KC_P   0x13
#define KC_R   0x15

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
// 曲谱表
//------------------------------------------------------
typedef struct { unsigned char col; unsigned char delay; } game_event_t;

static const game_event_t SONG1[] = {
    {3, 50}, {2, 50}, {3, 50}, {2, 50},
    {1, 50}, {2, 50}, {3, 50}, {3, 50},
    {2, 50}, {3, 50}, {2, 50}, {3, 50},
    {1, 60}, {0, 60}, {2, 50}, {3, 90},
};
#define SONG1_LEN (sizeof(SONG1)/sizeof(game_event_t))

static const game_event_t SONG2[] = {
    {0, 35}, {0, 35}, {3, 35}, {3, 35},
    {3, 35}, {3, 35}, {2, 70},
    {2, 35}, {2, 35}, {1, 35}, {1, 35},
    {1, 35}, {1, 35}, {0, 90},
};
#define SONG2_LEN (sizeof(SONG2)/sizeof(game_event_t))

static const game_event_t SONG3[] = {
    {0, 25}, {3, 25}, {1, 25}, {2, 25},
    {0, 30}, {3, 25}, {2, 25}, {1, 30},
    {3, 25}, {0, 25}, {2, 25}, {1, 25},
    {3, 30}, {1, 25}, {2, 25}, {0, 25},
    {3, 30}, {2, 80},
};
#define SONG3_LEN (sizeof(SONG3)/sizeof(game_event_t))

static const game_event_t* const SONG_TABLES[3] = { SONG1, SONG2, SONG3 };
static const int SONG_LENS[3]                    = { SONG1_LEN, SONG2_LEN, SONG3_LEN };
static const char* const SONG_NAMES[3]           = { "Easy", "Medium", "Hard" };

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
// 状态机
//------------------------------------------------------
typedef enum {
    GS_MANUAL    = 0,
    GS_AUTO      = 1,
    GS_SELECT    = 2,
    GS_COUNTDOWN = 3,
    GS_PLAYING   = 4,
    GS_PAUSED    = 5,
    GS_WIN       = 6,
    GS_LOSE      = 7
} game_state_t;

static game_state_t game_state    = GS_MANUAL;
static int          sel_song      = 0;     // 0..2
static int          countdown_left= 0;     // 帧数
static int          countdown_val = 0;     // 显示用 0..3

#define WIN_SCORE   25
#define LOSE_SCORE -10

//------------------------------------------------------
// 游戏数据
//------------------------------------------------------
#define MAX_TILES        2
#define TILE_HEIGHT_PX  40
#define TILE_FALL_PX     2
#define TILE_OFFSCREEN_Y 500
#define KEYPAD_CENTER   420
#define PERFECT_DIST     4
#define GOOD_DIST       25
#define MISS_AT_CENTER 460

typedef enum { T_NORMAL=0, T_HIT=1, T_PERFECT=2, T_MISSED=3 } tile_state_t;

typedef struct {
    int active;
    int col;
    int y_top;
    tile_state_t state;
} tile_t;

static tile_t   tiles[MAX_TILES];
static int      score         = 0;
static unsigned col_flash[4]  = {0};
static unsigned hit_note_left = 0;
static unsigned wrong_buzz_left = 0;

static int      song_pos       = 0;
static int      song_delay     = 0;

static const unsigned int COL_NOTE[4] = { 11236, 14152, 16838, 22473 };
#define BUZZ_PHASE_INC  4724

#define HIT_NOTE_FRAMES   12
#define BUZZ_FRAMES       9
#define COL_FLASH_FRAMES  12

#define COUNTDOWN_FRAMES  60   // 每个数字 1 秒

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
//------------------------------------------------------
static inline unsigned int clamp_y9(int y) {
    if (y < 0) return 0;
    if (y > 511) return 511;
    return (unsigned int)y;
}
static inline unsigned int pack_t0(int col, int y, int act, int state) {
    return ((col & 3u) << 14) | (clamp_y9(y) << 5) | ((act & 1u) << 4) | ((state & 3u) << 1);
}
static inline unsigned int pack_t1(int col, int y, int act, int state) {
    return ((col & 3u) << 14) | (clamp_y9(y) << 5) | ((act & 1u) << 4) | ((state & 3u) << 0);
}

static int is_game_ui(void) {
    return (game_state != GS_MANUAL) && (game_state != GS_AUTO);
}

static void push_tile_state(void) {
    unsigned int t0 = pack_t0(tiles[0].col, tiles[0].y_top, tiles[0].active, (int)tiles[0].state);
    unsigned int t1 = pack_t1(tiles[1].col, tiles[1].y_top, tiles[1].active, (int)tiles[1].state);
    unsigned int word = ((t1 & 0xFFFFu) << 16) | (t0 & 0xFFFFu);
    if (is_game_ui()) word |= (1u << 3);
    XGpio_DiscreteWrite(&gpio_tiles_lo, 1, word);
}

static int find_free_tile_slot(void) {
    for (int i = 0; i < MAX_TILES; i++) if (!tiles[i].active) return i;
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

static int find_target_tile(int col) {
    int best = -1, best_y = -1000;
    for (int i = 0; i < MAX_TILES; i++) {
        if (!tiles[i].active || tiles[i].state != T_NORMAL) continue;
        if (tiles[i].col != col) continue;
        if (tiles[i].y_top > best_y) { best = i; best_y = tiles[i].y_top; }
    }
    return best;
}

static int handle_hit(int col) {
    int idx = find_target_tile(col);
    if (idx < 0) return -1;
    int center = tiles[idx].y_top + TILE_HEIGHT_PX / 2;
    int dist = center - KEYPAD_CENTER;
    if (dist < 0) dist = -dist;
    if (dist > GOOD_DIST) return -1;
    if (dist <= PERFECT_DIST) { tiles[idx].state = T_PERFECT; return 1; }
    tiles[idx].state = T_HIT;
    return 0;
}

//------------------------------------------------------
// 边沿检测
//------------------------------------------------------
static int check_capslock_edge(const BOOT_KBD_REPORT *rep) {
    static BYTE prev_keys[6] = {0};
    int fired = 0;
    for (int i = 0; i < 6; i++)
        if (rep->keycode[i] == KC_CAPSLOCK && !was_pressed(KC_CAPSLOCK, prev_keys)) { fired = 1; break; }
    for (int i = 0; i < 6; i++) prev_keys[i] = rep->keycode[i];
    return fired;
}
static int check_keycode_edge(BYTE target, const BOOT_KBD_REPORT *rep, BYTE *prev_keys) {
    int fired = 0;
    for (int i = 0; i < 6; i++)
        if (rep->keycode[i] == target && !was_pressed(target, prev_keys)) { fired = 1; break; }
    for (int i = 0; i < 6; i++) prev_keys[i] = rep->keycode[i];
    return fired;
}

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
// 游戏帧
//------------------------------------------------------
static void update_playing_frame(void) {
    // tile 下落
    for (int i = 0; i < MAX_TILES; i++) {
        if (!tiles[i].active) continue;
        tiles[i].y_top += TILE_FALL_PX;
        if (tiles[i].y_top >= TILE_OFFSCREEN_Y) {
            tiles[i].active = 0;
            tiles[i].state  = T_NORMAL;
        }
    }
    // MISS
    for (int i = 0; i < MAX_TILES; i++) {
        if (!tiles[i].active || tiles[i].state != T_NORMAL) continue;
        int center = tiles[i].y_top + TILE_HEIGHT_PX / 2;
        if (center > MISS_AT_CENTER) {
            tiles[i].state = T_MISSED;
            score--;
            xil_printf("[MISS] col=%d score=%d\r\n", tiles[i].col, score);
        }
    }
    // 曲谱 spawn
    if (song_delay > 0) {
        song_delay--;
    } else {
        const game_event_t* song = SONG_TABLES[sel_song];
        spawn_tile(song[song_pos].col);
        song_delay = song[song_pos].delay;
        song_pos++;
        if (song_pos >= SONG_LENS[sel_song]) {
            song_pos = 0;
            xil_printf("[loop] %s\r\n", SONG_NAMES[sel_song]);
        }
    }
    // 倒计时
    for (int c = 0; c < 4; c++) if (col_flash[c] > 0) col_flash[c]--;
    if (hit_note_left > 0) {
        hit_note_left--;
        if (hit_note_left == 0) set_voice(0, 0);
    }
    if (wrong_buzz_left > 0) {
        wrong_buzz_left--;
        if (wrong_buzz_left == 0) set_voice(1, 0);
    }
    // WIN/LOSE
    if (score >= WIN_SCORE) {
        game_state = GS_WIN;
        silence_all();
        xil_printf("=== WIN! score=%d ===\r\n", score);
    } else if (score <= LOSE_SCORE) {
        game_state = GS_LOSE;
        silence_all();
        xil_printf("=== LOSE score=%d ===\r\n", score);
    }
}

static void process_asdf_press(unsigned edge) {
    if (game_state != GS_PLAYING) return;
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

//------------------------------------------------------
// 状态切换
//------------------------------------------------------
static void enter_select(void) {
    game_state = GS_SELECT;
    silence_all();
    clear_all_tiles();
    xil_printf("=== SELECT (current: %s) ===\r\n", SONG_NAMES[sel_song]);
}

static void enter_countdown(int song_idx) {
    if (song_idx < 0 || song_idx > 2) song_idx = 0;
    sel_song = song_idx;
    song_pos = 0;
    song_delay = 0;
    score = 0;
    for (int c = 0; c < 4; c++) col_flash[c] = 0;
    hit_note_left = 0;
    wrong_buzz_left = 0;
    clear_all_tiles();
    silence_all();
    countdown_left = 3 * COUNTDOWN_FRAMES;
    countdown_val  = 3;
    game_state = GS_COUNTDOWN;
    xil_printf("=== COUNTDOWN [%s, %d events] ===\r\n",
               SONG_NAMES[sel_song], SONG_LENS[sel_song]);
}

static void enter_playing(void) {
    game_state = GS_PLAYING;
    song_delay = 30;     // 进 PLAYING 后 0.5 秒第一个 tile spawn
    xil_printf("=== PLAYING ===\r\n");
}

static void enter_manual(void) {
    game_state = GS_MANUAL;
    silence_all();
    clear_all_tiles();
    xil_printf("=== MANUAL ===\r\n");
}

//------------------------------------------------------
// keymask / auto_keymask 打包
//------------------------------------------------------
static unsigned int build_game_keymask(const BOOT_KBD_REPORT *rep) {
    unsigned int km = 0;
    if (game_state == GS_PLAYING) km |= build_asdf_mask(rep) & 0xF;
    int s = score + 128;
    if (s < 0) s = 0; if (s > 255) s = 255;
    km |= ((unsigned)s & 0xFF) << 4;
    for (int c = 0; c < 4; c++)
        if (col_flash[c] > 0) km |= (1u << (12 + c));
    return km;
}

static unsigned int build_auto_meta(void) {
    unsigned int meta = 0;
    meta |= ((unsigned)game_state) & 7;
    meta |= ((unsigned)sel_song & 3) << 3;
    meta |= ((unsigned)countdown_val & 3) << 5;
    if (game_state == GS_PLAYING) {
        unsigned prog = (song_pos * 127u) / (unsigned)SONG_LENS[sel_song];
        if (prog > 127) prog = 127;
        meta |= (prog & 0x7F) << 8;
    }
    return meta;
}

//------------------------------------------------------
// 手动模式 (沿用)
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
    xil_printf("=== AUTO ===\r\n");
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
    xil_printf("\r\n=== USB Piano + Rhythm Game (Full FSM) ===\r\n");
    xil_printf("MANUAL: piano keys / [ ] Space / -, = / F1-F6 / CapsLock=AUTO\r\n");
    xil_printf("Tab:    enter SELECT screen\r\n");
    xil_printf("SELECT: F7/F8/F9 = pick song, Tab = back to MANUAL\r\n");
    xil_printf("PLAY:   ASDF, P=pause, Tab=quit\r\n");
    xil_printf("WIN/LOSE: R=retry, Tab=select\r\n\r\n");

    if (XGpio_Initialize(&gpio_keymask, XPAR_GPIO_KEYMASK_DEVICE_ID) != XST_SUCCESS)
        xil_printf("WARN: keymask init failed\r\n");
    if (XGpio_Initialize(&gpio_autokey, XPAR_GPIO_AUTOKEY_DEVICE_ID) != XST_SUCCESS)
        xil_printf("WARN: autokey init failed\r\n");
    if (XGpio_Initialize(&gpio_octave,  XPAR_GPIO_OCTAVE_DEVICE_ID)  != XST_SUCCESS)
        xil_printf("WARN: octave init failed\r\n");
    if (XGpio_Initialize(&gpio_wave,    XPAR_GPIO_WAVE_DEVICE_ID)    != XST_SUCCESS)
        xil_printf("WARN: wave init failed\r\n");
    if (XGpio_Initialize(&gpio_tiles_lo, XPAR_GPIO_TILES_LO_DEVICE_ID) != XST_SUCCESS)
        xil_printf("WARN: tiles_lo init failed\r\n");

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
    unsigned int last_auto      = 0;

    static BYTE p_prev[6]   = {0};
    static BYTE r_prev[6]   = {0};
    static BYTE tab_prev[6] = {0};
    static BYTE f7_prev[6]  = {0};
    static BYTE f8_prev[6]  = {0};
    static BYTE f9_prev[6]  = {0};

    clear_all_tiles();
    push_tile_state();

    while (1) {
        if (auto_mode) {
            run_auto_mode();
            auto_mode = 0;
            game_state = GS_MANUAL;
            set_wave_dds(wave_idx);
            set_volume_hw(volume);
            XGpio_DiscreteWrite(&gpio_wave,    1, wave_idx);
            XGpio_DiscreteWrite(&gpio_autokey, 1, 0);
            silence_all();
            last_voices[0]=last_voices[1]=last_voices[2]=last_voices[3]=0;
            last_mask = 0; last_auto = 0;
            XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
            xil_printf("=== MANUAL ===\r\n");
            continue;
        }

        MAX3421E_Task(); USB_Task();

        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BYTE rc = kbdPoll(&kbd);
            if (rc == 0) {
                // CapsLock 总是有效, 跳到 AUTO
                if (check_capslock_edge(&kbd)) {
                    auto_mode = 1;
                    silence_all();
                    last_voices[0]=last_voices[1]=last_voices[2]=last_voices[3]=0;
                    last_mask = 0; last_auto = 0;
                    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
                    XGpio_DiscreteWrite(&gpio_autokey, 1, 0);
                    continue;
                }

                // Tab 边沿
                int tab_edge = check_keycode_edge(KC_TAB, &kbd, tab_prev);
                int p_edge   = check_keycode_edge(KC_P,   &kbd, p_prev);
                int r_edge   = check_keycode_edge(KC_R,   &kbd, r_prev);
                int f7_edge  = check_keycode_edge(KC_F7,  &kbd, f7_prev);
                int f8_edge  = check_keycode_edge(KC_F8,  &kbd, f8_prev);
                int f9_edge  = check_keycode_edge(KC_F9,  &kbd, f9_prev);

                // 按状态分发
                switch (game_state) {
                case GS_MANUAL: {
                    if (tab_edge) { enter_select(); break; }
                    unsigned int v[4], m;
                    process_manual(&kbd, v, &m);
                    for (int i = 0; i < 4; i++) {
                        if (v[i] != last_voices[i]) { set_voice(i, v[i]); last_voices[i] = v[i]; }
                    }
                    if (m != last_mask) { XGpio_DiscreteWrite(&gpio_keymask, 1, m); last_mask = m; }
                    break;
                }
                case GS_SELECT: {
                    if (tab_edge) { enter_manual(); break; }
                    if (f7_edge) enter_countdown(0);
                    else if (f8_edge) enter_countdown(1);
                    else if (f9_edge) enter_countdown(2);
                    break;
                }
                case GS_COUNTDOWN: {
                    if (tab_edge) { enter_select(); break; }
                    // 倒计时结束 → PLAYING (下面的帧推进里处理)
                    break;
                }
                case GS_PLAYING: {
                    if (tab_edge) { enter_select(); break; }
                    if (p_edge)   { game_state = GS_PAUSED; silence_all();
                                    xil_printf("[PAUSED]\r\n"); break; }
                    unsigned edge = check_asdf_edge(&kbd);
                    if (edge) process_asdf_press(edge);
                    break;
                }
                case GS_PAUSED: {
                    if (tab_edge) { enter_select(); break; }
                    if (p_edge)   { game_state = GS_PLAYING;
                                    xil_printf("[RESUMED]\r\n"); break; }
                    break;
                }
                case GS_WIN:
                case GS_LOSE: {
                    if (tab_edge) { enter_select(); break; }
                    if (r_edge)   { enter_countdown(sel_song); break; }
                    break;
                }
                default: break;
                }
            }
        } else {
            if (game_state == GS_MANUAL) {
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

        // ===== 帧推进 (除 MANUAL/AUTO 外都跑 60Hz) =====
        if (is_game_ui()) {
            // COUNTDOWN
            if (game_state == GS_COUNTDOWN) {
                countdown_left--;
                if (countdown_left > 2 * COUNTDOWN_FRAMES)      countdown_val = 3;
                else if (countdown_left > COUNTDOWN_FRAMES)     countdown_val = 2;
                else if (countdown_left > 0)                    countdown_val = 1;
                else { countdown_val = 0; enter_playing(); }
            }

            // PLAYING
            if (game_state == GS_PLAYING) {
                update_playing_frame();
            }
            // PAUSED / WIN / LOSE / SELECT / COUNTDOWN: 不推 tile

            push_tile_state();

            unsigned int km = build_game_keymask(&kbd);
            if (km != last_mask) {
                XGpio_DiscreteWrite(&gpio_keymask, 1, km);
                last_mask = km;
            }
            unsigned int meta = build_auto_meta();
            if (meta != last_auto) {
                XGpio_DiscreteWrite(&gpio_autokey, 1, meta);
                last_auto = meta;
            }
            usleep(16000);
        } else {
            // MANUAL: 把 auto_keymask 设为 state=0
            unsigned int meta = 0;   // GS_MANUAL = 0
            if (meta != last_auto) {
                XGpio_DiscreteWrite(&gpio_autokey, 1, meta);
                last_auto = meta;
            }
            // tile_word_lo 设 game_active=0
            push_tile_state();
        }
    }
    return 0;
}
