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
    output logic [`InstructionBus] ID_instruction,

    input  logic                   CSR_stall,
    input  logic                   CSR_rst,

    input  logic                   Hazardstall_flag,

    output wire [     `RegAddrBus] rs1_addr,
    output wire [     `RegAddrBus] rs2_addr,
    output wire [     `RegAddrBus] rd_addr,
    output wire [    `OPCODE -1:0] opcode,
    output wire [`FUNCTION_3 -1:0] funct3,
    output wire [`FUNCTION_7 -1:0] funct7,
    output wire [            11:0] csr_addr
);

assign rs1_addr = (IF_Flush) ?  5'd0 : ID_instruction[19:15];
assign rs2_addr = (IF_Flush) ?  5'd0 : ID_instruction[24:20];
assign rd_addr  = (IF_Flush) ?  5'd0 : ID_instruction[11:7];
assign opcode   = (IF_Flush) ?  7'd0 : ID_instruction[6:0];
assign funct3   = (IF_Flush) ?  3'd0 : ID_instruction[14:12];
assign funct7   = (IF_Flush) ?  7'd0 : ID_instruction[31:25];
assign csr_addr = (IF_Flush) ? 12'd0 : ID_instruction[31:20];

always_ff @ (posedge clk or posedge rst)
begin
    if(rst)
    begin
        ID_PC_out          <= `ZeroWord;
        ID_instruction     <= `NOP;
    end
    else if(CSR_stall || CSR_rst)
    begin
        ID_PC_out          <= `ZeroWord;
        ID_instruction     <= `NOP;
    end
    else
    begin
        if(IF_ID_Reg_Write && (!Hazardstall_flag))
        begin
            ID_PC_out      <= IF_ID_PC_out;
            if(IF_Flush)
                ID_instruction <= `NOP;
            else
                ID_instruction <= IF_ID_instruction;
        end
        else
        begin
            ID_PC_out      <= ID_PC_out;
            ID_instruction <= ID_instruction;
        end
    end
end

endmodule