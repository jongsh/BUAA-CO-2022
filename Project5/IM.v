`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:55:04 11/06/2022 
// Design Name: 
// Module Name:    IM 
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
module IM(
    input [31:0] F_PC,
    output [31:0] F_instr
    );
	 
	 reg [31:0] IM_ROM[0:4095];
	 
	 wire [31:0] F_PCtemp;
	 
	 initial begin
	     $readmemh("code.txt", IM_ROM, 0);
	 end
	 
	 assign F_PCtemp = F_PC - 32'h00003000;
	 assign F_instr = IM_ROM[F_PCtemp[13:2]];
	 
	 


endmodule
