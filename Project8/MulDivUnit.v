`timescale 1ns / 1ps
`define  IDLE 2'b00
`define  MUL  2'b01
`define  DIV  2'b10
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:29:21 12/08/2022 
// Design Name: 
// Module Name:    MulDivUnit 
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
module MulDivUnit(
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
    wire [31:0] mul_out_res [1:0];
    wire [31:0] div_out_res [1:0];
    reg [1:0] op;
    
    always@(posedge clk) begin
        if(reset)
            op  <= 'h0;
        else if(in_ready & in_valid)
            op <= in_op;
        else if(out_ready & out_valid)
            op <= 'h0;
    end

    MulUnit MulUnit(
        .clk(clk), 
        .reset(reset), 
        .in_src0(in_src0),
        .in_src1(in_src1),
        .in_op(in_op), 
        .in_sign(in_sign), 
        .in_ready(mul_in_ready), 
        .in_valid(in_valid), 
        .out_ready(out_ready), 
        .out_valid(mul_out_valid), 
        .out_res0(mul_out_res[0]),
        .out_res1(mul_out_res[1])
    );
            
    DivUnit DivUnit(
        .clk(clk), 
        .reset(reset), 
        .in_src0(in_src0),
        .in_src1(in_src1),
        .in_op(in_op), 
        .in_sign(in_sign), 
        .in_ready(div_in_ready), 
        .in_valid(in_valid), 
        .out_ready(out_ready), 
        .out_valid(div_out_valid), 
        .out_res0(div_out_res[0]),
        .out_res1(div_out_res[1])
    );
    
    assign in_ready = mul_in_ready & div_in_ready;
    assign out_valid = mul_out_valid | div_out_valid;
    assign {out_res1, out_res0} = (op == `DIV) ? {div_out_res[1], div_out_res[0]} :{mul_out_res[1], mul_out_res[0]};
endmodule
