./yosys/yosys -p "
  read_verilog -sv mul.v
  lakeroad mul out:18 xilinx-ultrascale-plus dsp 3 clk a:18 b:18
  write_verilog
  stat"
