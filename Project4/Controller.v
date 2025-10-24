`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:16:08 10/26/2022 
// Design Name: 
// Module Name:    Controller 
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
module Controller(
    input [5:0] instr_op,
    input [5:0] instr_func,
	 output RegWrite,
	 output [1:0] RegDst,
	 output [1:0] EXTop,
	 output [1:0] NPCop,
	 output ALUSrc,
	 output [2:0] ALUop,
	 output [2:0] CMPop,
	 output MemWrite,
	 output [2:0] DatatoReg
    );
	 
	 wire ori;
	 wire lui;
	 wire add;
	 wire sub;
	 wire lw;
	 wire sw;
	 wire beq;
	 wire jr;
	 wire jal;
	 
	 wire addi;
	 wire j;
	 wire bne;
	 wire slt;
	 
	 assign ori = (instr_op == 6'b001101) ? 1'b1 : 1'b0;
	 assign lui = (instr_op == 6'b001111) ? 1'b1 : 1'b0;
	 assign add = (instr_op == 6'd0 && instr_func == 6'b100000) ? 1'b1 : 1'b0;
	 assign sub = (instr_op == 6'd0 && instr_func == 6'b100010) ? 1'b1 : 1'b0;
	 assign lw = (instr_op == 6'b100011) ? 1'b1 : 1'b0;
	 assign sw = (instr_op == 6'b101011) ? 1'b1 : 1'b0;
	 assign beq = (instr_op == 6'b000100) ? 1'b1 : 1'b0;
	 assign jr = (instr_op == 6'd0 && instr_func == 6'b001000) ? 1'b1 : 1'b0;
	 assign jal = (instr_op == 6'b000011) ? 1'b1 : 1'b0;
	 assign addi = (instr_op == 6'b001000) ? 1'b1 : 1'b0;
	 assign j = (instr_op == 6'b000010) ? 1'b1 : 1'b0;
	 assign bne = (instr_op == 6'b000101) ? 1'b1 : 1'b0;
	 assign slt = (instr_op == 6'd0 && instr_func == 6'b101010) ? 1'b1 : 1'b0;
	 
	 
	 // output signal
	 
	 assign RegWrite = 1'b0||ori||lui||add||sub||lw||jal||addi||slt;
    assign RegDst[0] = 1'b0||ori||lui||lw||addi;
	 assign RegDst[1] = 1'b0||jal;
	 assign EXTop[0] = 1'b0||ori;
	 assign EXTop[1] = 1'b0||lui;
    assign NPCop[0] = 1'b0||beq||jr||bne;
    assign NPCop[1] = 1'b0||jr||jal||j;
	 assign ALUSrc = 1'b0||ori||lui||lw||sw||addi;
	 assign ALUop[0] = 1'b0||sub;
	 assign ALUop[1] = 1'b0||ori;
	 assign ALUop[2] = 1'b0;
	 assign CMPop[0] = 1'b0||bne||slt;
	 assign CMPop[1] = 1'b0;
	 assign CMPop[2] = 1'b0||bne;
	 assign MemWrite = 1'b0||sw;
	 assign DatatoReg[0] = 1'b0||lw||slt;
	 assign DatatoReg[1] = 1'b0||jal||slt;
	 assign DatatoReg[2] = 1'b0;


endmodule
