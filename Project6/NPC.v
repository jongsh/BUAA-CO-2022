`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:31:50 11/06/2022 
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
    input [31:0] D_NPC_PC,
    input [3:0] D_NPCop,
    input [15:0] D_NPC_imm16,
    input [25:0] D_NPC_imm26,
    input [31:0] D_CMP_result,
    input [31:0] D_NPC_RegData,
    output reg [31:0] D_NPC_PCnext
    );
	 
	 // NPC µƒ ‰»ÎΩ” F_PC = D_PC + 4
	 always @(*) begin
	     case(D_NPCop)
		      4'b0000: D_NPC_PCnext = D_NPC_PC + 32'd4;
				4'b0001: D_NPC_PCnext = (D_CMP_result == 32'd1) ? (D_NPC_PC + {{14{D_NPC_imm16[15]}}, D_NPC_imm16, 2'b00}) : D_NPC_PC + 32'd4;
				4'b0010: D_NPC_PCnext = {D_NPC_PC[31:28], D_NPC_imm26, 2'b00};
				4'b0011: D_NPC_PCnext = D_NPC_RegData;
				default: D_NPC_PCnext = D_NPC_PC + 32'd4;
		  endcase
	 end

endmodule
