/* -----------------------------------------------
 * Project Name   : DRAC
 * File           : vga_fontMem.v
 * Organization   : Barcelona Supercomputing Center
 * Author         : Narcis Rodas
 * Email(s)       : narcis.rodaquiroga@bsc.es
 */

`default_nettype none

// Memory map of the representation of the 128 ASCII characters in 8x16 pixels
module vga_fontMem 
#(
`ifdef FORMAL
    parameter FONT_FILE = "../../../includes/char_bitmap/charmem_8b_data.list",
`elsif WAVE
    parameter FONT_FILE = "../../includes/char_bitmap/charmem_8b_data.list",
`elsif VERILATOR
    parameter FONT_FILE = "../soc/submodules/asic_top/submodules/processor/submodules/tile/submodules/vga/includes/char_bitmap/charmem_8b_data.list",
`else
    parameter FONT_FILE = "../includes/char_bitmap/charmem_8b_data.list", // bitmap of the characters sorted by ASCII code
`endif
    parameter ADDR_WIDTH = 11, // log2(128 characters x 16 rows each)
    parameter DATA_WIDTH = 8   // 8 bits per row
)
(
    input wire                  clk_i,    // 25MHz clock
    input wire [ADDR_WIDTH-1:0] addr_i,   // address to be accessed, ASCII code of the character needed
    output reg [0:DATA_WIDTH-1] dout_o,   // data output, 8 pixels that can be background (0) or character (1)
    input wire [ADDR_WIDTH-1:0] addr_w_i, // write address
    input wire                  wr_en_i,  // write enable
    input wire [0:DATA_WIDTH-1] din_i     // data to write
);

    reg [0:DATA_WIDTH-1] mem [0:(1 << ADDR_WIDTH)-1]; // single port memory of the characters bitmap

`ifdef WAVE
    // memory initialization
    initial begin
        if (FONT_FILE) $readmemb(FONT_FILE, mem);
    end
`elsif SIM
    initial begin
        if (FONT_FILE) $readmemb(FONT_FILE, mem);
    end
`endif

    // write and read operations, if both happen in the same cycle, no data is read and the output is 0 (background)
    always @(posedge clk_i) begin
        if (wr_en_i) begin 
            mem[addr_w_i] <= din_i;
            dout_o <= 8'd0;
        end
        else
            dout_o <= mem[addr_i];
    end

endmodule

`default_nettype wire
