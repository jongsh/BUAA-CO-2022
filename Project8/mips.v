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
	 input clk_in,
    input sys_rstn,
    // dip switch
    input [7:0] dip_switch0,
    input [7:0] dip_switch1,
    input [7:0] dip_switch2,
    input [7:0] dip_switch3,
    input [7:0] dip_switch4,
    input [7:0] dip_switch5,
    input [7:0] dip_switch6,
    input [7:0] dip_switch7,
    // key
    input [7:0] user_key,
    // led
    output [31:0] led_light,
    // digital tube
    output [7:0] digital_tube2,
    output digital_tube_sel2,
    output [7:0] digital_tube1,
    output [3:0] digital_tube_sel1,
    output [7:0] digital_tube0,
    output [3:0] digital_tube_sel0,
    // uart
    input uart_rxd,
    output uart_txd
    );
	 
	 wire reset;
	 wire clk;
	 
	 wire TC_IRQ;
	 wire interrupt;
	 wire [5:0] HWInt;        // CPU 外部中断信号
	 wire [3:0] CPU_byteen;   // CPU 对外设的写字节使能
	 wire [31:0] PrAddr;      // CPU 所需外设地址
	 wire [31:0] PrRD;        // 外设传递给 CPU 数据
	 wire [31:0] PrWD;        // CPU 写入外设的数据
	 wire [31:0] DevAddr;     // 外设写入地址
	 wire [31:0] DevWD;       // 外设写入数据
	 wire [31:0] IMAddr;
	 wire [31:0] IM_RD;
	 
	 wire [3:0] DM_byteen;
	 wire TC_WE;
	 wire [3:0] Tube_byteen;
	 wire [3:0] LED_byteen;
	 wire UART_EN;
	 wire [31:0] TC_RD;
	 wire [31:0] DM_RD;
	 wire [31:0] key_RD;
	 wire [31:0] DipSwitch_RD;
	 wire [31:0] UART_RD;
	

///////////// Signs /////////
    assign reset = ~sys_rstn;
	 assign clk = clk_in;
	 assign HWInt = {3'b000, interrupt, 1'b0, TC_IRQ};
	 
	 
///////////// PipleLine CPU /////////////////	
    CPU cpu (
    .clk(clk), 
    .reset(reset), 
    .i_inst_rdata(IM_RD), 
    .m_data_rdata(PrRD), 
    .HWInt(HWInt),
    .i_inst_addr(IMAddr), 
    .m_data_addr(PrAddr), 
    .m_data_wdata(PrWD), 
    .m_data_byteen(CPU_byteen)
    );

////////// Bridge ////////////// 
    Bridge bridge (
    .clk(clk), 
    .reset(reset), 
    .PrAddr(PrAddr), 
    .PrWD(PrWD), 
    .byteen(CPU_byteen), 
    .PrRD(PrRD), 
    .DevAddr(DevAddr), 
    .DevWD(DevWD), 
    .DM_byteen(DM_byteen), 
    .DM_RD(DM_RD), 
    .TC_WE(TC_WE), 
    .TC_RD(TC_RD), 
    .key_RD(key_RD), 
    .DipSwitch_RD(DipSwitch_RD), 
    .Tube_byteen(Tube_byteen), 
    .LED_byteen(LED_byteen), 
    .UART_EN(UART_EN), 
    .UART_RD(UART_RD)
    );

//////////// DM /////////////////
	 DM dm (
    .clka(clk), // input clka
    .wea(DM_byteen), // input [3 : 0] wea
    .addra(DevAddr[14:2]), // input [12 : 0] addra
    .dina(DevWD), // input [31 : 0] dina
    .douta(DM_RD) // output [31 : 0] douta
    );
//////////// IM ///////////////
    wire [31:0] IM_Addr;
	 assign IM_Addr = IMAddr - 32'h3000;
	 IM im (
    .clka(clk), // input clka
    .addra(IM_Addr[14:2]), // input [12 : 0] addra
    .douta(IM_RD) // output [31 : 0] douta
    );
//////////// Timer //////////////	 
	 TC timer (
    .clk(clk), 
    .reset(reset), 
    .Addr(DevAddr[31:2]), 
    .WE(TC_WE), 
    .Din(DevWD), 
    .Dout(TC_RD), 
    .IRQ(TC_IRQ)
    );	 
	 
/////////// Digital Tube /////////////
    DigitalTube DigitalTube (
    .clk(clk), 
    .reset(reset), 
    .byteen(Tube_byteen), 
    .Addr(DevAddr), 
    .WD(DevWD), 
    .digital_tube0(digital_tube0), 
    .digital_tube1(digital_tube1), 
    .digital_tube2(digital_tube2), 
    .digital_tube_sel0(digital_tube_sel0), 
    .digital_tube_sel1(digital_tube_sel1), 
    .digital_tube_sel2(digital_tube_sel2)
    );

//////////// Key ///////////////
    KEY key (
    .clk(clk), 
    .reset(reset), 
    .key_in(user_key), 
    .key_out(key_RD)
    );

////////// Dip Switch ////////////
    DipSwitch DipSwitch (
    .clk(clk), 
    .reset(reset), 
    .Addr(DevAddr), 
    .switch0(dip_switch0), 
    .switch1(dip_switch1), 
    .switch2(dip_switch2), 
    .switch3(dip_switch3), 
    .switch4(dip_switch4), 
    .switch5(dip_switch5), 
    .switch6(dip_switch6), 
    .switch7(dip_switch7), 
    .DSout(DipSwitch_RD)
    );

///////////// LED ////////////
    LED led (
    .clk(clk), 
    .reset(reset), 
    .byteen(LED_byteen), 
    .WD(DevWD), 
    .led_light(led_light)
    );
	 
//////////// UART ///////////
    UART uart (
    .clk(clk), 
    .reset(reset), 
    .WE(UART_EN), 
    .addr(DevAddr), 
    .WD(DevWD), 
    .rxd(uart_rxd), 
    .txd(uart_txd), 
    .RD(UART_RD), 
    .interrupt(interrupt)
    );


endmodule
