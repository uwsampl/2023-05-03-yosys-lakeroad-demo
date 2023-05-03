./yosys/yosys -p "
  read_verilog -sv mul.v
  synth_xilinx -top mul
  write_verilog
  stat"
