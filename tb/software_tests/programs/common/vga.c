#include <vga.h>

void read_range(uint32_t entry, uint32_t exit,uint32_t aligment){
    volatile uint32_t *var;
    volatile uint32_t reader;
     #ifdef __UART__
    printf("\n *** Memory dump***\n\n");
    #endif
    for(uint32_t i=entry;i<exit+4;i=i+aligment){
        var=(uint32_t*)(i);
        reader=*var;
        #ifdef __UART__
        printf("addres:%x \n",i);
        printf("value :%d \n",reader);
        #endif
    }
    #ifdef __UART__
    printf("\n *** END DUMP ***\n\n");
    #endif
}

void search(uint32_t entry, uint32_t exit,uint32_t aligment, uint32_t key){
    volatile uint32_t *var;
    volatile uint32_t reader;
    #ifdef __UART__
    printf("\n *** Memory dump***\n\n");
    #endif
    for(uint32_t i=entry;i<exit+4;i=i+aligment){
        var=(uint32_t*)(i);
        reader=*var;
        if (reader==key){
            #ifdef __UART__
            printf("addres:%x \n",i);
            printf("value :%d \n",reader);
            #endif
            i=exit;
        }
    }
    #ifdef __UART__
    printf("\n *** END DUMP ***\n\n");
    #endif
}

uint32_t write_ROM(uint32_t addr, uint32_t data) {
    volatile uint32_t *var;
    var=(uint32_t*)(BASE_ROM+addr);
    *var = data;
    return *var;
}

uint32_t write_buffer(uint32_t addr, uint32_t data) {
    volatile uint32_t *var;
    var=(uint32_t*)(BASE_BUFF+addr);
    *var = data;
    return *var;
}

uint32_t write_reg(uint32_t addr, uint32_t data) {
    volatile uint32_t *var;
    var=(uint32_t*)(BASE_CONF+addr);
    *var = data;
    return *var;
}

uint32_t test_vga(void){
    
    uint32_t addr_ROM = 0x00000000;
    uint32_t data_ROM = 0xFF773311;
    // Write all the bitmap memory addressess (only the 8 least significant bits of the data are written)
    for (unsigned int i=BASE_ROM; i<=LAST_ROM; i=i+4) {
        write_ROM(addr_ROM, data_ROM);
        addr_ROM = addr_ROM + 4;
        data_ROM = (data_ROM >> 1) | (data_ROM << 31); // shift 1 bit right wrap around
    }

    uint32_t addr_buff = 0x00000000;
    uint32_t data_buff = 0xFF765432;
    // Write all the buffer memory addressess
    for (int i=BASE_BUFF; i<=LAST_BUFF; i=i+4) {
        write_buffer(addr_buff, data_buff);
        addr_buff = addr_buff + 4;
        data_buff = (data_buff >> 8) | (data_buff << 24); // shift 8 bit right wrap around
    }

    uint32_t addr_reg = 0x00000000;
    uint32_t data_reg = 0xFFFF0000;
    // Write the color registers (only the 4 least significant bits of the data are written)
    for (int i=BASE_CONF; i<=LAST_CONF; i=i+4) {
        write_reg(addr_reg, data_reg);
        addr_reg = addr_reg + 4;
        data_reg = (data_reg << 4) | (data_reg >> 28); // shift 4 bit left wrap around
    }
    
    // Read all the VGA addressess (only the color registers can be read)
    read_range(VGA_BASE, LAST_ADDR, 4);
    return(0);
}

uint32_t test_vga2(void){
    
    // 'B' in position 66
    uint32_t addr_ROM = 0x00001080;
    uint32_t data_ROM = 0x00000000;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x000000FC;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000082;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000084;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x000000F8;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000084;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000082;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x000000FC;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000000;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    //'A' in position 65
    addr_ROM = 0x00001040;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000010;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000028;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000044;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x0000007C;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000044;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000082;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000000;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    //'C' in position 67
    addr_ROM = 0x000010C0;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x0000007C;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000082;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000080;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000082;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x0000007C;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000000;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    // 'D' in position 68
    addr_ROM = 0x00001100;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x000000F0;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000088;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000084;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000082;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000084;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x000000F8;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000000;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    //'S' in position 83
    addr_ROM = 0x000014C0;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x0000007C;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000082;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000080;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x0000007C;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000002;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000082;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x0000007C;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000000;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    //'R' in position 82
    addr_ROM = 0x00001480;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x0000007C;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000082;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x000000FC;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x000000A0;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000090;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000088;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000084;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000082;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    data_ROM = 0x00000000;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);
    addr_ROM = addr_ROM + 4;
    write_ROM(addr_ROM, data_ROM);

    //write DRAC in the first tiles and BSC in the last
    uint32_t addr_buff = 0x00000000;
    uint32_t data_buff = 0x43415244;
    write_buffer(addr_buff, data_buff);
    addr_buff = LAST_BUFF;
    data_buff = 0x43534200;
    write_buffer(addr_buff, data_buff);

    //change background color to blue
    uint32_t addr_reg = 0x00000008;
    uint32_t data_reg = 0x0000000F;
    write_reg(addr_reg, data_reg);
    
    // Read all the VGA addressess (only the color registers can be read)
    read_range(VGA_BASE, LAST_ADDR, 4);
    return(0);
}
    
    
    
    
