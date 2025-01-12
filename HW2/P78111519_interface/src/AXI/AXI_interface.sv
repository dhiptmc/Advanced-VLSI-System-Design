interface AR_interface;
	logic [  `AXI_ID_BITS-1:0] ARID;
    logic [ `AXI_IDS_BITS-1:0] ARID_S;
	logic [`AXI_ADDR_BITS-1:0] ARADDR;		
	logic [ `AXI_LEN_BITS-1:0] ARLEN;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE;
	logic [               1:0] ARBURST;	
	logic                      ARVALID;
	logic                      ARREADY;

    //AXI AR
    modport M0 (input ARID, input ARADDR, input ARLEN, input ARSIZE, input ARBURST, input ARVALID, output ARREADY);
    modport M1 (input ARID, input ARADDR, input ARLEN, input ARSIZE, input ARBURST, input ARVALID, output ARREADY);

    modport S1       (output ARID_S, output ARADDR, output ARLEN, output ARSIZE, output ARBURST, output ARVALID, input ARREADY);
    modport S2       (output ARID_S, output ARADDR, output ARLEN, output ARSIZE, output ARBURST, output ARVALID, input ARREADY);
    modport SDEFAULT (output ARID_S, output ARADDR, output ARLEN, output ARSIZE, output ARBURST, output ARVALID, input ARREADY);

    //for CPU_wrapper
    modport IM (output ARID, output ARADDR, output ARLEN, output ARSIZE, output ARBURST, output ARVALID, input ARREADY);
    modport DM (output ARID, output ARADDR, output ARLEN, output ARSIZE, output ARBURST, output ARVALID, input ARREADY);

    //for SRAM_wrapper
    modport SRAM (input ARID_S, input ARADDR, input ARLEN, input ARSIZE, input ARBURST, input ARVALID, output ARREADY);

    //for DEFAULT slave
    modport Default_Slave (input ARID_S, input ARADDR, input ARLEN, input ARSIZE, input ARBURST, input ARVALID, output ARREADY);
endinterface

interface R_interface;
	logic [  `AXI_ID_BITS-1:0] RID;
	logic [ `AXI_IDS_BITS-1:0] RID_S;
	logic [`AXI_DATA_BITS-1:0] RDATA;
	logic [               1:0] RRESP;
	logic                      RLAST;
	logic                      RVALID;
	logic                      RREADY;

    //AXI R
    modport M0 (output RID, output RDATA, output RRESP, output RLAST, output RVALID, input RREADY);
    modport M1 (output RID, output RDATA, output RRESP, output RLAST, output RVALID, input RREADY);

    modport S1       (input RID_S, input RDATA, input RRESP, input RLAST, input RVALID, output RREADY);
    modport S2       (input RID_S, input RDATA, input RRESP, input RLAST, input RVALID, output RREADY);
    modport SDEFAULT (input RID_S, input RDATA, input RRESP, input RLAST, input RVALID, output RREADY);

    //for CPU_wrapper
    modport IM (input RID, input RDATA, input RRESP, input RLAST, input RVALID, output RREADY);
    modport DM (input RID, input RDATA, input RRESP, input RLAST, input RVALID, output RREADY);

    //for SRAM_wrapper
    modport SRAM (output RID_S, output RDATA, output RRESP, output RLAST, output RVALID, input RREADY);

    //for DEFAULT slave
    modport Default_Slave (output RID_S, output RDATA, output RRESP, output RLAST, output RVALID, input RREADY);
endinterface

interface AW_interface;
	logic [  `AXI_ID_BITS-1:0] AWID;
	logic [ `AXI_IDS_BITS-1:0] AWID_S;
	logic [`AXI_ADDR_BITS-1:0] AWADDR;
	logic [ `AXI_LEN_BITS-1:0] AWLEN;
	logic [`AXI_SIZE_BITS-1:0] AWSIZE;
	logic [               1:0] AWBURST;
	logic                      AWVALID;
	logic                      AWREADY;

    //AXI AW
    modport M1 (input AWID, input AWADDR, input AWLEN, input AWSIZE, input AWBURST, input AWVALID, output AWREADY);

    modport S1       (output AWID_S, output AWADDR, output AWLEN, output AWSIZE, output AWBURST, output AWVALID, input AWREADY);
    modport S2       (output AWID_S, output AWADDR, output AWLEN, output AWSIZE, output AWBURST, output AWVALID, input AWREADY);
    modport SDEFAULT (output AWID_S, output AWADDR, output AWLEN, output AWSIZE, output AWBURST, output AWVALID, input AWREADY);

    //for CPU_wrapper
    modport DM (output AWID, output AWADDR, output AWLEN, output AWSIZE, output AWBURST, output AWVALID, input AWREADY);

    //for SRAM_wrapper
    modport SRAM (input AWID_S, input AWADDR, input AWLEN, input AWSIZE, input AWBURST, input AWVALID, output AWREADY);

    //for DEFAULT slave
    modport Default_Slave (input AWID_S, input AWADDR, input AWLEN, input AWSIZE, input AWBURST, input AWVALID, output AWREADY);
endinterface

interface W_interface;
	logic [`AXI_DATA_BITS-1:0] WDATA;
	logic [`AXI_STRB_BITS-1:0] WSTRB;
	logic                      WLAST;
	logic                      WVALID;
	logic                      WREADY;

    //AXI W
    modport M1 (input WDATA, input WSTRB, input WLAST, input WVALID, output WREADY);

    modport S1       (output WDATA, output WSTRB, output WLAST, output WVALID, input WREADY);
    modport S2       (output WDATA, output WSTRB, output WLAST, output WVALID, input WREADY);
    modport SDEFAULT (output WDATA, output WSTRB, output WLAST, output WVALID, input WREADY);

    //for CPU_wrapper
    modport DM (output WDATA, output WSTRB, output WLAST, output WVALID, input WREADY);

    //for SRAM_wrapper
    modport SRAM (input WDATA, input WSTRB, input WLAST, input WVALID, output WREADY);

    //for DEFAULT slave
    modport Default_Slave (input WDATA, input WSTRB, input WLAST, input WVALID, output WREADY);
endinterface

interface B_interface;
	logic [  `AXI_ID_BITS-1:0] BID;
	logic [ `AXI_IDS_BITS-1:0] BID_S;
	logic [               1:0] BRESP;
	logic BVALID;
	logic BREADY;

    //AXI B
    modport M1 (output BID, output BRESP, output BVALID, input BREADY);

    modport S1       (input BID_S, input BRESP, input BVALID, output BREADY);
    modport S2       (input BID_S, input BRESP, input BVALID, output BREADY);
    modport SDEFAULT (input BID_S, input BRESP, input BVALID, output BREADY);

    //for CPU_wrapper
    modport DM (input BID, input BRESP, input BVALID, output BREADY);

    //for SRAM_wrapper
    modport SRAM (output BID_S, output BRESP, output BVALID, input BREADY);

    //for DEFAULT slave
    modport Default_Slave (output BID_S, output BRESP, output BVALID, input BREADY);
endinterface