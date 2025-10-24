`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:10:22 10/26/2022 
// Design Name: 
// Module Name:    DM 
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
module DM(
    input clk,
    input reset,
    input MemWrite,
    input [11:0] MemAddr,
    input [31:0] MemWD,
    output [31:0] MemReadData
    );
	 
	 reg [31:0] DataRAM[0:4095];
	 integer i; 
	 
	 assign MemReadData = DataRAM[MemAddr];
	 
	 always @(posedge clk) begin
	     if (reset) begin
		      for (i = 0; i < 4096; i = i + 1) begin
				    DataRAM[i] <= 32'd0;
				end
		  end else begin
		      if (MemWrite == 1'b1) begin
				    DataRAM[MemAddr] <= MemWD;
				end 
		  end
	 end


endmodule
