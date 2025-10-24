`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:28:29 12/11/2022 
// Design Name: 
// Module Name:    uart_rx 
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
module uart_rx (
    input wire clk,
    input wire rstn,
    input wire [15:0] period,
    input wire rxd,
    input wire rx_clear,        // 1 if outside took or discarded the received data
    output reg [7:0] rx_data,   // data has been read
    output reg rx_ready         // 1 if 'uart_rx' has read complete data(a byte)
);
    localparam IDLE = 0, START = 1, WORK = 2, STOP = 3;

    wire count_en = state != IDLE;
    wire count_q;

    uart_count count (
        .clk(clk), .rstn(rstn), .period(period), .en(count_en), 
        .q(count_q), .preset(period >> 1) // half sample cycle offset
    );

    reg [1:0] state;
    reg [7:0] buffer;       // buffer for received bits
    reg [2:0] bit_count;    // number of bits which need to receive

    always @(posedge clk) begin
        if (~rstn) begin
            state <= 0;
            buffer <= 0;
            bit_count <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (~rxd) begin
                        state <= START;
                        buffer <= 0;
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
                        if (bit_count == 0) begin
                            state <= STOP;
                        end
                        else begin
                            bit_count <= bit_count - 3'd1;
                        end
                        buffer <= {rxd, buffer[7:1]};   // take received bit
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

    always @(posedge clk) begin
        if (~rstn) begin
            rx_data <= 0;
            rx_ready <= 0;
        end
        else begin
            if (rx_clear) begin
                rx_data <= 0;
                rx_ready <= 0;
            end
            else if (state == STOP && count_q) begin    // complete receiving
                rx_data <= buffer;
                rx_ready <= 1;
            end
        end
    end


endmodule
