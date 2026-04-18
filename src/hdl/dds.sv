//=============================================================================
// dds.sv  -  Direct Digital Synthesizer (Week 1: square wave only)
//
// Phase accumulator + simple square-wave output.
// To upgrade to sine/saw later, replace the always_comb with a LUT lookup.
//
// phase_increment = f_target * 2^32 / f_clk
// At 100MHz: 440 Hz -> 18897, 261.6 Hz -> 11236
//=============================================================================
module dds_oscillator (
    input  logic        clk,
    input  logic        reset_n,            // synchronous, active-low
    input  logic [31:0] phase_increment,    // from AXI register
    output logic [15:0] audio_out           // signed 16-bit
);

    logic [31:0] phase;

    // synchronous reset (matches AXI s00_axi_aresetn)
    always_ff @(posedge clk) begin
        if (!reset_n)
            phase <= 32'd0;
        else
            phase <= phase + phase_increment;
    end

    // square wave: top bit of phase decides +max or -max
    // when phase_increment == 0, output mid-scale (silence)
    always_comb begin
        if (phase_increment == 32'd0)
            audio_out = 16'h0000;        // signed zero -> PDM mid -> silence
        else if (phase[31])
            audio_out = 16'h7FFF;        // +max
        else
            audio_out = 16'h8000;        // -max  (signed -32768)
    end

endmodule