//=============================================================================
// main_M4d.c  --  M4c + 4 tile slots + 2 列和弦
//
// 改动 (相对 M4c):
//   - MAX_TILES = 4 (借助新加 gpio_tiles_hi)
//   - 曲谱事件支持 2 列同时 spawn (chord)
//   - push_tile_state 写两个 GPIO
//   - 节拍调到 1 tick ≈ 30 frames, 让 Peppa 的真实和弦序列能装下
//
// 曲谱事件:
//   { col1, note1, col2, note2, delay }
//   col*=−1 表示 REST 或无 chord
//=============================================================================

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

// --- 4 组 (中音组 - 中央C所在八度) ---
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

// --- 5 组 (高音组) ---
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
    uint32_t ticks;
    uint32_t auto_mask;
} PeppaNote;

static const PeppaNote SCORE_PEPPA_AUTO[] = {
	    { 0, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 11236, 0, 0, 1, 0x1 },
	    { 0, 0, 0, 1, 0x0 },
	    { 14999, 0, 0, 1, 0x20 },
	    { 0, 0, 0, 1, 0x0 },
	    { 17838, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 22473, 0, 0, 1, 0x1 },
	    { 0, 0, 0, 1, 0x0 },
	    { 29998, 0, 0, 1, 0x20 },
	    { 0, 0, 0, 1, 0x0 },
	    { 35676, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 7497, 11236, 8917, 1, 0x1 },
	    { 33676, 29998, 28304, 1, 0xb0 },
	    { 29998, 7497, 11236, 1, 0x21 },
	    { 0, 0, 0, 1, 0x0 },
	    { 11236, 7497, 11236, 1, 0x1 },
	    { 0, 0, 0, 1, 0x0 },
	    { 16838, 7076, 11236, 1, 0x81 },
	    { 0, 0, 0, 1, 0x0 },
	    { 22473, 0, 0, 1, 0x1 },
	    { 0, 0, 0, 1, 0x0 },
	    { 28304, 0, 0, 1, 0x10 },
	    { 0, 0, 0, 1, 0x0 },
	    { 33676, 0, 0, 1, 0x80 },
	    { 0, 0, 0, 1, 0x0 },
	    { 40044, 0, 0, 1, 0x0 },
	    { 0, 0, 0, 1, 0x0 },
	    { 7076, 11236, 8416, 1, 0x1 },
	    { 35676, 33676, 0, 1, 0x80 },
	    { 29998, 7076, 8416, 1, 0x21 },
};

#define PEPPA_LEN (sizeof(SCORE_PEPPA_AUTO)/sizeof(PeppaNote))

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
        g_sd_song[i].ticks    = ((uint32_t)p[12]) | ((uint32_t)p[13]<< 8) | ((uint32_t)p[14]<< 16) | ((uint32_t)p[15]<< 24);
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
            g_sd_song[written].ticks    = ((uint32_t)p[12]) | ((uint32_t)p[13]<< 8) | ((uint32_t)p[14]<< 16) | ((uint32_t)p[15]<< 24);
            g_sd_song[written].auto_mask= ((uint32_t)p[16]) | ((uint32_t)p[17]<< 8) | ((uint32_t)p[18]<< 16) | ((uint32_t)p[19]<< 24);
        }
        next_block++;
    }

    g_sd_song_len = (int)count;
    return g_sd_song_len;
}

//------------------------------------------------------
// 游戏曲谱: { col1, note1, col2, note2, delay }
// 列分配:
//   col 0 (A) = 低音 0..6 (C4..F#4)
//   col 1 (S) = 中低 7..11 (G4..B4)
//   col 2 (D) = 中高 12..15 (C5..D#5)
//   col 3 (F) = 高 16+ (E5..)
//------------------------------------------------------
typedef struct {
    signed char col1, note1;
    signed char col2, note2;     // -1 表示无 chord
    unsigned char delay;
	unsigned char is_long;        // ★ NEW: 这个 tile 是不是长 tile
} game_event_t;

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
{ 1,  7, -1,  0, T1 },
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

