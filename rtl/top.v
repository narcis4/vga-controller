// Top module, instantiates and wires other modules, defines background and character color, adjusts current pixel positions
// and processes data from uart
module top (
    input wire clk_i,	          // 25MHz clock input
    //input wire RSTN_BUTTON, // rstn,
    input wire rx_i,            // Tx from the computer
    output wire [15:0] PMOD   // VGA PMOD
  );

//--------------------
//Local parameters
//--------------------
    // V for Video output resolution
    localparam V_WIDTH=1280;
    localparam V_HEIGHT=1024;
    // C for Character resolution
    localparam C_WIDTH=8;
    localparam C_HEIGHT=16;
    // Number of columns and rows
    localparam N_COL=V_WIDTH/C_WIDTH;
    localparam N_ROW=V_HEIGHT/C_HEIGHT;
    
    localparam N_COUNTER_WIDTH = 11;
    localparam N_PIXEL_WIDTH = 11;
    localparam UART_DATA_WIDTH = 8;
    localparam COLOR_WIDTH = 4;
    localparam COLOR_0 = 4'b0000; // black background
    localparam COLOR_1 = 4'b1111; // white characters
    localparam N_ROW_WIDTH = 6;
    localparam N_COL_WIDTH = 8;
    localparam N_CHARS_WIDTH = 7;
    localparam H_PIXELS = 1712;
    localparam V_PIXELS = 994;
    localparam H_BLACK = H_PIXELS - V_WIDTH;
    localparam V_BLACK = V_PIXELS - V_HEIGHT;
    localparam C_ADDR_WIDTH = 3;
    localparam C_ADDR_HEIGHT = 4;

//--------------------
//IO pins assigments
//--------------------
    //Names of the signals on digilent VGA PMOD adapter
    wire R0, R1, R2, R3; // red
    wire G0, G1, G2, G3; // green
    wire B0, B1, B2, B3; // blue
    wire HS,VS; // horizontal and vertical sync
    //wire rstn;
    //pmod1
    assign PMOD[0] = B0;
    assign PMOD[1] = B1;
    assign PMOD[2] = B2;
    assign PMOD[3] = B3;
    assign PMOD[4] = R0;
    assign PMOD[5] = R1;
    assign PMOD[6] = R2;
    assign PMOD[7] = R3;
    //pmod2
    assign PMOD[8] = HS;
    assign PMOD[9] = VS;
    assign PMOD[10] = 0;
    assign PMOD[11] = 0;
    assign PMOD[12] = G0;
    assign PMOD[13] = G1;
    assign PMOD[14] = G2;
    assign PMOD[15] = G3;
    //sync reset from button and enable pull up
    /*wire rstn_button_int; //internal signal after pullups
    reg bf1_rstn;
    reg bf2_rstn;
    always @(posedge px_clk) begin
        bf1_rstn <= rstn_button_int;
        bf2_rstn <= bf1_rstn;
    end
    assign  rstn = bf2_rstn;*/

