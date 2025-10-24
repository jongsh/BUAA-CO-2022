`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:09:47 10/05/2022
// Design Name:   BlockChecker
// Module Name:   C:/Users/cjh/Desktop/Verilog/P1/P1_BlockChecker/BlockChecker_tb.v
// Project Name:  P1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: BlockChecker
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module BlockChecker_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] in;

	// Outputs
	wire result;

	// Instantiate the Unit Under Test (UUT)
	BlockChecker uut (
		.clk(clk), 
		.reset(reset), 
		.in(in), 
		.result(result)
	);
	
	always #5 clk = ~clk; 

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		in = 0;

		#10
		reset = 0;
		#42;
      in = " ";
		#10;
		in = "B";
		#10;
		in = "E";
		#10;
		in = "g";
		#10;
		in = "i";
		#10;
		in = "n";
		#10;
		in = " ";
		#10;
		in = "a";
		#10;
		in = "E";
		#10;
		in = "n";
		#10;
		in = "D";
		#10;
		in = " ";
		#10;
		in = "E";
		#10;
		in = "n";
		#10;
		in = "D";
		#10;
		in = " ";
		#10;
		in = "E";
		#10;
		in = "n";
		#10;
		in = "D";
		#10;
		in = "a";
		

	end
      
endmodule

