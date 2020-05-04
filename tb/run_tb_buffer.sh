#!/bin/bash

if [ -z "$1" ]
then 
    iverilog -o tb_buffer.x tb_buffer.v ../rtl/buffer.v
    ./tb_buffer.x
    rm tb_buffer.x
    rm tb_buffer.vcd
fi
if [ "$1" == 'w' ]
then
    mkdir -p qsim_buffer
    cd qsim_buffer
    vsim -do ../qsim_config/buffer.do
fi



