`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:40:53 11/23/2022 
// Design Name: 
// Module Name:    CP0 
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
`define IM SR[15:10]                // 对应六个中断位置使能端
`define EXL SR[1]                   // 发生任何异常时置位1，并禁止中断    
`define IE SR[0]                    // 全局中断使能，置 1 表示允许中断，置 0 表示禁止中断
`define BD Cause[31]                // 延迟槽标志
`define IP Cause[15:10]             // 6 位待决的中断位，分别对应 6 个外部中断，相应位置 1 表示有中断，置 0 表示无中断
`define ExcCode Cause[6:2]          // 异常编码

module CP0(
    input clk,
    input reset,
    input CP0_write,
    input [4:0] CP0_addr,
    input [31:0] CP0_in,     // CP0的写入数据
    input [31:0] EPC_in,     // 受害指令地址
    input BD_in,             // 标记受害指令是否是延迟槽指令
    input [4:0] ExcCodeIn,   // 记录中断异常类型
    input [5:0] HWInt,       // 中断信号
    input EXL_clr,           // EXL 复位信号
    output [31:0] CP0_out,   
    output [31:0] EPC_out,   
    output Req               // 中断处理信号
    );
	      
	 reg [31:0] SR;
	 reg [31:0] Cause;
	 reg [31:0] EPC;
	 
	 wire interrupt, exception;


////////////////////// Read CP0 Reg Data////////////////////////////
    assign CP0_out = (CP0_addr == 5'd12) ? SR :
	                  (CP0_addr == 5'd13) ? Cause :
							(CP0_addr == 5'd14) ? EPC :
							                      32'd0;
														 
	 assign  EPC_out = EPC;
	 
///////////////////// 判断中断异常////////////////////////////////////
	 assign interrupt = (((HWInt & `IM) != 6'd0) && (`EXL === 1'b0) && (`IE === 1'b1));
	 assign exception = (ExcCodeIn != 5'd0) ? 1'b1 : 1'b0;
	 assign Req = interrupt | exception;
	 
	 
//////////////////// updata CP0 ///////////////
    
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin
		      EPC <= 32'd0;
				SR <= 32'd0;
				Cause <= 32'd0;
		  end else begin
		      if (Req == 1'b1) begin
				    `ExcCode <= (interrupt == 1'b1) ? 5'd0 : ExcCodeIn;
					 `EXL <= 1'b1;
					 `BD <= BD_in;
					 EPC <= (BD_in == 1'b1) ? (EPC_in - 32'd4) : EPC_in;
				end
				if (CP0_write == 1'b1) begin
				    case(CP0_addr)
					     5'd12: SR <= CP0_in; 
						  5'd13: Cause <= CP0_in;
						  5'd14: EPC <= CP0_in;
					 endcase
				end
				if (EXL_clr == 1'b1) begin
				    `EXL <= 1'b0;
				end
		      `IP <= HWInt;
		  end
	 end
	 


endmodule