// Peppa Pig 主旋律 + 配音 (取原 SCORE_PEPPA_AUTO 的 ch0+ch1)
//
// 列映射:
//   G5(19)→3, F5(17)→3, E5(16)→3
//   D5(14)→2, C5(12)→2
//   B4(11)→1, G4(7)→1
//   C4(0)→0
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
};
#define SONG2_LEN (sizeof(SONG_PEPPA)/sizeof(game_event_t))

// Harry Potter 主题 (Hedwig's Theme, 简化版)
// 3 拍 (T3=90 frame) 的事件标记为 long
static const game_event_t SONG_HARRY[] = {
    // E4 (mid-low → S col)
    { 1,  4, -1,  0, 60, 0 },
    // A4+A3+E3, 3 ticks → LONG
    { 1,  9,  0, -3, 90, 1 },
    // C5
    { 2, 12, -1,  0, 30, 0 },
    // B4+G4
    { 1, 11,  1,  7, 60, 0 },
    // A4+E4
    { 1,  9,  1,  4, 60, 0 },
    // REST 2t
    {-1,  0, -1,  0, 60, 0 },
    // E5+B4
    { 3, 16,  1, 11, 60, 0 },
    // D5+A4, 2t (3-key chord 简化为 2-key)
    { 2, 14,  1,  9, 60, 0 },
    // REST 4t
    {-1,  0, -1,  0,120, 0 },
    // B4 2t
    { 1, 11, -1,  0, 60, 0 },
    // REST 4t
    {-1,  0, -1,  0,120, 0 },
    // A4+A3+E5, 3 ticks → LONG
    { 1,  9,  3, 16, 90, 1 },
    // C5
    { 2, 12, -1,  0, 30, 0 },
    // B4+G4
    { 1, 11,  1,  7, 60, 0 },
    // G4+D4
    { 1,  7,  0,  2, 60, 0 },
    // REST
    {-1,  0, -1,  0, 60, 0 },
    // A#4 (Bb4)
    { 1, 10, -1,  0, 60, 0 },
    // E4+A4 chord, 2t
    { 1,  4,  1,  9, 60, 0 },
    // REST
    {-1,  0, -1,  0, 60, 0 },
    // C4
    { 0,  0, -1,  0, 60, 0 },
    // E4
    { 1,  4, -1,  0, 60, 0 },
    // REST
    {-1,  0, -1,  0, 60, 0 },
    // E4 (last note, slightly long)
    { 1,  4, -1,  0,120, 0 },
};
#define SONG3_LEN (sizeof(SONG_HARRY)/sizeof(game_event_t))

static const game_event_t* const SONG_TABLES[3] = { SONG_TWINKLE, SONG_PEPPA, SONG_HARRY };
static const int          SONG_LENS[3]          = { SONG1_LEN,  SONG2_LEN,    SONG3_LEN };
static const char* const  SONG_NAMES[3]         = { "Peppa",    "Twinkle",    "Harry"   };

//------------------------------------------------------
// 全局
//------------------------------------------------------
static XGpio gpio_keymask, gpio_autokey, gpio_octave, gpio_wave;
static XGpio gpio_tiles_lo, gpio_tiles_hi;       // ★ M4d: 加 hi

static int          octave_shift = 0;
static unsigned int wave_idx     = 3;
static int          auto_mode    = 0;
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
#define TILE_FALL_PX     6
#define TILE_OFFSCREEN_Y 471
#define KEYPAD_CENTER   380
#define PERFECT_DIST     6
#define GOOD_DIST       28
#define MISS_AT_CENTER 420
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
} tile_t;

static tile_t   tiles[MAX_TILES];
static int      score         = 0;
static unsigned col_flash[4]  = {0};
static unsigned hit_note_left = 0;
static unsigned wrong_buzz_left = 0;

static int      song_pos       = 0;
static int      song_delay     = 0;

#define BUZZ_PHASE_INC  4724
#define HIT_NOTE_FRAMES   12
#define BUZZ_FRAMES       9
#define COL_FLASH_FRAMES  12

static void calculate_and_enter_win(void);

static int check_score_cap_and_finish(void) {
    if (score >= 99) {
        score = 99;
        xil_printf("[SCORE CAP] score reached 99, finish game\r\n");
        calculate_and_enter_win();
        return 1;
    }
    return 0;
}



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

