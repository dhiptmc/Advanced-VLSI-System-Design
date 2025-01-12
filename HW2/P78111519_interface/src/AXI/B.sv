module B (
    B_interface.M1       M1,
    B_interface.S1       S1,
    B_interface.S2       S2,
    B_interface.SDEFAULT SDEFAULT
);

logic [             1:0] master;
logic [             2:0] slave;
logic                    READY;

logic [`AXI_ID_BITS-1:0] BID_M;
logic [             1:0] BRESP_M;
logic                    BVALID_M;

always_comb
begin
    if(SDEFAULT.BVALID)
        slave = 3'b100;
    else if(S2.BVALID)
        slave = 3'b010;
    else if(S1.BVALID)
        slave = 3'b001;
    else
        slave = 3'b000;
end

always_comb
begin
    case(master)
        2'b10:
        begin
            READY     = M1.BREADY;
            M1.BID    = BID_M;
            M1.BRESP  = BRESP_M;
            M1.BVALID = BVALID_M;
        end
        default:
        begin
            READY     = 1'b0;
            M1.BID    = `AXI_ID_BITS'd0;
            M1.BRESP  = `AXI_RESP_DECERR;
            M1.BVALID = 1'b0;
        end
    endcase
end

always_comb
begin
    case(slave)
        3'b001:
        begin
            master   = S1.BID_S[5:4];
            BID_M    = S1.BID_S[`AXI_ID_BITS-1:0];
            BRESP_M  = S1.BRESP;
            BVALID_M = S1.BVALID;
            {SDEFAULT.BREADY, S2.BREADY, S1.BREADY} = {2'b00, READY & S1.BVALID};
        end
        3'b010:
        begin
            master   = S2.BID_S[5:4];
            BID_M    = S2.BID_S[`AXI_ID_BITS-1:0];
            BRESP_M  = S2.BRESP;
            BVALID_M = S2.BVALID;
            {SDEFAULT.BREADY, S2.BREADY, S1.BREADY} = {1'b0, READY & S2.BVALID , 1'b0};
        end
        3'b100:
        begin
            master   = SDEFAULT.BID_S[5:4];
            BID_M    = SDEFAULT.BID_S[`AXI_ID_BITS-1:0];
            BRESP_M  = SDEFAULT.BRESP;
            BVALID_M = SDEFAULT.BVALID;
            {SDEFAULT.BREADY, S2.BREADY, S1.BREADY} = {READY & SDEFAULT.BVALID, 2'b00};
        end
        default:
        begin
            master   = 2'b00;
            BID_M    = `AXI_ID_BITS'd0;
            BRESP_M  = `AXI_RESP_DECERR;
            BVALID_M = 1'b0;
            {SDEFAULT.BREADY, S2.BREADY, S1.BREADY} = 3'b000;
        end
    endcase
end

endmodule