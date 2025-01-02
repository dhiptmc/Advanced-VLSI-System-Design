`include "../include/def.svh"
`include "../include/AXI_define.svh"

`include "CPU.sv"
`include "IM_Master.sv"
`include "DM_Master.sv"

module CPU_wrapper (
    input  logic ACLK,
    input  logic ARESETn,

	//WRITE ADDRESS1
	output logic [`AXI_ID_BITS-1:0] AWID_M1,		//Bits of master is 4 and for slave is 8, see A5-80 in spec
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_M1,		//Burst length.
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,	//Burst size.
	output logic [1:0] AWBURST_M1,					//Burst type. Only need to implement INCR type.
	output logic AWVALID_M1,
	input  logic AWREADY_M1,
	
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,		//Write strobes. 4 bits because 32/8 = 4
	output logic WLAST_M1,							//Write last. This signal indicates the last transfer in a write burst.
	output logic WVALID_M1,
	input  logic WREADY_M1,
	
	//WRITE RESPONSE1
	input  logic [`AXI_ID_BITS-1:0] BID_M1,			//Bits of master is 4 and for slave is 8, see A5-80 in spec
	input  logic [1:0] BRESP_M1,					//Write response. This signal indicates the status of the write transaction.
	input  logic BVALID_M1,
	output logic BREADY_M1,

	// //WRITE ADDRESS0
	// output logic [`AXI_ID_BITS-1:0] AWID_M0,
	// output logic [`AXI_ADDR_BITS-1:0] AWADDR_M0,
	// output logic [`AXI_LEN_BITS-1:0] AWLEN_M0,
	// output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M0,
	// output logic [1:0] AWBURST_M0,
	// output logic AWVALID_M0,
	// input  logic AWREADY_M0,
	
	// //WRITE DATA0
	// output logic [`AXI_DATA_BITS-1:0] WDATA_M0,
	// output logic [`AXI_STRB_BITS-1:0] WSTRB_M0,
	// output logic WLAST_M0,
	// output logic WVALID_M0,
	// input  logic WREADY_M0,
	
	// //WRITE RESPONSE0
	// input  logic [`AXI_ID_BITS-1:0] BID_M0,
	// input  logic [1:0] BRESP_M0,
	// input  logic BVALID_M0,
	// output logic BREADY_M0,

	//READ ADDRESS0
	output logic [`AXI_ID_BITS-1:0] ARID_M0,		//Bits of master is 4 and for slave is 8, see A5-80 in spec
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,			
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M0,		//Burst length.
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,	//Burst size.
	output logic [1:0] ARBURST_M0,					//Burst type. Only need to implement INCR type.
	output logic ARVALID_M0,
	input  logic ARREADY_M0,
	
	//READ DATA0
	input  logic [`AXI_ID_BITS-1:0] RID_M0,			//Bits of master is 4 and for slave is 8, see A5-80 in spec
	input  logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	input  logic [1:0] RRESP_M0,					//Read response. This signal indicates the status of the read transfer.
	input  logic RLAST_M0,							//Read last. This signal indicates the last transfer in a read burst.
	input  logic RVALID_M0,
	output logic RREADY_M0,
	
	//READ ADDRESS1
	output logic [`AXI_ID_BITS-1:0] ARID_M1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	output logic [1:0] ARBURST_M1,
	output logic ARVALID_M1,
	input  logic ARREADY_M1,
	
	//READ DATA1
	input  logic [`AXI_ID_BITS-1:0] RID_M1,
	input  logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	input  logic [1:0] RRESP_M1,
	input  logic RLAST_M1,
	input  logic RVALID_M1,
	output logic RREADY_M1
);

logic [`InstructionAddrBus] imem_addr;
logic [    `InstructionBus] imem_rdata;

logic                       DM_CEB;
logic                       DM_WEB;
logic [           `BWEBBus] DM_BWEB;
logic [       `DataAddrBus] dmem_addr;
logic [           `DataBus] dmem_wdata;
logic [           `DataBus] dmem_rdata;

logic                       instruction_fetch_sig;
logic                       MEM_MemRead;
logic                       MEM_MemWrite;

logic                       IM_stall;
logic                       DM_stall;

logic                       lock_DM;

always_ff @ (posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)
        lock_DM <= 1'b0;
    else
        lock_DM <= (!IM_stall) ? 1'b0 : ( (!DM_stall) ? 1'b1 : lock_DM);
        //if    IM_stall is 0 -> IM master done, then DM can do things (lock = 0)
        //else  IM_stall is 1 -> IM master not done, if DM not done then keep moving else set lock on DM to prevent further DM action.
end

