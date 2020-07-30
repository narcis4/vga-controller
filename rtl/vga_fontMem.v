/* -----------------------------------------------
 * Project Name   : DRAC
 * File           : vga_fontMem.v
 * Organization   : Barcelona Supercomputing Center
 * Author         : Narcis Rodas
 * Email(s)       : narcis.rodaquiroga@bsc.es
 */

`default_nettype none

// Memory of the 128 bitmap patterns of the characters in 8x16 pixels
module vga_fontMem 
#(
`ifdef FORMAL
    parameter FONT_FILE = "../../../includes/char_bitmap/charmem_8b_data.list", // bitmap of the characters sorted by ASCII code
`elsif WAVE
    parameter FONT_FILE = "../../includes/char_bitmap/charmem_8b_data.list",
`elsif VERILATOR
    parameter FONT_FILE = "../soc/submodules/asic_top/submodules/processor/submodules/tile/submodules/vga/includes/char_bitmap/charmem_8b_data.list",
`elsif TBSIM
    parameter FONT_FILE = "../includes/char_bitmap/charmem_8b_data.list", 
`elsif TBSIM2
    parameter FONT_FILE = "../includes/char_bitmap/charmem_8b_data.list",
`endif
    parameter ADDR_WIDTH = 11, // log2(128 characters x 16 rows each)
    parameter DATA_WIDTH = 8   // 8 bits per row
)
(
    input wire                  clk_i,    // 25MHz clock
    input wire [ADDR_WIDTH-1:0] addr_i,   // address to be accessed
    output reg [0:DATA_WIDTH-1] dout_o,   // data output, 8 pixels that can be background (0) or character (1)
    input wire [ADDR_WIDTH-1:0] addr_w_i, // write address
    input wire                  wr_en_i,  // write enable
    input wire [0:DATA_WIDTH-1] din_i,    // data to write
    input wire [ADDR_WIDTH-1:0] addr_r_i, // read address
    input wire                  r_req_i,  // read enable
    output reg [0:DATA_WIDTH-1] r_data_o  // data read
);

    reg [0:DATA_WIDTH-1] mem [0:(1 << ADDR_WIDTH)-1]; // single port memory of the characters bitmap

`ifdef WAVE
    // memory initialization for simulation
    initial begin
        if (FONT_FILE) $readmemb(FONT_FILE, mem);
    end
`elsif TBSIM
    initial begin
        if (FONT_FILE) $readmemb(FONT_FILE, mem);
    end
`elsif TBSIM2
    initial begin
        if (FONT_FILE) $readmemb(FONT_FILE, mem);
    end
`endif

    // write read for AXI and read for display operations, if there is an AXI operation, no display data is read and the output is 0 (background)
    always @(posedge clk_i) begin
        if (wr_en_i) begin 
            mem[addr_w_i] <= din_i;
            dout_o <= 8'd0;
        end
        else if (r_req_i) begin
            r_data_o <= mem[addr_r_i];
            dout_o <= 8'd0;
        end
        else
            dout_o <= mem[addr_i];
    end

endmodule

`default_nettype wire
