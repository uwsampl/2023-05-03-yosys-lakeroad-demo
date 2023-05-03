# Yosys + Lakeroad Demo

This repository contains a demonstration of how Lakeroad can be integrated into Yosys, to extend Yosys's existing capabilities.

The `yosys/` directory contains a fork of Yosys into which we've built a command named `lakeroad`. This command runs a pass which compiles modules using Lakeroad, which is also added as a submodule to Yosys (see `yosys/lakeroad/`).

To set up the demo, you can build and run the Docker container:

```sh
git clone --recursive <this-repo>
cd <this-repo>
docker build -t yosys-lakeroad-demo . 
docker run -it yosys-lakeroad-demo /bin/bash
```

The rest of this document will assume we're running inside the Docker container.

This demonstration compiles a simple three-stage pipelined multiplier [`mul.v`](./mul.v) to three FPGA architectures (Xilinx, Lattice, Intel) using existing Yosys passes and Yosys+Lakeroad.

Let's begin with compilation to Lattice. Run the following script:

```sh
./mul-lattice-yosys.sh
```

This script uses the built-in `synth_ecp5` pass to compile the design for Lattice. The output shows the following:

```
...

4. Printing statistics.

=== mul ===

   Number of wires:                  9
   Number of wire bits:            163
   Number of public wires:           9
   Number of public wire bits:     163
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                 55
     MULT18X18D                      1
     TRELLIS_FF                     54
```

Now, if we compile using the `lakeroad` pass:

```sh
./mul-lattice-yosys-lakeroad.sh
```

We see the following output:

```
...

4. Printing statistics.

=== mul ===

   Number of wires:                131
   Number of wire bits:            182
   Number of public wires:         131
   Number of public wire bits:     182
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                  1
     MULT18X18D                      1
```

As we can see, both Yosys and Yosys+Lakeroad understand how to put the multiplier onto Lattice's special-purpose `MULT18X18D` unit.

Now, let's move on to Xilinx. When we compile with Yosys using the built-in `synth_xilinx` pass:

```sh
./mul-xilinx-yosys.sh
```

We get the following output:

```
...

4. Printing statistics.

=== mul ===

   Number of wires:                 17
   Number of wire bits:            338
   Number of public wires:           7
   Number of public wire bits:     109
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                 77
     BUFG                            1
     DSP48E1                         2
     FDRE                            2
     IBUF                           37
     OBUF                           18
     SRL16E                         17
```

But when we compile with Lakeroad, we get:

```
...

4. Printing statistics.

=== mul ===

   Number of wires:                  5
   Number of wire bits:            103
   Number of public wires:           5
   Number of public wire bits:     103
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                  1
     DSP48E2                         1
```

This is interesting! The `lakeroad` pass is better able to utilize the Xilinx `DSP48E2` when compared with Yosys's existing `synth_xilinx` pass.

In this final example, we will show how Lakeroad can add support for Intel DSPs to Yosys. Yosys currently supports Intel only experimentally, and does not support compiling to its DSPs. So when we compile our `mul` module using `synth_intel`:

```sh
./mul-intel-yosys.sh
```

We get:

```
...

4. Printing statistics.

=== mul ===

   Number of wires:                214
   Number of wire bits:            913
   Number of public wires:           6
   Number of public wire bits:      91
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                463
     dffeas                         54
     fiftyfivenm_lcell_comb        409
```

But with Lakeroad, we get:

```
...

4. Printing statistics.

=== mul ===

   Number of wires:                  5
   Number of wire bits:             91
   Number of public wires:           5
   Number of public wire bits:      91
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                  1
     altmult_accum                   1
```

That is, once Lakeroad is integrated into Yosys, Yosys is able to compile the multiplier onto a specialized unit!