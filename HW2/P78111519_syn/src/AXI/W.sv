`include "../../include/AXI_define.svh"

module W (
    input  logic                       clk,
    input  logic                       rstn,

    // master 1 send
    input  logic [`AXI_DATA_BITS -1:0] WDATA_M1,
    input  logic [`AXI_STRB_BITS -1:0] WSTRB_M1,
    input  logic                       WLAST_M1,
    input  logic                       WVALID_M1,
    // master 1 receive
    output logic                       WREADY_M1,

    // slave 0 receive
    output logic [`AXI_DATA_BITS -1:0] WDATA_S0,
    output logic [`AXI_STRB_BITS -1:0] WSTRB_S0,
    output logic                       WLAST_S0,
    output logic                       WVALID_S0,
    // slave 0 send
    input  logic                       WREADY_S0,

    // slave 1 receive
    output logic [`AXI_DATA_BITS -1:0] WDATA_S1,
    output logic [`AXI_STRB_BITS -1:0] WSTRB_S1,
    output logic                       WLAST_S1,
    output logic                       WVALID_S1,
    // slave 1 send
    input  logic                       WREADY_S1,

    // DEFAULT slave receive
    output logic [`AXI_DATA_BITS -1:0] WDATA_SDEFAULT,
    output logic [`AXI_STRB_BITS -1:0] WSTRB_SDEFAULT,
    output logic                       WLAST_SDEFAULT,
    output logic                       WVALID_SDEFAULT,
    // DEFAULT slave send
    input  logic                       WREADY_SDEFAULT,

    input  logic                       AWVALID_S0,
    input  logic                       AWVALID_S1,
    input  logic                       AWVALID_SDEFAULT
);

logic WVALID_S0_reg, WVALID_S1_reg, WVALID_SDEFAULT_reg;

logic [2:0] slave;

logic [`AXI_DATA_BITS-1:0] WDATA_M;
logic [`AXI_STRB_BITS-1:0] WSTRB_M;
logic WLAST_M;
logic WVALID_M;

logic READY;

// signals from master 1
assign WDATA_M = WDATA_M1;
assign WSTRB_M = WSTRB_M1;
assign WLAST_M = WLAST_M1;
assign WVALID_M = WVALID_M1;
// signals to master 1
assign WREADY_M1 = READY & WVALID_M;

// signals to slaves
// slave 0
assign WDATA_S0 = WDATA_M;
assign WSTRB_S0 = (WVALID_S0) ? WSTRB_M : `AXI_STRB_BITS'b0000;
assign WLAST_S0 = WLAST_M;
// slave 1
assign WDATA_S1 = WDATA_M;
assign WSTRB_S1 = (WVALID_S1) ? WSTRB_M : `AXI_STRB_BITS'b0000;
assign WLAST_S1 = WLAST_M;
// DEFAULT slave
assign WDATA_SDEFAULT = WDATA_M;
assign WSTRB_SDEFAULT = (WVALID_SDEFAULT) ? WSTRB_M : `AXI_STRB_BITS'b0000;
assign WLAST_SDEFAULT = WLAST_M;

assign slave = {(WVALID_SDEFAULT_reg | AWVALID_SDEFAULT), (WVALID_S1_reg | AWVALID_S1), (WVALID_S0_reg | AWVALID_S0)};

always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        WVALID_S0_reg       <= 1'b0;
        WVALID_S1_reg       <= 1'b0;
        WVALID_SDEFAULT_reg <= 1'b0;
    end
    else
    begin //?
        WVALID_S0_reg       <= (      AWVALID_S0) ? 1'b1 : ( (WLAST_M) ? 1'b0 : WVALID_S0_reg      );
        WVALID_S1_reg       <= (      AWVALID_S1) ? 1'b1 : ( (WLAST_M) ? 1'b0 : WVALID_S1_reg      );
        WVALID_SDEFAULT_reg <= (AWVALID_SDEFAULT) ? 1'b1 : ( (WLAST_M) ? 1'b0 : WVALID_SDEFAULT_reg);
    end
end

always_comb
begin
    case(slave)
        // slave 0
        3'b001:
        begin
            READY = WREADY_S0;
            {WVALID_SDEFAULT, WVALID_S1, WVALID_S0} = {2'b00, WVALID_M};
        end
        // slave 1
        3'b010:
        begin
            READY = WREADY_S1;
            {WVALID_SDEFAULT, WVALID_S1, WVALID_S0} = {1'b0, WVALID_M , 1'b0};
        end
        // DEFAULT slave
        3'b100:
        begin
            READY = WREADY_SDEFAULT;
            {WVALID_SDEFAULT, WVALID_S1, WVALID_S0} = {WVALID_M, 2'b00};
        end
        default:
        begin
            READY = 1'b0;
            {WVALID_SDEFAULT, WVALID_S1, WVALID_S0} = 3'b000;
        end
    endcase
end

endmodule