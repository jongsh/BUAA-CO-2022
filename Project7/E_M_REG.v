`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:25:50 11/06/2022 
// Design Name: 
// Module Name:    E_M_REG 
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
module E_M_REG(
    input clk,
    input reset,
	 input Req,
    input E_M_REG_EN,
	 input [31:0] E_PC,
	 input [31:0] E_instr,
	 input [31:0] E_RD2,
	 input E_DM_write,
	 input E_GRF_write,
	 input E_CP0_write,
	 input [1:0] E_DMop,
	 input [2:0] E_BEop,
	 input [31:0] E_MDUout,
	 input [31:0] E_ALUout,
	 input [4:0] E_GRF_A3,
	 input [3:0] E_GRF_DatatoReg,
	 input [31:0] E_CMP_result,
	 input E_BD,
	 input E_eret,
	 input [3:0] E_instr_type,
	 input [4:0] E_ExcCode,
	 input [3:0] E_rs_Tuse,
	 input [3:0] E_rt_Tuse,
	 input [3:0] E_Tnew,
	 output reg [31:0] M_PC,
	 output reg [31:0] M_instr,
	 output reg [31:0] M_RD2,
	 output reg M_DM_write,
	 output reg M_GRF_write,
	 output reg M_CP0_write,
	 output reg [1:0] M_DMop,
	 output reg [31:0] M_ALUout,
	 output reg [2:0] M_BEop,
	 output reg [31:0] M_MDUout,
	 output reg [4:0] M_GRF_A3,
	 output reg [3:0] M_GRF_DatatoReg,
	 output reg [31:0] M_CMP_result,
	 output reg M_BD,
	 output reg M_eret,
	 output reg [3:0] M_instr_type,
	 output reg [4:0] M_ExcCode,
	 output reg [3:0] M_rs_Tuse,
	 output reg [3:0] M_rt_Tuse,
	 output reg [3:0] M_Tnew
    );
	 
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin
		      M_PC <= 32'h3000;
				M_instr <= 32'd0;
			   M_DM_write <= 1'b0;
				M_GRF_write <= 1'b0;
				M_CP0_write <= 1'b0;
				M_BD <= 1'b0;
				M_eret <= 1'b0;
				M_instr_type <= 4'b0000;
				M_ExcCode <= 5'd0;
		  end else if (Req == 1'b1) begin
		      M_PC <= 32'h4180;
				M_instr <= 32'd0;
			   M_DM_write <= 1'b0;
				M_GRF_write <= 1'b0;
				M_CP0_write <= 1'b0;
				M_BD <= 1'b0;
				M_eret <= 1'b0;
				M_instr_type <= 4'b0000;
				M_ExcCode <= 5'd0;
		  end else if (E_M_REG_EN == 1'b1) begin
				M_PC <= E_PC;
				M_instr <= (E_ExcCode != 5'd0) ? 32'd0 : E_instr;
				M_RD2 <= E_RD2;
				M_DM_write <= (E_ExcCode != 5'd0) ? 1'b0 : E_DM_write;
				M_GRF_write <= (E_ExcCode != 5'd0) ? 1'b0 : E_GRF_write;
				M_CP0_write <= (E_ExcCode != 5'd0) ? 1'b0 : E_CP0_write;
				M_DMop <= E_DMop;
				M_ALUout <= E_ALUout;
				M_BEop <= E_BEop;
				M_MDUout <= E_MDUout;
				M_GRF_A3 <= E_GRF_A3;
				M_GRF_DatatoReg <= E_GRF_DatatoReg;
				M_CMP_result <= E_CMP_result;
				M_BD <= E_BD;
			   M_eret <= E_eret;
				M_instr_type <= (E_ExcCode != 5'd0) ? 4'b0000 : E_instr_type;
				M_ExcCode <= E_ExcCode;
				M_rs_Tuse <= E_rs_Tuse;
				M_rt_Tuse <= E_rt_Tuse;
	  			M_Tnew <= (E_Tnew == 4'd0) ? 4'd0 : (E_Tnew - 4'd1);
				
		  end
	 end


endmodule
