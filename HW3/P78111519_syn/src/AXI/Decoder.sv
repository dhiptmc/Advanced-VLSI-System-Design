module Decoder (
    // VALID
    input  logic                      VALID,
    input  logic [`AXI_ADDR_BITS-1:0] ADDR,

    output logic                      VALID_S0,
    output logic                      VALID_S1,
    output logic                      VALID_S2,
    output logic                      VALID_S3,
    output logic                      VALID_S4,
    output logic                      VALID_S5,
    output logic                      VALID_SDEFAULT,

    // READY
    input  logic                      READY_S0,
    input  logic                      READY_S1,
    input  logic                      READY_S2,
    input  logic                      READY_S3,
    input  logic                      READY_S4,
    input  logic                      READY_S5,
    input  logic                      READY_SDEFAULT,

    output logic                      READY_S
);

always_comb
begin
    casez(ADDR[31:16])
        16'h0000: //ROM
        begin
            {VALID_SDEFAULT, VALID_S5 , VALID_S4 , VALID_S3 , VALID_S2, VALID_S1 , VALID_S0} = {6'b00_0000, VALID};
            READY_S = (VALID) ? READY_S0 : 1'b0;
        end
        
        16'h0001: //IM
        begin
            {VALID_SDEFAULT, VALID_S5 , VALID_S4 , VALID_S3 , VALID_S2, VALID_S1 , VALID_S0} = {5'b0_0000 , VALID , 1'b0};
            READY_S = (VALID) ? READY_S1 : 1'b0;
        end
        
        16'h0002: //DM
        begin
            {VALID_SDEFAULT, VALID_S5 , VALID_S4 , VALID_S3 , VALID_S2, VALID_S1 , VALID_S0} = {4'b0000 , VALID , 2'b00};
            READY_S = (VALID) ? READY_S2 : 1'b0;
        end
        
        16'h1002: //DMA
        begin
            if(ADDR[15:0] <= 16'h0400)
            begin
                {VALID_SDEFAULT, VALID_S5 , VALID_S4 , VALID_S3 , VALID_S2, VALID_S1 , VALID_S0} = {3'b000 , VALID , 3'b000};
                READY_S = (VALID) ? READY_S3 : 1'b0;
            end
            else
            begin
                {VALID_SDEFAULT, VALID_S5 , VALID_S4 , VALID_S3 , VALID_S2, VALID_S1 , VALID_S0} = {VALID, 6'b00_0000};
                READY_S = (VALID) ? READY_SDEFAULT : 1'b0;
            end
        end

        16'h1001: //WDT
        begin
            if(ADDR[15:0] <= 16'h03FF)
            begin         
                {VALID_SDEFAULT, VALID_S5 , VALID_S4 , VALID_S3 , VALID_S2, VALID_S1 , VALID_S0} = {2'b00, VALID , 4'b0000};
                READY_S = (VALID) ? READY_S4 : 1'b0;
            end
            else
            begin
                {VALID_SDEFAULT, VALID_S5 , VALID_S4 , VALID_S3 , VALID_S2, VALID_S1 , VALID_S0} = {VALID, 6'b00_0000};
                READY_S = (VALID) ? READY_SDEFAULT : 1'b0;
            end
        end

        16'h20??: //DRAM
        begin
            if(ADDR[23:0] <= 24'h1F_FFFF)
            begin         
                {VALID_SDEFAULT, VALID_S5 , VALID_S4 , VALID_S3 , VALID_S2, VALID_S1 , VALID_S0} = {1'b0, VALID , 5'b0_0000};
                READY_S = (VALID) ? READY_S5 : 1'b0;
            end
            else
            begin
                {VALID_SDEFAULT, VALID_S5 , VALID_S4 , VALID_S3 , VALID_S2, VALID_S1 , VALID_S0} = {VALID, 6'b00_0000};
                READY_S = (VALID) ? READY_SDEFAULT : 1'b0;
            end
        end      

        default:
        begin
            {VALID_SDEFAULT, VALID_S5 , VALID_S4 , VALID_S3 , VALID_S2, VALID_S1 , VALID_S0} = {VALID, 6'b00_0000};
            READY_S = (VALID) ? READY_SDEFAULT : 1'b0;
        end
    endcase
end

endmodule