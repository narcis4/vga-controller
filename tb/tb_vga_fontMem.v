`default_nettype none
`timescale 1ns/1ns

module tb_vga_fontMem;

    reg clk;
    reg [10:0] addr;
    wire [0:7] dout;
    reg [0:7] expected [0:2047];
    reg [10:0] addr_w;
    reg wr_en;
    reg [0:7] din;
    reg error;
    reg read;
    reg write_done;
    reg finish;

    initial begin
        $dumpfile("tb_vga_fontMem.vcd");
        $dumpvars(0, tb_vga_fontMem);
        wait(finish); 
        if (error == 1'b0) $display("PASS");
        $finish;
    end

    initial begin
        clk = 1'b0;
        addr = 11'd0;
        error = 1'b0;
        addr_w = 11'd0;
        wr_en = 1'b0;
        din = 8'd0;
        read = 1'b1;
        write_done = 1'b0;
        finish = 1'b0;
`ifdef WAVE
        $readmemb("../../includes/char_bitmap/charmem_8b_data.list", expected);
`else
        $readmemb("../includes/char_bitmap/charmem_8b_data.list", expected);
`endif
    end
        
    vga_fontMem dut_vga_fontMem( .clk_i(clk), .addr_i(addr), .dout_o(dout), .addr_w_i(addr_w), .wr_en_i(wr_en), .din_i(din));

    // this test reads all memory positions starting from 0 and checks that they have the expected value, then does a full write and a full read
    always @(posedge clk) begin
        #1 if (read) begin
            if (dout != expected[addr]) begin
                $display("Error during initial read at address %d", addr);
                error <= 1'b1;
            end
            addr <= addr + 1;
            if (addr == 11'd2047) begin
                read <= 1'b0;
                wr_en <= 1'b1;
                addr <= 11'd0;
            end
        end
        else if (~write_done) begin
            if (dout != 8'd0) begin
                $display("Error during write at w_address %d, read address %d", addr_w, addr);
                error <= 1'b1;
            end
            if (addr_w != 11'd2047) begin
                din <= din + 1;
                addr_w <= addr_w + 1;
            end
            else begin
                write_done <= 1'b1;
                din <= 8'd0;
                wr_en <= 1'b0;
            end
        end
        if (write_done) begin
            if (dout != din) begin
                $display("ERROR during final read at address %d dout %d din %d", addr, dout, din);
                error <= 1'b1;
            end
            din <= din + 1;
            addr <= addr + 1;
            if (addr == 11'd2047) finish = 1'b1;    
        end
    end 

    /* Make a regular pulsing clock. */
    always #20 clk = !clk;

endmodule // test

`default_nettype wire
