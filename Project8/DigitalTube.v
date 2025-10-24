`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:28:27 12/09/2022 
// Design Name: 
// Module Name:    DigitalTube 
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
module DigitalTube(
    input clk,
    input reset,
    input [3:0] byteen,	 
	 input [31:0] Addr,
	 input [31:0] WD,
	 output [7:0] digital_tube0,
    output [7:0] digital_tube1,
    output [7:0] digital_tube2,
    output [3:0] digital_tube_sel0,
    output [3:0] digital_tube_sel1,
    output digital_tube_sel2
    );

////////////////////////// Signals ///////////////////////////////
	 localparam PERIOD = 32'd25_000;   // 1ms
	 reg [31:0] fixedWD;
	 reg [15:0] data1, data0;
	 reg [31:0] counter;
    reg [1:0] select;

////////////////////// Function to Transform Data ////////////////////////
	 function [7:0] hex2dig;   // dp = 1
        input [3:0] hex;
        begin
            case (hex)
            4'h0    : hex2dig = 8'b1000_0001;   // not G
            4'h1    : hex2dig = 8'b1100_1111;   // B, C
            4'h2    : hex2dig = 8'b1001_0010;   // not C, F
            4'h3    : hex2dig = 8'b1000_0110;   // not E, F
            4'h4    : hex2dig = 8'b1100_1100;   // not A, D, E
            4'h5    : hex2dig = 8'b1010_0100;   // not B, E
            4'h6    : hex2dig = 8'b1010_0000;   // not B
            4'h7    : hex2dig = 8'b1000_1111;   // A, B, C
            4'h8    : hex2dig = 8'b1000_0000;   // All
            4'h9    : hex2dig = 8'b1000_0100;   // not E
            4'hA    : hex2dig = 8'b1000_1000;   // not D
            4'hB    : hex2dig = 8'b1110_0000;   // not A, B
            4'hC    : hex2dig = 8'b1011_0001;   // A, D, E, F
            4'hD    : hex2dig = 8'b1100_0010;   // not A, F
            4'hE    : hex2dig = 8'b1011_0000;   // not B, C
            4'hF    : hex2dig = 8'b1011_1000;   // A, E, F, G
            default : hex2dig = 8'b1111_1111;
            endcase
        end
    endfunction
	 
////////////////////////// Store Data //////////////////////////////

    always @(*) begin
	     fixedWD = {data1, data0};
		  if (byteen[3] == 1'b1) fixedWD[31:24] = WD[31:24];
		  if (byteen[2] == 1'b1) fixedWD[23:16] = WD[23:16];
		  if (byteen[1] == 1'b1) fixedWD[15:8]  = WD[15:8];
		  if (byteen[0] == 1'b1) fixedWD[7:0]   = WD[7:0];
	 end
	 
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin
		      data0 <= 16'd0;
				data1 <= 16'd0;
		  end else if (|byteen != 0 && Addr >= 32'h7f50 && Addr <= 32'h7f57)begin
		      {data1, data0} <= fixedWD;
		  end
	 end
	 
///////////////////////// Count ////////////////////////////////
    always @(posedge clk) begin
        if (reset) begin
            counter <= 0;
            select <= 0;
        end
        else begin
            if (counter + 1 == PERIOD) begin
                counter <= 0;
                select <= select + 1'b1;
            end 
            else begin
                counter <= counter + 1;
            end
        end
    end
	 
///////////////////////////// Output ///////////////////////////////
    
    assign tubeNum = {data1,data0};

    assign digital_tube2 = 8'b1111_1111;
	 assign digital_tube_sel2 = 1'b1;
	 
	 assign digital_tube0 = hex2dig(data0[select * 4 +: 4]);
	 assign digital_tube_sel0 = (4'b1 << select);
	 
	 assign digital_tube1 = hex2dig(data1[select * 4 +: 4]);
	 assign digital_tube_sel1 = (4'b1 << select);

endmodule
