module B (
    B_interface.M1       M1,
    B_interface.M2       M2, 
    B_interface.S1       S1,
    B_interface.S2       S2,
    B_interface.S3       S3,
    B_interface.S4       S4,
    B_interface.S5       S5,
    B_interface.SDEFAULT SDEFAULT
);

logic [3:0] master;
logic [5:0] slave;
logic                    READY;

logic [`AXI_ID_BITS-1:0] BID_M;
logic [             1:0] BRESP_M;
logic                    BVALID_M;

always_comb
begin
    if(SDEFAULT.BVALID)
        slave = 6'b10_0000;
    else if(S5.BVALID)
        slave = 6'b01_0000;
    else if(S4.BVALID)
        slave = 6'b00_1000;
    else if(S3.BVALID)
        slave = 6'b00_0100;
    else if(S2.BVALID)
        slave = 6'b00_0010;
    else if(S1.BVALID)
        slave = 6'b00_0001;
    else
        slave = 6'b00_0000;
end

always_comb
begin
    case(master)
        4'b0010:
        begin
            READY     = M1.BREADY;
            M1.BID    = BID_M;
            M1.BRESP  = BRESP_M;
            M1.BVALID = BVALID_M;
            M2.BID    = `AXI_ID_BITS'd0;
            M2.BRESP  = `AXI_RESP_DECERR;
            M2.BVALID = 1'b0;
        end

        4'b0100:
        begin
            READY     = M2.BREADY;
            M1.BID    = `AXI_ID_BITS'd0;
            M1.BRESP  = `AXI_RESP_DECERR;
            M1.BVALID = 1'b0;
            M2.BID    = BID_M;
            M2.BRESP  = BRESP_M;
            M2.BVALID = BVALID_M;
        end

        default:
        begin
            READY     = 1'b0;
            M1.BID    = `AXI_ID_BITS'd0;
            M1.BRESP  = `AXI_RESP_DECERR;
            M1.BVALID = 1'b0;
            M2.BID    = `AXI_ID_BITS'd0;
            M2.BRESP  = `AXI_RESP_DECERR;
            M2.BVALID = 1'b0;
        end
    endcase
end

always_comb
begin
    case(slave)
        6'b00_0001:
        begin
            master   = S1.BID_S[7:4];
            BID_M    = S1.BID_S[`AXI_ID_BITS-1:0];
            BRESP_M  = S1.BRESP;
            BVALID_M = S1.BVALID;
            {SDEFAULT.BREADY, S5.BREADY , S4.BREADY , S3.BREADY , S2.BREADY , S1.BREADY} = {5'b0_0000, READY & S1.BVALID};           
        end

        6'b00_0010:
        begin
            master   = S2.BID_S[7:4];
            BID_M    = S2.BID_S[`AXI_ID_BITS-1:0];
            BRESP_M  = S2.BRESP;
            BVALID_M = S2.BVALID;
            {SDEFAULT.BREADY, S5.BREADY , S4.BREADY , S3.BREADY , S2.BREADY , S1.BREADY} = {4'b0000, READY & S2.BVALID , 1'b0};
        end

        6'b00_0100:
        begin
            master   = S3.BID_S[7:4];
            BID_M    = S3.BID_S[`AXI_ID_BITS-1:0];
            BRESP_M  = S3.BRESP;
            BVALID_M = S3.BVALID;
            {SDEFAULT.BREADY, S5.BREADY , S4.BREADY , S3.BREADY , S2.BREADY , S1.BREADY} = {3'b000 , READY & S3.BVALID , 2'b00};
        end

        6'b00_1000:
        begin
            master   = S4.BID_S[7:4];
            BID_M    = S4.BID_S[`AXI_ID_BITS-1:0];
            BRESP_M  = S4.BRESP;
            BVALID_M = S4.BVALID;
            {SDEFAULT.BREADY, S5.BREADY , S4.BREADY , S3.BREADY , S2.BREADY , S1.BREADY} = {2'b00 , READY & S4.BVALID , 3'b000};
        end

        6'b01_0000:
        begin
            master   = S5.BID_S[7:4];
            BID_M    = S5.BID_S[`AXI_ID_BITS-1:0];
            BRESP_M  = S5.BRESP;
            BVALID_M = S5.BVALID;
            {SDEFAULT.BREADY, S5.BREADY , S4.BREADY , S3.BREADY , S2.BREADY , S1.BREADY} = {1'b0, READY & S5.BVALID , 4'b0000};
        end

        6'b10_0000:
        begin
            master   = SDEFAULT.BID_S[7:4];
            BID_M    = SDEFAULT.BID_S[`AXI_ID_BITS-1:0];
            BRESP_M  = SDEFAULT.BRESP;
            BVALID_M = SDEFAULT.BVALID;
            {SDEFAULT.BREADY, S5.BREADY , S4.BREADY , S3.BREADY , S2.BREADY , S1.BREADY} = {READY & SDEFAULT.BVALID, 5'b0_0000};
        end

        default:
        begin
            master   = 4'b0000;
            BID_M    = `AXI_ID_BITS'd0;
            BRESP_M  = `AXI_RESP_DECERR;
            BVALID_M = 1'b0;
            {SDEFAULT.BREADY, S5.BREADY , S4.BREADY , S3.BREADY , S2.BREADY , S1.BREADY} = 6'b00_0000;
        end
    endcase
end

endmodule