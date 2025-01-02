`include "../../include/AXI_define.svh"

module Default_Slave (
    input  logic                       clk,
    input  logic                       rstn,

    //AR
	//READ ADDRESS DEFAULT
	input  logic [ `AXI_IDS_BITS -1:0] ARID_SDEFAULT,
	input  logic [`AXI_ADDR_BITS -1:0] ARADDR_SDEFAULT,
	input  logic [ `AXI_LEN_BITS -1:0] ARLEN_SDEFAULT,
	input  logic [`AXI_SIZE_BITS -1:0] ARSIZE_SDEFAULT,
	input  logic [                1:0] ARBURST_SDEFAULT,
	input  logic                       ARVALID_SDEFAULT,
	output logic                       ARREADY_SDEFAULT,

    //R
    //READ DATA DEFAULT
	output logic [ `AXI_IDS_BITS -1:0] RID_SDEFAULT,
	output logic [`AXI_DATA_BITS -1:0] RDATA_SDEFAULT,
	output logic [                1:0] RRESP_SDEFAULT,
	output logic                       RLAST_SDEFAULT,
	output logic                       RVALID_SDEFAULT,
	input  logic                       RREADY_SDEFAULT,

    //AW
	//WRITE ADDRESS DEFAULT
	input  logic [ `AXI_IDS_BITS -1:0] AWID_SDEFAULT,
	input  logic [`AXI_ADDR_BITS -1:0] AWADDR_SDEFAULT,
	input  logic [ `AXI_LEN_BITS -1:0] AWLEN_SDEFAULT,
	input  logic [`AXI_SIZE_BITS -1:0] AWSIZE_SDEFAULT,
	input  logic [                1:0] AWBURST_SDEFAULT,
	input  logic                       AWVALID_SDEFAULT,
	output logic                       AWREADY_SDEFAULT,

    //W
    //WRITE DATA DEFAULT
	input  logic [`AXI_DATA_BITS -1:0] WDATA_SDEFAULT,
	input  logic [`AXI_STRB_BITS -1:0] WSTRB_SDEFAULT,
	input  logic                       WLAST_SDEFAULT,
	input  logic                       WVALID_SDEFAULT,
	output logic                       WREADY_SDEFAULT,

    //B
	//WRITE RESPONSE DEFAULT
	output logic [ `AXI_IDS_BITS -1:0] BID_SDEFAULT,
	output logic [                1:0] BRESP_SDEFAULT,
	output logic                       BVALID_SDEFAULT,
	input  logic                       BREADY_SDEFAULT
);

//Handshake process check
logic AR_hs_done;
logic R_hs_done;
logic AW_hs_done;
logic W_hs_done;
logic B_hs_done;

assign AR_hs_done = ARVALID_SDEFAULT & ARREADY_SDEFAULT; 
assign R_hs_done  = RVALID_SDEFAULT  & RREADY_SDEFAULT ;
assign AW_hs_done = AWVALID_SDEFAULT & AWREADY_SDEFAULT;
assign W_hs_done  = WVALID_SDEFAULT  & WREADY_SDEFAULT ;
assign B_hs_done  = BVALID_SDEFAULT  & BREADY_SDEFAULT ;

logic [1:0] slave_state, nxt_state;
localparam [1:0] ADDR  = 2'b00,
                 READ  = 2'b01,
                 WRITE = 2'b10,
                 RESP  = 2'b11;

always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
        slave_state <= ADDR;
    else
        slave_state <= nxt_state;
end

always_comb
begin
    case(slave_state)
    ADDR:
    begin
        if(AR_hs_done)
            nxt_state = READ;
        else if (AW_hs_done)
            nxt_state = WRITE;
        else
            nxt_state = ADDR;
    end

    READ:
    begin
        if(R_hs_done)
            nxt_state = ADDR;
        else
            nxt_state = READ;
    end

    WRITE:
    begin
        if(W_hs_done && WLAST_SDEFAULT)
            nxt_state = RESP;
        else
            nxt_state = WRITE;
    end

    RESP:
    begin
        if(B_hs_done)
            nxt_state = ADDR;
        else
            nxt_state = RESP;        
    end
    endcase
end

//AR
assign ARREADY_SDEFAULT = (ARVALID_SDEFAULT && (slave_state == ADDR)) ? 1'b1 : 1'b0;

//R
always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        RID_SDEFAULT <= `AXI_IDS_BITS'd0;
    end
    else
    begin
        RID_SDEFAULT <= (AR_hs_done) ? ARID_SDEFAULT: RID_SDEFAULT;
    end
end

assign RDATA_SDEFAULT   = `AXI_DATA_BITS'd0;
assign RRESP_SDEFAULT   = `AXI_RESP_DECERR;
assign RLAST_SDEFAULT   = 1'b1;
assign RVALID_SDEFAULT  = (slave_state == READ) ? 1'b1 : 1'b0; //VALID signal must not be dependent on the READY signal in the transaction!!

//AW
assign AWREADY_SDEFAULT = (AWVALID_SDEFAULT && (slave_state == ADDR)) ? 1'b1 : 1'b0;

//W
assign WREADY_SDEFAULT  = (WVALID_SDEFAULT  && (slave_state == WRITE));

//B
always_ff @(posedge clk or negedge rstn)
begin
    if(!rstn)
        BID_SDEFAULT <= `AXI_IDS_BITS'd0;
    else
        BID_SDEFAULT <= (AW_hs_done) ? AWID_SDEFAULT : BID_SDEFAULT;
end

assign BRESP_SDEFAULT   = `AXI_RESP_DECERR;
assign BVALID_SDEFAULT  = (slave_state == RESP) ? 1'b1 : 1'b0; //VALID signal must not be dependent on the READY signal in the transaction!!

endmodule