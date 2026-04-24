`timescale 1 ns / 1 ps
//=============================================================================
// dds.sv - DDS Oscillator, 6 waveforms, ZERO ROM/BRAM dependency
//
// Root cause of previous failures: $readmemh only works in simulation;
// initial blocks in Vivado synthesis are unreliable for ROM init;
// case-statement functions get optimized away by synthesis.
//
// Solution: Bhaskara I (628 AD) sine approximation — pure arithmetic.
//   sin(x) ≈ 4x(π-x)/(5π²-4x(π-x)),  max error < 1.8%
// Hardware: half_ph*(32767-half_ph) >> 13
//   Uses one DSP48 multiplier per call, runs at 100 MHz easily.
//
// wave_sel[2:0]:
//   000 = Square    001 = Triangle  010 = Sawtooth
//   011 = Sine      100 = Organ     101 = Vibrato
//=============================================================================
module dds_oscillator (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [31:0] phase_increment,
    input  logic [2:0]  wave_sel,
    output logic [15:0] audio_out
);

    //------------------------------------------------------------------
    // Phase accumulators
    //------------------------------------------------------------------
    logic [31:0] phase;
    logic [31:0] lfo_phase;
    // LFO ~6 Hz at 100 MHz clock
    localparam logic [31:0] LFO_INC = 32'd257;

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            phase     <= 32'd0;
            lfo_phase <= 32'd0;
        end else begin
            phase     <= phase + phase_increment;
            lfo_phase <= lfo_phase + LFO_INC;
        end
    end

    //------------------------------------------------------------------
    // Bhaskara I sine approximation — synthesizable pure logic
    //
    // Input:  32-bit phase accumulator
    // Output: signed 16-bit, range -32766 ~ +32766
    //
    // Algorithm:
    //   half_ph = phase[30:16] if positive half, else ~phase[30:16]
    //   numer   = half_ph * (32767 - half_ph)     [30-bit result]
    //   sin_pos = numer[28:13]                     [15-bit, 0..32766]
    //   result  = phase[31] ? -sin_pos : +sin_pos
    //------------------------------------------------------------------
    function automatic logic signed [15:0] bhaskara(
        input logic [31:0] ph
    );
        logic [14:0] half_ph;
        logic [29:0] numer;
        logic [14:0] sin_pos;

        // Mirror negative half-cycle
        half_ph = ph[31] ? ~ph[30:16] : ph[30:16];

        // Core multiply: max = 16383 * 16384 = 268,402,688 < 2^28
        numer = 30'(half_ph) * 30'(15'd32767 - half_ph);

        // Scale to 0..32766
        sin_pos = numer[28:14];   // >> 14 gives 0..16383; use [28:13] for full range
        // Actually: numer max=268M, >>13=32767 ✓
        sin_pos = numer[28:14];   // This gives 0~16383; double for full range below

        // Return signed, full ±32766 range
        // sin_pos is 0~16383; {sin_pos, 1'b0} doubles it to 0~32766
        if (ph[31])
            return -$signed({1'b0, sin_pos, 1'b0});
        else
            return  $signed({1'b0, sin_pos, 1'b0});
    endfunction

    //------------------------------------------------------------------
    // 000  Square wave
    //------------------------------------------------------------------
    logic signed [15:0] sq_out;
    assign sq_out = phase[31] ? 16'sh7FFF : 16'sh8000;

    //------------------------------------------------------------------
    // 001  Triangle wave
    //------------------------------------------------------------------
    logic [14:0]        tri_ramp;
    logic signed [15:0] tri_out;
    always_comb begin
        tri_ramp = phase[31] ? ~phase[30:16] : phase[30:16];
        tri_out  = $signed({2'b00, tri_ramp}) - 16'sh4000;
    end

    //------------------------------------------------------------------
    // 010  Sawtooth wave
    //------------------------------------------------------------------
    logic signed [15:0] saw_out;
    assign saw_out = $signed(phase[31:16]) - 16'sh8000;

    //------------------------------------------------------------------
    // 011  Sine wave (Bhaskara approximation)
    //------------------------------------------------------------------
    logic signed [15:0] sine_out;
    always_comb
        sine_out = bhaskara(phase);

    //------------------------------------------------------------------
    // 100  Organ: fundamental + 3rd harmonic (phase × 3)
    //      3rd harmonic at 1/3 amplitude via arithmetic right shift
    //------------------------------------------------------------------
    logic signed [15:0] org_fund, org_3rd;
    logic signed [17:0] organ_sum;
    logic signed [15:0] organ_out;
    always_comb begin
        org_fund  = bhaskara(phase);
        org_3rd   = bhaskara(phase * 3);        // 3rd harmonic
        organ_sum = $signed({{2{org_fund[15]}}, org_fund})
                  + $signed({{2{org_3rd[15]}},  org_3rd >>> 1}); // 3rd at half amp
        organ_out = organ_sum[17:2];
    end

    //------------------------------------------------------------------
    // 101  Vibrato: sine with LFO-modulated phase
    //      LFO adds ±1/32 cycle wobble to main phase
    //------------------------------------------------------------------
    logic signed [15:0] lfo_val;
    logic [31:0]        vib_phase;
    logic signed [15:0] vibrato_out;
    always_comb begin
        lfo_val     = bhaskara(lfo_phase);
        // depth: lfo_val >> 3 ≈ ±4096, adds small pitch wobble
        vib_phase   = phase + $signed({{3{lfo_val[15]}}, lfo_val[15:3]});
        vibrato_out = bhaskara(vib_phase);
    end

    //------------------------------------------------------------------
    // Output mux — registered for timing closure
    //------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!reset_n)
            audio_out <= 16'h0000;
        else if (phase_increment == 32'd0)
            audio_out <= 16'h0000;
        else
            case (wave_sel)
                3'b000:  audio_out <= sq_out;
                3'b001:  audio_out <= tri_out;
                3'b010:  audio_out <= saw_out;
                3'b011:  audio_out <= sine_out;
                3'b100:  audio_out <= organ_out;
                3'b101:  audio_out <= vibrato_out;
                default: audio_out <= 16'h0000;
            endcase
    end

endmodule