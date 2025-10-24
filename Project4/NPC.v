`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:53:31 10/26/2022 
// Design Name: 
// Module Name:    NPC 
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
module NPC(
    input [25:0] imm26,
    input [15:0] imm16,
    input [31:0] regRa,
    input [31:0] PC,
    input [1:0] NPCop,
    input CMPResult,
    output reg [31:0] PCnext
    );
	 
	 always @(*) begin
	     case(NPCop)
		      2'b00: PCnext = PC + 32'd4;
				2'b01: PCnext = (CMPResult == 1'b1) ? (PC + 4 + {{14{imm16[15]}},imm16,2'b00}) : PC + 32'd4;
				2'b10: PCnext = {PC[31:28], imm26, 2'b00};
				2'b11: PCnext = regRa;
				default: PCnext = PC + 32'd4;
		  endcase
	 end


endmodule
