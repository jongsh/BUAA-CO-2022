`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:42:30 11/06/2022 
// Design Name: 
// Module Name:    M_W_REG 
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
module M_W_REG(
    input clk,
    input reset,
	 input Req,
    input M_W_REG_EN,
	 input [31:0] M_PC,
	 input [31:0] M_instr,
	 input [31:0] M_ALUout,
	 input [4:0] M_GRF_A3,
	 input [31:0] M_DMout,
	 input M_GRF_write,
	 input [3:0] M_GRF_DatatoReg,
	 input [31:0] M_CMP_result,
	 input [31:0] M_MDUout,
	 input [31:0] M_CP0_EPC,
	 input [31:0] M_CP0out,
	 input [2:0] M_BEop,
	 input [3:0] M_rs_Tuse,
	 input [3:0] M_rt_Tuse,
	 input [3:0] M_Tnew,
	 output reg [31:0] W_PC,
	 output reg [31:0] W_instr,
	 output reg [31:0] W_ALUout,
	 output reg [4:0] W_GRF_A3,
	 output wire [31:0] W_DMout,
	 output reg W_GRF_write,
	 output reg [3:0] W_GRF_DatatoReg,
	 output reg [31:0] W_CMP_result,
	 output reg [31:0] W_MDUout,
	 output reg [31:0] W_CP0out,
	 output reg [2:0] W_BEop,
	 output reg [31:0] W_CP0_EPC,
	 output reg [3:0] W_rs_Tuse,
	 output reg [3:0] W_rt_Tuse,
	 output reg [3:0] W_Tnew
    );
	 
	 assign W_DMout = M_DMout;
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin
		      W_PC <= 32'h3000;
				W_instr <= 32'd0;
				W_GRF_write <= 1'b0;
		  end else if (Req == 1'b1) begin
		      W_PC <= 32'h4180;
				W_instr <= 32'd0;
				W_GRF_write <= 1'b0;
		  end else if (M_W_REG_EN == 1'b1) begin
				W_PC <= M_PC;
				W_instr <= M_instr; 
				W_ALUout <= M_ALUout;
				W_GRF_A3 <= M_GRF_A3;
				W_GRF_write <= M_GRF_write;
				W_GRF_DatatoReg <= M_GRF_DatatoReg;
				W_CMP_result <= M_CMP_result;
				W_MDUout <= M_MDUout;
				W_CP0out <= M_CP0out;
				W_BEop <= M_BEop;
				W_CP0_EPC <= M_CP0_EPC;
				W_rs_Tuse <= M_rs_Tuse;
				W_rt_Tuse <= M_rt_Tuse;
				W_Tnew <= (M_Tnew == 4'd0) ? 4'd0 : (M_Tnew - 4'd1);
		  end
	 end

endmodule
