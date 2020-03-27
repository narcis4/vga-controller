module miter (
    input clk,
	input ref_din_data,
	input uut_din_data,
);
	wire [15:0] ref_dout_data;
	wire [15:0] uut_dout_data;

	top ref (
		.mutsel    (1'b 0),
        .clk_i (clk),
		.rx_i  (ref_din_data),
		.PMOD (ref_dout_data)
	);

	top uut (
		.mutsel    (1'b 1),
        .clk_i (clk),
		.rx_i  (uut_din_data),
		.PMOD (uut_dout_data)
	);

	always @* begin
        assume (ref_din_data == uut_din_data);
		assert (ref_dout_data == uut_dout_data);
	end
endmodule
