//=============================================================================
// dds_mixer.sv  -  4 声道硬件 mixer + 波形选择
//
// 新增端口：wave_sel[2:0]
//   来自 AXI 寄存器（软件写），4 个声道共享同一波形模式。
//
// 信号流：
//   phase_inc[0..3] + wave_sel → 4× dds_oscillator
//   → signed 求和 → >>2 归一化 → audio_pdm → pdm_out
//=============================================================================
module dds_mixer (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [31:0] phase_inc_0,
    input  logic [31:0] phase_inc_1,
    input  logic [31:0] phase_inc_2,
    input  logic [31:0] phase_inc_3,
    input  logic        enable,         // 全局开关；0 → 静音
    input  logic [2:0]  wave_sel,       // 波形选择（透传给所有 oscillator）
    output logic        pdm_out
);

    // 4 路 oscillator 输出（signed 16-bit）
    logic signed [15:0] s0, s1, s2, s3;

    dds_oscillator osc0 (
        .clk(clk), .reset_n(reset_n),
        .phase_increment(enable ? phase_inc_0 : 32'd0),
        .wave_sel(wave_sel),
        .audio_out(s0)
    );
    dds_oscillator osc1 (
        .clk(clk), .reset_n(reset_n),
        .phase_increment(enable ? phase_inc_1 : 32'd0),
        .wave_sel(wave_sel),
        .audio_out(s1)
    );
    dds_oscillator osc2 (
        .clk(clk), .reset_n(reset_n),
        .phase_increment(enable ? phase_inc_2 : 32'd0),
        .wave_sel(wave_sel),
        .audio_out(s2)
    );
    dds_oscillator osc3 (
        .clk(clk), .reset_n(reset_n),
        .phase_increment(enable ? phase_inc_3 : 32'd0),
        .wave_sel(wave_sel),
        .audio_out(s3)
    );

    // 求和：4× signed 16-bit → 最大 18-bit signed
    logic signed [17:0] sum;
    always_comb begin
        sum = $signed({{2{s0[15]}}, s0})
            + $signed({{2{s1[15]}}, s1})
            + $signed({{2{s2[15]}}, s2})
            + $signed({{2{s3[15]}}, s3});
    end

    // 归一化：算术右移 2 位（÷4）→ 回到 signed 16-bit
    logic signed [15:0] mixed;
    assign mixed = sum[17:2];

    // PDM 调制
    audio_pdm pdm_inst (
        .clk(clk),
        .reset_n(reset_n),
        .audio_in(mixed),
        .pdm_out(pdm_out)
    );

endmodule