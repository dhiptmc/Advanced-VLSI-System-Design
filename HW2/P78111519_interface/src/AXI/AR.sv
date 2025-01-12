module AR (
    input logic           clk,
    input logic           rstn,

    AR_interface.M0       M0,
    AR_interface.M1       M1,
    AR_interface.S1       S1,
    AR_interface.S2       S2,
    AR_interface.SDEFAULT SDEFAULT
);

logic [ `AXI_IDS_BITS -1:0] IDS_M;
logic [`AXI_ADDR_BITS -1:0] ADDR_M;
logic [ `AXI_LEN_BITS -1:0] LEN_M;
logic [`AXI_SIZE_BITS -1:0] SIZE_M;
logic [                1:0] BURST_M;
logic                       VALID_M;

// slave 1 IM
assign S1.ARID_S        = IDS_M;
assign S1.ARADDR        = ADDR_M;
assign S1.ARLEN         = LEN_M;
assign S1.ARSIZE        = SIZE_M;
assign S1.ARBURST       = BURST_M;
// S1.ARVALID is already set in Decoder

// slave 2 DM
assign S2.ARID_S        = IDS_M;
assign S2.ARADDR        = ADDR_M;
assign S2.ARLEN         = LEN_M;
assign S2.ARSIZE        = SIZE_M;
assign S2.ARBURST       = BURST_M;
// S2.ARVALID is already set in Decoder

// DEFAULT slave
assign SDEFAULT.ARID_S  = IDS_M;
assign SDEFAULT.ARADDR  = ADDR_M;
assign SDEFAULT.ARLEN   = LEN_M;
assign SDEFAULT.ARSIZE  = SIZE_M;
assign SDEFAULT.ARBURST = BURST_M;

logic READY_S;

Arbiter AR_Arbiter(
    .clk           (clk),
    .rstn          (rstn),

    // from M0
    .ID_M0         (M0.ARID),
    .ADDR_M0       (M0.ARADDR),
    .LEN_M0        (M0.ARLEN),
    .SIZE_M0       (M0.ARSIZE),
    .BURST_M0      (M0.ARBURST),
    .VALID_M0      (M0.ARVALID),

    .READY_M0      (M0.ARREADY),

    // from M1
    .ID_M1         (M1.ARID),
    .ADDR_M1       (M1.ARADDR),
    .LEN_M1        (M1.ARLEN),
    .SIZE_M1       (M1.ARSIZE),
    .BURST_M1      (M1.ARBURST),
    .VALID_M1      (M1.ARVALID),

    .READY_M1      (M1.ARREADY),

    // to slaves
    .IDS_M         (IDS_M),
    .ADDR_M        (ADDR_M),
    .LEN_M         (LEN_M),
    .SIZE_M        (SIZE_M),
    .BURST_M       (BURST_M),
    .VALID_M       (VALID_M),

    .READY_S       (READY_S)
);

Decoder AR_Decoder(
    .VALID         (VALID_M),
    .ADDR          (ADDR_M),
    .VALID_S1      (S1.ARVALID),
    .VALID_S2      (S2.ARVALID),
    .VALID_SDEFAULT(SDEFAULT.ARVALID),
    .READY_S1      (S1.ARREADY),
    .READY_S2      (S2.ARREADY),
    .READY_SDEFAULT(SDEFAULT.ARREADY),
    .READY_S       (READY_S)
);

endmodule