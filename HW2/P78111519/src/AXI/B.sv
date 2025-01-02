`include "../../include/AXI_define.svh"

module B (
    // master 1 receive
    output logic [`AXI_ID_BITS -1:0] BID_M1,
    output logic [              1:0] BRESP_M1,
    output logic                     BVALID_M1,
    // master 1 send
    input  logic                     BREADY_M1,

    // slave 0 send
    input  logic [`AXI_IDS_BITS-1:0] BID_S0,
    input  logic [              1:0] BRESP_S0,
    input  logic                     BVALID_S0,
    // slave 0 receive
    output logic                     BREADY_S0,

    // slave 1 send
    input  logic [`AXI_IDS_BITS-1:0] BID_S1,
    input  logic [              1:0] BRESP_S1,
    input  logic                     BVALID_S1,
    // slave 1 receive
    output logic                     BREADY_S1,

    // DEFAULT slave send
    input  logic [`AXI_IDS_BITS-1:0] BID_SDEFAULT,
    input  logic [              1:0] BRESP_SDEFAULT,
    input  logic                     BVALID_SDEFAULT,
    // DEFAULT slave receive
    output logic                     BREADY_SDEFAULT 
);

logic [             1:0] master;
logic [             2:0] slave;
logic                    READY;

logic [`AXI_ID_BITS-1:0] BID_M;
logic [             1:0] BRESP_M;
logic                    BVALID_M;

always_comb
begin
    if(BVALID_SDEFAULT)
        slave = 3'b100;
    else if(BVALID_S1)
        slave = 3'b010;
    else if(BVALID_S0)
        slave = 3'b001;
    else
        slave = 3'b000;
end

always_comb
begin
    case(master)
        2'b10:
        begin
            READY     = BREADY_M1;
            BID_M1    = BID_M;
            BRESP_M1  = BRESP_M;
            BVALID_M1 = BVALID_M;
        end
        default:
        begin
            READY     = 1'b0;
            BID_M1    = `AXI_ID_BITS'd0;
            BRESP_M1  = `AXI_RESP_DECERR;
            BVALID_M1 = 1'b0;
        end
    endcase
end

always_comb
begin
    case(slave)
        3'b001:
        begin
            master   = BID_S0[5:4];
            BID_M    = BID_S0[`AXI_ID_BITS-1:0];
            BRESP_M  = BRESP_S0;
            BVALID_M = BVALID_S0;
            {BREADY_SDEFAULT, BREADY_S1, BREADY_S0} = {2'b00, READY & BVALID_S0};
        end
        3'b010:
        begin
            master   = BID_S1[5:4];
            BID_M    = BID_S1[`AXI_ID_BITS-1:0];
            BRESP_M  = BRESP_S1;
            BVALID_M = BVALID_S1;
            {BREADY_SDEFAULT, BREADY_S1, BREADY_S0} = {1'b0, READY & BVALID_S1, 1'b0};
        end
        3'b100:
        begin
            master   = BID_SDEFAULT[5:4];
            BID_M    = BID_SDEFAULT[`AXI_ID_BITS-1:0];
            BRESP_M  = BRESP_SDEFAULT;
            BVALID_M = BVALID_SDEFAULT;
            {BREADY_SDEFAULT, BREADY_S1, BREADY_S0} = {READY & BVALID_SDEFAULT, 2'b00};
        end
        default:
        begin
            master   = 2'b00;
            BID_M    = `AXI_ID_BITS'd0;
            BRESP_M  = `AXI_RESP_DECERR;
            BVALID_M = 1'b0;
            {BREADY_SDEFAULT, BREADY_S1, BREADY_S0} = 3'b000;
        end
    endcase
end

endmodule