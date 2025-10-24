`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:25:08 11/06/2022
// Design Name:   CMP
// Module Name:   C:/Users/cjh/Desktop/Verilog/P5/CMP_tb.v
// Project Name:  P5
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CMP
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CMP_tb;

	// Inputs
	reg [31:0] D_CMP_opA;
	reg [31:0] D_CMP_opB;
	reg [3:0] D_CMPop;

	// Outputs
	wire [31:0] D_CMP_result;

	// Instantiate the Unit Under Test (UUT)
	CMP uut (
		.D_CMP_opA(D_CMP_opA), 
		.D_CMP_opB(D_CMP_opB), 
		.D_CMPop(D_CMPop), 
		.D_CMP_result(D_CMP_result)
	);

	initial begin
		// Initialize Inputs
		D_CMP_opA = 0;
		D_CMP_opB = 0;
		D_CMPop = 4'd0;

		// Wait 100 ns for global reset to finish
		#100;
		D_CMP_opA = -1;
		D_CMP_opB = 0;
		D_CMPop = 4'd1;
		
		#100;
		D_CMP_opA = -1;
		D_CMP_opB = 0;
		D_CMPop = 4'd3;
		
		#100;
		D_CMP_opA = -1;
		D_CMP_opB = 0;
		D_CMPop = 4'd5;
        
		// Add stimulus here

	end
      
endmodule

