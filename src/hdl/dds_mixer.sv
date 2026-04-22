//=============================================================================
// dds_mixer.sv  -  Week 2 Day 2�?4 声道硬件 mixer
//
// 4 �? dds_oscillator 并联，输出按位求和后右移 2 位（除以 4）做归一化，
// 然后送给同一�? audio_pdm。这就是 proposal �? "Hardware Mixer for polyphony"
// 的最小实�? —�?? 真硬件复音�??
//
// 信号流：
//   phase_inc[0] �?�? osc0 �?�? s16 �?
//   phase_inc[1] �?�? osc1 �?�? s16 ├─�? sum(s18) �?�? >>2 �?�? s16 �?�? audio_pdm �?�? pdm_out
//   phase_inc[2] �?�? osc2 �?�? s16 �?
//   phase_inc[3] �?�? osc3 �?�? s16 �?
//
// 复音效果�?4 个声道独立设 phase_inc �? 同时听到 4 个音 (e.g. C E G + 旋律)
// 单音效果：只�? phase_inc[0]，其�? = 0 �? 跟原来一�?
//=============================================================================
module dds_mixer (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [31:0] phase_inc_0,
    input  logic [31:0] phase_inc_1,
    input  logic [31:0] phase_inc_2,
    input  logic [31:0] phase_inc_3,
    input  logic        enable,         // 全局�?关；0 �? 静音
    input  logic [2:0]  wave_sel,
    output logic        pdm_out
);

    // 4 �? oscillator 输出（signed 16-bit�?
    logic signed [15:0] s0, s1, s2, s3;

    dds_oscillator osc0 (
        .clk(clk), .reset_n(reset_n),
        .phase_increment(enable ? phase_inc_0 : 32'd0),
        .audio_out(s0)
    );
    dds_oscillator osc1 (
        .clk(clk), .reset_n(reset_n),
        .phase_increment(enable ? phase_inc_1 : 32'd0),
        .audio_out(s1)
    );
    dds_oscillator osc2 (
        .clk(clk), .reset_n(reset_n),
        .phase_increment(enable ? phase_inc_2 : 32'd0),
        .audio_out(s2)
    );
    dds_oscillator osc3 (
        .clk(clk), .reset_n(reset_n),
        .phase_increment(enable ? phase_inc_3 : 32'd0),
        .audio_out(s3)
    );

    // 求和�?4 �? signed 16-bit 加起来最�? 18-bit signed
    logic signed [17:0] sum;
    always_comb begin
        sum = $signed({{2{s0[15]}}, s0})
            + $signed({{2{s1[15]}}, s1})
            + $signed({{2{s2[15]}}, s2})
            + $signed({{2{s3[15]}}, s3});
    end

    // 除以 4（算术右�? 2 位）�? 回到 signed 16-bit
    // 这样不会 clip：单声道只占 1/4 满刻度，4 声道全开恰好满刻�?
    logic signed [15:0] mixed;
    assign mixed = sum[17:2];

    // 送给 PDM 调制�?
    audio_pdm pdm_inst (
        .clk(clk),
        .reset_n(reset_n),
        .audio_in(mixed),
        .pdm_out(pdm_out)
    );

endmodule
