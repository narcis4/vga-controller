`timescale 1us/10ns

module top_tb;

    reg clk;
    reg rx;
    wire [15:0] pmod;
    reg error;

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        #50000 $finish;
    end

    // this test sends a character 'A' to write and then checks that the corresponding pixels are white
    initial begin
        clk = 1'b0;
        error = 1'b0;
        // send column 0
        rx = 1'b0;         // start bit
        #8.68 rx = 1'b0;   // data bits
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;   // stop bit
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
        // send ASCII 65 (character 'A')
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        #8.68 rx = 1'b0;
        #8.68 rx = 1'b1;
        // wait for the start of the next frame and then the first white pixel
        #10000 wait(pmod[7:0] == 8'hFF);
        // next pixel of the character 'A' is at next line -1, so (800 horizontal cycles -1)*0.04 clk = 31.96, add 0.01 to have time to change output
        #31.97 if (pmod[7:0] != 8'hFF) begin
            $display("Error 1");
            error = 1'b1;
        end
        // next pixel is 2 away
        #0.08 if (pmod[7:0] != 8'hFF) begin
            $display("Error 2");
            error = 1'b1;
        end
        #31.92 if (pmod[7:0] != 8'hFF) begin
            $display("Error 3");
            error = 1'b1;
        end
        #0.08 if (pmod[7:0] != 8'hFF) begin
            $display("Error 4");
            error = 1'b1;
        end
        #31.92 if (pmod[7:0] != 8'hFF) begin
            $display("Error 5");
            error = 1'b1;
        end
        #0.08 if (pmod[7:0] != 8'hFF) begin
            $display("Error 6");
            error = 1'b1;
        end
        #31.88 if (pmod[7:0] != 8'hFF) begin
            $display("Error 7");
            error = 1'b1;
        end
        #0.16 if (pmod[7:0] != 8'hFF) begin
            $display("Error 8");
            error = 1'b1;
        end
        #31.84 if (pmod[7:0] != 8'hFF) begin
            $display("Error 9");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("Error 10");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("Error 11");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("Error 12");
            error = 1'b1;
        end
        #0.04 if (pmod[7:0] != 8'hFF) begin
            $display("Error 13");
            error = 1'b1;
        end
        #31.84 if (pmod[7:0] != 8'hFF) begin
            $display("Error 14");
            error = 1'b1;
        end
        #0.16 if (pmod[7:0] != 8'hFF) begin
            $display("Error 15");
            error = 1'b1;
        end
        #31.84 if (pmod[7:0] != 8'hFF) begin
            $display("Error 16");
            error = 1'b1;
        end
        #0.16 if (pmod[7:0] != 8'hFF) begin
            $display("Error 17");
            error = 1'b1;
        end
        #31.80 if (pmod[7:0] != 8'hFF) begin
            $display("Error 18");
            error = 1'b1;
        end
        #0.24 if (pmod[7:0] != 8'hFF) begin
            $display("Error 19");
            error = 1'b1;
        end
        #31.76 if (pmod[7:0] != 8'hFF) begin
            $display("Error 20");
            error = 1'b1;
        end
        #0.24 if (pmod[7:0] != 8'hFF) begin
            $display("Error 21");
            error = 1'b1;
        end
        #31.76 if (pmod[7:0] != 8'hFF) begin
            $display("Error 22");
            error = 1'b1;
        end
        #0.24 if (pmod[7:0] != 8'hFF) begin
            $display("Error 23");
            error = 1'b1;
        end
        if (error == 1'b0) $display("PASS");
    end
        
    top dut_top( .clk_i(clk), .rx_i(rx), .PMOD(pmod));

    /* Make a regular pulsing clock. */
    always #0.02 clk = !clk;

endmodule // test
