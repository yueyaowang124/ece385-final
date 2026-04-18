module synth_top (
    input  wire        clk,             // 把 logic 改成 wire
    input  wire        reset_n,         // 把 logic 改成 wire
    input  wire [31:0] phase_increment, // 把 logic 改成 wire
    output wire        SPKL,            // 把 logic 改成 wire
    output wire        SPKR             // 把 logic 改成 wire
);

    // 内部的变量依然保留 logic，不需要改
    logic [15:0] dds_to_pdm_wire;
    logic        pdm_mono_signal;        

    // 1. 实例化 DDS 模块
    dds_oscillator my_dds_inst (
        .clk             (clk),
        .reset_n         (reset_n),
        .phase_increment (phase_increment),
        .audio_out       (dds_to_pdm_wire)  
    );

    // 2. 实例化 PDM 模块
    audio_pdm my_pdm_inst (
        .clk             (clk),
        .reset_n         (reset_n),
        .audio_in        (dds_to_pdm_wire), 
        .pdm_out         (pdm_mono_signal)   
    );

    // 3. 将单声道声音同时发送给左右耳
    assign SPKL = pdm_mono_signal;
    assign SPKR = pdm_mono_signal;

endmodule