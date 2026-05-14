#!/usr/bin/env python3
"""
verify_img.py - 验证 sd_layout.py 生成的 .img 文件内容是否正确

用法:
    python verify_img.py sd_image.img
"""
import os
import struct
import sys

SECTOR_SIZE = 512
SONG_BASE_BLOCK = 1024
SONG_BLOCKS_PER_SLOT = 4
NOTE_FMT = '<5I'
NOTE_SIZE = 20


def hex_dump(data, offset=0, max_bytes=64):
    """16 字节一行的 hex dump."""
    out = []
    for i in range(0, min(len(data), max_bytes), 16):
        chunk = data[i:i+16]
        hex_part = ' '.join(f'{b:02x}' for b in chunk)
        ascii_part = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
        out.append(f'  {offset+i:08x}  {hex_part:<48}  {ascii_part}')
    return '\n'.join(out)


def main():
    if len(sys.argv) < 2:
        print("用法: python verify_img.py sd_image.img")
        sys.exit(1)

    path = sys.argv[1]
    if not os.path.exists(path):
        print(f"错误: {path} 不存在")
        sys.exit(1)

    size = os.path.getsize(path)
    sectors = size // SECTOR_SIZE
    print(f"文件: {path}")
    print(f"大小: {size} 字节 = {sectors} sectors\n")

    with open(path, 'rb') as f:
        # 1. 看 sector 0 (应该全是 0)
        f.seek(0)
        s0 = f.read(64)
        print(f"Sector 0 (offset 0x00000) - 应该全 0 (boot 区):")
        print(hex_dump(s0, 0, 32))

        # 2. 看每个 song slot
        for slot in range(4):
            slot_block = SONG_BASE_BLOCK + slot * SONG_BLOCKS_PER_SLOT
            slot_offset = slot_block * SECTOR_SIZE
            if slot_offset >= size:
                print(f"\nSlot {slot}: 不在文件范围内 (文件只有 {sectors} sectors)")
                continue

            f.seek(slot_offset)
            header = f.read(4)
            if len(header) < 4:
                print(f"\nSlot {slot}: 数据不完整")
                continue

            note_count = struct.unpack('<I', header)[0]
            print(f"\nSlot {slot} (sector {slot_block}, offset 0x{slot_offset:x}):")
            print(f"  note count = {note_count}")

            if note_count == 0:
                print(f"  (空槽)")
                continue

            # 看第 1 个 note
            note_bytes = f.read(NOTE_SIZE)
            if len(note_bytes) == NOTE_SIZE:
                ch0, ch1, ch2, ticks, mask = struct.unpack(NOTE_FMT, note_bytes)
                print(f"  note[0]:  ch0={ch0}, ch1={ch1}, ch2={ch2}, ticks={ticks}, mask=0x{mask:x}")

            # 看第 2 个 note
            note_bytes = f.read(NOTE_SIZE)
            if len(note_bytes) == NOTE_SIZE:
                ch0, ch1, ch2, ticks, mask = struct.unpack(NOTE_FMT, note_bytes)
                print(f"  note[1]:  ch0={ch0}, ch1={ch1}, ch2={ch2}, ticks={ticks}, mask=0x{mask:x}")

            # 看最后一个 note (在 slot 内)
            max_in_slot = (SONG_BLOCKS_PER_SLOT * SECTOR_SIZE - 4) // NOTE_SIZE
            last_idx = min(note_count, max_in_slot) - 1
            if last_idx > 1:
                f.seek(slot_offset + 4 + last_idx * NOTE_SIZE)
                note_bytes = f.read(NOTE_SIZE)
                if len(note_bytes) == NOTE_SIZE:
                    ch0, ch1, ch2, ticks, mask = struct.unpack(NOTE_FMT, note_bytes)
                    print(f"  note[{last_idx}]: ch0={ch0}, ch1={ch1}, ch2={ch2}, ticks={ticks}, mask=0x{mask:x}")

            # 显示 slot 起始 64 字节的 hex dump
            f.seek(slot_offset)
            data = f.read(64)
            print(f"  hex dump (前 64 字节):")
            print(hex_dump(data, slot_offset, 64))

    print()
    print("=" * 60)
    print("如果 Slot 0 的 note count 显示为你的曲谱条数 (102 截断后)")
    print("并且 note[0] 不是全 0, 说明 .img 文件正常.")
    print("文件开头 512 KB 全 0 是设计如此 (boot 区), 不是损坏!")


if __name__ == '__main__':
    main()
