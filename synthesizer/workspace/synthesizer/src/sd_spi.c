// sd_spi.c - 瑁� SPI 璇� SD 鍗� (缁曞紑 FatFs / xilffs)
//
// 鐩存帴瀵勫瓨鍣ㄨ闂� AXI Quad SPI IP锛屽疄鐜版渶灏� SD 鍗� SPI 鍗忚:
//   - CMD0  GO_IDLE_STATE
//   - CMD8  SEND_IF_COND  (SDC v2.0 妫�娴�)
//   - ACMD41 SEND_OP_COND  (HCS=1 楂樺閲�)
//   - CMD58 READ_OCR        (纭 CCS=1 鍧楀鍧�)
//   - CMD17 READ_SINGLE_BLOCK
//
// 渚濊禆: BSP 閲岀殑 xparameters.h 鎻愪緵 XPAR_SPI_SD_BASEADDR (浣� IP 鍛藉悕 spi_sd 鐨勮瘽)
//       濡傛灉浣� IP 鍚嶅瓧涓嶄竴鏍�, 鏀逛笅闈㈢殑 #define SD_SPI_BASE 鍗冲彲
//
// 鍋囪: SDHC/SDXC 鍗� (鍧楀鍧�). 鑰佺殑 SDSC 鍗′笉鏀寔 (1GB 浠ヤ笅鐨勫崱).

#include "sd_spi.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xgpio.h"

// ★ debug: 暴露 CMD0 实际响应字节
volatile uint8_t g_dbg_cmd0_r = 0xFF;
volatile uint8_t g_dbg_cmd17_r = 0xFF;
volatile uint8_t g_dbg_token=0xFF;
volatile int g_dbg_read_err=0;
// ===== 鏀硅繖閲屽鏋滀綘 IP 鍛藉悕涓嶆槸 spi_sd =====
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

// ===== AXI Quad SPI 瀵勫瓨鍣ㄥ亸绉� (PG153) =====
#define SRR     (SD_SPI_BASE + 0x40)   // 杞浣� (鍐� 0x0A)
#define SPICR   (SD_SPI_BASE + 0x60)   // 鎺у埗瀵勫瓨鍣�
#define SPISR   (SD_SPI_BASE + 0x64)   // 鐘舵�佸瘎瀛樺櫒
#define SPIDTR  (SD_SPI_BASE + 0x68)   // 鍙戦�佹暟鎹瘎瀛樺櫒
#define SPIDRR  (SD_SPI_BASE + 0x6C)   // 鎺ユ敹鏁版嵁瀵勫瓨鍣�
#define SPISSR  (SD_SPI_BASE + 0x70)   // 鐗囬�夊瘎瀛樺櫒

// SPICR bits
#define CR_SPE         0x002
#define CR_MASTER      0x004
#define CR_TX_RST      0x020
#define CR_RX_RST      0x040
#define CR_MANUAL_SS   0x080

// SPISR bits
#define SR_RX_EMPTY    0x01
#define SR_TX_FULL     0x08

// 鐗囬�� (manual SS 妯″紡, 1 涓� slave 鍦� bit 0 涓�, active low)
#define CS_LOW()   Xil_Out32(SPISSR, 0xFFFFFFFE)
#define CS_HIGH()  Xil_Out32(SPISSR, 0xFFFFFFFF)

// ----- 浣庡眰: SPI 鍗曞瓧鑺備氦鎹� -----
static uint8_t spi_xchg(uint8_t out) {
    // 绛� TX FIFO 鏈夌┖浣�
    while (Xil_In32(SPISR) & SR_TX_FULL) { }
    // 鍐欏彂閫�
    Xil_Out32(SPIDTR, out);
    // 绛� RX FIFO 鏈夋暟鎹�
    while (Xil_In32(SPISR) & SR_RX_EMPTY) { }
    // 璇绘帴鏀�
    return (uint8_t)(Xil_In32(SPIDRR) & 0xFF);
}

// ----- 鍒濆鍖� AXI Quad SPI 鎺у埗鍣� -----
static void spi_init_hw(void) {
    Xil_Out32(SRR, 0x0A);                                                  // 杞浣�
    // Mode 0: CPOL=0, CPHA=0 (我们的)
    //Xil_Out32(SPICR, 0x086);

    // Mode 1: CPOL=0, CPHA=1
    //Xil_Out32(SPICR, 0x086 | 0x010);

    // Mode 2: CPOL=1, CPHA=0
    //Xil_Out32(SPICR, 0x086 | 0x008);

    // Mode 3: CPOL=1, CPHA=1
    Xil_Out32(SPICR, 0x086 | 0x018);
    CS_HIGH();
}

