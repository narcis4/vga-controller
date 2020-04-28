`default_nettype none

// Screen buffer divided in 80x30 tiles, each containing the 7 bit address of a character
module buffer 
#(
    parameter H_TILES = 640/8,             // 640x480 resolution and chars of 8x16 pixels
    parameter V_TILES = 480/16,
    parameter NUM_TILES = H_TILES*V_TILES, // 80x30 = 2400
    parameter ADDR_COL_WIDTH = 7,          // log2(80)
    parameter ADDR_ROW_WIDTH = 5,          // log2(30)
    parameter DATA_WIDTH = 7,               // log2(128 possible characters)
    parameter C_AXI_DATA_WIDTH = 32,
    parameter C_AXI_ADDR_WIDTH = $clog2(NUM_TILES),
    parameter ADDRLSB = $clog2(C_AXI_DATA_WIDTH)-3
)
(
`ifdef FORMAL
    input wire [C_AXI_DATA_WIDTH-1:0] f_rdata_i,
    input wire f_past_valid_i,
    input wire f_reset_i,
    input wire f_ready_i,
    input wire clk_axi_i,
`endif
    input wire                  clk_i,       // 25 MHz clock
    input wire                  wr_en_i,     // write enable for the data input
    input wire [C_AXI_ADDR_WIDTH-1:0] w_addr_i, // write address from AXI //input wire [C_AXI_ADDR_WIDTH-ADDRLSB-1:0] w_addr_i,
    input wire [C_AXI_DATA_WIDTH/8-1:0] w_strb_i, // write strobe
    input wire [C_AXI_ADDR_WIDTH-1:0] r_addr_i, // read address //input wire [C_AXI_ADDR_WIDTH-ADDRLSB-1:0] r_addr_i,
    input wire                  r_req_i, // read enable
    input wire [ADDR_COL_WIDTH-1:0] col_r_i, // column of tile to read
    input wire [ADDR_ROW_WIDTH-1:0] row_r_i, // row of tile to read
    input wire [C_AXI_DATA_WIDTH-1:0] din_i,       // data input, the ASCII code of the character
    output reg [DATA_WIDTH-1:0] dout_o,       // data output for the display
    output reg [C_AXI_DATA_WIDTH-1:0] r_data_o // data read for the AXI
    
);
 
    reg [DATA_WIDTH-1:0] bmem [0:NUM_TILES-1]; // memory of the current frame

    // memory initialization
    integer i,j;
    initial begin
        for (i=0; i<V_TILES;i=i+1) begin
            for (j=0; j<H_TILES;j=j+1) begin
                bmem[i*H_TILES+j]=7'd00;
            end
        end
    end

    // read for display and write from AXI operation
    integer k;
    always @(posedge clk_i)
    begin
        dout_o <= bmem[row_r_i * H_TILES + col_r_i]; 
        if (wr_en_i) begin
            for(k=0; k<C_AXI_DATA_WIDTH/8; k=k+1) begin
			    if (w_strb_i[k] && (w_addr_i+k < NUM_TILES) ) bmem[w_addr_i+k] <= din_i[k*8+:7]; 
		    end
        end
    end
    
    // read for AXI
    always @(posedge clk_i) begin
        if (r_req_i) begin
            case(r_addr_i)
                12'd2397: r_data_o <= {8'b0, bmem[r_addr_i+2], 1'b0, bmem[r_addr_i+1], 1'b0, bmem[r_addr_i]};
                12'd2398: r_data_o <= {16'b0, bmem[r_addr_i+1], 1'b0, bmem[r_addr_i]};
                12'd2399: r_data_o <= {24'b0, bmem[r_addr_i]};
                default: r_data_o <= {bmem[r_addr_i+3], 1'b0, bmem[r_addr_i+2], 1'b0, bmem[r_addr_i+1], 1'b0, bmem[r_addr_i]};
            endcase
        end
    end

`ifdef FORMAL
    always @(posedge clk_axi_i)
	if (f_past_valid_i && $past(f_reset_i
			&& f_ready_i))
	begin
        case($past(r_addr_i))
            12'd2397: assert(f_rdata_i == $past({8'b0, bmem[r_addr_i+2], 1'b0, bmem[r_addr_i+1], 1'b0, bmem[r_addr_i]}));
            12'd2398: assert(f_rdata_i == $past({16'b0, bmem[r_addr_i+1], 1'b0, bmem[r_addr_i]}));
            12'd2399: assert(f_rdata_i == $past({24'b0, bmem[r_addr_i]}));
            default: assert(f_rdata_i == $past({bmem[r_addr_i+3], 1'b0, bmem[r_addr_i+2], 1'b0, bmem[r_addr_i+1], 1'b0, bmem[r_addr_i]}));
        endcase
	end
`endif
            
endmodule

`default_nettype wire
