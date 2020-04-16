#!/bin/bash

iverilog -o tb_uart.x tb_uart.v ../rtl/uart.v
if [ -z "$1" ]
then 
    ./tb_uart.x
    rm tb_uart.x
fi
if [ "$1" == 'w' ]
then
    ./tb_uart.x > foo.txt
    rm foo.txt
    rm tb_uart.x
    gtkwave tb_uart.vcd signals_config/signals_uart.gtkw
    #rm tb_uart.vcd
fi

