`include "IF_Stage.sv"
`include "IF_ID_Reg.sv"
`include "ID_Stage.sv"
`include "ID_EXE_Reg.sv"
`include "EXE_Stage.sv"
`include "EXE_MEM_Reg.sv"
`include "MEM_Stage.sv"
`include "MEM_WB_Reg.sv"
`include "WB_Stage.sv"

`include "BranchControl.sv"
`include "ForwardingUnit.sv"
`include "HazardDetectionUnit.sv"
`include "CSR.sv"

module CPU (
    input  logic clk,
    input  logic rst,

    output logic [`InstructionAddrBus] Instruction_addr,
    input  logic [    `InstructionBus] Instruciton_data,
    
    output logic                       DM_CEB,
    output logic                       DM_WEB,
    output logic [           `BWEBBus] DM_BWEB,
    output logic [       `DataAddrBus] Data_addr,
    output logic [           `DataBus] Data_out,
    input  logic [           `DataBus] Data_in,

    output logic                       instruction_fetch_sig,
    output logic                       MEM_MemRead,
    output logic                       MEM_MemWrite,

    input  logic                       IM_stall,
    input  logic                       DM_stall,

    input  logic                       DMA_interrupt,
    input  logic                       WDT_timeout
);

/*IF Stage*/
logic [  `InstructionBus] IF_ID_instruction;

/*IF/ID Register*/  
logic [          `RegBus] ID_PC_out;
logic [  `InstructionBus] ID_instruction;
wire  [      `RegAddrBus] rs1_addr;
wire  [      `RegAddrBus] rs2_addr;
wire  [      `RegAddrBus] rd_addr;
wire  [     `OPCODE -1:0] opcode;
wire  [  `FUNCTION_3-1:0] funct3;
wire  [  `FUNCTION_7-1:0] funct7;
wire  [             11:0] csr_addr;

/*ID Stage*/
logic [          `RegBus] rs1_data;
logic [          `RegBus] rs2_data;
logic [          `RegBus] Imm_out;
logic [      `ALUTypeBus] ALU_mode;
logic                     EXE_PC_sel;
logic                     ALUSrc;
logic [   `BranchTypeBus] branch_signal;
logic                     MEM_rd_sel;
logic                     gen_fp_rs1_sel;
logic                     gen_fp_rs2_sel;
logic                     MemRead;
logic                     MemWrite;
logic                     gen_reg_write;
logic                     fp_reg_write;
logic                     WB_data_sel;
logic                     CSR_sel;
logic [          `RegBus] ID_EXE_PC_out;

/*ID/EXE Register*/
logic [      `RegAddrBus] EXE_rs1_addr; 
logic [          `RegBus] EXE_rs1_data;
logic [      `RegAddrBus] EXE_rs2_addr;
logic [          `RegBus] EXE_rs2_data;
logic [      `RegAddrBus] EXE_rd_addr;
logic [  `FUNCTION_3-1:0] EXE_funct3;
logic [  `FUNCTION_7-1:0] EXE_funct7;
logic [          `RegBus] EXE_Imm_out;
logic [      `ALUTypeBus] EXE_ALU_mode;
logic                     EXE_EXE_PC_sel;
logic                     EXE_ALUSrc;
logic [   `BranchTypeBus] EXE_branch_signal;
logic                     EXE_MEM_rd_sel;
logic                     EXE_gen_fp_rs1_sel;
logic                     EXE_gen_fp_rs2_sel;
logic                     EXE_MemRead;
logic                     EXE_MemWrite;
logic                     EXE_gen_reg_write;
logic                     EXE_fp_reg_write;
logic                     EXE_WB_data_sel;
logic                     EXE_CSR_sel;
logic [          `RegBus] EXE_PC_out;
logic [             11:0] EXE_csr_addr;
logic [              1:0] EXE_CSR_type;

/*EXE Stage*/
logic                     EXE_MEM_MEM_rd_sel;
logic                     EXE_MEM_MemRead;
logic                     EXE_MEM_MemWrite;
logic                     EXE_MEM_gen_reg_write; 
logic                     EXE_MEM_fp_reg_write;
logic                     EXE_MEM_WB_data_sel;
logic [          `RegBus] PC_imm;
logic [          `RegBus] PC_imm_rs1;
logic                     branch_taken_flag;
logic [`FUNCTION_3 - 1:0] EXE_MEM_funct3;
logic [      `RegAddrBus] EXE_MEM_rd_addr;
logic [          `RegBus] PC_sel_out;
logic [          `RegBus] ALU_final;
logic [          `RegBus] EXE_mux_rs2_data;
logic [          `RegBus] ALU_rs1_data;

/*EXE/MEM Register*/
logic                     MEM_MEM_rd_sel;
logic                     MEM_gen_reg_write; 
logic                     MEM_fp_reg_write;
logic                     MEM_WB_data_sel;
logic [`FUNCTION_3 - 1:0] MEM_funct3;
logic [      `RegAddrBus] MEM_rd_addr;
logic [          `RegBus] MEM_PC_sel_out;
logic [          `RegBus] MEM_ALU_final;
logic [          `RegBus] MEM_EXE_mux_rs2_data;

