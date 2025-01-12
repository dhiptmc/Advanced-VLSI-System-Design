module Decoder (
    // VALID
    input  logic                      VALID,
    input  logic [`AXI_ADDR_BITS-1:0] ADDR,
    output logic                      VALID_S1,
    output logic                      VALID_S2,
    output logic                      VALID_SDEFAULT,

    // READY
    input  logic                      READY_S1,
    input  logic                      READY_S2,
    input  logic                      READY_SDEFAULT,
    output logic                      READY_S
);

always_comb //modified
begin
    case(ADDR[31:16])
        16'h0000:
        begin
            {VALID_SDEFAULT, VALID_S2, VALID_S1} = {2'b00, VALID};
            READY_S = (VALID) ? READY_S1 : 1'b0;
        end
        16'h0001:
        begin
            {VALID_SDEFAULT, VALID_S2, VALID_S1} = {1'b0, VALID, 1'b0};
            READY_S = (VALID) ? READY_S2 : 1'b0;
        end
        default:
        begin
            {VALID_SDEFAULT, VALID_S2, VALID_S1} = {VALID, 2'b00};
            READY_S = (VALID) ? READY_SDEFAULT : 1'b0;
        end
    endcase
end

endmodule