#define IO_BASE (0x80000000)
#define IO_MASK (0x00030fff)
#define VGA_BASE (0x80030000)
#define MASK4 (0x00000fff)

#define C_AXI_DATA_WIDTH    32
#define C_AXI_ADDR_WIDTH    12 
#define N_REGS              2400
#define N_CONF_REGS         0
#define ADDR_LSB            0
#define OPT_MEM_ADDR_BITS   4
#define MAIN_CONF_REG       (N_REGS)*(C_AXI_DATA_WIDTH/8) 

//#define W_ONLY_REGS       N_REGS
#define W_ONLY_REGS         0
#define R_ONLY_REGS         0  
//#define RW_REGS           N_CONF_REGS   
#define RW_REGS             (N_REGS + N_CONF_REGS)
#define TOTAL_REGS          ((R_ONLY_REGS + RW_REGS) + W_ONLY_REGS)           
//More parameters we may use
        //boundaries
#define LAST_ADDR (VGA_BASE+(TOTAL_REGS-1))
        //Counters addresses
#define BASE_REG VGA_BASE
#define LAST_REG (VGA_BASE + (N_REGS-1))
        //cONF_REGS ADDRESSES
#define BASE_CONF LAST_REG + 1
#define LAST_CONF (BASE_CONF + (N_CONF_REGS-1))

/****** end values Specific to each implementation ******/
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#endif


