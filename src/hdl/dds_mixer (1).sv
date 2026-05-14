//=============================================================================
// dds_mixer.sv  -  4声道硬件mixer + 波形选择 + 音量控制
//
// 新增端口：volume[3:0]
//   来自 AXI 寄存器 slv_reg6（软件写），范围 0~8
//   0 = 静音，8 = 满量（默认）
//
// 音量实现原理：
//   mixed_raw = sum[17:2]                      (4路求和后÷4，signed 16-bit)
//   vol_product = mixed_raw × volume           (signed 20-bit，最大32767×8=262136)
//   mixed       = vol_product >> 3             (÷8，回到signed 16-bit)
//
// 信号流：
//   phase_inc[0..3] + wave_sel → 4× dds_oscillator
//   → signed求和 → ÷4归一化 → ×(volume/8) → audio_pdm → pdm_out
//=============================================================================
module dds_mixer (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [31:0] phase_inc_0,
    input  logic [31:0] phase_inc_1,
    input  logic [31:0] phase_inc_2,
    input  logic [31:0] phase_inc_3,
    input  logic        enable,       // 全局开关；0=静音
    input  logic [2:0]  wave_sel,     // 波形选择（透传给所有oscillator）
    input  logic [3:0]  volume,       // 音量 0~8，8=满量  ← 新增
    output logic        pdm_out
);

    //------------------------------------------------------------------
    // 4路oscillator输出（signed 16-bit）
    //------------------------------------------------------------------
    logic signed [15:0] s0, s1, s2, s3;

    dds_oscillator osc0 (
        .clk(clk), .reset_n(reset_n),
        .phase_increment(enable ? phase_inc_0 : 32'd0),
        .wave_sel(wave_sel), .audio_out(s0)
    );
    dds_oscillator osc1 (
        .clk(clk), .reset_n(reset_n),
        .phase_increment(enable ? phase_inc_1 : 32'd0),
        .wave_sel(wave_sel), .audio_out(s1)
    );
    dds_oscillator osc2 (
        .clk(clk), .reset_n(reset_n),
        .phase_increment(enable ? phase_inc_2 : 32'd0),
        .wave_sel(wave_sel), .audio_out(s2)
    );
    dds_oscillator osc3 (
        .clk(clk), .reset_n(reset_n),
        .phase_increment(enable ? phase_inc_3 : 32'd0),
        .wave_sel(wave_sel), .audio_out(s3)
    );

    //------------------------------------------------------------------
    // 求和：4× signed 16-bit → signed 18-bit
    //------------------------------------------------------------------
    logic signed [17:0] sum;
    always_comb begin
        sum = $signed({{2{s0[15]}}, s0})
            + $signed({{2{s1[15]}}, s1})
            + $signed({{2{s2[15]}}, s2})
            + $signed({{2{s3[15]}}, s3});
    end

    //------------------------------------------------------------------
    // 归一化：算术右移2位(÷4) → signed 16-bit
    //------------------------------------------------------------------
    logic signed [15:0] mixed_raw;
    assign mixed_raw = sum[17:2];

    //------------------------------------------------------------------
    // 音量缩放：mixed_raw × volume >> 3
    //   signed [19:0] 中间值防溢出
    //   volume是无符号0~8，补0符号位扩展到signed参与乘法
    //   >> 3 = ÷8，结果回到signed 16-bit
    //------------------------------------------------------------------
    logic signed [19:0] vol_product;
    logic signed [15:0] mixed;

    always_comb begin
        vol_product = $signed({{4{mixed_raw[15]}}, mixed_raw})
                      * $signed({1'b0, volume});
        mixed = vol_product[18:3];
    end

    //------------------------------------------------------------------
    // PDM调制输出
    //------------------------------------------------------------------
    audio_pdm pdm_inst (
        .clk     (clk),
        .reset_n (reset_n),
        .audio_in(mixed),
        .pdm_out (pdm_out)
    );

endmodule