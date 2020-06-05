#!/bin/bash

if [ -z "$1" ]
then 
    iverilog -DTBSIM -o tb_axi_vga.x tb_axi_vga.v ../rtl/axi_vga.v ../rtl/vga_top.v ../rtl/vga_fontMem.v ../rtl/vga_buffer.v ../rtl/vga_syncGen.v
    ./tb_axi_vga.x
    rm tb_axi_vga.x
    #rm tb_axi_vga.vcd
fi
if [ "$1" == 'w' ]
then
    mkdir -p qsim_axi_vga
    cd qsim_axi_vga
    vsim -do ../qsim_config/axi_vga.do
elif [ "$1" == 'f' ]
then
    sby -f axi_vga.sby
fi

