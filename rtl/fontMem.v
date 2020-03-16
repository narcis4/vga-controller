//////////////////////////////////////////////////////////////////////////////////
// Company: Ridotech
// Engineer: Juan Manuel Rico
//
// Create Date: 21:30:38 26/04/2018
// Module Name: fontROM
//
// Description: Font ROM for numbers (16x19 bits for numbers 0 to 9).
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
//
// Additional Comments:
//
//-----------------------------------------------------------------------------
//-- GPL license
//-----------------------------------------------------------------------------
module fontMem 
#(
    parameter FONT_FILE = "charmem.list",
    parameter addr_width = 7,  // 128 characters
    parameter h_pix = 8, // 8x16 pixels characters 
    parameter v_pix = 16
)
(
    input wire                  clk,
    input wire [addr_width-1:0] addr,
    output reg [0:v_pix-1][h_pix-1:0] dout
);

reg [0:v_pix-1] [h_pix-1:0] mem [0:(1 << addr_width)-1]; // memory of the characters bitmap

// memory initialization
initial begin
  if (FONT_FILE) $readmemb(FONT_FILE, mem);
end

always @(posedge clk)
begin
    dout = mem[addr]; // Output register controlled by clock.
end

endmodule

