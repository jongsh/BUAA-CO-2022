`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:00:18 10/10/2022 
// Design Name: 
// Module Name:    string2 
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
module string2(
    input clk,
    input clr,
    input [7:0] in,
    output out
    );
	 
	 parameter s0 = 2'b00, s1 = 2'b01, s2 = 2'b10;
	 reg [31:0] cnt;
	 reg [1:0] state;
	 
	 initial begin
	     cnt = 32'd0;
		  state = s0;
	 end
	 
	 always @(posedge clk or posedge clr) begin
	     if (clr) begin
		      state <= s0;
				cnt <= 32'd0;
		  end else begin
		      case(state) 
				    s0 : begin
					     if (in >= "0" && in <= "9") state <= s1;
						  else if (in == "(") begin
						      state <= s0;
								cnt <= cnt + 32'd1;
						  end else state <= s2;
					 end
					 s1 : begin
					     if (in >= "0" && in <= "9") state <= s2;
						  else if (in == "+" || in == "*") state <= s0;
						  else if (in == ")") begin
						      if (cnt == 32'd0) state <= s2;
								else begin
								    state <= s1;
									 cnt <= cnt - 32'd1;
							   end
						  end else state <= s2;
					 end
					 s2 : state <= s2;
					 default : state <= s0;
				endcase
		  end
	 end
	 
	 assign out = (state == s1 && cnt == 32'd0) ? 1'b1 : 1'b0;


endmodule
