#!/bin/bash

mcy init
mcy run -j$(nproc)

if [ "$1" == 'g' ]
then 
    mcy gui
fi
if [ "$1" == 'd' ]
then
    mcy dash
fi
if [ "$1" == 'p' ]
then
    mcy purge
fi
