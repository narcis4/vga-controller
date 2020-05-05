`default_nettype none
`timescale 1ns/1ns

module tb_vga_fontMem;

    reg clk;
    reg [10:0] addr;
    wire [0:7] dout;
    reg [0:7] expected [0:2047];
    reg error;

    initial begin
        $dumpfile("tb_vga_fontMem.vcd");
        $dumpvars(0, tb_vga_fontMem);
        wait(addr == 11'd2047); // last character address
        if (error == 1'b0) $display("PASS");
        $finish;
    end

    initial begin
        clk = 1'b0;
        addr = 11'd0;
        error = 1'b0;
`ifdef WAVE
        $readmemb("../../rtl/char_bitmap/charmem_8b_data.list", expected);
`else
        $readmemb("../rtl/char_bitmap/charmem_8b_data.list", expected);
`endif
    end
        
    vga_fontMem dut_vga_fontMem( .clk_i(clk), .addr_i(addr), .dout_o(dout));

    // this test reads all memory positions starting from 0 and checks that they are the same
    always @(posedge clk) begin
        #1 if (dout != expected[addr]) begin
            $display("Error at address %d", addr);
            error <= 1'b1;
        end
        addr <= addr + 1;
    end 

    /* Make a regular pulsing clock. */
    always #20 clk = !clk;

endmodule // test

`default_nettype wire
