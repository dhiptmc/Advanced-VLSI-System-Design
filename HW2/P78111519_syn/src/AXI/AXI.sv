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
`include "../../include/AXI_define.svh"

`include "../../src/AXI/Default_Slave.sv"
`include "../../src/AXI/Arbiter.sv"
`include "../../src/AXI/Decoder.sv"
`include "../../src/AXI/AR.sv"
`include "../../src/AXI/R.sv"
`include "../../src/AXI/AW.sv"
`include "../../src/AXI/W.sv"
`include "../../src/AXI/B.sv"

//M0 -> IF  Stage
//M1 -> MEM Stage
//S0 -> IM
//S1 -> DM

module AXI(

	input ACLK,										//Global clock signal
	input ARESETn,									//Global reset signal, active LOW

	//SLAVE INTERFACE FOR MASTERS
	//WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_M1,				//Bits of master is 4 and for slave is 8, see A5-80 in spec
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,				//Burst length.
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,			//Burst size.
	input [1:0] AWBURST_M1,							//Burst type. Only need to implement INCR type.
	input AWVALID_M1,
	output logic AWREADY_M1,
	
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,			//Write strobes. 4 bits because 32/8 = 4
	input WLAST_M1,									//Write last. This signal indicates the last transfer in a write burst.
	input WVALID_M1,
	output logic WREADY_M1,
	
	//WRITE RESPONSE
	output logic [`AXI_ID_BITS-1:0] BID_M1,			//Bits of master is 4 and for slave is 8, see A5-80 in spec
	output logic [1:0] BRESP_M1,					//Write response. This signal indicates the status of the write transaction.
	output logic BVALID_M1,
	input BREADY_M1,

	//READ ADDRESS0
	input [`AXI_ID_BITS-1:0] ARID_M0,				//Bits of master is 4 and for slave is 8, see A5-80 in spec
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,			
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,				//Burst length.
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,			//Burst size.
	input [1:0] ARBURST_M0,							//Burst type. Only need to implement INCR type.
	input ARVALID_M0,
	output logic ARREADY_M0,
	
	//READ DATA0
	output logic [`AXI_ID_BITS-1:0] RID_M0,			//Bits of master is 4 and for slave is 8, see A5-80 in spec
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,					//Read response. This signal indicates the status of the read transfer.
	output logic RLAST_M0,							//Read last. This signal indicates the last transfer in a read burst.
	output logic RVALID_M0,
	input RREADY_M0,
	
	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	
	//READ DATA1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,

	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] AWID_S0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output logic [1:0] AWBURST_S0,
	output logic AWVALID_S0,
	input AWREADY_S0,
	
	//WRITE DATA0
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,
	
	//WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,
	
	//WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,
	
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,
	
	//READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	input ARREADY_S0,
	
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,
	
	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,
	
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1
	
);
    //---------- you should put your design here ----------//

/* DEFAULT slave*/
logic [ `AXI_IDS_BITS -1:0] ARID_SDEFAULT;
logic [`AXI_ADDR_BITS -1:0] ARADDR_SDEFAULT;
logic [ `AXI_LEN_BITS -1:0] ARLEN_SDEFAULT;
logic [`AXI_SIZE_BITS -1:0] ARSIZE_SDEFAULT;
logic [                1:0] ARBURST_SDEFAULT;
logic                       ARVALID_SDEFAULT;
logic                       ARREADY_SDEFAULT;

logic [ `AXI_IDS_BITS -1:0] RID_SDEFAULT;
logic [`AXI_DATA_BITS -1:0] RDATA_SDEFAULT;
logic [                1:0] RRESP_SDEFAULT;
logic                       RLAST_SDEFAULT;
logic                       RVALID_SDEFAULT;
logic                       RREADY_SDEFAULT;

logic [ `AXI_IDS_BITS -1:0] AWID_SDEFAULT;
logic [`AXI_ADDR_BITS -1:0] AWADDR_SDEFAULT;
logic [ `AXI_LEN_BITS -1:0] AWLEN_SDEFAULT;
logic [`AXI_SIZE_BITS -1:0] AWSIZE_SDEFAULT;
logic [                1:0] AWBURST_SDEFAULT;
logic                       AWVALID_SDEFAULT;
logic                       AWREADY_SDEFAULT;

logic [`AXI_DATA_BITS -1:0] WDATA_SDEFAULT;
logic [`AXI_STRB_BITS -1:0] WSTRB_SDEFAULT;
logic                       WLAST_SDEFAULT;
logic                       WVALID_SDEFAULT;
logic                       WREADY_SDEFAULT;

