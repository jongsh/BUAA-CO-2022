`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:29:29 10/05/2022 
// Design Name: 
// Module Name:    ext 
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
module ext(
    input [15:0] imm,
    input [1:0] EOp,
    output [31:0] ext
    );
	 
	 assign ext = (EOp == 2'b00) ? {{16{imm[15]}},imm} :
	              (EOp == 2'b01) ? {16'd0, imm} :
					  (EOp == 2'b10) ? {imm, 16'd0} :
					  (EOp == 2'b11) ? {{14{imm[15]}}, imm, 2'd0} :
					                   0;


endmodule
