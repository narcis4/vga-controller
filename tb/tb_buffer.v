`default_nettype none
`timescale 1ns/1ns

module tb_buffer;

    reg clk;
    reg wr_en;
    reg [12-1:0] w_addr_i;   
    reg [32/8-1:0] w_strb_i;
    reg [12-1:0] r_addr_i;
    reg r_req_i;
    reg [6:0] col_r;
    reg [4:0] row_r;
    reg [31:0] din;  
    wire [6:0] dout;
    reg write_done;
    reg ini_read_done;
    reg write_delay;
    reg finish;
    reg error;
    reg error2;
    reg fin;
    reg error3;

    initial begin
        $dumpfile("tb_buffer.vcd");
        $dumpvars(0, tb_buffer);
        wait(fin);
        #10 if (error == 1'b0 && error2 == 1'b0 && error3 == 1'b0) $display("PASS");
        $finish;
    end

    initial begin
        clk = 1'b0;
        w_addr_i = 12'd0;
        w_strb_i = 4'b0001;
        r_addr_i = 12'd0;
        r_req_i = 1'b0;
        col_r = 7'd0;
        row_r = 5'd0;
        din = 32'd0;
        wr_en = 1'b1;
        write_done = 1'b0;
        ini_read_done = 1'b0;
        write_delay = 1'b0;
        finish = 1'b0;
        error = 1'b0;
        error2 = 1'b0;
        error3 = 1'b0;
        fin = 1'b0;
    end
        
    buffer dut_buffer( .clk_i(clk), .wr_en_i(wr_en), .w_addr_i(w_addr_i), .w_strb_i(w_strb_i), .r_addr_i(r_addr_i), .r_req_i(r_req_i), 
.col_r_i(col_r), .row_r_i(row_r), .din_i(din), .dout_o(dout));

    // this test does a initializationr read, writes every tile starting from bottom right with increasing numbers starting from 0, then reads 
    // all the tiles starting from top left and finally performs writes with write strobes
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
                if (w_addr_i == 12'd0) begin
                    $display("Doing full write...");
                end
                if (w_addr_i != 12'd2399) begin
                    din <= din + 1;
                    w_addr_i <= w_addr_i + 1;
                end
                else begin
                    write_done <= 1'b1;
                    din <= 7'd0;
                    wr_en <= 1'b0;
                    $display("Full write OK");
                end
            end
        end
        else if (!finish) begin
            if (write_done) begin
                if (col_r == 7'd0 && row_r == 5'd0) begin
                    $display("Doing final read...");
                    wr_en <= 1'b0;
                end 
                if (dout != din[6:0]) begin
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

    initial begin
        wait(finish);
        #5 $display("Doing write with strobes...");
        w_addr_i = 12'd4;
        w_strb_i = 4'b1111;
        wr_en = 1'b1;
        din = 32'hBBBBBBBB;
        #40 col_r = 7'd4;
        row_r = 7'd0;
        wr_en = 1'b0;
        #40 if (dout != 7'h3B) begin
            $display("ERROR during write strobe full at column %d row %d dout %d", col_r, row_r, dout);
            error3 = 1'b1;
        end
        col_r = 7'd5;
        #40 if (dout != 7'h3B) begin
            $display("ERROR during write strobe full at column %d row %d dout %d", col_r, row_r, dout);
            error3 = 1'b1;
        end
        col_r = 7'd6;
        #40 if (dout != 7'h3B) begin
            $display("ERROR during write strobe full at column %d row %d dout %d", col_r, row_r, dout);
            error3 = 1'b1;
        end
        col_r = 7'd7;
        #40 if (dout != 7'h3B) begin
            $display("ERROR during write strobe full at column %d row %d dout %d", col_r, row_r, dout);
            error3 = 1'b1;
        end
        w_strb_i = 4'b0000;
        wr_en = 1'b1;
        din = 32'h44444444;
        #40 col_r = 7'd4;
        wr_en = 1'b0;
        #40 if (dout != 7'h3B) begin
            $display("ERROR during write strobe 0 at column %d row %d dout %d", col_r, row_r, dout);
            error3 = 1'b1;
        end
        #5 if (!error3) $display("Write strobes OK");
        fin = 1'b1;
    end

    /* Make a regular pulsing clock. */
    always #20 clk = !clk;

endmodule // test

`default_nettype wire
