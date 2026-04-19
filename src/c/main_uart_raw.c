//=============================================================================
// main_uart_raw.c  -  绕过 xil_printf 直接写 UART
//
// AXI Uartlite 寄存器图：
//   0x00 : RX FIFO  (read only)
//   0x04 : TX FIFO  (write only)  ← 写一个字节就发出去
//   0x08 : STATUS   (bit 3 = TX_Full, bit 2 = TX_Empty)
//   0x0C : CONTROL
//
// 我们直接 Xil_Out32 写 TX FIFO，不轮询 STATUS。如果硬件正常，字符会发出去；
// 如果硬件挂了，至少 CPU 不会卡死。
//=============================================================================
#include "xparameters.h"
#include "xil_io.h"

#define DDS_BASE        0x44A00000
#define UART_BASE       0x40600000
#define UART_TX_FIFO    (UART_BASE + 0x04)
#define UART_STATUS     (UART_BASE + 0x08)
#define UART_TX_FULL    (1 << 3)

// 简单延迟（不依赖 sleep 库）
static void delay(volatile int n) {
    while (n--) ;
}

// 直接写一个字节到 UART，最多等 1000 个循环（防止卡死）
static void uart_putc(char c) {
    int wait = 1000;
    // 等 TX FIFO 不满
    while ((Xil_In32(UART_STATUS) & UART_TX_FULL) && wait--) {
        ;
    }
    // 不管 wait 是不是超时都写（超时也写，至少能看出"写"动作发生过）
    Xil_Out32(UART_TX_FIFO, (u32)c);
}

static void uart_puts(const char *s) {
    while (*s) {
        uart_putc(*s++);
    }
}

int main(void) {
    // 立即开 A4，不依赖 UART
    Xil_Out32(DDS_BASE + 0x00, 18897);
    Xil_Out32(DDS_BASE + 0x08, 1);

    // 等一会儿（让 A4 先响起来）
    delay(10000000);

    // 直接发字节
    uart_puts("HELLO\r\n");

    // 切到 200Hz，证明 CPU 还活着
    Xil_Out32(DDS_BASE + 0x00, 8590);

    delay(10000000);
    uart_puts("WORLD\r\n");

    while (1) {
        delay(50000000);
        uart_puts(".");
    }
    return 0;
}
