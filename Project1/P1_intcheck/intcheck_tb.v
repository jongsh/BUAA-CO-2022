`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:47:34 10/10/2022
// Design Name:   intcheck
// Module Name:   C:/Users/cjh/Desktop/Verilog/P1/P1_intcheck/intcheck_tb.v
// Project Name:  P1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: intcheck
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module intcheck_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] in;

	// Outputs
	wire out;

	// Instantiate the Unit Under Test (UUT)
	intcheck uut (
		.clk(clk), 
		.reset(reset), 
		.in(in), 
		.out(out)
	);
	
	always #5 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		in = " ";

		// Wait 100 ns for global reset to finish
		#5;
		reset = 0;
		#10;
		in = "i";
		#10;
		in = "i";
		#10;
		in = "n";
		#10;
		in = "t";
		#10;
		in = "	";
		#10;
		in = " ";
		#10;
		in = "i";
		#10;
		in = "n";
		#10;
		in = "T";
		#10;
		in = "\0";
		#10;
		in = " ";
		#10;
		in = ";";
		#10;
		in = "i";
		#10;
		in = "n";
		#10;
		in = "t";
		#10;
		in = " ";
		#10;
		in = "i";
		#10;
		in = "_";
		#10;
		in = ",";
		#10;
		in = "c";
		#10;
		in = ",";
		#10;
		in = " ";
		#10;
		in = "\t";
		#10;
		in = "I";
		#10;
		in = ";";
		
		
        
		// Add stimulus here

	end
      
endmodule

