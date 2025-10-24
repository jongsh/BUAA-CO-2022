`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:55:27 11/13/2022 
// Design Name: 
// Module Name:    BE 
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
module BE(
    input [31:0] M_BE_addr,
    input [31:0] M_BE_in,
    input [2:0] M_BEop,
    output reg [31:0] M_BEout
    );
	 
	 // 000：无扩展；001：无符号字节数据扩展；010：符号字节数据扩展；011：无符号半字数据扩展；100：符号半字数据扩展
	 always @(*) begin
	     case(M_BEop)
		  
		      3'b000: begin
				            M_BEout = M_BE_in;
						  end
				3'b001: begin
				            M_BEout = (M_BE_addr[1:0] == 2'b00) ? {24'd0, M_BE_in[7:0]} :
								          (M_BE_addr[1:0] == 2'b01) ? {24'd0, M_BE_in[15:8]} :
											 (M_BE_addr[1:0] == 2'b10) ? {24'd0, M_BE_in[23:16]} :
											 (M_BE_addr[1:0] == 2'b11) ? {24'd0, M_BE_in[31:24]} :
											                             32'd0;
						  end
				3'b010: begin
				            M_BEout = (M_BE_addr[1:0] == 2'b00) ? {{24{M_BE_in[7]}}, M_BE_in[7:0]} :
								          (M_BE_addr[1:0] == 2'b01) ? {{24{M_BE_in[15]}}, M_BE_in[15:8]} :
											 (M_BE_addr[1:0] == 2'b10) ? {{24{M_BE_in[23]}}, M_BE_in[23:16]} :
											 (M_BE_addr[1:0] == 2'b11) ? {{24{M_BE_in[31]}}, M_BE_in[31:24]} :
											                             32'd0;
				        end
				3'b011: begin
				            M_BEout = (M_BE_addr[1:0] == 2'b00) ? {16'd0, M_BE_in[15:0]} :
								          (M_BE_addr[1:0] == 2'b10) ? {16'd0, M_BE_in[31:16]} :
											                             32'd0;
				        end
				3'b100: begin
				            M_BEout = (M_BE_addr[1:0] == 2'b00) ? {{16{M_BE_in[15]}}, M_BE_in[15:0]} :
								          (M_BE_addr[1:0] == 2'b10) ? {{16{M_BE_in[31]}}, M_BE_in[31:16]} :
											                             32'd0;
		              end
		  endcase
	 end

endmodule
