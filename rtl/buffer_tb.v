`timescale 1ns/1ns

module buffer_tb;

    reg clk;
    reg wr_en;
    reg [6:0] col_w;
    reg [4:0] row_w;
    reg [6:0] col_r;
    reg [4:0] row_r;
    reg [6:0] din;  

    initial begin
        $dumpfile("buffer_tb.vcd");
        $dumpvars(0, buffer_tb);
        wait(row_r == 5'd29 && col_r == 7'd79); // last tile, bottom right
        $finish;
    end

    initial begin
        clk = 1'b0;
        col_r = 7'd0;
        row_r = 5'd0;
        col_w = 7'd79;
        row_w = 5'd29;
        din = 7'd1;
        #10 wr_en = 1'b1;
    end
        
    buffer buf_inst( .clk(clk), .wr_en(wr_en), .col_w(col_w), .row_w(row_w), .col_r(col_r), .row_r(row_r), .din(din));

    // this test reads every tile starting from top left and writes all the tiles starting from bottom right with increasing numers starting from 1
    always @(posedge clk) begin
        col_r <= col_r + 1;
        if (col_r == 7'd80) begin
            col_r <= 7'd0;
            row_r <= row_r + 1;
        end
        col_w <= col_w - 1;
        if (col_w == 7'b1111111) begin
            col_w <= 7'd79;
            row_w <= row_w - 1;
        end
        din <= din + 1;
    end 

    /* Make a regular pulsing clock. */
    always #20 clk = !clk;

endmodule // test
