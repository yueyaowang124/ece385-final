// 这个函数以循环控制 GPIO 输出的逻辑实现 C4 到 B4 七个音阶的自动播放
#include "xparameters.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "sleep.h"

// 这里的 ID 必须对应你在 Vivado 中连接 DDS 的 GPIO 模块
#define GPIO_DEVICE_ID  XPAR_GPIO_USB_KEYCODE_DEVICE_ID 

// 基于 100MHz 时钟和 32 位累加器计算的相位增量
// 计算公式：increment = (f_out * 2^32) / 100,000,000
#define INC_C4  11236  // 261.63 Hz
#define INC_D4  12612  // 293.66 Hz
#define INC_E4  14157  // 329.63 Hz
#define INC_F4  15000  // 349.23 Hz
#define INC_G4  16838  // 392.00 Hz
#define INC_A4  18897  // 440.00 Hz
#define INC_B4  21213  // 493.88 Hz

XGpio Keycode_Gpio;

int main() {
    xil_printf("\r\n=== Ariel's CDEFGAB Scale Test ===\r\n");

    if (XGpio_Initialize(&Keycode_Gpio, GPIO_DEVICE_ID) != XST_SUCCESS) {
        xil_printf("GPIO initialization fail.\r\n");
        return XST_FAILURE;
    }

    XGpio_SetDataDirection(&Keycode_Gpio, 1, 0x0);

    xil_printf("GPIO initialization success.\r\n");

    while (1) {
        xil_printf("Playing: Do (C4)\r\n");
        XGpio_DiscreteWrite(&Keycode_Gpio, 1, INC_C4);
        sleep(2);

        xil_printf("Playing: Re (D4)\r\n");
        XGpio_DiscreteWrite(&Keycode_Gpio, 1, INC_D4);
        sleep(2);

        xil_printf("Playing: Mi (E4)\r\n");
        XGpio_DiscreteWrite(&Keycode_Gpio, 1, INC_E4);
        sleep(2);

        xil_printf("Playing: Fa (F4)\r\n");
        XGpio_DiscreteWrite(&Keycode_Gpio, 1, INC_F4);
        sleep(2);

        xil_printf("Playing: Sol (G4)\r\n");
        XGpio_DiscreteWrite(&Keycode_Gpio, 1, INC_G4);
        sleep(2);

        xil_printf("Playing: La (A4)\r\n");
        XGpio_DiscreteWrite(&Keycode_Gpio, 1, INC_A4);
        sleep(2);

        xil_printf("Playing: Si (B4)\r\n");
        XGpio_DiscreteWrite(&Keycode_Gpio, 1, INC_B4);
        sleep(2);
        
        xil_printf("--- Loop Restart ---\r\n");
        XGpio_DiscreteWrite(&Keycode_Gpio, 1, 0);
        sleep(1);
    }

    return 0;
}