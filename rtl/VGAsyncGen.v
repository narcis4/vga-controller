// Generation of the VGA sync signals, the position of the current pixel and the horizontal and vertical counters of the screen
module VGAsyncGen (
            input wire       clk_i,           // Input clock: 102.1MHz
            output wire      hsync_o,         // Horizontal sync out
            output wire      vsync_o,         // Vertical sync out
            output reg [10:0] x_px_o,          // X position for actual pixel
            output reg [10:0] y_px_o,          // Y position for actual pixel
            output reg [10:0] hc_o,            // horizontal counter
            output reg [10:0] vc_o,            // vertical counter
            output wire      activevideo_o    // 1 if we are in the display zone, 0 otherwise (sync and porches)
         );

    // Video structure constants for 1280x960@60Hz
    parameter ACTIVE_H_VIDEO = 1280;               // Width of visible pixels.
    parameter ACTIVE_V_VIDEO =  960;              // Height of visible lines.
    parameter HFP = 80;                         // Horizontal front porch length.
    parameter H_PULSE = 136;                      // Hsync pulse length.
    parameter HBP = 216;                         // Horizontal back porch length.
    parameter VFP = 1;                         // Vertical front porch length.
    parameter V_PULSE = 3;                       // Vsync pulse length.
    parameter VBP = 30;                         // Vertical back porch length.
    parameter BLACK_H = HFP + H_PULSE + HBP;      // Hide pixels in one line.
    parameter BLACK_V = VFP + V_PULSE + VBP;      // Hide lines in one frame.
    parameter H_PIXELS = BLACK_H + ACTIVE_H_VIDEO;  // Total horizontal pixels.
    parameter V_LINES = BLACK_V + ACTIVE_V_VIDEO;   // Total lines.

    // Initial values.
    initial
    begin
      x_px_o <= 0;
      y_px_o <= 0;
      hc_o <= 0;
      vc_o <= 0;
    end

    // Update counters
    always @(posedge clk_i)
    begin
        // Keep counting until the end of the line.
        if (hc_o < H_PIXELS - 1)
            hc_o <= hc_o + 1;
        else
        // When we hit the end of the line, reset the horizontal
        // counter and increment the vertical counter.
        // If vertical counter is at the end of the frame, then
        // reset that one too.
        begin
            hc_o <= 0;
            if (vc_o < V_LINES - 1)
            vc_o <= vc_o + 1;
        else
           vc_o <= 0;
        end
     end

    // Generate sync pulses (active low) and active video.
    assign hsync_o = (hc_o >= HFP && hc_o < HFP + H_PULSE) ? 0:1;
    assign vsync_o = (vc_o >= VFP && vc_o < VFP + V_PULSE) ? 0:1;
    assign activevideo_o = (hc_o >= BLACK_H -1 && vc_o >= BLACK_V) ? 1:0; // we generate activevideo 1 pixel before horizontally due to register delay (see top.v)

    // Track current pixel position
    always @(posedge clk_i)
    begin
        // First check if we are within vertical active video range.
        if (activevideo_o)
        begin
            x_px_o <= hc_o - BLACK_H;
            y_px_o <= vc_o - BLACK_V;
        end
        else
        // We are outside active video range so display black.
        begin
            x_px_o <= 0;
            y_px_o <= 0;
        end
     end
 endmodule

