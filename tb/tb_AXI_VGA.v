`default_nettype none
`timescale 1ns/1ns

module tb_AXI_VGA;

    localparam	C_AXI_ADDR_WIDTH = $clog2(2400);
	localparam	C_AXI_DATA_WIDTH = 32;
	localparam [0:0]	OPT_SKIDBUFFER = 1'b0;
	localparam [0:0]	OPT_LOWPOWER = 0;
	localparam	ADDRLSB = $clog2(C_AXI_DATA_WIDTH)-3;

    reg					         s_axi_aclk;
	reg					         s_axi_aresetn;
	//
	reg					         s_axi_awvalid;
	wire					     s_axi_awready;
	reg [C_AXI_ADDR_WIDTH-1:0]   s_axi_awaddr;
	reg [2:0]			         s_axi_awprot;
	//
	reg					         s_axi_wvalid;
	wire					     s_axi_wready;
	reg [C_AXI_DATA_WIDTH-1:0]   s_axi_wdata;
	reg [C_AXI_DATA_WIDTH/8-1:0] s_axi_wstrb;
	//
	wire					     s_axi_bvalid;
	reg					         s_axi_bready;
	wire [1:0]				     s_axi_bresp;
	//
	reg					         s_axi_arvalid; 
	wire					     s_axi_arready; 
	reg [C_AXI_ADDR_WIDTH-1:0]	 s_axi_araddr;
	reg [2:0]				     s_axi_arprot;
	//
	wire					     s_axi_rvalid;
	reg					         s_axi_rready;
	wire [C_AXI_DATA_WIDTH-1:0]  s_axi_rdata;
	wire [1:0]				     s_axi_rresp;
	// }}}
    wire [15:0]                  vga_o;
    
    reg                        error;
    reg                        write_end;
    reg [3:0]                  write_timeout;
    reg                        read_end;
    reg [3:0]                  read_timeout;
    reg [C_AXI_DATA_WIDTH-1:0] read_data;
    reg [C_AXI_DATA_WIDTH-1:0] read_data2;

    initial begin
        $dumpfile("tb_AXI_VGA.vcd");
        $dumpvars(0, tb_AXI_VGA);
        #2000 if (error == 1'b0) $display("PASS");
        $finish;
    end
    
    // This test makes 6 AXI-lite transactions, a read, a write, 2 writes (one right after the other, before the VGA has finished the first one) and 2 reads (also
    // without waiting between them). The writes also test different write strobes and the edge registers based on address
    initial begin
        // signal initialization
        s_axi_aclk = 1'b0;
        s_axi_aresetn = 1'b1;
        s_axi_awvalid = 1'b0;
        s_axi_awaddr = 12'b0;
        s_axi_awprot = 3'b0;
        s_axi_wvalid = 1'b0;
        s_axi_wdata = 32'b0;
        s_axi_wstrb = 4'b0;
        s_axi_bready = 1'b1;
        s_axi_arvalid = 1'b0;
        s_axi_araddr = 12'b0;
        s_axi_arprot = 3'b0;
        s_axi_rready = 1'b0;
        error = 1'b0;
        write_end = 1'b0;
        write_timeout = 4'd0;
        read_end = 1'b0;
        read_timeout = 4'd0;
        read_data = 32'd0;
        read_data2 = 32'd0;

        // first write, address 0, data 0xFFFFFFFF, strobe 1 (only writes the least significant register)
        #15 s_axi_awaddr = 12'd0;
        s_axi_awvalid = 1'b1;
        s_axi_wdata = 32'hFFFFFFFF;
        s_axi_wvalid = 1'b1;
        s_axi_wstrb = 4'b0001;
        #14 while (write_timeout < 10 && ~write_end) begin
            if (s_axi_awready) begin
                if (s_axi_wready) begin
                    #2 s_axi_awvalid = 1'b0;
                    s_axi_wvalid = 1'b0;
                end
                else #2 s_axi_awvalid = 1'b0;
            end
            else begin
                if (s_axi_wready) begin
                    #2 s_axi_wvalid = 1'b0;
                end
                else #2 s_axi_awprot = 3'd0;
            end
            if (~s_axi_awvalid && ~s_axi_wvalid) write_end = 1'b1;
            write_timeout = write_timeout + 1;
            #18 s_axi_awprot = 3'd0;
        end
        if (~write_end) begin
            $display("Write timeout, AXI slave was not ready for 10 cycles");
            error = 1'b1;
        end
        
        // first read, reads the address 0 to check the data written
        #6 s_axi_araddr = 12'd0;
        s_axi_arvalid = 1'b1;
        s_axi_rready = 1'b1;
        #14 while (read_timeout < 10 && ~read_end) begin
            if (s_axi_arready) begin
                if (s_axi_rvalid) begin
                    #2 s_axi_arvalid = 1'b0;
                    s_axi_rready = 1'b0;
                    read_data = s_axi_rdata;
                end
                else #2 s_axi_arvalid = 1'b0;
            end
            else begin
                if (s_axi_rvalid) begin
                    #2 s_axi_rready = 1'b0;
                    read_data = s_axi_rdata;
                end
                else #2 s_axi_awprot = 3'd0;
            end
            if (~s_axi_arvalid && ~s_axi_rready) read_end = 1'b1;
            read_timeout = read_timeout + 1;
            #18 s_axi_awprot = 3'd0;
        end
        if (~read_end) begin
            $display("Read timeout, AXI slave didn't put valid data for 10 cycles");
            error = 1'b1;
        end
        if (read_data != 32'h0000007F) begin
            $display("Wrong read data");
            error = 1'b1;
        end

        // second and third writes, address 2396 and 2398, data 0x99999999 and 0xE6E6E6E6, strobe F
        #6 s_axi_awaddr = 12'd2396;
        s_axi_awvalid = 1'b1;
        s_axi_wdata = 32'h99999999;
        s_axi_wvalid = 1'b1;
        s_axi_wstrb = 4'b1111;
        write_end = 1'b0;
        write_timeout = 4'd0;
        #14 while (write_timeout < 16 && ~write_end) begin
            if (s_axi_awaddr != 12'd2398 || s_axi_wdata != 32'hE6E6E6E6) begin
                if (s_axi_awready) begin
                    if (s_axi_wready) begin
                        #2 s_axi_awaddr = 12'd2398;
                        s_axi_wdata = 32'hE6E6E6E6;
                    end
                    else #2 s_axi_awaddr = 12'd2398;
                end
                else begin
                    if (s_axi_wready) begin
                        #2 s_axi_wdata = 32'hE6E6E6E6;
                    end
                    else #2 s_axi_awprot = 3'd0;
                end
                write_timeout = write_timeout + 1;
                #18 s_axi_awprot = 3'd0;
            end
            else begin
                if (s_axi_awready) begin
                    if (s_axi_wready) begin
                        #2 s_axi_awvalid = 1'b0;
                        s_axi_wvalid = 1'b0;
                    end
                    else #2 s_axi_awvalid = 1'b0;
                end
                else begin
                    if (s_axi_wready) begin
                        #2 s_axi_wvalid = 1'b0;
                    end
                    else #2 s_axi_awprot = 3'd0;
                end
                if (~s_axi_awvalid && ~s_axi_wvalid) write_end = 1'b1;
                write_timeout = write_timeout + 1;
                #18 s_axi_awprot = 3'd0;
            end         
        end
        if (~write_end) begin
            $display("Write 2 timeout, AXI slave didn't make 2 transactions in 16 cycles");
            error = 1'b1;
        end

        // second and third reads, check the data written before 
        #6 s_axi_araddr = 12'd2396;
        s_axi_arvalid = 1'b1;
        s_axi_rready = 1'b1;
        read_end = 1'b0;
        read_timeout = 4'd0;
        read_data = 32'h33333333;
        #14 while (read_timeout < 16 && ~read_end) begin
            if (s_axi_araddr != 12'd2398 || read_data == 32'h33333333) begin
                if (s_axi_arready) begin
                    if (s_axi_rvalid) begin
                        #2 read_data = s_axi_rdata;
                        s_axi_araddr = 12'd2398;
                    end
                    else #2 s_axi_araddr = 12'd2398;
                end
                else begin
                    if (s_axi_rvalid) begin
                        #2 read_data = s_axi_rdata;
                    end
                    else #2 s_axi_awprot = 3'd0;
                end
                read_timeout = read_timeout + 1;
                #18 s_axi_awprot = 3'd0;
            end
            else begin
                if (s_axi_arready) begin
                    if (s_axi_rvalid) begin
                        #2 s_axi_arvalid = 1'b0;
                        s_axi_rready = 1'b0;
                        read_data2 = s_axi_rdata;
                    end
                    else #2 s_axi_arvalid = 1'b0;
                end
                else begin
                    if (s_axi_rvalid) begin
                        #2 s_axi_rready = 1'b0;
                        read_data2 = s_axi_rdata;
                    end
                    else #2 s_axi_awprot = 3'd0;
                end
                if (~s_axi_arvalid && ~s_axi_rready) read_end = 1'b1;
                read_timeout = read_timeout + 1;
                #18 s_axi_awprot = 3'd0;
            end         
        end
        if (~read_end) begin
            $display("Read 2 timeout, AXI slave didn't put 2 valid datas in 16 cycles");
            error = 1'b1;
        end
        if (read_data != 32'h66661919) begin
            $display("Wrong first read 2 data");
            error = 1'b1;
        end  
        if (read_data2 != 32'h00006666) begin
            $display("Wrong second read 2 data");
            error = 1'b1;
        end   
    end

    AXI_VGA dut_AXI_VGA (.S_AXI_ACLK(s_axi_aclk), 
                         .S_AXI_ARESETN(s_axi_aresetn), 
                         .S_AXI_AWVALID(s_axi_awvalid), 
                         .S_AXI_AWREADY(s_axi_awready), 
                         .S_AXI_AWADDR(s_axi_awaddr), 
                         .S_AXI_AWPROT(s_axi_awprot), 
                         .S_AXI_WVALID(s_axi_wvalid), 
                         .S_AXI_WREADY(s_axi_wready), 
                         .S_AXI_WDATA(s_axi_wdata), 
                         .S_AXI_WSTRB(s_axi_wstrb), 
                         .S_AXI_BVALID(s_axi_bvalid), 
                         .S_AXI_BREADY(s_axi_bready), 
                         .S_AXI_BRESP(s_axi_bresp),
                         .S_AXI_ARVALID(s_axi_arvalid), 
                         .S_AXI_ARREADY(s_axi_arready), 
                         .S_AXI_ARADDR(s_axi_araddr), 
                         .S_AXI_ARPROT(s_axi_arprot),
                         .S_AXI_RVALID(s_axi_rvalid), 
                         .S_AXI_RREADY(s_axi_rready), 
                         .S_AXI_RDATA(s_axi_rdata), 
                         .S_AXI_RRESP(s_axi_rresp), 
                         .vga_o(vga_o));

    /* Make a regular pulsing clock. */
    always #10 s_axi_aclk = !s_axi_aclk;

endmodule

`default_nettype wire

