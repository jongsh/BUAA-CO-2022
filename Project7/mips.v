`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:31:27 11/23/2022 
// Design Name: 
// Module Name:    mips 
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
module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据

    output [31:0] w_inst_addr     // W 级 PC
    );
	 
	 wire [5:0] HWInt;        // CPU 外部中断信号
	 wire TC1_IRQ, TC0_IRQ;   // Time1,Time0 中断信号
	 wire TC0_WE, TC1_WE;     // Time0,TIme1 使能
	 wire [31:0] TC0out;      // Time0 读出数据
	 wire [31:0] TC1out;      // Time1 读出数据
	 wire [3:0] CPU_byteen;   // CPU 对外设的写字节使能
	 wire [31:0] PrAddr;      // CPU 所需外设地址
	 wire [31:0] PrRD;        // 外设传递给 CPU 数据
	 wire [31:0] PrWD;        // CPU 写入外设的数据
	 wire [31:0] DevAddr;     // 外设写入地址
	 wire [31:0] DevWD;       // 外设写入数据
	 

///////////// Signs /////////
	 assign HWInt = {3'b000, interrupt, TC1_IRQ, TC0_IRQ};
	 assign m_data_wdata = DevWD;
	 assign m_data_addr = DevAddr;
	 assign m_int_addr = DevAddr;
	 
	 
///////////// PipleLine CPU /////////////////	
    CPU cpu (
    .clk(clk), 
    .reset(reset), 
    .i_inst_rdata(i_inst_rdata), 
    .m_data_rdata(PrRD), 
    .HWInt(HWInt), 
	 .MacroPC(macroscopic_pc),
    .i_inst_addr(i_inst_addr), 
    .m_data_addr(PrAddr), 
    .m_data_wdata(PrWD), 
    .m_data_byteen(CPU_byteen), 
    .m_inst_addr(m_inst_addr), 
    .w_grf_we(w_grf_we), 
    .w_grf_addr(w_grf_addr), 
    .w_grf_wdata(w_grf_wdata), 
    .w_inst_addr(w_inst_addr)
    );

////////// Bridge ////////////// 
    Bridge bridge (
    .PrAddr(PrAddr), 
    .PrWD(PrWD), 
    .byteen(CPU_byteen), 
    .PrRD(PrRD), 
    .DevAddr(DevAddr), 
    .DevWD(DevWD), 
    .m_int_byteen(m_int_byteen), 
    .m_data_byteen(m_data_byteen), 
    .m_data_rdata(m_data_rdata), 
    .TC0_WE(TC0_WE), 
    .TC0RD(TC0out), 
    .TC1_WE(TC1_WE), 
    .TC1RD(TC1out)
    );
	 
//////////// Time0 //////////////	 
	 TC TC0 (
    .clk(clk), 
    .reset(reset), 
    .Addr(DevAddr[31:2]), 
    .WE(TC0_WE), 
    .Din(DevWD), 
    .Dout(TC0out), 
    .IRQ(TC0_IRQ)
    );
	 
//////////// Time1 //////////////
	 TC TC1 (
    .clk(clk), 
    .reset(reset), 
    .Addr(DevAddr[31:2]), 
    .WE(TC1_WE), 
    .Din(DevWD), 
    .Dout(TC1out), 
    .IRQ(TC1_IRQ)
    );
	 
	 

endmodule
