`include "../include/def.svh"

module IF_ProgramCounter (
    input  logic clk,
    input  logic rst,

    //Control
    input  logic PCWrite,

    //I/O
    input  logic [`RegBus] PC_in,
    output logic [`RegBus] PC_out
);

always_ff @ (posedge clk or posedge rst)
begin
    if(rst)
        PC_out <= `StartAddress;
    else if(PCWrite)
        PC_out <= PC_in;
end

endmodule