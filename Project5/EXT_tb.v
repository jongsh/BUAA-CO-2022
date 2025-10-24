`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:15:41 11/06/2022
// Design Name:   EXT
// Module Name:   C:/Users/cjh/Desktop/Verilog/P5/EXT_tb.v
// Project Name:  P5
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: EXT
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module EXT_tb;

	// Inputs
	reg [16:0] D_EXT_imm16;
	reg [3:0] D_EXTop;

	// Outputs
	wire [31:0] D_EXT_imm32;

	// Instantiate the Unit Under Test (UUT)
	EXT uut (
		.D_EXT_imm16(D_EXT_imm16), 
		.D_EXTop(D_EXTop), 
		.D_EXT_imm32(D_EXT_imm32)
	);

	initial begin
		// Initialize Inputs
		D_EXT_imm16 = 16'd99;
		D_EXTop = 4'd0;

	   #5;
		D_EXTop = 4'd1;
		#5;
		D_EXTop = 4'd2;
		#5;
		D_EXTop = 4'd3;

	end
      
endmodule

