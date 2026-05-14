#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xgpio.h"
#include <unistd.h>
#include "sd_spi.h"

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
#ifndef XPAR_GPIO_TILES_HI_DEVICE_ID
  #define XPAR_GPIO_TILES_HI_DEVICE_ID XPAR_AXI_GPIO_TILES_HI_DEVICE_ID
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
#define KC_ENTER 0x28
#define KC_DOWN  0x51
#define KC_LEFT  0x50
#define KC_RIGHT 0x4F
#define KC_UP    0x52

__attribute__((unused))
static const char *WAVE_NAMES[8] = {
    "Square","Triangle","Sawtooth","Sine","Organ","Vibrato","---","---"
};

#define REST      0
#define NOTE_A2   4725

#define NOTE_C3   5618
#define NOTE_CS3  5952   // C# / Db
#define NOTE_D3   6304
#define NOTE_DS3  6681   // D# / Eb
#define NOTE_E3   7079
#define NOTE_F3   7500
#define NOTE_FS3  7946   // F# / Gb
#define NOTE_G3   8419
#define NOTE_GS3  8919   // G# / Ab
#define NOTE_A3   9449
#define NOTE_AS3  10011  // A# / Bb
#define NOTE_B3   10606

#define NOTE_C4   11236
#define NOTE_CS4  11904
#define NOTE_D4   12608
#define NOTE_DS4  13362
#define NOTE_E4   14157
#define NOTE_F4   15000
#define NOTE_FS4  15892
#define NOTE_G4   16838
#define NOTE_GS4  17838
#define NOTE_A4   18898
#define NOTE_AS4  20022
#define NOTE_B4   21213

#define NOTE_C5   22473
#define NOTE_CS5  23808
#define NOTE_D5   25215
#define NOTE_DS5  26724
#define NOTE_E5   28314
#define NOTE_F5   30000
#define NOTE_FS5  31784
#define NOTE_G5   33676
#define NOTE_GS5  35676
#define NOTE_A5   37794
#define NOTE_AS5  40044
#define NOTE_B5   42426

// --- 6 组 (倍高音组) ---
#define NOTE_C6   44946
#define NOTE_CS6  47616
#define NOTE_D6   50430
#define NOTE_DS6  53448
#define NOTE_E6   56628
#define NOTE_F6   60000
#define NOTE_FS6  63568
#define NOTE_G6   67352
#define NOTE_GS6  71352
#define NOTE_A6   75588
#define NOTE_AS6  80088
#define NOTE_B6   84852

// --- 7 组 (更高音边界) ---
#define NOTE_C7   89892

#define TICK_MS    125
#define MUTE_RATIO 30

static int final_stars = 0;

#define NUM_SONGS 3

static int best_score[NUM_SONGS] = {0, 0, 0};
static int is_infinite_mode = 0;
static int is_new_best = 0;

static int ending_timer = -1;
static int loop_counter = 0;

static unsigned int last_voices[4] = {0};
static unsigned int last_mask      = 0;
static unsigned int last_auto      = 0;


typedef struct {
    uint32_t ch0, ch1, ch2;
    uint32_t duration_ms;
    uint32_t auto_mask;
} PeppaNote;

//------------------------------------------------------
// SD 卡曲库
//------------------------------------------------------
#define SONG_BASE_BLOCK     1024
#define SLOT_BLOCKS         16          // 每首歌 16 sectors = 8KB = ~408 notes
#define MAX_SLOTS           4           // 最多 4 首
#define MAX_NOTES_PER_SLOT  408

static PeppaNote g_sd_song[MAX_NOTES_PER_SLOT];
static int       g_sd_song_len = 0;
static int       g_sd_ready    = 0;
static int       g_sd_init_err = 999;   // 999 = 还没尝试过

// 从 SD 卡 slot N 加载曲谱到 g_sd_song
// 返回 note 数, < 0 = 失败
__attribute__((unused))
static int load_song_from_sd(int slot) {
    if (slot < 0 || slot >= MAX_SLOTS) return -1;

    if (!g_sd_ready) {
        g_sd_init_err = sd_init();
        if (g_sd_init_err != 0) return -2;
        g_sd_ready = 1;
    }

    uint32_t base = SONG_BASE_BLOCK + slot * SLOT_BLOCKS;
    uint8_t  buf[512];

    // 第 0 块: 头 4 字节 = note count, 后面是 25 个 note
    if (sd_read_block(base, buf) != 0) return -3;
    uint32_t count = ((uint32_t)buf[0])       | ((uint32_t)buf[1] << 8)
                   | ((uint32_t)buf[2] << 16) | ((uint32_t)buf[3] << 24);
    if (count > MAX_NOTES_PER_SLOT) count = MAX_NOTES_PER_SLOT;
    if (count == 0) return -4;

    int notes_in_block_0 = (512 - 4) / 20;   // 25
    int written = 0;
    for (int i = 0; i < (int)count && i < notes_in_block_0; i++) {
        const uint8_t *p = buf + 4 + i * 20;
        g_sd_song[i].ch0 = ((uint32_t)p[0])  | ((uint32_t)p[1] << 8)  | ((uint32_t)p[2] << 16)  | ((uint32_t)p[3] << 24);
        g_sd_song[i].ch1 = ((uint32_t)p[4])  | ((uint32_t)p[5] << 8)  | ((uint32_t)p[6] << 16)  | ((uint32_t)p[7] << 24);
        g_sd_song[i].ch2 = ((uint32_t)p[8])  | ((uint32_t)p[9] << 8)  | ((uint32_t)p[10]<< 16)  | ((uint32_t)p[11]<< 24);
        g_sd_song[i].duration_ms    = ((uint32_t)p[12]) | ((uint32_t)p[13]<< 8) | ((uint32_t)p[14]<< 16) | ((uint32_t)p[15]<< 24);
        g_sd_song[i].auto_mask= ((uint32_t)p[16]) | ((uint32_t)p[17]<< 8) | ((uint32_t)p[18]<< 16) | ((uint32_t)p[19]<< 24);
        written++;
    }

    // 后续块
    int notes_per_full_block = 512 / 20;   // 25
    int next_block = 1;
    while (written < (int)count && next_block < SLOT_BLOCKS) {
        if (sd_read_block(base + next_block, buf) != 0) return -3;
        for (int i = 0; i < notes_per_full_block && written < (int)count; i++, written++) {
            const uint8_t *p = buf + i * 20;
            g_sd_song[written].ch0 = ((uint32_t)p[0])  | ((uint32_t)p[1] << 8)  | ((uint32_t)p[2] << 16)  | ((uint32_t)p[3] << 24);
            g_sd_song[written].ch1 = ((uint32_t)p[4])  | ((uint32_t)p[5] << 8)  | ((uint32_t)p[6] << 16)  | ((uint32_t)p[7] << 24);
            g_sd_song[written].ch2 = ((uint32_t)p[8])  | ((uint32_t)p[9] << 8)  | ((uint32_t)p[10]<< 16)  | ((uint32_t)p[11]<< 24);
            g_sd_song[written].duration_ms    = ((uint32_t)p[12]) | ((uint32_t)p[13]<< 8) | ((uint32_t)p[14]<< 16) | ((uint32_t)p[15]<< 24);
            g_sd_song[written].auto_mask= ((uint32_t)p[16]) | ((uint32_t)p[17]<< 8) | ((uint32_t)p[18]<< 16) | ((uint32_t)p[19]<< 24);
        }
        next_block++;
    }

    g_sd_song_len = (int)count;
    return g_sd_song_len;
}

