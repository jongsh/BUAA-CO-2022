`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:13:03 11/06/2022
// Design Name:   DM
// Module Name:   C:/Users/cjh/Desktop/Verilog/P5/DM_tb.v
// Project Name:  P5
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DM
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module DM_tb;

	// Inputs
	reg clk;
	reg reset;
	reg DM_write;
	reg [1:0] DMop;
	reg [31:0] DM_addr;
	reg [31:0] DM_WD;

	// Outputs
	wire [31:0] DMout;

	// Instantiate the Unit Under Test (UUT)
	DM uut (
		.clk(clk), 
		.reset(reset), 
		.DM_write(DM_write), 
		.DMop(DMop), 
		.DM_addr(DM_addr), 
		.DM_WD(DM_WD), 
		.DMout(DMout)
	);
	always #10 clk = ~clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		DM_write = 0;
		DMop = 0;
		DM_addr = 0;
		DM_WD = 0;

		// Wait 100 ns for global reset to finish
		#20;
		reset = 0;
		DM_addr = 0;
      DMop = 2'd0;
		DM_WD = 32'habcd5555;
		DM_write = 1'b1;
		
		#20;
		DM_addr = 32'd4;
		DMop = 2'd0;
		DM_WD = 32'hab005511;
		DM_write = 1'b1;
		// Add stimulus here
		
		#20;
		DM_write = 1'b1;
		DMop = 2'd2;
		DM_addr = 32'd0;
		DM_WD = 32'hfe;
		

	end
      
endmodule

