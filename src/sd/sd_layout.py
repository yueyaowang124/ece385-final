#!/usr/bin/env python3
"""
sd_layout.py - 把 PeppaNote 曲谱 .txt 文件打包成 SD 卡 raw image

用法:
    python sd_layout.py harry.txt peppa.txt twinkle.txt -o sd_image.img

生成的 sd_image.img 用 Win32DiskImager 写到 SD 卡上。
然后 MicroBlaze 端用 sd_read_block(SONG_BASE + slot * SLOT_BLOCKS, buf) 读出来。

raw 布局 (1 sector = 512 bytes):
    Sector 0..1023:  保留 (boot 区不动)
    Sector 1024 + slot * 4:  song header (4 字节 note 数 + 余下 padding)
                              slot 0 → 1024, slot 1 → 1028, slot 2 → 1032, slot 3 → 1036
    Sector +1..+3:           连续打包 PeppaNote 数据 (每个 note 20 字节)

每个 slot 占 4 个 sector = 2048 字节, 头 4 字节存 note count, 剩余 2044 字节最多
存 102 个 PeppaNote.

PeppaNote 二进制 (little-endian):
    uint32_t ch0
    uint32_t ch1
    uint32_t ch2
    uint32_t ticks
    uint32_t auto_mask
"""

import argparse
import re
import struct
import sys

SECTOR_SIZE          = 512
SONG_BASE_BLOCK      = 1024
SONG_BLOCKS_PER_SLOT = 16        # 4 sectors per song slot
NOTE_FMT             = '<5I'     # little-endian 5x uint32_t
NOTE_SIZE            = struct.calcsize(NOTE_FMT)   # 20 bytes
MAX_NOTES_PER_SLOT   = (SONG_BLOCKS_PER_SLOT * SECTOR_SIZE - 4) // NOTE_SIZE   # 102

NOTE_RE = re.compile(
    r'\{\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*(0x[0-9a-fA-F]+|[0-9]+)\s*\}'
)

def parse_song(path):
    """从 .txt / .c / 任意源文件抽出所有 {a,b,c,d,e} 五元组."""
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        text = f.read()
    notes = []
    for m in NOTE_RE.finditer(text):
        ch0, ch1, ch2, ticks, mask = m.groups()
        notes.append((
            int(ch0), int(ch1), int(ch2),
            int(ticks),
            int(mask, 0),    # 自动识别 0x 前缀
        ))
    return notes


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('songs', nargs='+', help='.txt 文件 (最多 4 个)')
    ap.add_argument('-o', '--output', default='sd_image.img', help='输出 raw image')
    args = ap.parse_args()

    if len(args.songs) > 4:
        print("最多支持 4 首曲子", file=sys.stderr)
        sys.exit(1)

    total_blocks = SONG_BASE_BLOCK + len(args.songs) * SONG_BLOCKS_PER_SLOT
    img = bytearray(total_blocks * SECTOR_SIZE)

    for slot, path in enumerate(args.songs):
        notes = parse_song(path)
        print(f"  slot {slot}: {path}  ({len(notes)} notes)")
        if len(notes) > MAX_NOTES_PER_SLOT:
            print(f"    WARNING: 超过 {MAX_NOTES_PER_SLOT} 条上限, 截断")
            notes = notes[:MAX_NOTES_PER_SLOT]

        slot_off = (SONG_BASE_BLOCK + slot * SONG_BLOCKS_PER_SLOT) * SECTOR_SIZE
        # 头 4 字节 = note count
        struct.pack_into('<I', img, slot_off, len(notes))
        # 之后是 notes
        for i, n in enumerate(notes):
            struct.pack_into(NOTE_FMT, img, slot_off + 4 + i * NOTE_SIZE, *n)

    with open(args.output, 'wb') as f:
        f.write(img)
    print(f"\n生成 {args.output}: {len(img)} 字节 ({total_blocks} sectors)")
    print("用 Win32DiskImager 把这个 .img 写到 microSD 卡上")
    print(f"在 C 代码里用: SONG_BASE_BLOCK = {SONG_BASE_BLOCK},  SLOT_BLOCKS = {SONG_BLOCKS_PER_SLOT}")


if __name__ == '__main__':
    main()
