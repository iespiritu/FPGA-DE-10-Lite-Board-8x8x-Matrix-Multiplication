`timescale 1ns/10ps
module Task3(
	input clk, start, reset,
	output reg done,
	output reg[10:0] clock_count
);
	
	//Determining states
	parameter stationary = 3'd0;
	parameter calculate = 3'd1;
	parameter finish = 3'd2;
	
	reg [2:0] state = stationary;
	
	reg signed [7:0] matrixA [63:0];
	reg signed [7:0] matrixB [63:0];
	
	initial begin
		$readmemb("ram_a_init.txt",matrixA);
		$readmemb("ram_b_init.txt",matrixB);
	end
	
	wire signed [7:0] calcA_even, calcA_odd, calcB;
	reg unsigned [5:0] addressA_even, addressA_odd, addressB;
	wire signed [18:0] outputMAC_even, outputMAC_odd, inputRAM;
	reg signed [18:0] outputBuffer_even, outputBuffer_odd, outputBuffer;
	
	reg clear; //toggles MAC operation
	reg enable; //toggles writing to memory operation
	reg [5:0] address, address_adj;
	
	assign calcA_even = matrixA [addressA_even];
	assign calcA_odd = matrixA [addressA_odd];
	assign calcB = matrixB [addressB];
	assign inputRAM = outputBuffer;
	
	RAM RAMOUTPUT(.datain (inputRAM),.clk	(clk),.write_enable(enable), .address (address_adj));
	
	MAC instMAC1(.inA (calcA_even),.inB	(calcB),.clear (clear),.clock (clk),.outC (outputMAC_even));
	MAC instMAC2(.inA (calcA_odd),.inB (calcB),.clear (clear),.clock	(clk),.outC (outputMAC_odd));
	
	always @ (posedge clk) begin 
		if (clock_count  > 6 && clock_count % 8 == 11'd7) begin //Save output
			outputBuffer_even <= outputMAC_even;
			outputBuffer_odd <= outputMAC_odd;
		end
	end
	
	always @ (posedge clk) begin
		if (clock_count > 6 && clock_count % 8 == 11'd0)
			enable <= 1'b1;
		else if (clock_count > 6 && clock_count % 8 == 11'd3)
			enable <= 1'b0;
	end
	
	always @ (negedge clk) begin
		if (clock_count > 6 && clock_count % 8 == 11'd0) begin
			address_adj <= 2 * (address - 6'd1); //first case 0
			outputBuffer <= outputBuffer_even; 
		end
		else if (clock_count > 6 && clock_count % 8 == 11'd2) begin
			address_adj <= 2 * (address - 6'd1) + 6'd1; //first case 1
			outputBuffer <= outputBuffer_odd;
		end
	end
	
	//Changing states
	always @ (posedge clk) begin
		case (state)
			stationary: begin
				clock_count <= 11'd0;
				if (start == 1'b1) begin
					state <= calculate;
				end
			end
			
			calculate:	begin
				clock_count <= clock_count + 11'd1;
				if (reset == 1'b1)
					state <= stationary;
				else if (clock_count == 11'd257)
					state <= finish;
			end
			
			finish:			begin
				if (reset == 1'b1) 
					state <= stationary;
				else
					done <= 1'b1;
			end
		endcase
	end
		
	//What each state does
	always @ (posedge clk) begin
		case (state)
			stationary: begin //Default parameters
				if (start == 1'b1) begin
					addressA_even <= 11'd0;
					addressA_odd <= 11'd1;
					addressB <= 11'd0;
					address <= 6'd0;
				end
			end
	
			calculate: begin
				if (clock_count > 6 && clock_count % 256 == 11'd255) begin //Finished
					address <= address + 6'd1;
				end
				else if (clock_count  > 6 && clock_count % 32 == 11'd31) begin //Calculated last entry in one column of C, need to move next column
					addressA_even <= addressA_even - 6'd62;
					addressA_odd <= addressA_odd - 6'd62;
					addressB <= addressB + 6'd1;
					address <= address + 6'd1;
				end
				else if (clock_count  > 6 && clock_count % 8 == 11'd7) begin //Calculated a row entry in C, need to shift down
					addressA_even <= addressA_even - 6'd54;
					addressA_odd <= addressA_odd - 6'd54;
					addressB <= addressB - 6'd7;
					address <= address + 6'd1;
				end
				else begin //Calculated A*B+C, need to still accumulate
					addressA_even <= addressA_even + 6'd8;
					addressA_odd <= addressA_odd + 6'd8;
					addressB <= addressB + 6'd1;
				end
			end
		endcase
	end
	
	always @ (negedge clk) begin
		case (state)
			stationary: begin //Default parameters
					if (start == 1'b1) begin
						clear <= 1'b1;
					end
			end
			
			calculate: begin
				if (clock_count > 6 && clock_count % 256 == 11'd255) begin //Finished
					//enable <= 1'b1;
				end
				else if (clock_count  > 6 && clock_count % 32 == 11'd31) begin //Calculated last entry in one column of C, need to move next column
					//enable <= 1'b1;
					clear <= 1'b1;
				end
				else if (clock_count  > 6 && clock_count % 8 == 11'd7) begin //Calculated a row entry in C, need to shift down
					//enable <= 1'b1;
					clear <= 1'b1;
				end
				else begin //Calculated A*B+C, need to still accumulate
					//enable <= 1'b0;
					clear <= 1'b0;
				end
			end
		endcase
	end
endmodule
