This repository is checked in as an example to illustrate a UVM testbench for keccak sha3 implementation downloaded from Opencores [Keccak SHA3 implementation] (https://opencores.org/projects/sha3)

The DUT has been slightly modified with a reduced AVST streaming interface wrapper.

The testbench is implemented in [Embedded UVM](http://uvm.io).

## Required Software
1. Icarus Verilog version 10.2 or newer
2. Emabedded UVM downloadable from http://uvm.io/download

To run the simulation just go to the checked-out directory and type `make run` on a bash prompt.
