vlib work
vlog +acc "../../rtl/vga_syncGen.v"
vlog +define+TBSIM +acc "../../rtl/vga_buffer.v"
vlog +define+WAVE +acc "../../rtl/vga_fontMem.v"
vlog +define+TBSIM +acc "../../rtl/vga_top.v"
vlog +acc "../../rtl/axi_vga.v"
vlog +acc "../tb_axi_vga.v"
vsim work.tb_axi_vga
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_axi_vga/s_axi_aclk
add wave -noupdate /tb_axi_vga/s_axi_aresetn
add wave -noupdate /tb_axi_vga/error
add wave -noupdate /tb_axi_vga/write_end
add wave -noupdate /tb_axi_vga/read_end
add wave -noupdate -radix hexadecimal /tb_axi_vga/read_data
add wave -noupdate -radix hexadecimal /tb_axi_vga/read_data2
add wave -noupdate /tb_axi_vga/s_axi_awvalid
add wave -noupdate /tb_axi_vga/s_axi_awready
add wave -noupdate -radix unsigned /tb_axi_vga/s_axi_awaddr
add wave -noupdate /tb_axi_vga/s_axi_wvalid
add wave -noupdate /tb_axi_vga/s_axi_wready
add wave -noupdate -radix binary /tb_axi_vga/s_axi_wstrb
add wave -noupdate /tb_axi_vga/s_axi_wdata
add wave -noupdate /tb_axi_vga/s_axi_bvalid
add wave -noupdate /tb_axi_vga/s_axi_bready
add wave -noupdate /tb_axi_vga/s_axi_arvalid
add wave -noupdate /tb_axi_vga/s_axi_arready
add wave -noupdate -radix unsigned /tb_axi_vga/s_axi_araddr
add wave -noupdate /tb_axi_vga/s_axi_rvalid
add wave -noupdate /tb_axi_vga/s_axi_rready
add wave -noupdate /tb_axi_vga/s_axi_rdata
add wave -noupdate /tb_axi_vga/dut_axi_vga/axil_read_req
add wave -noupdate /tb_axi_vga/vga_o
add wave -noupdate /tb_axi_vga/dut_axi_vga/vga_top_inst/wr_ena
add wave -noupdate -radix binary /tb_axi_vga/dut_axi_vga/vga_top_inst/vga_buffer_inst/bmem
add wave -noupdate /tb_axi_vga/dut_axi_vga/vga_top_inst/wr_en_rom
add wave -noupdate /tb_axi_vga/dut_axi_vga/vga_top_inst/vga_fontMem_inst/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1078 ns} 0}
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
