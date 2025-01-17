module R (
    input logic          clk,
    input logic          rstn,

    R_interface.M0       M0,
    R_interface.M1       M1,
    R_interface.M2       M2,
    R_interface.S0       S0,
    R_interface.S1       S1,
    R_interface.S2       S2,
    R_interface.S3       S3,
    R_interface.S4       S4,
    R_interface.S5       S5,
    R_interface.SDEFAULT SDEFAULT

);

logic [6:0] slave;

// Slave
logic [`AXI_IDS_BITS -1:0] RID_S;
logic [`AXI_DATA_BITS-1:0] RDATA_S;
logic [               1:0] RRESP_S;
logic                      RLAST_S;

logic lock_s0;
logic lock_s1;
logic lock_s2;
logic lock_s3;
logic lock_s4;
logic lock_s5;
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
// DMA
assign M2.RID   = RID_S[`AXI_ID_BITS-1:0];
assign M2.RDATA = RDATA_S;
assign M2.RRESP = RRESP_S;
assign M2.RLAST = RLAST_S;

always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        lock_s0       <= 1'b0;
        lock_s1       <= 1'b0;
        lock_s2       <= 1'b0;
        lock_s3       <= 1'b0;
        lock_s4       <= 1'b0;
        lock_s5       <= 1'b0;
        lock_sdefault <= 1'b0;
    end
    else
    begin //when slave undone, lock it
        lock_s0       <= (S0.RLAST)       ? 1'b0 : (      S0.RVALID && ~lock_s1 && ~lock_s2 && ~lock_s3 && ~lock_s4 && ~lock_s5 && ~lock_sdefault) ? 1'b1 : lock_s0      ; 
        lock_s1       <= (S1.RLAST)       ? 1'b0 : (      S1.RVALID && ~lock_s0 && ~lock_s2 && ~lock_s3 && ~lock_s4 && ~lock_s5 && ~lock_sdefault) ? 1'b1 : lock_s1      ;
        lock_s2       <= (S2.RLAST)       ? 1'b0 : (      S2.RVALID && ~lock_s0 && ~lock_s1 && ~lock_s3 && ~lock_s4 && ~lock_s5 && ~lock_sdefault) ? 1'b1 : lock_s2      ;
        lock_s3       <= (S3.RLAST)       ? 1'b0 : (      S3.RVALID && ~lock_s0 && ~lock_s1 && ~lock_s2 && ~lock_s4 && ~lock_s5 && ~lock_sdefault) ? 1'b1 : lock_s3      ;
        lock_s4       <= (S4.RLAST)       ? 1'b0 : (      S4.RVALID && ~lock_s0 && ~lock_s1 && ~lock_s2 && ~lock_s3 && ~lock_s5 && ~lock_sdefault) ? 1'b1 : lock_s4      ;
        lock_s5       <= (S5.RLAST)       ? 1'b0 : (      S5.RVALID && ~lock_s0 && ~lock_s1 && ~lock_s2 && ~lock_s3 && ~lock_s4 && ~lock_sdefault) ? 1'b1 : lock_s5      ;
        lock_sdefault <= (SDEFAULT.RLAST) ? 1'b0 : (SDEFAULT.RVALID && ~lock_s0 && ~lock_s1 && ~lock_s2 && ~lock_s3 && ~lock_s4 && ~lock_s5      ) ? 1'b1 : lock_sdefault;
    end
end

always_comb
begin
    if( ( SDEFAULT.RVALID && (~(lock_s0 | lock_s1 | lock_s2 | lock_s3 | lock_s4 | lock_s5)) ) || lock_sdefault )
        slave = 7'b100_0000;
    else if( ( S5.RVALID && (~(lock_s0 | lock_s1 | lock_s2 | lock_s3 | lock_s4)) ) || lock_s5 )
        slave = 7'b010_0000;
    else if( ( S4.RVALID && (~(lock_s0 | lock_s1 | lock_s2 | lock_s3)) ) || lock_s4 )
        slave = 7'b001_0000;
    else if( ( S3.RVALID && (~(lock_s0 | lock_s1 | lock_s2)) ) || lock_s3 )
        slave = 7'b000_1000;
    else if( ( S2.RVALID && (~(lock_s0 | lock_s1)) ) || lock_s2 )
        slave = 7'b000_0100;      
    else if( ( S1.RVALID && (~lock_s0) ) || lock_s1 )
        slave = 7'b000_0010;   
    else if( S0.RVALID || lock_s0 )
        slave = 7'b000_0001; 
    else
        slave = 7'b000_0000;
end

always_comb
begin
    case (slave)
        7'b000_0001:
        begin
            RID_S    = S0.RID_S;
            RDATA_S  = S0.RDATA;
            RRESP_S  = S0.RRESP;
            RLAST_S  = S0.RLAST;

            case(S0.RID_S[6:4])
                3'b001: //master 0
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {6'b00_0000, M0.RREADY & S0.RVALID};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {2'b00, S0.RVALID};
                end

                3'b010: //master 1
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {6'b00_0000, M1.RREADY & S0.RVALID};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {1'b0, S0.RVALID , 1'b0};
                end

                3'b100: //DMA
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {6'b00_0000, M2.RREADY & S0.RVALID};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {S0.RVALID, 2'b00};
                end

                default:
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = 7'b000_0000;
                    {M2.RVALID , M1.RVALID , M0.RVALID} = 3'b000;
                end
            endcase
        end

        7'b000_0010:
        begin
            RID_S    = S1.RID_S;
            RDATA_S  = S1.RDATA;
            RRESP_S  = S1.RRESP;
            RLAST_S  = S1.RLAST;

            case(S1.RID_S[6:4])
                3'b001: //master 0
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {5'b0_0000 , M0.RREADY & S1.RVALID , 1'b0};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {2'b00, S1.RVALID};
                end

                3'b010: //master 1
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {5'b0_0000 , M1.RREADY & S1.RVALID , 1'b0};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {1'b0, S1.RVALID , 1'b0};
                end

                3'b100: //DMA
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {5'b0_0000 , M2.RREADY & S1.RVALID , 1'b0};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {S1.RVALID, 2'b00};
                end

                default:
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = 7'b000_0000;
                    {M2.RVALID , M1.RVALID , M0.RVALID} = 3'b000;
                end
            endcase
        end

        7'b000_0100:
        begin
            RID_S    = S2.RID_S;
            RDATA_S  = S2.RDATA;
            RRESP_S  = S2.RRESP;
            RLAST_S  = S2.RLAST;

            case(S2.RID_S[6:4])
                3'b001: //master 0
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {4'b0000 , M0.RREADY & S2.RVALID , 2'b00};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {2'b00, S2.RVALID};
                end

                3'b010: //master 1
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {4'b0000 , M1.RREADY & S2.RVALID , 2'b00};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {1'b0, S2.RVALID , 1'b0};
                end

                3'b100: //DMA
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {4'b0000 , M2.RREADY & S2.RVALID , 2'b00};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {S2.RVALID, 2'b00};
                end

                default:
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = 7'b000_0000;
                    {M2.RVALID , M1.RVALID , M0.RVALID} = 3'b000;
                end
            endcase
        end

        7'b000_1000:
        begin
            RID_S    = S3.RID_S;
            RDATA_S  = S3.RDATA;
            RRESP_S  = S3.RRESP;
            RLAST_S  = S3.RLAST;

            case(S3.RID_S[6:4])
                3'b001: //master 0
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {3'b000 , M0.RREADY & S3.RVALID , 3'b000};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {2'b00, S3.RVALID};
                end

                3'b010: //master 1
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {3'b000 , M1.RREADY & S3.RVALID , 3'b000};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {1'b0, S3.RVALID , 1'b0};
                end

                3'b100: //DMA
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {3'b000 , M2.RREADY & S3.RVALID , 3'b000};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {S3.RVALID, 2'b00};
                end

                default:
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = 7'b000_0000;
                    {M2.RVALID , M1.RVALID , M0.RVALID} = 3'b000;
                end
            endcase
        end

        7'b001_0000:
        begin
            RID_S    = S4.RID_S;
            RDATA_S  = S4.RDATA;
            RRESP_S  = S4.RRESP;
            RLAST_S  = S4.RLAST;

            case(S4.RID_S[6:4])
                3'b001: //master 0
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {2'b00 , M0.RREADY & S4.RVALID , 4'b0000};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {2'b00, S4.RVALID};
                end

                3'b010: //master 1
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {2'b00 , M1.RREADY & S4.RVALID , 4'b0000};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {1'b0, S4.RVALID , 1'b0};
                end

                3'b100: //DMA
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {2'b00 , M2.RREADY & S4.RVALID , 4'b0000};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {S4.RVALID, 2'b00};
                end

                default:
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = 7'b000_0000;
                    {M2.RVALID , M1.RVALID , M0.RVALID} = 3'b000;
                end
            endcase
        end

        7'b010_0000:
        begin
            RID_S    = S5.RID_S;
            RDATA_S  = S5.RDATA;
            RRESP_S  = S5.RRESP;
            RLAST_S  = S5.RLAST;

            case(S5.RID_S[6:4])
                3'b001: //master 0
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {1'b0, M0.RREADY & S5.RVALID , 5'b0_0000};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {2'b00, S5.RVALID};
                end

                3'b010: //master 1
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {1'b0, M1.RREADY & S5.RVALID , 5'b0_0000};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {1'b0, S5.RVALID , 1'b0};
                end

                3'b100: //DMA
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {1'b0, M2.RREADY & S5.RVALID , 5'b0_0000};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {S5.RVALID, 2'b00};
                end

                default:
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = 7'b000_0000;
                    {M2.RVALID , M1.RVALID , M0.RVALID} = 3'b000;
                end
            endcase
        end

        7'b100_0000:
        begin
            RID_S    = SDEFAULT.RID_S;
            RDATA_S  = SDEFAULT.RDATA;
            RRESP_S  = SDEFAULT.RRESP;
            RLAST_S  = SDEFAULT.RLAST;

            case(SDEFAULT.RID_S[6:4])
                3'b001: //master 0
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {M0.RREADY & SDEFAULT.RVALID, 6'b00_0000};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {2'b00, SDEFAULT.RVALID};
                end

                3'b010: //master 1
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {M1.RREADY & SDEFAULT.RVALID , 6'b00_0000};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {1'b0, SDEFAULT.RVALID , 1'b0};
                end

                3'b100: //DMA
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = {M2.RREADY & SDEFAULT.RVALID , 6'b00_0000};
                    {M2.RVALID , M1.RVALID , M0.RVALID} = {SDEFAULT.RVALID, 2'b00};
                end

                default:
                begin
                    {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = 7'b000_0000;
                    {M2.RVALID , M1.RVALID , M0.RVALID} = 3'b000;
                end
            endcase
        end

        default:
        begin
            RID_S    = `AXI_IDS_BITS'd0;
            RDATA_S  = `AXI_DATA_BITS'd0;
            RRESP_S  = `AXI_RESP_DECERR;
            RLAST_S  = 1'b0;

            {SDEFAULT.RREADY, S5.RREADY , S4.RREADY , S3.RREADY , S2.RREADY , S1.RREADY , S0.RREADY} = 7'b000_0000;
            {M2.RVALID , M1.RVALID , M0.RVALID} = 3'b000;
        end
    endcase
end

endmodule