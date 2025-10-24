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
	 
	 wire j;
	 
//////////////////////  instr /////////////////////////////////////////
	 
	 assign ori = (D_CU_opcode == 6'b001101) ? 1'b1 : 1'b0;
	 assign lui = (D_CU_opcode == 6'b001111) ? 1'b1 : 1'b0;
	 assign jal = (D_CU_opcode == 6'b000011) ? 1'b1 : 1'b0;
	 assign jr =  (D_CU_opcode == 6'd0 && D_CU_func == 6'b001000) ? 1'b1 : 1'b0;
	 assign add = (D_CU_opcode == 6'd0 && D_CU_func == 6'b100000) ? 1'b1 : 1'b0;
	 assign sub = (D_CU_opcode == 6'd0 && D_CU_func == 6'b100010) ? 1'b1 : 1'b0;
	 assign beq = (D_CU_opcode == 6'b000100) ? 1'b1 : 1'b0;
	 assign lw =  (D_CU_opcode == 6'b100011) ? 1'b1 : 1'b0;
	 assign sw =  (D_CU_opcode == 6'b101011) ? 1'b1 : 1'b0;
	 assign j =   (D_CU_opcode == 6'b000010) ? 1'b1 : 1'b0;
	 
	 
	 // CRTL signs
	 assign D_GRF_write = 1'b0 || ori || lui || jal || add || sub || lw;
	 
	 assign D_DM_write = 1'b0 || sw;
	 
	 assign D_EXTop[0] = 1'b0 || ori;
	 assign D_EXTop[1] = 1'b0 || lui;
	 assign D_EXTop[2] = 1'b0;
	 assign D_EXTop[3] = 1'b0;
	 
	 assign D_CMPop[0] = 1'b0;
	 assign D_CMPop[1] = 1'b0;
	 assign D_CMPop[2] = 1'b0;
	 assign D_CMPop[3] = 1'b0;
	 
	 assign D_NPCop[0] = 1'b0 || jr || beq;
	 assign D_NPCop[1] = 1'b0 || jal || jr || j;
	 assign D_NPCop[2] = 1'b0;
	 assign D_NPCop[3] = 1'b0;
	 
	 assign D_ALUop[0] = 1'b0 || sub;
	 assign D_ALUop[1] = 1'b0 || ori;
	 assign D_ALUop[2] = 1'b0;
	 assign D_ALUop[3] = 1'b0;
	 assign D_ALUop[4] = 1'b0;
	 
	 assign D_GRF_DatatoReg[0] = 1'b0 || lw;
	 assign D_GRF_DatatoReg[1] = 1'b0 || jal;
	 assign D_GRF_DatatoReg[2] = 1'b0;
	 assign D_GRF_DatatoReg[3] = 1'b0;
	 
	 assign D_GRF_A3_sel[0] = 1'b0 || ori || lui || lw;
	 assign D_GRF_A3_sel[1] = 1'b0 || jal;
	 assign D_GRF_A3_sel[2] = 1'b0;
	 
	 assign D_ALU_Bsel[0] = 1'b0 || ori || lui || lw || sw;
	 assign D_ALU_Bsel[1] = 1'b0;
	 assign D_ALU_Bsel[2] = 1'b0;
	 
	 assign D_DMop[0] = 1'b0;
	 assign D_DMop[1] = 1'b0;
	 
	 assign D_rs_Tuse = (ori == 1'b1) ? 4'd1 :
	                    (lui == 1'b1) ? 4'd1 :
							  (jal == 1'b1) ? 4'd7 :
							  (jr == 1'b1)  ? 4'd0 :   
							  (add == 1'b1) ? 4'd1 :
							  (sub == 1'b1) ? 4'd1 :
							  (beq == 1'b1) ? 4'd0 :
							  (lw == 1'b1)  ? 4'd1 :
							  (sw == 1'b1)  ? 4'd1 :
							  (j == 1'b1)   ? 4'd7 :
	                                    4'd7;
    
	 assign D_rt_Tuse = (ori == 1'b1) ? 4'd7 :
	                    (lui == 1'b1) ? 4'd7 :
							  (jal == 1'b1) ? 4'd7 :
							  (jr == 1'b1)  ? 4'd7 :
							  (add == 1'b1) ? 4'd1 :
							  (sub == 1'b1) ? 4'd1 :
							  (beq == 1'b1) ? 4'd0 :
							  (lw == 1'b1)  ? 4'd7 :
							  (sw == 1'b1)  ? 4'd2 : 
							  (j == 1'b1)   ? 4'd7 :
	                                    4'd7;
									
    assign D_Tnew = (ori == 1'b1) ? 4'd2 :
	                 (lui == 1'b1) ? 4'd2 :
						  (jal == 1'b1) ? 4'd1 :
						  (jr == 1'b1)  ? 4'd0 :
						  (add == 1'b1) ? 4'd2 :
						  (sub == 1'b1) ? 4'd2 :
						  (beq == 1'b1) ? 4'd0 :
						  (lw == 1'b1)  ? 4'd3 :
						  (sw == 1'b1)  ? 4'd0 :
						  (j == 1'b1)   ? 4'd0 :
                                    4'd0;
endmodule
