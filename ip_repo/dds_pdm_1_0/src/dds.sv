module dds_oscillator 
(
    input  logic        clk,
    input  logic        reset_n, //low-level reset
    input  logic [31:0] phase_increment,//from AXI, the step size
    output logic [15:0] audio_out
);

    logic [31:0] phase;//the current phase
    logic reset = ~reset_n;

    always_ff @(posedge clk or negedge reset_n)
    begin
        if (!reset_n) 
        begin
            phase <= 32'd0;
        end 

        else 
        begin
            phase <= phase + phase_increment;
        end
    end

    always_comb 
    begin
        if (phase_increment == 32'd0) //nothing being pressed
        begin
            audio_out = 16'h0000;
        end 
        else 
        begin
            if (phase[31] == 1'b1) 
            begin
                audio_out = 16'h7FFF;//the max output a 16bit signed number can represents
            end
            else 
            begin
                audio_out = 16'h8000;//the min output a 16 bit signed number can represent
            end
        end
    end

endmodule