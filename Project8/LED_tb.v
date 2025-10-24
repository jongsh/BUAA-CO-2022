`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:18:04 12/13/2022
// Design Name:   LED
// Module Name:   C:/Users/cjh/Desktop/Verilog/P8/LED_tb.v
// Project Name:  P8
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: LED
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module LED_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [3:0] byteen;
	reg [31:0] WD;

	// Outputs
	wire [31:0] led_light;

	// Instantiate the Unit Under Test (UUT)
	LED uut (
		.clk(clk), 
		.reset(reset), 
		.byteen(byteen), 
		.WD(WD), 
		.led_light(led_light)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		byteen = 0;
		WD = 0;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 0;
		byteen = 4'b1111;
		WD = 32'h0afd2403;
		#50;
		
		byteen = 4'b1100;
		WD = 32'd88800891;
        
		// Add stimulus here

	end
	
	always #5 clk = ~clk;
      
endmodule

