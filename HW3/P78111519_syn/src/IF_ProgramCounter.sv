module IF_ProgramCounter (
    input  logic           clk,
    input  logic           rst,

    //Control
    input  logic           PCWrite,

    //I/O
    input  logic [`RegBus] PC_in,
    output logic [`RegBus] PC_out,

    input  logic [`RegBus] CSR_return_PC,
    input  logic [`RegBus] CSR_ISR_PC,
    input  logic           CSR_stall,   
    input  logic           CSR_interrupt,
    input  logic           CSR_ret,
    input  logic           CSR_rst
);

logic  ISR_reg1, ISR_reg2;
logic  ISR_reg_result;
assign ISR_reg_result = ISR_reg1 ^ CSR_interrupt;

always_ff @ (posedge clk or posedge rst)
begin 
    if(rst)
    begin
        ISR_reg1 <= 1'b0;
        ISR_reg2 <= 1'b0;
    end
    else if(CSR_interrupt)
    begin
        ISR_reg1 <= CSR_interrupt; 
        ISR_reg2 <= ISR_reg1;        
    end
    else
    begin
        ISR_reg1 <= 1'b0;
        ISR_reg2 <= 1'b0;     
    end
end

always_ff @ (posedge clk or posedge rst)
begin
    if(rst)
        PC_out <= `StartAddress;
    else if(CSR_rst)
        PC_out <= `StartAddress;
    else if(CSR_ret)
        PC_out <= CSR_return_PC;
    else if(ISR_reg_result)
        PC_out <= CSR_ISR_PC;
    else if(PCWrite)
        PC_out <= PC_in;
    else
        PC_out <= PC_out;
end


endmodule