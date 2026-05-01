//=============================================================================
// dds_mixer_v2.sv  -  4 声道 mixer + 波形选择透传
//
// 相对原版 (Week 2 Day 2) 的改动：
//   - 新增 input wave_sel[2:0]
//   - 把 wave_sel 同步透传给 4 个 dds_oscillator
//   - 其余信号和老的 dds_mixer 完全相同 (phase_inc_0..3 + enable + pdm_out)
//=============================================================================
module dds_mixer (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [31:0] phase_inc_0,
    input  logic [31:0] phase_inc_1,
    input  logic [31:0] phase_inc_2,
    input  logic [31:0] phase_inc_3,
    input  logic [2:0]  wave_sel,       // ← 新增
    input  logic        enable,
    output logic        pdm_out
);

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

    // 求和 + 除 4
    logic signed [17:0] sum;
    always_comb begin
        sum = $signed({{2{s0[15]}}, s0})
            + $signed({{2{s1[15]}}, s1})
            + $signed({{2{s2[15]}}, s2})
            + $signed({{2{s3[15]}}, s3});
    end
    logic signed [15:0] mixed;
    assign mixed = sum[17:2];

    audio_pdm pdm_inst (
        .clk(clk),
        .reset_n(reset_n),
        .audio_in(mixed),
        .pdm_out(pdm_out)
    );

endmodule
