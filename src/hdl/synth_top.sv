module synth_top (
    input  wire        clk,             // FPGA 系统时钟
    input  wire        reset_n,         // 全局复位
    input  wire [31:0] phase_increment, // 频率步进�?
    output wire        SPKL,            // 左声道输�?
    output wire        SPKR             // 右声道输�?
);

    logic [15:0] dds_to_pdm_wire;
    logic        pdm_mono_signal;        // 内部产生�? 1-bit 声音信号

    // 1. 实例�? DDS 模块
    dds_oscillator my_dds_inst (
        .clk             (clk),
        .reset_n         (reset_n),
        .phase_increment (phase_increment),
        .audio_out       (dds_to_pdm_wire)  
    );

    // 2. 实例�? PDM 模块
    audio_pdm my_pdm_inst (
        .clk             (clk),
        .reset_n         (reset_n),
        .audio_in        (dds_to_pdm_wire), 
        .pdm_out         (pdm_mono_signal)   // 声音先输出到这个内部信号�?
    );

    // 3. 将单声道声音同时发�?�给左右�?
    assign SPKL = pdm_mono_signal;
    assign SPKR = pdm_mono_signal;

endmodule