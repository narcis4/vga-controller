`timescale 1us/10ns

module uart_tb;

    reg clk;
    reg rx;
    wire wr;
    wire [7:0] data;
    reg error;
    
    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);
        #10000 $finish;
    end
    
    // this test sends data to print 2 characters, a '2' in column 17 row 29, and a '9' in column 79 row 0
    initial begin
        clk = 1'b0;
        error = 1'b0;
        // send column 17
        rx = 1'b0;         // start bit
        #8.68 rx = 1'b1;   // data bits
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;   // stop bit
        wait (wr);
        if (data != 8'd17) begin
            $display("Error sending column 17, result: %d", data);
            error = 1'b1;
        end
        // send row 29
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        wait (wr);
        if (data != 8'd29) begin
            $display("Error sending row 29, result: %d", data);
            error = 1'b1;
        end
        // send ASCII 50 (character '2')
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        wait (wr);
        if (data != 8'd50) begin
            $display("Error sending ASCII 50 (character '2'), result: %d", data);
            error = 1'b1;
        end
        // send column 79
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        wait (wr);
        if (data != 8'd79) begin
            $display("Error sending column 79, result: %d", data);
            error = 1'b1;
        end
        // send row 0
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        wait (wr);
        if (data != 8'd0) begin
            $display("Error sending row 0, result: %d", data);
            error = 1'b1;
        end
        // send ASCII 57 (character '9')
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        wait (wr);
        if (data != 8'd57) begin
            $display("Error sending ASCII 57 (character '9'), result: %d", data);
            error = 1'b1;
        end
        if (error == 1'b0) $display("PASS");
    end
        
    uart dut_uart( .clk_i(clk), .uart_rx_i(rx), .wr_o(wr), .data_o(data));

    /* Make a regular pulsing clock. */
    always #0.02 clk = !clk;

endmodule // test
