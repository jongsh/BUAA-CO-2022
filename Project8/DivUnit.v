`timescale 1ns / 1ps
`define  IDLE 2'b00
`define  MUL  2'b01
`define  DIV  2'b10
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:30:48 12/08/2022 
// Design Name: 
// Module Name:    DivUnit 
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
module DivUnit(
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
    wire negSrcBits [1:0];
    wire [31:0] absSrc [1:0];
    wire [63:0] absSrc64 [1:0];
    reg busy;
    reg [31:0] timer;
    reg [66:0] tmps [3:0];
    reg negResBits [1:0];
    wire [66:0] subs [2:0];
    wire[31:0] tmp[1:0];

    assign {negSrcBits[1], negSrcBits[0]} = {in_src1[31] & in_sign, in_src0[31] & in_sign};
    assign {absSrc[1], absSrc[0]} = {negSrcBits[1] ? -in_src1 : in_src1, negSrcBits[0] ? -in_src0 : in_src0};
    assign {absSrc64[1], absSrc64[0]} = {absSrc[1], 64'h0, absSrc[0]};
    assign {subs[2], subs[1], subs[0]} = {(tmps[0] << 2) - tmps[3], (tmps[0] << 2) - tmps[2], (tmps[0] << 2) - tmps[1]};
    assign {tmp[1], tmp[0]} = tmps[0][63:0];
    assign {out_res1, out_res0} = {negResBits[1] ? -tmp[1] : tmp[1], negResBits[0] ? -tmp[0] : tmp[0]};
    assign {in_ready, out_valid} = {!busy, !timer[1] & busy};

    always@(posedge clk) begin
        if(reset) begin
            {negResBits[1], negResBits[0], timer, tmps[3], tmps[2], tmps[1], tmps[0], busy} <= 0;
        end else if(in_valid & in_ready & in_op == `DIV) begin
            timer <= 32'hffffffff;
            {negResBits[1], negResBits[0]} <= {negSrcBits[0], negSrcBits[0] ^ negSrcBits[1]};
            {tmps[3], tmps[2], tmps[1], tmps[0]} <= {({3'b0, absSrc64[1]} << 1) + {3'b0, absSrc64[1]}, {3'b0, absSrc64[1]} << 1, {3'b0, absSrc64[1]}, {3'b0, absSrc64[0]}};
            busy <= 'b1;
        end else begin
            if(out_valid & out_ready) begin
                busy <= 'b0;
            end
            if(timer[15] & (tmps[0][47:16] < tmps[1][63:32])) begin
                timer <= timer >> 16;
                tmps[0] <= tmps[0] << 16;
            end 
            else if(timer[7] & (tmps[0][55:24] < tmps[1][63:32])) begin
                timer <= timer >> 8;
                tmps[0] <= tmps[0] << 8;
            end 
            else if(timer[3] & (tmps[0][59:28] < tmps[1][63:32])) begin
                timer <= timer >> 4;
                tmps[0] <= tmps[0] << 4;
            end 
            else if(timer[0]) begin
                timer <= timer >> 2;
                tmps[0] <= !subs[2][66] ? subs[2] + 'd3 : !subs[1][66] ? subs[1] + 'd2 : !subs[0][66] ? subs[0] + 'd1 : (tmps[0] << 2);
            end
        end
     end
endmodule
