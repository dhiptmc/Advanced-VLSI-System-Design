`include "DMA_Master.sv"
`include "DMA_Slave.sv"

module DMA_wrapper (
    input  logic       ACLK,
    input  logic       ARESETn,

    AR_interface.DMA_M M2_AR,
    R_interface.DMA_M  M2_R,
    AW_interface.DMA_M M2_AW,
    W_interface.DMA_M  M2_W,
    B_interface.DMA_M  M2_B,

    AR_interface.DMA_S S3_AR,
    R_interface.DMA_S  S3_R,
    AW_interface.DMA_S S3_AW,
    W_interface.DMA_S  S3_W,
    B_interface.DMA_S  S3_B,

    output logic       DMA_interrupt
);

//DMA_Slave pass to DMA_Master
logic        DMAEN;
logic [31:0] DMASRC;
logic [31:0] DMADST;
logic [31:0] DMALEN;

/*          DMA Master          */
DMA_Master i_DMA_Master(
    .ACLK(ACLK),
    .ARESETn(ARESETn),

    .DMAEN(DMAEN),
    .DMASRC(DMASRC),
    .DMADST(DMADST),
    .DMALEN(DMALEN),
    .DMA_interrupt(DMA_interrupt),

    .M2_AR(M2_AR),
    .M2_R(M2_R),
    .M2_AW(M2_AW),
    .M2_W(M2_W),
    .M2_B(M2_B)
);

/*          DMA Slave           */
DMA_Slave i_DMA_Slave(
    .ACLK(ACLK),
    .ARESETn(ARESETn),

    .DMAEN(DMAEN),
    .DMASRC(DMASRC),
    .DMADST(DMADST),
    .DMALEN(DMALEN),

    .S3_AR(S3_AR),
    .S3_R(S3_R),
    .S3_AW(S3_AW),
    .S3_W(S3_W),
    .S3_B(S3_B)
);

endmodule