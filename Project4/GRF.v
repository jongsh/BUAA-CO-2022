`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:22:11 10/26/2022 
// Design Name: 
// Module Name:    GRF 
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
module GRF(
    input clk,
    input reset,
    input GRFWrite,
    input [4:0] regAddr1,
    input [4:0] regAddr2,
    input [4:0] regAddr3,
    input [31:0] regWD,
    output [31:0] RD1,
    output [31:0] RD2
    );
	 
	 reg [31:0] reg_GRF[0:31];
	 integer i;
	 assign RD1 = reg_GRF[regAddr1];
	 assign RD2 = reg_GRF[regAddr2];
	 
	 always @(posedge clk) begin
	     if (reset) begin
		      for (i = 0; i < 32; i = i + 1) begin
				    reg_GRF[i] = 32'd0;
				end
		  end else begin
		      if (GRFWrite && regAddr3 != 5'd0) begin
				    reg_GRF[regAddr3] <= regWD;
				end
		  end
	 end
endmodule
