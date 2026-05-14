module digit_palette (
	input logic [3:0] index,
	output logic [3:0] red, green, blue
);

localparam [0:15][11:0] palette = {
	{4'hF, 4'h0, 4'hF},
	{4'h3, 4'hF, 4'h1},
	{4'h0, 4'h6, 4'h0},
	{4'hF, 4'h0, 4'hF},
	{4'hF, 4'h0, 4'hF},
	{4'hF, 4'h0, 4'hF},
	{4'hF, 4'h0, 4'hF},
	{4'hF, 4'h0, 4'hF},
	{4'hF, 4'h0, 4'hF},
	{4'hF, 4'h0, 4'hF},
	{4'hF, 4'h0, 4'hF},
	{4'hF, 4'h0, 4'hF},
	{4'hF, 4'h0, 4'hF},
	{4'hF, 4'h0, 4'hF},
	{4'hF, 4'h0, 4'hF},
	{4'hF, 4'h0, 4'hF}
};

assign {red, green, blue} = palette[index];

endmodule
