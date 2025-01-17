//////////////////////////////////////////////////////////////////////
//          ██╗       ██████╗   ██╗  ██╗    ██████╗            		//
//          ██║       ██╔══█║   ██║  ██║    ██╔══█║            		//
//          ██║       ██████║   ███████║    ██████║            		//
//          ██║       ██╔═══╝   ██╔══██║    ██╔═══╝            		//
//          ███████╗  ██║  	    ██║  ██║    ██║  	           		//
//          ╚══════╝  ╚═╝  	    ╚═╝  ╚═╝    ╚═╝  	           		//
//                                                             		//
// 	2024 Advanced VLSI System Design, advisor: Lih-Yih, Chiou		//
//                                                             		//
//////////////////////////////////////////////////////////////////////
//                                                             		//
// 	Author:			Shan-Chi Yu            				  	   		//
//	Filename:	    AXI.sv			                            	//
//	Description:	Top module of AXI	 							//
// 	Version:		2.0	    								   		//
//////////////////////////////////////////////////////////////////////
`include "../../src/AXI/Default_Slave.sv"
`include "../../src/AXI/Arbiter.sv"
`include "../../src/AXI/Decoder.sv"
`include "../../src/AXI/AR.sv"
`include "../../src/AXI/R.sv"
`include "../../src/AXI/AW.sv"
`include "../../src/AXI/W.sv"
`include "../../src/AXI/B.sv"

module AXI(

	input 			ACLK,		//Global clock signal
	input 			ARESETn,	//Global reset signal, active LOW

	AR_interface.M0 M0_AR,
	R_interface.M0  M0_R,

	AR_interface.M1 M1_AR,
	R_interface.M1  M1_R,
	AW_interface.M1 M1_AW,
	W_interface.M1  M1_W,
	B_interface.M1  M1_B,

	AR_interface.M2 M2_AR,
	R_interface.M2  M2_R,
	AW_interface.M2 M2_AW,
	W_interface.M2  M2_W,
	B_interface.M2  M2_B,

	AR_interface.S0 S0_AR,
	R_interface.S0  S0_R,

	AR_interface.S1 S1_AR,
	R_interface.S1  S1_R,
	AW_interface.S1 S1_AW,
	W_interface.S1  S1_W,
	B_interface.S1  S1_B,

	AR_interface.S2 S2_AR,
	R_interface.S2  S2_R,
	AW_interface.S2 S2_AW,
	W_interface.S2  S2_W,
	B_interface.S2  S2_B,

	AR_interface.S3 S3_AR,
	R_interface.S3  S3_R,
	AW_interface.S3 S3_AW,
	W_interface.S3  S3_W,
	B_interface.S3  S3_B,

	AR_interface.S4 S4_AR,
	R_interface.S4  S4_R,
	AW_interface.S4 S4_AW,
	W_interface.S4  S4_W,
	B_interface.S4  S4_B,

	AR_interface.S5 S5_AR,
	R_interface.S5  S5_R,
	AW_interface.S5 S5_AW,
	W_interface.S5  S5_W,
	B_interface.S5  S5_B
);
    //---------- you should put your design here ----------//
//wire
AR_interface DS_AR();
R_interface  DS_R ();
AW_interface DS_AW();
W_interface  DS_W ();
B_interface  DS_B ();

Default_Slave i_Default_Slave(
	.clk  	 		 (ACLK),
	.rstn 	 		 (ARESETn),

	.DS_AR	 		 (DS_AR.Default_Slave),
	.DS_R 	 		 (DS_R.Default_Slave),
	.DS_AW	 		 (DS_AW.Default_Slave),
	.DS_W 	 		 (DS_W.Default_Slave),
	.DS_B 	 		 (DS_B.Default_Slave)
);

AR i_AR(
    .clk 	 		 (ACLK),
    .rstn	 		 (ARESETn),

	.M0		 		 (M0_AR),
	.M1		 		 (M1_AR),
	.M2		 		 (M2_AR),	
	.S0		 		 (S0_AR),
	.S1		 		 (S1_AR),
	.S2		 		 (S2_AR),
	.S3		 		 (S3_AR),
	.S4		 		 (S4_AR),
	.S5		 		 (S5_AR),
	.SDEFAULT		 (DS_AR.SDEFAULT)
);

R i_R(
    .clk	 		 (ACLK),
    .rstn	 		 (ARESETn),
	
	.M0		 		 (M0_R),
	.M1		 		 (M1_R),
	.M2				 (M2_R),
	.S0		 		 (S0_R),
	.S1		 		 (S1_R),
	.S2		 		 (S2_R),
	.S3		 		 (S3_R),
	.S4		 		 (S4_R),
	.S5		 		 (S5_R),
	.SDEFAULT		 (DS_R.SDEFAULT)
);

AW i_AW(
    .clk	 		 (ACLK),
    .rstn	 		 (ARESETn),

	.M1		 		 (M1_AW),
	.M2				 (M2_AW),
	.S1		 		 (S1_AW),
	.S2		 		 (S2_AW),
	.S3		 		 (S3_AW),
	.S4		 		 (S4_AW),
	.S5		 		 (S5_AW),
	.SDEFAULT		 (DS_AW.SDEFAULT)
);

W i_W(
    .clk			 (ACLK),
    .rstn			 (ARESETn),

	.M1		 		 (M1_W),
	.M2				 (M2_W),
	.S1		 		 (S1_W),
	.S2		 		 (S2_W),
	.S3		 		 (S3_W),
	.S4		 		 (S4_W),
	.S5		 		 (S5_W),
	.SDEFAULT		 (DS_W.SDEFAULT),

    .AWID_S_S1		 (S1_AW.AWID_S),
    .AWID_S_S2		 (S2_AW.AWID_S),
    .AWID_S_S3		 (S3_AW.AWID_S),
    .AWID_S_S4		 (S4_AW.AWID_S),
    .AWID_S_S5		 (S5_AW.AWID_S),
	// .AWID_S_SDEFAULT (DS_AW.SDEFAULT),	
	.AWVALID_S1		 (S1_AW.AWVALID),
	.AWVALID_S2		 (S2_AW.AWVALID),	
	.AWVALID_S3		 (S3_AW.AWVALID),
	.AWVALID_S4		 (S4_AW.AWVALID),
	.AWVALID_S5		 (S5_AW.AWVALID),
	// .AWVALID_SDEFAULT(DS_AW.SDEFAULT)
	.AW_SDEFAULT	 (DS_AW.SDEFAULT)
);

B i_B(
	.M1		 		 (M1_B),
	.M2				 (M2_B),
	.S1		 		 (S1_B),
	.S2		 		 (S2_B),
	.S3		 		 (S3_B),
	.S4		 		 (S4_B),
	.S5		 		 (S5_B),
	.SDEFAULT		 (DS_B.SDEFAULT)
);

endmodule