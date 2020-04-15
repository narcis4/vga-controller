module miter (
    input clk,
	input wr_en,
    input col_w,
    input row_w,
    input col_r,
    input row_r,
    input din
);
	wire [6:0] ref_dout;
	wire [6:0] uut_dout;

	buffer ref (
		.mutsel    (1'b 0),
        .clk_i (clk),
		.wr_en_i  (wr_en),
		.col_w_i (col_w),
        .row_w_i (row_w),
        .col_r_i (col_r),
        .row_r_i (row_r),
        .din_i (din),
        .dout_o (ref_dout)
	);

	buffer uut (
		.mutsel    (1'b 1),
        .clk_i (clk),
		.wr_en_i  (wr_en),
		.col_w_i (col_w),
        .row_w_i (row_w),
        .col_r_i (col_r),
        .row_r_i (row_r),
        .din_i (din),
        .dout_o (uut_dout)
	);

	always @* begin
		assert (ref_dout == uut_dout);
	end
endmodule
