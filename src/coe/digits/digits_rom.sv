module digits_rom (
	input logic clock,
	input logic [12:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:5759] /* synthesis ram_init_file = "./digits/digits.COE" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