typedef struct {
    signed char col1, note1;
    signed char col2, note2;     // -1 表示无 chord
    unsigned char delay;
	unsigned char is_long;        // ★ NEW: 这个 tile 是不是长 tile
} game_event_t;
#include "harry_potter_score.h"
#include "mario_auto_ms.h"
#include "NOKIA_auto_ms.h"
#include "summer_auto_ms.h"
#include "imperial_march_auto_ms.h"
#include "game_of_thrones_auto_ms.h"
#include "cantina_band_auto_ms.h"
#include "mii_channel_auto_ms.h"
// 1 tick = 30 frames = 500ms (4 slots 能撑住的节拍)
#define T1  30
#define T2  60
#define T3  90

// Twinkle Twinkle (左手 C 大调和弦伴奏)
// CC GG AA G | FF EE DD C
//                C major     G major
static const game_event_t SONG_TWINKLE[] = {
{ 3, 19, -1,  0, T2 },
{ 3, 16, -1,  0, T1 },
{ 2, 12, -1,  0, T1 },
{ 2, 14, -1,  0, T2 },
{ 1,  7, -1,  0, T1 },
{ 3,  7, -1,  0, T1 },
{ 1, 11, -1,  0, T1 },
{ 2, 14, -1,  0, T1 },
{ 3, 17, -1,  0, T1 },
{ 3, 16, -1,  0, T2 },
{ 2, 12, -1,  0, T2 },
{ 3, 16, -1,  0, T3 },
{ 3, 16, -1,  0, T1 },
{ 3, 19, -1,  0, T2 },
{-1,  0, -1,  0, T2 }
};
#define SONG1_LEN (sizeof(SONG_TWINKLE)/sizeof(game_event_t))


static const game_event_t SONG_PEPPA[] = {
    { 2, 12,  0,  0, T1 },   // C5 + C4
    { 2, 12, -1,  0, T1 },   // C5
    { 3, 19,  0,  0, T1 },   // G5 + C4
    { 3, 19, -1,  0, T1 },   // G5
    { 3, 21,  1,  9, T1 },   // A5 + A4
    { 3, 21, -1,  0, T1 },   // A5
    { 3, 19,  0,  0, T2 },   // G5 + C4
    { 3, 17,  1,  5, T1 },   // F5 + F4
    { 3, 17, -1,  0, T1 },   // F5
    { 3, 16, -1,  0, T1 },   // E5
    { 3, 16,  0,  0, T1 },   // E5 + C4
    { 2, 14,  1,  7, T1 },   // D5 + G4
    { 2, 14, -1,  0, T1 },   // D5
    { 2, 12,  0,  0, T2 },   // C5 + C4
    {-1,  0, -1,  0, T1 },
	{-1,  0, -1,  0, T2 },
    {-1,  0, -1,  0, T2 }

};
#define SONG2_LEN (sizeof(SONG_PEPPA)/sizeof(game_event_t))

#define SONG3_LEN (sizeof(SONG_HARRY)/sizeof(game_event_t))

static const game_event_t* const SONG_TABLES[3] = { SONG_TWINKLE, SONG_PEPPA, SONG_HARRY_GAME };
static const int          SONG_LENS[3]          = { SONG1_LEN,  SONG2_LEN,    HARRY_GAME_LEN };
static const char* const  SONG_NAMES[3]         = { "Peppa",    "Twinkle",    "Harry"   };

/* ── 曲库 (Auto-play song library) ── */
typedef struct {
    const PeppaNote *notes;
    int              len;
} AutoSongEntry;
static const AutoSongEntry AUTO_LIB[] = {
    { SCORE_HARRY_AUTO,    HARRY_AUTO_LEN    },  // 0: Harry Potter
    { SCORE_MARIO_AUTO,    MARIO_AUTO_LEN    },  // 1: Super Mario
    { SCORE_NOKIA_AUTO,    NOKIA_AUTO_LEN    },  // 2: NOKIA
    { SCORE_SUMMER_AUTO,   SUMMER_AUTO_LEN   },  // 3: Summer
    { SCORE_IMPERIAL_AUTO, IMPERIAL_AUTO_LEN },  // 4: Imperial March
    { SCORE_GOT_AUTO,      GOT_AUTO_LEN      },  // 5: Game of Thrones
    { SCORE_CANTINA_AUTO,  CANTINA_AUTO_LEN  },  // 6: Cantina Band
    { SCORE_MII_AUTO,      MII_AUTO_LEN      },  // 7: Mii Channel
};
#define AUTO_LIB_SIZE  ((int)(sizeof(AUTO_LIB)/sizeof(AUTO_LIB[0])))

//------------------------------------------------------
// 全局
//------------------------------------------------------
static XGpio gpio_keymask, gpio_autokey, gpio_octave, gpio_wave;
static XGpio gpio_tiles_lo, gpio_tiles_hi;       // ★ M4d: 加 hi

static int          octave_shift = 0;
static unsigned int wave_idx     = 3;
static int          auto_mode    = 0;
static int          auto_select_active = 0;   // 1 = 曲库选歌界面打开
static int          auto_song_sel      = 0;   // 当前高亮的曲库条目
static int          auto_song_to_play  = 0;   // Enter 后要播放的条目
static int          volume       = 10;

static unsigned int g_asdf_held = 0;   // 当前帧 ASDF 按住状态

#define VOLUME_MAX 10
#define VOLUME_MIN  0

typedef enum {
    GS_MANUAL=0, GS_AUTO=1, GS_SELECT=2, GS_COUNTDOWN=3,
    GS_PLAYING=4, GS_PAUSED=5, GS_WIN=6, GS_LOSE=7
} game_state_t;

static game_state_t game_state    = GS_MANUAL;
static int          sel_song      = 0;
static int          countdown_left= 0;
static int          countdown_val = 0;

#define MAX_TILES        4         // ★ M4d: 4 槽
#define TILE_HEIGHT_PX  40
#define TILE_FALL_PX_BASE     9
#define TILE_FALL_PX_MAX   20
#define TILE_OFFSCREEN_Y 471
#define KEYPAD_CENTER   380
#define PERFECT_DIST     8
#define GOOD_DIST       32
#define MISS_AT_CENTER (KEYPAD_CENTER+GOOD_DIST+4)
#define COUNTDOWN_FRAMES 60

