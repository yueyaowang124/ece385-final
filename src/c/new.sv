/*
 * 概述：手动琴与自动演奏(小猪佩奇)切换系统
 * 逻辑实现：
 * 1. 默认模式为手动演奏。按下键盘 ESC 键 (0x29) 切换至自动演奏模式。
 * 2. 自动演奏模式下，程序独占 DDS 控制权，播放完毕后自动切回手动模式。
 * 3. 详细中文注释：每行代码的功能与逻辑均已标明。
 */

#include <stdio.h>
#include <unistd.h>
#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "lwip/tcp.h"
#include "xstatus.h"

// --- 硬件寄存器基地址与偏移 ---
#define DDS_BASE        0x44A00000
#define REG_PHASE_0     0x00    // 声道 0 频率控制
#define REG_PHASE_1     0x04    // 声道 1 频率控制
#define REG_ENABLE      0x10    // DDS 总开关
#define REG_WAVE_SEL    0x14    // 波形选择 (0:方波, 1:锯齿波, 2:三角波, 3:正弦波)

// --- 频率步进值定义 (对齐主程序表) ---
#define REST    0
#define NOTE_C4 11236
#define NOTE_D4 12607
#define NOTE_E4 14157
#define NOTE_F4 14999
#define NOTE_G4 16838
#define NOTE_A4 18897
#define NOTE_B4 21213
#define NOTE_C5 22473
#define NOTE_D5 25215
#define NOTE_E5 28314
#define NOTE_F5 29998
#define NOTE_G5 33676
#define NOTE_A5 37795

// --- 模式定义 ---
#define MODE_MANUAL 0
#define MODE_AUTO   1

// --- 自动演奏数据结构 ---
typedef struct {
    uint32_t mel;   // 旋律音
    uint32_t acc;   // 伴奏音
    uint32_t ticks; // 持续节拍数
} PeppaScore;

// 节拍基础时长 (ms)
#define TICK_MS 150 

// 自动演奏曲谱数据 (小猪佩奇片段)
const PeppaScore PEPPA_SONG[] = {
    {NOTE_E5, NOTE_C4, 2}, {NOTE_G5, NOTE_C4, 2}, {NOTE_E5, NOTE_C4, 2}, {NOTE_C5, NOTE_C4, 2},
    {NOTE_G4, NOTE_C4, 2}, {REST,    NOTE_C4, 2}, {NOTE_G4, NOTE_C4, 2}, {NOTE_A4, NOTE_C4, 2},
    {NOTE_B4, NOTE_C4, 2}, {NOTE_C5, NOTE_C4, 4}
};

// --- 全局变量 ---
int current_mode = MODE_MANUAL; // 初始为手动模式
uint8_t last_key = 0;          // 记录最后一次按下的键

// --- 函数声明 ---
void silence_all();
void play_peppa_auto();
void handle_manual_piano(uint8_t keycode);

/**
 * 概述：静音函数。将所有 DDS 通道频率置 0。
 */
void silence_all() {
    Xil_Out32(DDS_BASE + REG_PHASE_0, 0); // 关闭声道 0
    Xil_Out32(DDS_BASE + REG_PHASE_1, 0); // 关闭声道 1
}

/**
 * 概述：自动演奏逻辑。
 * 实现逻辑：独占 CPU 运行直至曲谱结束。
 */
void play_peppa_auto() {
    xil_printf("Ariel, 进入自动演奏模式...\r\n");
    silence_all(); // 播放前先静音，防止手动模式残留声音
    
    for (int i = 0; i < sizeof(PEPPA_SONG)/sizeof(PeppaScore); i++) {
        // 写入频率
        Xil_Out32(DDS_BASE + REG_PHASE_0, PEPPA_SONG[i].mel);
        Xil_Out32(DDS_BASE + REG_PHASE_1, PEPPA_SONG[i].acc);
        
        // 维持时长
        usleep(PEPPA_SONG[i].ticks * TICK_MS * 1000);
        
        // 短暂断音增强节奏感
        silence_all();
        usleep(10000);
    }
    
    xil_printf("自动演奏结束，切回手动模式。\r\n");
    current_mode = MODE_MANUAL; // 自动切回手动
}

/**
 * 概述：手动弹奏逻辑。
 * 实现逻辑：根据输入的按键码，通过 switch-case 映射到对应频率。
 */
void handle_manual_piano(uint8_t keycode) {
    uint32_t freq = REST;
    switch(keycode) {
        case 0x04: freq = NOTE_C4; break; // A 键对应 C4
        case 0x07: freq = NOTE_D4; break; // D 键对应 D4
        case 0x08: freq = NOTE_E4; break; // E 键对应 E4
        case 0x09: freq = NOTE_F4; break; // F 键对应 F4
        case 0x0A: freq = NOTE_G4; break; // G 键对应 G4
        default: freq = REST; break;
    }
    Xil_Out32(DDS_BASE + REG_PHASE_0, freq); // 写入手动声道
}

int main() {
    // 1. 初始化硬件使能
    Xil_Out32(DDS_BASE + REG_ENABLE, 1);    // 开启 DDS
    Xil_Out32(DDS_BASE + REG_WAVE_SEL, 0);  // 默认方波
    
    xil_printf("Ariel, 系统就绪！[ESC: 切换自动播放] [A-G: 手动弹奏]\r\n");

    // 2. 主循环
    while (1) {
        // 调用 USB 轮询任务（这部分代码需保留你工程中原有的初始化）
        MAX3421E_Task();
        USB_Task();     

        // 获取当前按键 (假设该函数从 USB 任务获取最新键值)
        uint8_t current_key = get_last_keycode(); 

        // --- 逻辑分支 ---
        
        // 模式切换判断：检测 ESC 键 (0x29)
        if (current_key == 0x29 && last_key != 0x29) {
            current_mode = MODE_AUTO;
        }

        if (current_mode == MODE_AUTO) {
            // 执行自动播放（函数执行完会自动切回手动）
            play_peppa_auto();
            clear_last_keycode(); // 播放完清空按键缓存，防止无限循环
        } 
        else {
            // 手动模式：正常弹奏
            handle_manual_piano(current_key);
        }

        last_key = current_key; // 记录按键状态
    }
    return 0;
}