# Simple_VGA_buffer

Simple VGA buffer to display the first 128 ASCII characters. The screen is divided in 80x30 tiles of 8x16 pixels each for a total resolution of 640x480. Each tile can display a diferent character.

Running on lattice ICE40HX4k FPGA in myStorm BlackIce Mx board with Digilent VGA Pmod adapter.

The VGA adapter has to be connected to MX1 (side to the left of the HDMI port when looking from in front of it). To upload the design, first open a terminal and write the following commands:
```
stty -F /dev/ttyACM0 raw -echo
cat /dev/ttyACM0
```
Then you send the design with:
```
make upload
```
To write characters you have to send the data through UART. First you send the column (0-79), then the row (0-29) and then the ASCII code of the character you want to display (0-127). The next 8 bits sent are ignored due to endlines to facilitate use of UART through terminal. 

