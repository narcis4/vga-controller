//////////////////////////////////////////////////////////////////////////////////
// Company: Ridotech
// Engineer: Juan Manuel Rico
// 
// Create Date:    09:34:23 30/09/2017 
// Module Name:    vga_controller
// Description:    Basic control for 640x480@72Hz VGA signal.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created for Roland Coeurjoly (RCoeurjoly) in 640x480@85Hz.
// Revision 0.02 - Change for 640x480@60Hz.
// Revision 0.03 - Solved some mistakes.
// Revision 0.04 - Change for 640x480@72Hz and output signals 'activevideo'
//                 and 'px_clk'.
//
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

//`define __ICARUS__ 0

module VGAsyncGen (
            input wire       clk,           // Input clock: 25MHz
            output wire      hsync,         // Horizontal sync out
            output wire      vsync,         // Vertical sync out
            output reg [9:0] x_px,          // X position for actual pixel.
            output reg [9:0] y_px,          // Y position for actual pixel.
            output reg [9:0] hc,            // horizontal counter
            output reg [9:0] vc,            // vertical counter
            output wire      activevideo
         );

    // Video structure constants for 640x480@60Hz
    parameter activeHvideo = 640;               // Width of visible pixels.
    parameter activeVvideo =  480;              // Height of visible lines.
    parameter hfp = 16;                         // Horizontal front porch length.
    parameter hpulse = 96;                      // Hsync pulse length.
    parameter hbp = 48;                         // Horizontal back porch length.
    parameter vfp = 10;                          // Vertical front porch length.
    parameter vpulse = 2;                       // Vsync pulse length.
    parameter vbp = 33;                         // Vertical back porch length.
    parameter blackH = hfp + hpulse + hbp;      // Hide pixels in one line.
    parameter blackV = vfp + vpulse + vbp;      // Hide lines in one frame.
    parameter hpixels = blackH + activeHvideo;  // Total horizontal pixels.
    parameter vlines = blackV + activeVvideo;   // Total lines.

    // Registers for storing the horizontal & vertical counters.
    //reg [9:0] hc;
    //reg [9:0] vc;

    // Initial values.
    initial
    begin
      x_px <= 0;
      y_px <= 0;
      hc <= 0;
      vc <= 0;
    end

    // Counting pixels.
    always @(posedge clk)
    begin
        // Keep counting until the end of the line.
        if (hc < hpixels - 1)
            hc <= hc + 1;
        else
        // When we hit the end of the line, reset the horizontal
        // counter and increment the vertical counter.
        // If vertical counter is at the end of the frame, then
        // reset that one too.
        begin
            hc <= 0;
            if (vc < vlines - 1)
            vc <= vc + 1;
        else
           vc <= 0;
        end
     end

    // Generate sync pulses (active low) and active video.
    assign hsync = (hc >= hfp && hc < hfp + hpulse) ? 0:1;
    assign vsync = (vc >= vfp && vc < vfp + vpulse) ? 0:1;
    assign activevideo = (hc >= blackH && vc >= blackV) ? 1:0;

    // Generate color.
    always @(posedge clk)
    begin
        // First check if we are within vertical active video range.
        if (activevideo)
        begin
            x_px <= hc - blackH;
            y_px <= vc - blackV;
        end
        else
        // We are outside active video range so display black.
        begin
            x_px <= 0;
            y_px <= 0;
        end
     end
 endmodule

