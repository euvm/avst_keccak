DEBUG = NONE

DFLAGS = -relocation-model=pic -w -O3 -lowmem -g

all: avst_keccak.vvp avst_keccak.vpi

clean:
	rm -f avst_keccak.vvp avst_keccak.vpi test_keccak.vcd avst_keccak.o
	cd c-model; make clean

run: avst_keccak.vvp avst_keccak.vpi
	vvp -M. -mavst_keccak avst_keccak.vvp \
	+UVM_TESTNAME=avst_keccak.random_test +UVM_VERBOSITY=DEBUG # +UVM_OBJECTION_TRACE

avst_keccak.vvp: test_avst_keccak.v verilog/*.v
	iverilog -o $@ $^

avst_keccak.vpi: avst_keccak.d c-model/libsha3.a
	ldmd2 $(DFLAGS) -shared -of$@ -L-luvm-ldc-shared -L-lesdl-ldc-shared \
		-L-lphobos2-ldc-shared -L-ldl $^

c-model/libsha3.a:
	cd c-model; make;
