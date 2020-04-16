#!/bin/bash

iverilog -o tb_top.x tb_top.v ../rtl/top.v ../rtl/fontMem.v ../rtl/buffer.v ../rtl/uart.v ../rtl/VGAsyncGen.v
if [ -z "$1" ]
then 
    ./tb_top.x
    rm tb_top.x
fi
if [ "$1" == 'w' ]
then
    ./tb_top.x > foo.txt
    rm foo.txt
    rm tb_top.x
    gtkwave tb_top.vcd
    #rm tb_top.vcd
fi

