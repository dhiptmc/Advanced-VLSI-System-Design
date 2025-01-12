`include "../include/def.svh"

module EXE_MEM_Reg (
    input  logic                     clk,
    input  logic                     rst,

    input  logic                     EXE_MEM_Reg_Write,

    //---------------------------------data pass in---------------------------------//
    //------------ Control signals------------//
    input  logic [              1:0] EXE_MEM_MEM_rd_sel,
    input  logic                     EXE_MEM_MemRead,
    input  logic                     EXE_MEM_MemWrite,
    input  logic                     EXE_MEM_gen_reg_write, 
    input  logic                     EXE_MEM_fp_reg_write,
    input  logic                     EXE_MEM_WB_data_sel, 
    //------------ Control signals------------//

    input  logic [`FUNCTION_3 - 1:0] EXE_MEM_funct3,
    input  logic [      `RegAddrBus] EXE_MEM_rd_addr,

    input  logic [          `RegBus] PC_sel_out,
    input  logic [          `RegBus] ALU_out,
    input  logic [          `RegBus] EXE_mux_rs2_data,

    input  logic [          `RegBus] CSR_rd_data,

    //---------------------------------data pass out---------------------------------//
    //------------ Control signals------------//
    output logic [              1:0] MEM_MEM_rd_sel,
    output logic                     MEM_MemRead,
    output logic                     MEM_MemWrite,
    output logic                     MEM_gen_reg_write, 
    output logic                     MEM_fp_reg_write,
    output logic                     MEM_WB_data_sel, 
    //------------ Control signals------------//

    output logic [`FUNCTION_3 - 1:0] MEM_funct3,
    output logic [      `RegAddrBus] MEM_rd_addr,

    output logic [          `RegBus] MEM_PC_sel_out,
    output logic [          `RegBus] MEM_ALU_out,
    output logic [          `RegBus] MEM_EXE_mux_rs2_data,

    output logic [          `RegBus] MEM_CSR_rd_data
);

always_ff @ (posedge clk or posedge rst)
begin
    if(rst)
    begin
        MEM_MEM_rd_sel       <= 2'b00;
        MEM_MemRead          <= 1'b0;
        MEM_MemWrite         <= 1'b0;
        MEM_gen_reg_write    <= 1'b0;
        MEM_fp_reg_write     <= 1'b0;
        MEM_WB_data_sel      <= 1'b0;

        MEM_funct3           <= `FUNCTION_3'd0;
        MEM_rd_addr          <= `RegNumLog2'd0;

        MEM_PC_sel_out       <= `ZeroWord;
        MEM_ALU_out          <= `ZeroWord;
        MEM_EXE_mux_rs2_data <= `ZeroWord;

        MEM_CSR_rd_data      <= `ZeroWord;
    end
    else if(EXE_MEM_Reg_Write)
    begin
        MEM_MEM_rd_sel       <= EXE_MEM_MEM_rd_sel;
        MEM_MemRead          <= EXE_MEM_MemRead;
        MEM_MemWrite         <= EXE_MEM_MemWrite;
        MEM_gen_reg_write    <= EXE_MEM_gen_reg_write;
        MEM_fp_reg_write     <= EXE_MEM_fp_reg_write;
        MEM_WB_data_sel      <= EXE_MEM_WB_data_sel;

        MEM_funct3           <= EXE_MEM_funct3;
        MEM_rd_addr          <= EXE_MEM_rd_addr;

        MEM_PC_sel_out       <= PC_sel_out;
        MEM_ALU_out          <= ALU_out;
        MEM_EXE_mux_rs2_data <= EXE_mux_rs2_data;

        MEM_CSR_rd_data      <= CSR_rd_data;
    end
    else
    begin
        MEM_MEM_rd_sel       <= MEM_MEM_rd_sel;
        MEM_MemRead          <= MEM_MemRead;
        MEM_MemWrite         <= MEM_MemWrite;
        MEM_gen_reg_write    <= MEM_gen_reg_write;
        MEM_fp_reg_write     <= MEM_fp_reg_write;
        MEM_WB_data_sel      <= MEM_WB_data_sel;

        MEM_funct3           <= MEM_funct3;
        MEM_rd_addr          <= MEM_rd_addr;

        MEM_PC_sel_out       <= MEM_PC_sel_out;
        MEM_ALU_out          <= MEM_ALU_out;
        MEM_EXE_mux_rs2_data <= MEM_EXE_mux_rs2_data;

        MEM_CSR_rd_data      <= MEM_CSR_rd_data;
    end
end

endmodule