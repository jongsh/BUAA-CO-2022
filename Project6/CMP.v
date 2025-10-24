`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:08:29 11/06/2022 
// Design Name: 
// Module Name:    CMP 
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
module CMP(
    input [31:0] D_CMP_opA,
    input [31:0] D_CMP_opB,
    input [3:0] D_CMPop,
    output [31:0] D_CMP_result
    );
	 
	 wire [31:0] high;
	 wire [31:0] low;
	 
	 assign high = ($signed(D_CMP_opA) > $signed(D_CMP_opB));  // ÓÐ·ûºÅ A > B
 	 assign low = ($signed(D_CMP_opA) < $signed(D_CMP_opB));  // ÓÐ·ûºÅ A < B
	 
	 assign D_CMP_result = (D_CMPop == 4'd0) ? (D_CMP_opA == D_CMP_opB) :
	                       (D_CMPop == 4'd1) ? low   :
								  (D_CMPop == 4'd2) ? high  :
								  (D_CMPop == 4'd3) ? (D_CMP_opA < D_CMP_opB) :
								  (D_CMPop == 4'd4) ? (D_CMP_opA > D_CMP_opB) :
								  (D_CMPop == 4'd5) ? (D_CMP_opA != D_CMP_opB) :
								                      32'd0;


endmodule
