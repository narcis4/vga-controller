// Screen buffer divided in 80x30 tiles, each containing the 7 bit address of a character
module buffer 
#(
    parameter H_TILES = 640/8,             // 640x480 resolution and chars of 8x16 pixels
    parameter V_TILES = 480/16,
    parameter NUM_TILES = H_TILES*V_TILES, // 80x30 = 2400
    parameter ADDR_COL_WIDTH = 7,          // log2(80)
    parameter ADDR_ROW_WIDTH = 5,          // log2(30)
    parameter DATA_WIDTH = 7,               // log2(128 possible characters)
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_AXI_ADDR_WIDTH = $clog2(NUM_TILES/C_S_AXI_DATA_WIDTH),
    localparam	ADDRLSB = $clog2(C_AXI_DATA_WIDTH)-3
)
(
    input wire                  clk_i,       // 25 MHz clock
    input wire                  wr_en_i,     // write enable for the data input
    input wire [C_AXI_ADDR_WIDTH-ADDRLSB-1:0] w_addr_i,
    input wire [C_AXI_DATA_WIDTH/8-1:0] w_strb_i,
    input wire [C_AXI_ADDR_WIDTH-ADDRLSB-1:0] r_addr_i,
    input wire                  r_req_i,
    input wire [ADDR_COL_WIDTH-1:0] col_r_i, // column of tile to read
    input wire [ADDR_ROW_WIDTH-1:0] row_r_i, // row of tile to read
    input wire [C_AXI_DATA_WIDTH-1:0] din_i,       // data input, the ASCII code of the character
    output reg [DATA_WIDTH-1:0] dout_o,       // data output
    output reg [C_AXI_DATA_WIDTH-1:0] r_data_o
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

    // read and write operation
    always @(posedge clk_i)
    begin
        dout_o <= bmem[row_r_i * H_TILES + col_r_i]; 
        if (wr_en_i) begin
            integer k;
            for(k=0; k<C_S_AXI_DATA_WIDTH/8; k=k+1) begin
			    if (w_strb_i[k]) bmem[w_addr_i+k] <= din_i[k*8+:7]; //bit order?
		    end
        end
    end

    always @(posedge clk_i) begin
        if (r_req_i) r_data_o <= {bmem[r_addr_i], bmem[r_addr_i+1], bmem[r_addr_i+2], bmem[r_addr_i+3]};
            

endmodule