#define LONG_TILE_PX     120
#define HOLD_FRAME_TICK   6      // 每 6 帧 hold +1
#define HOLD_BONUS        5
#define KC_REL_THRESH     0      // ASDF 边沿释放检测
// 长 tile 尾巴离开 keypad 的 Y 坐标 (= KEYPAD_CENTER + TILE_HEIGHT_PX)
// tail_y >= G_KEYPAD_Y1 表示整个 hold 区已经穿过判定线 → 给 hold bonus
#define G_KEYPAD_Y1     (KEYPAD_CENTER + TILE_HEIGHT_PX)   // 420

typedef enum { T_NORMAL=0, T_HIT=1, T_PERFECT=2, T_MISSED=3 } tile_state_t;

typedef struct {
    int         active;
    int         col;
    int         y_top;
    signed char note;
    tile_state_t state;
	unsigned char is_long;        // 1=长 tile (120px), 0=短 (40px)
    int          hold_started;    // 玩家按下了 head
    int          hold_frames;     // 已经持续按住几帧
    unsigned char bonus_given;    // tail bonus 是否已给
    unsigned char held_tried;
} tile_t;

static tile_t   tiles[MAX_TILES];
static int      score         = 0;
static unsigned col_flash[4]  = {0};
static unsigned hit_note_left = 0;
static unsigned wrong_buzz_left = 0;
static int      combo         = 0;
static int      max_combo     = 0;

static int      song_pos       = 0;
static int      song_delay     = 0;
static int tile_fall_px=TILE_FALL_PX_BASE;

#define BUZZ_PHASE_INC  4724
#define HIT_NOTE_FRAMES   12
#define BUZZ_FRAMES       9
#define COL_FLASH_FRAMES  12

static void calculate_and_enter_win(void);

static int check_score_cap_and_finish(void) {
    if (score >= 999) {
        score = 999;
        xil_printf("[SCORE CAP] score reached 99, finish game\r\n");
        calculate_and_enter_win();
        return 1;
    }
    return 0;
}

static void combo_add_hit(void) {
    combo++;

    if (combo > 999)
        combo = 999;

    if (combo > max_combo)
        max_combo = combo;
}

