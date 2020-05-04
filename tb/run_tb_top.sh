#!/bin/bash

if [ -z "$1" ]
then 
    iverilog -o tb_top.x tb_top.v ../rtl/top.v ../rtl/fontMem.v ../rtl/buffer.v ../rtl/VGAsyncGen.v
    ./tb_top.x
    rm tb_top.x
    rm tb_top.vcd
fi
if [ "$1" == 'w' ]
then
    mkdir -p qsim_top
    cd qsim_top
    vsim -do ../qsim_config/top.do
fi

