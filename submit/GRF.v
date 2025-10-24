`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:27:21 11/06/2022 
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
    input GRF_write,
    input [4:0] GRF_A1,
    input [4:0] GRF_A2,
    input [4:0] GRF_A3,
    input [31:0] GRF_WD,
    output reg [31:0] GRF_RD1,
    output reg [31:0] GRF_RD2
    );
	 
	 reg [31:0] reg_GRF[0:31];
	 integer i;
	 
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin
		      for (i = 0; i < 32; i = i + 1) begin
				    reg_GRF[i] <= 32'd0;
				end
		  end else begin
		      if (GRF_write == 1'b1 && GRF_A3 != 5'd0) begin
				    reg_GRF[GRF_A3] <= GRF_WD;
				end 
		  end
	 end
	 
	 // GRF 支持内部转发
	 always @(*) begin
	     if (GRF_A3 == GRF_A1 && GRF_A3 != 5'd0 && GRF_write == 1'b1) begin
		      GRF_RD1 = GRF_WD;
		  end else begin
		      GRF_RD1 = reg_GRF[GRF_A1];
		  end
		  
		  if (GRF_A3 == GRF_A2 && GRF_A3 != 5'd0 && GRF_write == 1'b1) begin
		      GRF_RD2 = GRF_WD;
		  end else begin
		      GRF_RD2 = reg_GRF[GRF_A2];
		  end
	 end

endmodule