static void combo_break(void) {
    combo = 0;
}


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
static unsigned int inc_for_abs_semi(signed char semi) {
    int idx = C4_INDEX + semi;
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

static inline unsigned int clamp_y9(int y) {
    if (y < 0) return 0;
    if (y > 511) return 511;
    return (unsigned int)y;
}

// "lo" 风格: state 在 [2:1] (t0, t2)
static inline unsigned int pack_tile_lo_style(int col, int y_top, int act, int state, int is_long, int hold) {
    return ((col & 3u) << 14) | (clamp_y9(y_top + 40) << 5) |
           ((act & 1u) << 4) | ((hold & 1u) << 3) |     // ★ 加 hold 在 bit 3
           ((state & 3u) << 1) | (is_long & 1u);
}
// "hi" 风格: state 在 [1:0] (t1, t3, 移到高 16 位后变 [17:16])
static inline unsigned int pack_tile_hi_style(int col, int y_top, int act, int state, int is_long, int hold) {
    return ((col & 3u) << 14) | (clamp_y9(y_top + 40) << 5) |
           ((act & 1u) << 4) | ((hold & 1u) << 3) |     // ★ 加 hold 在 bit 3
           ((state & 3u) << 0) | ((is_long & 1u) << 2);
}


static int is_game_ui(void) {
    return (game_state != GS_MANUAL) && (game_state != GS_AUTO);
}

static void push_tile_state(void) {
    int h0 = tiles[0].hold_started && (g_asdf_held & (1 << tiles[0].col));
    int h1 = tiles[1].hold_started && (g_asdf_held & (1 << tiles[1].col));
    int h2 = tiles[2].hold_started && (g_asdf_held & (1 << tiles[2].col));
    int h3 = tiles[3].hold_started && (g_asdf_held & (1 << tiles[3].col));

    unsigned int t0 = pack_tile_lo_style(tiles[0].col, tiles[0].y_top, tiles[0].active, tiles[0].state, tiles[0].is_long, h0);
    unsigned int t1 = pack_tile_hi_style(tiles[1].col, tiles[1].y_top, tiles[1].active, tiles[1].state, tiles[1].is_long, h1);
    unsigned int word_lo = ((t1 & 0xFFFFu) << 16) | (t0 & 0xFFFFu);
    //if (is_game_ui()) word_lo |= (1u << 31);
    XGpio_DiscreteWrite(&gpio_tiles_lo, 1, word_lo);

    unsigned int t2 = pack_tile_lo_style(tiles[2].col, tiles[2].y_top, tiles[2].active, tiles[2].state, tiles[2].is_long, h2);
    unsigned int t3 = pack_tile_hi_style(tiles[3].col, tiles[3].y_top, tiles[3].active, tiles[3].state, tiles[3].is_long, h3);
    unsigned int word_hi = ((t3 & 0xFFFFu) << 16) | (t2 & 0xFFFFu);
    XGpio_DiscreteWrite(&gpio_tiles_hi, 1, word_hi);
}

static int find_free_tile_slot(void) {
    for (int i = 0; i < MAX_TILES; i++) if (!tiles[i].active) return i;
    return -1;
}
static void spawn_tile(int col, signed char note, int is_long) {
    int idx = find_free_tile_slot();
    if (idx < 0) return;
    tiles[idx].active       = 1;
    tiles[idx].col          = col;
    tiles[idx].y_top        = -(is_long ? LONG_TILE_PX : TILE_HEIGHT_PX);  // 顶部外
    tiles[idx].note         = note;
    tiles[idx].state        = T_NORMAL;
    tiles[idx].is_long      = is_long;
    tiles[idx].hold_started = 0;
    tiles[idx].hold_frames  = 0;
    tiles[idx].bonus_given  = 0;
    tiles[idx].held_tried=0;
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

static int handle_hit(int col, int *out_idx) {
    int idx = find_target_tile(col);
    *out_idx = idx;
    if (idx < 0) return -1;

    int tile_h = tiles[idx].is_long ? LONG_TILE_PX : TILE_HEIGHT_PX;
    int head_y = tiles[idx].y_top + tile_h;            // 长 tile 的 head 在底部
    int dist = head_y - KEYPAD_CENTER;
    if (dist < 0) dist = -dist;
    if (dist > GOOD_DIST) return -1;

    tiles[idx].hold_started = 1;
    if (dist <= PERFECT_DIST)
    {
    	tiles[idx].state = T_PERFECT;
    	return 1;
    }
    tiles[idx].state = T_HIT;
    return 0;
}


static void update_holds(unsigned int held_now) {
    g_asdf_held = held_now;

    for (int i = 0; i < MAX_TILES; i++) {
        if (!tiles[i].active) continue;
        if (!tiles[i].is_long) continue;        // 短 tile 不需要 hold 处理
        if (!tiles[i].hold_started) continue;
        if (tiles[i].state == T_MISSED) continue;

        unsigned int col_bit = 1u << tiles[i].col;
        int still_holding = (g_asdf_held & col_bit) != 0;

        if (still_holding) {
            tiles[i].hold_frames++;
            // 每 HOLD_FRAME_TICK 帧 +1
            if ((tiles[i].hold_frames % HOLD_FRAME_TICK) == 0) {
                score++;
                if (check_score_cap_and_finish()) return;
            }
        } else {
            // 玩家放开了, 标记 hold_started=0 但保留状态 (不退分)
            tiles[i].hold_started = 0;
        }

        // 检测 tail 是否离开 keypad → 给 bonus
        int tail_y = tiles[i].y_top;            // 长 tile 的 tail 在顶部
        if (still_holding && !tiles[i].bonus_given && tail_y >= G_KEYPAD_Y1) {
            score += HOLD_BONUS;
            tiles[i].bonus_given = 1;
            if (check_score_cap_and_finish()) return;
            xil_printf("[HOLD BONUS] +%d, score=%d\r\n", HOLD_BONUS, score);
        }
    }
}

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

// 根据当前分数计算应该亮几颗星 (跟 calculate_and_enter_win 用同样的阈值)
static int calc_progressive_stars(int song_idx, int cur_score) {
    int stars = 0;
    if (song_idx == 0) {              // Peppa
        if (cur_score >= 25) stars = 1;
        if (cur_score >= 40) stars = 2;
        if (cur_score >= 60) stars = 3;
    } else if (song_idx == 1) {       // Twinkle
        if (cur_score >= 25) stars = 1;
        if (cur_score >= 50) stars = 2;
        if (cur_score >= 80) stars = 3;
    } else {                          // Harry
        if (cur_score >= 90) stars = 1;
        if (cur_score >= 130) stars = 2;
        if (cur_score >= 170) stars = 3;
    }
    return stars;
}

static void calculate_and_enter_win(void) {
	combo=0;
	max_combo=0;
    final_stars = 1;

    if (sel_song == 0) {
        if (score >= 45)      final_stars = 3;
        else if (score >= 25) final_stars = 2;
    }
    else if (sel_song == 1) {
        if (score >= 70)      final_stars = 3;
        else if (score >= 40) final_stars = 2;
    }
    else {
        if (score >= 60)      final_stars = 3;
        else if (score >= 30) final_stars = 2;
    }

    is_new_best = 0;

    // 必须严格大于最高分，等于不算新纪录
    if (score > best_score[sel_song]) {
        best_score[sel_song] = score;
        is_new_best = 1;
    }

    game_state = GS_WIN;
    silence_all();
    clear_all_tiles();
    push_tile_state();

    xil_printf("=== WIN === Song:%d Score:%d Best:%d Stars:%d NewBest:%d Infinite:%d\r\n",
               sel_song, score, best_score[sel_song],
               final_stars, is_new_best, is_infinite_mode);
}

__attribute((unused))
static void check_held_hits(unsigned held) {
    if (game_state != GS_PLAYING) return;

    for (int i = 0; i < MAX_TILES; i++) {
        if (!tiles[i].active) continue;
        if (tiles[i].state != T_NORMAL) continue;
        if (tiles[i].held_tried) continue;

        int c = tiles[i].col;
        if (c < 0 || c > 3) continue;
        if (!(held & (1u << c))) continue;

        int tile_h = tiles[i].is_long ? LONG_TILE_PX : TILE_HEIGHT_PX;
        int head_y = tiles[i].y_top + tile_h;
        int dist = head_y - KEYPAD_CENTER;
        if (dist < 0) dist = -dist;

        if (dist > GOOD_DIST) continue;

        // 在 GOOD 区且按住, 自动 hit
        tiles[i].hold_started = 1;
        tiles[i].held_tried   = 1;

        if (dist <= PERFECT_DIST) {
            tiles[i].state = T_PERFECT;
            score += 2;
            xil_printf("[HOLD-PERFECT] col=%d score=%d\r\n", c, score);
        } else {
            tiles[i].state = T_HIT;
            score += 1;
            xil_printf("[HOLD-GOOD] col=%d score=%d\r\n", c, score);
        }

        unsigned int inc = inc_for_abs_semi(tiles[i].note);
        set_voice(0, inc);
        hit_note_left = HIT_NOTE_FRAMES;

        if (check_score_cap_and_finish()) return;
    }
}

static void update_playing_frame(void) {

    for (int i = 0; i < MAX_TILES; i++) {
        // 如果方块当前是非激活状态，则跳过
        if (!tiles[i].active) continue;

        // 方块根据设定的下落像素速度向下移动

        tiles[i].y_top += tile_fall_px;


        // 如果方块完全超出了屏幕底部边界，则将其设为非激活
        if (tiles[i].y_top >= TILE_OFFSCREEN_Y) {
            tiles[i].active = 0;
            tiles[i].state  = T_NORMAL;
        }
    }

    for (int i = 0; i < MAX_TILES; i++) {
        // 仅处理处于激活状态且尚未被点击的方块
        if (!tiles[i].active || tiles[i].state != T_NORMAL) continue;

        // 计算方块中心位置以进行精准判定
        int center = tiles[i].y_top + TILE_HEIGHT_PX / 2;

        // 如果中心点超过了设定的 MISS 线，则判定为漏打
        if (center > MISS_AT_CENTER) {
            tiles[i].state = T_MISSED;
            combo_break();

            if (is_infinite_mode) {
                calculate_and_enter_win();
                return;
            }

            score--;
            xil_printf("[MISS] col=%d note=%d score=%d\r\n",
                        tiles[i].col, tiles[i].note, score);
        }
    }

    if (score < 0) {
        score = 0;
        game_state = GS_LOSE;   // 状态切换为失败
        silence_all();          // 立即切断所有音频输出
        loop_counter = 0;       // 重置循环计数器，为下次游玩做准备
        ending_timer = -1;      // 重置结束计时器
        xil_printf("=== GAME OVER: Negative Score! score=%d ===\r\n", score);
        return;                 // 立即退出，不再执行后续逻辑
    }

    if (song_delay > 0) {
    	song_delay-=is_infinite_mode ?2:1;
    	if(song_delay<0)
    		song_delay=0;
    } else {
        const game_event_t* song = SONG_TABLES[sel_song];

        // 关键逻辑：只有当不在结束倒计时中，才继续派发新的音符
        if (ending_timer == -1) {
            signed char c1 = song[song_pos].col1;
            signed char c2 = song[song_pos].col2;

            // 如果曲谱在该行有音符定义，则生成对应的方块
            if (c1 >= 0) spawn_tile(c1, song[song_pos].note1, song[song_pos].is_long);
			if (c2 >= 0) spawn_tile(c2, song[song_pos].note2, song[song_pos].is_long);

            // 设置下一次派发音符的延迟并推进指针
            song_delay = song[song_pos].delay;
            song_pos++;

            // 检查是否到达当前曲谱末尾
            if (song_pos >= SONG_LENS[sel_song]) {
                loop_counter++;
                song_pos = 0;

                if (loop_counter >= 2) {
                    is_infinite_mode = 1;
                    if(tile_fall_px<TILE_FALL_PX_MAX){
                    	tile_fall_px++;
                    }
                }
            }
        }
    }

    if (ending_timer > 0) {
        ending_timer--;
        if (ending_timer == 0)
        {
            // 只有当计时器归零，才进行最终星级判定并切换至胜利界面[cite: 3]
            calculate_and_enter_win();
            ending_timer = -1; // 恢复初始状态
        }
    }

    for (int c = 0; c < 4; c++) {
        if (col_flash[c] > 0) col_flash[c]--;
    }

    // 控制命中音符后的发声持续时间
    if (hit_note_left > 0) {
        hit_note_left--;
        if (hit_note_left == 0) set_voice(0, 0); // 发声时间到，停止该通道声音
    }

    // 控制按键错误时的蜂鸣反馈持续时间
    if (wrong_buzz_left > 0) {
        wrong_buzz_left--;
        if (wrong_buzz_left == 0) set_voice(1, 0); // 蜂鸣时间到，停止该通道声音
    }
}




static void process_asdf_press(unsigned edge) {
    if (game_state != GS_PLAYING) return;
    for (int c = 0; c < 4; c++) {
        if (!(edge & (1u << c))) continue;
        int hit_idx;
        int res = handle_hit(c, &hit_idx);
        if (res >= 0) {
            combo_add_hit();

            unsigned int inc = inc_for_abs_semi(tiles[hit_idx].note);
            // 多手指同时按可叠加: 用 voice 0/2/3 轮换 (避免覆盖之前的命中音)
            // 简化: 每次都用 voice 0
            set_voice(0, inc);
            hit_note_left = HIT_NOTE_FRAMES;
            if (res == 1) {
                score += 2;
                xil_printf("[PERFECT] col=%d note=%d score=%d\r\n",
                           c, tiles[hit_idx].note, score);
            } else {
                score += 1;
                xil_printf("[GOOD] col=%d note=%d score=%d\r\n",
                           c, tiles[hit_idx].note, score);
            }
                    if (check_score_cap_and_finish()) return;
                } else
            {
                combo_break();

                if (is_infinite_mode) {
                    calculate_and_enter_win();
                    return;
                }

                score--;
            col_flash[c]    = COL_FLASH_FRAMES;
            wrong_buzz_left = BUZZ_FRAMES;
            set_voice(1, BUZZ_PHASE_INC);
            xil_printf("[WRONG] col=%d score=%d\r\n", c, score);
        }
    }
}

static void enter_select(void) {
	combo=0;
	max_combo=0;
    game_state = GS_SELECT;
    silence_all();
    clear_all_tiles();
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
    last_mask=0;
    xil_printf("=== SELECT (current: %s) ===\r\n", SONG_NAMES[sel_song]);
}
static void enter_countdown(int song_idx) {
    if (song_idx < 0 || song_idx > 2) song_idx = 0;

    sel_song = song_idx;
    song_pos = 0;
    song_delay = 0;

    ending_timer = -1;
    loop_counter = 0;

    score = 0;
    combo = 0;
    max_combo = 0;

    is_infinite_mode = 0;
    is_new_best = 0;

    for (int c = 0; c < 4; c++) col_flash[c] = 0;

    hit_note_left = 0;
    wrong_buzz_left = 0;

    clear_all_tiles();
    silence_all();

    countdown_left = 3 * COUNTDOWN_FRAMES;
    countdown_val  = 3;

    game_state = GS_COUNTDOWN;
    tile_fall_px=TILE_FALL_PX_BASE;

    xil_printf("=== COUNTDOWN [%s] Best:%d ===\r\n",
               SONG_NAMES[sel_song], best_score[sel_song]);
}
static void enter_playing(void) {
    game_state = GS_PLAYING;
    song_delay = 30;
    xil_printf("=== PLAYING ===\r\n");
}
static void enter_manual(void) {
	combo=0;
	max_combo=0;
    game_state = GS_MANUAL;
    silence_all();
    clear_all_tiles();
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
    XGpio_DiscreteWrite(&gpio_autokey, 1, 0);
    last_mask=0;
    last_auto=0;
    xil_printf("=== MANUAL ===\r\n");
}

static unsigned int build_game_keymask(const BOOT_KBD_REPORT *rep) {
    unsigned int km = 0;

    if (game_state == GS_PLAYING) {
        km |= build_asdf_mask(rep) & 0xF;
    }

    // keymask[13:4] = 当前分数 (0-999, 10-bit 直接编码)
    int s = score;
    if (s < 0) s = 0;
    if (s > 999) s = 999;
    km |= ((unsigned)s & 0x3FFu) << 4;

    // keymask[17:14] = col_flash (4 bits)
    for (int c = 0; c < 4; c++) {
        if (col_flash[c] > 0) km |= (1u << (14 + c));
    }

    // keymask[27:18] = 当前歌曲个人最高分 (0-999, 10-bit)
    unsigned int best = best_score[sel_song];
    if (best > 999) best = 999;
    km |= (best & 0x3FFu) << 18;

    // keymask[28] = is_new_best
    //if (is_new_best)
        //km |= (1u << 28);

    return km;
}

static unsigned int build_select_keymask(void) {
    unsigned int b0 = (best_score[0] > 999) ? 999u : (unsigned int)best_score[0];
    unsigned int b1 = (best_score[1] > 999) ? 999u : (unsigned int)best_score[1];
    unsigned int b2 = (best_score[2] > 999) ? 999u : (unsigned int)best_score[2];
    return (b0 & 0x3FFu) | ((b1 & 0x3FFu) << 10) | ((b2 & 0x3FFu) << 20);
}

static unsigned int build_auto_meta(void) {
    unsigned int meta = 0;
    meta |= ((unsigned)game_state) & 7;              // [2:0] 游戏状态[cite: 4]
    meta |= ((unsigned)sel_song & 3) << 3;           // [4:3] 歌曲编号[cite: 4]
    meta |= ((unsigned)countdown_val & 3) << 5;      // [6:5] 倒计时值[cite: 4]

    // 如果在结算页面，发送星级；如果在游戏中，发送进度条[cite: 4]
    if (game_state == GS_WIN) {
        meta |= (final_stars & 3) << 15;             // [16:15] 星级结果 (新加)
    } else if (game_state == GS_PLAYING) {

		int cur_stars = calc_progressive_stars(sel_song, score);
		meta |= (cur_stars & 3) << 15;       // 同位置, 复用 SV 端的星级渲染逻辑
        unsigned prog = (song_pos * 127u) / (unsigned)SONG_LENS[sel_song];
        if (prog > 127) prog = 127;
        meta |= (prog & 0x7F) << 8;                  // [14:8] 进度条[cite: 4]
    }

    meta |= (is_new_best & 1) << 17;
    meta |= (is_infinite_mode & 1) << 18;
    // auto_keymask[28:19] = current combo, 0-999
    unsigned int combo_disp = (combo > 999) ? 999u : (unsigned int)combo;
    meta |= (combo_disp & 0x3FFu) << 19;

    // [23:20] = auto_song_sel (当前高亮曲目 0..15，始终推送)
    meta |= ((unsigned)(auto_song_sel & 0xF) << 20);
    return meta;
}


static int is_piano_key(BYTE kc) {
    switch (kc) {
        case 0x1D: case 0x1B: case 0x06: case 0x19:        // Z X C V
        case 0x05: case 0x11: case 0x10:                    // B N M
        case 0x16: case 0x07: case 0x0A: case 0x0B: case 0x0D:  // S D G H J
        case 0x14: case 0x1A: case 0x08: case 0x15:        // Q W E R
        case 0x17: case 0x1C: case 0x18:                    // T Y U
        case 0x1F: case 0x20: case 0x22: case 0x23: case 0x24:  // 2 3 5 6 7
            return 1;
        default:
            return 0;
    }
}
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
            XGpio_DiscreteWrite(&gpio_octave, 1, octave_shift + 4);
        }
        else if (kc == KC_RBRACKET && octave_shift < 4) {
            octave_shift++;
            XGpio_DiscreteWrite(&gpio_octave, 1, octave_shift + 4);
        }
        else if (kc == KC_SPACE) {
            octave_shift = 0;
            XGpio_DiscreteWrite(&gpio_octave, 1, 4);
        }
        else if (kc == KC_MINUS && volume > VOLUME_MIN) { volume--; set_volume_hw(volume); }
        else if (kc == KC_EQUAL && volume < VOLUME_MAX) { volume++; set_volume_hw(volume); }
        else if (kc == KC_F1) { wave_idx = 0; goto wave_changed; }
        else if (kc == KC_F2) { wave_idx = 1; goto wave_changed; }
        else if (kc == KC_F3) { wave_idx = 2; goto wave_changed; }
        else if (kc == KC_F4) { wave_idx = 3; goto wave_changed; }
        else if (kc == KC_F5) { wave_idx = 4; goto wave_changed; }
        else if (kc == KC_F6) { wave_idx = 5; goto wave_changed; }
        continue;
wave_changed:
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
        if(!is_piano_key(kc))continue;
        key_info_t info = KEY_INFO[kc];
        if (info.bit < 0) continue;
        unsigned int inc = inc_for_semi(info.semi);
        if (inc == 0) continue;
        mask |= (1u << info.bit);
        if (vcount < 4) voices[vcount++] = inc;
    }
    *pmask = mask;
}
static int auto_handle_control_keys(const BOOT_KBD_REPORT *rep) {
    static BYTE prev_wave_keys[6] = {0};

    int changed = 0;

    for (int i = 0; i < 6; i++) {
        BYTE kc = rep->keycode[i];
        if (kc == 0 || was_pressed(kc, prev_wave_keys)) continue;

        if      (kc == KC_F1) { wave_idx = 0; changed = 1; }
        else if (kc == KC_F2) { wave_idx = 1; changed = 1; }
        else if (kc == KC_F3) { wave_idx = 2; changed = 1; }
        else if (kc == KC_F4) { wave_idx = 3; changed = 1; }
        else if (kc == KC_F5) { wave_idx = 4; changed = 1; }
        else if (kc == KC_F6) { wave_idx = 5; changed = 1; }
    }

    for (int i = 0; i < 6; i++)
        prev_wave_keys[i] = rep->keycode[i];

    if (changed) {
        set_wave_dds(wave_idx);
        XGpio_DiscreteWrite(&gpio_wave, 1, wave_idx);
    }

    return changed;
}

