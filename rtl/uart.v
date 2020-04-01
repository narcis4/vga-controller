// Uart receiver
module uart(
	input	wire        clk_i,     // 102.1MHz clock
	input	wire        uart_rx_i, // bit received from the uart
	//input   wire rst,
	output	reg	        wr_o,    // 1 when data_o is valid, 0 otherwise
    output	wire [7:0]	data_o   // data received from the uart
);


    localparam clk_frequency = 102.1e6;
    parameter baudRate = 115200; 
    parameter if_parity = 0; // 0 no parity bit, 1 otherwise
    localparam BAUD_WIDTH = 16;
    localparam DATA_WIDTH = 8;
    localparam [BAUD_WIDTH-1:0] clocksPerBaud = clk_frequency/baudRate;

    //STATES
    localparam [2:0] IDLE   = 3'b000;
    localparam [2:0] START  = 3'b001;
    localparam [2:0] DATA   = 3'b010;
    localparam [2:0] PARITY = 3'b011;
    localparam [2:0] STOP   = 3'b100;



    reg  [2:0]  state = IDLE;    // current transmission state
    reg  [2:0]  next_state;      // next transmission state
    reg  [BAUD_WIDTH-1:0] baudSync = 0;    // counter to know when to move to the next state, every baud cycle
    wire [BAUD_WIDTH-1:0] next_baudSync;   // baudsync for the next clock edge
    reg  [2:0]  dataCounter = 0; // counter to know when the data ends
    reg  [DATA_WIDTH-1:0]  data = 0;        // current data received
    reg  [DATA_WIDTH-1:0]  next_data;       // data for the next clock edge



    // 2FF synchronizer
    reg rx  = 1; 
    reg rx1 = 1;

    always @(posedge clk_i) begin
	    //if (!rst) begin
		    //rx <= 0;
		    //rx1 <= 0;
	    //end
	    //else
		    {rx, rx1} <= {rx1, uart_rx_i};
    end


    // Baud counter, Data counter and states
    assign next_baudSync = (state == IDLE) ? 0 : (baudSync == clocksPerBaud-1) ? 0 : baudSync + 1;

    // Update registers
    always @(posedge clk_i) begin
	    //if (!rst)  begin
		    //baudSync <= 0;
		    //dataCounter <= 0;
		    //state <= IDLE;
		    //data <= 0;
	    //end
	    //else begin
		    state <= next_state;
		    baudSync <= next_baudSync;
		    data <= next_data;
		    if (baudSync == clocksPerBaud-1 && state == DATA) 
			    dataCounter <= dataCounter + 1'b1;
	    //end				
    end



    //State machine control and output
    always @(state or baudSync or dataCounter or rx or data) begin
	    wr_o = 0;
	    next_state = state;
	    next_data = data;
	    case (state)
		    IDLE: begin
			    if (!rx) 
				    next_state = START;
			    end
		    START: begin
			    if (baudSync == clocksPerBaud-1)
				    next_state = DATA;
			    end
		    DATA: begin
			    if (baudSync == clocksPerBaud/2-1)
				    next_data = {rx, data[7:1]};
			    if (dataCounter == 7 && baudSync == clocksPerBaud-1)
				    if (if_parity)
					    next_state = PARITY;
				    else 
					    next_state = STOP;
			    end
		    PARITY: begin
				    next_state = STOP;
			    end
		    STOP: begin
			    wr_o = 1;
			    if (baudSync == clocksPerBaud/2-1)
				    next_state = IDLE;
			    end
	    endcase
    end


    assign data_o = data;

endmodule

