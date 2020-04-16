#!/bin/bash

iverilog -o tb_fontMem.x tb_fontMem.v ../rtl/fontMem.v
if [ -z "$1" ]
then 
    ./tb_fontMem.x
    rm tb_fontMem.x
fi
if [ "$1" == 'w' ]
then
    ./tb_fontMem.x > foo.txt
    rm foo.txt
    rm tb_fontMem.x
    gtkwave tb_fontMem.vcd signals_config/signals_fontMem.gtkw
    #rm tb_fontMem.vcd
fi

