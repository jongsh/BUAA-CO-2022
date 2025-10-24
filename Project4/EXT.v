`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:58:07 10/26/2022 
// Design Name: 
// Module Name:    EXT 
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
module EXT(
    input [15:0] EXTin,
    input [1:0] EXTop,
    output [31:0] EXTout
    );
	 
	 
	 assign EXTout = (EXTop == 2'b00) ? {{16{EXTin[15]}}, EXTin} :
	                 (EXTop == 2'b01) ? {16'd0, EXTin} :
						  (EXTop == 2'b10) ? {EXTin, 16'd0} :
						  32'd0;

endmodule
