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
    input  logic [2:0]  wave_sel,
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

    //sin
    logic signed [15:0] sine_lut [0:255];
    initial $readmemh("sine_lut.hex", sine_lut);

    logic signed [15:0] sine_base;
    assign sine_base = sine_lut[phase[31:24]];


    //000:quare wave
    logic signed [15:0] sq_out;
    always_comb
        sq_out = phase[31] ? 16'sh7FFF : 16'sh8000;

    //001: triangle wave
    logic signed [15:0] tri_out;
    always_comb begin
        logic [14:0] ramp;
        ramp = phase[31] ? ~phase[30:16] : phase[30:16];
        tri_out = $signed({1'b0, ramp, 1'b0}) - 16'sh3FFF;
    end

    //010: saw wave
    logic signed [15:0] saw_out;
    assign saw_out = $signed(phase[31:16]) - 16'sh8000;

    //011: sin wave
    //directly output from LUT

    //100: Organ wave
    logic signed [15:0] sine_3rd, sine_5th;
    assign sine_3rd = sine_lut[phase[31:24] * 3];
    assign sine_5th = sine_lut[phase[31:24] * 5]; 
    logic signed [17:0] organ_sum;
    logic signed [15:0] organ_out;

    always_comb 
    begin
        organ_sum = ($signed({{2{sine_base[15]}}, sine_base}) * 3
                   + $signed({{2{sine_3rd[15]}},  sine_3rd}))
                   + $signed({{2{sine_5th[15]}},  sine_5th});
        organ_out = organ_sum[17:2];
    end

    //101: Vibrato wave 
    logic [31:0] lfo_phase;
    localparam logic [31:0] LFO_INC = 32'd215;   // ~5 Hz LFO
 
    always_ff @(posedge clk) begin
        if (!reset_n)
            lfo_phase <= 32'd0;
        else if (phase_increment != 32'd0)
            lfo_phase <= lfo_phase + LFO_INC;
        else
            lfo_phase <= 32'd0;
    end
 
    logic signed [15:0] lfo_val;
    assign lfo_val = sine_lut[lfo_phase[31:24]];
    logic [7:0] vibrato_idx;
    assign vibrato_idx = phase[31:24] + lfo_val[15:8]; 
    logic signed [15:0] vibrato_out;
    assign vibrato_out = sine_lut[vibrato_idx];

    //output mux
     always_comb begin
        if (phase_increment == 32'd0) 
        begin
            audio_out = 16'h0000;
        end 
        else 
        begin
            case (wave_sel)
                3'b000:  audio_out = sq_out;
                3'b001:  audio_out = tri_out;
                3'b010:  audio_out = saw_out;
                3'b011:  audio_out = sine_base;
                3'b100:  audio_out = organ_out;
                3'b101:  audio_out = vibrato_out;
                default: audio_out = 16'h0000;
            endcase
        end
    end

    
endmodule