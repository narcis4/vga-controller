`timescale 1us/10ns

module top_tb;

    reg clk;
    reg rx;
    
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        #10000 $finish;
    end
    
    // this test sends data to print 2 characters, a '2' in column 17 row 29, and a '9' in column 79 row 0
    initial begin
        clk = 1'b0;
        // send column 17
        rx = 1'b0;         // start bit
        #8.68 rx = 1'b1;   // data bits
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;   // stop bit
        // send row 29
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        // send ASCII 50 (character '2')
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        // send column 79
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        // send row 0
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        // send ASCII 57 (character '9')
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
    end
        
    top dut_top( .clk_i(clk), .rx_i(rx));

    /* Make a regular pulsing clock. */
    always #0.02 clk = !clk;

endmodule // test

