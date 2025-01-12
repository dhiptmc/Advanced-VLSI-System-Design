`include "../include/def.svh"

module IF_ID_Reg (
    input  logic clk,
    input  logic rst,

    //control
    input  logic                   IF_ID_Reg_Write, //Stall or not
    input  logic                   IF_Flush,        //Flush or not

    //---------------------------------data pass in---------------------------------//
    input  logic [        `RegBus] IF_ID_PC_out,
    input  logic [`InstructionBus] IF_ID_instruction,

    //---------------------------------data pass out---------------------------------//
    output logic [        `RegBus] ID_PC_out,
    output logic [`InstructionBus] ID_instruction
);

always_ff @ (posedge clk or posedge rst)
begin
    if(rst)
    begin
        ID_PC_out       <= `ZeroWord;
        ID_instruction  <= `NOP;
    end
    else if(IF_ID_Reg_Write)
    begin
        ID_PC_out       <= (IF_Flush) ? `ZeroWord : IF_ID_PC_out;
        ID_instruction  <= (IF_Flush) ? `NOP      : IF_ID_instruction;
    end
end

endmodule