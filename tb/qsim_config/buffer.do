vlib work
vlog +acc "../../rtl/buffer.v"
vlog +acc "../tb_buffer.v"
vsim work.tb_buffer
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_buffer/clk
add wave -noupdate /tb_buffer/error
add wave -noupdate /tb_buffer/error2
add wave -noupdate /tb_buffer/error3
add wave -noupdate /tb_buffer/ini_read_done
add wave -noupdate /tb_buffer/write_done
add wave -noupdate /tb_buffer/finish
add wave -noupdate -radix decimal /tb_buffer/col_r
add wave -noupdate -radix decimal /tb_buffer/row_r
add wave -noupdate -radix decimal /tb_buffer/dout
add wave -noupdate /tb_buffer/wr_en
add wave -noupdate -radix decimal /tb_buffer/w_addr_i
add wave -noupdate -radix binary /tb_buffer/w_strb_i
add wave -noupdate /tb_buffer/din
add wave -noupdate /tb_buffer/dut_buffer/bmem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
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
run -all

