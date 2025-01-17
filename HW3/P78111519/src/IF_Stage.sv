`include "./IF_ProgramCounter.sv"

module IF_Stage (
    input  logic clk,
    input  logic rst,

    //Branch Control Unit
    input  logic [         `PCTypeBus] PCSrc,
    //Hazard Detection Unit
    input  logic                       PCWrite,

    //From Instruction Memory
    input  logic [    `InstructionBus] IM_instruction,

    input  logic [            `RegBus] PC_imm,
    input  logic [            `RegBus] PC_imm_rs1,

    output logic [`InstructionAddrBus] PC_out_IM,    // To IM & IF/ID Register
    output logic [    `InstructionBus] IF_ID_instruction,

    output logic                       instruction_fetch_sig,

    input  logic [            `RegBus] CSR_return_PC,
    input  logic [            `RegBus] CSR_ISR_PC,
    input  logic                       CSR_stall,   
    input  logic                       CSR_interrupt,
    input  logic                       CSR_ret,
    input  logic                       CSR_rst
);

assign IF_ID_instruction = IM_instruction;           //Pass the instruction fetch from Instruction memory
assign instruction_fetch_sig = ~CSR_stall;

logic [`RegBus] PC_4;
assign PC_4 = PC_out_IM + `DataWidth'd4;

logic [`RegBus] PC_in;

//PC Mux//
always_comb
begin
    case(PCSrc)
    2'b00:
        PC_in = PC_4;        
    2'b01:
        PC_in = PC_imm;
    2'b10:
        PC_in = PC_imm_rs1;
    default:
        PC_in = PC_4;
    endcase
end

//ProgramCounter//
IF_ProgramCounter i_IF_ProgramCounter(
    .clk(clk),
    .rst(rst),
    .PCWrite(PCWrite),
    .PC_in(PC_in),
    .PC_out(PC_out_IM),

    .CSR_return_PC(CSR_return_PC),
    .CSR_ISR_PC(CSR_ISR_PC),
    .CSR_stall(CSR_stall),   
    .CSR_interrupt(CSR_interrupt),
    .CSR_ret(CSR_ret),
    .CSR_rst(CSR_rst)
);

endmodule