/*MEM Stage*/
logic                     MEM_WB_gen_reg_write; 
logic                     MEM_WB_fp_reg_write;
logic                     MEM_WB_WB_data_sel;
logic [      `RegAddrBus] MEM_WB_rd_addr;
logic [          `RegBus] MEM_rd_data;
logic [          `RegBus] DM_rd_data;

/*MEM/WB Register*/
logic                     WB_gen_reg_write; 
logic                     WB_fp_reg_write;
logic                     WB_WB_data_sel;
logic [      `RegAddrBus] WB_rd_addr;
logic [          `RegBus] WB_MEM_rd_data;
logic [          `RegBus] WB_DM_rd_data;

/*WB Stage*/
logic [          `RegBus] WB_rd_data;

/*BranchControl*/
logic [       `PCTypeBus] PCSrc;

/*ForwardingUnit*/
logic [`ForwardSelectBus] ForwardA;
logic [`ForwardSelectBus] ForwardB;

/*HazardDetectionUnit*/
logic                     PCWrite;
logic                     IF_Flush;
logic                     IF_ID_Reg_Write;
logic                     ID_Flush;
logic                     Hazardstall_flag;
logic                     EXE_MEM_Reg_Write;
logic                     MEM_WB_Reg_Write;
logic [              1:0] CSR_type;

