`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:06:24 12/13/2022
// Design Name:   DigitalTube
// Module Name:   C:/Users/cjh/Desktop/Verilog/P8/DigitalTube_tb.v
// Project Name:  P8
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DigitalTube
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module DigitalTube_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [3:0] byteen;
	reg [31:0] Addr;
	reg [31:0] WD;

	// Outputs
	wire [7:0] digital_tube0;
	wire [7:0] digital_tube1;
	wire [7:0] digital_tube2;
	wire [3:0] digital_tube_sel0;
	wire [3:0] digital_tube_sel1;
	wire digital_tube_sel2;
	wire [31:0] tubeNum;

	// Instantiate the Unit Under Test (UUT)
	DigitalTube uut (
		.clk(clk), 
		.reset(reset), 
		.byteen(byteen), 
		.Addr(Addr), 
		.WD(WD), 
		.digital_tube0(digital_tube0), 
		.digital_tube1(digital_tube1), 
		.digital_tube2(digital_tube2), 
		.digital_tube_sel0(digital_tube_sel0), 
		.digital_tube_sel1(digital_tube_sel1), 
		.digital_tube_sel2(digital_tube_sel2), 
		.tubeNum(tubeNum)
	);

   
	always #5 clk = ~clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		byteen = 0;
		Addr = 0;
		WD = 0;

		// Wait 100 ns for global reset to finish
		#20
		reset = 0;
		WD = 32'h012345f;
		byteen = 4'b1111;
		Addr = 32'h7f50;
		
        
		// Add stimulus here

	end
      
endmodule

