`include "../include/def.svh"
`include "../include/AXI_define.svh"
`include "AXI/AXI_interface.sv"

`include "CPU_wrapper.sv"
`include "SRAM_wrapper.sv"
`include "AXI/AXI.sv"
`include "reset_sync.sv"

module top (
    input logic clk,
    input logic rst
);

logic rst_sync, rstn_sync;
reset_sync i_reset_sync (
    .clk	  (clk),
    .rst_async(rst),
    .rst_sync (rst_sync),
	.rstn_sync(rstn_sync)
);

/*                  AXI ports                  */
AR_interface M0_AR();
AR_interface M1_AR();
AR_interface S1_AR();
AR_interface S2_AR();

R_interface  M0_R();
R_interface  M1_R();
R_interface  S1_R();
R_interface  S2_R();

AW_interface M1_AW();
AW_interface S1_AW();
AW_interface S2_AW();

W_interface  M1_W();
W_interface  S1_W();
W_interface  S2_W();

B_interface  M1_B();
B_interface  S1_B();
B_interface  S2_B();
/*                  AXI ports                  */

CPU_wrapper i_CPU_wrapper (
    .ACLK	(clk),
	.ARESETn(rstn_sync),

	.M0_AR  (M0_AR),
	.M0_R   (M0_R),

	.M1_AR	(M1_AR),
	.M1_R 	(M1_R),
	.M1_AW	(M1_AW),
	.M1_W 	(M1_W),
	.M1_B 	(M1_B)
);

AXI i_AXI (
    .ACLK	(clk),
    .ARESETn(rstn_sync),

	.AR_M0  (M0_AR),
	.R_M0	(M0_R),

	.AR_M1	(M1_AR),
	.R_M1	(M1_R),
	.AW_M1	(M1_AW),
	.W_M1	(M1_W),
	.B_M1	(M1_B),

	.AR_S1	(S1_AR),
	.R_S1	(S1_R),
	.AW_S1	(S1_AW),
	.W_S1	(S1_W),
	.B_S1	(S1_B),

	.AR_S2	(S2_AR),
	.R_S2	(S2_R),
	.AW_S2	(S2_AW),
	.W_S2	(S2_W),
	.B_S2	(S2_B)
);

SRAM_wrapper IM1 (
    .ACLK	(clk),
    .ARESETn(rstn_sync),

	.S_AR	(S1_AR),
	.S_R	(S1_R),
	.S_AW	(S1_AW),
	.S_W	(S1_W),
	.S_B	(S1_B)
);

SRAM_wrapper DM1 (
    .ACLK	(clk),
    .ARESETn(rstn_sync),

	.S_AR	(S2_AR),
	.S_R	(S2_R),
	.S_AW	(S2_AW),
	.S_W	(S2_W),
	.S_B	(S2_B)
);

endmodule