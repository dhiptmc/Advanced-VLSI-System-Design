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
// 	Author:			TZUNG-JIN, TSAI (Leo)				  	   		//
//	Filename:	    AXI.sv			                            	//
//	Description:	Top module of AXI	 							//
// 	Version:		1.0	    								   		//
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

	//AXI to master 0 (IM_Master)
	AR_interface.M0 AR_M0,
	R_interface.M0  R_M0,

	//AXI to master 1 (DM_Master)
	AR_interface.M1 AR_M1,
	R_interface.M1  R_M1,
	AW_interface.M1 AW_M1,
	W_interface.M1  W_M1,
	B_interface.M1  B_M1,

	//AXI to slave 1 (IM)
	AR_interface.S1 AR_S1,
	R_interface.S1  R_S1,
	AW_interface.S1 AW_S1,
	W_interface.S1  W_S1,
	B_interface.S1  B_S1,

	//AXI to slave 2 (DM)
	AR_interface.S2 AR_S2,
	R_interface.S2  R_S2,
	AW_interface.S2 AW_S2,
	W_interface.S2  W_S2,
	B_interface.S2  B_S2
);
    //---------- you should put your design here ----------//

//wire
AR_interface AR_wire();
R_interface  R_wire ();
AW_interface AW_wire();
W_interface  W_wire ();
B_interface  B_wire ();

Default_Slave i_Default_Slave(
	.clk  	 		 (ACLK),
	.rstn 	 		 (ARESETn),

	.DS_AR	 		 (AR_wire),
	.DS_R 	 		 (R_wire),
	.DS_AW	 		 (AW_wire),
	.DS_W 	 		 (W_wire),
	.DS_B 	 		 (B_wire)
);

AR i_AR(
    .clk 	 		 (ACLK),
    .rstn	 		 (ARESETn),

	.M0		 		 (AR_M0),
	.M1		 		 (AR_M1),
	.S1		 		 (AR_S1),
	.S2		 		 (AR_S2),
	.SDEFAULT		 (AR_wire)
);

R i_R(
    .clk	 		 (ACLK),
    .rstn	 		 (ARESETn),
	
	.M0		 		 (R_M0),
	.M1		 		 (R_M1),
	.S1		 		 (R_S1),
	.S2		 		 (R_S2),
	.SDEFAULT		 (R_wire)
);

AW i_AW(
    .clk	 		 (ACLK),
    .rstn	 		 (ARESETn),

	.M1		 		 (AW_M1),
	.S1		 		 (AW_S1),
	.S2		 		 (AW_S2),
	.SDEFAULT		 (AW_wire)
);

W i_W(
    .clk			 (ACLK),
    .rstn			 (ARESETn),

	.M1				 (W_M1),
	.S1				 (W_S1),
	.S2				 (W_S2),
	.SDEFAULT		 (W_wire),
	.AWVALID_S1		 (AW_S1.AWVALID),
	.AWVALID_S2		 (AW_S2.AWVALID),	
	.AWVALID_SDEFAULT(AW_wire.AWVALID)
);

B i_B(
	.M1		 		 (B_M1),
	.S1		 		 (B_S1),
	.S2		 		 (B_S2),
	.SDEFAULT		 (B_wire)
);

endmodule