`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:33:33 11/06/2022 
// Design Name: 
// Module Name:    CU 
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
module CU(
    input [5:0] D_CU_opcode,
    input [5:0] D_CU_func,
	 output D_GRF_write,
	 output D_DM_write,
	 output [3:0] D_EXTop,
	 output [3:0] D_CMPop,
	 output [3:0] D_NPCop,
	 output [4:0] D_ALUop,
	 output [3:0] D_GRF_DatatoReg,
	 output [2:0] D_GRF_A3_sel,
	 output [2:0] D_ALU_Bsel,
	 output [1:0] D_DMop,
	 output [3:0] D_MDUop,
	 output D_MDU_start,
	 output D_MDUout_sel,
	 output [2:0] D_BEop,
	 output [3:0] D_rs_Tuse,
	 output [3:0] D_rt_Tuse,
	 output [3:0] D_Tnew
	 
    );
	 
	 wire ori;
	 wire lui;
	 wire jal;
	 wire jr;
	 wire add;
	 wire sub;
	 wire beq;
	 wire lw;
	 wire sw;
	 wire mult;
	 wire div;
	 wire multu;
	 wire divu;
	 wire mfhi;
	 wire mflo;
	 wire mthi;
	 wire mtlo;
	 wire And;
	 wire OR;
	 wire slt;
	 wire sltu;
	 wire addi;
	 wire andi;
	 wire bne;
	 wire sh;
	 wire sb;
	 wire lb;
	 wire lh;
	 
	 wire j;
	 wire jalr;
	 
	 
	 assign ori = (D_CU_opcode == 6'b001101) ? 1'b1 : 1'b0;
	 assign lui = (D_CU_opcode == 6'b001111) ? 1'b1 : 1'b0;
	 assign jal = (D_CU_opcode == 6'b000011) ? 1'b1 : 1'b0;
	 assign jr =  (D_CU_opcode == 6'd0 && D_CU_func == 6'b001000) ? 1'b1 : 1'b0;
	 
	 assign add = (D_CU_opcode == 6'd0 && D_CU_func == 6'b100000) ? 1'b1 : 1'b0;
	 assign sub = (D_CU_opcode == 6'd0 && D_CU_func == 6'b100010) ? 1'b1 : 1'b0;
	 
	 assign beq = (D_CU_opcode == 6'b000100) ? 1'b1 : 1'b0;
	 assign lw =  (D_CU_opcode == 6'b100011) ? 1'b1 : 1'b0;
	 assign sw =  (D_CU_opcode == 6'b101011) ? 1'b1 : 1'b0;
	 assign mult = (D_CU_opcode == 6'd0 && D_CU_func == 6'b011000) ? 1'b1 : 1'b0;
	 assign div = (D_CU_opcode == 6'd0 && D_CU_func == 6'b011010) ? 1'b1 : 1'b0;
	 assign multu = (D_CU_opcode == 6'd0 && D_CU_func == 6'b011001) ? 1'b1 : 1'b0;
	 assign divu = (D_CU_opcode == 6'd0 && D_CU_func == 6'b011011) ? 1'b1 : 1'b0;
	 assign mfhi = (D_CU_opcode == 6'd0 && D_CU_func == 6'b010000) ? 1'b1 : 1'b0;
	 assign mflo = (D_CU_opcode == 6'd0 && D_CU_func == 6'b010010) ? 1'b1 : 1'b0;
	 assign mthi = (D_CU_opcode == 6'd0 && D_CU_func == 6'b010001) ? 1'b1 : 1'b0;
	 assign mtlo = (D_CU_opcode == 6'd0 && D_CU_func == 6'b010011) ? 1'b1 : 1'b0;
	 assign And = (D_CU_opcode == 6'd0 && D_CU_func == 6'b100100) ? 1'b1 : 1'b0;
	 assign OR = (D_CU_opcode == 6'd0 && D_CU_func == 6'b100101) ? 1'b1 : 1'b0;
	 assign slt = (D_CU_opcode == 6'd0 && D_CU_func == 6'b101010) ? 1'b1 : 1'b0;
	 assign sltu = (D_CU_opcode == 6'd0 && D_CU_func == 6'b101011) ? 1'b1 : 1'b0;
	 assign addi = (D_CU_opcode == 6'b001000) ? 1'b1 : 1'b0;
	 assign andi = (D_CU_opcode == 6'b001100) ? 1'b1 : 1'b0;
	 assign bne = (D_CU_opcode == 6'b000101) ? 1'b1 : 1'b0;
	 assign sh = (D_CU_opcode == 6'b101001) ? 1'b1 : 1'b0;
	 assign sb = (D_CU_opcode == 6'b101000) ? 1'b1 : 1'b0;
	 assign lb = (D_CU_opcode == 6'b100000) ? 1'b1 : 1'b0;
	 assign lh = (D_CU_opcode == 6'b100001) ? 1'b1 : 1'b0;
	 assign j = (D_CU_opcode == 6'b000010) ? 1'b1 : 1'b0;
	 assign jalr = (D_CU_opcode == 6'd0 && D_CU_func == 6'b001001) ? 1'b1 : 1'b0;
	 
///////////////////////////   CRTL signs   ////////////////////////////////////

	 assign D_GRF_write = 1'b0 || ori || lui || jal || add || sub || lw || mfhi || mflo || And || OR
	                           || slt || sltu || addi || andi || lb || lh || jalr;
	 
	 assign D_DM_write = 1'b0 || sw || sh || sb;
	 
	 assign D_EXTop[0] = 1'b0 || ori || andi;
	 assign D_EXTop[1] = 1'b0 || lui;
	 assign D_EXTop[2] = 1'b0;
	 assign D_EXTop[3] = 1'b0;
	 
	 assign D_CMPop[0] = 1'b0 ||  bne;
	 assign D_CMPop[1] = 1'b0 ;
	 assign D_CMPop[2] = 1'b0 || bne;
	 assign D_CMPop[3] = 1'b0;
	 
	 assign D_NPCop[0] = 1'b0 || jr || beq || bne || jalr;
	 assign D_NPCop[1] = 1'b0 || jal || jr || j || jalr;
	 assign D_NPCop[2] = 1'b0;
	 assign D_NPCop[3] = 1'b0;
	 
	 assign D_ALUop[0] = 1'b0 || sub || And || andi || slt || sltu;
	 assign D_ALUop[1] = 1'b0 || ori || And || OR || andi || slt;
	 assign D_ALUop[2] = 1'b0 || slt;
	 assign D_ALUop[3] = 1'b0 || sltu;
	 assign D_ALUop[4] = 1'b0;
	 
	 assign D_GRF_DatatoReg[0] = 1'b0 || lw ||  lb || lh;
	 assign D_GRF_DatatoReg[1] = 1'b0 || jal || jalr;
	 assign D_GRF_DatatoReg[2] = 1'b0 || mfhi || mflo;
	 assign D_GRF_DatatoReg[3] = 1'b0;
	 
	 assign D_GRF_A3_sel[0] = 1'b0 || ori || lui || lw || addi || andi || lb || lh;
	 assign D_GRF_A3_sel[1] = 1'b0 || jal;
	 assign D_GRF_A3_sel[2] = 1'b0;
	 
	 assign D_ALU_Bsel[0] = 1'b0 || ori || lui || lw || sw || addi || andi || sh || sb || lb || lh;
	 assign D_ALU_Bsel[1] = 1'b0;
	 assign D_ALU_Bsel[2] = 1'b0;
	 
	 assign D_MDUop[0] = 1'b0 || mult || div || mthi;
	 assign D_MDUop[1] = 1'b0 || div || multu || mtlo;
	 assign D_MDUop[2] = 1'b0 || divu || mthi || mtlo;
	 assign D_MDUop[3] = 1'b0;
	 
	 assign D_MDU_start = 1'b0 || mult || div || multu || divu || mthi || mtlo;
	 
	 assign D_MDUout_sel = 1'b0 || mflo;
	 
	 assign D_BEop[0] = 1'b0;
	 assign D_BEop[1] = 1'b0 || lb;
	 assign D_BEop[2] = 1'b0 || lh;
	 
	 assign D_DMop[0] = 1'b0 || sh || lh;
	 assign D_DMop[1] = 1'b0 || sb || lb;
	 
	 assign D_rs_Tuse = (ori == 1'b1)  ? 4'd1 :
	                    (lui == 1'b1)  ? 4'd1 :
							  (jal == 1'b1)  ? 4'd7 :
							  (jr == 1'b1)   ? 4'd0 :   
							  (add == 1'b1)  ? 4'd1 :
							  (sub == 1'b1)  ? 4'd1 :
							  (beq == 1'b1)  ? 4'd0 :
							  (lw == 1'b1)   ? 4'd1 :
							  (sw == 1'b1)   ? 4'd1 :
							  (mult == 1'b1) ? 4'd1 :
							  (div == 1'b1)  ? 4'd1 :
							  (multu == 1'b1)? 4'd1 :
							  (divu == 1'b1) ? 4'd1 :
							  (mfhi == 1'b1) ? 4'd7 :
							  (mflo == 1'b1) ? 4'd7 :
							  (mthi == 1'b1) ? 4'd1 :
							  (mtlo == 1'b1) ? 4'd1 :
							  (And == 1'b1)  ? 4'd1 :
							  (OR == 1'b1)   ? 4'd1 :
							  (slt == 1'b1)  ? 4'd1 :
							  (sltu == 1'b1) ? 4'd1 :
							  (addi == 1'b1) ? 4'd1 :
							  (andi == 1'b1) ? 4'd1 :
							  (bne == 1'b1)  ? 4'd0 :
							  (sh == 1'b1)   ? 4'd1 : 
							  (sb == 1'b1)   ? 4'd1 : 
							  (lb == 1'b1)   ? 4'd1 :
							  (lh == 1'b1)   ? 4'd1 :
							  (j == 1'b1)    ? 4'd7 :
							  (jalr == 1'b1) ? 4'd0 :
	                                     4'd7;
    
	 assign D_rt_Tuse = (ori == 1'b1)  ? 4'd7 :
	                    (lui == 1'b1)  ? 4'd7 :
							  (jal == 1'b1)  ? 4'd7 :
							  (jr == 1'b1)   ? 4'd7 :
							  (add == 1'b1)  ? 4'd1 :
							  (sub == 1'b1)  ? 4'd1 :
							  (beq == 1'b1)  ? 4'd0 :
							  (lw == 1'b1)   ? 4'd7 :
							  (sw == 1'b1)   ? 4'd2 : 
							  (mult == 1'b1) ? 4'd1 :
							  (div == 1'b1)  ? 4'd1 :
							  (multu == 1'b1)? 4'd1 :
							  (divu == 1'b1) ? 4'd1 :
							  (mfhi == 1'b1) ? 4'd7 :
							  (mflo == 1'b1) ? 4'd7 :
							  (mthi == 1'b1) ? 4'd7 :
							  (mtlo == 1'b1) ? 4'd7 :
							  (And == 1'b1)  ? 4'd1 :
							  (OR == 1'b1)   ? 4'd1 :
							  (slt == 1'b1)  ? 4'd1 :
							  (sltu == 1'b1) ? 4'd1 :
							  (addi == 1'b1) ? 4'd7 :
							  (andi == 1'b1) ? 4'd7 :
							  (bne == 1'b1)  ? 4'd0 :
							  (sh == 1'b1)   ? 4'd2 :
							  (sb == 1'b1)   ? 4'd2 : 
							  (lb == 1'b1)   ? 4'd7 :
							  (lh == 1'b1)   ? 4'd7 :
							  (j == 1'b1)    ? 4'd7 :
							  (jalr == 1'b1) ? 4'd7 :
	                                     4'd7;
									
    assign D_Tnew = (ori == 1'b1)  ? 4'd2 :
	                 (lui == 1'b1)  ? 4'd2 :
						  (jal == 1'b1)  ? 4'd1 :
						  (jr == 1'b1)   ? 4'd0 :
						  (add == 1'b1)  ? 4'd2 :
						  (sub == 1'b1)  ? 4'd2 :
						  (beq == 1'b1)  ? 4'd0 :
						  (lw == 1'b1)   ? 4'd3 :
						  (sw == 1'b1)   ? 4'd0 :
						  (mult == 1'b1) ? 4'd0 :
						  (div == 1'b1)  ? 4'd0 :
						  (multu == 1'b1)? 4'd0 :
						  (divu == 1'b1) ? 4'd0 :
						  (mfhi == 1'b1) ? 4'd2 :
						  (mflo == 1'b1) ? 4'd2 :
						  (mthi == 1'b1) ? 4'd0 :
						  (mtlo == 1'b1) ? 4'd0 :
						  (And == 1'b1)  ? 4'd2 :
						  (OR == 1'b1)   ? 4'd2 :
						  (slt == 1'b1)  ? 4'd2 :
						  (sltu == 1'b1) ? 4'd2 :
						  (addi == 1'b1) ? 4'd2 :
						  (andi == 1'b1) ? 4'd2 :
						  (bne == 1'b1)  ? 4'd0 :
						  (sh == 1'b1)   ? 4'd0 :
						  (sb == 1'b1)   ? 4'd0 :
						  (lb == 1'b1)   ? 4'd3 :
						  (lh == 1'b1)   ? 4'd3 :
						  (j == 1'b1)    ? 4'd0 :	
						  (jalr == 1'b1) ? 4'd1 :
                                     4'd0;
endmodule
