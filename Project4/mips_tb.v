`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:17:09 10/27/2022
// Design Name:   mips
// Module Name:   C:/Users/cjh/Desktop/Verilog/P4/mips_tb.v
// Project Name:  P4
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mips
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mips_tb;

	// Inputs
	reg clk;
	reg reset;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk(clk), 
		.reset(reset)
	);
	
	always #5 clk = ~clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1'b1;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 1'b0;
		// Add stimulus here

	end
      
endmodule

