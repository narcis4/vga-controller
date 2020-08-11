`timescale 1us/1ns

module tb_vga_top;

    localparam	C_AXI_ADDR_WIDTH = 15;
	localparam	C_AXI_DATA_WIDTH = 32;

    reg                          clk;	
    reg                          rstn;       
    wire [15:0]                  pmod;        
    reg [C_AXI_DATA_WIDTH-1:0]   axil_wdata; 
    reg [C_AXI_DATA_WIDTH/8-1:0] axil_wstrb; 
    reg [C_AXI_ADDR_WIDTH-1:0]   axil_waddr; 
    reg                          axil_wready;
    reg                          axil_rreq;   
    reg [C_AXI_ADDR_WIDTH-1:0]   axil_raddr;
    wire [C_AXI_DATA_WIDTH-1:0]  axil_rdata;
   
    reg error;

    initial begin
        $dumpfile("tb_vga_top.vcd");
        $dumpvars(0, tb_vga_top);
        #40000 if (error == 1'b0) $display("PASS");
        $finish;
    end

    // this test sends the characters 'A' and 'C' to write, then checks that the corresponding pixels of the screen are white, overwrites the first row
    // of pixels of the character 'A' and checks it, writes and reads the color register and activates debug mode to read from the ROM memory
    initial begin
        // signal initialization
        clk = 1'b0;
        rstn = 1'b0;
        error = 1'b0;
        #0.02 rstn = 1'b1;
        // send the address 0 for the first column and row of the screen and the data for the character 'A'
        axil_wdata = 32'd65; // 'A' in ASCII
        axil_wstrb = 4'b1111;
        axil_waddr = 15'h4000; // first buffer address
        axil_wready = 1'b1;
        axil_rreq = 1'b0;
        axil_raddr = 15'd0;
        error = 1'b0;
        #0.020 axil_wready = 1'b0;
        // send the address of the last tile and the data for the character 'C'
        #0.04 axil_wdata = 32'h43000000; // 'C' in ASCII to the last tile
        axil_waddr = 15'h495F; // 4096 + 2399
        axil_wready = 1'b1;
        #0.04 axil_wready = 1'b0;
        // wait for the start of the next frame and then the first white pixel
        #17546.75 wait(pmod[7:0] == 8'hFF);
        // next pixel of the character 'A' is at next line -1 pixel, so (800 horizontal cycles -1)*0.04 clk = 31.96, add 0.01 to have time to change output
        #31.97 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 1");
            error = 1'b1;
        end
        // next pixel is 2 away
        #0.08 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 2");
            error = 1'b1;
        end
        #31.92 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 3");
            error = 1'b1;
        end
        #0.08 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 4");
            error = 1'b1;
        end
        #31.92 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 5");
            error = 1'b1;
        end
        #0.08 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 6");
            error = 1'b1;
        end
        #31.88 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 7");
            error = 1'b1;
        end
        #0.16 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 8");
            error = 1'b1;
        end
        #31.84 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 9");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 10");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 11");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 12");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 13");
            error = 1'b1;
        end
        #31.84 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 14");
            error = 1'b1;
        end
        #0.16 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 15");
            error = 1'b1;
        end
        #31.84 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 16");
            error = 1'b1;
        end
        #0.16 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 17");
            error = 1'b1;
        end
        #31.80 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 18");
            error = 1'b1;
        end
        #0.24 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 19");
            error = 1'b1;
        end
        #31.76 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 20");
            error = 1'b1;
        end
        #0.24 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 21");
            error = 1'b1;
        end
        #31.76 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 22");
            error = 1'b1;
        end
        #0.24 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 23");
            error = 1'b1;
        end
        // check the white pixels for the character 'C'
        $display("Character C");
        #10 wait(pmod[7:0] == 8'hFF); 
        #0.05 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 1");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 2");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 3");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 4");
            error = 1'b1;
        end
        #31.80 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 5");
            error = 1'b1;
        end
        #0.24 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 6");
            error = 1'b1;
        end
        #31.76 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 7");
            error = 1'b1;
        end
        #32 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 8");
            error = 1'b1;
        end
        #32 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 9");
            error = 1'b1;
        end
        #32 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 10");
            error = 1'b1;
        end
        #32 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 11");
            error = 1'b1;
        end
        #32 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 12");
            error = 1'b1;
        end
        #32 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 13");
            error = 1'b1;
        end
        #32 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 14");
            error = 1'b1;
        end
        #0.24 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 15");
            error = 1'b1;
        end
        #31.80 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 16");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 17");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 18");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 19");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 20");
            error = 1'b1;
        end
        #0.04 axil_wdata = 32'h000000FF; // write all the pixels to 1
        axil_waddr = 15'h1040; // first line of character 'A' memory address
        axil_wready = 1'b1;
        #0.04 axil_wready = 1'b0;
        $display("ROM memory overwrite");
        wait(pmod[7:0] == 8'hFF); // wait for the next white pixel and check that the next 7 are also white
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 1");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 2");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 3");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 4");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 5");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 6");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("ERROR 7");
            error = 1'b1;
        end
        #0.04 axil_wdata = 32'h00000000; // write the color 0
        axil_waddr = 15'h2004; // second reg memory address (red component for characters)
        axil_wready = 1'b1;
        #0.04 axil_wready = 1'b0;
        $display("Color register write and read");
        wait(pmod[7:0] == 8'h0F);
        #31.97 if (pmod[7:0] != 8'h0F) begin
            $display("ERROR 1");
            error = 1'b1;
        end
        #0.04 axil_raddr = 15'h2004;
        axil_rreq = 1'b1;
        #0.04 if (axil_rdata != 32'h00000000) begin
            $display("ERROR 2");
            error = 1'b1;
        end
        #0.04 axil_raddr = 15'h1040; // first line of character 'A' memory address
        $display("Debug mode write and ROM read");
        #0.04 if (axil_rdata != 32'h00000000) begin // check that data read is 0 when debug mode is OFF
            $display("ERROR 1");
            error = 1'b1;
        end
        #0.04 axil_wdata = 32'h00000001; // activate debug mode
        axil_waddr = 15'h2018; // debug mode configuration register address
        axil_wready = 1'b1;
        #0.04 axil_wready = 1'b0;
        axil_raddr = 15'h1040;
        #0.04 if (axil_rdata != 32'h000000FF) begin // check data read from the ROM
            $display("ERROR 2");
            error = 1'b1;
        end
        $display("END");
    end
        
    vga_top dut_vga_top( .clk_i(clk), .rstn_i(rstn), .PMOD(pmod), .axil_wdata_i(axil_wdata), .axil_wstrb_i(axil_wstrb), .axil_waddr_i(axil_waddr), 
    .axil_wready_i(axil_wready), .axil_rreq_i(axil_rreq), .axil_raddr_i(axil_raddr), .axil_rdata_o(axil_rdata));

    /* Make a regular pulsing clock. */
    always #0.01 clk = !clk;

endmodule // test