// ----- 鍙� SD 鍛戒护, 杩斿洖 R1 (0x80 琛ㄧず鏃犲搷搴�) -----
static uint8_t sd_cmd(uint8_t cmd, uint32_t arg) {
    uint8_t buf[6];
    buf[0] = 0x40 | (cmd & 0x3F);
    buf[1] = (uint8_t)(arg >> 24);
    buf[2] = (uint8_t)(arg >> 16);
    buf[3] = (uint8_t)(arg >>  8);
    buf[4] = (uint8_t)(arg      );
    if      (cmd == 0) buf[5] = 0x95;   // CMD0 CRC
    else if (cmd == 8) buf[5] = 0x87;   // CMD8 CRC
    else               buf[5] = 0xFF;   // 鍏朵粬鍛戒护 SPI 妯″紡涓嶆牎楠�

    for (int i = 0; i < 6; i++) spi_xchg(buf[i]);

    // 绛� R1 (椤� bit = 0). 鍗℃湁 1-8 涓� dummy clock 鎵嶅洖璇�.
    uint8_t r = 0xFF;
    for (int i = 0; i < 16; i++) {
        r = spi_xchg(0xFF);
        if (!(r & 0x80)) return r;
    }
    return r;
}

int sd_init(void) {
    spi_init_hw();

    // ★ 加: 上电后等 500ms 让卡完全稳定 (有些慢卡需要)
	for (volatile int i = 0; i < 200000000; i++) { __asm__("nop"); }

	// ★ 改: 200 字节 dummy clocks (1600 个 SPI clock, 远超规范要求)
	CS_HIGH();
	for (int i = 0; i < 200; i++) spi_xchg(0xFF);

	// ★ 加: 试 CMD0 三次, 取最好结果 (有些卡第一次会 miss)
	uint8_t r = 0xFF;
	for (int retry = 0; retry < 3; retry++) {
		CS_LOW();
		r = sd_cmd(0, 0);
		CS_HIGH();
		spi_xchg(0xFF);
		g_dbg_cmd0_r = r;     // ★ 保存最后一次
		if (r == 0x01) break;
		for (int i = 0; i < 10; i++) spi_xchg(0xFF);
		for (volatile int i = 0; i < 50000000; i++) { __asm__("nop"); }
	}
	if (r & 0x80) return -1;

    // CMD8: 妫�娴� v2.0 (鏈熸湜 0x01 + 4 瀛楄妭鍥炲０: 妫�鏌� 0x1AA)
    CS_LOW();
    r = sd_cmd(8, 0x000001AA);
    if (r & 0x80) {
        CS_HIGH();
        spi_xchg(0xFF);
        return -2;
    }
    uint8_t resp[4];
    for (int i = 0; i < 4; i++) resp[i] = spi_xchg(0xFF);
    CS_HIGH();
    spi_xchg(0xFF);
    //if ((resp[2] & 0x01) == 0 || resp[3] != 0xAA) return -2;
    (void)resp;

    // ACMD41 with HCS=1, 寰幆鍒板崱灏辩华 (R1 = 0x00)
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

    // CMD58: 璇� OCR, 妫�鏌� CCS=1 (鍧楀鍧�)
    CS_LOW();
    r = sd_cmd(58, 0);
    if (r & 0x80) {
        CS_HIGH();
        spi_xchg(0xFF);
        return -4;
    }
    uint8_t ocr[4];
    for (int i = 0; i < 4; i++) ocr[i] = spi_xchg(0xFF);
    CS_HIGH();
    spi_xchg(0xFF);
    //if ((ocr[0] & 0x40) == 0) return -4;   // CCS=0 鏄�� SDSC, 鏈┍鍔ㄤ笉鏀寔
    (void)ocr;

    CS_LOW();
    sd_cmd(16, 512);
    CS_HIGH();
    spi_xchg(0xFF);
    return 0;
}

int sd_read_block(uint32_t block_addr, uint8_t *buf) {
    if (!buf) { g_dbg_read_err = -1; return -1; }

    CS_LOW();
    uint8_t r = sd_cmd(17, block_addr);   // CMD17 READ_SINGLE_BLOCK
    g_dbg_cmd17_r = r;                     // ★ 保存 CMD17 R1

    if (r & 0x80) {                        // ★ 放宽: 只要 valid R1 就继续
        CS_HIGH();
        spi_xchg(0xFF);
        g_dbg_read_err = -1;
        return -1;
    }
    for(int i=0; i<8; i++) spi_xchg(0xFF);

    // 等数据令牌 0xFE
    int timeout = 200000;
    uint8_t tok = 0xFF;
    while (timeout-- > 0) {
        tok = spi_xchg(0xFF);
        if (tok == 0xFE) break;
        if ((tok & 0xF0)==0 && (tok & 0x0F)!=0 && tok!=0x00) {
            g_dbg_token = tok;
            g_dbg_read_err = -3;
            CS_HIGH();
            spi_xchg(0xFF);
            return -3;
        }
    }
    g_dbg_token = tok;
    if (timeout <= 0) {
        CS_HIGH();
        spi_xchg(0xFF);
        g_dbg_read_err = -2;
        return -2;
    }

    // 读 512 字节
    for (int i = 0; i < 512; i++) buf[i] = spi_xchg(0xFF);
    spi_xchg(0xFF);
    spi_xchg(0xFF);

    CS_HIGH();
    spi_xchg(0xFF);
    g_dbg_read_err = 0;
    return 0;
}
