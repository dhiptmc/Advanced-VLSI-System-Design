`include "../include/def.svh"

module ID_ImmediateGenerator (
    input  logic [    `ImmTypeBus] Imm_type,
    input  logic [`InstructionBus] instruction,
    output logic [        `RegBus] Imm_out
);

//parameter
localparam [`ImmTypeBus] Imm_I = 3'b000, //plus FLW
                         Imm_S = 3'b001, //plus FSW
                         Imm_B = 3'b010,
                         Imm_U = 3'b011,
                         Imm_J = 3'b100;

always_comb
begin
    case(Imm_type)
        Imm_I:
            Imm_out = { {20{instruction[31]}} , instruction[31:20] };
        Imm_S:
            Imm_out = { {20{instruction[31]}} , instruction[31:25] , instruction[11:7] };
        Imm_B:
            Imm_out = { {19{instruction[31]}}, instruction[31] , instruction[7] , instruction[30:25] , instruction[11:8] , 1'b0 };
        Imm_U:
            Imm_out = { instruction[31:12] , 12'b0 };
        Imm_J:
            Imm_out = { {11{instruction[31]}} , instruction[31] , instruction[19:12] , instruction[20] , instruction[30:21] , 1'b0};
        //Imm_CSR:
        default:
            Imm_out = `ZeroWord;
    endcase
end

endmodule