`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:26:18 12/11/2022 
// Design Name: 
// Module Name:    uart 
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
module uart_count (
    input wire clk,
    input wire rstn,
    input wire en,
    input wire [15:0] period,
    input wire [15:0] preset,   // preset value
    output wire q
);

    reg [15:0] count;

    always @(posedge clk) begin
        if (~rstn) begin
            count <= 0;
        end
        else begin
            if (en) begin
                if (count + 16'd1 == period) begin
                    count <= 16'd0;
                end
                else begin
                    count <= count + 16'd1;
                end
            end
            else begin
                count <= preset;
            end
        end
    end

    assign q = count + 16'd1 == period;

endmodule