/*CSR*/
logic [          `RegBus] CSR_return_PC;
logic [          `RegBus] CSR_ISR_PC;
logic                     CSR_stall;
logic                     CSR_interrupt;
logic                     CSR_ret;
logic                     CSR_rst;
logic [          `RegBus] CSR_rd_data;


/*Initiate submodule*/
IF_Stage i_IF_Stage(
    .clk(clk),
    .rst(rst),

    .PCSrc(PCSrc),

    .PCWrite(PCWrite),

    .IM_instruction(Instruciton_data),

    .PC_imm(PC_imm),
    .PC_imm_rs1(PC_imm_rs1),

    .PC_out_IM(Instruction_addr),
    .IF_ID_instruction(IF_ID_instruction),
    .instruction_fetch_sig(instruction_fetch_sig),

    .CSR_return_PC(CSR_return_PC),
    .CSR_ISR_PC(CSR_ISR_PC),
    .CSR_stall(CSR_stall),
    .CSR_interrupt(CSR_interrupt),
    .CSR_ret(CSR_ret),
    .CSR_rst(CSR_rst)
);

IF_ID_Reg i_IF_ID_Reg(
    .clk(clk),
    .rst(rst),

    .IF_ID_Reg_Write(IF_ID_Reg_Write),
    .IF_Flush(IF_Flush),

    .IF_ID_PC_out(Instruction_addr),
    .IF_ID_instruction(IF_ID_instruction),

    .ID_PC_out(ID_PC_out),
    .ID_instruction(ID_instruction),

    .CSR_stall(CSR_stall),
    .CSR_rst(CSR_rst),

    .Hazardstall_flag(Hazardstall_flag),

    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .rd_addr(rd_addr),
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .csr_addr(csr_addr)
);

ID_Stage i_ID_Stage (
    .clk(clk),
    .rst(rst),

    .ID_PC_out(ID_PC_out),
    .ID_instruction(ID_instruction),

    .regwrite_gen(WB_gen_reg_write),
    .regwrite_fp(WB_fp_reg_write),
    .reg_rd_addr(WB_rd_addr),
    .reg_rd_data(WB_rd_data),

    .rs1_addr(rs1_addr),
    .rs1_data(rs1_data),

    .rs2_addr(rs2_addr),
    .rs2_data(rs2_data),

    .rd_addr(rd_addr),

    .funct3(funct3),
    .funct7(funct7),
    .Imm_out(Imm_out),

    .ALU_mode(ALU_mode),
    .EXE_PC_sel(EXE_PC_sel),
    .ALUSrc(ALUSrc),       
    .branch_signal(branch_signal),
    .MEM_rd_sel(MEM_rd_sel),
    .gen_fp_rs1_sel(gen_fp_rs1_sel),
    .gen_fp_rs2_sel(gen_fp_rs2_sel),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .gen_reg_write(gen_reg_write),
    .fp_reg_write(fp_reg_write),
    .WB_data_sel(WB_data_sel),
    .CSR_sel(CSR_sel),  

    .ID_EXE_PC_out(ID_EXE_PC_out),
    
    .csr_addr(csr_addr),

    .opcode(opcode)
);

ID_EXE_Reg i_ID_EXE_Reg(
    .clk(clk),
    .rst(rst),
    
    .ID_Flush(ID_Flush),

    .rs1_addr(rs1_addr),
    .rs1_data(rs1_data),

    .rs2_addr(rs2_addr),
    .rs2_data(rs2_data),

    .rd_addr(rd_addr),

    .funct3(funct3),
    .funct7(funct7),
    .Imm_out(Imm_out),

    .ALU_mode(ALU_mode),
    .EXE_PC_sel(EXE_PC_sel),
    .ALUSrc(ALUSrc),       
    .branch_signal(branch_signal),
    .MEM_rd_sel(MEM_rd_sel),
    .gen_fp_rs1_sel(gen_fp_rs1_sel),
    .gen_fp_rs2_sel(gen_fp_rs2_sel),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .gen_reg_write(gen_reg_write),
    .fp_reg_write(fp_reg_write),
    .WB_data_sel(WB_data_sel),
    .CSR_sel(CSR_sel),

    .ID_EXE_PC_out(ID_EXE_PC_out),

    .csr_addr(csr_addr),

    .CSR_type(CSR_type),

    .EXE_rs1_addr(EXE_rs1_addr),
    .EXE_rs1_data(EXE_rs1_data),

    .EXE_rs2_addr(EXE_rs2_addr),
    .EXE_rs2_data(EXE_rs2_data),

    .EXE_rd_addr(EXE_rd_addr),

    .EXE_funct3(EXE_funct3),
    .EXE_funct7(EXE_funct7),
    .EXE_Imm_out(EXE_Imm_out),

    .EXE_ALU_mode(EXE_ALU_mode),
    .EXE_EXE_PC_sel(EXE_EXE_PC_sel),
    .EXE_ALUSrc(EXE_ALUSrc),       
    .EXE_branch_signal(EXE_branch_signal),
    .EXE_MEM_rd_sel(EXE_MEM_rd_sel),
    .EXE_gen_fp_rs1_sel(EXE_gen_fp_rs1_sel),
    .EXE_gen_fp_rs2_sel(EXE_gen_fp_rs2_sel),
    .EXE_MemRead(EXE_MemRead),
    .EXE_MemWrite(EXE_MemWrite),
    .EXE_gen_reg_write(EXE_gen_reg_write),
    .EXE_fp_reg_write(EXE_fp_reg_write),
    .EXE_WB_data_sel(EXE_WB_data_sel),
    .EXE_CSR_sel(EXE_CSR_sel),

    .EXE_PC_out(EXE_PC_out),

    .EXE_csr_addr(EXE_csr_addr),

    .EXE_CSR_type(EXE_CSR_type),

    .Hazardstall_flag(Hazardstall_flag),   
    .CSR_stall(CSR_stall)
);

EXE_Stage i_EXE_Stage(
    .EXE_rs1_data(EXE_rs1_data),
    .EXE_rs2_data(EXE_rs2_data),
    .EXE_rd_addr(EXE_rd_addr),

    .EXE_funct3(EXE_funct3),
    .EXE_funct7(EXE_funct7),
    .EXE_Imm_out(EXE_Imm_out),

    .EXE_ALU_mode(EXE_ALU_mode),
    .EXE_EXE_PC_sel(EXE_EXE_PC_sel),
    .EXE_ALUSrc(EXE_ALUSrc),
    .EXE_MEM_rd_sel(EXE_MEM_rd_sel),
    .EXE_MemRead(EXE_MemRead),
    .EXE_MemWrite(EXE_MemWrite),
    .EXE_gen_reg_write(EXE_gen_reg_write),
    .EXE_fp_reg_write(EXE_fp_reg_write),
    .EXE_WB_data_sel(EXE_WB_data_sel),   

    .EXE_PC_out(EXE_PC_out),
    
    .EXE_MEM_MEM_rd_sel(EXE_MEM_MEM_rd_sel),
    .EXE_MEM_MemRead(EXE_MEM_MemRead),
    .EXE_MEM_MemWrite(EXE_MEM_MemWrite),
    .EXE_MEM_gen_reg_write(EXE_MEM_gen_reg_write), 
    .EXE_MEM_fp_reg_write(EXE_MEM_fp_reg_write),
    .EXE_MEM_WB_data_sel(EXE_MEM_WB_data_sel), 


    .ForwardA(ForwardA),
    .ForwardB(ForwardB),


    .MEM_rd_data(MEM_rd_data),
    .WB_rd_data(WB_rd_data),


    .PC_imm(PC_imm),
    .PC_imm_rs1(PC_imm_rs1),
    .branch_taken_flag(branch_taken_flag),

    .EXE_MEM_funct3(EXE_MEM_funct3),
    .EXE_MEM_rd_addr(EXE_MEM_rd_addr),

    .PC_sel_out(PC_sel_out),
    .ALU_final(ALU_final),
    .EXE_mux_rs2_data(EXE_mux_rs2_data),

    .ALU_rs1_data(ALU_rs1_data),

    .CSR_rd_data(CSR_rd_data),
    .EXE_CSR_sel(EXE_CSR_sel)
);

EXE_MEM_Reg i_EXE_MEM_Reg(
    .clk(clk),
    .rst(rst),

    .EXE_MEM_Reg_Write(EXE_MEM_Reg_Write),

    .EXE_MEM_MEM_rd_sel(EXE_MEM_MEM_rd_sel),
    .EXE_MEM_MemRead(EXE_MEM_MemRead),
    .EXE_MEM_MemWrite(EXE_MEM_MemWrite),
    .EXE_MEM_gen_reg_write(EXE_MEM_gen_reg_write), 
    .EXE_MEM_fp_reg_write(EXE_MEM_fp_reg_write),
    .EXE_MEM_WB_data_sel(EXE_MEM_WB_data_sel), 

    .EXE_MEM_funct3(EXE_MEM_funct3),
    .EXE_MEM_rd_addr(EXE_MEM_rd_addr),

    .PC_sel_out(PC_sel_out),
    .ALU_final(ALU_final),
    .EXE_mux_rs2_data(EXE_mux_rs2_data),

    .MEM_MEM_rd_sel(MEM_MEM_rd_sel),
    .MEM_MemRead(MEM_MemRead),
    .MEM_MemWrite(MEM_MemWrite),
    .MEM_gen_reg_write(MEM_gen_reg_write), 
    .MEM_fp_reg_write(MEM_fp_reg_write),
    .MEM_WB_data_sel(MEM_WB_data_sel), 

    .MEM_funct3(MEM_funct3),
    .MEM_rd_addr(MEM_rd_addr),

    .MEM_PC_sel_out(MEM_PC_sel_out),
    .MEM_ALU_final(MEM_ALU_final),
    .MEM_EXE_mux_rs2_data(MEM_EXE_mux_rs2_data),

    .CSR_rst(CSR_rst),

    .IM_stall(IM_stall),
    .DM_stall(DM_stall),
    .CSR_stall(CSR_stall)
);

MEM_Stage i_MEM_Stage(
    .MEM_MEM_rd_sel(MEM_MEM_rd_sel),
    .MEM_MemRead(MEM_MemRead),
    .MEM_MemWrite(MEM_MemWrite),
    .MEM_gen_reg_write(MEM_gen_reg_write), 
    .MEM_fp_reg_write(MEM_fp_reg_write),
    .MEM_WB_data_sel(MEM_WB_data_sel), 

    .MEM_funct3(MEM_funct3),
    .MEM_rd_addr(MEM_rd_addr),

    .MEM_PC_sel_out(MEM_PC_sel_out),
    .MEM_ALU_final(MEM_ALU_final),
    .MEM_EXE_mux_rs2_data(MEM_EXE_mux_rs2_data),

    .MEM_WB_gen_reg_write(MEM_WB_gen_reg_write), 
    .MEM_WB_fp_reg_write(MEM_WB_fp_reg_write),
    .MEM_WB_WB_data_sel(MEM_WB_WB_data_sel), 

    .DM_CEB(DM_CEB),        
    .DM_WEB(DM_WEB),        
    .DM_BWEB(DM_BWEB),       
    .Data_addr(Data_addr),
    .Data_in(Data_in),
    .Data_out(Data_out),      

    .MEM_WB_rd_addr(MEM_WB_rd_addr),
    .MEM_rd_data(MEM_rd_data),   
    .DM_rd_data(DM_rd_data) 
);

MEM_WB_Reg i_MEM_WB_Reg(
    .clk(clk),
    .rst(rst),

    .MEM_WB_Reg_Write(MEM_WB_Reg_Write),

    .MEM_WB_gen_reg_write(MEM_WB_gen_reg_write), 
    .MEM_WB_fp_reg_write(MEM_WB_fp_reg_write),
    .MEM_WB_WB_data_sel(MEM_WB_WB_data_sel),

    .MEM_WB_rd_addr(MEM_WB_rd_addr),
    .MEM_rd_data(MEM_rd_data),
    .DM_rd_data(DM_rd_data),

    .WB_gen_reg_write(WB_gen_reg_write), 
    .WB_fp_reg_write(WB_fp_reg_write),
    .WB_WB_data_sel(WB_WB_data_sel),

    .WB_rd_addr(WB_rd_addr),
    .WB_MEM_rd_data(WB_MEM_rd_data),
    .WB_DM_rd_data(WB_DM_rd_data),

    .CSR_rst(CSR_rst)
);

WB_Stage i_WB_Stage(
    .WB_WB_data_sel(WB_WB_data_sel),
    .WB_MEM_rd_data(WB_MEM_rd_data),
    .WB_DM_rd_data(WB_DM_rd_data),
    .WB_rd_data(WB_rd_data)
);

BranchControl i_BranchControl (
    .branch_taken_flag(branch_taken_flag),
    .branch_signal(EXE_branch_signal),
    .PCSrc(PCSrc)
);

ForwardingUnit i_ForwardingUnit (
    .EXE_rs1_addr(EXE_rs1_addr),
    .EXE_rs2_addr(EXE_rs2_addr),
    .MEM_rd_addr(MEM_rd_addr),
    .WB_rd_addr(WB_rd_addr),
        
    .EXE_gen_fp_rs1_sel(EXE_gen_fp_rs1_sel),
    .EXE_gen_fp_rs2_sel(EXE_gen_fp_rs2_sel),   
    .MEM_gen_reg_write(MEM_gen_reg_write),
    .MEM_fp_reg_write(MEM_fp_reg_write),
    .WB_gen_reg_write(WB_gen_reg_write),
    .WB_fp_reg_write(WB_fp_reg_write),

    .ForwardA(ForwardA),
    .ForwardB(ForwardB)
);

HazardDetectionUnit i_HazardDetectionUnit(
    .PCSrc(PCSrc),
    .EXE_MemRead(EXE_MemRead),

    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .EXE_rd_addr(EXE_rd_addr),

    .PCWrite(PCWrite),
    .IF_Flush(IF_Flush),
    .IF_ID_Reg_Write(IF_ID_Reg_Write),
    .ID_Flush(ID_Flush),

    .IM_stall(IM_stall),
    .DM_stall(DM_stall),
    .Hazardstall_flag(Hazardstall_flag),

    .EXE_MEM_Reg_Write(EXE_MEM_Reg_Write),
    .MEM_WB_Reg_Write(MEM_WB_Reg_Write),

    .CSR_stall(CSR_stall),
    .CSR_interrupt(CSR_interrupt),
    .CSR_ret(CSR_ret),
    .CSR_rst(CSR_rst),
    .CSR_type(CSR_type)
);

CSR i_CSR(
    .clk(clk),
    .rst(rst),
    
    .funct3(EXE_funct3),
    .funct7(EXE_funct7),

    .EXE_PC_out(EXE_PC_out),
    .EXE_rs1_addr(EXE_rs1_addr),
    .ALU_rs1_data(ALU_rs1_data),
    .Imm_CSR(EXE_Imm_out),
    
    .EXE_csr_addr(EXE_csr_addr),
    .EXE_CSR_sel(EXE_CSR_sel),
    .EXE_CSR_type(EXE_CSR_type),

    .Hazardstall_flag(Hazardstall_flag),
    .PCSrc(PCSrc),

    .DMA_interrupt(DMA_interrupt),
    .WDT_timeout(WDT_timeout),

    .CSR_return_PC(CSR_return_PC),
    .CSR_ISR_PC(CSR_ISR_PC),
    .CSR_stall(CSR_stall),
    .CSR_interrupt(CSR_interrupt),
    .CSR_ret(CSR_ret),
    .CSR_rst(CSR_rst),

    .CSR_rd_data(CSR_rd_data)
);

endmodule