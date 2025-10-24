`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:33:18 11/07/2022 
// Design Name: 
// Module Name:    HCU 
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
module HCU(
    input [31:0] D_instr,
    input [31:0] E_instr,
    input [31:0] M_instr,
	 input [3:0] D_rs_Tuse,
	 input [3:0] D_rt_Tuse,
	 input [3:0] E_rs_Tuse,
	 input [3:0] E_rt_Tuse,
	 input [3:0] E_Tnew,
	 input [3:0] M_rt_Tuse,
	 input [3:0] M_Tnew,
	 input [3:0] W_Tnew,
	 input E_GRF_write,
    input M_GRF_write,
	 input W_GRF_write,
    input [4:0] E_GRF_A3,
    input [4:0] M_GRF_A3,
    input [4:0] W_GRF_A3,
	 input [3:0] M_GRF_DatatoReg,
    input [3:0] E_GRF_DatatoReg,
	 input [3:0] W_GRF_DatatoReg,
	 input E_MDU_busy,
	 input E_MDU_start,
	 output reg [2:0] D_FW_EPC_sel,
	 output reg [4:0] D_FW_rs_sel,
	 output reg [4:0] D_FW_rt_sel,
	 output reg [4:0] E_FW_rs_sel,
	 output reg [4:0] E_FW_rt_sel,
	 output reg [4:0] M_FW_rt_sel,
	 output stall,
	 output E_flush
    );
	 
	 
	 wire D_mflo;
	 wire D_mfhi;
	 wire E_mthi;
	 wire E_mtlo;
	 wire [4:0] D_rs;
	 wire [4:0] D_rt;
	 wire [4:0] E_rs;
	 wire [4:0] E_rt;
	 wire [4:0] M_rt;
	 
	 
	 assign D_rs = D_instr[25:21];
	 assign D_rt = D_instr[20:16];
	 assign E_rs = E_instr[25:21];
	 assign E_rt = E_instr[20:16];
	 assign M_rt = M_instr[20:16];
	 // special judge
	 assign D_mfhi = (D_instr[31:26] == 6'd0 && D_instr[5:0] == 6'b010000) ? 1'b1 : 1'b0;
	 assign D_mflo = (D_instr[31:26] == 6'd0 && D_instr[5:0] == 6'b010010) ? 1'b1 : 1'b0;
	 assign E_mthi = (E_instr[31:26] == 6'd0 && E_instr[5:0] == 6'b010001) ? 1'b1 : 1'b0;
	 assign E_mtlo = (E_instr[31:26] == 6'd0 && E_instr[5:0] == 6'b010011) ? 1'b1 : 1'b0;
	 assign D_eret = (D_instr == 32'b010000_1000_0000_0000_0000_0000_011000) ? 1'b1 : 1'b0;
	 assign E_mtc0 = (E_instr[31:21] == 11'b010000_00100) ? 1'b1 : 1'b0;
	 assign M_mtc0 = (M_instr[31:21] == 11'b010000_00100) ? 1'b1 : 1'b0;
	 
	 // 判断阻塞
	 wire stall_rs_ED;
	 wire stall_rt_ED;
	 wire stall_rs_MD;
	 wire stall_rt_MD;
	 wire stall_MDU;
	 assign stall_rs_ED = (D_rs == E_GRF_A3 && E_GRF_write == 1'b1 && E_GRF_A3 != 5'd0 && D_rs_Tuse < E_Tnew);
	 assign stall_rs_MD = (D_rs == M_GRF_A3 && M_GRF_write == 1'b1 && M_GRF_A3 != 5'd0 && D_rs_Tuse < M_Tnew);
	 assign stall_rt_ED = (D_rt == E_GRF_A3 && E_GRF_write == 1'b1 && E_GRF_A3 != 5'd0 && D_rt_Tuse < E_Tnew);
	 assign stall_rt_MD = (D_rt == M_GRF_A3 && M_GRF_write == 1'b1 && M_GRF_A3 != 5'd0 && D_rt_Tuse < M_Tnew);
	 assign stall_MDU = (E_MDU_busy | E_MDU_start);
	 //assign stall_MDU = ((D_mflo == 1'b1 || D_mfhi == 1'b1) && (E_MDU_busy == 1'b1 || E_MDU_start == 1'b1) && E_mthi === 1'b0 && E_mtlo === 1'b0);
	 assign stall = stall_rs_ED || stall_rt_ED || stall_rs_MD || stall_rt_MD || stall_MDU;
	 assign E_flush = stall;
	 
	 
	 // 判断D级流水
	 always @(*) begin
	     // rs
		  if (D_rs == E_GRF_A3 && E_GRF_write == 1'b1 && E_GRF_A3 != 5'd0) begin
		      if (E_Tnew == 4'd0) begin  // 转发
					 D_FW_rs_sel = (E_GRF_DatatoReg == 4'd2) ? 5'd1 :
                              (E_GRF_DatatoReg == 4'd3) ? 5'd2 :
                                                          5'd0;										
				end else begin                      // 继续流水
					 D_FW_rs_sel = 5'd0;
				end
		  end else if (D_rs == M_GRF_A3 && M_GRF_write == 1'b1 && M_GRF_A3 != 5'd0) begin
		      if (M_Tnew == 4'd0) begin  // 转发
					 D_FW_rs_sel = (M_GRF_DatatoReg == 4'd2) ? 5'd3 :
                              (M_GRF_DatatoReg == 4'd3) ? 5'd5 :
										(M_GRF_DatatoReg == 4'd0) ? 5'd4 :
										(M_GRF_DatatoReg == 4'd4) ? 5'd6 :
                                                          5'd0;										
				end else begin                      // 继续流水
					 D_FW_rs_sel = 5'd0;
				end
		  end else begin
				D_FW_rs_sel = 5'd0;
		  end
		  // rt
		  if (D_rt == E_GRF_A3 && E_GRF_write == 1'b1 && E_GRF_A3 != 5'd0) begin
		      if (E_Tnew == 4'd0) begin  // 转发
					 D_FW_rt_sel = (E_GRF_DatatoReg == 4'd2) ? 5'd1 :
                              (E_GRF_DatatoReg == 4'd3) ? 5'd2 :
                                                          5'd0;										
				end else begin                      // 继续流水
					 D_FW_rt_sel = 5'd0;
				end
		  end else if (D_rt == M_GRF_A3 && M_GRF_write == 1'b1 && M_GRF_A3 != 5'd0) begin
		      if (M_Tnew == 4'd0) begin  // 转发
					 D_FW_rt_sel = (M_GRF_DatatoReg == 4'd0) ? 5'd4 :
                              (M_GRF_DatatoReg == 4'd2) ? 5'd3 :
										(M_GRF_DatatoReg == 4'd3) ? 5'd5 : 
										(M_GRF_DatatoReg == 4'd4) ? 5'd6 :
                                                          5'd0;										
				end else begin                      // 继续流水
					 D_FW_rt_sel = 5'd0;
				end
		  end else begin
				D_FW_rt_sel = 5'd0;
		  end
		  
		  // EPC
		  if (D_eret == 1'b1) begin
            D_FW_EPC_sel = (E_mtc0 && (E_instr[15:11] == 5'd14)) ? 3'b010 : 
				               (M_mtc0 && (M_instr[15:11] == 5'd14)) ? 3'b001 :
                           3'b000;									
        end else begin		  
		      D_FW_EPC_sel = 3'd0;
        end		  
	 end
	 
	 // 判断 E 级流水
	 // 00000: keep; 00001: M_ALUout; 00010: M_PC+8; 00011: M_CMP_result; 00100: W_ALUout; 00101: W_DMout; 00110: W_PC+8; 00111: W_CMP_result
	 always @(*) begin
	     // rs
	     if (E_rs == M_GRF_A3 && M_GRF_write == 1'b1 && M_GRF_A3 != 5'd0) begin
		      if (M_Tnew == 4'd0) begin         // 转发
                E_FW_rs_sel = (M_GRF_DatatoReg == 4'd0) ? 5'd1 :
                              (M_GRF_DatatoReg == 4'd2) ? 5'd2 :
                              (M_GRF_DatatoReg == 4'd3) ? 5'd3 :
										(M_GRF_DatatoReg == 4'd4) ? 5'd4 : 
                                                          5'd0;										
            end else begin                   // 继续流水
                E_FW_rs_sel = 5'd0;
            end				
        end else if (E_rs == W_GRF_A3 && W_GRF_write == 1'b1 && W_GRF_A3 != 5'd0) begin
		      if (W_Tnew == 4'd0) begin      // 转发
				    E_FW_rs_sel = (W_GRF_DatatoReg == 4'd0) ? 5'd5 :
                              (W_GRF_DatatoReg == 4'd1) ? 5'd6 :
                              (W_GRF_DatatoReg == 4'd2) ? 5'd7 : 
                              (W_GRF_DatatoReg == 4'd3) ? 5'd8 :
										(W_GRF_DatatoReg == 4'd4) ? 5'd9 :
										(W_GRF_DatatoReg == 4'd5) ? 5'd10 :
                                                          5'd0;										
				end else begin                 // 流水
				    E_FW_rs_sel = 5'd0;
				end
		  end else begin
		      E_FW_rs_sel = 5'd0;
		  end
        
		  // rt
		  if (E_rt == M_GRF_A3 && M_GRF_write == 1'b1 && M_GRF_A3 != 5'd0) begin
		      if (M_Tnew == 4'd0) begin         // 转发
                E_FW_rt_sel = (M_GRF_DatatoReg == 4'd0) ? 5'd1 :
                              (M_GRF_DatatoReg == 4'd2) ? 5'd2 :
                              (M_GRF_DatatoReg == 4'd3) ? 5'd3 :
										(M_GRF_DatatoReg == 4'd4) ? 5'd4 :
                                                          5'd0;										
            end else begin                   // 继续流水
                E_FW_rt_sel = 5'd0;
            end				
		  end else if (E_rt == W_GRF_A3 && W_GRF_write == 1'b1 && W_GRF_A3 != 5'd0) begin
		      if (W_Tnew == 4'd0) begin        // 转发
				    E_FW_rt_sel = (W_GRF_DatatoReg == 4'd0) ? 5'd5 :
                              (W_GRF_DatatoReg == 4'd1) ? 5'd6 :
                              (W_GRF_DatatoReg == 4'd2) ? 5'd7 : 
                              (W_GRF_DatatoReg == 4'd3) ? 5'd8 :
										(W_GRF_DatatoReg == 4'd4) ? 5'd9 :
										(W_GRF_DatatoReg == 4'd5) ? 5'd10 :
                                                          5'd0;
				end else begin
				    E_FW_rt_sel = 5'd0;
				end
		  end else begin
		      E_FW_rt_sel = 5'd0;
		  end
	 end
	 
	 // 判断 M 级流水
    // 00000: keep; 00001: W_ALUout; 00010: W_DMout; 00011: W_PC+8; 00100: W_CMP_result
    always @(*) begin
        // rt
		  if (M_rt == W_GRF_A3 && W_GRF_write == 1'b1 && W_GRF_A3 != 5'd0) begin 
		      M_FW_rt_sel = (W_GRF_DatatoReg == 4'd0) ? 5'd1 :
				              (W_GRF_DatatoReg == 4'd1) ? 5'd2 :
								  (W_GRF_DatatoReg == 4'd2) ? 5'd3 :
								  (W_GRF_DatatoReg == 4'd3) ? 5'd4 :
								  (W_GRF_DatatoReg == 4'd4) ? 5'd5 :
								  (W_GRF_DatatoReg == 4'd5) ? 5'd6 :
								                              5'd0;
		  end else begin
		      M_FW_rt_sel = 5'd0;
		  end
    end	 

endmodule
