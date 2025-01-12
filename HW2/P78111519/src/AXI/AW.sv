`include "../../include/AXI_define.svh"

module AW (
    input                              clk,
    input                              rstn,

    // Master 1 send, only DM will be write
    input  logic [  `AXI_ID_BITS -1:0] AWID_M1,
    input  logic [`AXI_ADDR_BITS -1:0] AWADDR_M1,
    input  logic [ `AXI_LEN_BITS -1:0] AWLEN_M1,
    input  logic [`AXI_SIZE_BITS -1:0] AWSIZE_M1,
    input  logic [                1:0] AWBURST_M1,
    input  logic                       AWVALID_M1,
    // Master 1 receive
    output logic                       AWREADY_M1,

    // Slave 0 receive
    output logic [ `AXI_IDS_BITS -1:0] AWID_S0,
    output logic [`AXI_ADDR_BITS -1:0] AWADDR_S0,
    output logic [ `AXI_LEN_BITS -1:0] AWLEN_S0,
    output logic [`AXI_SIZE_BITS -1:0] AWSIZE_S0,
    output logic [                1:0] AWBURST_S0,
    output logic                       AWVALID_S0,
    // Slave 0 send
    input  logic                       AWREADY_S0,

    // Slave 1 receive
    output logic [ `AXI_IDS_BITS -1:0] AWID_S1,
    output logic [`AXI_ADDR_BITS -1:0] AWADDR_S1,
    output logic [ `AXI_LEN_BITS -1:0] AWLEN_S1,
    output logic [`AXI_SIZE_BITS -1:0] AWSIZE_S1,
    output logic [                1:0] AWBURST_S1,
    output logic                       AWVALID_S1,
    // Slave 1 send
    input  logic                       AWREADY_S1,

    // DEFAULT slave receive
    output logic [ `AXI_IDS_BITS -1:0] AWID_SDEFAULT,
    output logic [`AXI_ADDR_BITS -1:0] AWADDR_SDEFAULT,
    output logic [ `AXI_LEN_BITS -1:0] AWLEN_SDEFAULT,
    output logic [`AXI_SIZE_BITS -1:0] AWSIZE_SDEFAULT,
    output logic [                1:0] AWBURST_SDEFAULT,
    output logic                       AWVALID_SDEFAULT,
    // DEFAULT slave send
    input  logic                       AWREADY_SDEFAULT
);

logic [ `AXI_IDS_BITS -1:0] IDS_M;
logic [`AXI_ADDR_BITS -1:0] ADDR_M;
logic [ `AXI_LEN_BITS -1:0] LEN_M;
logic [`AXI_SIZE_BITS -1:0] SIZE_M;
logic [                1:0] BURST_M;
logic                       VALID_M;

// slave 0 IM
assign AWID_S0          = IDS_M;
assign AWADDR_S0        = ADDR_M;
assign AWLEN_S0         = LEN_M;
assign AWSIZE_S0        = SIZE_M;
assign AWBURST_S0       = BURST_M;

// slave 1 DM
assign AWID_S1          = IDS_M;
assign AWADDR_S1        = ADDR_M;
assign AWLEN_S1         = LEN_M;
assign AWSIZE_S1        = SIZE_M;
assign AWBURST_S1       = BURST_M;

// DEFAULT slave
assign AWID_SDEFAULT    = IDS_M;
assign AWADDR_SDEFAULT  = ADDR_M;
assign AWLEN_SDEFAULT   = LEN_M;
assign AWSIZE_SDEFAULT  = SIZE_M;
assign AWBURST_SDEFAULT = BURST_M;

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
    .ID_M1(AWID_M1),
    .ADDR_M1(AWADDR_M1),
    .LEN_M1(AWLEN_M1),
    .SIZE_M1(AWSIZE_M1),
    .BURST_M1(AWBURST_M1),
    .VALID_M1(AWVALID_M1),

    .READY_M1(AWREADY_M1),

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
    .VALID_S0(AWVALID_S0),
    .VALID_S1(AWVALID_S1),
    .VALID_SDEFAULT(AWVALID_SDEFAULT),
    .READY_S0(AWREADY_S0),
    .READY_S1(AWREADY_S1),
    .READY_SDEFAULT(AWREADY_SDEFAULT),
    .READY_S(READY_S)
);

endmodule