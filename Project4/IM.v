`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:11:36 10/26/2022 
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
    input [13:2] instrAddr,
    output [31:0] instr
    );
	 
	 reg [31:0] instrROM[0:4095];
	 wire [11:0] instrAddrtmp;
	 
	 
	 initial begin
	     $readmemh("code.txt", instrROM, 0);
	 end
	 
	 assign instrAddrtmp = instrAddr - 12'b110000000000;
	 assign instr = instrROM[instrAddrtmp];
	 
endmodule
