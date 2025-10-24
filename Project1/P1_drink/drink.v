`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:27:28 10/10/2022 
// Design Name: 
// Module Name:    drink 
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
module drink(
    input clk,
    input reset,
    input [1:0] coin,
    output drink,
    output reg [1:0] back
    );
	 
	 reg [1:0] cnt;
	 reg [2:0] state;
	 parameter s0 = 3'd0, s1 = 3'd1, s2 = 3'd2, s3 = 3'd3, s4 = 3'd4, s5 = 3'd5;
	 
	 initial begin
	     cnt <= 2'd0;
		  state <= s0;
	 end
	 
	 always @(posedge clk or posedge reset) begin
	     if (reset == 1'b1) begin
		      cnt <= 2'd0;
				state <= s0;
				back <= 2'd0;
		  end else begin
		      
		      case(state)
				    s0 : begin
					     if (coin == 2'b00) begin
						      back <= 2'd0;
						      state <= s0;
						  end
						  else if (coin == 2'b01) begin
						      back <= 2'd0;
						      cnt <= cnt + coin;
								state <= s1;
						  end else if (coin == 2'b10) begin
						      cnt <= cnt + coin;
						      state <= s2;
								back <= 2'd0;
						  end else begin
						      back <= cnt;
								cnt <= 2'd0;
								state <= s0;
						  end
					 end
					 s1 : begin
					     if (coin == 2'b00) begin
						      state <= s1;
								back <= 2'd0;
						  end
						  else if (coin == 2'b01) begin
						      cnt <= cnt + coin;
								state <= s2;
								back <= 2'd0;
						  end else if (coin == 2'b10) begin
						      cnt <= cnt + coin;
						      state <= s3;
								back <= 2'd0;
						  end else begin
						      back <= cnt;
								cnt <= 2'd0;
								state <= s0;
						  end
					 end
					 s2 : begin
					     if (coin == 2'b00) begin
						      state <= s2;
								back <= 2'd0;
						  end
						  else if (coin == 2'b01) begin
						      cnt <= cnt + coin;
								state <= s3;
								back <= 2'd0;
						  end else if (coin == 2'b10) begin
						      cnt <= 2'd0;
						      state <= s4;
								back <= 2'd0;
						  end else begin
						      back <= cnt;
								cnt <= 2'd0;
								state <= s0;
						  end
					 end
					 s3 : begin
					     if (coin == 2'b00) begin
						      state <= s3;
								back <= 2'd0;
						  end
						  else if (coin == 2'b01) begin
						      cnt <= 2'd0;
								state <= s4;
								back <= 2'd0;
						  end else if (coin == 2'b10) begin
						      state <= s5;
								back <= 2'b01;
								cnt <= 2'd0;
						  end else begin
						      back <= cnt;
								cnt <= 2'd0;
								state <= s0;
						  end
					 end
					 s4 : begin
					     if (coin == 2'b00) begin
						      state <= s0;
								back <= 2'd0;
						  end
						  else if (coin == 2'b01) begin
						      cnt <= cnt + coin;
								state <= s1;
								back <= 2'd0;
						  end else if (coin == 2'b10) begin
						      cnt <= cnt + coin;
						      state <= s2;
								back <= 2'd0;
						  end else begin
						      back <= cnt;
								cnt <= 2'd0;
								state <= s0;
						  end
					 end
					 s5 : begin
					     if (coin == 2'b00) begin
						      state <= s0;
								back <= 2'd0;
					     end
						  else if (coin == 2'b01) begin
						      cnt <= cnt + coin;
								state <= s1;
								back <= 2'd0;
						  end else if (coin == 2'b10) begin
						      cnt <= cnt + coin;
						      state <= s2;
								back <= 2'd0;
						  end else begin
						      back <= cnt;
								cnt <= 2'd0;
								state <= s0;
						  end
					 end
					 default : begin
					     state <= s0;
						  back <= 2'd0;
				   end
			 endcase
	     end
	 end
	 
	 assign drink = (state == s4 || state == s5) ? 1'b1 : 1'b0;


endmodule
