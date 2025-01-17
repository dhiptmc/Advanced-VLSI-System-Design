`include "Control.sv"
`include "ID_ImmediateGenerator.sv"
`include "ID_Gen_RegFile.sv"
`include "ID_FP_RegFile.sv"

module ID_Stage (
    input  logic clk,
    input  logic rst,

    //------------From IF/ID Register------------//
    input  logic [          `RegBus] ID_PC_out,
    input  logic [  `InstructionBus] ID_instruction,
    //------------From IF/ID Register------------//

    input  logic                     regwrite_gen,
    input  logic                     regwrite_fp,
    input  logic [      `RegAddrBus] reg_rd_addr,
    input  logic [          `RegBus] reg_rd_data,

    inout  wire  [      `RegAddrBus] rs1_addr,    //for (forwarding and hazard) detection
    output logic [          `RegBus] rs1_data,

    inout  wire  [      `RegAddrBus] rs2_addr,    //for (forwarding and hazard) detection
    output logic [          `RegBus] rs2_data,

    inout  wire  [      `RegAddrBus] rd_addr,     //for hazard detection and target store register  

    inout  wire  [`FUNCTION_3 - 1:0] funct3,
    inout  wire  [`FUNCTION_7 - 1:0] funct7,
    output logic [          `RegBus] Imm_out,

    //------------Output Control signals------------//
    output logic [      `ALUTypeBus] ALU_mode,
    output logic                     EXE_PC_sel,
    output logic                     ALUSrc,       
    output logic [   `BranchTypeBus] branch_signal,
    output logic                     MEM_rd_sel,
    output logic                     gen_fp_rs1_sel,
    output logic                     gen_fp_rs2_sel,
    output logic                     MemRead,
    output logic                     MemWrite,
    output logic                     gen_reg_write,
    output logic                     fp_reg_write,
    output logic                     WB_data_sel,
    output logic                     CSR_sel, 
    //------------Output Control signals------------//

    output logic [          `RegBus] ID_EXE_PC_out,

    inout  wire  [             11:0] csr_addr,

    input  logic [      `OPCODE-1:0] opcode
);

assign ID_EXE_PC_out = ID_PC_out;

logic [`ImmTypeBus] Imm_type;
logic [    `RegBus] rs1_gen_data;
logic [    `RegBus] rs2_gen_data;
logic [    `RegBus] rs1_fp_data;
logic [    `RegBus] rs2_fp_data;

//----------------------Control----------------------//
Control i_Control(
    .opcode(opcode),
    .Imm_type(Imm_type),
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
    .CSR_sel(CSR_sel)
);
//----------------------Control----------------------//

//------------------ Register File -------------------//
ID_Gen_RegFile i_ID_Gen_RegFile(
    .clk(clk),
    .rst(rst),

    .regwrite(regwrite_gen),

    .rs1_addr(rs1_addr),
    .rs1_data(rs1_gen_data),

    .rs2_addr(rs2_addr),
    .rs2_data(rs2_gen_data),

    .rd_addr(reg_rd_addr),
    .rd_data(reg_rd_data)
);

ID_FP_RegFile i_ID_FP_RegFile(
    .clk(clk),
    .rst(rst),

    .regwrite(regwrite_fp),

    .rs1_addr(rs1_addr),
    .rs1_data(rs1_fp_data),

    .rs2_addr(rs2_addr),
    .rs2_data(rs2_fp_data),

    .rd_addr(reg_rd_addr),
    .rd_data(reg_rd_data)
);


always_comb
begin
    case(gen_fp_rs1_sel)
        1'b0:    rs1_data = rs1_gen_data;
        
        1'b1:    rs1_data = rs1_fp_data;
    endcase
end

always_comb
begin
    case(gen_fp_rs2_sel)
        1'b0:    rs2_data = rs2_gen_data;
        
        1'b1:    rs2_data = rs2_fp_data;
    endcase
end
//------------------ Register File -------------------//

//-----------------ImmediateGenerator-----------------//
ID_ImmediateGenerator i_ID_ImmediateGenerator(
    .Imm_type(Imm_type),
    .instruction(ID_instruction),
    .Imm_out(Imm_out)
);
//-----------------ImmediateGenerator-----------------//

endmodule