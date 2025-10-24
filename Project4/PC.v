`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:47:33 10/26/2022 
// Design Name: 
// Module Name:    PC 
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
module PC(
    input [31:0] PCnext,
    input clk,
    input reset,
    output reg [31:0] PC
    );
	 
	 always @(posedge clk) begin
	     if (reset) begin
		      PC <= 32'h00003000;
		  end else begin
		      PC <= PCnext;
		  end
	 end


endmodule
