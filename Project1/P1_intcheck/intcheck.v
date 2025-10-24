`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:09:44 10/10/2022 
// Design Name: 
// Module Name:    intcheck 
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
module intcheck(
    input clk,
    input reset,
    input [7:0] in,
    output out
    );
	 parameter s0 = 3'd0, s1 = 3'd1, s2 = 3'd2, s3 = 3'd3, s4 = 3'd4, s5 = 3'd5, s6 = 3'd6;
	 parameter nothing = 256'd0;
	 reg [255:0] str;
	 reg [2:0]state;
	 
	 assign out = (state == s5) ? 1'b1 : 1'b0;
	 
	 initial begin
	     state = s0;
		  str = nothing;
	 end
	 
	 always @(posedge clk) begin
	     if (reset) begin
		      state <= s0;
		      str <= 256'd0;
		  end else begin
		      case(state)
				        s6 : begin
						           state <= s6;
								     str <= nothing;
								 end
				        s0 : begin
						           if (in == " " || in == "	") begin
								         str <= nothing;
									      state <= s0;
								     end else if (in == "i") begin
								         state <= s1;
									      str[7:0] <= in;
									  end else begin
											state <= s6;
									  end
						       end
						  s1 : begin
								     if (in >= "a" && in <= "z") begin
								         state <= s1;
									      str <= (str<<8) + in;
								     end else if (in == " " || in == "	") begin
								         if ((str ^ "int") == 256'd0) begin
										       state <= s2;
											    str <= nothing;
										   end else begin
										       state <= s6;
											    str <= nothing;
										   end
								     end else begin
								         state <= s6;
									      str <= nothing;
								     end
						       end
						  s2 : begin
						           if (in == " " || in == "	") begin
									      state <= s2;
									  end else if ((in >= "a" && in <= "z") || (in >= "A" && in <= "Z") || in == "\0" || in == "\t" || in == "_") begin
									      str[7:0] = in;
											state <= s3;
									  end else state <= s6;
								 end
						  s3 : begin
						           if (in >= "0" && in <= 9) begin
									      state <= s3;
											str <= (str<<8) + in;
									  end else if ((in >= "a" && in <= "z") || (in >= "A" && in <= "Z") || in == "\0" || in == "\t" || in == "_") begin
									      state <= s3;
											str <= (str<<8) + in;
									  end else if (in == " " || in == "	") begin
									      if ((str ^ "int") != 256'd0) begin
											    state <= s4;
												 str <= nothing;
											end else begin
											    state <= s6;
												 str <= nothing;
											end
									  end else if (in == ";") begin
									      if ((str ^ "int") != 256'd0) begin
											    state <= s5;
												 str <= nothing;
											end else begin
											    state <= s6;
												 str <= nothing;
											end
									  end else if (in == ",") begin
									       if ((str ^ "int") != 256'd0) begin
									           state <= s2;
											     str <= nothing;
											 end else begin
											     state <= s6;
												  str <= nothing;
											 end
									  end else begin
									      state <= s6;
											str <= nothing;
									  end
						       end
						  s4 : begin
						           if (in == " " || in == "	") begin
									      state <= s4;
									  end else if (in == ",") begin
									       state <= s2;
											 str <= nothing;
									  end else if (in == ";")begin
									      state <= s5;
										   str <= nothing;
									  end else state <= s6;
						       end
						  s5 : begin
						           if (in == " " || in == "	") begin
									      state <= s0;
											str <= nothing;
									  end else if (in == "i") begin
									      state <= s1;
											str[7:0] <= in; 
									  end else begin
									      state <= s6;
									  end
								 end
 			   endcase
		  end
	 end
endmodule
