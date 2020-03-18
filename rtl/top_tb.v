`timescale 1ns/1ns

module top_tb;

    reg clk;
    

  /* Make a reset that pulses once. */
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        #1000000 $finish;
    end

    initial begin
        clk = 1'b0;
    end
        
    top top_inst( .clk(clk));

    /* Make a regular pulsing clock. */
    always #20 clk = !clk;

endmodule // test

