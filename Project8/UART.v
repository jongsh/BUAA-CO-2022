`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:37:51 12/14/2022 
// Design Name: 
// Module Name:    UART 
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
module UART(
    input clk,
	 input reset,
	 input WE,
	 input [31:0] addr,
	 input [31:0] WD,
	 input rxd,
	 output txd,
	 output [31:0] RD,
	 output interrupt
    );
	 
	 parameter IDLE = 2'b00, READ = 2'b01, SEND = 2'b10;
	 
	 wire rstn;  // 低电平有效复位信号
	 reg [31:0] data;  // [7:0] RData, [23:16] WData
	 reg [31:0] state;
	 wire [31:0] DIVR;
	 wire [31:0] DIVT;
	 
	 wire tx_avai;     // 1 if uart can send data
	 wire rx_ready;    // 1 if 'uart_rx' has read complete data(a byte)
	 reg  tx_start;
	 wire rx_clear;
	 wire [7:0] tx_data, rx_data;
	 
	 assign rstn = ~reset;
	 assign DIVR = 32'd2604;
	 assign DIVT = 32'd2604;


	 
    uart_tx uart_tx (
    .clk(clk), 
    .rstn(rstn), 
    .period(DIVR[15:0]), 
    .tx_start(tx_start), 
    .tx_data(tx_data), 
    .txd(txd), 
    .tx_avai(tx_avai)
    );
	 
	 uart_rx uart_rx (
    .clk(clk), 
    .rstn(rstn), 
    .period(DIVT[15:0]), 
    .rxd(rxd), 
    .rx_clear(rx_clear), 
    .rx_data(rx_data), 
    .rx_ready(rx_ready)
    );
	 
///////////// REG /////////////
    always @(posedge clk) begin
	     if (reset == 1'b1) begin
		      data <= 32'd0;
				state <= 32'd1;
		  end else begin
		      data[7:0] <= rx_data;
				if (WE == 1'b1) begin
				    data[23:16] <= WD[23:16];
				end
				state[0] <= tx_avai;
				tx_start <= (WE == 1'b1) ? 1'b1 : 1'b0;
		  end
	 end
	 
//////////// Signals //////////////
	 assign rx_clear = (addr == 32'h7f30) ? 1'b1 : 1'b0;
	 assign tx_data = data[23:16];
	 
///////////// output /////////////////
    assign RD = (addr[31:2] == 30'h1fcc) ? data :
	             (addr[31:2] == 30'h1fcd) ? state :
					                      32'd0;
	 assign interrupt = rx_ready;
	 
endmodule
