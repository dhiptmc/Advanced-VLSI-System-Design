module IM_Master (
    input  logic                       clk,
    input  logic                       rstn,

    //from CPU
    input  logic                       read,
    input  logic [`AXI_ADDR_BITS -1:0] addr_in,
    //to CPU
    output logic [`AXI_DATA_BITS -1:0] data_out,
    output logic                       stall,
	
	//READ ADDRESS
	output logic [  `AXI_ID_BITS -1:0] ARID_M,
	output logic [`AXI_ADDR_BITS -1:0] ARADDR_M,
	output logic [ `AXI_LEN_BITS -1:0] ARLEN_M,
	output logic [`AXI_SIZE_BITS -1:0] ARSIZE_M,
	output logic [                1:0] ARBURST_M,
	output logic                       ARVALID_M,
	input  logic                       ARREADY_M,
	
	//READ DATA
	input  logic [  `AXI_ID_BITS- 1:0] RID_M,
	input  logic [`AXI_DATA_BITS -1:0] RDATA_M,
	input  logic [                1:0] RRESP_M,
	input  logic                       RLAST_M,
	input  logic                       RVALID_M,
	output logic                       RREADY_M
);

logic [1:0] cur_state, nxt_state;
localparam [1:0] INIT      = 2'b00,
                 READADDR  = 2'b01,
                 READDATA  = 2'b10;

//Handshake process check
logic AR_hs_done;
logic R_hs_done;

assign AR_hs_done = ARVALID_M & ARREADY_M; 
assign R_hs_done  = RVALID_M  & RREADY_M ;

//Last check
logic R_last;
assign R_last = RLAST_M & R_hs_done;

always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
        cur_state <= INIT;
    else
        cur_state <= nxt_state;
end

always_comb
begin
    case(cur_state)
    INIT:
    begin
        if(ARVALID_M)
            nxt_state = (AR_hs_done) ? READDATA  : READADDR;
        else
            nxt_state = INIT;
    end

    READADDR:
        nxt_state = (AR_hs_done) ? READDATA  : READADDR;

    READDATA:
        nxt_state = (R_last)     ? INIT      : READDATA;

    default:
        nxt_state = INIT;
    endcase
end

logic r;
always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
        r <= 1'b0;
    else
        r <= 1'b1;
end

//AR
assign ARID_M    = `AXI_ID_BITS'd0;
assign ARADDR_M  = addr_in;
assign ARLEN_M   = `AXI_LEN_BITS'd0;
assign ARSIZE_M  = `AXI_SIZE_BITS'b10;
assign ARBURST_M = `AXI_BURST_INC;
assign ARVALID_M = (cur_state == INIT) ? ( read & r ) : (cur_state == READADDR); 

//R
assign RREADY_M = ( RVALID_M && (cur_state == READDATA) );

logic [`AXI_DATA_BITS -1:0] RDATA_M_reg;
always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
        RDATA_M_reg <= `AXI_DATA_BITS'd0;
    else
        RDATA_M_reg <= (R_last) ? RDATA_M : RDATA_M_reg;
end

assign data_out = (R_last) ? RDATA_M : RDATA_M_reg;

assign stall = (read & (~R_last));

endmodule