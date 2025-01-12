module AW (
    input logic           clk,
    input logic           rstn,

    AW_interface.M1       M1,
    AW_interface.S1       S1,
    AW_interface.S2       S2,
    AW_interface.SDEFAULT SDEFAULT
);

logic [ `AXI_IDS_BITS -1:0] IDS_M;
logic [`AXI_ADDR_BITS -1:0] ADDR_M;
logic [ `AXI_LEN_BITS -1:0] LEN_M;
logic [`AXI_SIZE_BITS -1:0] SIZE_M;
logic [                1:0] BURST_M;
logic                       VALID_M;

// slave 1 IM
assign S1.AWID_S        = IDS_M;
assign S1.AWADDR        = ADDR_M;
assign S1.AWLEN         = LEN_M;
assign S1.AWSIZE        = SIZE_M;
assign S1.AWBURST       = BURST_M;

// slave 2 DM
assign S2.AWID_S        = IDS_M;
assign S2.AWADDR        = ADDR_M;
assign S2.AWLEN         = LEN_M;
assign S2.AWSIZE        = SIZE_M;
assign S2.AWBURST       = BURST_M;

// DEFAULT slave
assign SDEFAULT.AWID_S  = IDS_M;
assign SDEFAULT.AWADDR  = ADDR_M;
assign SDEFAULT.AWLEN   = LEN_M;
assign SDEFAULT.AWSIZE  = SIZE_M;
assign SDEFAULT.AWBURST = BURST_M;

logic READY_S;

logic AWREADY_M0;

Arbiter AW_Arbiter(
    .clk(clk),
    .rstn(rstn),

    // from M0
    .ID_M0(`AXI_ID_BITS'd0),
    .ADDR_M0(`AXI_ADDR_BITS'd0),
    .LEN_M0(`AXI_LEN_BITS'd0),
    .SIZE_M0(`AXI_SIZE_BITS'd0),
    .BURST_M0(2'b00),
    .VALID_M0(1'b0),

    .READY_M0(AWREADY_M0), // Because AWREADY_M0 doesn't exist

    // from M1
    .ID_M1(M1.AWID),
    .ADDR_M1(M1.AWADDR),
    .LEN_M1(M1.AWLEN),
    .SIZE_M1(M1.AWSIZE),
    .BURST_M1(M1.AWBURST),
    .VALID_M1(M1.AWVALID),

    .READY_M1(M1.AWREADY),

    // to slaves
    .IDS_M(IDS_M),
    .ADDR_M(ADDR_M),
    .LEN_M(LEN_M),
    .SIZE_M(SIZE_M),
    .BURST_M(BURST_M),
    .VALID_M(VALID_M),

    .READY_S(READY_S)
);

Decoder AW_Decoder(
    .VALID(VALID_M),
    .ADDR(ADDR_M),
    .VALID_S1(S1.AWVALID),
    .VALID_S2(S2.AWVALID),
    .VALID_SDEFAULT(SDEFAULT.AWVALID),
    .READY_S1(S1.AWREADY),
    .READY_S2(S2.AWREADY),
    .READY_SDEFAULT(SDEFAULT.AWREADY),
    .READY_S(READY_S)
);

endmodule