#!/bin/bash

iverilog -o tb_buffer.x tb_buffer.v ../rtl/buffer.v
if [ -z "$1" ]
then 
    ./tb_buffer.x
    rm tb_buffer.x
fi
if [ "$1" == 'w' ]
then
    ./tb_buffer.x > foo.txt
    rm foo.txt
    rm tb_buffer.x
    gtkwave tb_buffer.vcd
    #rm tb_buffer.vcd
fi



