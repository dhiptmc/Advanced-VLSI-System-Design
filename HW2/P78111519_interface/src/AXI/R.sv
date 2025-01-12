module R (
    input logic         clk,
    input logic         rstn,

    R_interface.M0       M0,
    R_interface.M1       M1,
    R_interface.S1       S1,
    R_interface.S2       S2,
    R_interface.SDEFAULT SDEFAULT
);

logic [2:0] slave;

// Slave
logic [`AXI_IDS_BITS -1:0] RID_S;
logic [`AXI_DATA_BITS-1:0] RDATA_S;
logic [               1:0] RRESP_S;
logic                      RLAST_S;

logic lock_s1;
logic lock_s2;
logic lock_sdefault;

// M0
assign M0.RID   = RID_S[`AXI_ID_BITS-1:0];
assign M0.RDATA = RDATA_S;
assign M0.RRESP = RRESP_S;
assign M0.RLAST = RLAST_S;
// M1
assign M1.RID   = RID_S[`AXI_ID_BITS-1:0];
assign M1.RDATA = RDATA_S;
assign M1.RRESP = RRESP_S;
assign M1.RLAST = RLAST_S;

always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        lock_s1       <= 1'b0;
        lock_s2       <= 1'b0;
        lock_sdefault <= 1'd0;
    end
    else
    begin
        lock_s1       <= (S1.RLAST      ) ? 1'b0 : (S1.RVALID && ~lock_s2   && ~lock_sdefault  ) ? 1'b1 : lock_s1; //when slave undone, lock it
        lock_s2       <= (S2.RLAST      ) ? 1'b0 : (~lock_s1  &&  S2.RVALID && ~lock_sdefault  ) ? 1'b1 : lock_s2;
        lock_sdefault <= (SDEFAULT.RLAST) ? 1'b0 : (~lock_s1  && ~lock_s2   &&  SDEFAULT.RVALID) ? 1'b1 : lock_sdefault;
    end
end

always_comb
begin
    if( (SDEFAULT.RVALID && (~(lock_s1 | lock_s2)) ) || lock_sdefault )
        slave = 3'b100;
    else if( (S2.RVALID && (~lock_s1) ) || lock_s2 )
        slave = 3'b010;
    else if(S1.RVALID || lock_s1)
        slave = 3'b001;
    else
        slave = 3'b000;
end

always_comb
begin
    case (slave)
        3'b001: //slave 1
        begin
            RID_S    = S1.RID_S;
            RDATA_S  = S1.RDATA;
            RRESP_S  = S1.RRESP;
            RLAST_S  = S1.RLAST;

            case(S1.RID_S[5:4])
                2'b01: //master 0
                begin
                    {SDEFAULT.RREADY , S2.RREADY , S1.RREADY} = {2'b00, M0.RREADY & S1.RVALID};
                    {M1.RVALID, M0.RVALID} = {1'b0, S1.RVALID};
                end

                2'b10: //master 1
                begin
                    {SDEFAULT.RREADY , S2.RREADY , S1.RREADY} = {2'b00, M1.RREADY & S1.RVALID};
                    {M1.RVALID, M0.RVALID} = {S1.RVALID, 1'b0};
                end

                default:
                begin
                    {SDEFAULT.RREADY , S2.RREADY , S1.RREADY} = 3'b000;
                    {M1.RVALID, M0.RVALID} = 2'b00;
                end
            endcase
        end

        3'b010: //slave 2
        begin
            RID_S    = S2.RID_S;
            RDATA_S  = S2.RDATA;
            RRESP_S  = S2.RRESP;
            RLAST_S  = S2.RLAST;


            case(S2.RID_S[5:4])
                2'b01: //master 0
                begin
                    {SDEFAULT.RREADY , S2.RREADY , S1.RREADY} = {1'b0, M0.RREADY & S2.RVALID , 1'b0};
                    {M1.RVALID, M0.RVALID} = {1'b0, S2.RVALID};
                end

                2'b10: //master 1
                begin
                    {SDEFAULT.RREADY , S2.RREADY , S1.RREADY} = {1'b0, M1.RREADY & S2.RVALID , 1'b0};
                    {M1.RVALID, M0.RVALID} = {S2.RVALID, 1'b0};
                end

                default:
                begin
                    {SDEFAULT.RREADY , S2.RREADY , S1.RREADY} = 3'b000;
                    {M1.RVALID, M0.RVALID} = 2'b00;
                end
            endcase
        end
        
        3'b100: //DEFAULT slave
        begin
            RID_S    = SDEFAULT.RID_S;
            RDATA_S  = SDEFAULT.RDATA;
            RRESP_S  = SDEFAULT.RRESP;
            RLAST_S  = SDEFAULT.RLAST;

            case(SDEFAULT.RID_S[5:4])
                2'b01: //master 0
                begin
                    {SDEFAULT.RREADY , S2.RREADY , S1.RREADY} = {M0.RREADY & SDEFAULT.RVALID, 2'b00};
                    {M1.RVALID, M0.RVALID} = {1'b0, SDEFAULT.RVALID};
                end

                2'b10: //master 1
                begin
                    {SDEFAULT.RREADY , S2.RREADY , S1.RREADY} = {M1.RREADY & SDEFAULT.RVALID, 2'b00};
                    {M1.RVALID, M0.RVALID} = {SDEFAULT.RVALID, 1'b0};
                end

                default:
                begin
                    {SDEFAULT.RREADY , S2.RREADY , S1.RREADY} = 3'b000;
                    {M1.RVALID, M0.RVALID} = 2'b00;
                end
            endcase
        end

        default:
        begin
            RID_S    = `AXI_IDS_BITS'd0;
            RDATA_S  = `AXI_DATA_BITS'd0;
            RRESP_S  = `AXI_RESP_DECERR;
            RLAST_S  = 1'b0;

            {SDEFAULT.RREADY , S2.RREADY , S1.RREADY} = 3'b000;
            {M1.RVALID, M0.RVALID} = 2'b00;
        end
    endcase
end

endmodule