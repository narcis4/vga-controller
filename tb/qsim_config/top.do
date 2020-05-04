vlib work
vlog +acc "../../rtl/VGAsyncGen.v"
vlog +acc "../../rtl/buffer.v"
vlog +define+WAVE +acc "../../rtl/fontMem.v"
vlog +acc "../../rtl/top.v"
vlog +acc "../tb_top.v"
vsim work.tb_top
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/clk
add wave -noupdate /tb_top/error
add wave -noupdate -radix decimal /tb_top/axil_waddr
add wave -noupdate -radix binary /tb_top/axil_wstrb
add wave -noupdate /tb_top/axil_wdata
add wave -noupdate /tb_top/axil_wready
add wave -noupdate /tb_top/axil_rreq
add wave -noupdate -radix decimal /tb_top/axil_raddr
add wave -noupdate /tb_top/axil_rdata
add wave -noupdate /tb_top/pmod
add wave -noupdate /tb_top/dut_top/vga_inst/activevideo_o
add wave -noupdate -radix decimal /tb_top/dut_top/x_px
add wave -noupdate -radix decimal /tb_top/dut_top/hmem
add wave -noupdate -radix decimal /tb_top/dut_top/hc
add wave -noupdate -radix decimal /tb_top/dut_top/current_col
add wave -noupdate -radix decimal /tb_top/dut_top/x_img
add wave -noupdate -radix decimal /tb_top/dut_top/y_px
add wave -noupdate -radix decimal /tb_top/dut_top/vmem
add wave -noupdate -radix decimal /tb_top/dut_top/vc
add wave -noupdate -radix decimal /tb_top/dut_top/current_row
add wave -noupdate -radix decimal /tb_top/dut_top/y_img
add wave -noupdate /tb_top/dut_top/char
add wave -noupdate -radix decimal /tb_top/dut_top/char_addr
add wave -noupdate /tb_top/dut_top/font_in
add wave -noupdate /tb_top/dut_top/wr_ena
add wave -noupdate /tb_top/dut_top/buf_inst/bmem
add wave -noupdate /tb_top/dut_top/fmem_inst/mem
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
