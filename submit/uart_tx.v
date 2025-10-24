`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:27:57 12/11/2022 
// Design Name: 
// Module Name:    uart_tx 
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
module uart_tx (
    input wire clk,
    input wire rstn,
    input wire [15:0] period,
    input wire tx_start,        // 1 if outside wants to send data
    input wire [7:0] tx_data,   // data to be sent
    output wire txd,
    output wire tx_avai         // 1 if uart can send data
);
    localparam IDLE = 0, START = 1, WORK = 2, STOP = 3;

    reg [1:0] state;
    reg [7:0] data;         // a copy of 'tx_data', modified(right shift) at each sample point
    reg [2:0] bit_count;    // number of bits which is not sent

    wire count_en = state != IDLE;
    wire count_q;

    uart_count count (
        .clk(clk), .rstn(rstn), .period(period), .en(count_en), .q(count_q),
        .preset(16'b0) // no offset
    );

    // transmit
    always @(posedge clk) begin
        if (~rstn) begin
            state <= IDLE;
            data <= 0;
            bit_count <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (tx_start) begin
                        state <= START;
                        data <= tx_data;
                    end
                end
                START: begin
                    if (count_q) begin
                        state <= WORK;
                        bit_count <= 3'd7;
                    end
                end
                WORK: begin
                    if (count_q) begin
                        data <= {1'b0, data[7:1]}; // right shift
                        if (bit_count == 0) begin
                            state <= STOP;
                        end
                        else begin
                            bit_count <= bit_count - 3'd1;
                        end
                    end
                end
                STOP: begin
                    if (count_q) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    assign tx_avai = state == IDLE;
    assign txd = (state == IDLE || state == STOP) ? 1'b1 :
                 (state == START) ? 1'b0 : data[0];

endmodule
