/* -----------------------------------------------
 * Project Name   : DRAC
 * File           : vga_buffer.v
 * Organization   : Barcelona Supercomputing Center
 * Author         : Narcis Rodas
 * Email(s)       : narcis.rodaquiroga@bsc.es
 */

`default_nettype none

// Screen buffer divided in 80x30 tiles, each containing the 7 bit address of a character
module vga_buffer 
#(
    parameter H_TILES = 640/8,                      // 640x480 resolution and chars of 8x16 pixels
    parameter V_TILES = 480/16,
    parameter NUM_TILES = H_TILES*V_TILES,          // 80x30 = 2400
    parameter NUM_ADDRS = NUM_TILES/4,
    parameter ADDR_COL_WIDTH = 7,                   // log2(80)
    parameter ADDR_ROW_WIDTH = 5,                   // log2(30)
    parameter DATA_WIDTH = 28,                      // log2(128 possible characters)
    parameter ADDR_WIDTH = 10,
    parameter C_AXI_DATA_WIDTH = 32,                // Width of the AXI-lite bus
    parameter C_AXI_ADDR_WIDTH = 13,                // AXI addr width based on the number of registers
    parameter ADDRLSB = $clog2(C_AXI_DATA_WIDTH)-3, // Least significant bits from address not used due to write strobes
    parameter SINGLE_DATA = 7
)
(
`ifdef FORMAL
    input wire [C_AXI_DATA_WIDTH-1:0] f_rdata_i,    // AXI read data
    input wire f_past_valid_i,                      // 1 after the first clock edge
    input wire f_reset_i,                           // AXI reset
    input wire f_ready_i,                           // AXI read ready
    input wire clk_axi_i,                           // AXI clk
`endif
    input wire                          clk_i,      // 25 MHz clock
    input wire                          wr_en_i,    // write enable for the data input
    input wire [ADDR_WIDTH-1:0]         w_addr_i,   // write address from AXI //input wire [C_AXI_ADDR_WIDTH-ADDRLSB-1:0] w_addr_i,
    input wire [C_AXI_DATA_WIDTH/8-1:0] w_strb_i,   // write strobe
    input wire [ADDR_WIDTH-1:0]         r_addr_i,   // read address //input wire [C_AXI_ADDR_WIDTH-ADDRLSB-1:0] r_addr_i,
    input wire                          r_req_i,    // read enable
    //input wire [ADDR_COL_WIDTH-1:0]     col_r_i,    // column of tile to read
    //input wire [ADDR_ROW_WIDTH-1:0]     row_r_i,    // row of tile to read
    input wire [ADDR_WIDTH-1:0]         vr_addr_i,
    input wire [DATA_WIDTH-1:0]         din_i,      // data input, the ASCII code of the character
    output reg [DATA_WIDTH-1:0]         dout_o,     // data output for the display
    output reg [DATA_WIDTH-1:0]         r_data_o    // data read for the AXI
    
);
 
    reg [DATA_WIDTH-1:0] bmem [0:NUM_ADDRS-1]; // memory of the current frame

    // memory initialization
    integer i;
    initial begin
        for (i=0; i<NUM_ADDRS;i=i+1) begin
            bmem[i]=28'd0;
        end
    end

    // read for display and write from AXI operation
    integer k;
    always @(posedge clk_i)
    begin
        dout_o <= bmem[vr_addr_i]; 
        if (wr_en_i) begin
            for(k=0; k<C_AXI_DATA_WIDTH/8; k=k+1) begin
			    if (w_strb_i[k]) bmem[w_addr_i] <= din_i[k*7+:6]; 
		    end
        end
    end
    
    // read for AXI
    always @(posedge clk_i) begin
        if (r_req_i) begin
            r_data_o <= bmem[r_addr_i];
        end
    end

`ifdef FORMAL
    // Check that read data from a transaction matches the state of the registers 1 cycle earlier
    always @(posedge clk_axi_i)
	if (f_past_valid_i && $past(f_reset_i
			&& f_ready_i))
	begin
        assert(f_rdata_i == $past({1'b0, bmem[r_addr_i][SINGLE_DATA*4-1:SINGLE_DATA*3], 1'b0, bmem[r_addr_i][SINGLE_DATA*3-1:SINGLE_DATA*2],
               1'b0, bmem[r_addr_i][SINGLE_DATA*2-1:SINGLE_DATA], 1'b0, bmem[r_addr_i][SINGLE_DATA-1:0]}));
	end
`endif
            
endmodule

`default_nettype wire
