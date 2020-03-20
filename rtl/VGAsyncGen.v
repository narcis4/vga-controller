module VGAsyncGen (
            input wire       clk,           // Input clock: 25MHz
            output wire      hsync,         // Horizontal sync out
            output wire      vsync,         // Vertical sync out
            output reg [9:0] x_px,          // X position for actual pixel
            output reg [9:0] y_px,          // Y position for actual pixel
            output reg [9:0] hc,            // horizontal counter
            output reg [9:0] vc,            // vertical counter
            output wire      activevideo    // 1 if we are in the display zone, 0 otherwise (sync and porches)
         );

    // Video structure constants for 640x480@60Hz
    parameter ACTIVE_H_VIDEO = 640;               // Width of visible pixels.
    parameter ACTIVE_V_VIDEO =  480;              // Height of visible lines.
    parameter HFP = 16;                         // Horizontal front porch length.
    parameter H_PULSE = 96;                      // Hsync pulse length.
    parameter HBP = 48;                         // Horizontal back porch length.
    parameter VFP = 10;                         // Vertical front porch length.
    parameter V_PULSE = 2;                       // Vsync pulse length.
    parameter VBP = 33;                         // Vertical back porch length.
    parameter BLACK_H = HFP + H_PULSE + HBP;      // Hide pixels in one line.
    parameter BLACK_V = VFP + V_PULSE + VBP;      // Hide lines in one frame.
    parameter H_PIXELS = BLACK_H + ACTIVE_H_VIDEO;  // Total horizontal pixels.
    parameter V_LINES = BLACK_V + ACTIVE_V_VIDEO;   // Total lines.

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
        if (hc < H_PIXELS - 1)
            hc <= hc + 1;
        else
        // When we hit the end of the line, reset the horizontal
        // counter and increment the vertical counter.
        // If vertical counter is at the end of the frame, then
        // reset that one too.
        begin
            hc <= 0;
            if (vc < V_LINES - 1)
            vc <= vc + 1;
        else
           vc <= 0;
        end
     end

    // Generate sync pulses (active low) and active video.
    assign hsync = (hc >= HFP && hc < HFP + H_PULSE) ? 0:1;
    assign vsync = (vc >= VFP && vc < VFP + V_PULSE) ? 0:1;
    assign activevideo = (hc >= BLACK_H && vc >= BLACK_V) ? 1:0;

    // Generate color.
    always @(posedge clk)
    begin
        // First check if we are within vertical active video range.
        if (activevideo)
        begin
            x_px <= hc - BLACK_H;
            y_px <= vc - BLACK_V;
        end
        else
        // We are outside active video range so display black.
        begin
            x_px <= 0;
            y_px <= 0;
        end
     end
 endmodule

