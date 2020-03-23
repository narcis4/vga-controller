`timescale 1ns/1ns

module fontMem_tb;

    reg clk;
    reg [6:0] addr;

    initial begin
        $dumpfile("fontMem_tb.vcd");
        $dumpvars(0, fontMem_tb);
        wait(addr == 7'd127); // last character address
        $finish;
    end

    initial begin
        clk = 1'b0;
        addr = 7'd0;
    end
        
    fontMem dut_fontMem( .clk_i(clk), .addr_i(addr));

    // this test reads all memory positions starting from 0
    always @(posedge clk) begin
        addr <= addr + 1;
    end 

    /* Make a regular pulsing clock. */
    always #20 clk = !clk;

endmodule // test
