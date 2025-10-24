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
    //// CPU ///
    input [31:0] PrAddr,  // 外设写地址
    input [31:0] PrWD,    // 外设写数据
    input [3:0] byteen,   // 字节使能信号
	 output [31:0] PrRD,   // 从外设读入的数据
	 
	 //// IO ////
	 output [31:0] DevAddr,  // 外设写入地址，通用
	 output [31:0] DevWD,    // 外设写入数据，通用
	 
	 ///// IG /////////
	 output [3:0] m_int_byteen,   // 中断发生器字节使能
	 
	 ///// DM /////
	 output [3:0] m_data_byteen,  // 数据存储器字节使能
	 input [31:0] m_data_rdata,   // 数据存储器读出的数据
	 
	 ///// TC0 ////////
	 output TC0_WE,          // TC0 写使能
	 input [31:0] TC0RD,     // TC0 读出的数据
	 
	 ///// TC1 /////
	 output TC1_WE,          // TC1 写使能
	 input [31:0] TC1RD             // TC1 读出的数据
    );
	 
	 wire inDM, inTC0, inTC1, inIG;
	 assign inDM = (PrAddr >= 32'h0 && PrAddr <= 32'h2fff);
	 assign inTC0 = (PrAddr >= 32'h7f00 && PrAddr <= 32'h7f0b);
	 assign inTC1 = (PrAddr >= 32'h7f10 && PrAddr <= 32'h7f1b);
	 assign inIG = (PrAddr >= 32'h7f20 && PrAddr <= 32'h7f23);
	 
	 assign DevAddr = PrAddr;
	 assign DevWD = PrWD;
	 
	 /////// CPU ///////////
	 assign PrRD = (inDM) ? m_data_rdata :
	               (inTC0) ? TC0RD :
						(inTC1) ? TC1RD : 
						          32'd0;
	 
	 
	 /////// IO ////////////////
	 assign m_data_byteen = (inDM) ? byteen : 4'b0000;
	 assign m_int_byteen = (inIG) ? byteen : 4'b0000;
	 assign TC0_WE = (inTC0) ? byteen : 4'b0000;
	 assign TC1_WE = (inTC1) ? byteen : 4'b0000;

endmodule
