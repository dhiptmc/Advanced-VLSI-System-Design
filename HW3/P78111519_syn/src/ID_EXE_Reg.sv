module ID_EXE_Reg (
    input  logic clk,
    input  logic rst,

    // input  logic                     ID_EXE_Reg_Write,

    //control
    input  logic                     ID_Flush,        //Flush or not

    //---------------------------------data pass in---------------------------------//
    input  logic [      `RegAddrBus] rs1_addr,
    input  logic [          `RegBus] rs1_data,

    input  logic [      `RegAddrBus] rs2_addr,
    input  logic [          `RegBus] rs2_data,

    input  logic [      `RegAddrBus] rd_addr,

    input  logic [`FUNCTION_3 - 1:0] funct3,
    input  logic [`FUNCTION_7 - 1:0] funct7,
    input  logic [          `RegBus] Imm_out,

    //------------ Control signals------------//
    input  logic [      `ALUTypeBus] ALU_mode,
    input  logic                     EXE_PC_sel,
    input  logic                     ALUSrc,       
    input  logic [   `BranchTypeBus] branch_signal,
    input  logic                     MEM_rd_sel,
    input  logic                     gen_fp_rs1_sel,
    input  logic                     gen_fp_rs2_sel,
    input  logic                     MemRead,
    input  logic                     MemWrite,
    input  logic                     gen_reg_write,
    input  logic                     fp_reg_write,
    input  logic                     WB_data_sel,
    input  logic                     CSR_sel,
    //------------ Control signals------------//

    input  logic [          `RegBus] ID_EXE_PC_out,

    input  logic [             11:0] csr_addr,

    input  logic [              1:0] CSR_type,

    //---------------------------------data pass out---------------------------------//

    output logic [      `RegAddrBus] EXE_rs1_addr,
    output logic [          `RegBus] EXE_rs1_data,

    output logic [      `RegAddrBus] EXE_rs2_addr,
    output logic [          `RegBus] EXE_rs2_data,

    output logic [      `RegAddrBus] EXE_rd_addr,

    output logic [`FUNCTION_3 - 1:0] EXE_funct3,
    output logic [`FUNCTION_7 - 1:0] EXE_funct7,
    output logic [          `RegBus] EXE_Imm_out,

    //------------ Control signals------------//
    output logic [      `ALUTypeBus] EXE_ALU_mode,
    output logic                     EXE_EXE_PC_sel,
    output logic                     EXE_ALUSrc,       
    output logic [   `BranchTypeBus] EXE_branch_signal,
    output logic                     EXE_MEM_rd_sel,
    output logic                     EXE_gen_fp_rs1_sel,
    output logic                     EXE_gen_fp_rs2_sel,   
    output logic                     EXE_MemRead,
    output logic                     EXE_MemWrite,
    output logic                     EXE_gen_reg_write,
    output logic                     EXE_fp_reg_write,
    output logic                     EXE_WB_data_sel,
    output logic                     EXE_CSR_sel,
    //------------ Control signals------------//

    output logic [          `RegBus] EXE_PC_out,

    output logic [             11:0] EXE_csr_addr,

    output logic [              1:0] EXE_CSR_type,

    input  logic                     Hazardstall_flag,   
    input  logic                     CSR_stall
);

