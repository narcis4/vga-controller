#!/bin/bash

if [ -z "$1" ]
then 
    iverilog -DTBSIM -o tb_vga_fontMem.x tb_vga_fontMem.v ../rtl/vga_fontMem.v
    ./tb_vga_fontMem.x
    rm tb_vga_fontMem.x
    rm tb_vga_fontMem.vcd
fi
if [ "$1" == 'w' ]
then
    mkdir -p qsim_vga_fontMem
    cd qsim_vga_fontMem
    vsim -do ../qsim_config/vga_fontMem.do
fi

