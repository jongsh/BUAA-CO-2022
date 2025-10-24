`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:08:03 11/06/2022 
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
    input [15:0] D_EXT_imm16,
    input [3:0] D_EXTop,
    output [31:0] D_EXT_imm32
    );
	 
	 assign D_EXT_imm32 = (D_EXTop == 4'b0000) ? {{16{D_EXT_imm16[15]}},D_EXT_imm16} :
	                      (D_EXTop == 4'b0001) ? {16'd0, D_EXT_imm16} :  
                         (D_EXTop == 4'b0010) ? {D_EXT_imm16, 16'd0} :  
                         (D_EXTop == 4'b0011) ? {D_EXT_imm16, 16'hffff} : 
                                                32'd0;								 


endmodule