static int play_note_interruptible(const PeppaNote *note) {
    uint32_t total_ms = note->duration_ms;
    uint32_t duty_ms  = total_ms * (100 - MUTE_RATIO) / 100;
    uint32_t pause_ms = total_ms - duty_ms;

    // --- 1. 发声控制 ---
    Xil_Out32(DDS_BASE + REG_PHASE_0, note->ch0);
    Xil_Out32(DDS_BASE + REG_PHASE_1, note->ch1);
    Xil_Out32(DDS_BASE + REG_PHASE_2, note->ch2);

    // --- 2. 自动显示 + 自动八度切换 ---
    unsigned int dynamic_mask = 0;

    if (note->ch0 != 0) {
        // ① 用最近邻匹配代替精确匹配，容忍 DDS 值的微小误差
        int best_i = 0;
        unsigned int best_diff = 0xFFFFFFFFu;
        for (int i = 0; i < TABLE_SIZE; i++) {
            unsigned int diff = (note->ch0 > PHASE_INC_TABLE[i])
                              ? (note->ch0 - PHASE_INC_TABLE[i])
                              : (PHASE_INC_TABLE[i] - note->ch0);
            if (diff < best_diff) { best_diff = diff; best_i = i; }
        }

        int relative_semi = best_i - C4_INDEX; // 相对 C4 的半音数

        int cur_min = octave_shift * 12;
        int cur_max = octave_shift * 12 + 23;
        if (relative_semi < cur_min || relative_semi > cur_max) {
            // 让音符落在显示区间的低半段 [0..11]
            int ideal;
            if (relative_semi >= 0) ideal = relative_semi / 12;
            else                    ideal = (relative_semi - 11) / 12; // 向下取整
            if (ideal < -4) ideal = -4;
            if (ideal >  4) ideal =  4;
            octave_shift = ideal;
            XGpio_DiscreteWrite(&gpio_octave, 1, (uint32_t)(octave_shift + 4));
        }


        int s_in_display = relative_semi - octave_shift * 12; // 应在 [0..23]
        for (int k = 0; k < 256; k++) {
            if (KEY_INFO[k].bit >= 0 && KEY_INFO[k].semi == s_in_display) {
                dynamic_mask |= (1u << KEY_INFO[k].bit);
                break;
            }
        }
    }

    // ch1 键位显示（不触发八度切换，超出范围就不显示）
    if (note->ch1 != 0) {
        int bi1 = 0; unsigned int bd1 = 0xFFFFFFFFu;
        for (int i = 0; i < TABLE_SIZE; i++) {
            unsigned int d = (note->ch1 > PHASE_INC_TABLE[i])
                           ? (note->ch1 - PHASE_INC_TABLE[i])
                           : (PHASE_INC_TABLE[i] - note->ch1);
            if (d < bd1) { bd1 = d; bi1 = i; }
        }
        int rs1 = bi1 - C4_INDEX - octave_shift * 12;
        if (rs1 >= 0 && rs1 <= 23) {
            for (int k = 0; k < 256; k++) {
                if (KEY_INFO[k].bit >= 0 && KEY_INFO[k].semi == rs1) {
                    dynamic_mask |= (1u << KEY_INFO[k].bit); break;
                }
            }
        }
    }

    // ch2 键位显示（同上）
    if (note->ch2 != 0) {
        int bi2 = 0; unsigned int bd2 = 0xFFFFFFFFu;
        for (int i = 0; i < TABLE_SIZE; i++) {
            unsigned int d = (note->ch2 > PHASE_INC_TABLE[i])
                           ? (note->ch2 - PHASE_INC_TABLE[i])
                           : (PHASE_INC_TABLE[i] - note->ch2);
            if (d < bd2) { bd2 = d; bi2 = i; }
        }
        int rs2 = bi2 - C4_INDEX - octave_shift * 12;
        if (rs2 >= 0 && rs2 <= 23) {
            for (int k = 0; k < 256; k++) {
                if (KEY_INFO[k].bit >= 0 && KEY_INFO[k].semi == rs2) {
                    dynamic_mask |= (1u << KEY_INFO[k].bit); break;
                }
            }
        }
    }

    // 实在找不到时退回 auto_mask（老格式兼容）
    if (dynamic_mask == 0) dynamic_mask = note->auto_mask;

    XGpio_DiscreteWrite(&gpio_autokey, 1, (uint32_t)GS_AUTO);
    XGpio_DiscreteWrite(&gpio_keymask, 1, dynamic_mask);

    // --- 3. 延时与中断监测 ---
    uint32_t elapsed = 0;
    while (elapsed < duty_ms) {
        uint32_t step = (duty_ms - elapsed > 20) ? 20 : (duty_ms - elapsed);
        usleep(step * 1000);
        elapsed += step;

        MAX3421E_Task(); USB_Task();
        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BOOT_KBD_REPORT tmp;
            //if (kbdPoll(&tmp) == 0 && check_capslock_edge(&tmp)) return 1; // 检测到 CapsLock 退出
            if (kbdPoll(&tmp) == 0)
                        {   auto_handle_control_keys(&tmp);
                        	if (check_capslock_edge(&tmp))      return 1;}
        }
    }

    // --- 4. 停止发声与清除显示 ---
    Xil_Out32(DDS_BASE + REG_PHASE_0, 0);
    Xil_Out32(DDS_BASE + REG_PHASE_1, 0);
    Xil_Out32(DDS_BASE + REG_PHASE_2, 0);

    XGpio_DiscreteWrite(&gpio_keymask, 1, 0); // 音符结束后立刻熄灭琴键

    elapsed = 0;
    while (elapsed < pause_ms) {
        uint32_t step = (pause_ms - elapsed > 20) ? 20 : (pause_ms - elapsed);
        usleep(step * 1000);
        elapsed += step;
        MAX3421E_Task(); USB_Task();
        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BOOT_KBD_REPORT tmp;
            //if (kbdPoll(&tmp) == 0 && check_capslock_edge(&tmp)) return 1;
            if (kbdPoll(&tmp) == 0)
            {   auto_handle_control_keys(&tmp);
            	if (check_capslock_edge(&tmp))      return 1;}
        }
    }
    return 0;
}


