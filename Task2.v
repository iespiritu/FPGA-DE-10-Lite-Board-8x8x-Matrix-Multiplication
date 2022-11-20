`timescale 1ns/10ps
module Task2(
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
	
	wire signed [7:0] calcA, calcB;
	reg unsigned [5:0] addressA, addressB;
	wire signed [18:0] outputMAC;
	
	reg clear; //toggles MAC operation
	reg enable; //toggles writing to memory operation
	reg [5:0] address;
	
	assign calcA = matrixA [addressA];
	assign calcB = matrixB [addressB];
	
	RAM RAMOUTPUT(
		.datain				(outputMAC),
		.clk					(clk),
		.write_enable		(enable),
		.address				(address)
	);
	
	MAC instMAC(
		.inA 		(calcA),
		.inB		(calcB),
		.clear	(clear),
		.clock	(clk),
		.outC		(outputMAC)
	);

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
				else if (clock_count == 11'd512)
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
					addressA <= 11'd0;
					addressB <= 11'd0;
					//clear <= 1'b1;
					address <= 6'd0;
				end
			end
	
			calculate: begin
				if (clock_count > 6 && clock_count % 512 == 11'd511) begin //Finished
					//enable <= 1'b1;
					//clear <= 1'b1;
					address <= address + 6'd1;
				end
				else if (clock_count  > 6 && clock_count % 64 == 11'd63) begin //Calculated last entry in one column of C, need to move next column
					//enable <= 1'b1;
					//clear <= 1'b1;
					addressA <= addressA - 6'd63;
					addressB <= addressB + 6'd1;
					address <= address + 6'd1;
				end
				else if (clock_count  > 6 && clock_count % 8 == 11'd7) begin //Calculated a row entry in C, need to shift down
					//enable <= 1'b1;
					//clear <= 1'b1;
					addressA <= addressA - 6'd55;
					addressB <= addressB - 6'd7;
					address <= address + 6'd1;
				end
				else begin //Calculated A*B+C, need to still accumulate
					//enable <= 1'b0;
					//clear <= 1'b0;
					addressA <= addressA + 6'd8;
					addressB <= addressB + 6'd1;
				end
			end
		endcase
	end
	
	always @ (negedge clk) begin
		case (state)
			stationary: begin //Default parameters
					if (start == 1'b1) begin
						//addressA <= 11'd0;
						//addressB <= 11'd0;
						clear <= 1'b1;
						//address <= 6'd0;
					end
			end
			
			calculate: begin
				if (clock_count > 6 && clock_count % 512 == 11'd511) begin //Finished
					enable <= 1'b1;
					//clear <= 1'b1;
					//address <= address + 6'd1;
				end
				else if (clock_count  > 6 && clock_count % 64 == 11'd63) begin //Calculated last entry in one column of C, need to move next column
					enable <= 1'b1;
					clear <= 1'b1;
					//addressA <= addressA - 6'd55;
					//addressB <= addressB - 6'd7;
					//address <= address + 6'd1;
				end
				else if (clock_count  > 6 && clock_count % 8 == 11'd7) begin //Calculated a row entry in C, need to shift down
					enable <= 1'b1;
					clear <= 1'b1;
					//addressA <= addressA - 6'd55;
					//addressB <= addressB - 6'd8;
					//address <= address + 6'd1;
				end
				else begin //Calculated A*B+C, need to still accumulate
					enable <= 1'b0;
					clear <= 1'b0;
					//addressA <= addressA + 6'd8;
					//addressB <= addressB + 6'd1;
				end
			end
		endcase
	end
endmodule
