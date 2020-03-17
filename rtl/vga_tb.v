`timescale 1ns/100ps

module vga_tb;

    reg clk;
    wire HS,VS;
    wire [9:0] x_px;
    wire [9:0] y_px;
    wire activevideo; 

    wire [6:0] current_col;
    wire [4:0] current_row;
    wire [2:0] x_img; 
    wire [3:0] y_img;
    wire wr_en;
    wire [6:0] col_w;
    wire [4:0] row_w;
    wire [6:0] din;

    reg [6:0] char_addr; // address of the char in the bitmap, ASCII code
    reg [0:Cwidth*Cheight-1] char; // bitmap of 1 character

  /* Make a reset that pulses once. */
    initial begin
        $dumpfile("vga_tb.vcd");
        $dumpvars(0, vga_tb);
    end

    initial begin
        clk = 1'b0;
        current_col = 7'd0;
        current_row = 5'd0;
        x_img = 3'd0;
        y_img = 4'd0;
        wr_en = 1'b0;
        col_w = 7'd0;
        row_w = 5'd0;
        din = 7'd0;
    end
        
    VGAsyncGen vga_inst( .clk(clk), .hsync(HS), .vsync(VS), .x_px(x_px), .y_px(y_px), .activevideo(activevideo));
    buffer buf_inst( .clk(clk), .wr_en(wr_en), .col_w(col_w), .row_w(row_w), .col_r(current_col), .row_r(current_row), .din(din), .dout(char_addr));
    fontMem fmem_inst( .clk(clk), .addr(char_addr), .dout(char));

    always @(posedge clk) begin
        x_img = x_img + 1;
        if (x_img == 0) begin
            y_img = y_img + 1;
            if (y_img == 0) begin
                current_col = current_col + 1;
                if (current_col == 80) begin
                    current_col = 7'd0;
                    current_row = current_row + 1;
                    if (current_row == 30) $finish;
                end
            end
        end
    end 

    /* Make a regular pulsing clock. */
    always #20 clk = !clk;

endmodule // test

