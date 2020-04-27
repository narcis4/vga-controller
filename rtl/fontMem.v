`default_nettype none

// Memory map of the representation of the 128 ASCII characters in 8x16 pixels
module fontMem 
#(
`ifdef FORMAL
    parameter FONT_FILE = "../../../rtl/char_bitmap/charmem_8b_data.list",
`else
    parameter FONT_FILE = "/../rtl/char_bitmap/charmem_8b_data.list", // bitmap of the characters sorted by ASCII code
`endif
    parameter ADDR_WIDTH = 11,        // log2(128 characters)
    parameter DATA_WIDTH = 8          // 8x16 pixels per character
)
(
    input wire                  clk_i,  // 25MHz clock
    input wire [ADDR_WIDTH-1:0] addr_i, // address to be accessed, ASCII code of the character needed
    output reg [0:DATA_WIDTH-1] dout_o  // data output, 128 pixels that can be off (0) or on (1)
);

    reg [0:DATA_WIDTH-1] mem [0:(1 << ADDR_WIDTH)-1]; // memory of the characters bitmap

    // memory initialization
    initial begin
        if (FONT_FILE) $readmemb(FONT_FILE, mem);
    end

    // output register controlled by clock
    always @(posedge clk_i) begin
        dout_o <= mem[addr_i];
    end

endmodule

`default_nettype wire
