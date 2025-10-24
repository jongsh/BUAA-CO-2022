`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:20:56 11/06/2022 
// Design Name: 
// Module Name:    F_D_REG 
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
module F_D_REG(
    input clk,
    input reset,
    input F_D_REG_EN,
	 input Req,
	 input F_BD,
	 input eret,
	 input [4:0]F_ExcCode,
    input [31:0] F_PC,
    input [31:0] F_instr,
	 output reg D_BD,
	 output reg [4:0] D_ExcCode,
    output reg [31:0] D_PC,
    output [31:0] D_instr
    );
	 
	 reg [31:0] D_instr_temp;
	 reg sel;
	 
	 always @(posedge clk) begin
	      if (reset == 1'b1) begin   // ¸´Î»Çå¿Õ
			    D_PC <= 32'h3000;
				 D_instr_temp <= 32'd0;
				 sel <= 1'b0;
				 D_ExcCode <= 5'd0;
				 D_BD <= 1'b0;
			end else if (Req == 1'b1) begin
			    D_PC <= 32'h4180;
				 D_instr_temp <= 32'd0;
				 sel <= 1'b0;
				 D_ExcCode <= 5'd0;
				 D_BD <= 1'b0;
			end else if (F_D_REG_EN == 1'b1) begin
			    D_PC <= F_PC;
				 D_BD <= F_BD;
				 D_ExcCode <= F_ExcCode;
				 sel <= (F_ExcCode == 5'd0 && eret == 1'b0) ? 1'b1 : 1'b0;
				 D_instr_temp <= 32'd0;
			end else begin
			    D_instr_temp <= D_instr;
				 sel <= 1'b0;
			end
	 end
	 
	 assign D_instr = (sel == 1'b1) ? F_instr : D_instr_temp;

endmodule
