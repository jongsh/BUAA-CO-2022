`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:46:14 11/06/2022 
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
module CPU(
    input clk,
    input reset,
    input [31:0] i_inst_rdata,
    input [31:0] m_data_rdata,
	 input [5:0] HWInt,
    output [31:0] i_inst_addr,
    output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3 :0] m_data_byteen,
    output w_grf_we,
    output [4:0] w_grf_addr,
    output [31:0] w_grf_wdata,
    output [31:0] w_inst_addr,
	 output [31:0] MacroPC
    );
	 
//////////////////////// 冲突控制单元 /////////////////////////////////

	 wire [31:0] F_PC;           // F 级指令地址
	 wire [31:0] D_PC;           // D 级指令地址
	 wire [31:0] E_PC;           // E 级指令地址
	 wire [31:0] M_PC;           // M 级指令地址
	 wire [31:0] W_PC;           // W 级指令地址
	 wire [3:0] D_rs_Tuse;       // D 级指令rs_Tuse
	 wire [3:0] D_rt_Tuse;       // D 级指令rt_Tuse
	 wire [3:0] D_Tnew;          // D 级指令Tnew
	 wire [3:0] E_rs_Tuse;       // E 级指令rs_Tuse
	 wire [3:0] E_rt_Tuse;       // E 级指令rt_Tuse
	 wire [3:0] E_Tnew;          // E 级指令Tnew
	 wire [3:0] M_rs_Tuse;       // M 级指令rs_Tuse
	 wire [3:0] M_rt_Tuse;       // M 级指令rt_Tuse
	 wire [3:0] M_Tnew;          // M 级指令Tnew
	 wire [3:0] W_rs_Tuse;       // W 级指令rs_Tuse
	 wire [3:0] W_rt_Tuse;       // W 级指令rt_Tuse
	 wire [3:0] W_Tnew;          // W 级指令Tnew
	 wire D_GRF_write;           // D 级指令GRF写信号
	 wire E_GRF_write;           // E 级指令GRF写信号
	 wire M_GRF_write;           // M 级指令GRF写信号
	 wire W_GRF_write;           // W 级指令GRF写信号
	 wire [4:0] D_GRF_A3;        // D 级指令目标寄存器
	 wire [3:0] D_GRF_DatatoReg; // D 级指令写数据选择信号
	 wire [4:0] E_GRF_A3;        // E 级指令目标寄存器
	 wire [3:0] E_GRF_DatatoReg; // E 级指令写数据选择信号
	 wire [4:0] M_GRF_A3;        // M 级指令目标寄存器
	 wire [3:0] M_GRF_DatatoReg; // M 级指令写数据选择信号
	 wire [4:0] W_GRF_A3;        // W 级指令目标寄存器
	 wire [3:0] W_GRF_DatatoReg; // W 级指令写数据选择信号
	 wire [2:0] D_FW_EPC_sel;    // D 级指令NPC输入EPC的转发信号
	 wire [4:0] D_FW_rs_sel;     // D 级指令rs数据转发信号
	 wire [4:0] D_FW_rt_sel;     // D 级指令rt数据转发信号
	 wire [4:0] E_FW_rs_sel;     // E 级指令rs数据转发信号
	 wire [4:0] E_FW_rt_sel;     // E 级指令rt数据转发信号
	 wire [4:0] M_FW_rt_sel;     // M 级指令rt数据转发信号
	 wire stall;                 // 阻塞信号
	 wire E_flush;               // E 级流水线寄存器清空信号
	 wire D_MDU_start;           // D 级指令 MDU 的开始信号
	 wire E_MDU_start;           // E 级指令 MDU 的开始信号
	 wire E_MDU_busy;            // E 级指令 MDU 的工作信号
	 
	 wire [31:0] F_instr;       // F 级指令机器码
	 wire [31:0] D_instr;       // D 级指令机器码
	 wire [31:0] E_instr;       // E 级指令机器码
	 wire [31:0] M_instr;       // M 级指令机器码
	 wire [31:0] W_instr;       // W 级指令机器码
	 
	 HCU hcu (
    .D_instr(D_instr), 
    .E_instr(E_instr), 
    .M_instr(M_instr), 
    .D_rs_Tuse(D_rs_Tuse), 
    .D_rt_Tuse(D_rt_Tuse), 
    .E_rs_Tuse(E_rs_Tuse), 
    .E_rt_Tuse(E_rt_Tuse), 
    .E_Tnew(E_Tnew), 
    .M_rt_Tuse(M_rt_Tuse), 
    .M_Tnew(M_Tnew), 
    .W_Tnew(W_Tnew), 
    .E_GRF_write(E_GRF_write), 
    .M_GRF_write(M_GRF_write), 
    .W_GRF_write(W_GRF_write), 
    .E_GRF_A3(E_GRF_A3), 
    .M_GRF_A3(M_GRF_A3), 
    .W_GRF_A3(W_GRF_A3), 
    .M_GRF_DatatoReg(M_GRF_DatatoReg), 
    .E_GRF_DatatoReg(E_GRF_DatatoReg), 
    .W_GRF_DatatoReg(W_GRF_DatatoReg), 
    .E_MDU_busy(E_MDU_busy), 
    .E_MDU_start(E_MDU_start), 
    .D_FW_EPC_sel(D_FW_EPC_sel), 
    .D_FW_rs_sel(D_FW_rs_sel), 
    .D_FW_rt_sel(D_FW_rt_sel), 
    .E_FW_rs_sel(E_FW_rs_sel), 
    .E_FW_rt_sel(E_FW_rt_sel), 
    .M_FW_rt_sel(M_FW_rt_sel), 
    .stall(stall), 
    .E_flush(E_flush)
    );
	 
///////////////////////// Fetch stage	/////////////////////////////////////

	 wire [31:0] F_PCnext;         			// D 级PC模块输入值，连接NPC的输出端
	 wire F_IFU_EN;              				// PC 使能信号
	 wire [4:0] F_ExcCode_temp;            
	 wire [4:0] F_ExcCode;
	 wire Req;                             // 中断异常信号
	 wire D_eret, E_eret, M_eret;          // eret 标记
	 wire F_BD, D_BD, E_BD, M_BD;          // 延迟槽标记
	 wire [3:0] D_instr_type;              // D 级指令类型
	 wire [3:0] E_instr_type;              // E 级指令类型
	 wire [3:0] M_instr_type;              // M 级指令类型
	 
	 assign F_IFU_EN = ~stall;
	 
	 IFU ifu (
    .clk(clk), 
    .reset(reset), 
    .F_IFU_EN(F_IFU_EN), 
    .Req(Req),
    .F_PCnext(F_PCnext), 
    .F_PC(i_inst_addr), 
    .F_ExcCode(F_ExcCode_temp)
    );
	 
	 assign F_PC = (D_eret == 1'b1) ? D_PC : i_inst_addr;
	 assign F_BD = (Req) ? 1'b0 :
	               (D_instr_type == 4'b0100) ? 1'b1 : 1'b0;
	 assign F_ExcCode = (D_eret == 1'b1) ? 5'd0 : F_ExcCode_temp;
	 
	 assign F_instr = i_inst_rdata;
	 
	 
////////////////////////////// Decode stage ////////////////////////////////////
    
	 wire [31:0] D_instr_temp;
	 wire [4:0] D_instr_rs;           // D 级指令rs段
	 wire [4:0] D_instr_rt;           // D 级指令rt段  
	 wire [4:0] D_instr_rd;           // D 级指令rd段
	 wire [5:0] D_instr_op;           // D 级指令opcode段
	 wire [5:0] D_instr_func;         // D 级指令functioncode段
	 wire [4:0] D_instr_shamt;        // D 级指令shamt段
	 wire [15:0] D_instr_imm16;       // D 级指令16位立即数
	 wire [25:0] D_instr_imm26;       // D 级指令26位立即数
	 wire [31:0] W_GRF_WD;            // W 级最终写入GRF的数据
	 wire [31:0] D_GRF_RD1;           // D 级指令从GRF读出的第一个数据，未转发
	 wire [31:0] D_GRF_RD2;           // D 级指令从GRF读出的第二个数据，未转发
	 wire [31:0] D_EXT_imm32;         // D 级指令EXT模块的32位立即数扩展输出
	 wire D_DM_write;                 // D 级指令DM写信号
	 wire [3:0] D_EXTop;              // D 级指令的EXT控制信号
	 wire [3:0] D_NPCop;              // D 级指令的NPC控制信号
	 wire [3:0] D_CMPop;              // D 级指令的CMP控制信号
	 wire [4:0] D_ALUop;              // D 级指令的ALU控制信号   
    wire [2:0] D_ALU_Bsel;           // D 级指令 ALU 操作数B选择信号	 
	 wire [2:0] D_GRF_A3_sel;         // D 级指令目的寄存器选择信号
	 wire [1:0] D_DMop;               // D 级指令的DM控制信号
	 wire [3:0] D_MDUop;              // D 级指令的MDU控制信号
	 wire D_MDUout_sel;               // D 级指令的MDUout选择信号
	 wire [2:0] D_BEop;               // D 级指令的BE控制信号
	 wire [31:0] D_RD1;               // D 级指令从GRF读出的第一个数据，已转发
	 wire [31:0] D_RD2;               // D 级指令从GRF读出的第二个数据，已转发
	 wire [31:0] D_CMP_result;        // D 级指令CMP比较结果
	 wire [4:0] D_CU_ExcCode;         // D 级指令 CU 译码得到的异常码
	 wire D_CP0_write;                // D 级指令的 CP0 写信号
	 
	 wire F_D_REG_EN;                 // D 流水线寄存器使能信号
	 wire [31:0] D_NPC_EPC;           // D 级 NPC 的输入EPC，已转发
	 wire [4:0] D_ExcCode_temp;       // D 级流水线寄存器得到的异常码
	 wire [4:0] D_ExcCode;            // D 级指令异常码
	 
	 assign F_D_REG_EN = ~stall;
	 assign D_instr_rs = D_instr[25:21];
	 assign D_instr_rt = D_instr[20:16];
	 assign D_instr_rd = D_instr[15:11];
	 assign D_instr_shamt = D_instr[10:6];
	 assign D_instr_imm16 = D_instr[15:0];
	 assign D_instr_imm26 = D_instr[25:0];
	 assign D_instr_op = D_instr[31:26];
	 assign D_instr_func = D_instr[5:0];
	 
	 
	 F_D_REG F_D_reg (
    .clk(clk), 
    .reset(reset), 
    .F_D_REG_EN(F_D_REG_EN), 
    .Req(Req), 
    .F_BD(F_BD), 
	 .eret(D_eret),
    .F_ExcCode(F_ExcCode), 
    .F_PC(F_PC), 
    .F_instr(F_instr), 
    .D_BD(D_BD), 
    .D_ExcCode(D_ExcCode_temp), 
    .D_PC(D_PC), 
    .D_instr(D_instr)
    );
	 
	 CU cu (
    .D_instr(D_instr), 
    .D_GRF_write(D_GRF_write), 
    .D_DM_write(D_DM_write), 
    .D_EXTop(D_EXTop), 
    .D_CMPop(D_CMPop), 
    .D_NPCop(D_NPCop), 
    .D_ALUop(D_ALUop), 
    .D_GRF_DatatoReg(D_GRF_DatatoReg), 
    .D_GRF_A3_sel(D_GRF_A3_sel), 
    .D_ALU_Bsel(D_ALU_Bsel), 
    .D_DMop(D_DMop), 
    .D_MDUop(D_MDUop), 
    .D_MDU_start(D_MDU_start), 
    .D_MDUout_sel(D_MDUout_sel), 
    .D_BEop(D_BEop), 
    .D_instr_type(D_instr_type), 
    .D_CU_ExcCode(D_CU_ExcCode), 
    .D_eret(D_eret), 
    .D_CP0_write(D_CP0_write), 
    .D_rs_Tuse(D_rs_Tuse), 
    .D_rt_Tuse(D_rt_Tuse), 
    .D_Tnew(D_Tnew)
    );
	 
	 assign D_ExcCode = (D_ExcCode_temp != 5'd0) ? D_ExcCode_temp :
	                    (D_CU_ExcCode != 5'd0) ? D_CU_ExcCode :
							                           5'd0;
	 
	 assign w_grf_we = W_GRF_write;
	 assign w_grf_addr = W_GRF_A3;
	 assign w_grf_wdata = W_GRF_WD;
	 assign w_inst_addr = W_PC;
	 
	 GRF grf (
    .clk(clk), 
    .reset(reset), 
    .GRF_write(W_GRF_write), 
    .GRF_A1(D_instr_rs), 
    .GRF_A2(D_instr_rt), 
    .GRF_A3(W_GRF_A3), 
    .GRF_WD(W_GRF_WD), 
    .GRF_RD1(D_GRF_RD1), 
    .GRF_RD2(D_GRF_RD2)
    );
	 
	 // 00000: keep; 00001: E_PC+8; 00010: E_CMP_result; 00011: M_PC+8; 00100: M_ALUout; 00101: M_CMP_result; 00110: M_MDUout
	 assign D_RD1 = (D_FW_rs_sel == 5'd0) ? D_GRF_RD1 :
	                (D_FW_rs_sel == 5'd1) ? E_PC + 32'd8 :
						 (D_FW_rs_sel == 5'd2) ? E_CMP_result :
						 (D_FW_rs_sel == 5'd3) ? M_PC + 32'd8 :
						 (D_FW_rs_sel == 5'd4) ? M_ALUout :
						 (D_FW_rs_sel == 5'd5) ? M_CMP_result :
						 (D_FW_rs_sel == 5'd6) ? M_MDUout :
						                         D_GRF_RD1;
														 
    assign D_RD2 = (D_FW_rt_sel == 5'd0) ? D_GRF_RD2 :
	                (D_FW_rt_sel == 5'd1) ? E_PC + 32'd8 :
						 (D_FW_rt_sel == 5'd2) ? E_CMP_result :
						 (D_FW_rt_sel == 5'd3) ? M_PC + 32'd8 :
						 (D_FW_rt_sel == 5'd4) ? M_ALUout :
						 (D_FW_rt_sel == 5'd5) ? M_CMP_result :
						 (D_FW_rt_sel == 5'd6) ? M_MDUout :
						                         D_GRF_RD2;
	 
	 EXT ext (
    .D_EXT_imm16(D_instr_imm16), 
    .D_EXTop(D_EXTop), 
    .D_EXT_imm32(D_EXT_imm32)
    );
	 
	 CMP cmp (
    .D_CMP_opA(D_RD1), 
    .D_CMP_opB(D_RD2), 
    .D_CMPop(D_CMPop), 
    .D_CMP_result(D_CMP_result)
    );
	 
	 assign D_NPC_EPC = (D_FW_EPC_sel == 3'b010) ? E_RD2_new :
	                    (D_FW_EPC_sel == 3'b001) ? M_RD2_new :
							                             W_CP0_EPC;
	 
	 NPC npc (
    .D_NPC_PC(F_PC), 
    .D_NPCop(D_NPCop), 
    .D_NPC_imm16(D_instr_imm16), 
    .D_NPC_imm26(D_instr_imm26), 
    .D_CMP_result(D_CMP_result), 
    .D_NPC_RegData(D_RD1), 
    .D_NPC_EPC(D_NPC_EPC), 
    .D_NPC_PCnext(F_PCnext)
    );
	 
	 // 000：rd；001：rt；010：31号寄存器
	 assign D_GRF_A3 = (D_GRF_A3_sel == 3'd0) ? D_instr_rd :
	                   (D_GRF_A3_sel == 3'd1) ? D_instr_rt :
							 (D_GRF_A3_sel == 3'd2) ? 5'd31 :
							                          5'd0;
	 
//////////////////////////////// Execute stage /////////////////////////////////////////

	 wire [31:0] E_RD1;                 // E 级的第一个寄存器数据,未转发
	 wire [31:0] E_RD2;                 // E 级的第二个寄存器数据，未转发
	 wire [31:0] E_RD2_new;             // E 级的第二个寄存器数据，已转发
	 wire [31:0] E_RD1_new;             // E 级的第一个寄存器数据，已转发
	 wire [31:0] E_ALU_opA;             // E 级指令ALU第一个操作数，经过转发和选择
	 wire [31:0] E_ALU_opB;             // E 级指令ALU第二个操作数，经过转发和选择
	 wire [4:0] E_ALUop;                // E 级指令的ALU控制信号
	 wire E_DM_write;                   // E 级指令DM写信号
	 wire [31:0] E_EXT_imm32;           // E 级指令EXT模块的32位立即数扩展输出
	 wire [31:0] E_CMP_result;          // E 级指令CMP比较结果
	 wire [2:0] E_ALU_Bsel;             // E 级指令 ALU 操作数B选择信号
	 wire [1:0] E_DMop;                 // E 级指令的DM控制信号
	 wire [4:0] E_instr_shamt;          // E 级指令shamt段
	 wire [31:0] E_ALUout;              // E 级指令的ALU计算结果
	 wire [2:0] E_BEop;                 // E 级指令BE控制信号
	 wire E_MDUout_sel;                 // E 级指令的MDUout选择信号
	 wire [3:0] E_MDUop;                // E 级指令的MDU功能选择信号
	 wire [31:0] E_MDUout;              // E 级指令的MDU输出结果
	 wire [31:0] M_MDUout;              // M 级指令MDU输出结果
	 wire [31:0] W_MDUout;              // W 级指令MDU计算结果
	 reg  [31:0] E_MDU_HI;              // MDU HI 寄存器
	 reg  [31:0] E_MDU_LO;              // MDU LO 寄存器
	 wire E_CP0_write;                  // E 级指令的CP0写信号
	 wire [4:0] E_ExcCode_temp;         // E 级流水线寄存器传递的异常码 
	 wire [4:0] E_ExcCode;              // E 级指令的异常码
	 wire [4:0] E_ALU_ExcCode;          // E 级ALU得到的异常码
	 
	 
	 //00000: keep; 00001: M_ALUout; 00010: M_PC+8; 00011: M_CMP_result; 00100: M_MDUout; 00101: W_ALUout; 
	 // 00110: W_DMout; 00111: W_PC+8; 01000: W_CMP_result; 01001: W_MDUout; 01010: W_CP0out
	 assign E_RD2_new = (E_FW_rt_sel == 5'd0) ? E_RD2 :
	                    (E_FW_rt_sel == 5'd1) ? M_ALUout :
							  (E_FW_rt_sel == 5'd2) ? M_PC + 32'd8 :
							  (E_FW_rt_sel == 5'd3) ? M_CMP_result :
							  (E_FW_rt_sel == 5'd4) ? M_MDUout :
							  (E_FW_rt_sel == 5'd5) ? W_ALUout :
							  (E_FW_rt_sel == 5'd6) ? W_DMout :
							  (E_FW_rt_sel == 5'd7) ? W_PC+ 32'd8 :
                       (E_FW_rt_sel == 5'd8) ? W_CMP_result:
							  (E_FW_rt_sel == 5'd9) ? W_MDUout :
							  (E_FW_rt_sel == 5'd10)? W_CP0out :
                                               E_RD2;
															  
	 assign E_RD1_new = (E_FW_rs_sel == 5'd0) ? E_RD1 :
	                    (E_FW_rs_sel == 5'd1) ? M_ALUout :
							  (E_FW_rs_sel == 5'd2) ? M_PC + 32'd8 :
							  (E_FW_rs_sel == 5'd3) ? M_CMP_result :
							  (E_FW_rs_sel == 5'd4) ? M_MDUout :
							  (E_FW_rs_sel == 5'd5) ? W_ALUout :
							  (E_FW_rs_sel == 5'd6) ? W_DMout :
							  (E_FW_rs_sel == 5'd7) ? W_PC+ 32'd8 :
                       (E_FW_rs_sel == 5'd8) ? W_CMP_result:
							  (E_FW_rs_sel == 5'd9) ? W_MDUout :
							  (E_FW_rs_sel == 5'd10)? W_CP0out :
                                               E_RD1;
															  
	 assign E_ALU_opA = E_RD1_new;
	 // 000：RD2 001：扩展后的32位立即数												  
    assign E_ALU_opB	= (E_ALU_Bsel == 3'd0) ? E_RD2_new :
                       (E_ALU_Bsel == 3'd1) ? E_EXT_imm32 :
                                              32'd0;							  
	 
	 D_E_REG D_E_reg (
    .clk(clk), 
    .reset(reset), 
    .Req(Req), 
    .flush(E_flush), 
    .D_E_REG_EN(1'b1), 
    .D_PC(D_PC), 
    .D_instr(D_instr), 
    .D_ALUop(D_ALUop), 
    .D_DM_write(D_DM_write), 
    .D_GRF_write(D_GRF_write), 
    .D_CP0_write(D_CP0_write), 
    .D_RD1(D_RD1), 
    .D_RD2(D_RD2), 
    .D_instr_shamt(D_instr_shamt), 
    .D_EXT_imm32(D_EXT_imm32), 
    .D_GRF_A3(D_GRF_A3), 
    .D_CMP_result(D_CMP_result), 
    .D_GRF_DatatoReg(D_GRF_DatatoReg), 
    .D_ALU_Bsel(D_ALU_Bsel), 
    .D_DMop(D_DMop), 
    .D_MDU_start(D_MDU_start), 
    .D_MDUout_sel(D_MDUout_sel), 
    .D_MDUop(D_MDUop), 
    .D_BEop(D_BEop), 
    .D_BD(D_BD), 
    .D_eret(D_eret), 
    .D_ExcCode(D_ExcCode), 
    .D_instr_type(D_instr_type), 
    .D_rs_Tuse(D_rs_Tuse), 
    .D_rt_Tuse(D_rt_Tuse), 
    .D_Tnew(D_Tnew), 
    .E_PC(E_PC), 
    .E_instr(E_instr), 
    .E_ALUop(E_ALUop), 
    .E_DM_write(E_DM_write), 
    .E_GRF_write(E_GRF_write), 
    .E_CP0_write(E_CP0_write), 
    .E_RD1(E_RD1), 
    .E_RD2(E_RD2), 
    .E_instr_shamt(E_instr_shamt), 
    .E_EXT_imm32(E_EXT_imm32), 
    .E_GRF_A3(E_GRF_A3), 
    .E_CMP_result(E_CMP_result), 
    .E_GRF_DatatoReg(E_GRF_DatatoReg), 
    .E_ALU_Bsel(E_ALU_Bsel), 
    .E_MDU_start(E_MDU_start), 
    .E_MDUout_sel(E_MDUout_sel), 
    .E_MDUop(E_MDUop), 
    .E_BEop(E_BEop), 
    .E_DMop(E_DMop), 
    .E_BD(E_BD), 
    .E_eret(E_eret), 
    .E_instr_type(E_instr_type), 
    .E_ExcCode(E_ExcCode_temp), 
    .E_rs_Tuse(E_rs_Tuse), 
    .E_rt_Tuse(E_rt_Tuse), 
    .E_Tnew(E_Tnew)
    );

	 ALU alu (
    .ALU_opA(E_ALU_opA), 
    .ALU_opB(E_ALU_opB), 
    .ALU_opC(E_instr_shamt), 
    .type(E_instr_type), 
    .ALUop(E_ALUop), 
    .ALU_result(E_ALUout), 
    .ALU_ExcCode(E_ALU_ExcCode)
    );
	 
	 assign E_ExcCode = (E_ExcCode_temp != 5'd0) ? E_ExcCode_temp :
	                    (E_ALU_ExcCode != 5'd0)  ? E_ALU_ExcCode :
							                             5'd0;
																  
	 
	 wire [1:0] MDU_in_op;                  // E 级指令修改后的控制信号
	 wire MDU_in_sign;                      // 0：无符号计算、1：有符号计算
	 wire MDU_in_valid;                     // 请求信号
	 wire MDU_ready;
	 wire MDU_out_valid;
	 wire [31:0] MDU_out_HI;
	 wire [31:0] MDU_out_LO;
	 
	 assign MDU_in_valid = E_MDU_start & ~Req;
	 assign MDU_in_sign = (E_MDUop == 4'b0001 || E_MDUop == 4'b0011) ? 1'b1 : 1'b0;
	 assign MDU_in_op = (E_MDUop == 4'b0001 || E_MDUop == 4'b0010) ? 2'b01 :
	                    (E_MDUop == 4'b0011 || E_MDUop == 4'b0100) ? 2'b10 :
							                                               2'b00;
	 assign E_MDU_busy = ~MDU_ready;
	 
	 
	 
	 MulDivUnit mdu (
    .clk(clk), 
    .reset(reset), 
    .in_src0(E_RD1_new), 
    .in_src1(E_RD2_new), 
    .in_op(MDU_in_op), 
    .in_sign(MDU_in_sign), 
    .in_ready(MDU_ready), 
    .in_valid(MDU_in_valid), 
    .out_ready(1'b1), 
    .out_valid(MDU_out_valid), 
    .out_res0(MDU_out_LO), 
    .out_res1(MDU_out_HI)
    );
	 
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin
		      E_MDU_LO <= 32'd0;
				E_MDU_HI <= 32'd0;
		  end else if (E_MDUop == 4'b0101) begin  // mthi
            E_MDU_HI <= E_RD1_new;
				E_MDU_LO <= E_MDU_LO;
		  end else if (E_MDUop == 4'b0110) begin  // mtlo
		      E_MDU_LO <= E_RD1_new;
				E_MDU_HI <= E_MDU_HI;
		  end else if (MDU_out_valid) begin
		      E_MDU_LO <= MDU_out_LO;
				E_MDU_HI <= MDU_out_HI;
		  end else begin
		      E_MDU_LO <= E_MDU_LO;
				E_MDU_HI <= E_MDU_HI;
		  end
	 end
	 
	 // 0：HI 寄存器；1：LO 寄存器
	 assign E_MDUout = (E_MDUout_sel == 1'b0) ? E_MDU_HI :
	                   (E_MDUout_sel == 1'b1) ? E_MDU_LO :
							                          32'd0;
	 
///////////////////////////////////// Memory stage //////////////////////////////////

	 wire [31:0] M_RD2;                // M 级指令的第二个寄存器数据，未转发
	 wire [31:0] M_RD2_new;            // M 级指令的第二个寄存器数据，已转发
	 wire [31:0] M_DM_WD;              // M 级指令DM写数据
	 wire M_DM_write;                  // M 级指令的DM写信号
	 wire M_CP0_write;                 // M 级指令的CP0写信号
	 wire [1:0] M_DMop;                // M 级指令的DM控制信号
	 wire [31:0] M_ALUout;             // M 级指令的ALU计算结果
	 wire [31:0] M_CMP_result;         // M 级指令CMP比较结果
	 wire [31:0] M_DMout;              // M 级指令读出的DM数据
	 wire [2:0] M_BEop;                // M 级指令BE控制信号
	 wire [31:0] M_BE_in;              // M 级 BE 模块的输入
	 wire [31:0] M_CP0_EPC;            // M 级 CP0 模块的EPC输出
	 wire [31:0] M_CP0out;             // M 级指令读出的CP0数据
	 wire [4:0] M_ExcCode_temp;        // M 级流水线寄存器传递的异常码
    wire [4:0] M_ExcCode;             // M 级指令异常码  
    wire [4:0] M_DM_ExcCode;          // M 级DM得到的的异常码	
    wire [3:0] M_byteen_temp; 
	 
	 
	 wire [31:0] W_ALUout;          // W 级指令的ALU计算结果 
	 wire [31:0] W_DMout;           // W 级指令DM数据
	 wire [31:0] W_CMP_result;      // W 级指令CMP比较结果
	 wire [31:0] W_CP0_EPC;         // W 级指令的EPC
	 wire [31:0] W_CP0out;          // W 级指令CP0数据
	 wire [2:0] W_BEop;
	 
	 // 00000: keep; 00001: W_ALUout; 00010: W_DMout; 00011: W_PC+8; 00100: W_CMP_result; 00101: W_MDUout
	 assign M_RD2_new = (M_FW_rt_sel == 5'd0) ? M_RD2 :
	                  (M_FW_rt_sel == 5'd1) ? W_ALUout :
							(M_FW_rt_sel == 5'd2) ? W_DMout :
							(M_FW_rt_sel == 5'd3) ? W_PC + 32'd8 :
                     (M_FW_rt_sel == 5'd4) ? W_CMP_result :
							(M_FW_rt_sel == 5'd5) ? W_MDUout :
							(M_FW_rt_sel == 5'd6) ? W_CP0out :
							                        M_RD2;
	 
	 E_M_REG E_M_reg (
    .clk(clk), 
    .reset(reset), 
    .Req(Req), 
    .E_M_REG_EN(1'b1), 
    .E_PC(E_PC), 
    .E_instr(E_instr), 
    .E_RD2(E_RD2_new), 
    .E_DM_write(E_DM_write), 
    .E_GRF_write(E_GRF_write), 
    .E_CP0_write(E_CP0_write), 
    .E_DMop(E_DMop), 
    .E_BEop(E_BEop), 
    .E_MDUout(E_MDUout), 
    .E_ALUout(E_ALUout), 
    .E_GRF_A3(E_GRF_A3), 
    .E_GRF_DatatoReg(E_GRF_DatatoReg), 
    .E_CMP_result(E_CMP_result), 
    .E_BD(E_BD), 
    .E_eret(E_eret), 
    .E_instr_type(E_instr_type), 
    .E_ExcCode(E_ExcCode), 
    .E_rs_Tuse(E_rs_Tuse), 
    .E_rt_Tuse(E_rt_Tuse), 
    .E_Tnew(E_Tnew), 
    .M_PC(M_PC), 
    .M_instr(M_instr), 
    .M_RD2(M_RD2), 
    .M_DM_write(M_DM_write), 
    .M_GRF_write(M_GRF_write), 
    .M_CP0_write(M_CP0_write), 
    .M_DMop(M_DMop), 
    .M_ALUout(M_ALUout), 
    .M_BEop(M_BEop), 
    .M_MDUout(M_MDUout), 
    .M_GRF_A3(M_GRF_A3), 
    .M_GRF_DatatoReg(M_GRF_DatatoReg), 
    .M_CMP_result(M_CMP_result), 
    .M_BD(M_BD), 
    .M_eret(M_eret), 
    .M_instr_type(M_instr_type), 
    .M_ExcCode(M_ExcCode_temp), 
    .M_rs_Tuse(M_rs_Tuse), 
    .M_rt_Tuse(M_rt_Tuse), 
    .M_Tnew(M_Tnew)
    );

	 DM_CU dm_cu (
    .M_ALUout(M_ALUout), 
    .M_RD2(M_RD2_new), 
    .DM_write(M_DM_write), 
    .M_instr_type(M_instr_type), 
    .M_DMop(M_DMop), 
    .M_byteen(M_byteen_temp), 
    .M_DM_WD(M_DM_WD), 
    .ExcCode(M_DM_ExcCode)
    );
	 
	 assign m_data_byteen = (Req != 1'b1) ? M_byteen_temp : 4'd0;
	 assign M_ExcCode = (M_ExcCode_temp != 5'd0) ? M_ExcCode_temp :
	                    (M_DM_ExcCode != 5'd0)   ? M_DM_ExcCode :
							                             5'd0;
	 
	 CP0 cp0 (
    .clk(clk), 
    .reset(reset), 
    .CP0_write(M_CP0_write), 
    .CP0_addr(M_instr[15:11]), 
    .CP0_in(M_RD2_new), 
    .EPC_in(M_PC), 
    .BD_in(M_BD), 
    .ExcCodeIn(M_ExcCode), 
    .HWInt(HWInt), 
    .EXL_clr(M_eret), 
    .CP0_out(M_CP0out), 
    .EPC_out(M_CP0_EPC), 
    .Req(Req)
    );
	 
	 assign m_data_wdata = M_DM_WD;
	 assign M_BE_in = m_data_rdata;
	 assign m_data_addr = M_ALUout;
	 assign MacroPC = M_PC;
	 
	 BE be (
    .M_BE_addr(W_ALUout), 
    .M_BE_in(M_BE_in), 
    .M_BEop(W_BEop), 
    .M_BEout(M_DMout)
    );
	 
///////////////////////////////////  WriteBack stage  //////////////////////////// 

	 
	 
	 M_W_REG M_W_reg (
    .clk(clk), 
    .reset(reset), 
    .Req(Req), 
    .M_W_REG_EN(1'b1), 
    .M_PC(M_PC), 
    .M_instr(M_instr), 
    .M_ALUout(M_ALUout), 
    .M_GRF_A3(M_GRF_A3), 
    .M_DMout(M_DMout), 
    .M_GRF_write(M_GRF_write), 
    .M_GRF_DatatoReg(M_GRF_DatatoReg), 
    .M_CMP_result(M_CMP_result), 
    .M_MDUout(M_MDUout), 
	 .M_BEop(M_BEop),
    .M_CP0_EPC(M_CP0_EPC), 
    .M_CP0out(M_CP0out), 
    .M_rs_Tuse(M_rs_Tuse), 
    .M_rt_Tuse(M_rt_Tuse), 
    .M_Tnew(M_Tnew), 
    .W_PC(W_PC), 
    .W_instr(W_instr), 
    .W_ALUout(W_ALUout), 
    .W_GRF_A3(W_GRF_A3), 
    .W_DMout(W_DMout), 
	 .W_BEop(W_BEop),
    .W_GRF_write(W_GRF_write), 
    .W_GRF_DatatoReg(W_GRF_DatatoReg), 
    .W_CMP_result(W_CMP_result), 
    .W_MDUout(W_MDUout), 
    .W_CP0out(W_CP0out), 
    .W_CP0_EPC(W_CP0_EPC), 
    .W_rs_Tuse(W_rs_Tuse), 
    .W_rt_Tuse(W_rt_Tuse), 
    .W_Tnew(W_Tnew)
    );
	 // 0000：ALUout; 0001：DMout; 0010：PC+8; 0011：写入CMPresult
	 assign W_GRF_WD = (W_GRF_DatatoReg == 4'd0) ? W_ALUout :
	                   (W_GRF_DatatoReg == 4'd1) ? W_DMout :
							 (W_GRF_DatatoReg == 4'd2) ? W_PC + 32'd8 :
							 (W_GRF_DatatoReg == 4'd3) ? W_CMP_result :
							 (W_GRF_DatatoReg == 4'd4) ? W_MDUout :
							 (W_GRF_DatatoReg == 4'd5) ? W_CP0out :
							                             32'd0;
																  
	 
	 
endmodule
