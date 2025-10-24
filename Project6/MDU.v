`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:19:50 11/12/2022 
// Design Name: 
// Module Name:    MDU 
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
module MDU(
    input clk,
    input reset,
	 input start,
	 input [31:0] MDU_opA,
	 input [31:0] MDU_opB,
	 input [3:0] MDUop,
	 output reg busy,
	 output reg [31:0] HI,
	 output reg [31:0] LO
    );
	 
	 reg [5:0] times;
	 reg [31:0] tempHI;
    reg [31:0] tempLO;
	 
	 // 0000£ºÎÞ²Ù×÷£»0001£º·ûºÅ³Ë A*B£»0010£ºÎÞ·ûºÅ³Ë A*B£»0011£º·ûºÅ³ý A/B£» 
	 // 0100£ºÎÞ·ûºÅ³ý A/B£»0101£ºÐ´ HI ¼Ä´æÆ÷£»0110£ºÐ´ LO ¼Ä´æÆ÷
	 
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin
				HI <= 32'd0;
				LO <= 32'd0;
				tempHI <= 32'd0;
				tempLO <= 32'd0;
				times <= 6'd0;
				busy <= 1'b0;
		  end else begin
		      if (start == 1'b1) begin // µ±Ç°½øÈë E ¼¶Á÷Ë®Ö¸ÁîµÄ¿ØÖÆÐÅºÅstartÎª1
					 case(MDUop) 
					     4'b0001: begin  // ·ûºÅ³Ë
						               {HI, LO} <= $signed(MDU_opA) * $signed(MDU_opB);
											times <= 6'd4;
											busy <= 1'b1;
						           end
						  4'b0010: begin  // ÎÞ·ûºÅ³Ë
						               {HI, LO} <= {32'd0,MDU_opA} * {32'd0, MDU_opB};
											times <= 6'd4;
											busy <= 1'b1;
									  end
						  4'b0011: begin  // ·ûºÅ³ý
						               {HI,LO} <= {$signed(MDU_opA) % $signed(MDU_opB),$signed(MDU_opA) / $signed(MDU_opB)};
											times <= 6'd9;
											busy <= 1'b1;
									  end
						  4'b0100: begin  // ÎÞ·ûºÅ³ý
						               {HI,LO} <= {MDU_opA % MDU_opB, MDU_opA / MDU_opB};
											times <= 6'd9;
											busy <= 1'b1;
									  end
						  4'b0101: begin // Ð´ HI ¼Ä´æÆ÷
						               HI <= MDU_opA;
											times <= 6'd0;
											busy <= 1'b0;
									  end
						  4'b0110: begin // Ð´ LO ¼Ä´æÆ÷
						               LO <= MDU_opA;
						               times <= 6'd0;
					                  busy <= 1'b0;
						           end
						  default : begin
						               times <= 6'd0;
											busy <= 1'b0;
										end
						  
					 endcase
				end else if (busy == 1'b1) begin
				    if (times == 6'd0) begin
					     busy <= 1'b0;
					 end else begin
					     busy <= 1'b1;
						  times <= times - 6'd1;
					 end
					 
		     end
		 end
	 end
	 
	 


endmodule
