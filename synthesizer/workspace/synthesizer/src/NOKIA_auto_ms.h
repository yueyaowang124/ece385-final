#ifndef NOKIA_AUTO_MS_H
#define NOKIA_AUTO_MS_H
/*=============================================================================
 * NOKIA_auto_ms.h  —  Nokia Ringtone
 * SCORE_NOKIA_AUTO[]  自动演奏格式 (PeppaNote, duration_ms = 实际毫秒)
 * NOKIA_AUTO_LEN  数组长度
==============================================================================*/

static const PeppaNote SCORE_NOKIA_AUTO[] = {
    { NOTE_E5,  0, 0, 167, 0x10000 },  // E5, 8
    { NOTE_D5,  0, 0, 167, 0x4000  },  // D5, 8
    { NOTE_FS4, 0, 0, 333, 0x40    },  // FS4, 4
    { NOTE_GS4, 0, 0, 333, 0x100   },  // GS4, 4

    { NOTE_CS5, 0, 0, 167, 0x2000  },  // CS5, 8
    { NOTE_B4,  0, 0, 167, 0x800   },  // B4, 8
    { NOTE_D4,  0, 0, 333, 0x4     },  // D4, 4
    { NOTE_E4,  0, 0, 333, 0x10    },  // E4, 4

    { NOTE_B4,  0, 0, 167, 0x800   },  // B4, 8
    { NOTE_A4,  0, 0, 167, 0x200   },  // A4, 8
    { NOTE_CS4, 0, 0, 333, 0x2     },  // CS4, 4
    { NOTE_E4,  0, 0, 333, 0x10    },  // E4, 4

    { NOTE_A4,  0, 0, 667, 0x200   },  // A4, 2
};

#define NOKIA_AUTO_LEN ((int)(sizeof(SCORE_NOKIA_AUTO)/sizeof(SCORE_NOKIA_AUTO[0])))

#endif /* NOKIA_AUTO_MS_H */
