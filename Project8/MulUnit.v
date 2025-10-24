`timescale 1ns / 1ps
`define  IDLE 2'b00
`define  MUL  2'b01
`define  DIV  2'b10
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:32:36 12/08/2022 
// Design Name: 
// Module Name:    MulUnit 
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
module MulUnit(
    input wire clk,
    input wire reset,
    input wire [31:0] in_src0,
    input wire [31:0] in_src1,
    input wire [1:0] in_op,
    input wire in_sign,
    output wire in_ready,
    input wire in_valid,
    input wire out_ready,
    output wire out_valid,
    output wire [31:0] out_res0,
    output wire [31:0] out_res1
);
    reg done;
    reg [63:0] tmp;
    wire signed [63:0] sr = $signed(in_src0) * $signed(in_src1);
    wire [63:0] usr = in_src0 * in_src1;

    assign {out_res1, out_res0, in_ready, out_valid} = {tmp, !done, done};

    always@(posedge clk) begin
        if(reset) begin
            done <= 'h0;
            tmp <= 'h0;
        end 
        else if(in_valid & in_ready & (in_op == `MUL)) begin
            tmp <= in_sign ? sr : usr;
            done <= 'h1;
        end 
        else if(out_valid & out_ready) begin
            tmp <= 'h0;
            done <= 'h0;
        end
    end
endmodule
