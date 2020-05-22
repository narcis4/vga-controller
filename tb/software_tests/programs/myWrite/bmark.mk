myWrite_c_src = \
	myWrite_main.c \
	syscalls.c \
	vga.c \

myWrite_riscv_src = \
	crt.S

myWrite_c_objs			= $(patsubst %.c, %.o, $(myWrite_c_src))
myWrite_riscv_objs = $(patsubst %.S, %.o, $(myWrite_riscv_src))

myWrite_host_bin = myWrite.host 
$(myWrite_host_bin): $(myWrite_c_src)
	$(HOST_COMP) $^ -o $(myWrite_host_bin)

myWrite_riscv_bin = myWrite.riscv 
$(myWrite_riscv_bin): $(myWrite_c_objs) $(myWrite_riscv_objs)
	$(RISCV_LINK) $(myWrite_c_objs) $(myWrite_riscv_objs) -o $(myWrite_riscv_bin) $(RISCV_LINK_OPTS)

junk += $(myWrite_c_objs) $(myWrite_riscv_objs) $(myWrite_host_bin) $(myWrite_riscv_bin)

