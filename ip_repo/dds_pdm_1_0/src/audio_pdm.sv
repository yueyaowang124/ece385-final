module audio_pdm (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [15:0] audio_in,
    output logic        pdm_out
);
    //change signed to unsigned
    logic [15:0] unsigned_audio;
    assign unsigned_audio = { ~audio_in[15], audio_in[14:0] };

    logic [16:0] accumulator;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            accumulator <= 17'd0;
        end else begin
            // add the unsigned_audio to accumulator every posedge of clk
            accumulator <= {1'b0, accumulator[15:0]} + {1'b0, unsigned_audio};
        end
    end

    //overflow is pdm_out signal
    assign pdm_out = accumulator[16];

endmodule