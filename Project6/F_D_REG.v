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
    input [31:0] F_PC,
    input [31:0] F_instr,
    output reg [31:0] D_PC,
    output reg [31:0] D_instr
    );
	 
	 always @(posedge clk) begin
	      if (reset == 1'b1) begin   // 复位清空
			    D_PC <= 32'h00003000;
				 D_instr <= 32'd0;
			end else begin
			    if (F_D_REG_EN == 1'b1) begin
				     D_PC <= F_PC;
					  D_instr <= F_instr;
				 end else begin     // 保持不变
				     D_PC <= D_PC;
					  D_instr <= D_instr;
				 end
			end
	 end


endmodule
