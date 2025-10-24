`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:41:42 11/06/2022 
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
    input [31:0] ALU_opA,
    input [31:0] ALU_opB,
    input [4:0] ALU_opC,
	 input [3:0] type,
    input [4:0] ALUop,
    output [31:0] ALU_result,
	 output reg [4:0] ALU_ExcCode
    );
	 
	 parameter cal = 4'b0001, load = 4'b0011, store = 4'b0010;
	 parameter Ov = 5'd12, AdEL = 5'd4, AdES = 5'd5;
	 
	 wire [31:0] archshift;
	 wire [31:0] high;
	 wire [31:0] low;
	 wire Exception;
	 wire [32:0] temp;           // 用于判断溢出的中间变量
	 
	 
	 assign high = ($signed(ALU_opA) > $signed(ALU_opB));  // 有符号 A > B
 	 assign low = ($signed(ALU_opA) < $signed(ALU_opB));  // 有符号 A < B
	 assign archishift = $signed(ALU_opB) >>> $signed(ALU_opC);
	 
	 assign temp = (ALUop == 5'd0) ? ({ALU_opA[31],ALU_opA} + {ALU_opB[31],ALU_opB}) :
	                    (ALUop == 5'd1) ? ({ALU_opA[31],ALU_opA} - {ALU_opB[31],ALU_opB}) :
							                    33'd0;
	 assign Exception = (temp[31] != temp[32]) ? 1'b1 : 1'b0;
	 
	 
/////////////////////////// Judge ExcCode //////////////////
    
    always @(*) begin
        if (Exception == 1'b1) begin
            case(type)
				    cal:    ALU_ExcCode = Ov;
					 load:   ALU_ExcCode = AdEL;
					 store:  ALU_ExcCode = AdES;
					 default : ALU_ExcCode = 5'd0;
				endcase
        end else begin
            ALU_ExcCode = 5'd0;
        end		  
    end	 
	 
 
	// 00000：A+B； 00001：A-B； 00010：A或B； 00011：A与B； 00100：B逻辑右移C; 00101: B逻辑左移C; 00110: B算数右移C; 
	// 00111；A<?B有符号; 01000: A>?B有符号;  01001：A<?B无符号; 01010: A>?B无符号
	 assign ALU_result = (ALUop == 5'd0) ? (ALU_opA + ALU_opB) :
	                     (ALUop == 5'd1) ? (ALU_opA - ALU_opB) : 
								(ALUop == 5'd2) ? (ALU_opA | ALU_opB) :
								(ALUop == 5'd3) ? (ALU_opA & ALU_opB) :
								(ALUop == 5'd4) ? (ALU_opB >> ALU_opC) :
								(ALUop == 5'd5) ? (ALU_opB << ALU_opC) :
								(ALUop == 5'd6) ? archshift : 
								(ALUop == 5'd7) ? low :
								(ALUop == 5'd8) ? high :
								(ALUop == 5'd9) ? (ALU_opA < ALU_opB) :
								(ALUop == 5'd10) ? (ALU_opA > ALU_opB) :
								                  32'd0;
	 


endmodule
