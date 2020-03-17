/*--------------------------------------------------------------------------------
----                                                                        ----
---- This file is part of the yaVGA project                                 ----
---- http://www.opencores.org/?do=project&who=yavga                         ----
----                                                                        ----
---- Description                                                            ----
---- Implementation of yaVGA IP core                                        ----
----                                                                        ----
---- To Do:                                                                 ----
----                                                                        ----
----                                                                        ----
---- Author(s):                                                             ----
---- Sandro Amato, sdroamt@netscape.net                                     ----
----                                                                        ----
--------------------------------------------------------------------------------
----                                                                        ----
---- Copyright (c) 2009, Sandro Amato                                       ----
---- All rights reserved.                                                   ----
----                                                                        ----
---- Redistribution  and  use in  source  and binary forms, with or without ----
---- modification,  are  permitted  provided that  the following conditions ----
---- are met:                                                               ----
----                                                                        ----
----     * Redistributions  of  source  code  must  retain the above        ----
----       copyright   notice,  this  list  of  conditions  and  the        ----
----       following disclaimer.                                            ----
----     * Redistributions  in  binary form must reproduce the above        ----
----       copyright   notice,  this  list  of  conditions  and  the        ----
----       following  disclaimer in  the documentation and/or  other        ----
----       materials provided with the distribution.                        ----
----     * Neither  the  name  of  SANDRO AMATO nor the names of its        ----
----       contributors may be used to  endorse or  promote products        ----
----       derived from this software without specific prior written        ----
----       permission.                                                      ----
----                                                                        ----
---- THIS SOFTWARE IS PROVIDED  BY THE COPYRIGHT  HOLDERS AND  CONTRIBUTORS ----
---- "AS IS"  AND  ANY EXPRESS OR  IMPLIED  WARRANTIES, INCLUDING,  BUT NOT ----
---- LIMITED  TO, THE  IMPLIED  WARRANTIES  OF MERCHANTABILITY  AND FITNESS ----
---- FOR  A PARTICULAR  PURPOSE  ARE  DISCLAIMED. IN  NO  EVENT  SHALL  THE ----
---- COPYRIGHT  OWNER  OR CONTRIBUTORS  BE LIABLE FOR ANY DIRECT, INDIRECT, ----
---- INCIDENTAL,  SPECIAL,  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, ----
---- BUT  NOT LIMITED  TO,  PROCUREMENT OF  SUBSTITUTE  GOODS  OR SERVICES; ----
---- LOSS  OF  USE,  DATA,  OR PROFITS;  OR  BUSINESS INTERRUPTION) HOWEVER ----
---- CAUSED  AND  ON  ANY THEORY  OF LIABILITY, WHETHER IN CONTRACT, STRICT ----
---- LIABILITY,  OR  TORT  (INCLUDING  NEGLIGENCE  OR OTHERWISE) ARISING IN ----
---- ANY  WAY OUT  OF THE  USE  OF  THIS  SOFTWARE,  EVEN IF ADVISED OF THE ----
---- POSSIBILITY OF SUCH DAMAGE.                                            ----
--------------------------------------------------------------------------------*/
module buffer 
#(
    parameter h_tiles = 640/8,  // 640x480 resolution and chars of 8x16 pixels
    parameter v_tiles = 480/16,
    parameter num_tiles = h_tiles*v_tiles, // 2400
    parameter addr_width = 12,  // log2(640/8 * 480/16)
    parameter data_width = 7 // 128 possible characters
)
(
    input wire                  clk,
    input wire                  wr_en, // write enable
    input wire [addr_width-6:0] col_w, // column of tile to write
    input wire [addr_width-8:0] row_w, // row of tile to write
    input wire [addr_width-6:0] col_r, // column of tile to read
    input wire [addr_width-8:0] row_r, // row of tile to read
    input wire [data_width-1:0] din,   // data to write
    output reg [data_width-1:0] dout   // data read
);

reg [data_width-1:0] bmem [0:num_tiles-1]; // memory of the current frame

// memory initialization
integer i,j;
initial begin
    for (i=0; i<v_tiles;i=i+1) begin
        for (j=0; j<h_tiles;j=j+1) begin
            if (i == j) begin
                case (i)
                    0: bmem[i*h_tiles+j]=7'd48; // ASCII code, 0 to 9 in the diagonal test
                    1: bmem[i*h_tiles+j]=7'd49;
                    2: bmem[i*h_tiles+j]=7'd50;
                    3: bmem[i*h_tiles+j]=7'd51;
                    4: bmem[i*h_tiles+j]=7'd52;
                    5: bmem[i*h_tiles+j]=7'd53;
                    6: bmem[i*h_tiles+j]=7'd54;
                    7: bmem[i*h_tiles+j]=7'd55;
                    8: bmem[i*h_tiles+j]=7'd56;
                    9: bmem[i*h_tiles+j]=7'd57;
                endcase
            end
            else bmem[i*h_tiles+j]=7'd00;
        end
    end
end

always @(posedge clk)
begin
    dout <= bmem[row_r * h_tiles + col_r]; // Output register controlled by clock.
    if (wr_en) begin
        bmem[row_w * h_tiles + col_w] <= din; // Write to tile
    end
end

endmodule
