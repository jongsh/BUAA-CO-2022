`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:48:52 12/18/2022
// Design Name:   IM
// Module Name:   C:/Users/cjh/Desktop/Verilog/P8/IM_tb.v
// Project Name:  P8
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: IM
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module IM_tb;

	// Inputs
	reg clka;
	reg [11:0] addra;

	// Outputs
	wire [31:0] douta;

	// Instantiate the Unit Under Test (UUT)
	IM uut (
		.clka(clka), 
		.addra(addra), 
		.douta(douta)
	);
    
	always #5 clka = ~clka;
	initial begin
		// Initialize Inputs
		clka = 0;
		addra = 0;
      
		// Wait 100 ns for global reset to finish
		#100;
      addra = 20;  
		// Add stimulus here

	end
      
endmodule

