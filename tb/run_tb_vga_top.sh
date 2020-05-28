#!/bin/bash

if [ -z "$1" ]
then 
    iverilog -DSIM -o tb_vga_top.x tb_vga_top.v ../rtl/vga_top.v ../rtl/vga_fontMem.v ../rtl/vga_buffer.v ../rtl/vga_syncGen.v
    ./tb_vga_top.x
    rm tb_vga_top.x
    rm tb_vga_top.vcd
fi
if [ "$1" == 'w' ]
then
    mkdir -p qsim_vga_top
    cd qsim_vga_top
    vsim -do ../qsim_config/vga_top.do
fi

