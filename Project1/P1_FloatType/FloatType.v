`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:14:17 10/10/2022 
// Design Name: 
// Module Name:    FloatType 
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
module FloatType(
    input [31:0] num,
    output reg [4:0] type
    );
	 
	 always @(*) begin
	     if (num[30:23] == 8'd0) begin
		      if (num[22:0] == 23'd0) begin
				    type = 5'b00001;
				end else begin
				    type = 5'b00100;
				end
		  end else if (num[30:23] == -8'd1) begin
		      if (num[22:0] == 23'd0) begin
				    type = 5'b01000;
				end else begin
				    type = 5'b10000;
				end
		  end else begin
		      type = 5'b00010;
		  end
	 end

endmodule
