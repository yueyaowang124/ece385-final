module synth_top (
    input  logic        clk,             // FPGA 系统时钟 (比如 100MHz)
    input  logic        reset_n,         // 全局复位
    input  logic [31:0] phase_increment, // 从 MicroBlaze AXI 总线传来的频率步进值
    output logic        audio_jack_out   // 这个信号要绑定到开发板 .xdc 约束文件的耳机孔引脚上
);

    // 声明一根内部导线，用来连接 DDS 的输出和 PDM 的输入
    logic [15:0] dds_to_pdm_wire;

    // 1. 实例化队友的 DDS 模块
    dds_oscillator my_dds_inst (
        .clk             (clk),
        .reset_n         (reset_n),
        .phase_increment (phase_increment),
        .audio_out       (dds_to_pdm_wire)  // 声音数据流出
    );

    // 2. 实例化你的 PDM 模块
    audio_pdm my_pdm_inst (
        .clk             (clk),
        .reset_n         (reset_n),
        .audio_in        (dds_to_pdm_wire), // 声音数据流入
        .pdm_out         (audio_jack_out)   // 变成 1-bit 脉冲流向耳机
    );

endmodule