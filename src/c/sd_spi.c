// sd_spi.c - 裸 SPI 读 SD 卡 (绕开 FatFs / xilffs)
//
// 直接寄存器访问 AXI Quad SPI IP，实现最小 SD 卡 SPI 协议:
//   - CMD0  GO_IDLE_STATE
//   - CMD8  SEND_IF_COND  (SDC v2.0 检测)
//   - ACMD41 SEND_OP_COND  (HCS=1 高容量)
//   - CMD58 READ_OCR        (确认 CCS=1 块寻址)
//   - CMD17 READ_SINGLE_BLOCK
//
// 依赖: BSP 里的 xparameters.h 提供 XPAR_SPI_SD_BASEADDR (你 IP 命名 spi_sd 的话)
//       如果你 IP 名字不一样, 改下面的 #define SD_SPI_BASE 即可
//
// 假设: SDHC/SDXC 卡 (块寻址). 老的 SDSC 卡不支持 (1GB 以下的卡).

#include "sd_spi.h"
#include "xparameters.h"
#include "xil_io.h"

// ===== 改这里如果你 IP 命名不是 spi_sd =====
#ifndef SD_SPI_BASE
  #ifdef XPAR_SPI_SD_BASEADDR
    #define SD_SPI_BASE  XPAR_SPI_SD_BASEADDR
  #elif defined(XPAR_AXI_QUAD_SPI_0_BASEADDR)
    #define SD_SPI_BASE  XPAR_AXI_QUAD_SPI_0_BASEADDR
  #elif defined(XPAR_SPI_0_BASEADDR)
    #define SD_SPI_BASE  XPAR_SPI_0_BASEADDR
  #else
    #error "Cannot find SD AXI Quad SPI base address. Check xparameters.h and define SD_SPI_BASE manually."
  #endif
#endif

// ===== AXI Quad SPI 寄存器偏移 (PG153) =====
#define SRR     (SD_SPI_BASE + 0x40)   // 软复位 (写 0x0A)
#define SPICR   (SD_SPI_BASE + 0x60)   // 控制寄存器
#define SPISR   (SD_SPI_BASE + 0x64)   // 状态寄存器
#define SPIDTR  (SD_SPI_BASE + 0x68)   // 发送数据寄存器
#define SPIDRR  (SD_SPI_BASE + 0x6C)   // 接收数据寄存器
#define SPISSR  (SD_SPI_BASE + 0x70)   // 片选寄存器

// SPICR bits
#define CR_SPE         0x002
#define CR_MASTER      0x004
#define CR_TX_RST      0x020
#define CR_RX_RST      0x040
#define CR_MANUAL_SS   0x080

// SPISR bits
#define SR_RX_EMPTY    0x01
#define SR_TX_FULL     0x08

// 片选 (manual SS 模式, 1 个 slave 在 bit 0 上, active low)
#define CS_LOW()   Xil_Out32(SPISSR, 0xFFFFFFFE)
#define CS_HIGH()  Xil_Out32(SPISSR, 0xFFFFFFFF)

// ----- 低层: SPI 单字节交换 -----
static uint8_t spi_xchg(uint8_t out) {
    // 等 TX FIFO 有空位
    while (Xil_In32(SPISR) & SR_TX_FULL) { }
    // 写发送
    Xil_Out32(SPIDTR, out);
    // 等 RX FIFO 有数据
    while (Xil_In32(SPISR) & SR_RX_EMPTY) { }
    // 读接收
    return (uint8_t)(Xil_In32(SPIDRR) & 0xFF);
}

// ----- 初始化 AXI Quad SPI 控制器 -----
static void spi_init_hw(void) {
    Xil_Out32(SRR, 0x0A);                                                  // 软复位
    Xil_Out32(SPICR, CR_MASTER | CR_MANUAL_SS | CR_TX_RST | CR_RX_RST | CR_SPE);
    CS_HIGH();
}

