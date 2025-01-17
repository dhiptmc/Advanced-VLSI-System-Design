`include "../include/def.svh"
`include "../include/AXI_define.svh"
`include "AXI/AXI_interface.sv"

`include "CPU_wrapper.sv"
`include "SRAM_wrapper.sv"
`include "AXI/AXI.sv"
`include "reset_sync_dual.sv"
`include "DRAM_wrapper.sv"
`include "ROM_wrapper.sv"
`include "DMA_wrapper.sv"
`include "WDT_wrapper.sv"

module top (
	/*	System signals	*/
    input  logic 		clk,			//System clock
    input  logic 		rst,			//System reset (active high)
	input  logic 		clk2,			//WDT clock
	input  logic 		rst2,			//WDT reset (active high)

	/*	Connect with ROM	*/
	input  logic [31:0] ROM_out,		//Data from ROM
	output logic 		ROM_read,		//ROM output enable
	output logic 		ROM_enable,		//Enable ROM
	output logic [11:0] ROM_address,	//Address to ROM

	/*	Connect with DRAM	*/
	input  logic [31:0] DRAM_Q,			//Data from DRAM
	input  logic		DRAM_valid,		//DRAM output data valid
	output logic 		DRAM_CSn,		//DRAM Chip Select (active low)
	output logic [3:0]	DRAM_WEn,		//DRAM Write Enable (active low)
	output logic 		DRAM_RASn,		//DRAM Row Access Strobe (active low)
	output logic 		DRAM_CASn,		//DRAM Column Access Strobe (active low)
	output logic [10:0] DRAM_A,			//Address to DRAM
	output logic [31:0] DRAM_D			//Data to DRAM
);

logic rst1n_sync, rst2n_sync;
reset_sync_dual i_reset_sync_dual (
    .clk1	    (clk),
    .clk2	    (clk2),
    .rst1_async (rst),
    .rst2_async (rst2),
	.rst1n_sync (rst1n_sync),
	.rst2n_sync (rst2n_sync)
);

/*                  AXI ports                  */
/* CPU_wrapper */
//IM Master
AR_interface M0_AR();
R_interface  M0_R();
//DM Master
AR_interface M1_AR();
R_interface  M1_R();
AW_interface M1_AW();
W_interface  M1_W();
B_interface  M1_B();

/* SRAM_wrapper */
//SRAM (IM)
AR_interface S1_AR();
R_interface  S1_R();
AW_interface S1_AW();
W_interface  S1_W();
B_interface  S1_B();
//SRAM (DM)
AR_interface S2_AR();
R_interface  S2_R();
AW_interface S2_AW();
W_interface  S2_W();
B_interface  S2_B();

/* DRAM */
AR_interface S5_AR();
R_interface  S5_R();
AW_interface S5_AW();
W_interface  S5_W();
B_interface  S5_B();

/* ROM */
AR_interface S0_AR();
R_interface  S0_R();

/* DMA */
//master
AR_interface M2_AR();
R_interface  M2_R();
AW_interface M2_AW();
W_interface  M2_W();
B_interface  M2_B();
//slave
AR_interface S3_AR();
R_interface  S3_R();
AW_interface S3_AW();
W_interface  S3_W();
B_interface  S3_B();

/* WDT */
AR_interface S4_AR();
R_interface  S4_R();
AW_interface S4_AW();
W_interface  S4_W();
B_interface  S4_B();
/*                  AXI ports                  */

logic DMA_interrupt;
logic WDT_timeout;

AXI i_AXI (
    .ACLK	(clk),
    .ARESETn(rst1n_sync),

	.M0_AR	(M0_AR.M0),
	.M0_R	(M0_R.M0),

	.M1_AR	(M1_AR.M1),
	.M1_R	(M1_R.M1),
	.M1_AW	(M1_AW.M1),
	.M1_W	(M1_W.M1),
	.M1_B	(M1_B.M1),

	.M2_AR	(M2_AR.M2),
	.M2_R	(M2_R.M2),
	.M2_AW	(M2_AW.M2),
	.M2_W	(M2_W.M2),
	.M2_B	(M2_B.M2),

	.S0_AR	(S0_AR.S0),
	.S0_R	(S0_R.S0),

	.S1_AR	(S1_AR.S1),
	.S1_R	(S1_R.S1),
	.S1_AW	(S1_AW.S1),
	.S1_W	(S1_W.S1),
	.S1_B	(S1_B.S1),

	.S2_AR	(S2_AR.S2),
	.S2_R	(S2_R.S2),
	.S2_AW	(S2_AW.S2),
	.S2_W	(S2_W.S2),
	.S2_B	(S2_B.S2),

	.S3_AR	(S3_AR.S3),
	.S3_R	(S3_R.S3),
	.S3_AW	(S3_AW.S3),
	.S3_W	(S3_W.S3),
	.S3_B	(S3_B.S3),

	.S4_AR	(S4_AR.S4),
	.S4_R	(S4_R.S4),
	.S4_AW	(S4_AW.S4),
	.S4_W	(S4_W.S4),
	.S4_B	(S4_B.S4),

	.S5_AR	(S5_AR.S5),
	.S5_R	(S5_R.S5),
	.S5_AW	(S5_AW.S5),
	.S5_W	(S5_W.S5),
	.S5_B	(S5_B.S5)
);

CPU_wrapper i_CPU_wrapper (
    .ACLK		  (clk),
	.ARESETn	  (rst1n_sync),

	.M0_AR  	  (M0_AR.IM),
	.M0_R   	  (M0_R.IM),

	.M1_AR		  (M1_AR.DM),
	.M1_R 		  (M1_R.DM),
	.M1_AW		  (M1_AW.DM),
	.M1_W 		  (M1_W.DM),
	.M1_B 		  (M1_B.DM),

	.DMA_interrupt(DMA_interrupt),
	.WDT_timeout  (WDT_timeout)
);

SRAM_wrapper IM1 (
    .ACLK	(clk),
    .ARESETn(rst1n_sync),

	.S_AR	(S1_AR.SRAM),
	.S_R	(S1_R.SRAM),
	.S_AW	(S1_AW.SRAM),
	.S_W	(S1_W.SRAM),
	.S_B	(S1_B.SRAM)
);

SRAM_wrapper DM1 (
    .ACLK	(clk),
    .ARESETn(rst1n_sync),

	.S_AR	(S2_AR.SRAM),
	.S_R	(S2_R.SRAM),
	.S_AW	(S2_AW.SRAM),
	.S_W	(S2_W.SRAM),
	.S_B	(S2_B.SRAM)
);

DRAM_wrapper DRAM (
	.ACLK		(clk),
	.ARESETn	(rst1n_sync),

	.DRAM_CSn	(DRAM_CSn),
	.DRAM_WEn	(DRAM_WEn),
	.DRAM_RASn	(DRAM_RASn),
	.DRAM_CASn	(DRAM_CASn),
	.DRAM_A		(DRAM_A),
	.DRAM_D		(DRAM_D),
	.DRAM_Q		(DRAM_Q),
	.DRAM_valid	(DRAM_valid),

	.S5_AR		(S5_AR.DRAM),
	.S5_R		(S5_R.DRAM),
	.S5_AW		(S5_AW.DRAM),
	.S5_W		(S5_W.DRAM),
	.S5_B		(S5_B.DRAM)
);

ROM_wrapper ROM (
	.ACLK		(clk),
	.ARESETn	(rst1n_sync),

	.ROM_out	(ROM_out),
	.ROM_read	(ROM_read),
	.ROM_enable (ROM_enable),
	.ROM_address(ROM_address),

	.S0_AR		(S0_AR.ROM),
	.S0_R		(S0_R.ROM)
);

DMA_wrapper DMA (
	.ACLK		  (clk),
	.ARESETn	  (rst1n_sync),

	.M2_AR		  (M2_AR.DMA_M),
	.M2_R		  (M2_R.DMA_M),
	.M2_AW		  (M2_AW.DMA_M),
	.M2_W		  (M2_W.DMA_M),
	.M2_B		  (M2_B.DMA_M),

	.S3_AR		  (S3_AR.DMA_S),
	.S3_R		  (S3_R.DMA_S),
	.S3_AW		  (S3_AW.DMA_S),
	.S3_W		  (S3_W.DMA_S),
	.S3_B		  (S3_B.DMA_S),

	.DMA_interrupt(DMA_interrupt)
);

WDT_wrapper WDT (
	.clk		(clk),
	.rstn		(rst1n_sync),
	.clk2		(clk2),
	.rstn2		(rst2n_sync),

	.S4_AR		(S4_AR.WDT),
	.S4_R 		(S4_R.WDT),
	.S4_AW		(S4_AW.WDT),
	.S4_W		(S4_W.WDT),
	.S4_B		(S4_B.WDT),

	.WTO		(WDT_timeout)
);

endmodule