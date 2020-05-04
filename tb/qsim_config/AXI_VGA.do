vlib work
vlog +acc "../../rtl/VGAsyncGen.v"
vlog +acc "../../rtl/buffer.v"
vlog +define+WAVE +acc "../../rtl/fontMem.v"
vlog +acc "../../rtl/top.v"
vlog +acc "../../rtl/AXI_VGA.v"
vlog +acc "../tb_AXI_VGA.v"
vsim work.tb_AXI_VGA
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_AXI_VGA/s_axi_aclk
add wave -noupdate /tb_AXI_VGA/s_axi_aresetn
add wave -noupdate /tb_AXI_VGA/error
add wave -noupdate /tb_AXI_VGA/write_end
add wave -noupdate /tb_AXI_VGA/read_end
add wave -noupdate -radix hexadecimal /tb_AXI_VGA/read_data
add wave -noupdate -radix hexadecimal /tb_AXI_VGA/read_data2
add wave -noupdate /tb_AXI_VGA/s_axi_awvalid
add wave -noupdate /tb_AXI_VGA/s_axi_awready
add wave -noupdate -radix decimal /tb_AXI_VGA/s_axi_awaddr
add wave -noupdate /tb_AXI_VGA/s_axi_wvalid
add wave -noupdate /tb_AXI_VGA/s_axi_wready
add wave -noupdate -radix binary /tb_AXI_VGA/s_axi_wstrb
add wave -noupdate /tb_AXI_VGA/s_axi_wdata
add wave -noupdate /tb_AXI_VGA/s_axi_bvalid
add wave -noupdate /tb_AXI_VGA/s_axi_bready
add wave -noupdate /tb_AXI_VGA/s_axi_arvalid
add wave -noupdate /tb_AXI_VGA/s_axi_arready
add wave -noupdate -radix decimal /tb_AXI_VGA/s_axi_araddr
add wave -noupdate /tb_AXI_VGA/s_axi_rvalid
add wave -noupdate /tb_AXI_VGA/s_axi_rready
add wave -noupdate /tb_AXI_VGA/s_axi_rdata
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/axil_read_req
add wave -noupdate /tb_AXI_VGA/vga_o
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/top_inst/wr_ena
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/top_inst/buf_inst/bmem
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/top_inst/fmem_inst/mem
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
