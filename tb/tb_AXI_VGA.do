vsim -vopt work.tb_AXI_VGA -voptargs=+acc
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_ACLK
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_ARESETN
add wave -noupdate /tb_AXI_VGA/error
add wave -noupdate /tb_AXI_VGA/write_end
add wave -noupdate /tb_AXI_VGA/write_timeout
add wave -noupdate /tb_AXI_VGA/read_end
add wave -noupdate /tb_AXI_VGA/read_timeout
add wave -noupdate /tb_AXI_VGA/read_data
add wave -noupdate /tb_AXI_VGA/read_data2
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_AWVALID
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_AWREADY
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_AWADDR
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_WVALID
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_WREADY
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_WDATA
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_WSTRB
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_BVALID
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_BREADY
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_ARVALID
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_ARREADY
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_ARADDR
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_RVALID
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_RREADY
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/S_AXI_RDATA
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/axil_read_req
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/top_inst/buf_inst/clk_i
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/top_inst/buf_inst/wr_en_i
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/top_inst/buf_inst/bmem
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/top_inst/buf_inst/bmem
add wave -noupdate /tb_AXI_VGA/dut_AXI_VGA/top_inst/buf_inst/k
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {22 ns} 0}
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
WaveRestoreZoom {0 ns} {210 ns}
run 300