logic [ `AXI_IDS_BITS -1:0] BID_SDEFAULT;
logic [                1:0] BRESP_SDEFAULT;
logic                       BVALID_SDEFAULT;
logic                       BREADY_SDEFAULT;

Default_Slave i_Default_Slave(
	.clk(ACLK),
	.rstn(ARESETn),

	.ARID_SDEFAULT(ARID_SDEFAULT),
	.ARADDR_SDEFAULT(ARADDR_SDEFAULT),
	.ARLEN_SDEFAULT(ARLEN_SDEFAULT),
	.ARSIZE_SDEFAULT(ARSIZE_SDEFAULT),
	.ARBURST_SDEFAULT(ARBURST_SDEFAULT),
	.ARVALID_SDEFAULT(ARVALID_SDEFAULT),
	.ARREADY_SDEFAULT(ARREADY_SDEFAULT),

	.RID_SDEFAULT(RID_SDEFAULT),
	.RDATA_SDEFAULT(RDATA_SDEFAULT),
	.RRESP_SDEFAULT(RRESP_SDEFAULT),
	.RLAST_SDEFAULT(RLAST_SDEFAULT),
	.RVALID_SDEFAULT(RVALID_SDEFAULT),
	.RREADY_SDEFAULT(RREADY_SDEFAULT),

	.AWID_SDEFAULT(AWID_SDEFAULT),
	.AWADDR_SDEFAULT(AWADDR_SDEFAULT),
	.AWLEN_SDEFAULT(AWLEN_SDEFAULT),
	.AWSIZE_SDEFAULT(AWSIZE_SDEFAULT),
	.AWBURST_SDEFAULT(AWBURST_SDEFAULT),
	.AWVALID_SDEFAULT(AWVALID_SDEFAULT),
	.AWREADY_SDEFAULT(AWREADY_SDEFAULT),

	.WDATA_SDEFAULT(WDATA_SDEFAULT),
	.WSTRB_SDEFAULT(WSTRB_SDEFAULT),
	.WLAST_SDEFAULT(WLAST_SDEFAULT),
	.WVALID_SDEFAULT(WVALID_SDEFAULT),
	.WREADY_SDEFAULT(WREADY_SDEFAULT),

	.BID_SDEFAULT(BID_SDEFAULT),
	.BRESP_SDEFAULT(BRESP_SDEFAULT),
	.BVALID_SDEFAULT(BVALID_SDEFAULT),
	.BREADY_SDEFAULT(BREADY_SDEFAULT)
);

AR i_AR(
    .clk(ACLK),
    .rstn(ARESETn),

    .ARID_M0(ARID_M0),
    .ARADDR_M0(ARADDR_M0),
    .ARLEN_M0(ARLEN_M0),
    .ARSIZE_M0(ARSIZE_M0),
    .ARBURST_M0(ARBURST_M0),
    .ARVALID_M0(ARVALID_M0),

    .ARREADY_M0(ARREADY_M0),

    .ARID_M1(ARID_M1),
    .ARADDR_M1(ARADDR_M1),
    .ARLEN_M1(ARLEN_M1),
    .ARSIZE_M1(ARSIZE_M1),
    .ARBURST_M1(ARBURST_M1),
    .ARVALID_M1(ARVALID_M1),

    .ARREADY_M1(ARREADY_M1),

    .ARID_S0(ARID_S0),
    .ARADDR_S0(ARADDR_S0),
    .ARLEN_S0(ARLEN_S0),
    .ARSIZE_S0(ARSIZE_S0),
    .ARBURST_S0(ARBURST_S0),
    .ARVALID_S0(ARVALID_S0),

    .ARREADY_S0(ARREADY_S0),

    .ARID_S1(ARID_S1),
    .ARADDR_S1(ARADDR_S1),
    .ARLEN_S1(ARLEN_S1),
    .ARSIZE_S1(ARSIZE_S1),
    .ARBURST_S1(ARBURST_S1),
    .ARVALID_S1(ARVALID_S1),

    .ARREADY_S1(ARREADY_S1),

    .ARID_SDEFAULT(ARID_SDEFAULT),
    .ARADDR_SDEFAULT(ARADDR_SDEFAULT),
    .ARLEN_SDEFAULT(ARLEN_SDEFAULT),
    .ARSIZE_SDEFAULT(ARSIZE_SDEFAULT),
    .ARBURST_SDEFAULT(ARBURST_SDEFAULT),
    .ARVALID_SDEFAULT(ARVALID_SDEFAULT),

    .ARREADY_SDEFAULT(ARREADY_SDEFAULT)
);

R i_R(
    .clk(ACLK),
    .rstn(ARESETn),

    .RID_M0(RID_M0),
    .RDATA_M0(RDATA_M0),
    .RRESP_M0(RRESP_M0),
    .RLAST_M0(RLAST_M0),
    .RVALID_M0(RVALID_M0),

    .RREADY_M0(RREADY_M0),

    .RID_M1(RID_M1),
    .RDATA_M1(RDATA_M1),
    .RRESP_M1(RRESP_M1),
    .RLAST_M1(RLAST_M1),
    .RVALID_M1(RVALID_M1),

    .RREADY_M1(RREADY_M1),

    .RID_S0(RID_S0),
    .RDATA_S0(RDATA_S0),
    .RRESP_S0(RRESP_S0),
    .RLAST_S0(RLAST_S0),
    .RVALID_S0(RVALID_S0),

    .RREADY_S0(RREADY_S0),

    .RID_S1(RID_S1),
    .RDATA_S1(RDATA_S1),
    .RRESP_S1(RRESP_S1),
    .RLAST_S1(RLAST_S1),
    .RVALID_S1(RVALID_S1),

    .RREADY_S1(RREADY_S1),

    .RID_SDEFAULT(RID_SDEFAULT),
    .RDATA_SDEFAULT(RDATA_SDEFAULT),
    .RRESP_SDEFAULT(RRESP_SDEFAULT),
    .RLAST_SDEFAULT(RLAST_SDEFAULT),
    .RVALID_SDEFAULT(RVALID_SDEFAULT),

    .RREADY_SDEFAULT(RREADY_SDEFAULT)
);

AW i_AW(
    .clk(ACLK),
    .rstn(ARESETn),

    .AWID_M1(AWID_M1),
    .AWADDR_M1(AWADDR_M1),
    .AWLEN_M1(AWLEN_M1),
    .AWSIZE_M1(AWSIZE_M1),
    .AWBURST_M1(AWBURST_M1),
    .AWVALID_M1(AWVALID_M1),

    .AWREADY_M1(AWREADY_M1),

    .AWID_S0(AWID_S0),
    .AWADDR_S0(AWADDR_S0),
    .AWLEN_S0(AWLEN_S0),
    .AWSIZE_S0(AWSIZE_S0),
    .AWBURST_S0(AWBURST_S0),
    .AWVALID_S0(AWVALID_S0),

    .AWREADY_S0(AWREADY_S0),

    .AWID_S1(AWID_S1),
    .AWADDR_S1(AWADDR_S1),
    .AWLEN_S1(AWLEN_S1),
    .AWSIZE_S1(AWSIZE_S1),
    .AWBURST_S1(AWBURST_S1),
    .AWVALID_S1(AWVALID_S1),

    .AWREADY_S1(AWREADY_S1),

    .AWID_SDEFAULT(AWID_SDEFAULT),
    .AWADDR_SDEFAULT(AWADDR_SDEFAULT),
    .AWLEN_SDEFAULT(AWLEN_SDEFAULT),
    .AWSIZE_SDEFAULT(AWSIZE_SDEFAULT),
    .AWBURST_SDEFAULT(AWBURST_SDEFAULT),
    .AWVALID_SDEFAULT(AWVALID_SDEFAULT),

    .AWREADY_SDEFAULT(AWREADY_SDEFAULT)
);

W i_W(
    .clk(ACLK),
    .rstn(ARESETn),

    .WDATA_M1(WDATA_M1),
    .WSTRB_M1(WSTRB_M1),
    .WLAST_M1(WLAST_M1),
    .WVALID_M1(WVALID_M1),

    .WREADY_M1(WREADY_M1),

    .WDATA_S0(WDATA_S0),
    .WSTRB_S0(WSTRB_S0),
    .WLAST_S0(WLAST_S0),
    .WVALID_S0(WVALID_S0),

    .WREADY_S0(WREADY_S0),

    .WDATA_S1(WDATA_S1),
    .WSTRB_S1(WSTRB_S1),
    .WLAST_S1(WLAST_S1),
    .WVALID_S1(WVALID_S1),

    .WREADY_S1(WREADY_S1),

    .WDATA_SDEFAULT(WDATA_SDEFAULT),
    .WSTRB_SDEFAULT(WSTRB_SDEFAULT),
    .WLAST_SDEFAULT(WLAST_SDEFAULT),
    .WVALID_SDEFAULT(WVALID_SDEFAULT),

    .WREADY_SDEFAULT(WREADY_SDEFAULT),

    .AWVALID_S0(AWVALID_S0),
    .AWVALID_S1(AWVALID_S1),
    .AWVALID_SDEFAULT(AWVALID_SDEFAULT)
);

B i_B(
    .BID_M1(BID_M1),
    .BRESP_M1(BRESP_M1),
    .BVALID_M1(BVALID_M1),

    .BREADY_M1(BREADY_M1),

    .BID_S0(BID_S0),
    .BRESP_S0(BRESP_S0),
    .BVALID_S0(BVALID_S0),

    .BREADY_S0(BREADY_S0),

    .BID_S1(BID_S1),
    .BRESP_S1(BRESP_S1),
    .BVALID_S1(BVALID_S1),

    .BREADY_S1(BREADY_S1),

    .BID_SDEFAULT(BID_SDEFAULT),
    .BRESP_SDEFAULT(BRESP_SDEFAULT),
    .BVALID_SDEFAULT(BVALID_SDEFAULT),

    .BREADY_SDEFAULT(BREADY_SDEFAULT)
);

endmodule