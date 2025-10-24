`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:51:58 11/06/2022 
// Design Name: 
// Module Name:    D_E_REG 
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
module D_E_REG(
    input clk,
    input reset,
    input D_E_REG_EN,
    input [31:0] D_PC,
    input [31:0] D_instr,
    input [4:0] D_ALUop,
	 input D_DM_write,
	 input D_GRF_write,
	 input [31:0] D_RD1,
	 input [31:0] D_RD2,
	 input [4:0] D_instr_shamt,
	 input [31:0] D_EXT_imm32,
	 input [4:0] D_GRF_A3,
	 input [31:0] D_CMP_result,
	 input [3:0] D_GRF_DatatoReg,
	 input [2:0] D_ALU_Bsel,
	 input [1:0] D_DMop,
	 input [3:0] D_rs_Tuse,
	 input [3:0] D_rt_Tuse,
	 input [3:0] D_Tnew,
	 output reg [31:0] E_PC,
    output reg [31:0] E_instr,
    output reg [4:0] E_ALUop,
	 output reg E_DM_write,
	 output reg E_GRF_write,
	 output reg [31:0] E_RD1,
	 output reg [31:0] E_RD2,
	 output reg [4:0] E_instr_shamt,
	 output reg [31:0] E_EXT_imm32,
	 output reg [4:0] E_GRF_A3,
	 output reg [31:0] E_CMP_result,
	 output reg [3:0] E_GRF_DatatoReg,
	 output reg [2:0] E_ALU_Bsel,
	 output reg [1:0] E_DMop,
	 output reg [3:0] E_rs_Tuse,
	 output reg [3:0] E_rt_Tuse,
	 output reg [3:0] E_Tnew
    );
	 
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin
		      E_PC <= 32'd0;
				E_instr <= 32'd0;
				E_DM_write <= 1'b0;
				E_GRF_write <= 1'b0;
				E_GRF_A3 <= 5'd0;
				E_GRF_DatatoReg <= 4'd0;
		  end else begin
		      if (D_E_REG_EN == 1'b1) begin
				    E_PC <= D_PC;
					 E_instr <= D_instr;
					 E_ALUop <= D_ALUop;
					 E_DM_write <= D_DM_write;
                E_GRF_write <= D_GRF_write;
                E_RD1 <= D_RD1;
					 E_RD2 <= D_RD2;
					 E_instr_shamt <= D_instr_shamt;
					 E_EXT_imm32 <= D_EXT_imm32;
					 E_GRF_A3 <= D_GRF_A3;
					 E_CMP_result <= D_CMP_result;
					 E_GRF_DatatoReg <= D_GRF_DatatoReg;
					 E_ALU_Bsel <= D_ALU_Bsel;
					 E_DMop <= D_DMop;
					 E_rs_Tuse <= D_rs_Tuse;
					 E_rt_Tuse <= D_rt_Tuse;
					 E_Tnew <= (D_Tnew == 4'd0) ? 4'd0 : (D_Tnew - 4'd1);
					 
				end
		  end
	 end


endmodule