//------------------------------------------------------
// tile 编码 (M4d: 4 个 tile, 写两个 GPIO)
//------------------------------------------------------
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
    if (is_game_ui()) word_lo |= (1u << 31);
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
    if (dist <= PERFECT_DIST) { tiles[idx].state = T_PERFECT; return 1; }
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

// 根据当前分数计算应该亮几颗星 (跟 calculate_and_enter_win 用同样的阈值)
static int calc_progressive_stars(int song_idx, int cur_score) {
    int stars = 0;
    if (song_idx == 0) {              // Peppa
        if (cur_score >= 25) stars = 1;
        if (cur_score >= 40) stars = 2;
        if (cur_score >= 45) stars = 3;
    } else if (song_idx == 1) {       // Twinkle
        if (cur_score >= 40) stars = 1;
        if (cur_score >= 60) stars = 2;
        if (cur_score >= 70) stars = 3;
    } else {                          // Harry
        if (cur_score >= 30) stars = 1;
        if (cur_score >= 50) stars = 2;
        if (cur_score >= 60) stars = 3;
    }
    return stars;
}
/**
 * 这个函数以得分判定与数据同步逻辑实现：
 * 1. 根据当前歌曲索引确定判分区间。
 * 2. 将计算得出的星级存入全局变量 final_stars。
 * 3. 切换状态，触发 build_auto_meta 将星级发送至硬件。
 */
static void calculate_and_enter_win(void) {
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

/**
 * update_playing_frame
 * 概述：这个函数以状态机更新逻辑实现游戏运行时的核心流程，包括方块下落、漏打检测、
 *       负分判定、曲谱循环读取以及延迟结算逻辑，确保最后一个音符能被正常处理。
 */
static void update_playing_frame(void) {


    // --- 第一部分：更新方块位置与状态 ---
    // 这个循环遍历所有方块，模拟物理下落过程
    for (int i = 0; i < MAX_TILES; i++) {
        // 如果方块当前是非激活状态，则跳过
        if (!tiles[i].active) continue;

        // 方块根据设定的下落像素速度向下移动
        tiles[i].y_top += TILE_FALL_PX;

        // 如果方块完全超出了屏幕底部边界，则将其设为非激活
        if (tiles[i].y_top >= TILE_OFFSCREEN_Y) {
            tiles[i].active = 0;
            tiles[i].state  = T_NORMAL;
        }
    }

    // --- 第二部分：检测漏打(Miss)逻辑 ---
    // 检查是否有玩家未点击且已越过判定线的方块[cite: 3]
    for (int i = 0; i < MAX_TILES; i++) {
        // 仅处理处于激活状态且尚未被点击的方块[cite: 3]
        if (!tiles[i].active || tiles[i].state != T_NORMAL) continue;

        // 计算方块中心位置以进行精准判定[cite: 3]
        int center = tiles[i].y_top + TILE_HEIGHT_PX / 2;

        // 如果中心点超过了设定的 MISS 线，则判定为漏打[cite: 3]
        if (center > MISS_AT_CENTER) {
            tiles[i].state = T_MISSED;

            if (is_infinite_mode) {
                xil_printf("[INFINITE MISS] Game End. score=%d\r\n", score);
                calculate_and_enter_win();
                return;
            }

            score--;
            xil_printf("[MISS] col=%d note=%d score=%d\r\n",
                        tiles[i].col, tiles[i].note, score);
        }
    }

    // --- 第三部分：负分即死检测 ---
    // 实时监控分数，若低于0则立即终止游戏[cite: 3]
    if (score < 0) {
        score = 0;
        game_state = GS_LOSE;   // 状态切换为失败[cite: 3]
        silence_all();          // 立即切断所有音频输出[cite: 3]
        loop_counter = 0;       // 重置循环计数器，为下次游玩做准备
        ending_timer = -1;      // 重置结束计时器
        xil_printf("=== GAME OVER: Negative Score! score=%d ===\r\n", score);
        return;                 // 立即退出，不再执行后续逻辑
    }

    // --- 第四部分：曲谱推进与循环逻辑 ---
    // 处理音符之间的时间间隔
    if (song_delay > 0) {
        song_delay--;
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
                    xil_printf("=== INFINITE MODE START ===\r\n");
                }
            }
        }
    }

    // --- 第五部分：处理结束结算计时 ---
    // 当曲谱停止派发后，等待最后的音符落地或被点击
    if (ending_timer > 0) {
        ending_timer--;
        if (ending_timer == 0)
        {
            // 只有当计时器归零，才进行最终星级判定并切换至胜利界面[cite: 3]
            calculate_and_enter_win();
            ending_timer = -1; // 恢复初始状态
        }
    }

    // --- 第六部分：反馈效果定时器更新 ---
    // 更新列点击时的视觉闪烁帧数[cite: 3]
    for (int c = 0; c < 4; c++) {
        if (col_flash[c] > 0) col_flash[c]--;
    }

    // 控制命中音符后的发声持续时间[cite: 3]
    if (hit_note_left > 0) {
        hit_note_left--;
        if (hit_note_left == 0) set_voice(0, 0); // 发声时间到，停止该通道声音[cite: 3]
    }

    // 控制按键错误时的蜂鸣反馈持续时间[cite: 3]
    if (wrong_buzz_left > 0) {
        wrong_buzz_left--;
        if (wrong_buzz_left == 0) set_voice(1, 0); // 蜂鸣时间到，停止该通道声音[cite: 3]
    }
}




