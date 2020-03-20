// Top module, instantiates and wires other modules, defines background and character color, adjusts current pixel positions
// and processes data from uart
module top (
    input wire clk,	          // 25MHz clock input
    //input wire RSTN_BUTTON, // rstn,
    input wire rx,            // Tx from the computer
    output wire [15:0] PMOD   // VGA PMOD
  );

//--------------------
//Local parameters
//--------------------
    // V for Video output resolution
    localparam Vwidth=640;
    localparam Vheight=480;
    // C for Character resolution
    localparam Cwidth=8;
    localparam Cheight=16;
    // Number of columns and rows
    localparam Ncol=Vwidth/Cwidth;
    localparam Nrow=Vheight/Cheight; 

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
// IP internal signals
//--------------------
    wire [9:0] x_px;  // current X position of the pixel
    wire [9:0] y_px;  // current Y position of the pixel
    wire [9:0] hc;    // horizontal counter
    wire [9:0] vc;    // vertical counter
    wire activevideo; // 1 if displaying pixels, 0 otherwise

    VGAsyncGen vga_inst( .clk(clk), .hsync(HS), .vsync(VS), .x_px(x_px), .y_px(y_px), .hc(hc), .vc(vc), .activevideo(activevideo));

    wire [7:0] dataRX; // data recieved from uart
    wire WR_RX;        // uart valid data

    uart #(.baudRate(115200), .if_parity(1'b0))
		reciver (
			.clk(clk), 		//Input	
			//.rst(RSTN2), 	    	//Input	
			.uart_rx(rx),		//Input
			.o_wr(WR_RX), 		//Output
			.o_data(dataRX)		//Output
	);

    //Internal registers for current pixel color
    reg [3:0] R_int = 4'b0000;
    reg [3:0] G_int = 4'b0000;
    reg [3:0] B_int = 4'b0000;
    //RGB values assigment from pixel color register
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
        assert Cwidth == 8;
        assert Cheight == 16;
        //if that assertions fail current_col current_row range need to change
        //along other parameters as the lookup and pixel within image
    `endif

    localparam Color0 = 4'b0000; // black background
    localparam Color1 = 4'b1111; // white characters

    wire [6:0] current_col; // column of the current tile
    wire [4:0] current_row; // row of the current tile
    wire [9:0] hmem; // adjusted current x position of the pixel
    wire [9:0] vmem; // adjusted current y position of the pixel
    // register must be loaded 2 cycles before access, so we adjust the addr to be 2 px ahead
    assign hmem = (hc >= 798) ? hc - 160 : (hc >= 158) ? hc + 2 - 160 : 0; // 798 = hpixels - 2, 160 = blackH, 158 = blackH - 2
    // x_px and y_px are 0 when !activevideo, so we need to adjust the vertical pixel to for the first character
    assign vmem = (hc == 158 || hc == 159 || hc == 160) ? vc - 45 : y_px; // 45 = blackV

    assign current_col = hmem[9:3]; 
    assign current_row = vmem[9:4]; 
    //x_img and y_img are used to index within the look up
    wire [2:0] x_img; // indicate X position inside the tile (0-7)
    wire [3:0] y_img; // inidicate Y position inside the tile (0-15)
    assign x_img = x_px[2:0]; 
    assign y_img = y_px[3:0]; 

    reg wr_en;                      // screen buffer write enable
    reg [6:0] col_w;                // column of the tile to write
    reg [4:0] row_w;                // row of the tile to write
    reg [6:0] din;                  // data input, ASCII code
    reg wr_rx1 = 1'b0;              // WR_RX one cycle delayed
    reg [1:0] data_counter = 2'b00; // indicates what will the next data recieved by the uart mean

    // Read data from the uart following the sequence: column -> row -> data -> end line (ignore)
    always @(posedge clk) begin
        wr_en <= 1'b0;
        if (!wr_rx1 && WR_RX) begin // WR_RX rising edge
            case (data_counter)
                2'b00: begin
                    if (dataRX[6:0] >= 80) col_w <= dataRX[6:0] - 80;
                    else col_w <= dataRX[6:0];
                end
                2'b01: row_w <= dataRX[4:0];
                2'b10: begin
                    din <= dataRX[6:0];
                    wr_en <= 1'b1;
                // 2'b11: ignore new line character
                end
            endcase
            data_counter <= data_counter + 1;
        end
        wr_rx1 <= WR_RX;
    end

    wire [6:0] char_addr; // address of the char in the bitmap, ASCII code
    wire [0:Cwidth*Cheight-1] char; // bitmap of 1 character
    
    buffer buf_inst( .clk(clk), .wr_en(wr_en), .col_w(col_w), .row_w(row_w), .col_r(current_col), .row_r(current_row), .din(din), .dout(char_addr));
    fontMem fmem_inst( .clk(clk), .addr(char_addr), .dout(char));

    //Update next pixel color
    //always @(posedge clk, negedge rstn) begin
    always @(posedge clk) begin
        //if (!rstn) begin
                //R_int <= 4'b0;
                //G_int <= 4'b0;
                //B_int <= 4'b0;
        //end else
        
        //remember that there is a section outside the screen
        //if We don't use the active video pixel value will increase in the 
        //section outside the display as well.
        if (activevideo) begin
                R_int <= char[y_img*Cwidth+x_img] ? Color1 : Color0; // paint white if pixel from the bitmap is active, black otherwise
                G_int <= char[y_img*Cwidth+x_img] ? Color1 : Color0; 
                B_int <= char[y_img*Cwidth+x_img] ? Color1 : Color0; 
        end
    end

endmodule
