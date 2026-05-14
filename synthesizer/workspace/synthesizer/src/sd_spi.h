// sd_spi.h - 裸 SPI 读 SD 卡 raw block (不依赖 FatFs)
#ifndef SD_SPI_H
#define SD_SPI_H

#include <stdint.h>

// 初始化 SD 卡 (CMD0 / CMD8 / ACMD41 / CMD58)
// 返回 0 = 成功, 负数 = 失败码
//   -1: CMD0 没回 0x01 (卡没响应)
//   -2: CMD8 失败 (不是 SDC v2.0+)
//   -3: ACMD41 超时 (卡没就绪)
//   -4: CMD58 失败或不是 high-capacity 卡 (本驱动只支持块寻址 SDHC/SDXC)
int sd_init(void);

// 读 1 个 512 字节的块
//   block_addr: 块号 (不是字节地址!)
//   buf: 至少 512 字节缓冲区
// 返回 0 = 成功, 负数 = 失败
int sd_read_block(uint32_t block_addr, uint8_t *buf);

#endif
