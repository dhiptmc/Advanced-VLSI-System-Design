`include "../include/def.svh"

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

    output logic [`InstructionAddrBus] PC_out_IM,    // To IM
    output logic [            `RegBus] IF_ID_PC_out, // To IF/ID Register
    output logic [    `InstructionBus] IF_ID_instruction
);

assign PC_out_IM = IF_ID_PC_out;
assign IF_ID_instruction = IM_instruction;           //Pass the instruction fetch from Instruction memory

logic [`RegBus] PC_4;
assign PC_4 = IF_ID_PC_out + `DataWidth'd4;

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
    .PC_out(IF_ID_PC_out)
);

endmodule