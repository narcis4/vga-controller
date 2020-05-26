#include "vga.h"

#include <stdio.h>

#ifdef __UART__
#include "uart.h"
#endif

#include <stdint.h>
#include <stdlib.h>


uint32_t bench_vga(void){
#ifdef __UART__
    printf("\n ***bench_vga***\n\n");
#endif
    int a=0, b =0;
    for(int i = 0 ; i< 0xfffff; i++){
        a=i-b;
        if(i%3){
            b++;
            read_range(VGA_BASE,LAST_ADDR,4);
        }
    }
    read_range(VGA_BASE,LAST_ADDR,4);
    return(0);
}

void main(void){
#ifdef __UART__
    uart_init();
#endif
   test_vga();
}

