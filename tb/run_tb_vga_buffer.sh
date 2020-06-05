#!/bin/bash

if [ -z "$1" ]
then 
    iverilog -DTBSIM -o tb_vga_buffer.x tb_vga_buffer.v ../rtl/vga_buffer.v
    ./tb_vga_buffer.x
    rm tb_vga_buffer.x
    rm tb_vga_buffer.vcd
fi
if [ "$1" == 'w' ]
then
    mkdir -p qsim_vga_buffer
    cd qsim_vga_buffer
    vsim -do ../qsim_config/vga_buffer.do
fi