static int run_auto_mode(int idx) {
    if (idx < 0 || idx >= AUTO_LIB_SIZE) idx = 0;
    const PeppaNote *score_data = AUTO_LIB[idx].notes;
    int              score_len  = AUTO_LIB[idx].len;
    set_wave_dds(wave_idx);
    XGpio_DiscreteWrite(&gpio_wave, 1, wave_idx);
    XGpio_DiscreteWrite(&gpio_autokey, 1, (uint32_t)GS_AUTO);
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);

    while (1) {
        for (int i = 0; i < score_len; i++) {
            if (play_note_interruptible(&score_data[i])) {
                silence_all();
                XGpio_DiscreteWrite(&gpio_autokey, 1, 0);
                XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
                return 1;
            }
        }

        usleep(2000000);

        MAX3421E_Task();
        USB_Task();

        if (GetUsbTaskState() == USB_STATE_RUNNING)
        {
            BOOT_KBD_REPORT tmp;
            //if (kbdPoll(&tmp) == 0 && check_capslock_edge(&tmp)) {
            if (kbdPoll(&tmp) == 0)
            {
            	auto_handle_control_keys(&tmp);
            	if (check_capslock_edge(&tmp))
            	{
                silence_all();
                XGpio_DiscreteWrite(&gpio_autokey, 1, 0);
                XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
                return 1;
            	}
            }
        }
}}

