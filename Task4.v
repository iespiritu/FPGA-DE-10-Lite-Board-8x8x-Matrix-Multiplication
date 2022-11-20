`timescale 1ns/10ps
module Task4(
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
	
	wire signed [7:0] calcA_0, calcA_1, calcA_2, calcA_3, calcA_4, calcA_5, calcA_6, calcA_7,  
							calcB;
	reg unsigned [5:0] addressA_0, addressA_1, addressA_2, addressA_3, addressA_4, addressA_5, addressA_6, addressA_7,
							 addressB;
	wire signed [18:0] outputMAC_0, outputMAC_1, outputMAC_2, outputMAC_3, outputMAC_4, outputMAC_5, outputMAC_6, outputMAC_7, inputRAM;
	reg signed [18:0] outputBuffer_0, outputBuffer_1, outputBuffer_2, outputBuffer_3, 
							outputBuffer_4, outputBuffer_5, outputBuffer_6, outputBuffer_7, 
							outputBuffer;
	
	reg clear; //toggles MAC operation
	reg enable; //toggles writing to memory operation
	reg [10:0] mem_write;
	reg [5:0] address, address_adj;

	assign calcA_0 = matrixA [addressA_0];
	assign calcA_1 = matrixA [addressA_1];
	assign calcA_2 = matrixA [addressA_2];
	assign calcA_3 = matrixA [addressA_3];
	assign calcA_4 = matrixA [addressA_4];
	assign calcA_5 = matrixA [addressA_5];
	assign calcA_6 = matrixA [addressA_6];
	assign calcA_7 = matrixA [addressA_7];
	
	assign calcB = matrixB [addressB];
	assign inputRAM = outputBuffer;
	
	RAM RAMOUTPUT(.datain (inputRAM),.clk	(clk),.write_enable(enable), .address (address_adj));
	
	MAC instMAC0(.inA (calcA_0),.inB	(calcB),.clear (clear),.clock (clk),.outC (outputMAC_0));
	MAC instMAC1(.inA (calcA_1),.inB (calcB),.clear (clear),.clock	(clk),.outC (outputMAC_1));
	MAC instMAC2(.inA (calcA_2),.inB	(calcB),.clear (clear),.clock (clk),.outC (outputMAC_2));
	MAC instMAC3(.inA (calcA_3),.inB (calcB),.clear (clear),.clock	(clk),.outC (outputMAC_3));
	MAC instMAC4(.inA (calcA_4),.inB	(calcB),.clear (clear),.clock (clk),.outC (outputMAC_4));
	MAC instMAC5(.inA (calcA_5),.inB (calcB),.clear (clear),.clock	(clk),.outC (outputMAC_5));
	MAC instMAC6(.inA (calcA_6),.inB	(calcB),.clear (clear),.clock (clk),.outC (outputMAC_6));
	MAC instMAC7(.inA (calcA_7),.inB (calcB),.clear (clear),.clock	(clk),.outC (outputMAC_7));
	
	always @ (posedge clk) begin 
		if (clock_count  > 6 && clock_count % 8 == 11'd7) begin //Save output
			outputBuffer_0 <= outputMAC_0;
			outputBuffer_1 <= outputMAC_1;
			outputBuffer_2 <= outputMAC_2;
			outputBuffer_3 <= outputMAC_3;
			outputBuffer_4 <= outputMAC_4;
			outputBuffer_5 <= outputMAC_5;
			outputBuffer_6 <= outputMAC_6;
			outputBuffer_7 <= outputMAC_7;
		end
		mem_write = clock_count % 11'd8;
	end
	
	always @ (posedge clk) begin
		if (clock_count > 6 && clock_count == 11'd71)
			enable <= 1'b0;
		else if (clock_count > 6 && clock_count % 8 == 11'd7)
			enable <= 1'b1;
	end
	
	always @ (negedge clk) begin
		mem_write = clock_count % 11'd8;
		case (mem_write)
			0:	begin address_adj <= 8 * (address - 6'd1) + 6'd0;
				outputBuffer <= outputBuffer_0; end
			1: begin address_adj <= 8 * (address - 6'd1) + 6'd1;
				outputBuffer <= outputBuffer_1; end
			2:	begin address_adj <= 8 * (address - 6'd1) + 6'd2;
				outputBuffer <= outputBuffer_2; end
			3:	begin address_adj <= 8 * (address - 6'd1) + 6'd3;
				outputBuffer <= outputBuffer_3; end
			4:	begin address_adj <= 8 * (address - 6'd1) + 6'd4;
				outputBuffer <= outputBuffer_4; end
			5:	begin address_adj <= 8 * (address - 6'd1) + 6'd5;
				outputBuffer <= outputBuffer_5; end
			6:	begin address_adj <= 8 * (address - 6'd1) + 6'd6;
				outputBuffer <= outputBuffer_6; end
			7:	begin address_adj <= 8 * (address - 6'd1) + 6'd7;
				outputBuffer <= outputBuffer_7; end
			endcase
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
				else if (clock_count == 11'd71)
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
					addressA_0 <= 11'd0;
					addressA_1 <= 11'd1;
					addressA_2 <= 11'd2;
					addressA_3 <= 11'd3;
					addressA_4 <= 11'd4;
					addressA_5 <= 11'd5;
					addressA_6 <= 11'd6;
					addressA_7 <= 11'd7;
					
					addressB <= 11'd0;
					address <= 6'd0;
				end
			end
	
			calculate: begin
				if (clock_count > 6 && clock_count % 64 == 11'd63) begin //Finished
					address <= address + 6'd1;
				end
				else if (clock_count  > 6 && clock_count % 8 == 11'd7) begin //Calculated one column of C, need to move next column					
					addressA_0 <= addressA_0 - 6'd56;
					addressA_1 <= addressA_1 - 6'd56;
					addressA_2 <= addressA_2 - 6'd56;
					addressA_3 <= addressA_3 - 6'd56;
					addressA_4 <= addressA_4 - 6'd56;
					addressA_5 <= addressA_5 - 6'd56;
					addressA_6 <= addressA_6 - 6'd56;
					addressA_7 <= addressA_7 - 6'd56;
			
					addressB <= addressB + 6'd1;
					address <= address + 6'd1;
				end
				else begin //Calculated A*B+C, need to still accumulate
					addressA_0 <= addressA_0 + 6'd8;
					addressA_1 <= addressA_1 + 6'd8;
					addressA_2 <= addressA_2 + 6'd8;
					addressA_3 <= addressA_3 + 6'd8;
					addressA_4 <= addressA_4 + 6'd8;
					addressA_5 <= addressA_5 + 6'd8;
					addressA_6 <= addressA_6 + 6'd8;
					addressA_7 <= addressA_7 + 6'd8;
					
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
				if (clock_count > 6 && clock_count % 64 == 11'd63) begin //Finished
					//enable <= 1'b1;
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
