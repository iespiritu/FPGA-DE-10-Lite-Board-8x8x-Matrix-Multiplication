# FPGA-DE-10-Lite-Board-8x8x-Matrix-Multiplication
Verilog code for long lab project performing 8x8 matrix multiplication for Digital Systems II. 

This project was to test my knowledge of digital logic design and creating finite state machines by coding a digital system that can perform 8x8 matrix multiplication.
I coded an 8x8 8-bit signed integer matrix multiplcator digital circuit in Verilog using Quartus and ModelSim. 

I created a Multiplication Accumulator Circuit and a testbench to test its functionality. 

My project was able to perform using 257 cycles for the base task with no pipelining or parallelism. This makes sense since every entry of the output matrix is calculated
every 8 cycles and the whole system was running synchronously using the positive and negative edges of the clock to update the MAC output and output matrix. 

