module ForwardingUnit (
    input  logic [      `RegAddrBus] EXE_rs1_addr,
    input  logic [      `RegAddrBus] EXE_rs2_addr,
    input  logic [      `RegAddrBus] MEM_rd_addr,
    input  logic [      `RegAddrBus] WB_rd_addr,
    
    input  logic                     EXE_gen_fp_rs1_sel,
    input  logic                     EXE_gen_fp_rs2_sel,
    input  logic                     MEM_gen_reg_write,
    input  logic                     MEM_fp_reg_write,
    input  logic                     WB_gen_reg_write,
    input  logic                     WB_fp_reg_write,

    output logic [`ForwardSelectBus] ForwardA,
    output logic [`ForwardSelectBus] ForwardB     
);

always_comb
begin
    if(EXE_rs1_addr == `RegNumLog2'd0)
        ForwardA = 2'b00;
    else if( ( ( MEM_gen_reg_write && (!EXE_gen_fp_rs1_sel == MEM_gen_reg_write) ) || ( MEM_fp_reg_write && (EXE_gen_fp_rs1_sel == MEM_fp_reg_write) ) ) && (MEM_rd_addr == EXE_rs1_addr) )
        ForwardA = 2'b10; //From MEM
    else if ( ( ( WB_gen_reg_write && (!EXE_gen_fp_rs1_sel == WB_gen_reg_write) ) || ( WB_fp_reg_write && (EXE_gen_fp_rs1_sel == WB_fp_reg_write) ) ) && (WB_rd_addr == EXE_rs1_addr) )
        ForwardA = 2'b01; //From WB
    else
        ForwardA = 2'b00;
end

always_comb
begin
    if(EXE_rs2_addr == `RegNumLog2'd0)
        ForwardB = 2'b00;
    else if( ( ( MEM_gen_reg_write && (!EXE_gen_fp_rs2_sel == MEM_gen_reg_write) ) || ( MEM_fp_reg_write && (EXE_gen_fp_rs2_sel == MEM_fp_reg_write) ) ) && (MEM_rd_addr == EXE_rs2_addr) )
        ForwardB = 2'b10; //From MEM
    else if ( ( ( WB_gen_reg_write && (!EXE_gen_fp_rs2_sel == WB_gen_reg_write) ) || ( WB_fp_reg_write && (EXE_gen_fp_rs2_sel == WB_fp_reg_write) ) ) && (WB_rd_addr == EXE_rs2_addr) )
        ForwardB = 2'b01; //From WB
    else
        ForwardB = 2'b00;
end

endmodule