int main(void) {
    xil_printf("\r\n=== USB Piano + Rhythm Game M4d (chord) ===\r\n");

    XGpio_Initialize(&gpio_keymask, XPAR_GPIO_KEYMASK_DEVICE_ID);
    XGpio_Initialize(&gpio_autokey, XPAR_GPIO_AUTOKEY_DEVICE_ID);
    XGpio_Initialize(&gpio_octave,  XPAR_GPIO_OCTAVE_DEVICE_ID);
    XGpio_Initialize(&gpio_wave,    XPAR_GPIO_WAVE_DEVICE_ID);
    XGpio_Initialize(&gpio_tiles_lo, XPAR_GPIO_TILES_LO_DEVICE_ID);
    XGpio_Initialize(&gpio_tiles_hi, XPAR_GPIO_TILES_HI_DEVICE_ID);   // ★

    XGpio_SetDataDirection(&gpio_keymask,  1, 0);
    XGpio_SetDataDirection(&gpio_autokey,  1, 0);
    XGpio_SetDataDirection(&gpio_octave,   1, 0);
    XGpio_SetDataDirection(&gpio_wave,     1, 0);
    XGpio_SetDataDirection(&gpio_tiles_lo, 1, 0);
    XGpio_SetDataDirection(&gpio_tiles_hi, 1, 0);                     // ★

    XGpio_DiscreteWrite(&gpio_keymask,  1, 0);
    XGpio_DiscreteWrite(&gpio_autokey,  1, 0);
    XGpio_DiscreteWrite(&gpio_octave,   1, 4);
    XGpio_DiscreteWrite(&gpio_wave,     1, wave_idx);
    XGpio_DiscreteWrite(&gpio_tiles_lo, 1, 0);
    XGpio_DiscreteWrite(&gpio_tiles_hi, 1, 0);                        // ★

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


    static BYTE p_prev[6]   = {0};
    static BYTE r_prev[6]   = {0};
    static BYTE tab_prev[6] = {0};
    static BYTE f7_prev[6]  = {0};
    static BYTE f8_prev[6]  = {0};
    static BYTE f9_prev[6]  = {0};
    static BYTE enter_prev[6] = {0}; // 新增
    static BYTE up_prev[6]    = {0}; // 新增
    static BYTE down_prev[6]  = {0}; // 新增
    static BYTE left_prev[6]  = {0}; // 曲库左移
    static BYTE right_prev[6] = {0}; // 曲库右移

    clear_all_tiles();
    push_tile_state();

    while (1) {
    	int playing_updated_this_loop = 0;

        if (auto_mode) {
            run_auto_mode(auto_song_to_play);
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
            continue;
        }

        MAX3421E_Task(); USB_Task();

        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BYTE rc = kbdPoll(&kbd);
            if (rc == 0) {
                if (check_capslock_edge(&kbd)) {
                    // CapsLock: 播放当前曲库选中的曲目 (所有状态统一行为)
                    auto_song_to_play = auto_song_sel;
                    auto_mode = 1;
                    silence_all();
                    last_voices[0]=last_voices[1]=last_voices[2]=last_voices[3]=0;
                    last_mask = 0; last_auto = 0;
                    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
                    XGpio_DiscreteWrite(&gpio_autokey, 1, 0);
                    continue;
                }

                int tab_edge = check_keycode_edge(KC_TAB, &kbd, tab_prev);
                int p_edge   = check_keycode_edge(KC_P,   &kbd, p_prev);
                int r_edge   = check_keycode_edge(KC_R,   &kbd, r_prev);
                int f7_edge  = check_keycode_edge(KC_F7,  &kbd, f7_prev);
                int f8_edge  = check_keycode_edge(KC_F8,  &kbd, f8_prev);
                int f9_edge  = check_keycode_edge(KC_F9,  &kbd, f9_prev);
                (void)f7_edge; (void)f8_edge; (void)f9_edge;   // 预留给曲库选择, 暂未使用

                switch (game_state) {
                case GS_MANUAL: {
                    if (tab_edge) { enter_select(); break; }

                    // ── 方向键导航曲库 (始终有效)，Enter/CapsLock 播放 ──
                    int left_edge2  = check_keycode_edge(KC_LEFT,  &kbd, left_prev);
                    int right_edge2 = check_keycode_edge(KC_RIGHT, &kbd, right_prev);
                    int up_edge2    = check_keycode_edge(KC_UP,    &kbd, up_prev);
                    int down_edge2  = check_keycode_edge(KC_DOWN,  &kbd, down_prev);
                    int enter_edge2 = check_keycode_edge(KC_ENTER, &kbd, enter_prev);

                    if (left_edge2) {
                        auto_song_sel--;
                        if (auto_song_sel < 0) auto_song_sel = AUTO_LIB_SIZE - 1;
                    }
                    if (right_edge2) {
                        auto_song_sel++;
                        if (auto_song_sel >= AUTO_LIB_SIZE) auto_song_sel = 0;
                    }
                    if (up_edge2) {
                        auto_song_sel -= 4;
                        if (auto_song_sel < 0) {
                            int last_row_start = ((AUTO_LIB_SIZE - 1) / 4) * 4;
                            auto_song_sel += last_row_start + 4;
                            if (auto_song_sel >= AUTO_LIB_SIZE) auto_song_sel -= 4;
                        }
                    }
                    if (down_edge2) {
                        auto_song_sel += 4;
                        if (auto_song_sel >= AUTO_LIB_SIZE)
                            auto_song_sel = auto_song_sel % 4;
                    }
                    if (enter_edge2) {
                        auto_song_to_play = auto_song_sel;
                        auto_mode         = 1;
                    }

                    // 推送选中高亮
                    uint32_t am3 = build_auto_meta();
                    if (am3 != last_auto) { XGpio_DiscreteWrite(&gpio_autokey, 1, am3); last_auto = am3; }

                    // ── 同时处理手弹琴键 ──
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
                    // 获取上下箭头和回车键的按下事件
                    int enter_edge = check_keycode_edge(KC_ENTER, &kbd, enter_prev);
                    int up_edge    = check_keycode_edge(KC_UP,    &kbd, up_prev);
                    int down_edge  = check_keycode_edge(KC_DOWN,  &kbd, down_prev);

                    if (up_edge) {
                    	sel_song--; // 向上翻
                    	if (sel_song < 0) sel_song = 2; // 循环到底部
                    }
                    if (down_edge) {
                       sel_song++; // 向下翻
                       if (sel_song > 2) sel_song = 0; // 循环到顶部
                    }
                    if (enter_edge) {
                       enter_countdown(sel_song); // 选中当前高亮的歌曲
                    }
                    break;
                }
                case GS_COUNTDOWN: {
                    if (tab_edge) { enter_select(); break; }
                    break;
                }
                case GS_PLAYING: {
                    if (tab_edge) { enter_select(); break; }
                    if (p_edge)   { game_state = GS_PAUSED; silence_all();
                                    xil_printf("[PAUSED]\r\n"); break; }

                    //先更新 tile 位置/曲谱/miss，再处理本帧按键
                    update_playing_frame();
                    playing_updated_this_loop = 1;

                    // update_playing_frame 可能已经让游戏进入 WIN/LOSE
                    if (game_state != GS_PLAYING) break;

                    unsigned int held_now = build_asdf_mask(&kbd);

                    unsigned edge = check_asdf_edge(&kbd);
                    if (edge) process_asdf_press(edge);


                    update_holds(held_now);

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

        if (is_game_ui()) {
            // 【游戏UI状态】：处理方块掉落与倒计时
            if (game_state == GS_COUNTDOWN) {
                countdown_left--;
                if (countdown_left > 2 * COUNTDOWN_FRAMES)      countdown_val = 3;
                else if (countdown_left > COUNTDOWN_FRAMES)     countdown_val = 2;
                else if (countdown_left > 0)                    countdown_val = 1;
                else { countdown_val = 0; enter_playing(); }
            }
            if (game_state == GS_PLAYING && !playing_updated_this_loop) {
                update_playing_frame();
            }
            push_tile_state(); // 推送方块位置

            // SELECT 仍然保持原来的 game_ui/tile_ui 时序，只是 keymask 改为三首歌 best score 打包。
            // 其他游戏状态完全沿用原 build_game_keymask，避免影响无尽模式判定。
            unsigned int km = (game_state == GS_SELECT) ? build_select_keymask() : build_game_keymask(&kbd);
            if (km != last_mask) {
                XGpio_DiscreteWrite(&gpio_keymask, 1, km);
                last_mask = km;
            }

            usleep(16000); // 维持帧率
        } else {
            // 【手动弹奏状态】：清空方块，并且绝不能去覆盖 gpio_keymask，
            // 因为手动模式的高亮已经在上面的 process_manual() 中写过了！
            push_tile_state();
        }

        // 无论任何状态，都把包含 sel_song, stars 等信息的 meta 推送给硬件
        unsigned int meta = build_auto_meta();
        if (meta != last_auto) {
            XGpio_DiscreteWrite(&gpio_autokey, 1, meta);
            last_auto = meta;
        }
    }
    return 0;
}
