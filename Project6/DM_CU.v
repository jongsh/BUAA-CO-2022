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
    input [1:0] M_DMop,
    output reg [3:0] M_byteen,
	 output reg [31:0] M_DM_WD
    );
	 
	 // W(00)¡¢H(01)¡¢B(10)
	 always @(*) begin
	     if (DM_write == 1'b1) begin
		      case(M_DMop) 
		           2'b00: begin
				                M_byteen = 4'b1111;
									 M_DM_WD = M_RD2;
						      end
			        2'b01: begin
					             M_DM_WD = (M_ALUout[1:0] == 2'b00) ? M_RD2 :
									           (M_ALUout[1:0] == 2'b10) ? {M_RD2[15:0], 16'd0} :
												                             32'd0;
																					  
				                M_byteen = (M_ALUout[1:0] == 2'b00) ? 4'b0011 :
									            (M_ALUout[1:0] == 2'b10) ? 4'b1100 : 
													                           4'b0000;
				            end
				     2'b10: begin
					             M_DM_WD = (M_ALUout[1:0] == 2'b00) ? M_RD2 :
									           (M_ALUout[1:0] == 2'b01) ? {16'd0, M_RD2[7:0], 8'd0} :
												  (M_ALUout[1:0] == 2'b10) ? {8'd0, M_RD2[7:0], 16'd0} :
												  (M_ALUout[1:0] == 2'b11) ? {M_RD2[7:0], 24'd0} :
													                           32'd0;
				                M_byteen = (M_ALUout[1:0] == 2'b00) ? 4'b0001 :
									            (M_ALUout[1:0] == 2'b01) ? 4'b0010 :
													(M_ALUout[1:0] == 2'b10) ? 4'b0100 :
													(M_ALUout[1:0] == 2'b11) ? 4'b1000 :
													                           4'b0000;
					         end
					  default : M_byteen = 4'b0000;
 		  
		      endcase
		      
		  end else begin
		      M_byteen = 4'b0000;
		  end
	 end


endmodule
