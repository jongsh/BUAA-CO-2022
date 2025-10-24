`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:32:32 12/13/2022 
// Design Name: 
// Module Name:    DipSwitch 
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
module DipSwitch(
    input clk,
	 input reset,
	 input [31:0] Addr,
	 input [7:0] switch0,
	 input [7:0] switch1,
	 input [7:0] switch2,
	 input [7:0] switch3,
	 input [7:0] switch4,
	 input [7:0] switch5,
	 input [7:0] switch6,
	 input [7:0] switch7,
	 output [31:0] DSout
    );
	 
	 reg [31:0] data0;
	 reg [31:0] data1;
	 
	 // 0-3组对应0x7f60 ; 4-7组对应0x7f64
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin
		      data0 <= 32'd0;
				data1 <= 32'd0;
		  end else begin
		      data0 <= ~{switch3, switch2, switch1, switch0};
				data1 <= ~{switch7, switch6, switch5, switch4};
		  end
	 end
	 
	 assign DSout = (Addr == 32'h7f60) ? data0 : 
	                (Addr == 32'h7f64) ? data1 : 32'd0;


endmodule
