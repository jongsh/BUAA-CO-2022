`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:39:41 11/25/2022 
// Design Name: 
// Module Name:    Bridge 
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
module Bridge(
    input clk,
	 input reset,
    //// CPU ///
    input [31:0] PrAddr,  // 外设写地址
    input [31:0] PrWD,    // 外设写数据
    input [3:0] byteen,   // 字节使能信号
	 output [31:0] PrRD,   // 从外设读入的数据
	 
	 //// IO ////
	 output [31:0] DevAddr,  // 外设写入地址，通用
	 output [31:0] DevWD,    // 外设写入数据，通用
	 
	 ///// DM /////
	 output [3:0] DM_byteen,  // 数据存储器字节使能
	 input [31:0] DM_RD,   // 数据存储器读出的数据
	 
	 ///// TC ////////
	 output TC_WE,          // TC0 写使能
	 input [31:0] TC_RD,     // TC0 读出的数据
	 
	 ///// key //////
	 input [31:0] key_RD,
	 
	 ////// DipSwitch /////
	 input [31:0] DipSwitch_RD,
	 
	 ///// digitalTube ////////
	 output [3:0] Tube_byteen,
	 
	 ///// LED ///////
	 output [3:0] LED_byteen,
	 
	 //// UART ///////
	 output UART_EN,
	 input [31:0] UART_RD
    );
	 
	 wire inDM, inTC, inKey, inSwitch, inTube, inLED, inUART;
	 assign inDM = (PrAddr >= 32'h0000 && PrAddr <= 32'h2fff);
	 assign inTC = (PrAddr >= 32'h7f00 && PrAddr <= 32'h7f0b);
	 assign inKey = (PrAddr >= 32'h7f68 && PrAddr <= 32'h7f6b);
	 assign inSwitch = (PrAddr >= 32'h7f60 && PrAddr <= 32'h7f67);
	 assign inTube = (PrAddr >= 32'h7f50 && PrAddr <= 32'h7f57);
	 assign inLED = (PrAddr >= 32'h7f70 && PrAddr <= 32'h7f73);
	 assign inUART = (PrAddr >= 32'h7f30 && PrAddr <= 32'h7f3f);
	 
	 assign DevAddr = PrAddr;
	 assign DevWD = PrWD;
	 
	 
	 assign DM_byteen = (inDM == 1'b1) ? byteen : 4'b0000;
	 assign TC_WE = (inTC) ? |byteen : 1'b0;
	 assign Tube_byteen = (inTube) ? byteen : 4'b0000;
	 assign UART_EN = (inUART) ? |byteen : 1'b0;
	 assign LED_byteen = (inLED) ? byteen : 4'b0000;
	 
//////////////// CPU //////////////////////
    reg [31:0] reg_RD;
	 reg sel;
	 
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin
		      reg_RD <= 32'd0;
				sel <= 1'b0;
		  end else begin
		      reg_RD <= (inTC)     ? TC_RD :
				          (inKey)    ? key_RD :
							 (inSwitch) ? DipSwitch_RD :
							 (inUART)   ? UART_RD :
                                   32'd0;		
            sel <= (inDM) ? 1'b0 : 1'b1;											  
		  end
	 end
	 
	 assign PrRD = (sel == 1'b0) ? DM_RD : reg_RD;


endmodule