static void process_asdf_press(unsigned edge) {
    if (game_state != GS_PLAYING) return;
    for (int c = 0; c < 4; c++) {
        if (!(edge & (1u << c))) continue;
        int hit_idx;
        int res = handle_hit(c, &hit_idx);
        if (res >= 0) {
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
                } else {
            if (is_infinite_mode) {
                xil_printf("[INFINITE WRONG] Game End. score=%d\r\n", score);
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

    xil_printf("=== COUNTDOWN [%s] Best:%d ===\r\n",
               SONG_NAMES[sel_song], best_score[sel_song]);
}
static void enter_playing(void) {
    game_state = GS_PLAYING;
    song_delay = 30;
    xil_printf("=== PLAYING ===\r\n");
}
static void enter_manual(void) {
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

    int s = score + 128;
    if (s < 0) s = 0;
    if (s > 255) s = 255;

    // keymask[11:4] = 当前分数 + 128
    km |= ((unsigned)s & 0xFF) << 4;

    for (int c = 0; c < 4; c++) {
        if (col_flash[c] > 0) km |= (1u << (12 + c));
    }

    // keymask[23:16] = 当前歌曲个人最高分
    unsigned int best = best_score[sel_song];
    if (best > 99) best = 99;
    km |= (best & 0x7F) << 16;
    if (is_new_best)
    	{km |= (1u << 23);}
    return km;
}
/**
 * 这个函数以位拼接逻辑实现：
 * 1. 将游戏状态、歌曲编号、进度条百分比打包。
 * 2. 新增：将计算出的星级结果（0-3）放入第 15-16 位，传递给硬件显示。
 */
static unsigned int build_auto_meta(void) {
    unsigned int meta = 0;
    meta |= ((unsigned)game_state) & 7;              // [2:0] 游戏状态[cite: 4]
    meta |= ((unsigned)sel_song & 3) << 3;           // [4:3] 歌曲编号[cite: 4]
    meta |= ((unsigned)countdown_val & 3) << 5;      // [6:5] 倒计时值[cite: 4]

    // 如果在结算页面，发送星级；如果在游戏中，发送进度条[cite: 4]
    if (game_state == GS_WIN) {
        meta |= (final_stars & 3) << 15;             // [16:15] 星级结果 (新加)
    } else if (game_state == GS_PLAYING) {
    	// ★ 改: 实时星级
		int cur_stars = calc_progressive_stars(sel_song, score);
		meta |= (cur_stars & 3) << 15;       // 同位置, 复用 SV 端的星级渲染逻辑
        unsigned prog = (song_pos * 127u) / (unsigned)SONG_LENS[sel_song];
        if (prog > 127) prog = 127;
        meta |= (prog & 0x7F) << 8;                  // [14:8] 进度条[cite: 4]
    }

    meta |= (is_new_best & 1) << 17;
    meta |= (is_infinite_mode & 1) << 18;
    return meta;
}

//------------------------------------------------------
// 手动 / 自动 (沿用)
//------------------------------------------------------

// 只有这些键才算钢琴键 (跟 KEY_INFO 里显式列的对应)
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
/**
 * 这个函数以阻塞但可中断的逻辑实现：
 * 1. 根据当前音符频率自动计算对应的琴键位置(bit)，实现音画一一对应。
 * 2. 通过控制 GPIO 信号，使屏幕上的对应琴键显示为青绿色（或自动模式定义的颜色）。
 * 3. 实时监测键盘输入，以便用户随时通过 CapsLock 中断自动演奏。
 */
static int play_note_interruptible(const PeppaNote *note) {
    uint32_t total_ms = note->ticks * TICK_MS;
    uint32_t duty_ms  = total_ms * (100 - MUTE_RATIO) / 100;
    uint32_t pause_ms = total_ms - duty_ms;

    // --- 1. 发声控制 ---
    Xil_Out32(DDS_BASE + REG_PHASE_0, note->ch0);
    Xil_Out32(DDS_BASE + REG_PHASE_1, note->ch1);
    Xil_Out32(DDS_BASE + REG_PHASE_2, note->ch2);

    // --- 2. 自动显示逻辑修正 ---
    // 我们需要通过 note->ch0 反推它对应哪个琴键 bit，以实现“音画对应”
    unsigned int dynamic_mask = 0;
    for (int i = 0; i < TABLE_SIZE; i++) {
        // 检查 ch0 对应 PHASE_INC_TABLE 中的哪个索引
        if (note->ch0 != 0 && note->ch0 == PHASE_INC_TABLE[i]) {
            int relative_semi = i - C4_INDEX; // 得到相对中央C的半音数
            // 遍历 KEY_INFO 找到对应的 bit
            for (int k = 0; k < 256; k++) {
                if (KEY_INFO[k].bit >= 0 && KEY_INFO[k].semi == relative_semi) {
                    dynamic_mask |= (1u << KEY_INFO[k].bit);
                    break;
                }
            }
        }
    }

    // 如果 note 本身自带了 auto_mask (针对和弦)，则合并
    if (dynamic_mask == 0) dynamic_mask = note->auto_mask;

    // 核心修正：
    // GS_AUTO (1) 告诉硬件处于自动演奏状态，此时 keymask 对应的琴键应显示为青绿色
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
            if (kbdPoll(&tmp) == 0 && check_capslock_edge(&tmp)) return 1; // 检测到 CapsLock 退出
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
            if (kbdPoll(&tmp) == 0 && check_capslock_edge(&tmp)) return 1;
        }
    }
    return 0;
}

static int run_auto_mode(void) {
    set_wave_dds(3);
    XGpio_DiscreteWrite(&gpio_wave, 1, 0);
    XGpio_DiscreteWrite(&gpio_autokey, 1, (uint32_t)GS_AUTO);
    XGpio_DiscreteWrite(&gpio_keymask, 1, 0);

    // ★ 尝试从 SD 卡 slot 0 加载; 失败用硬编码
    const PeppaNote *score    = SCORE_PEPPA_AUTO;
    int              score_len = (int)PEPPA_LEN;

    int loaded = load_song_from_sd(0);
    if (loaded > 0) {
        score    = g_sd_song;
        score_len = loaded;
        xil_printf("[AUTO] SD slot 0 loaded: %d notes\r\n", loaded);
    } else {
        xil_printf("[AUTO] SD load failed (%d), using built-in score\r\n", loaded);
    }

    while (1) {
        for (int i = 0; i < score_len; i++) {
            if (play_note_interruptible(&score[i])) {
                silence_all();
                XGpio_DiscreteWrite(&gpio_autokey, 1, 0);
                XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
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
                XGpio_DiscreteWrite(&gpio_keymask, 1, 0);
                return 1;
            }
        }
    }
}

//------------------------------------------------------
// main
//------------------------------------------------------
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
            continue;
        }

        MAX3421E_Task(); USB_Task();

        if (GetUsbTaskState() == USB_STATE_RUNNING) {
            BYTE rc = kbdPoll(&kbd);
            if (rc == 0) {
                if (check_capslock_edge(&kbd)) {
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
            if (game_state == GS_PLAYING) {
                update_playing_frame();
            }

            push_tile_state(); // 推送方块位置

            // ★ 修复点：只有在游戏UI状态下，才用游戏专属的掩码覆盖键盘！
            unsigned int km = build_game_keymask(&kbd);
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
