module AR (
    input logic           clk,
    input logic           rstn,

    AR_interface.M0       M0,
    AR_interface.M1       M1,
    AR_interface.M2       M2,
    AR_interface.S0       S0,
    AR_interface.S1       S1,
    AR_interface.S2       S2,
    AR_interface.S3       S3,
    AR_interface.S4       S4,
    AR_interface.S5       S5,
    AR_interface.SDEFAULT SDEFAULT
);

logic [ `AXI_IDS_BITS -1:0] IDS_M;
logic [`AXI_ADDR_BITS -1:0] ADDR_M;
logic [ `AXI_LEN_BITS -1:0] LEN_M;
logic [`AXI_SIZE_BITS -1:0] SIZE_M;
logic [                1:0] BURST_M;
logic                       VALID_M;


// slave 0 ROM
assign S0.ARID_S        = IDS_M;
assign S0.ARADDR        = ADDR_M;
assign S0.ARLEN         = LEN_M;
assign S0.ARSIZE        = SIZE_M;
assign S0.ARBURST       = BURST_M;

// slave 1 IM
assign S1.ARID_S        = IDS_M;
assign S1.ARADDR        = ADDR_M;
assign S1.ARLEN         = LEN_M;
assign S1.ARSIZE        = SIZE_M;
assign S1.ARBURST       = BURST_M;

// slave 2 DM
assign S2.ARID_S        = IDS_M;
assign S2.ARADDR        = ADDR_M;
assign S2.ARLEN         = LEN_M;
assign S2.ARSIZE        = SIZE_M;
assign S2.ARBURST       = BURST_M;

// slave 3 DMA
assign S3.ARID_S        = IDS_M;
assign S3.ARADDR        = ADDR_M;
assign S3.ARLEN         = LEN_M;
assign S3.ARSIZE        = SIZE_M;
assign S3.ARBURST       = BURST_M;

// slave 4 WDT
assign S4.ARID_S        = IDS_M;
assign S4.ARADDR        = ADDR_M;
assign S4.ARLEN         = LEN_M;
assign S4.ARSIZE        = SIZE_M;
assign S4.ARBURST       = BURST_M;

// slave 5 DRAM
assign S5.ARID_S        = IDS_M;
assign S5.ARADDR        = ADDR_M;
assign S5.ARLEN         = LEN_M;
assign S5.ARSIZE        = SIZE_M;
assign S5.ARBURST       = BURST_M;

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

    // from DMA
    .ID_M2         (M2.ARID),
    .ADDR_M2       (M2.ARADDR),
    .LEN_M2        (M2.ARLEN),
    .SIZE_M2       (M2.ARSIZE),
    .BURST_M2      (M2.ARBURST),
    .VALID_M2      (M2.ARVALID),

    .READY_M2      (M2.ARREADY),

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

    .VALID_S0      (S0.ARVALID),
    .VALID_S1      (S1.ARVALID),
    .VALID_S2      (S2.ARVALID),
    .VALID_S3      (S3.ARVALID),
    .VALID_S4      (S4.ARVALID),
    .VALID_S5      (S5.ARVALID),
    .VALID_SDEFAULT(SDEFAULT.ARVALID),

    .READY_S0      (S0.ARREADY),
    .READY_S1      (S1.ARREADY),
    .READY_S2      (S2.ARREADY),
    .READY_S3      (S3.ARREADY),
    .READY_S4      (S4.ARREADY),
    .READY_S5      (S5.ARREADY),
    .READY_SDEFAULT(SDEFAULT.ARREADY),

    .READY_S       (READY_S)
);

endmodule