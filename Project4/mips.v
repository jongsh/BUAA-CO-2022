`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:38:59 10/25/2022 
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
    input clk,
    input reset
    );
	 
	 wire [31:0] PCnext;
	 wire [31:0] PC;
	 wire [25:0] instr_imm26;   // 立即数imm26
	 wire [15:0] instr_imm16;   // 立即数imm16
	 wire [5:0] instr_op;       // opcode字段
	 wire [5:0] instr_func;     // R指令辅助func
	 wire [4:0] instr_shamt;    // R指令移位shamt
	 wire [4:0] instr_rd;       // 寄存器rd
	 wire [4:0] instr_rt;       // 寄存器rt
	 wire [4:0] instr_rs;       // 寄存器rs
	 wire [31:0] regRD1;        // GRF 读出的第一个寄存器数据
	 wire [31:0] regRD2;        // GRF 读出的第二个寄存器数据
	 wire [31:0] EXTout;        // EXT 的输出信号
	 wire [31:0] opA;           // ALU 操作数A
	 wire [31:0] opB;           // ALU 操作数B
	 wire CMPresult;            // ALU 输出的比较信号
	 wire [31:0] ALUresult;     // ALU 运算结果
	 wire [11:0] instrAddr;
	 wire [31:0] instr;       // 32 位指令机器码
	 wire [4:0] regAddr3;     // GRF 的写入地址
	 wire [31:0] regWD;       // GRF 的写入数据
	 wire [11:0] MemAddr;     // DM 写入地址
	 wire [31:0] MemWD;      // DM 写入数据
	 wire [31:0] MemReadData;  // DM 读出的数据
	 // 控制信号
	 wire [1:0] NPCop;       // NPC 操作控制信号
	 wire RegWrite;          // GRF 写使能信号
	 wire [1:0] RegDst;      // GRF 的 regWD 数据选择信号
	 wire [1:0] EXTop;       // EXT 控制信号
	 wire ALUSrc;            // ALU的 operationB 数据选择信号 
	 wire [2:0] ALUop;       // ALU 计算信号
	 wire [2:0] CMPop;      // ALU 比较信号
	 wire MemWrite;          // DM 写使能信号
	 wire [2:0] DatatoReg;   // GRF 读入的数据
	 
	 assign instr_imm26 = instr[25:0];   // 立即数imm26
    assign instr_imm16 = instr[15:0];   // 立即数imm16
    assign instr_func = instr[5:0];     // R指令辅助func
    assign instr_op = instr[31:26];     // opcode字段
    assign instr_shamt = instr[10:6];   // R指令移位shamt
	 assign instr_rd = instr[15:11];     // 寄存器rd
	 assign instr_rt = instr[20:16];     // 寄存器rt
	 assign instr_rs = instr[25:21];     // 寄存器rs
	 assign instrAddr = PC[13:2];        // 指令地址 
	 assign regAddr3 = (RegDst == 2'b00) ? instr_rd :   // GRF 写地址选择
	                   (RegDst == 3'b01) ? instr_rt :
							 (RegDst == 3'b10) ? 5'd31 :
							 5'd0;
	 assign regWD = (DatatoReg == 3'b000) ? ALUresult :
	                (DatatoReg == 3'b001) ? MemReadData :
						 (DatatoReg == 3'b010) ? (PC + 32'd4) :
						 (DatatoReg == 3'b011) ? {31'd0,CMPresult} :
						 32'd0;
	 assign MemAddr = ALUresult[13:2];
	 assign MemWD = regRD2;
	 assign opA = regRD1;
	 assign opB = (ALUSrc == 1'b0) ? regRD2 : EXTout;
	 
	 // some output message
	 always @(posedge clk) begin
	     if (reset != 1'b1) begin
		      if (RegWrite == 1'b1) begin
				    $display("@%h: $%d <= %h", PC, regAddr3, regWD);
				end else if (MemWrite == 1'b1) begin
				    $display("@%h: *%h <= %h", PC, ALUresult, MemWD);
				end
		  end
	 end
	 
	 // PC 实例化
	 PC pc (
    .PCnext(PCnext), 
    .clk(clk), 
    .reset(reset), 
    .PC(PC)
    );
	 // NPC 实例化
	 NPC npc (
    .imm26(instr_imm26), 
    .imm16(instr_imm16), 
    .regRa(regRD1), 
    .PC(PC), 
    .NPCop(NPCop), 
    .CMPResult(CMPresult), 
    .PCnext(PCnext)
    );
	 // IM 实例化
	 IM im (
    .instrAddr(instrAddr), 
    .instr(instr)
    );
	 // GRF 实例化
	 GRF grf (
    .clk(clk), 
    .reset(reset), 
    .GRFWrite(RegWrite), 
    .regAddr1(instr_rs), 
    .regAddr2(instr_rt), 
    .regAddr3(regAddr3), 
    .regWD(regWD), 
    .RD1(regRD1), 
    .RD2(regRD2)
    );
	 // DM 实例化
	 DM dm (
    .clk(clk), 
    .reset(reset), 
    .MemWrite(MemWrite), 
    .MemAddr(MemAddr), 
    .MemWD(MemWD), 
    .MemReadData(MemReadData)
    );
	 // EXT 实例化
	 EXT ext (
    .EXTin(instr_imm16), 
    .EXTop(EXTop), 
    .EXTout(EXTout)
    );
	 // ALU 实例化
	 ALU alu (
    .operationA(opA), 
    .operationB(opB), 
    .shamtC(instr_shamt), 
    .ALUop(ALUop), 
    .CMPop(CMPop), 
    .ALUresult(ALUresult), 
    .CMPresult(CMPresult)
    );
	 // Controller 实例化
	 Controller controller (
    .instr_op(instr_op), 
    .instr_func(instr_func), 
    .RegWrite(RegWrite), 
    .RegDst(RegDst), 
    .EXTop(EXTop), 
    .NPCop(NPCop), 
    .ALUSrc(ALUSrc), 
    .ALUop(ALUop), 
    .CMPop(CMPop), 
    .MemWrite(MemWrite), 
    .DatatoReg(DatatoReg)
    );
	 

endmodule