// ----- 发 SD 命令, 返回 R1 (0x80 表示无响应) -----
static uint8_t sd_cmd(uint8_t cmd, uint32_t arg) {
    uint8_t buf[6];
    buf[0] = 0x40 | (cmd & 0x3F);
    buf[1] = (uint8_t)(arg >> 24);
    buf[2] = (uint8_t)(arg >> 16);
    buf[3] = (uint8_t)(arg >>  8);
    buf[4] = (uint8_t)(arg      );
    if      (cmd == 0) buf[5] = 0x95;   // CMD0 CRC
    else if (cmd == 8) buf[5] = 0x87;   // CMD8 CRC
    else               buf[5] = 0xFF;   // 其他命令 SPI 模式不校验

    for (int i = 0; i < 6; i++) spi_xchg(buf[i]);

    // 等 R1 (顶 bit = 0). 卡有 1-8 个 dummy clock 才回话.
    uint8_t r = 0xFF;
    for (int i = 0; i < 16; i++) {
        r = spi_xchg(0xFF);
        if (!(r & 0x80)) return r;
    }
    return r;
}

int sd_init(void) {
    spi_init_hw();

    // 发 80+ dummy clock (CS 高), 让卡进 SPI 模式
    CS_HIGH();
    for (int i = 0; i < 10; i++) spi_xchg(0xFF);

    // CMD0: 进 idle (期望 0x01)
    CS_LOW();
    uint8_t r = sd_cmd(0, 0);
    CS_HIGH();
    spi_xchg(0xFF);
    if (r != 0x01) return -1;

    // CMD8: 检测 v2.0 (期望 0x01 + 4 字节回声: 检查 0x1AA)
    CS_LOW();
    r = sd_cmd(8, 0x000001AA);
    if (r != 0x01) {
        CS_HIGH();
        spi_xchg(0xFF);
        return -2;
    }
    uint8_t resp[4];
    for (int i = 0; i < 4; i++) resp[i] = spi_xchg(0xFF);
    CS_HIGH();
    spi_xchg(0xFF);
    if ((resp[2] & 0x01) == 0 || resp[3] != 0xAA) return -2;

    // ACMD41 with HCS=1, 循环到卡就绪 (R1 = 0x00)
    int retry = 5000;
    while (retry-- > 0) {
        CS_LOW();
        sd_cmd(55, 0);                  // CMD55 prefix
        CS_HIGH();
        spi_xchg(0xFF);

        CS_LOW();
        r = sd_cmd(41, 0x40000000);     // ACMD41 HCS=1
        CS_HIGH();
        spi_xchg(0xFF);

        if (r == 0x00) break;
        for (volatile int j = 0; j < 200; j++) { }
    }
    if (retry <= 0) return -3;

    // CMD58: 读 OCR, 检查 CCS=1 (块寻址)
    CS_LOW();
    r = sd_cmd(58, 0);
    if (r != 0x00) {
        CS_HIGH();
        spi_xchg(0xFF);
        return -4;
    }
    uint8_t ocr[4];
    for (int i = 0; i < 4; i++) ocr[i] = spi_xchg(0xFF);
    CS_HIGH();
    spi_xchg(0xFF);
    if ((ocr[0] & 0x40) == 0) return -4;   // CCS=0 是老 SDSC, 本驱动不支持

    return 0;
}

int sd_read_block(uint32_t block_addr, uint8_t *buf) {
    if (!buf) return -1;

    CS_LOW();
    uint8_t r = sd_cmd(17, block_addr);   // CMD17 READ_SINGLE_BLOCK (块号)
    if (r != 0x00) {
        CS_HIGH();
        spi_xchg(0xFF);
        return -1;
    }

    // 等数据令牌 0xFE
    int timeout = 200000;
    uint8_t tok = 0xFF;
    while (timeout-- > 0) {
        tok = spi_xchg(0xFF);
        if (tok == 0xFE) break;
        if (tok != 0xFF) {
            // 收到错误令牌 (顶 4 bits = 0)
            CS_HIGH();
            spi_xchg(0xFF);
            return -3;
        }
    }
    if (timeout <= 0) {
        CS_HIGH();
        spi_xchg(0xFF);
        return -2;
    }

    // 读 512 字节
    for (int i = 0; i < 512; i++) buf[i] = spi_xchg(0xFF);

    // 2 字节 CRC (忽略)
    spi_xchg(0xFF);
    spi_xchg(0xFF);

    CS_HIGH();
    spi_xchg(0xFF);
    return 0;
}
