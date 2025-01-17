module Control (
    input  logic [   `OPCODE-1:0] opcode,

    //Output Control signals
    output logic [   `ImmTypeBus] Imm_type,
    output logic [   `ALUTypeBus] ALU_mode,
    output logic                  EXE_PC_sel,
    output logic                  ALUSrc,       
    output logic [`BranchTypeBus] branch_signal,
    output logic                  MEM_rd_sel,
    output logic                  gen_fp_rs1_sel,
    output logic                  gen_fp_rs2_sel, //choose whether general or floating point register will output
    output logic                  MemRead,
    output logic                  MemWrite,
    output logic                  gen_reg_write,
    output logic                  fp_reg_write,
    output logic                  WB_data_sel,
    output logic                  CSR_sel
);

//parameters

localparam [   `ImmTypeBus] Imm_I       = 3'b000, //plus FLW
                            Imm_S       = 3'b001, //plus FSW
                            Imm_B       = 3'b010,
                            Imm_U       = 3'b011,
                            Imm_J       = 3'b100,
                            Imm_CSR     = 3'b101;

localparam [   `ALUTypeBus] R_type      = 3'b000,
                            I_type      = 3'b001,
                            ADD_type    = 3'b010, // partial I, S, U(AUIPC), J-type, F-type(FLW, FSW)
                            I_JALR_type = 3'b011,
                            B_type      = 3'b100,
                            U_LUI_type  = 3'b101,
                            F_type      = 3'b110,
                            CSR_type    = 3'b111;     

