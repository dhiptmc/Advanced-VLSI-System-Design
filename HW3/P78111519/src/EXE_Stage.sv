`include "EXE_ALU.sv"
`include "EXE_ALUControl.sv"

module EXE_Stage (
    //----------------From ID/EXE Register----------------//
    input  logic [          `RegBus] EXE_rs1_data,

    input  logic [          `RegBus] EXE_rs2_data,

    input  logic [      `RegAddrBus] EXE_rd_addr,

    input  logic [`FUNCTION_3 - 1:0] EXE_funct3,
    input  logic [`FUNCTION_7 - 1:0] EXE_funct7,
    input  logic [          `RegBus] EXE_Imm_out,

        //------------ Control signals------------//
    input  logic [      `ALUTypeBus] EXE_ALU_mode,
    input  logic                     EXE_EXE_PC_sel,
    input  logic                     EXE_ALUSrc,       
    input  logic                     EXE_MEM_rd_sel,
    input  logic                     EXE_MemRead,
    input  logic                     EXE_MemWrite,
    input  logic                     EXE_gen_reg_write,
    input  logic                     EXE_fp_reg_write,
    input  logic                     EXE_WB_data_sel,   
        //------------ Control signals------------//

    input  logic [          `RegBus] EXE_PC_out,
    
    //----------------From ID/EXE Register----------------//

    //-----Output Control signals for later stages...-----//
    output logic                     EXE_MEM_MEM_rd_sel,
    output logic                     EXE_MEM_MemRead,
    output logic                     EXE_MEM_MemWrite,
    output logic                     EXE_MEM_gen_reg_write, 
    output logic                     EXE_MEM_fp_reg_write,
    output logic                     EXE_MEM_WB_data_sel, 
    //-----Output Control signals for later stages...-----//

    //------Input Control signals from FowardingUnit------//
    input  logic [`ForwardSelectBus] ForwardA,
    input  logic [`ForwardSelectBus] ForwardB,
    //------Input Control signals from FowardingUnit------//

    //-------------------Forwarded data-------------------//
    input  logic [          `RegBus] MEM_rd_data,
    input  logic [          `RegBus] WB_rd_data,
    //-------------------Forwarded data-------------------//

    // below are output signals or data
    output logic [          `RegBus] PC_imm,
    output logic [          `RegBus] PC_imm_rs1,
    output logic                     branch_taken_flag,

    // need to pass to MEM stage
    output logic [`FUNCTION_3 - 1:0] EXE_MEM_funct3,
    output logic [      `RegAddrBus] EXE_MEM_rd_addr,

    output logic [          `RegBus] PC_sel_out,
    output logic [          `RegBus] ALU_final,
    output logic [          `RegBus] EXE_mux_rs2_data,

    output logic [          `RegBus] ALU_rs1_data,

    input  logic [          `RegBus] CSR_rd_data,
    input  logic                     EXE_CSR_sel
);

logic [`RegBus] ALU_out;
assign ALU_final = ( (EXE_CSR_sel) && (EXE_rd_addr != `RegNumLog2'd0) ) ? CSR_rd_data : ALU_out;

assign EXE_MEM_MEM_rd_sel    = EXE_MEM_rd_sel;
assign EXE_MEM_MemRead       = EXE_MemRead;
assign EXE_MEM_MemWrite      = EXE_MemWrite;
assign EXE_MEM_gen_reg_write = EXE_gen_reg_write;
assign EXE_MEM_fp_reg_write  = EXE_fp_reg_write;
assign EXE_MEM_WB_data_sel   = EXE_WB_data_sel;

logic [`RegBus] mux_4;
logic [`RegBus] mux_Imm;
logic [`RegBus] temp_rs2_data;

assign mux_4   = EXE_PC_out + `DataWidth'd4; // PC + 4
assign mux_Imm = EXE_PC_out + EXE_Imm_out;   // PC + imm

assign PC_imm           = mux_Imm;
assign PC_imm_rs1       = ALU_out;

assign EXE_MEM_funct3   = EXE_funct3;
assign EXE_MEM_rd_addr  = EXE_rd_addr;

assign PC_sel_out       = (EXE_EXE_PC_sel) ? mux_Imm : mux_4;
assign EXE_mux_rs2_data = temp_rs2_data;


logic [    4:0] ALU_ctrl;

//choose rs1 and rs2 data
// logic [`RegBus] ALU_rs1_data;
logic [`RegBus] ALU_rs2_data;

always_comb
begin
    case(ForwardA)
        2'b10:   ALU_rs1_data =  MEM_rd_data;
        2'b01:   ALU_rs1_data =  WB_rd_data;
        2'b00:   ALU_rs1_data =  EXE_rs1_data;
        default: ALU_rs1_data =  `ZeroWord;
    endcase
end

always_comb
begin
    case(ForwardB)
        2'b10:   temp_rs2_data =  MEM_rd_data;
        2'b01:   temp_rs2_data =  WB_rd_data;
        2'b00:   temp_rs2_data =  EXE_rs2_data;
        default: temp_rs2_data =  `ZeroWord;
    endcase
end

assign ALU_rs2_data = (EXE_ALUSrc) ? temp_rs2_data : EXE_Imm_out;
//

EXE_ALU i_EXE_ALU(
    .ALU_ctrl(ALU_ctrl),

    .rs1(ALU_rs1_data),
    .rs2(ALU_rs2_data),
    .ALU_out(ALU_out),

    .branch_taken_flag(branch_taken_flag)
);

EXE_ALUControl i_EXE_ALUControl(
    .ALU_mode(EXE_ALU_mode),
    .funct3(EXE_funct3),
    .funct7(EXE_funct7),
    .ALU_ctrl(ALU_ctrl)
);

endmodule