//=============================================================================
// audio_pdm.sv  -  First-order PDM (pulse-density) modulator
//
// Converts a 16-bit signed audio sample into a 1-bit PDM stream
// suitable for the Urbana board's on-board 3.5mm audio jack
// (the jack expects a 1-bit signal that gets analog-low-pass-filtered).
//
// Algorithm:
//   - Convert signed input to unsigned (offset binary): flip MSB
//   - Accumulate the unsigned input each clock cycle
//   - Output the carry (overflow) bit as the PDM stream
//   - Average duty cycle of the output is proportional to input amplitude
//=============================================================================
module audio_pdm (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [15:0] audio_in,    // signed 16-bit
    output logic        pdm_out      // 1-bit PDM stream
);

    // signed -> unsigned (offset binary): flip MSB
    logic [15:0] unsigned_audio;
    assign unsigned_audio = { ~audio_in[15], audio_in[14:0] };

    // 17-bit accumulator: bit 16 is the carry-out
    logic [16:0] accumulator;

    always_ff @(posedge clk) begin
        if (!reset_n)
            accumulator <= 17'd0;
        else
            accumulator <= {1'b0, accumulator[15:0]} + {1'b0, unsigned_audio};
    end

    assign pdm_out = accumulator[16];

endmodule