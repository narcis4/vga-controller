`timescale 1ns/1ns

module tb_buffer;

    reg clk;
    reg wr_en;
    reg [6:0] col_w;
    reg [4:0] row_w;
    reg [6:0] col_r;
    reg [4:0] row_r;
    reg [6:0] din;  
    wire [6:0] dout;
    reg write_done;
    reg ini_read_done;
    reg write_delay;
    reg finish;
    reg error;
    reg error2;

    initial begin
        $dumpfile("tb_buffer.vcd");
        $dumpvars(0, tb_buffer);
        wait(finish); // last tile, bottom right
        #10 if (error == 1'b0 && error2 == 1'b0) $display("PASS");
        $finish;
    end

    initial begin
        clk = 1'b0;
        col_r = 7'd0;
        row_r = 5'd0;
        col_w = 7'd0;
        row_w = 5'd0;
        din = 7'd0;
        wr_en = 1'b1;
        write_done = 1'b0;
        ini_read_done = 1'b0;
        write_delay = 1'b0;
        finish = 1'b0;
        error = 1'b0;
        error2 = 1'b0;
    end
        
    buffer dut_buffer( .clk_i(clk), .wr_en_i(wr_en), .col_w_i(col_w), .row_w_i(row_w), .col_r_i(col_r), .row_r_i(row_r), .din_i(din), .dout_o(dout));

    // this test writes every tile starting from bottom right with increasing numbers starting from 0 and then reads all the tiles starting from top left
    always @(posedge clk) begin
        #1 if (!ini_read_done) begin
            if (col_r == 7'd0 && row_r == 5'd0) begin
                write_delay = 1'b1;
                $display("Doing initialization read...");
            end
            if (dout != 7'd0) begin
                $display("ERROR during initialization read at column %d row %d dout %d din %d", col_r, row_r, dout, din);
                error <= 1'b1;
            end
            col_r <= col_r + 1;
            if (col_r == 7'd79) begin
                col_r <= 7'd0;
                row_r <= row_r + 1;
            end
            if (row_r == 5'd29 && col_r == 7'd79) begin
                if (error == 1'b0) $display("Initilization read OK");
                ini_read_done <= 1'b1;
                row_r <= 5'd0;
                col_r <= 7'd0;
            end
            if (write_delay) begin
                if (col_w == 7'd0 && row_w == 5'd0) begin
                    $display("Doing full write...");
                end
                if (col_w != 7'd79 || row_w != 5'd29) begin
                    din <= din + 1;
                    col_w <= col_w + 1;
                    if (col_w == 7'd79) begin
                        col_w <= 7'd0;
                        row_w <= row_w + 1;
                    end
                end
                else begin
                    write_done <= 1'b1;
                    din <= 7'd0;
                    wr_en <= 1'b0;
                    $display("Full write OK");
                end
            end
        end
        else begin
            if (write_done) begin
                if (col_r == 7'd0 && row_r == 5'd0) begin
                    $display("Doing final read...");
                end 
                if (dout != din) begin
                    $display("ERROR during final read at column %d row %d dout %d din %d", col_r, row_r, dout, din);
                    error2 <= 1'b1;
                end
                din <= din + 1;
                col_r <= col_r + 1;
                if (col_r == 7'd79) begin
                    col_r <= 7'd0;
                    row_r <= row_r + 1;
                end
                if (row_r == 5'd29 && col_r == 7'd79) begin
                    finish = 1'b1;
                    if (error2 == 1'b0) $display("Final read OK");
                end
            end
        end
    end 

    /* Make a regular pulsing clock. */
    always #20 clk = !clk;

endmodule // test
