`include "CPU.sv"
`include "IM_Master.sv"
`include "DM_Master.sv"

module CPU_wrapper (
    input logic     ACLK,
    input logic     ARESETn,
    
    AR_interface.IM M0_AR,
    R_interface.IM  M0_R,

    AR_interface.DM M1_AR,
    R_interface.DM  M1_R,
    AW_interface.DM M1_AW,
    W_interface.DM  M1_W,
    B_interface.DM  M1_B,

    input logic     DMA_interrupt,
    input logic     WDT_timeout
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

CPU i_CPU(
    .clk                  (ACLK),
    .rst                  (~ARESETn),

    .Instruction_addr     (imem_addr),
    .Instruciton_data     (imem_rdata),

    .DM_CEB               (DM_CEB),
    .DM_WEB               (DM_WEB),
    .DM_BWEB              (DM_BWEB),
    .Data_addr            (dmem_addr),
    .Data_out             (dmem_wdata),
    .Data_in              (dmem_rdata),

    .instruction_fetch_sig(instruction_fetch_sig),
    .MEM_MemRead          (MEM_MemRead),
    .MEM_MemWrite         (MEM_MemWrite),
    
    .IM_stall             (IM_stall),
    .DM_stall             (DM_stall),
    .DMA_interrupt        (DMA_interrupt),
    .WDT_timeout          (WDT_timeout)
);

IM_Master M0( //Instruction Memory Master
    .clk      (ACLK),
    .rstn     (ARESETn),

    .read     (instruction_fetch_sig),

    .addr_in  (imem_addr),

    .data_out (imem_rdata),
    .stall    (IM_stall),

        
    .ARID_M   (M0_AR.ARID),
    .ARADDR_M (M0_AR.ARADDR),
    .ARLEN_M  (M0_AR.ARLEN),
    .ARSIZE_M (M0_AR.ARSIZE),
    .ARBURST_M(M0_AR.ARBURST),
    .ARVALID_M(M0_AR.ARVALID),
    .ARREADY_M(M0_AR.ARREADY),
        
    .RID_M    (M0_R.RID),
    .RDATA_M  (M0_R.RDATA),
    .RRESP_M  (M0_R.RRESP),
    .RLAST_M  (M0_R.RLAST),
    .RVALID_M (M0_R.RVALID),
    .RREADY_M (M0_R.RREADY)
);

DM_Master M1( //Data Memory Master
    .clk           (ACLK),
    .rstn          (ARESETn),

    .read          (MEM_MemRead),
    .write         (MEM_MemWrite),
    .DM_BWEB       (DM_BWEB),
    .data_in       (dmem_wdata),
    .addr_in       (dmem_addr),

    .data_out      (dmem_rdata),
    .stall         (DM_stall),

    .AWID_M        (M1_AW.AWID),
    .AWADDR_M      (M1_AW.AWADDR),
    .AWLEN_M       (M1_AW.AWLEN),
    .AWSIZE_M      (M1_AW.AWSIZE),
    .AWBURST_M     (M1_AW.AWBURST),
    .AWVALID_M     (M1_AW.AWVALID),
    .AWREADY_M     (M1_AW.AWREADY),
        
    .WDATA_M       (M1_W.WDATA),
    .WSTRB_M       (M1_W.WSTRB),
    .WLAST_M       (M1_W.WLAST),
    .WVALID_M      (M1_W.WVALID),
    .WREADY_M      (M1_W.WREADY),
        
    .BID_M         (M1_B.BID),
    .BRESP_M       (M1_B.BRESP),
    .BVALID_M      (M1_B.BVALID),
    .BREADY_M      (M1_B.BREADY),
        
    .ARID_M        (M1_AR.ARID),
    .ARADDR_M      (M1_AR.ARADDR),
    .ARLEN_M       (M1_AR.ARLEN),
    .ARSIZE_M      (M1_AR.ARSIZE),
    .ARBURST_M     (M1_AR.ARBURST),
    .ARVALID_M     (M1_AR.ARVALID),
    .ARREADY_M     (M1_AR.ARREADY),
        
    .RID_M         (M1_R.RID),
    .RDATA_M       (M1_R.RDATA),
    .RRESP_M       (M1_R.RRESP),
    .RLAST_M       (M1_R.RLAST),
    .RVALID_M      (M1_R.RVALID),
    .RREADY_M      (M1_R.RREADY)
);

endmodule