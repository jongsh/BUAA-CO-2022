`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:31:10 12/13/2022 
// Design Name: 
// Module Name:    LED 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module LED(
    input clk,
	 input reset,
	 input [3:0] byteen,
	 input [31:0] WD,
	 output [31:0] led_light
    );
	 
	 reg [31:0] fixedWD;
	 reg [31:0] led;
	 
	 always @(*) begin
	     fixedWD = led;
		  if (byteen[3] == 1'b1) fixedWD[31:24] = WD[31:24];
		  if (byteen[2] == 1'b1) fixedWD[23:16] = WD[23:16];
		  if (byteen[1] == 1'b1) fixedWD[15:8]  = WD[15:8];
		  if (byteen[0] == 1'b1) fixedWD[7:0]   = WD[7:0];
	 end
	 
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin
		      led <= 32'd0;
		  end else if (|byteen == 1'b1) begin
		      led <= fixedWD;
		  end
	 end
	 
	 assign led_light = ~led;

endmodule
