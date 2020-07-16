////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	easyaxil
// {{{
// Project:	WB2AXIPSP: bus bridges and other odds and ends
//
// Purpose:	Demonstrates a simple AXI-Lite interface.
//
//	This was written in light of my last demonstrator, for which others
//	declared that it was much too complicated to understand.  The goal of
//	this demonstrator is to have logic that's easier to understand, use,
//	and copy as needed.
//
//	Since there are two basic approaches to AXI-lite signaling, both with
//	and without skidbuffers, this example demonstrates both so that the
//	differences can be compared and contrasted.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
// }}}
// Copyright (C) 2020, Gisselquist Technology, LLC
// {{{
//
// This file is part of the WB2AXIP project.
//
// The WB2AXIP project contains free software and gateware, licensed under the
// Apache License, Version 2.0 (the "License").  You may not use this project,
// or this file, except in compliance with the License.  You may obtain a copy
// of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations
// under the License.
//
////////////////////////////////////////////////////////////////////////////////
/* -----------------------------------------------
 * Project Name   : DRAC
 * File           : axi_vga.v
 * Organization   : Barcelona Supercomputing Center
 * Modified by    : Narcis Rodas
 * Email(s)       : narcis.rodaquiroga@bsc.es
 */
// }}}
//
`default_nettype none

//The AXI-lite wrapper for interfacing with the VGA. The VGA can handle up to 1 AXI transaction every 2 bus cycles. 
module axi_vga #(
		// {{{
		parameter	C_AXI_ADDR_WIDTH = 15,               // Addr width based on the number of registers
		parameter	C_AXI_DATA_WIDTH = 32,               // Width of the AXI-lite bus
		parameter [0:0]	OPT_SKIDBUFFER = 1'b0,           // This determines if we want to use more logic to achieve 1 transaction per bus cycle
		parameter [0:0]	OPT_LOWPOWER = 0,                // Lowpower option to disable channels if inactive
		parameter	ADDRLSB = $clog2(C_AXI_DATA_WIDTH)-3 // Least significant bits from address not used
		// }}}
	) (
		// {{{
		input wire					        S_AXI_ACLK,    // AXI bus clock
		input wire					        S_AXI_ARESETN, // AXI reset
		//
		input wire					        S_AXI_AWVALID, // The write address from the master in AWADDR is valid and can be read
		output wire					        S_AXI_AWREADY, // The slave (the VGA) is ready to read the write address
		input wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_AWADDR,  // The write address for the transaction
		input wire [2:0]			        S_AXI_AWPROT,  // The write address protection level (level of priviledge)
		//
		input wire					        S_AXI_WVALID,  // The write data in WDATA is valid and can be read
		output wire					        S_AXI_WREADY,  // The VGA is ready to read the write data
		input wire [C_AXI_DATA_WIDTH-1:0]   S_AXI_WDATA,   // The write data from the master
		input wire [C_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,   // This determines which bytes of the write data to write and to leave the rest unchanged
		//
		output wire					        S_AXI_BVALID,  // Write acknowledgement
		input wire					        S_AXI_BREADY,  // The master is ready to receive the write acknowledgement
		output wire [1:0]				    S_AXI_BRESP,   // The VGA sends the result code for the write operation
		//
		input wire					        S_AXI_ARVALID, // The read address from the master in ARADDR is valid and can be read
		output wire					        S_AXI_ARREADY, // The VGA is ready to read the read address
		input wire [C_AXI_ADDR_WIDTH-1:0]	S_AXI_ARADDR,  // The read address for the transaction
		input wire [2:0]				    S_AXI_ARPROT,  // The read address level of priviledge
		//
		output wire					        S_AXI_RVALID,  // The read data in RDATA is valid and can be read by the master
		input wire					        S_AXI_RREADY,  // The master is ready to read the RDATA
		output wire	[C_AXI_DATA_WIDTH-1:0]  S_AXI_RDATA,   // The read data from the slave
		output wire [1:0]				    S_AXI_RRESP,   // The VGA sends the result for the read operation
		// }}}
        output wire [15:0] vga_o                           // The VGA signal containing the RGB and horizontal and vertical sync signals
	);

	////////////////////////////////////////////////////////////////////////
	//
	// Register/wire signal declarations
	//
	////////////////////////////////////////////////////////////////////////

	wire i_reset = !S_AXI_ARESETN;

	reg				                axil_write_ready; // Register for holding the write enable of the registers
	reg [C_AXI_ADDR_WIDTH-1:0]      awskd_addr;       // Register for holding AWADDR 
	//
	reg [C_AXI_DATA_WIDTH-1:0]	    wskd_data;        // Register for holding WDATA
	reg [C_AXI_DATA_WIDTH/8-1:0]    wskd_strb;        // Register for holding WSTRB
	reg			                    axil_bvalid;      // Same as BVALID
	//
	wire				            axil_read_ready;  // The VGA is about to read the ARADDR
	wire [C_AXI_ADDR_WIDTH-1:0]     arskd_addr;       // Same as ARADDR
	wire [C_AXI_DATA_WIDTH-1:0]	    axil_read_data;   // Same as RDATA
	reg				                axil_read_valid;  // Same as RVALID

    wire axil_read_req;                               // The VGA is about to read from the registers into RDATA

	////////////////////////////////////////////////////////////////////////
	//
	// AXI-lite signaling
	//
	////////////////////////////////////////////////////////////////////////
    //
	// Write signaling
    //
	reg	axil_awready; // Same as AWREADY

`ifdef TBSIM2
    initial begin
        axil_awready = 1'b0;
        axil_bvalid = 0;
        axil_read_valid = 1'b0;
    end
