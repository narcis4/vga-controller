vlib work
vlog +acc "../../rtl/vga_syncGen.v"
vlog +acc "../../rtl/vga_buffer.v"
vlog +define+WAVE +acc "../../rtl/vga_fontMem.v"
vlog +acc "../../rtl/vga_top.v"
vlog +acc "../tb_vga_top.v"
vsim work.tb_vga_top
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_vga_top/clk
add wave -noupdate /tb_vga_top/error
add wave -noupdate -radix decimal /tb_vga_top/axil_waddr
add wave -noupdate -radix binary /tb_vga_top/axil_wstrb
add wave -noupdate /tb_vga_top/axil_wdata
add wave -noupdate /tb_vga_top/axil_wready
add wave -noupdate /tb_vga_top/axil_rreq
add wave -noupdate -radix decimal /tb_vga_top/axil_raddr
add wave -noupdate /tb_vga_top/axil_rdata
add wave -noupdate /tb_vga_top/pmod
add wave -noupdate /tb_vga_top/dut_vga_top/vga_syncGen_inst/activevideo_o
add wave -noupdate -radix decimal /tb_vga_top/dut_vga_top/x_px
add wave -noupdate -radix decimal /tb_vga_top/dut_vga_top/hmem
add wave -noupdate -radix decimal /tb_vga_top/dut_vga_top/hc
add wave -noupdate -radix decimal /tb_vga_top/dut_vga_top/current_col
add wave -noupdate -radix decimal /tb_vga_top/dut_vga_top/x_img
add wave -noupdate -radix decimal /tb_vga_top/dut_vga_top/y_px
add wave -noupdate -radix decimal /tb_vga_top/dut_vga_top/vmem
add wave -noupdate -radix decimal /tb_vga_top/dut_vga_top/vc
add wave -noupdate -radix decimal /tb_vga_top/dut_vga_top/current_row
add wave -noupdate -radix decimal /tb_vga_top/dut_vga_top/y_img
add wave -noupdate /tb_vga_top/dut_vga_top/char
add wave -noupdate -radix decimal /tb_vga_top/dut_vga_top/char_addr
add wave -noupdate /tb_vga_top/dut_vga_top/font_in
add wave -noupdate /tb_vga_top/dut_vga_top/wr_ena
add wave -noupdate /tb_vga_top/dut_vga_top/vga_buffer_inst/bmem
add wave -noupdate /tb_vga_top/dut_vga_top/vga_fontMem_inst/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1 us}
run -all
