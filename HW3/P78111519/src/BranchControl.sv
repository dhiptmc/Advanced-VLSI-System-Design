module BranchControl (
    input  logic                  branch_taken_flag,
    input  logic [`BranchTypeBus] branch_signal,
    output logic [    `PCTypeBus] PCSrc
);

//parameter
localparam [`BranchTypeBus] No_Branch   = 2'b00,
                            JALR_Branch = 2'b01,
                            B_Branch    = 2'b10,
                            J_Branch    = 2'b11;  

localparam [    `PCTypeBus] PC_4       = 2'b00,
                            PC_imm     = 2'b01, 
                            PC_imm_rs1 = 2'b10;

always_comb
begin
    case(branch_signal)
        No_Branch:
            PCSrc = PC_4;
        JALR_Branch:
            PCSrc = PC_imm_rs1;
        B_Branch:
        begin
            if(branch_taken_flag)
                PCSrc = PC_imm;
            else
                PCSrc = PC_4;
        end
        J_Branch:
            PCSrc = PC_imm;
    endcase
end

endmodule