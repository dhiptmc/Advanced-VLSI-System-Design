`include "../../include/AXI_define.svh"

module AR (
    input  logic                       clk,
    input  logic                       rstn,

    // Master_0 send
    input  logic [  `AXI_ID_BITS -1:0] ARID_M0,
    input  logic [`AXI_ADDR_BITS -1:0] ARADDR_M0,
    input  logic [ `AXI_LEN_BITS -1:0] ARLEN_M0,
    input  logic [`AXI_SIZE_BITS -1:0] ARSIZE_M0,
    input  logic [                1:0] ARBURST_M0,
    input  logic                       ARVALID_M0,
    // Master_0 receive
    output logic                       ARREADY_M0,

    // Master_1 send
    input  logic [  `AXI_ID_BITS -1:0] ARID_M1,
    input  logic [`AXI_ADDR_BITS -1:0] ARADDR_M1,
    input  logic [ `AXI_LEN_BITS -1:0] ARLEN_M1,
    input  logic [`AXI_SIZE_BITS -1:0] ARSIZE_M1,
    input  logic [                1:0] ARBURST_M1,
    input  logic                       ARVALID_M1,
    // Master_1 receive
    output logic                       ARREADY_M1,

    // Slaves 0 receive
    output logic [ `AXI_IDS_BITS -1:0] ARID_S0,
    output logic [`AXI_ADDR_BITS -1:0] ARADDR_S0,
    output logic [ `AXI_LEN_BITS -1:0] ARLEN_S0,
    output logic [`AXI_SIZE_BITS -1:0] ARSIZE_S0,
    output logic [                1:0] ARBURST_S0,
    output logic                       ARVALID_S0,
    // Slaves send
    input  logic                       ARREADY_S0,

    // Slaves 1 receive
    output logic [ `AXI_IDS_BITS -1:0] ARID_S1,
    output logic [`AXI_ADDR_BITS -1:0] ARADDR_S1,
    output logic [ `AXI_LEN_BITS -1:0] ARLEN_S1,
    output logic [`AXI_SIZE_BITS -1:0] ARSIZE_S1,
    output logic [                1:0] ARBURST_S1,
    output logic                       ARVALID_S1,
    // Slaves send
    input  logic                       ARREADY_S1,

    // DEFAULT slave receive
    output logic [ `AXI_IDS_BITS -1:0] ARID_SDEFAULT,
    output logic [`AXI_ADDR_BITS -1:0] ARADDR_SDEFAULT,
    output logic [ `AXI_LEN_BITS -1:0] ARLEN_SDEFAULT,
    output logic [`AXI_SIZE_BITS -1:0] ARSIZE_SDEFAULT,
    output logic [                1:0] ARBURST_SDEFAULT,
    output logic                       ARVALID_SDEFAULT,
    // DEFAULT slave send
    input  logic                       ARREADY_SDEFAULT
);

logic [ `AXI_IDS_BITS -1:0] IDS_M;
logic [`AXI_ADDR_BITS -1:0] ADDR_M;
logic [ `AXI_LEN_BITS -1:0] LEN_M;
logic [`AXI_SIZE_BITS -1:0] SIZE_M;
logic [                1:0] BURST_M;
logic                       VALID_M;

// slave 0 IM
assign ARID_S0          = IDS_M;
assign ARADDR_S0        = ADDR_M;
assign ARLEN_S0         = LEN_M;
assign ARSIZE_S0        = SIZE_M;
assign ARBURST_S0       = BURST_M;
// ARVALID_S0 is already set in Decoder

// slave 1 DM
assign ARID_S1          = IDS_M;
assign ARADDR_S1        = ADDR_M;
assign ARLEN_S1         = LEN_M;
assign ARSIZE_S1        = SIZE_M;
assign ARBURST_S1       = BURST_M;
// ARVALID_S1 is already set in Decoder

// DEFAULT slave
assign ARID_SDEFAULT    = IDS_M;
assign ARADDR_SDEFAULT  = ADDR_M;
assign ARLEN_SDEFAULT   = LEN_M;
assign ARSIZE_SDEFAULT  = SIZE_M;
assign ARBURST_SDEFAULT = BURST_M;

logic READY_S;

Arbiter AR_Arbiter(
    .clk(clk),
    .rstn(rstn),

    // from M0
    .ID_M0(ARID_M0),
    .ADDR_M0(ARADDR_M0),
    .LEN_M0(ARLEN_M0),
    .SIZE_M0(ARSIZE_M0),
    .BURST_M0(ARBURST_M0),
    .VALID_M0(ARVALID_M0),

    .READY_M0(ARREADY_M0),

    // from M1
    .ID_M1(ARID_M1),
    .ADDR_M1(ARADDR_M1),
    .LEN_M1(ARLEN_M1),
    .SIZE_M1(ARSIZE_M1),
    .BURST_M1(ARBURST_M1),
    .VALID_M1(ARVALID_M1),

    .READY_M1(ARREADY_M1),

    // to slaves
    .IDS_M(IDS_M),
    .ADDR_M(ADDR_M),
    .LEN_M(LEN_M),
    .SIZE_M(SIZE_M),
    .BURST_M(BURST_M),
    .VALID_M(VALID_M),

    .READY_S(READY_S)
);

Decoder AR_Decoder(
    .VALID(VALID_M),
    .ADDR(ADDR_M),
    .VALID_S0(ARVALID_S0),
    .VALID_S1(ARVALID_S1),
    .VALID_SDEFAULT(ARVALID_SDEFAULT),
    .READY_S0(ARREADY_S0),
    .READY_S1(ARREADY_S1),
    .READY_SDEFAULT(ARREADY_SDEFAULT),
    .READY_S(READY_S)
);

endmodule