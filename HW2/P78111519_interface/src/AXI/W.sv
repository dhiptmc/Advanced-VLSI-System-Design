module W (
    input logic          clk,
    input logic          rstn,

    W_interface.M1       M1,
    W_interface.S1       S1,
    W_interface.S2       S2,
    W_interface.SDEFAULT SDEFAULT,

    input logic          AWVALID_S1,
    input logic          AWVALID_S2,
    input logic          AWVALID_SDEFAULT
);

logic WVALID_S1_reg, WVALID_S2_reg, WVALID_SDEFAULT_reg;

logic [2:0] slave;

logic [`AXI_DATA_BITS-1:0] WDATA_M;
logic [`AXI_STRB_BITS-1:0] WSTRB_M;
logic WLAST_M;
logic WVALID_M;

logic READY;

// signals from master 1
assign WDATA_M   = M1.WDATA;
assign WSTRB_M   = M1.WSTRB;
assign WLAST_M   = M1.WLAST;
assign WVALID_M  = M1.WVALID;
// signals to master 1
assign M1.WREADY = READY & WVALID_M;

// signals to slaves
// slave 1
assign S1.WDATA = WDATA_M;
assign S1.WSTRB = (S1.WVALID) ? WSTRB_M : `AXI_STRB_BITS'b0000;
assign S1.WLAST = WLAST_M;
// slave 2
assign S2.WDATA = WDATA_M;
assign S2.WSTRB = (S2.WVALID) ? WSTRB_M : `AXI_STRB_BITS'b0000;
assign S2.WLAST = WLAST_M;
// DEFAULT slave
assign SDEFAULT.WDATA = WDATA_M;
assign SDEFAULT.WSTRB = (SDEFAULT.WVALID) ? WSTRB_M : `AXI_STRB_BITS'b0000;
assign SDEFAULT.WLAST = WLAST_M;

assign slave = {(WVALID_SDEFAULT_reg | AWVALID_SDEFAULT), (WVALID_S2_reg | AWVALID_S2), (WVALID_S1_reg | AWVALID_S1)};

always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        WVALID_S1_reg       <= 1'b0;
        WVALID_S2_reg       <= 1'b0;
        WVALID_SDEFAULT_reg <= 1'b0;
    end
    else
    begin
        WVALID_S1_reg       <= (      AWVALID_S1) ? 1'b1 : ( (WLAST_M) ? 1'b0 : WVALID_S1_reg      );
        WVALID_S2_reg       <= (      AWVALID_S2) ? 1'b1 : ( (WLAST_M) ? 1'b0 : WVALID_S2_reg      );
        WVALID_SDEFAULT_reg <= (AWVALID_SDEFAULT) ? 1'b1 : ( (WLAST_M) ? 1'b0 : WVALID_SDEFAULT_reg);
    end
end

always_comb
begin
    case(slave)
        // slave 1
        3'b001:
        begin
            READY = S1.WREADY;
            {SDEFAULT.WVALID, S2.WVALID, S1.WVALID} = {2'b00, WVALID_M};
        end
        // slave 2
        3'b010:
        begin
            READY = S2.WREADY;
            {SDEFAULT.WVALID, S2.WVALID, S1.WVALID} = {1'b0, WVALID_M , 1'b0};
        end
        // DEFAULT slave
        3'b100:
        begin
            READY = SDEFAULT.WREADY;
            {SDEFAULT.WVALID, S2.WVALID, S1.WVALID} = {WVALID_M, 2'b00};
        end
        default:
        begin
            READY = 1'b0;
            {SDEFAULT.WVALID, S2.WVALID, S1.WVALID} = 3'b000;
        end
    endcase
end

endmodule