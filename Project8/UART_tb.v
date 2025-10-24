`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:16:21 12/15/2022
// Design Name:   UART
// Module Name:   C:/Users/cjh/Desktop/Verilog/P8/UART_tb.v
// Project Name:  P8
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: UART
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module UART_tb;

	// Inputs
	reg clk;
	reg reset;
	reg WE;
	reg [31:0] addr;
	reg [31:0] WD;
	reg rxd;

	// Outputs
	wire txd;
	wire [31:0] RD;
	wire interrupt;

	// Instantiate the Unit Under Test (UUT)
	UART uut (
		.clk(clk), 
		.reset(reset), 
		.WE(WE), 
		.addr(addr), 
		.WD(WD), 
		.rxd(rxd), 
		.txd(txd), 
		.RD(RD), 
		.interrupt(interrupt)
	);

   always #5 clk = ~clk;
	initial begin
		// Initialize Inputs
		clk = 1;
		reset = 1;
		WE = 0;
		addr = 0;
		WD = 0;
		rxd = 0;

		// Wait 100 ns for global reset to finish
		#29;
		reset = 0;
      addr = 32'h7f32;
      WE = 1'b1;
		WD = 32'hfa;
      #10;
      addr = 32'd0;
      WE = 0;
       		
		// Add stimulus here

	end
      
endmodule