logic  RW_synchr_lock; // IM read and DM write to same slave
assign RW_synchr_lock = (ARVALID_M0 && AWVALID_M1) ? ( (ARADDR_M0[16] == AWADDR_M1[16]) ? 1'b1 : 1'b0) : 1'b0;


CPU i_CPU(
    .clk(ACLK),
    .rst(~ARESETn),

    .Instruction_addr(imem_addr),
    .Instruciton_data(imem_rdata),

    .DM_CEB(DM_CEB),
    .DM_WEB(DM_WEB),
    .DM_BWEB(DM_BWEB),
    .Data_addr(dmem_addr),
    .Data_out(dmem_wdata),
    .Data_in(dmem_rdata),

    .instruction_fetch_sig(instruction_fetch_sig),
    .MEM_MemRead(MEM_MemRead),
    .MEM_MemWrite(MEM_MemWrite),
    
    .IM_stall(IM_stall),
    .DM_stall(DM_stall)
);

IM_Master M0( //Instruction Memory Master
    .clk(ACLK),
    .rstn(ARESETn),

    .read(instruction_fetch_sig),
    // .write(1'b0),
    // .DM_BWEB(DM_BWEB),
    // .data_in(`AXI_DATA_BITS'd0),
    .addr_in(imem_addr),

    .data_out(imem_rdata),
    .stall(IM_stall),

    // .AWID_M(AWID_M0),
    // .AWADDR_M(AWADDR_M0),
    // .AWLEN_M(AWLEN_M0),
    // .AWSIZE_M(AWSIZE_M0),
    // .AWBURST_M(AWBURST_M0),
    // .AWVALID_M(AWVALID_M0),
    // .AWREADY_M(AWREADY_M0),
        
    // .WDATA_M(WDATA_M0),
    // .WSTRB_M(WSTRB_M0),
    // .WLAST_M(WLAST_M0),
    // .WVALID_M(WVALID_M0),
    // .WREADY_M(WREADY_M0),
        
    // .BID_M(BID_M0),
    // .BRESP_M(BRESP_M0),
    // .BVALID_M(BVALID_M0),
    // .BREADY_M(BREADY_M0),
        
    .ARID_M(ARID_M0),
    .ARADDR_M(ARADDR_M0),
    .ARLEN_M(ARLEN_M0),
    .ARSIZE_M(ARSIZE_M0),
    .ARBURST_M(ARBURST_M0),
    .ARVALID_M(ARVALID_M0),
    .ARREADY_M(ARREADY_M0),
        
    .RID_M(RID_M0),
    .RDATA_M(RDATA_M0),
    .RRESP_M(RRESP_M0),
    .RLAST_M(RLAST_M0),
    .RVALID_M(RVALID_M0),
    .RREADY_M(RREADY_M0)
);

DM_Master M1( //Data Memory Master
    .clk(ACLK),
    .rstn(ARESETn),

    .read(MEM_MemRead & (~lock_DM)),
    .write(MEM_MemWrite & (~lock_DM)),
    .DM_BWEB(DM_BWEB),
    .data_in(dmem_wdata),
    .addr_in(dmem_addr),

    .data_out(dmem_rdata),
    .stall(DM_stall),

    .AWID_M(AWID_M1),
    .AWADDR_M(AWADDR_M1),
    .AWLEN_M(AWLEN_M1),
    .AWSIZE_M(AWSIZE_M1),
    .AWBURST_M(AWBURST_M1),
    .AWVALID_M(AWVALID_M1),
    .AWREADY_M(AWREADY_M1),
        
    .WDATA_M(WDATA_M1),
    .WSTRB_M(WSTRB_M1),
    .WLAST_M(WLAST_M1),
    .WVALID_M(WVALID_M1),
    .WREADY_M(WREADY_M1),
        
    .BID_M(BID_M1),
    .BRESP_M(BRESP_M1),
    .BVALID_M(BVALID_M1),
    .BREADY_M(BREADY_M1),
        
    .ARID_M(ARID_M1),
    .ARADDR_M(ARADDR_M1),
    .ARLEN_M(ARLEN_M1),
    .ARSIZE_M(ARSIZE_M1),
    .ARBURST_M(ARBURST_M1),
    .ARVALID_M(ARVALID_M1),
    .ARREADY_M(ARREADY_M1),
        
    .RID_M(RID_M1),
    .RDATA_M(RDATA_M1),
    .RRESP_M(RRESP_M1),
    .RLAST_M(RLAST_M1),
    .RVALID_M(RVALID_M1),
    .RREADY_M(RREADY_M1),

    .RW_synchr_lock(RW_synchr_lock)
);

endmodule