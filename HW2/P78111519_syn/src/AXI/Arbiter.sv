`include "../../include/AXI_define.svh"

module Arbiter (
    input  logic                       clk,
    input  logic                       rstn,

    // Master 0
    input  logic [  `AXI_ID_BITS -1:0] ID_M0,
    input  logic [`AXI_ADDR_BITS -1:0] ADDR_M0,
    input  logic [ `AXI_LEN_BITS -1:0] LEN_M0,
    input  logic [`AXI_SIZE_BITS -1:0] SIZE_M0,
    input  logic [                1:0] BURST_M0,
    input  logic                       VALID_M0,

    output logic                       READY_M0,

    // Master 1
    input  logic [  `AXI_ID_BITS -1:0] ID_M1,
    input  logic [`AXI_ADDR_BITS -1:0] ADDR_M1,
    input  logic [ `AXI_LEN_BITS -1:0] LEN_M1,
    input  logic [`AXI_SIZE_BITS -1:0] SIZE_M1,
    input  logic [                1:0] BURST_M1,
    input  logic                       VALID_M1,

    output logic                       READY_M1,

    // Slaves
    output logic [ `AXI_IDS_BITS -1:0] IDS_M,
    output logic [`AXI_ADDR_BITS -1:0] ADDR_M,
    output logic [ `AXI_LEN_BITS -1:0] LEN_M,
    output logic [`AXI_SIZE_BITS -1:0] SIZE_M,
    output logic [                1:0] BURST_M,
    output logic                       VALID_M,

    input READY_S
);

logic LockM0;
logic LockM1;
logic [1:0] master;

always_ff@(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        LockM0 <= 1'b0;
        LockM1 <= 1'b0;
    end
    else
    begin
        LockM0 <= (LockM0 && READY_S) ? 1'b0 : ( ( VALID_M0 && ~READY_S && ~LockM1 ) ? 1'b1 : LockM0 ); //when master undone, lock it
        LockM1 <= (LockM1 && READY_S) ? 1'b0 : ( ( VALID_M1 && ~READY_S && ~LockM0 ) ? 1'b1 : LockM1 );
    end
end

always_comb
begin
    if((VALID_M1 && (~LockM0)) || LockM1)
        master = 2'b10;
    else if (VALID_M0 || LockM0)
        master = 2'b01;
    else
        master = 2'b00;
end

always_comb
begin
    case (master)
        2'b01: //master 0
        begin
            IDS_M   = {4'b0001, ID_M0};
            ADDR_M  = ADDR_M0;
            LEN_M   = LEN_M0;
            SIZE_M  = SIZE_M0;
            BURST_M = BURST_M0;
            VALID_M = VALID_M0;

            READY_M0 = VALID_M0 & READY_S;
            READY_M1 = 1'b0;
        end
        
        2'b10:
        begin // master 1
            IDS_M   = {4'b0010, ID_M1};
            ADDR_M  = ADDR_M1;
            LEN_M   = LEN_M1;
            SIZE_M  = SIZE_M1;
            BURST_M = BURST_M1;
            VALID_M = VALID_M1;

            READY_M0 = 1'b0;
            READY_M1 = VALID_M1 & READY_S;
        end
        
        default : begin
            IDS_M   = {4'd0, `AXI_ID_BITS'b0};
            ADDR_M  = `AXI_ADDR_BITS'b0;
            LEN_M   = `AXI_LEN_BITS'b0;
            SIZE_M  = `AXI_SIZE_BITS'b0;
            BURST_M = 2'b0;
            VALID_M = 1'b0;

            READY_M0 = 1'b0;
            READY_M1 = 1'b0;
        end
    endcase
end

endmodule