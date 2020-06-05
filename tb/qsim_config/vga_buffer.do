vlib work
vlog +define+TBSIM +acc "../../rtl/vga_buffer.v"
vlog +define+TBSIM +acc "../tb_vga_buffer.v"
vsim work.tb_vga_buffer
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_vga_buffer/clk
add wave -noupdate /tb_vga_buffer/error
add wave -noupdate /tb_vga_buffer/error2
add wave -noupdate /tb_vga_buffer/error3
add wave -noupdate /tb_vga_buffer/ini_read_done
add wave -noupdate /tb_vga_buffer/write_done
add wave -noupdate /tb_vga_buffer/finish
add wave -noupdate -radix unsigned /tb_vga_buffer/vr_addr
add wave -noupdate -radix binary /tb_vga_buffer/dout
add wave -noupdate /tb_vga_buffer/wr_en
add wave -noupdate -radix unsigned /tb_vga_buffer/w_addr_i
add wave -noupdate -radix binary /tb_vga_buffer/w_strb_i
add wave -noupdate -radix binary /tb_vga_buffer/din
add wave -noupdate -radix binary /tb_vga_buffer/dut_vga_buffer/bmem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11 ns} 0}
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

