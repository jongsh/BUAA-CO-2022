`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:37:11 11/12/2022
// Design Name:   MDU
// Module Name:   C:/Users/cjh/Desktop/Verilog/P6/MDU_tb.v
// Project Name:  P6
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MDU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module MDU_tb;

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [31:0] MDU_opA;
	reg [31:0] MDU_opB;
	reg [3:0] MDUop;

	// Outputs
	wire busy;
	wire [31:0] hi;
	wire [31:0] lo;

	// Instantiate the Unit Under Test (UUT)
	MDU uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.MDU_opA(MDU_opA), 
		.MDU_opB(MDU_opB), 
		.MDUop(MDUop), 
		.busy(busy), 
		.HI(hi),
		.LO(lo)
	);
	
	
	// 0000£ºÎÞ²Ù×÷£»0001£º·ûºÅ³Ë AB£»0010£ºÎÞ·ûºÅ³Ë AB£»0011£º·ûºÅ³ý A/B£» 
	 // 0100£ºÎÞ·ûºÅ³ý A/B£»0101£ºÐ´ HI ¼Ä´æÆ÷£»0110£ºÐ´ LO ¼Ä´æÆ÷
	 
	wire [63:0] temp;
	assign temp = {hi,lo};
	 
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1'b1;
		start = 0;
		MDU_opA = 0;
		MDU_opB = 0;
		MDUop = 0;
		
		#15;
		reset = 1'b0;
		#1;
		start = 1'b1;
		MDU_opA = -32'd17;
		MDU_opB = 32'd101;
		MDUop = 5'd1;
		#10;
		start = 1'b0;
		MDUop = 5'd0;
		#100;
		start = 1'b1;
		MDU_opA = -32'd17;
		MDU_opB = 32'd101;
		MDUop = 5'd2;
		#10;
		start = 1'b0;
		MDUop = 5'd0;
		#100;
		start = 1'b1;
		MDU_opA = 32'd101;
		MDU_opB = -32'd10;
		MDUop = 5'd3;
		#10;
		start = 1'b0;
		MDUop = 5'd0;
		#100;
		start = 1'b1;
		MDU_opA = -32'd101;
		MDU_opB = 32'd10;
		MDUop = 5'd4;
		#10;
		start = 1'b0;
		MDUop = 5'd0;
		#100;
		start = 1'b1;
		MDU_opA = 32'd123;
		MDUop = 5'd5;
		#10; 
		start = 1'b0;
		MDUop = 5'd0;
		MDU_opA = 32'd4433;
		#10; 
		start = 1'b1;
		MDUop = 5'd6;
		

		
	end
	
	always #5 clk = ~clk;
      
endmodule