//--------------------
// PLL
//--------------------

    wire clk108;
    SB_PLL40_CORE #(
		.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0001),		// DIVR =  1
		.DIVF(7'b1000100),	// DIVF = 68
		.DIVQ(3'b011),		// DIVQ =  3
		.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
	) uut (
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.REFERENCECLK(clk_i),
		.PLLOUTCORE(clk108)
		);


    wire [N_PIXEL_WIDTH-1:0] x_px;  // current X position of the pixel
    wire [N_PIXEL_WIDTH-1:0] y_px;  // current Y position of the pixel
    wire [N_COUNTER_WIDTH-1:0] hc;    // horizontal counter
    wire [N_COUNTER_WIDTH-1:0] vc;    // vertical counter
    wire activevideo; // 1 if displaying pixels, 0 otherwise

    VGAsyncGen vga_inst( .clk_i(clk108), .hsync_o(HS), .vsync_o(VS), .x_px_o(x_px), .y_px_o(y_px), .hc_o(hc), .vc_o(vc), .activevideo_o(activevideo));

    wire [UART_DATA_WIDTH-1:0] dataRX; // data received from uart
    wire WR_RX;        // uart valid data

    uart #(.baudRate(115200), .if_parity(1'b0))
		uart_inst (
			.clk_i(clk108), 		
			//.rst(RSTN2), 	    	
			.uart_rx_i(rx_i),		
			.wr_o(WR_RX), 	
			.data_o(dataRX)		
	);

    //Internal registers for current pixel color
    reg [COLOR_WIDTH-1:0] R_int = 4'b0000;
    reg [COLOR_WIDTH-1:0] G_int = 4'b0000;
    reg [COLOR_WIDTH-1:0] B_int = 4'b0000;
    //RGB values assigment from pixel color register or black if we are not in display zone
    assign R0 = activevideo ? R_int[0] :0; 
    assign R1 = activevideo ? R_int[1] :0; 
    assign R2 = activevideo ? R_int[2] :0; 
    assign R3 = activevideo ? R_int[3] :0; 
    assign G0 = activevideo ? G_int[0] :0; 
    assign G1 = activevideo ? G_int[1] :0; 
    assign G2 = activevideo ? G_int[2] :0; 
    assign G3 = activevideo ? G_int[3] :0; 
    assign B0 = activevideo ? B_int[0] :0; 
    assign B1 = activevideo ? B_int[1] :0; 
    assign B2 = activevideo ? B_int[2] :0; 
    assign B3 = activevideo ? B_int[3] :0; 
    
    //Track current column and row
    `ifdef ASSERTIONS
        assert C_WIDTH == 8;
        assert C_HEIGHT == 16;
        //if that assertions fail current_col current_row range need to change
        //along other parameters as the lookup and pixel within image
    `endif

    wire [N_COL_WIDTH-1:0] current_col; // column of the current tile
    wire [N_ROW_WIDTH-1:0] current_row; // row of the current tile
    wire [N_PIXEL_WIDTH-1:0] hmem; // adjusted current x position of the pixel
    wire [N_PIXEL_WIDTH-1:0] vmem; // adjusted current y position of the pixel
    // register must be loaded 2 cycles before access, so we adjust the addr to be 2 px ahead
    assign hmem = (hc >= H_PIXELS-1) ? hc - H_BLACK : (hc >= H_BLACK-2) ? hc + 2 - H_BLACK : 0; // 798 = hpixels - 2, 160 = blackH, 158 = blackH - 2
    // x_px and y_px are 0 when !activevideo, so we need to adjust the vertical pixel too for the first character
    assign vmem = (hc == H_BLACK-2 || hc == H_BLACK-1 || hc == H_BLACK) ? vc - V_BLACK : y_px; // 45 = blackV

    assign current_col = hmem[N_PIXEL_WIDTH-1:C_ADDR_WIDTH]; 
    assign current_row = vmem[N_PIXEL_WIDTH-1:C_ADDR_HEIGHT]; 
    //x_img and y_img are used to index within the look up
    wire [C_ADDR_WIDTH-1:0] x_img; // indicate X position inside the tile (0-7)
    wire [C_ADDR_HEIGHT-1:0] y_img; // inidicate Y position inside the tile (0-15)
    assign x_img = x_px[C_ADDR_WIDTH-1:0] + 1; // similar as hmem, we need to load the pixel 1 cycle earlier, so we adjust the fetch to be 1 ahead
    assign y_img = y_px[C_ADDR_HEIGHT-1:0]; 

    reg wr_en;                      // screen buffer write enable
    reg [N_COL_WIDTH-1:0] col_w;    // column of the tile to write
    reg [N_ROW_WIDTH-1:0] row_w;    // row of the tile to write
    reg [N_CHARS_WIDTH-1:0] din;    // data input, ASCII code
    reg wr_rx1 = 1'b0;              // WR_RX one cycle delayed
    reg [1:0] data_counter = 2'b00; // indicates what will the next data received by the uart mean

    // Read data from the uart following the sequence: column -> row -> data -> end line (ignore)
    always @(posedge clk108) begin
        wr_en <= 1'b0;
        if (!wr_rx1 && WR_RX) begin // WR_RX rising edge
            case (data_counter)
                2'b00: begin
                    if (dataRX[N_COL_WIDTH-1:0] >= N_COL) col_w <= dataRX[N_COL_WIDTH-1:0] - N_COL;
                    else col_w <= dataRX[N_COL_WIDTH-1:0];
                end
                2'b01: row_w <= dataRX[N_ROW_WIDTH-1:0];
                2'b10: begin
                    din <= dataRX[N_CHARS_WIDTH-1:0];
                    wr_en <= 1'b1;
                // 2'b11: ignore new line character
                end
            endcase
            data_counter <= data_counter + 1;
        end
        wr_rx1 <= WR_RX;
    end

    wire [N_CHARS_WIDTH-1:0] char_addr; // address of the char in the bitmap, ASCII code
    wire [0:C_WIDTH*C_HEIGHT-1] char; // bitmap of 1 character
    
    buffer buf_inst( .clk_i(clk108), .wr_en_i(wr_en), .col_w_i(col_w), .row_w_i(row_w), .col_r_i(current_col), .row_r_i(current_row), .din_i(din), .dout_o(char_addr));
    fontMem fmem_inst( .clk_i(clk108), .addr_i(char_addr), .dout_o(char));

    //Update next pixel color
    //always @(posedge clk108, negedge rstn) begin
    always @(posedge clk108) begin
        //if (!rstn) begin
                //R_int <= 4'b0;
                //G_int <= 4'b0;
                //B_int <= 4'b0;
        //end else
        
        //remember that there is a section outside the screen
        //if We don't use the active video pixel value will increase in the 
        //section outside the display as well.
        if (activevideo) begin
                R_int <= char[y_img*C_WIDTH+x_img] ? COLOR_1 : COLOR_0; // paint white if pixel from the bitmap is active, black otherwise
                G_int <= char[y_img*C_WIDTH+x_img] ? COLOR_1 : COLOR_0; 
                B_int <= char[y_img*C_WIDTH+x_img] ? COLOR_1 : COLOR_0; 
        end
    end

endmodule
