# Simple_VGA_buffer

Simple VGA buffer to display the first 128 ASCII characters. The screen is divided in 80x30 tiles of 8x16 pixels each for a total resolution of 640x480. Each tile can display a diferent character.

Running on lattice ICE40HX4k FPGA with Digilent VGA Pmod adapter.

To write characters you have to send the data through UART. First you send the column (0-79), then the row (0-29) and then the ASCII code of the character you want to display (0-127). The next 8 bits sent are ignored due to endlines to facilitate use of UART through terminal. 
