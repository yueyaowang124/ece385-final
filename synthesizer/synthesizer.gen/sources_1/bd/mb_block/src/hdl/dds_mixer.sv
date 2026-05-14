//=============================================================================
// dds_mixer.sv  -  4����Ӳ��mixer + ����ѡ�� + ��������
//
// �����˿ڣ�volume[3:0]
//   ���� AXI �Ĵ��� slv_reg6������д������Χ 0~8
//   0 = ������8 = ������Ĭ�ϣ�
//
// ����ʵ��ԭ����
//   mixed_raw = sum[17:2]                      (4·��ͺ��4��signed 16-bit)
//   vol_product = mixed_raw �� volume           (signed 20-bit�����32767��8=262136)
//   mixed       = vol_product >> 3             (��8���ص�signed 16-bit)
//
// �ź�����
//   phase_inc[0..3] + wave_sel �� 4�� dds_oscillator
//   �� signed��� �� ��4��һ�� �� ��(volume/8) �� audio_pdm �� pdm_out
//=============================================================================
module dds_mixer (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [31:0] phase_inc_0,
    input  logic [31:0] phase_inc_1,
    input  logic [31:0] phase_inc_2,
    input  logic [31:0] phase_inc_3,
    input  logic        enable,       // ȫ�ֿ��أ�0=����
    input  logic [2:0]  wave_sel,     // ����ѡ��͸��������oscillator��
    input  logic [3:0]  volume,       // ���� 0~8��8=����  �� ����
    output logic        pdm_out
);

    //------------------------------------------------------------------
    // 4·oscillator�����signed 16-bit��
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
    // ��ͣ�4�� signed 16-bit �� signed 18-bit
    //------------------------------------------------------------------
    logic signed [17:0] sum;
    always_comb begin
        sum = $signed({{2{s0[15]}}, s0})
            + $signed({{2{s1[15]}}, s1})
            + $signed({{2{s2[15]}}, s2})
            + $signed({{2{s3[15]}}, s3});
    end

    //------------------------------------------------------------------
    // ��һ������������2λ(��4) �� signed 16-bit
    //------------------------------------------------------------------
    logic signed [15:0] mixed_raw;
    assign mixed_raw = sum[17:2];

    //------------------------------------------------------------------
    // �������ţ�mixed_raw �� volume >> 3
    //   signed [19:0] �м�ֵ�����
    //   volume���޷���0~8����0����λ��չ��signed����˷�
    //   >> 3 = ��8������ص�signed 16-bit
    //------------------------------------------------------------------
    logic signed [19:0] vol_product;
    logic signed [15:0] mixed;

    always_comb begin
        vol_product = $signed({{4{mixed_raw[15]}}, mixed_raw})
                      * $signed({1'b0, volume});
        mixed = vol_product[18:3];
    end

    //------------------------------------------------------------------
    // PDM�������
    //------------------------------------------------------------------
    audio_pdm pdm_inst (
        .clk     (clk),
        .reset_n (reset_n),
        .audio_in(mixed),
        .pdm_out (pdm_out)
    );

endmodule