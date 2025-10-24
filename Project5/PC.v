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
module PC(
    input clk,
    input reset,
    input F_PC_EN,
    input [31:0] F_PCnext,
    output reg [31:0] F_PC
    );
	 
	 always @(posedge clk) begin
        if (reset == 1'b1) begin
		      F_PC <= 32'h00003000;
		  end else begin
		      if (F_PC_EN == 1'b1) begin
				    F_PC <= F_PCnext;
				end else begin
				    F_PC <= F_PC;
				end
		  end
    end	 

endmodule
