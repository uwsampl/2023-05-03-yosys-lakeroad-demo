./yosys/yosys -p "
  read_verilog -sv mul.v
  synth_intel -top mul
  write_verilog
  stat"
