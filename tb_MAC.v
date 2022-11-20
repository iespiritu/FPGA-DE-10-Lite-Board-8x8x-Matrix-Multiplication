module tb_MAC;
	wire [7:0] inputA;
	wire [7:0] inputB;
	wire inputclear;
	wire inputclock;
	wire [18:0] outputC;
	
	MAC test_MAC (
	.inA		(inputA),
	.inB		(inputB),
	.clear	(inputclear),
	.clock	(inputclock),
	.outC		(outputC)
	);
	
	reg [7:0] testinputA;
	reg [7:0] testinputB;
	reg testinputclear;
	reg testinputclock;
	
	
	assign inputA = testinputA;
	assign inputB = testinputB;
	assign inputclear = testinputclear;
	assign inputclock = testinputclock;
	
	
	initial begin
	testinputA = 8'd4;
	testinputB = 8'd3;
	testinputclear = 1'b1;
	testinputclock = 1'b0;

	
	$display ("Testing updated with A = 4 and B = 3");
	#100;
	testinputclock = ~testinputclock;
	$display ("A = %d,  B = %d, Clear = %b, Clock = %d, C = %d", 
					inputA, inputB, inputclear, inputclock, outputC);
	#100;
	testinputclock = ~testinputclock;
	$display ("A = %d,  B = %d, Clear = %b, Clock = %d, C = %d", 
					inputA, inputB, inputclear, inputclock, outputC);
	#100;
	testinputclock = ~testinputclock;
	$display ("A = %d,  B = %d, Clear = %b, Clock = %d, C = %d", 
					inputA, inputB, inputclear, inputclock, outputC);
	#100;
	testinputclock = ~testinputclock;
	$display ("A = %d,  B = %d, Clear = %b, Clock = %d, C = %d", 
					inputA, inputB, inputclear, inputclock, outputC);
	testinputclear = 1'b0;
	testinputclock = 1'b0;
	
	#100;
	testinputclock = ~testinputclock;
	$display ("A = %d,  B = %d, Clear = %b, Clock = %d, C = %d", 
					inputA, inputB, inputclear, inputclock, outputC);
	#100;
	testinputclock = ~testinputclock;
	$display ("A = %d,  B = %d, Clear = %b, Clock = %d, C = %d", 
					inputA, inputB, inputclear, inputclock, outputC);
	#100;
	testinputclock = ~testinputclock;
	$display ("A = %d,  B = %d, Clear = %b, Clock = %d, C = %d", 
					inputA, inputB, inputclear, inputclock, outputC);
	#100;
	testinputclock = ~testinputclock;
	$display ("A = %d,  B = %d, Clear = %b, Clock = %d, C = %d", 
					inputA, inputB, inputclear, inputclock, outputC);
	#100;
	testinputclock = ~testinputclock;
	$display ("A = %d,  B = %d, Clear = %b, Clock = %d, C = %d", 
					inputA, inputB, inputclear, inputclock, outputC);
	end
	
	
endmodule
	