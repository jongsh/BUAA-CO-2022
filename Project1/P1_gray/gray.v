`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:36:34 10/05/2022 
// Design Name: 
// Module Name:    gray 
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
module gray(
    input Clk,
    input Reset,
    input En,
    output reg Overflow,
    output [2:0] Output
    );
	 
	 reg [2:0] cnt;
	 
	 assign Output = cnt;
	 
	 initial begin
	     cnt = 3'd0;
		  Overflow = 1'b0;
	 end
	 
	 always @(posedge Clk) begin
	     if (Reset == 1'b1) begin
		      Overflow <= 1'b0;
				cnt <= 3'd0;
		  end else begin
		      if (En == 1'b0) cnt <= cnt;
				else begin
				    case(cnt)
					     3'b000 : cnt <= 3'b001;
						  3'b001 : cnt <= 3'b011;
						  3'b011 : cnt <= 3'b010;
						  3'b010 : cnt <= 3'b110;
						  3'b110 : cnt <= 3'b111;
						  3'b111 : cnt <= 3'b101;
						  3'b101 : cnt <= 3'b100;
						  3'b100 : begin
						      Overflow <= 1'b1;
								cnt <= 3'b000;
						  end
						  default : cnt <= 3'd0;
					 endcase
				end
		  end
		  
	 end
	 

endmodule