localparam [`BranchTypeBus] No_Branch   = 2'b00,
                            JALR_Branch = 2'b01,
                            B_Branch    = 2'b10,
                            J_Branch    = 2'b11;

localparam                  from_ALU    = 1'b0,
                            from_PC     = 1'b1;

always_comb
begin
    case(opcode)
        7'b0110011: //R-type
        begin
            Imm_type        = Imm_I;// don't care
            ALU_mode        = R_type;
            EXE_PC_sel      = 1'b0; // 0:PC+4    , 1:PC+imm (don't care)
            ALUSrc          = 1'b1; // 0:imm     , 1:rs2
            branch_signal   = No_Branch;
            MEM_rd_sel      = from_ALU;
            gen_fp_rs1_sel  = 1'b0; // 0:general , 1:floating point
            gen_fp_rs2_sel  = 1'b0; // 0:general , 1:floating point
            MemRead         = 1'b0;
            MemWrite        = 1'b0;
            gen_reg_write   = 1'b1;
            fp_reg_write    = 1'b0;
            WB_data_sel     = 1'b0; // 0:from mux, 1:from DM
            CSR_sel         = 1'b0;
        end

        7'b0000011: //I-type - LW/LB/LH/LBU/LHU
        begin
            Imm_type        = Imm_I;
            ALU_mode        = ADD_type;
            EXE_PC_sel      = 1'b0; // 0:PC+4    , 1:PC+imm (don't care)
            ALUSrc          = 1'b0; // 0:imm     , 1:rs2
            branch_signal   = No_Branch;
            MEM_rd_sel      = from_ALU; //don't care
            gen_fp_rs1_sel  = 1'b0; // 0:general , 1:floating point
            gen_fp_rs2_sel  = 1'b0; // 0:general , 1:floating point
            MemRead         = 1'b1;
            MemWrite        = 1'b0;
            gen_reg_write   = 1'b1;
            fp_reg_write    = 1'b0;
            WB_data_sel     = 1'b1; // 0:from mux, 1:from DM
            CSR_sel         = 1'b0;
        end

        7'b1100111: //I-type - JALR
        begin
            Imm_type        = Imm_I;
            ALU_mode        = I_JALR_type;
            EXE_PC_sel      = 1'b0; // 0:PC+4    , 1:PC+imm
            ALUSrc          = 1'b0; // 0:imm     , 1:rs2
            branch_signal   = JALR_Branch;
            MEM_rd_sel      = from_PC;
            gen_fp_rs1_sel  = 1'b0; // 0:general , 1:floating point
            gen_fp_rs2_sel  = 1'b0; // 0:general , 1:floating point
            MemRead         = 1'b0;
            MemWrite        = 1'b0;
            gen_reg_write   = 1'b1;
            fp_reg_write    = 1'b0;
            WB_data_sel     = 1'b0; // 0:from mux, 1:from DM
            CSR_sel         = 1'b0;    
        end

        7'b0010011: //I-type
        begin
            Imm_type        = Imm_I;
            ALU_mode        = I_type;
            EXE_PC_sel      = 1'b0; // 0:PC+4    , 1:PC+imm (don't care)
            ALUSrc          = 1'b0; // 0:imm     , 1:rs2
            branch_signal   = No_Branch;
            MEM_rd_sel      = from_ALU;
            gen_fp_rs1_sel  = 1'b0; // 0:general , 1:floating point
            gen_fp_rs2_sel  = 1'b0; // 0:general , 1:floating point
            MemRead         = 1'b0;
            MemWrite        = 1'b0;
            gen_reg_write   = 1'b1;
            fp_reg_write    = 1'b0;
            WB_data_sel     = 1'b0; // 0:from mux, 1:from DM
            CSR_sel         = 1'b0;
        end

        7'b0100011: //S-type
        begin
            Imm_type        = Imm_S;
            ALU_mode        = ADD_type;
            EXE_PC_sel      = 1'b0; // 0:PC+4    , 1:PC+imm (don't care)
            ALUSrc          = 1'b0; // 0:imm     , 1:rs2
            branch_signal   = No_Branch;
            MEM_rd_sel      = from_ALU; //don't care
            gen_fp_rs1_sel  = 1'b0; // 0:general , 1:floating point
            gen_fp_rs2_sel  = 1'b0; // 0:general , 1:floating point
            MemRead         = 1'b0;
            MemWrite        = 1'b1;
            gen_reg_write   = 1'b0;
            fp_reg_write    = 1'b0;
            WB_data_sel     = 1'b0; // 0:from mux, 1:from DM
            CSR_sel         = 1'b0;
        end

        7'b1100011: //B-type
        begin
            Imm_type        = Imm_B;
            ALU_mode        = B_type;
            EXE_PC_sel      = 1'b0; // 0:PC+4    , 1:PC+imm (don't care)
            ALUSrc          = 1'b1; // 0:imm     , 1:rs2
            branch_signal   = B_Branch;
            MEM_rd_sel      = from_PC; //don't care
            gen_fp_rs1_sel  = 1'b0; // 0:general , 1:floating point
            gen_fp_rs2_sel  = 1'b0; // 0:general , 1:floating point
            MemRead         = 1'b0;
            MemWrite        = 1'b0;
            gen_reg_write   = 1'b0;
            fp_reg_write    = 1'b0;
            WB_data_sel     = 1'b0; // 0:from mux, 1:from DM
            CSR_sel         = 1'b0;
        end

        7'b0010111: //U-type - AUIPC
        begin
            Imm_type        = Imm_U;
            ALU_mode        = ADD_type;
            EXE_PC_sel      = 1'b1; // 0:PC+4    , 1:PC+imm
            ALUSrc          = 1'b0; // 0:imm     , 1:rs2 (don't care)
            branch_signal   = No_Branch;
            MEM_rd_sel      = from_PC;
            gen_fp_rs1_sel  = 1'b0; // 0:general , 1:floating point
            gen_fp_rs2_sel  = 1'b0; // 0:general , 1:floating point
            MemRead         = 1'b0;
            MemWrite        = 1'b0;
            gen_reg_write   = 1'b1;
            fp_reg_write    = 1'b0;
            WB_data_sel     = 1'b0; // 0:from mux, 1:from DM
            CSR_sel         = 1'b0;
        end

        7'b0110111: //U-type - LUI
        begin
            Imm_type        = Imm_U;
            ALU_mode        = U_LUI_type;
            EXE_PC_sel      = 1'b0; // 0:PC+4    , 1:PC+imm (don't care)
            ALUSrc          = 1'b0; // 0:imm     , 1:rs2
            branch_signal   = No_Branch;
            MEM_rd_sel      = from_ALU;
            gen_fp_rs1_sel  = 1'b0; // 0:general , 1:floating point
            gen_fp_rs2_sel  = 1'b0; // 0:general , 1:floating point
            MemRead         = 1'b0;
            MemWrite        = 1'b0;
            gen_reg_write   = 1'b1;
            fp_reg_write    = 1'b0;
            WB_data_sel     = 1'b0; // 0:from mux, 1:from DM
            CSR_sel         = 1'b0;
        end

        7'b1101111: //J-type
        begin
            Imm_type        = Imm_J;
            ALU_mode        = ADD_type;
            EXE_PC_sel      = 1'b0; // 0:PC+4    , 1:PC+imm
            ALUSrc          = 1'b0; // 0:imm     , 1:rs2
            branch_signal   = J_Branch;
            MEM_rd_sel      = from_PC;
            gen_fp_rs1_sel  = 1'b0; // 0:general , 1:floating point
            gen_fp_rs2_sel  = 1'b0; // 0:general , 1:floating point
            MemRead         = 1'b0;
            MemWrite        = 1'b0;
            gen_reg_write   = 1'b1;
            fp_reg_write    = 1'b0;
            WB_data_sel     = 1'b0; // 0:from mux, 1:from DM
            CSR_sel         = 1'b0;
        end

        7'b0000111: //F-type - FLW
        begin
            Imm_type        = Imm_I;
            ALU_mode        = ADD_type;
            EXE_PC_sel      = 1'b0; // 0:PC+4    , 1:PC+imm (don't care)
            ALUSrc          = 1'b0; // 0:imm     , 1:rs2
            branch_signal   = No_Branch;
            MEM_rd_sel      = from_ALU; //don't care
            gen_fp_rs1_sel  = 1'b0; // 0:general , 1:floating point              
            gen_fp_rs2_sel  = 1'b0; // 0:general , 1:floating point (don't care)
            MemRead         = 1'b1;
            MemWrite        = 1'b0;
            gen_reg_write   = 1'b0;
            fp_reg_write    = 1'b1;
            WB_data_sel     = 1'b1; // 0:from mux, 1:from DM
            CSR_sel         = 1'b0;
        end

        7'b0100111: //F-type - FSW
        begin
            Imm_type        = Imm_S;
            ALU_mode        = ADD_type;
            EXE_PC_sel      = 1'b0; // 0:PC+4    , 1:PC+imm (don't care)
            ALUSrc          = 1'b0; // 0:imm     , 1:rs2
            branch_signal   = No_Branch;
            MEM_rd_sel      = from_ALU; //don't care
            gen_fp_rs1_sel  = 1'b0; // 0:general , 1:floating point           
            gen_fp_rs2_sel  = 1'b1; // 0:general , 1:floating point
            MemRead         = 1'b0;
            MemWrite        = 1'b1;
            gen_reg_write   = 1'b0;
            fp_reg_write    = 1'b0;
            WB_data_sel     = 1'b0; // 0:from mux, 1:from DM
            CSR_sel         = 1'b0;
        end

        7'b1010011: //F-type
        begin
            Imm_type        = Imm_I;// don't care
            ALU_mode        = F_type;
            EXE_PC_sel      = 1'b0; // 0:PC+4    , 1:PC+imm (don't care)
            ALUSrc          = 1'b1; // 0:imm     , 1:rs2
            branch_signal   = No_Branch;
            MEM_rd_sel      = from_ALU;
            gen_fp_rs1_sel  = 1'b1; // 0:general , 1:floating point
            gen_fp_rs2_sel  = 1'b1; // 0:general , 1:floating point
            MemRead         = 1'b0;
            MemWrite        = 1'b0;
            gen_reg_write   = 1'b0;
            fp_reg_write    = 1'b1;
            WB_data_sel     = 1'b0; // 0:from mux, 1:from DM
            CSR_sel         = 1'b0;
        end

        7'b1110011: //CSR
        begin
            Imm_type        = Imm_CSR;
            ALU_mode        = CSR_type;
            EXE_PC_sel      = 1'b0; // 0:PC+4    , 1:PC+imm (don't care)
            ALUSrc          = 1'b0; // 0:imm     , 1:rs2 (don't care)
            branch_signal   = No_Branch;
            MEM_rd_sel      = from_ALU;
            gen_fp_rs1_sel  = 1'b0; // 0:general , 1:floating point
            gen_fp_rs2_sel  = 1'b0; // 0:general , 1:floating point
            MemRead         = 1'b0;
            MemWrite        = 1'b0;
            gen_reg_write   = 1'b1;
            fp_reg_write    = 1'b0;
            WB_data_sel     = 1'b0; // 0:from mux, 1:from DM
            CSR_sel         = 1'b1;
        end

        default: //don't care
        begin
            Imm_type        = Imm_I;
            ALU_mode        = ADD_type;
            EXE_PC_sel      = 1'b0; // 0:PC+4    , 1:PC+imm
            ALUSrc          = 1'b0; // 0:imm     , 1:rs2
            branch_signal   = No_Branch;
            MEM_rd_sel      = from_ALU;
            gen_fp_rs1_sel  = 1'b0; // 0:general , 1:floating point
            gen_fp_rs2_sel  = 1'b0; // 0:general , 1:floating point
            MemRead         = 1'b0;
            MemWrite        = 1'b0;
            gen_reg_write   = 1'b0;
            fp_reg_write    = 1'b0;
            WB_data_sel     = 1'b0; // 0:from mux, 1:from DM
            CSR_sel         = 1'b0;
        end
    endcase
end

endmodule