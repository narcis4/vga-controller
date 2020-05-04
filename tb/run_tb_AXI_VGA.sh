#!/bin/bash

if [ -z "$1" ]
then 
    iverilog -o tb_AXI_VGA.x tb_AXI_VGA.v ../rtl/AXI_VGA.v ../rtl/top.v ../rtl/fontMem.v ../rtl/buffer.v ../rtl/VGAsyncGen.v
    ./tb_AXI_VGA.x
    rm tb_AXI_VGA.x
    rm tb_AXI_VGA.vcd
fi
if [ "$1" == 'w' ]
then
    mkdir -p qsim_AXI_VGA
    cd qsim_AXI_VGA
    vsim -do ../qsim_config/AXI_VGA.do
elif [ "$1" == 'f' ]
then
    sby -f AXI_VGA.sby
fi

