`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:43:05 11/13/2022 
// Design Name: 
// Module Name:    DM_CU 
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
module DM_CU(
    input [31:0] M_ALUout,
	 input [31:0] M_RD2,
	 input DM_write,
	 input [3:0] M_instr_type,
    input [1:0] M_DMop,
    output reg [3:0] M_byteen,
	 output reg [31:0] M_DM_WD,
	 output reg [4:0] ExcCode
    );
	 
	 parameter AdEL = 5'd4, AdES = 5'd5;
	 parameter store = 4'b0010, load = 4'b0011;
	 
	 reg exception;
	 wire inDM, inTC1, inTC0, inIG, inCount;
	 
///////////// ExcCode ///////////////////
    assign inDM = (M_ALUout >= 32'h0 && M_ALUout <= 32'h2fff);
	 assign inTC0 = (M_ALUout >= 32'h7f00 && M_ALUout <= 32'h7f0b);
	 assign inTC1 = (M_ALUout >= 32'h7f10 && M_ALUout <= 32'h7f1b);
	 assign inIG = (M_ALUout >= 32'h7f20 && M_ALUout <= 32'h7f23);
	 assign inCount = (M_ALUout == 32'h7f08) || (M_ALUout == 32'h7f18);

	 always @(*) begin
	     case(M_instr_type)
		  
		      load: begin
				          case (M_DMop)
							     2'b00: exception = (M_ALUout[1:0] != 2'b00) || (~inDM && ~inTC0 && ~inTC1 && ~inIG);
							     2'b01: exception = (M_ALUout[0] != 1'b0) || (inTC1 || inTC0) || (~inDM && ~inTC0 && ~inTC1 && ~inIG);
								  2'b10: exception = (inTC0 || inTC1) || (~inDM && ~inTC0 && ~inTC1 && ~inIG);
								  default : exception = 1'b0;
							 endcase
							 ExcCode = (exception) ? AdEL : 5'b0;
						end
				
				store: begin
				           case (M_DMop)
							      2'b00: exception = (M_ALUout[1:0] != 2'b00) || (~inDM && ~inTC0 && ~inTC1 && ~inIG) || inCount;
									2'b01: exception = (M_ALUout[0] != 1'b0) || (~inDM && ~inTC0 && ~inTC1 && ~inIG) || inCount || inTC0 || inTC1;
				               2'b10: exception = (~inDM && ~inTC0 && ~inTC1 && ~inIG) || inCount || inTC0 ||inTC1;
									default: exception = 1'b0;
							  endcase
							  ExcCode = (exception) ? AdES : 5'd0;
				       end
				
				default: begin
				             ExcCode = 5'd0;
								 exception = 1'b0;
				         end
		  endcase
	 end
	 
	 // W(00)¡¢H(01)¡¢B(10)
	 always @(*) begin
	     if (DM_write == 1'b1) begin
		      case(M_DMop) 
		           2'b00: begin
				                M_byteen = (exception == 1'b1) ? 4'b0000 : 4'b1111;
									 M_DM_WD = M_RD2;
						      end
			        2'b01: begin
					             M_DM_WD = (M_ALUout[1:0] == 2'b00) ? M_RD2 :
									           (M_ALUout[1:0] == 2'b10) ? {M_RD2[15:0], 16'd0} :
												                             32'd0;
																					  
				                M_byteen = (exception == 1'b1) ? 4'b0000 : 
									            (M_ALUout[1:0] == 2'b00) ? 4'b0011 :
									            (M_ALUout[1:0] == 2'b10) ? 4'b1100 : 
													                           4'b0000;
				            end
				     2'b10: begin
					             M_DM_WD = (M_ALUout[1:0] == 2'b00) ? M_RD2 :
									           (M_ALUout[1:0] == 2'b01) ? {16'd0, M_RD2[7:0], 8'd0} :
												  (M_ALUout[1:0] == 2'b10) ? {8'd0, M_RD2[7:0], 16'd0} :
												  (M_ALUout[1:0] == 2'b11) ? {M_RD2[7:0], 24'd0} :
													                           32'd0;
																						
				                M_byteen = (exception == 1'b1) ? 4'b0000 :
									            (M_ALUout[1:0] == 2'b00) ? 4'b0001 :
									            (M_ALUout[1:0] == 2'b01) ? 4'b0010 :
													(M_ALUout[1:0] == 2'b10) ? 4'b0100 :
													(M_ALUout[1:0] == 2'b11) ? 4'b1000 :
													                           4'b0000;
					         end
					  default : begin 
					                M_byteen = 4'b0000;
					                M_DM_WD = 32'd0;
                           end										 
 		  
		      endcase
		      
		  end else begin
		      M_byteen = 4'b0000;
		  end
	 end


endmodule
