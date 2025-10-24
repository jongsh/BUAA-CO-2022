`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:26:49 10/05/2022 
// Design Name: 
// Module Name:    BlockChecker 
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
module BlockChecker(
    input clk,
    input reset,
    input [7:0] in,
    output result
    );
	 
	 reg [4:0] state;
	 reg [31:0] cnt_begin, cnt_end;
	 parameter s0 = 5'd0, s1 = 5'd1, s2 = 5'd2, s3 = 5'd3, s4 = 5'd4, s5 = 5'd5, s6 = 5'd6;
	 parameter s7 = 5'd7, s8 = 5'd8, s9 = 5'd9, s10 = 5'd10, s11 = 5'd11;
	 
	 
	 initial begin
	     cnt_begin = 32'd0;
		  cnt_end = 32'd0;
		  state = s0;
	 end
	  
	 always @(posedge clk or posedge reset) begin
	 
	     if (reset) begin
		      cnt_begin <= 32'd0;
				cnt_end <= 32'd0;
				state <= s0;
		  end else begin
		      case(state)
				    s0 : begin
					     if (in == "b" || in == "B") state <= s1;
						  else if (in == "E" || in == "e") state <= s6;
						  else if (in == " ") state <= s0;
						  else state <= s9;
					 end
					 s1 : begin
					     if (in == "E" || in == "e") state <= s2;
						  else if (in == " ") state <= s0;
						  else state <= s9;
					 end
					 s2 : begin
					     if (in == "g" || in == "G") state <= s3;
						  else if (in == " ") state <= s0;
						  else state <= s9;
					 end
					 s3 : begin
                    if (in == "i" || in == "I") state <= s4;
						  else if (in == " ") state <= s0;
						  else state <= s9;
					 end
					 s4 : begin
					     if (in == "n" || in == "N") begin
						      state <= s5;
								cnt_begin <= cnt_begin + 32'd1;
                    end else if (in == " ") state <= s0;
                    else state <= s9;					
					 end
					 s5 : begin
					     if (in == " ") begin 
						      state <= s0;
						  end
						  else begin
						      state <= s9;
								cnt_begin <= cnt_begin - 32'd1;
						  end
					 end
					 s6 : begin
					     if (in == "n" || in == "N") state <= s7;
						  else if (in == " ") state <= s0;
						  else state <= s9;
					 end
					 s7 : begin
					     if (in == "d" || in == "D") begin
						      if (cnt_end == cnt_begin) begin
								    state <= s10;
								end else begin
								    state <= s8;
									 cnt_end <= cnt_end + 32'd1;
								end
						  end else if (in == " ") state <= s0;
						  else state <= s9;
					 end
					 s8 : begin
					     if (in == " ") state <= s0;
						  else begin 
						      state <= s9;
								cnt_end <= cnt_end - 32'd1;
						  end
					 end
					 s9 : begin
					     if (in == " ") state <= s0;
						  else state <= s9;
					 end
					 s10 : begin
					     if (in == " ") state <= s11;
						  else begin
								state <= s9;
						  end
					 end
					 s11 : begin
					     state <= s11;
					 end
			   endcase
		  end
	 end
	 
	 assign result = (cnt_begin == cnt_end && state != s11 && state != s10) ? 1'b1 : 1'b0;
	 
endmodule