always_ff @ (posedge clk or posedge rst)
begin
    if(rst)
    begin
        EXE_rs1_addr       <= `RegNumLog2'd0;
        EXE_rs1_data       <= `ZeroWord;

        EXE_rs2_addr       <= `RegNumLog2'd0;
        EXE_rs2_data       <= `ZeroWord;

        EXE_rd_addr        <= `RegNumLog2'd0;

        EXE_funct3         <= `FUNCTION_3'd0;
        EXE_funct7         <= `FUNCTION_7'd0;
        EXE_Imm_out        <= `ZeroWord;

        EXE_ALU_mode       <= 3'b010;
        EXE_EXE_PC_sel     <= 1'b0;
        EXE_ALUSrc         <= 1'b0;
        EXE_branch_signal  <= 2'b00;
        EXE_MEM_rd_sel     <= 1'b0;
        EXE_gen_fp_rs1_sel <= 1'b0;
        EXE_gen_fp_rs2_sel <= 1'b0;
        EXE_MemRead        <= 1'b0;
        EXE_MemWrite       <= 1'b0;
        EXE_gen_reg_write  <= 1'b0;
        EXE_fp_reg_write   <= 1'b0;
        EXE_WB_data_sel    <= 1'b0;
        EXE_CSR_sel        <= 1'b0;

        EXE_PC_out         <= `ZeroWord;

        EXE_csr_addr       <= 12'd0;

        EXE_CSR_type       <= 2'd2;
    end
    else if(Hazardstall_flag)
    begin
        EXE_rs1_addr       <= EXE_rs1_addr;
        EXE_rs1_data       <= EXE_rs1_data;

        EXE_rs2_addr       <= EXE_rs2_addr; 
        EXE_rs2_data       <= EXE_rs2_data; 

        EXE_rd_addr        <= EXE_rd_addr;

        EXE_funct3         <= EXE_funct3;
        EXE_funct7         <= EXE_funct7;
        EXE_Imm_out        <= EXE_Imm_out;
    
        EXE_ALU_mode       <= EXE_ALU_mode;     
        EXE_EXE_PC_sel     <= EXE_EXE_PC_sel;   
        EXE_ALUSrc         <= EXE_ALUSrc; 
        EXE_branch_signal  <= EXE_branch_signal; 
        EXE_MEM_rd_sel     <= EXE_MEM_rd_sel;    
        EXE_gen_fp_rs1_sel <= EXE_gen_fp_rs1_sel;
        EXE_gen_fp_rs2_sel <= EXE_gen_fp_rs2_sel;   
        EXE_MemRead        <= EXE_MemRead;       
        EXE_MemWrite       <= EXE_MemWrite;      
        EXE_gen_reg_write  <= EXE_gen_reg_write; 
        EXE_fp_reg_write   <= EXE_fp_reg_write;  
        EXE_WB_data_sel    <= EXE_WB_data_sel;
        EXE_CSR_sel        <= EXE_CSR_sel;   

        EXE_PC_out         <= EXE_PC_out;

        EXE_csr_addr       <= EXE_csr_addr;

        EXE_CSR_type       <= EXE_CSR_type;
    end
    else if(ID_Flush)
    begin
        EXE_branch_signal  <= 2'b00;
        EXE_MemRead        <= 1'b0;
        EXE_MemWrite       <= 1'b0;
        EXE_gen_reg_write  <= 1'b0;
        EXE_fp_reg_write   <= 1'b0;
        EXE_CSR_sel        <= 1'b0;
    end
    else
    begin
        EXE_rs1_addr       <= rs1_addr;
        EXE_rs1_data       <= rs1_data;

        EXE_rs2_addr       <= rs2_addr; 
        EXE_rs2_data       <= rs2_data; 

        EXE_rd_addr        <= rd_addr;

        EXE_funct3         <= funct3;
        EXE_funct7         <= funct7;
        EXE_Imm_out        <= Imm_out;
    
        EXE_ALU_mode       <= ALU_mode;     
        EXE_EXE_PC_sel     <= EXE_PC_sel;   
        EXE_ALUSrc         <= ALUSrc; 
        EXE_branch_signal  <= branch_signal; 
        EXE_MEM_rd_sel     <= MEM_rd_sel;    
        EXE_gen_fp_rs1_sel <= gen_fp_rs1_sel;
        EXE_gen_fp_rs2_sel <= gen_fp_rs2_sel;   
        EXE_MemRead        <= MemRead;       
        EXE_MemWrite       <= MemWrite;      
        EXE_gen_reg_write  <= gen_reg_write; 
        EXE_fp_reg_write   <= fp_reg_write;  
        EXE_WB_data_sel    <= WB_data_sel;
        EXE_CSR_sel        <= CSR_sel;

        EXE_PC_out         <= ID_EXE_PC_out;

        EXE_csr_addr       <= csr_addr;

        EXE_CSR_type       <= CSR_type;     
    end
end

endmodule