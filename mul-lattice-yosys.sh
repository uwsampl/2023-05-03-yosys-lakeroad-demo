./yosys/yosys -p "
  read_verilog -sv mul.v
  synth_ecp5 -top mul
  write_verilog
  stat"
