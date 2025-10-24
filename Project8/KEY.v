`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:10:20 12/13/2022 
// Design Name: 
// Module Name:    KEY 
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
module KEY(
    input clk,
	 input reset,
    input [7:0] key_in,
    output reg [31:0] key_out
    );
	 
	 always @(posedge clk) begin
	     if (reset) begin
		      key_out <= 32'd0;
		  end else begin
		      key_out <= {24'd0, ~key_in};
		  end
	 end

endmodule
