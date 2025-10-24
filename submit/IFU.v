`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:47:36 11/06/2022 
// Design Name: 
// Module Name:    PC 
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
module IFU(
    input clk,
    input reset,
    input F_IFU_EN,
	 input Req,
    input [31:0] F_PCnext,
    output reg [31:0] F_PC,
	 output reg [4:0] F_ExcCode
    );
	 
	 wire flag;
	 parameter AdEL = 5'd4;
	 assign flag = ((F_PCnext[1:0] != 2'b00) || (F_PCnext < 32'h3000) || (F_PCnext > 32'h6ffc)) ? 1'b1 : 1'b0;
	 
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin           
		      F_PC <= 32'h3000;
				F_ExcCode <= 5'd0;
		  end else if (Req == 1'b1) begin   // M 级指令异常，下一个上升沿写入0x4180
		      F_PC <= 32'h4180;
		      F_ExcCode <= 5'd0;
		  end else if (F_IFU_EN == 1'b1) begin
		      F_PC <= F_PCnext;
				F_ExcCode <= flag ? AdEL : 5'd0;
		  end else begin
		      F_PC <= F_PC;
				F_ExcCode <= F_ExcCode;
		  end
		  
	 end
	 	 

endmodule
