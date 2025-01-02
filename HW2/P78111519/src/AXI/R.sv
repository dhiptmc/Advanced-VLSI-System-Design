`include "../../include/AXI_define.svh"

module R (
    input  logic                       clk,
    input  logic                       rstn,

    // Master 0 receive
    output logic [ `AXI_ID_BITS  -1:0] RID_M0,
    output logic [`AXI_DATA_BITS -1:0] RDATA_M0,
    output logic [                1:0] RRESP_M0,
    output logic                       RLAST_M0,
    output logic                       RVALID_M0,
    // Master 0 send
    input  logic                       RREADY_M0,

    // Master 1 receive
    output logic [  `AXI_ID_BITS -1:0] RID_M1,
    output logic [`AXI_DATA_BITS -1:0] RDATA_M1,
    output logic [                1:0] RRESP_M1,
    output logic                       RLAST_M1,
    output logic                       RVALID_M1,
    // Master 1 send
    input  logic                       RREADY_M1,

    // Slave 0 send
    input  logic [ `AXI_IDS_BITS -1:0] RID_S0,
    input  logic [`AXI_DATA_BITS -1:0] RDATA_S0,
    input  logic [                1:0] RRESP_S0,
    input  logic                       RLAST_S0,
    input  logic                       RVALID_S0,
    // Slave 0 receive
    output logic                       RREADY_S0,

    // slave 1 send
    input  logic [ `AXI_IDS_BITS -1:0] RID_S1,
    input  logic [`AXI_DATA_BITS -1:0] RDATA_S1,
    input  logic [                1:0] RRESP_S1,
    input  logic                       RLAST_S1,
    input  logic                       RVALID_S1,
    // slave 1 receive
    output logic                       RREADY_S1,

    // DEFAULT slave send
    input  logic [ `AXI_IDS_BITS -1:0] RID_SDEFAULT,
    input  logic [`AXI_DATA_BITS -1:0] RDATA_SDEFAULT,
    input  logic [                1:0] RRESP_SDEFAULT,
    input  logic                       RLAST_SDEFAULT,
    input  logic                       RVALID_SDEFAULT,
    // DEFAULT slave receive
    output logic                       RREADY_SDEFAULT
);

logic [2:0] slave;

// Slave
logic [`AXI_IDS_BITS -1:0] RID_S;
logic [`AXI_DATA_BITS-1:0] RDATA_S;
logic [               1:0] RRESP_S;
logic                      RLAST_S;

logic lock_s0;
logic lock_s1;
logic lock_s2;

// M0
assign RID_M0   = RID_S[`AXI_ID_BITS-1:0];
assign RDATA_M0 = RDATA_S;
assign RRESP_M0 = RRESP_S;
assign RLAST_M0 = RLAST_S;
// M1
assign RID_M1   = RID_S[`AXI_ID_BITS-1:0];
assign RDATA_M1 = RDATA_S;
assign RRESP_M1 = RRESP_S;
assign RLAST_M1 = RLAST_S;

always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        lock_s0 <= 1'b0;
        lock_s1 <= 1'b0;
        lock_s2 <= 1'b0;
    end
    else
    begin
        lock_s0 <= (RLAST_S0      ) ? 1'b0 : (RVALID_S0 && ~lock_s1   &&        ~lock_s2) ? 1'b1 : lock_s0; //when slave undone, lock it
        lock_s1 <= (RLAST_S1      ) ? 1'b0 : (~lock_s0  &&  RVALID_S1 &&        ~lock_s2) ? 1'b1 : lock_s1;
        lock_s2 <= (RLAST_SDEFAULT) ? 1'b0 : (~lock_s0  && ~lock_s1   && RVALID_SDEFAULT) ? 1'b1 : lock_s2;
    end
end

always_comb
begin
    if( (RVALID_SDEFAULT && (~(lock_s0 | lock_s1)) ) || lock_s2 )
        slave = 3'b100;
    else if( (RVALID_S1 && (~lock_s0) ) || lock_s1 )
        slave = 3'b010;
    else if(RVALID_S0 || lock_s0)
        slave = 3'b001;
    else
        slave = 3'b000;
end

// always_comb
// begin
//     case(master)
//         2'b01: //master 0
//         begin
//             READY_M = RREADY_M0;
//             {RVALID_M1, RVALID_M0} = {1'b0, RVALID_S};
//         end

//         2'b10: //master 1
//         begin
//             READY_M = RREADY_M1;
//             {RVALID_M1, RVALID_M0} = {RVALID_S, 1'b0};
//         end

//         default:
//         begin
//             READY_M = 1'b0;
//             {RVALID_M1, RVALID_M0} = 2'b00;
//         end
//     endcase
// end

always_comb
begin
    case (slave)
        3'b001: //slave 0
        begin
            RID_S    = RID_S0;
            RDATA_S  = RDATA_S0;
            RRESP_S  = RRESP_S0;
            RLAST_S  = RLAST_S0;

            case(RID_S0[5:4])
                2'b01: //master 0
                begin
                    {RREADY_SDEFAULT, RREADY_S1, RREADY_S0} = {2'b00, RREADY_M0 & RVALID_S0};
                    {RVALID_M1, RVALID_M0} = {1'b0, RVALID_S0};
                end

                2'b10: //master 1
                begin
                    {RREADY_SDEFAULT, RREADY_S1, RREADY_S0} = {2'b00, RREADY_M1 & RVALID_S0};
                    {RVALID_M1, RVALID_M0} = {RVALID_S0, 1'b0};
                end

                default:
                begin
                    {RREADY_SDEFAULT, RREADY_S1, RREADY_S0} = 3'b000;
                    {RVALID_M1, RVALID_M0} = 2'b00;
                end
            endcase
        end

        3'b010: //slave 1
        begin
            RID_S    = RID_S1;
            RDATA_S  = RDATA_S1;
            RRESP_S  = RRESP_S1;
            RLAST_S  = RLAST_S1;


            case(RID_S1[5:4])
                2'b01: //master 0
                begin
                    {RREADY_SDEFAULT, RREADY_S1, RREADY_S0} = {1'b0, RREADY_M0 & RVALID_S1 , 1'b0};
                    {RVALID_M1, RVALID_M0} = {1'b0, RVALID_S1};
                end

                2'b10: //master 1
                begin
                    {RREADY_SDEFAULT, RREADY_S1, RREADY_S0} = {1'b0, RREADY_M1 & RVALID_S1 , 1'b0};
                    {RVALID_M1, RVALID_M0} = {RVALID_S1, 1'b0};
                end

                default:
                begin
                    {RREADY_SDEFAULT, RREADY_S1, RREADY_S0} = 3'b000;
                    {RVALID_M1, RVALID_M0} = 2'b00;
                end
            endcase
        end
        
        3'b100: //DEFAULT slave
        begin
            RID_S    = RID_SDEFAULT;
            RDATA_S  = RDATA_SDEFAULT;
            RRESP_S  = RRESP_SDEFAULT;
            RLAST_S  = RLAST_SDEFAULT;

            case(RID_SDEFAULT[5:4])
                2'b01: //master 0
                begin
                    {RREADY_SDEFAULT, RREADY_S1, RREADY_S0} = {RREADY_M0 & RVALID_SDEFAULT, 2'b00};
                    {RVALID_M1, RVALID_M0} = {1'b0, RVALID_SDEFAULT};
                end

                2'b10: //master 1
                begin
                    {RREADY_SDEFAULT, RREADY_S1, RREADY_S0} = {RREADY_M1 & RVALID_SDEFAULT, 2'b00};
                    {RVALID_M1, RVALID_M0} = {RVALID_SDEFAULT, 1'b0};
                end

                default:
                begin
                    {RREADY_SDEFAULT, RREADY_S1, RREADY_S0} = 3'b000;
                    {RVALID_M1, RVALID_M0} = 2'b00;
                end
            endcase
        end

        default:
        begin
            RID_S    = `AXI_IDS_BITS'd0;
            RDATA_S  = `AXI_DATA_BITS'd0;
            RRESP_S  = `AXI_RESP_DECERR;
            RLAST_S  = 1'b0;

            {RREADY_SDEFAULT, RREADY_S1, RREADY_S0} = 3'b000;
            {RVALID_M1, RVALID_M0} = 2'b00;
        end
    endcase
end

endmodule