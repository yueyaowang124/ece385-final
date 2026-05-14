#ifndef PEPPA_SCORE_H
#define PEPPA_SCORE_H
/*=============================================================================
 * peppa_score.h  —  Peppa Pig Theme  自动演奏曲谱
 *
 *   SCORE_PEPPA_AUTO[]  自动演奏格式 (PeppaNote, duration_ms = 实际毫秒)
 *   PEPPA_AUTO_LEN      数组长度
 *
 * 注：ch0/ch1/ch2 使用 NOTE_* 宏，需在 main.c 中先 #define 这些宏再 #include 本文件。
 *============================================================================*/

static const PeppaNote SCORE_PEPPA_AUTO[] = {
		{NOTE_E4,REST,REST, 250, 0x01},

				    // 4分浮点：（1A 2A） -> 扩展为 (1A, 2A, 1E)
				    {NOTE_A4,NOTE_A3,NOTE_E3, 375, 0x03},

				    // 8分：3C
				    {NOTE_C5,REST,REST, 125, 0x04},

				    // 4分：2B 2A 0 3E
				    {NOTE_B4,NOTE_G4,REST, 250, 0x02},
				    {NOTE_A4,NOTE_E4,REST, 250, 0x01},
				    {REST,REST,REST, 250, 0x00},
				    {NOTE_E5,NOTE_B4,REST, 250, 0x08},

				    // （1A 3D） -> 扩展为 (1A, 3D, 2A)
				    {NOTE_D5,NOTE_A3,NOTE_A4, 250, 0x0B},

				    // 00 2B 00
				    {REST,REST,REST, 500, 0x00},
				    {NOTE_B4,REST,REST, 250, 0x02},
				    {REST,REST,REST, 500, 0x00},

				    // 4分浮点：（1A 2A） -> 扩展为 (1A, 2A, 3E)
				    {NOTE_A4,NOTE_A3,NOTE_E5, 375, 0x03},

				    // 8分：3C
				    {NOTE_C5,REST,REST, 125, 0x04},

				    // 4分：2B 2G 0 2A(升)
				    {NOTE_B4,NOTE_G4,REST, 250, 0x02},
				    {NOTE_G4,NOTE_D4,REST, 250, 0x02},
				    {REST,REST,REST, 250, 0x00},
				    {NOTE_AS4,REST,REST, 250, 0x01},

				    // (1A 2E) 0 2C 2E 0 2E
				    {NOTE_E4,NOTE_A3,NOTE_A4, 250, 0x03},
				    {REST,REST,REST, 250, 0x00},
				    {NOTE_C4,REST,REST, 250, 0x01},
				    {NOTE_E4,REST,REST, 250, 0x01},
				    {REST,REST,REST, 250, 0x00},
				    {NOTE_E4,REST,REST, 250, 0x01},

				    // 4分浮点：（1A 2A） -> 扩展为 (1A, 2A, 1E)
				    {NOTE_A4,NOTE_A3,NOTE_E3, 375, 0x03},

				    // 8分：3C
				    {NOTE_C5,REST,REST, 125, 0x04},

				    // 4分：2B 2A 0 3E
				    {NOTE_B4,NOTE_G4,REST, 250, 0x02},
				    {NOTE_A4,NOTE_E4,REST, 250, 0x01},
				    {REST,REST,REST, 250, 0x00},
				    {NOTE_E5,REST,REST, 250, 0x08},

				    // (3G 2E) 0 3F(升) -> 扩展为 (3G, 2E, 2B)
				    {NOTE_G5,NOTE_E4,NOTE_B4, 250, 0x0E},
				    {REST,REST,REST, 250, 0x00},
				    {NOTE_FS5,REST,REST, 250, 0x08},

				    // (3F(升) 2D) 0 3C(升) -> 扩展为 (3FS, 2D, 2A)
				    {NOTE_FS5,NOTE_D4,NOTE_A4, 250, 0x0A},
				    {REST,REST,REST, 250, 0x00},
				    {NOTE_CS5,REST,REST, 250, 0x04},

				    // 4浮点:(3F, 2F) 8分：3E
				    {NOTE_F5,NOTE_F4,NOTE_C5, 375, 0x0F},
				    {NOTE_E5,REST,REST, 125, 0x08},

				    // 4分：3D(升) (3D(升) 2E)
				    {NOTE_DS5,NOTE_AS4,REST, 250, 0x08},
				    {NOTE_DS5,NOTE_E4,NOTE_B4, 250, 0x0B},

				    // 0 3C (2A 1A ) 0 2E 2C
				    {REST,REST,REST, 250, 0x00},
				    {NOTE_C5,REST,REST, 250, 0x04},
				    {NOTE_A4,NOTE_A3,NOTE_E4, 250, 0x03},
				    {REST,REST,REST, 250, 0x00},
				    {NOTE_E4,REST,REST, 250, 0x01},
				    {NOTE_C4,REST,REST, 250, 0x01}
};

#define PEPPA_AUTO_LEN ((int)(sizeof(SCORE_PEPPA_AUTO)/sizeof(SCORE_PEPPA_AUTO[0])))

#endif /* PEPPA_SCORE_H */
