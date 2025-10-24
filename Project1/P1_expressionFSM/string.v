`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:09:52 10/05/2022 
// Design Name: 
// Module Name:    string 
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
module string(
    input clk,
    input clr,
    input [7:0] in,
    output out
    );
	 reg [2:0] state;
	 parameter s0 = 2'b00, s1 = 2'b01, s2 = 2'b11;
	 
	 assign out = (state == s1) ? 1'b1 : 1'b0;
	 
	 always @(posedge clk or posedge clr) begin
	     if (clr == 1'b1) begin
				state <= s0;
		  end else begin
		      case(state)
				    s0 : state <= (in >= "0" && in <= "9") ? s1 : s2;
					 s1 : state <= (in == "+" || in == "*") ? s0 : s2;
					 s2 : state <= s2;
					 default : state <= s0;
			   endcase
		  end
	 end
	 


endmodule
