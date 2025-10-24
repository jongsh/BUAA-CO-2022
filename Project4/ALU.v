`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:41:10 10/26/2022 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input [31:0] operationA,
    input [31:0] operationB,
    input [4:0] shamtC,
    input [2:0] ALUop,
    input [2:0] CMPop,
    output [31:0] ALUresult,
    output CMPresult
    );
	 wire larger;
	 wire litter;
	 wire [31:0] archshift;
	 assign larger = ($signed(operationA) > $signed(operationB)) ? 1'b1 : 1'b0;
	 assign litter = ($signed(operationA) < $signed(operationB)) ? 1'b1 : 1'b0;
	 assign archshift = $signed(operationB) >>> $signed(shamtC);
	 
	 assign CMPresult = (CMPop == 3'b000) ? (operationA == operationB) :
	                    (CMPop == 3'b001) ? litter :
							  (CMPop == 3'b010) ? larger :
							  (CMPop == 3'b011) ? (operationA < operationB) :
							  (CMPop == 3'b100) ? (operationA > operationB) :
							  (CMPop == 3'b101) ? (operationA != operationB) :
							  1'b0;
	
	 assign ALUresult = (ALUop == 3'b000) ? (operationA + operationB) :
	                    (ALUop == 3'b001) ? (operationA - operationB) :
							  (ALUop == 3'b010) ? (operationA | operationB) :
							  (ALUop == 3'b011) ? (operationA & operationB) :
							  (ALUop == 3'b100) ? (operationB >> shamtC) :
							  (ALUop == 3'b101) ? (operationB << shamtC) :
							  (ALUop == 3'b110) ? archshift :
							  32'd0;


endmodule
