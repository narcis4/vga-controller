`default_nettype none
`timescale 1ns/1ns

module tb_vga_buffer;

    reg clk;
    reg wr_en;
    reg [10-1:0] w_addr_i;   
    reg [32/8-1:0] w_strb_i;
    reg [10-1:0] r_addr_i;
    reg r_req_i;
    reg [9:0] vr_addr;
    reg [28-1:0] din;  
    wire [28-1:0] dout;
    reg write_done;
    reg ini_read_done;
    reg write_delay;
    reg finish;
    reg error;
    reg error2;
    reg fin;
    reg error3;

    initial begin
        $dumpfile("tb_vga_buffer.vcd");
        $dumpvars(0, tb_vga_buffer);
        wait(fin);
        #10 if (error == 1'b0 && error2 == 1'b0 && error3 == 1'b0) $display("PASS");
        $finish;
    end

    initial begin
        clk = 1'b0;
        w_addr_i = 10'd0;
        w_strb_i = 4'b1111;
        r_addr_i = 10'd0;
        r_req_i = 1'b0;
        vr_addr = 10'd0;
        din = 28'd0;
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
        
    vga_buffer dut_vga_buffer( .clk_i(clk), .wr_en_i(wr_en), .w_addr_i(w_addr_i), .w_strb_i(w_strb_i), .r_addr_i(r_addr_i), .r_req_i(r_req_i), 
.vr_addr_i(vr_addr), .din_i(din), .dout_o(dout));

    // this test does a initialization read, writes every tile starting from bottom right with increasing numbers starting from 0, then reads 
    // all the tiles starting from top left and finally performs writes with write strobes
    always @(posedge clk) begin
        // initialization read
        #1 if (!ini_read_done) begin
            if (vr_addr == 10'd0) begin
                write_delay = 1'b1;
                $display("Doing initialization read...");
            end
            if (dout != 28'd0) begin
                $display("ERROR during initialization read at addr %d dout %d din %d", vr_addr, dout, din);
                error <= 1'b1;
            end
            vr_addr <= vr_addr + 1;
            if (vr_addr == 10'd599) begin
                if (error == 1'b0) $display("Initilization read OK");
                ini_read_done <= 1'b1;
                vr_addr <= 10'd0;
            end
            // full write
            if (write_delay) begin
                if (w_addr_i == 10'd0) begin
                    $display("Doing full write...");
                end
                if (w_addr_i != 10'd599) begin
                    din <= din + 1;
                    w_addr_i <= w_addr_i + 1;
                end
                else begin
                    write_done <= 1'b1;
                    din <= 28'd0;
                    wr_en <= 1'b0;
                    $display("Full write OK");
                end
            end
        end
        // full read
        else if (!finish) begin
            if (write_done) begin
                if (vr_addr == 10'd0) begin
                    $display("Doing final read...");
                    wr_en <= 1'b0;
                end 
                if (dout != din) begin
                    $display("ERROR during final read at address %d dout %d din %d", vr_addr, dout, din);
                    error2 <= 1'b1;
                end
                din <= din + 1;
                vr_addr <= vr_addr + 1;
                if (vr_addr == 10'd599) begin
                    finish = 1'b1;
                    if (error2 == 1'b0) $display("Final read OK");
                end
            end
        end
    end 

    // Write using strobes
    initial begin
        wait(finish);
        #5 $display("Doing write with strobes...");
        w_addr_i = 10'd4;
        w_strb_i = 4'b1111;
        wr_en = 1'b1;
        din = 28'hBBBBBBB; // 28'b1011101110111011101110111011
        #40 vr_addr = 10'd4;
        wr_en = 1'b0;
        #40 if (dout != 28'hBBBBBBB) begin
            $display("ERROR during write strobe full at address %d dout %d", vr_addr, dout);
            error3 = 1'b1;
        end
        w_strb_i = 4'b0000;
        wr_en = 1'b1;
        din = 28'h4444444;
        #40 vr_addr = 10'd4;
        #40 if (dout != 28'hBBBBBBB) begin
            $display("ERROR during write strobe 0 at address %d dout %d", vr_addr, dout);
            error3 = 1'b1;
        end
        w_strb_i = 4'b1010;
        wr_en = 1'b1;
        din = 28'b0001111000010000010000000011;
        #40 vr_addr = 10'd4;
        #40 if (dout != 28'b0001111110111000010000111011) begin
            $display("ERROR during write strobe partial at address %d dout %d", vr_addr, dout);
            error3 = 1'b1;
        end
        #5 if (!error3) $display("Write strobes OK");
        fin = 1'b1;
    end

    /* Make a regular pulsing clock. */
    always #20 clk = !clk;

endmodule // test

`default_nettype wire
