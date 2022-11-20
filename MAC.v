`timescale 1ns/10ps
module MAC(
	input signed [7:0] inA,
	input signed [7:0] inB,
	input clear,
	input clock,
	output reg signed [18:0] outC
	);
	
	always @ (negedge clock) begin
	if (clear == 1'b1)
		outC <= inA*inB;
	else if (clear == 1'b0)
		outC <= inA*inB + outC;
	end
		
endmodule


		