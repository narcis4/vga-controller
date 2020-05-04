#!/bin/bash

if [ -z "$1" ]
then 
    iverilog -o tb_fontMem.x tb_fontMem.v ../rtl/fontMem.v
    ./tb_fontMem.x
    rm tb_fontMem.x
    rm tb_fontMem.vcd
fi
if [ "$1" == 'w' ]
then
    mkdir -p qsim_fontMem
    cd qsim_fontMem
    vsim -do ../qsim_config/fontMem.do
fi

