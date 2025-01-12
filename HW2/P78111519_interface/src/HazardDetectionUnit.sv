module HazardDetectionUnit (
    input  logic [ `PCTypeBus] PCSrc,
    input  logic               EXE_MemRead,

    input  logic [`RegAddrBus] rs1_addr,
    input  logic [`RegAddrBus] rs2_addr,
    input  logic [`RegAddrBus] EXE_rd_addr,

    output logic               PCWrite,
    output logic               IF_Flush,
    output logic               IF_ID_Reg_Write,
    output logic               ID_Flush, //because we branch in EXE
    
    output logic               lw_use,   // for CSR

    input  logic               IM_stall,
    input  logic               DM_stall,
    output logic               Hazardstall_flag,

    output logic               ID_EXE_Reg_Write,
    output logic               EXE_MEM_Reg_Write,
    output logic               MEM_WB_Reg_Write
);

localparam [       `PCTypeBus] PC_4       = 2'b00,
                               PC_imm     = 2'b01, 
                               PC_imm_rs1 = 2'b10;

assign lw_use           = ( EXE_MemRead && ((EXE_rd_addr == rs1_addr) || (EXE_rd_addr == rs2_addr)) );
assign Hazardstall_flag = (IM_stall || DM_stall);

always_comb
begin
    if(IM_stall || DM_stall)
    begin
        PCWrite           = 1'b0;
        IF_Flush          = 1'b0;
        IF_ID_Reg_Write   = 1'b0;
        ID_Flush          = 1'b0;
        ID_EXE_Reg_Write  = 1'b0;
        EXE_MEM_Reg_Write = 1'b0;
        MEM_WB_Reg_Write  = 1'b0;
    end
    else if(PCSrc != 2'b00) //branch taken
    begin
        PCWrite           = 1'b1;
        IF_Flush          = 1'b1;
        IF_ID_Reg_Write   = 1'b1;
        ID_Flush          = 1'b1;
        ID_EXE_Reg_Write  = 1'b1;
        EXE_MEM_Reg_Write = 1'b1;
        MEM_WB_Reg_Write  = 1'b1;
    end
    else if ( EXE_MemRead && ((EXE_rd_addr == rs1_addr) || (EXE_rd_addr == rs2_addr)) )
    begin
        PCWrite           = 1'b0;
        IF_Flush          = 1'b0;
        IF_ID_Reg_Write   = 1'b0;
        ID_Flush          = 1'b1;
        ID_EXE_Reg_Write  = 1'b1;
        EXE_MEM_Reg_Write = 1'b1;
        MEM_WB_Reg_Write  = 1'b1;
    end
    else
    begin
        PCWrite           = 1'b1;
        IF_Flush          = 1'b0;
        IF_ID_Reg_Write   = 1'b1;
        ID_Flush          = 1'b0;
        ID_EXE_Reg_Write  = 1'b1;
        EXE_MEM_Reg_Write = 1'b1;
        MEM_WB_Reg_Write  = 1'b1;
    end
end

endmodule