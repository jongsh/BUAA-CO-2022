`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:18:50 11/06/2022 
// Design Name: 
// Module Name:    DM 
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
module DM(
    input clk,
    input reset,
    input DM_write,
    input [1:0] DMop,
    input [31:0] DM_addr,
    input [31:0] DM_WD,
    output reg [31:0] DMout
    );
	 
	 reg [31:0] DM_RAM[0:4095];
	 reg [31:0] DM_WDtemp;
	 reg [31:0] DM_WDtemp2;
	 reg [31:0] DMout_temp;
	 reg [31:0] DMout_temp2;
	 
	 integer i;
	 
	 // DMop: 00-word, 01-half, 10-bite
	 
	 // read the data
	 always @(*) begin

	     case(DMop)
		      2'b00: begin
				           DMout = DM_RAM[DM_addr[13:2]];
				       end
			   2'b01: begin
				           DMout_temp2 = (DM_addr[1:0] << 3);
				           DMout_temp = (DM_RAM[DM_addr[13:2]] >> DMout_temp2);
				           DMout = {16'd0, DMout_temp[15:0]};
				       end
			   2'b10: begin
				           DMout_temp2 = (DM_addr[1:0] << 3);
				           DMout_temp = (DM_RAM[DM_addr[13:2]] >> DMout_temp2);
				           DMout = {24'd0, DMout_temp[7:0]};
						 end
			   default: DMout = DM_RAM[DM_addr[13:2]];
		  endcase
	 end
	 
	 // write the data
	 always @(*) begin
	     case(DMop)
				    2'b00: begin
					            DM_WDtemp = DM_WD;
							  end
					 2'b01: begin
							      DM_WDtemp2 = (~(32'h0000ffff << DMout_temp2) & DM_RAM[DM_addr[13:2]]);
									DM_WDtemp = (DM_WDtemp2 | (DM_WD[15:0] << DMout_temp2));
							  end
					 2'b10: begin
							      DM_WDtemp2 = (~(32'h000000ff << DMout_temp2) & DM_RAM[DM_addr[13:2]]);
									DM_WDtemp = (DM_WDtemp2 | (DM_WD[7:0] << DMout_temp2));
							  end
					 default : DM_WDtemp = DM_WD;
		  endcase
	 end
	 
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin    // ¸´Î»Çå¿Õ
		      for (i = 0; i < 4096; i = i + 1) begin
				    DM_RAM[i] <= 32'd0;
				end
		  end else begin
		      if (DM_write == 1'b1) begin
		          DM_RAM[DM_addr[13:2]] <= DM_WDtemp;
		      end
		  end
	 end


endmodule
