#ifndef VGA_HEADER_H
#define VGA_HEADER_H

#define IO_BASE (0x80000000)
#define IO_MASK (0x0003ffff)
#define VGA_BASE (0x80030000)
#define MASK4 (0x0000ffff)

#define C_AXI_DATA_WIDTH    32
#define C_AXI_ADDR_WIDTH    15 
#define N_REGS_ROM          2048  
//#define N_CONF_REGS         2048
#define N_CONF_REGS         6
#define REG_SPACE           2048
#define N_REGS_BUFF         600 //2400
#define ADDR_LSB            2
#define OPT_MEM_ADDR_BITS   4
#define MAIN_CONF_REG       (N_REGS)*(C_AXI_DATA_WIDTH/8)

#define W_ONLY_REGS         (N_REGS_ROM + N_REGS_BUFF)
//#define W_ONLY_REGS         0 
#define R_ONLY_REGS         0  
#define RW_REGS             N_CONF_REGS   
//#define RW_REGS             (N_REGS + N_CONF_REGS)
#define TOTAL_REGS          ((R_ONLY_REGS + RW_REGS) + W_ONLY_REGS)           
//More parameters we may use
        //boundaries
#define FIRST_ADDR VGA_BASE
#define N_REGISTERS TOTAL_REGS
#define LAST_ADDR (VGA_BASE + (REG_SPACE+N_REGS_BUFF+N_REGS_ROM-1)*4)
        //ROM addresses
#define BASE_ROM VGA_BASE
#define LAST_ROM (VGA_BASE + (N_REGS_ROM-1)*4)
        //cONF_REGS ADDRESSES
#define BASE_CONF (LAST_ROM + 4)
#define LAST_CONF (BASE_CONF + (N_CONF_REGS-1)*4)
#define MAIN_CONF BASE_CONF
        //Buffer addresses
#define BASE_BUFF (LAST_CONF + 4)
#define LAST_BUFF (BASE_BUFF + (N_REGS_BUFF-1)*4)

/****** end values Specific to each implementation ******/
#include <stdio.h>
#ifdef __UART__
    #include "uart.h"
#endif
#include <stdint.h>
#include <stdlib.h>
uint32_t test_vga(void);
void read_range(uint32_t entry, uint32_t exit,uint32_t aligment);
void search(uint32_t entry, uint32_t exit,uint32_t aligment, uint32_t key);
uint32_t write_ROM(uint32_t addr, uint32_t data);
uint32_t write_buffer(uint32_t addr, uint32_t data);
uint32_t write_reg(uint32_t addr, uint32_t data);
uint32_t test_vga(void);

#endif


