`timescale 1ns/100ps

module fontMem_tb;

    reg clk;
    reg [6:0] addr;

  /* Make a reset that pulses once. */
    initial begin
        $dumpfile("fontMem_tb.vcd");
        $dumpvars(0, fontMem_tb);
    end

    initial begin
        clk = 1'b0;
        addr = 7'd0;
        wait(addr == 127);
        $finish;
    end
        
    fontMem fmem_inst( .clk(clk), .addr(addr));

    always @(posedge clk) begin
        addr <= addr + 1;
    end 

    /* Make a regular pulsing clock. */
    always #20 clk = !clk;

endmodule // test