`endif
    
    // Control of write ready, determines when the VGA is ready to accept a write transaction
	always @(posedge S_AXI_ACLK) begin
	    if (!S_AXI_ARESETN)
		    axil_awready <= 1'b0;
	    else
		    axil_awready <= !axil_awready
			    && (S_AXI_AWVALID && S_AXI_WVALID)
			    && (!S_AXI_BVALID || S_AXI_BREADY);
    end

	assign	S_AXI_AWREADY = axil_awready;
	assign	S_AXI_WREADY  = axil_awready;

    // This signal determines the write enable on the registers, it is held during 2 cycles because the VGA clock is slower than the bus
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN)
            axil_write_ready <= 1'b0;
        else
            axil_write_ready <= ((S_AXI_AWVALID && S_AXI_WVALID) && (!S_AXI_BVALID || S_AXI_BREADY)) || axil_awready;
    end

    // Update the write address, data and strobes when the VGA is ready to write, and hold their values until the next transaction
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            awskd_addr <= 1'b0;
            wskd_data <= 1'b0;
            wskd_strb <= 1'b0;
        end
        else if ((S_AXI_AWVALID && S_AXI_WVALID) && (!S_AXI_BVALID || S_AXI_BREADY) && !axil_awready) begin
            awskd_addr <= S_AXI_AWADDR[C_AXI_ADDR_WIDTH-1:0];
            wskd_data <= S_AXI_WDATA;
            wskd_strb <= S_AXI_WSTRB;
        end
    end

    // Control of write acknowledgement, it is set to 1 when the VGA accepts a write transaction
	always @(posedge S_AXI_ACLK) begin
	    if (i_reset)
		    axil_bvalid <= 0;
	    else if (axil_awready)
		    axil_bvalid <= 1;
	    else if (S_AXI_BREADY)
		    axil_bvalid <= 0;
    end

	assign	S_AXI_BVALID = axil_bvalid;
	assign	S_AXI_BRESP = 2'b00;

    //
	// Read signaling
    //
	reg	axil_arready; // Same as ARREADY

	always @(*) axil_arready = !S_AXI_RVALID;

	assign	arskd_addr = S_AXI_ARADDR[C_AXI_ADDR_WIDTH-1:0]; 
	assign	S_AXI_ARREADY = axil_arready;
	assign	axil_read_ready = (S_AXI_ARVALID && S_AXI_ARREADY);
    
    assign  axil_read_req = (!S_AXI_RVALID || S_AXI_RREADY);

    // Control of read valid, it is set to 1 when the read data can be read by the master
	always @(posedge S_AXI_ACLK) begin
	    if (i_reset)
		    axil_read_valid <= 1'b0;
	    else if (axil_read_ready)
		    axil_read_valid <= 1'b1;
	    else if (S_AXI_RREADY)
		    axil_read_valid <= 1'b0;
    end

	assign	S_AXI_RVALID = axil_read_valid;
	assign	S_AXI_RDATA  = axil_read_data;
	assign	S_AXI_RRESP = 2'b00;

	// Verilator lint_off UNUSED
	wire	unused;
	assign	unused = &{ 1'b0, S_AXI_AWPROT, S_AXI_ARPROT,
			S_AXI_ARADDR[ADDRLSB-1:0],
			S_AXI_AWADDR[ADDRLSB-1:0] };
	// Verilator lint_on  UNUSED

`ifdef	FORMAL
    vga_top #(.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH), .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH))
    vga_top_inst(.clk_i(S_AXI_ACLK), .rstn_i(S_AXI_ARESETN), .PMOD(vga_o), .axil_wdata_i(wskd_data), .axil_wstrb_i(wskd_strb), .axil_waddr_i(awskd_addr), 
    .axil_wready_i(axil_write_ready), .axil_rreq_i(axil_read_req), .axil_raddr_i(arskd_addr), .axil_rdata_o(axil_read_data), .f_rdata_i(axil_read_data), 
    .f_past_valid_i(f_past_valid), .f_reset_i(S_AXI_ARESETN), .f_ready_i(axil_read_ready));
	////////////////////////////////////////////////////////////////////////
	//
	// Formal properties used in verfiying this core
	//
	////////////////////////////////////////////////////////////////////////
	//
	// {{{
	reg	f_past_valid;
	initial	f_past_valid = 0;
	always @(posedge S_AXI_ACLK)
		f_past_valid <= 1;

	////////////////////////////////////////////////////////////////////////
	//
	// The AXI-lite control interface
	//
	////////////////////////////////////////////////////////////////////////
	//
	// {{{
	localparam	F_AXIL_LGDEPTH = 4;
	wire	[F_AXIL_LGDEPTH-1:0]	faxil_rd_outstanding,
					faxil_wr_outstanding,
					faxil_awr_outstanding;

	faxil_vga_slave #(
		// {{{
		.C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
		.F_LGDEPTH(F_AXIL_LGDEPTH),
		.F_AXI_MAXWAIT(2),
		.F_AXI_MAXDELAY(2),
		.F_AXI_MAXRSTALL(3),
		.F_OPT_COVER_BURST(4)
		// }}}
	) faxil(
		// {{{
		.i_clk(S_AXI_ACLK), .i_axi_reset_n(S_AXI_ARESETN),
		//
		.i_axi_awvalid(S_AXI_AWVALID),
		.i_axi_awready(S_AXI_AWREADY),
		.i_axi_awaddr( S_AXI_AWADDR),
		.i_axi_awcache(4'h0),
		.i_axi_awprot( S_AXI_AWPROT),
		//
		.i_axi_wvalid(S_AXI_WVALID),
		.i_axi_wready(S_AXI_WREADY),
		.i_axi_wdata( S_AXI_WDATA),
		.i_axi_wstrb( S_AXI_WSTRB),
		//
		.i_axi_bvalid(S_AXI_BVALID),
		.i_axi_bready(S_AXI_BREADY),
		.i_axi_bresp( S_AXI_BRESP),
		//
		.i_axi_arvalid(S_AXI_ARVALID),
		.i_axi_arready(S_AXI_ARREADY),
		.i_axi_araddr( S_AXI_ARADDR),
		.i_axi_arcache(4'h0),
		.i_axi_arprot( S_AXI_ARPROT),
		//
		.i_axi_rvalid(S_AXI_RVALID),
		.i_axi_rready(S_AXI_RREADY),
		.i_axi_rdata( S_AXI_RDATA),
		.i_axi_rresp( S_AXI_RRESP),
		//
		.f_axi_rd_outstanding(faxil_rd_outstanding),
		.f_axi_wr_outstanding(faxil_wr_outstanding),
		.f_axi_awr_outstanding(faxil_awr_outstanding)
		// }}}
		);

    // Check that when write acknowledgement or valid read data are set to 1 there is a write or read transaction in progress respectively
    // The write address has to be in the same as the write data since the write starts when both are accepted
	always @(*)
	begin
		assert(faxil_wr_outstanding == (S_AXI_BVALID ? 1:0));
		assert(faxil_awr_outstanding == faxil_wr_outstanding);

		assert(faxil_rd_outstanding == (S_AXI_RVALID ? 1:0));
	end

    // Check that when we read data from the registers, the read valid data is set to 1
	always @(posedge S_AXI_ACLK)
	if (f_past_valid && $past(S_AXI_ARESETN
			&& axil_read_ready))
	begin
		assert(S_AXI_RVALID);
	end

`else
    vga_top #(.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH), .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH))
    vga_top_inst(.clk_i(S_AXI_ACLK), .rstn_i(S_AXI_ARESETN), .PMOD(vga_o), .axil_wdata_i(wskd_data), .axil_wstrb_i(wskd_strb), .axil_waddr_i(awskd_addr), 
    .axil_wready_i(axil_write_ready), .axil_rreq_i(axil_read_req), .axil_raddr_i(arskd_addr), .axil_rdata_o(axil_read_data));
`endif

endmodule

`default_nettype wire

