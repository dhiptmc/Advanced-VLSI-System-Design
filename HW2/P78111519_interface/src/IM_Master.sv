module IM_Master (
    input  logic                       clk,
    input  logic                       rstn,

    //from CPU
    input  logic                       read,
    // input  logic                       write,
    // input  logic [           `BWEBBus] DM_BWEB,
    // input  logic [`AXI_DATA_BITS -1:0] data_in,
    input  logic [`AXI_ADDR_BITS -1:0] addr_in,
    //to CPU
    output logic [`AXI_DATA_BITS -1:0] data_out,
    output logic                       stall,

	//SLAVE INTERFACE FOR MASTERS
	//WRITE ADDRESS
	// output logic [  `AXI_ID_BITS -1:0] AWID_M,		//Bits of master is 4 and for slave is 8, see A5-80 in spec
	// output logic [`AXI_ADDR_BITS -1:0] AWADDR_M,
	// output logic [ `AXI_LEN_BITS -1:0] AWLEN_M,		//Burst length.
	// output logic [`AXI_SIZE_BITS -1:0] AWSIZE_M,	//Burst size.
	// output logic [                1:0] AWBURST_M,	//Burst type. Only need to implement INCR type.
	// output logic                       AWVALID_M,
	// input  logic                       AWREADY_M,
	
	// //WRITE DATA
	// output logic [`AXI_DATA_BITS -1:0] WDATA_M,
	// output logic [`AXI_STRB_BITS -1:0] WSTRB_M,		//Write strobes. 4 bits because 32/8 = 4
	// output logic                       WLAST_M,		//Write last. This signal indicates the last transfer in a write burst.
	// output logic                       WVALID_M,
	// input  logic                       WREADY_M,
	
	// //WRITE RESPONSE
	// input  logic [  `AXI_ID_BITS -1:0] BID_M,		//Bits of master is 4 and for slave is 8, see A5-80 in spec
	// input  logic [                1:0] BRESP_M,		//Write response. This signal indicates the status of the write transaction.
	// input  logic                       BVALID_M,
	// output logic                       BREADY_M,
	
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
                //  WRITEADDR = 3'b011,
                //  WRITEDATA = 3'b100,
                //  WRITERESP = 3'b101;

//Handshake process check
logic AR_hs_done;
logic R_hs_done;
// logic AW_hs_done;
// logic W_hs_done;
// logic B_hs_done;

assign AR_hs_done = ARVALID_M & ARREADY_M; 
assign R_hs_done  = RVALID_M  & RREADY_M ;
// assign AW_hs_done = AWVALID_M & AWREADY_M;
// assign W_hs_done  = WVALID_M  & WREADY_M ;
// assign B_hs_done  = BVALID_M  & BREADY_M ;

//Last check
logic R_last;
// logic W_last;
assign R_last = RLAST_M & R_hs_done;
// assign W_last = WLAST_M & W_hs_done;

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

    // WRITEADDR:
    //     nxt_state = (AW_hs_done) ? WRITEDATA : WRITEADDR;

    // WRITEDATA:
    //     nxt_state = (W_last)     ? WRITERESP : WRITEDATA;

    // WRITERESP:
    //     nxt_state = (B_hs_done)  ? INIT      : WRITERESP;

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
assign ARVALID_M = (cur_state == INIT) ? ( read & r ) : ( (cur_state == READADDR) ? 1'b1 : 1'b0 ); 

//R
assign RREADY_M = ( RVALID_M && (cur_state == READDATA) ) ? 1'b1 : 1'b0;

logic [`AXI_DATA_BITS -1:0] RDATA_M_reg;
always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
        RDATA_M_reg <= `AXI_DATA_BITS'd0;
    else
        RDATA_M_reg <= (R_last) ? RDATA_M : RDATA_M_reg;
end

assign data_out = (R_last) ? RDATA_M : RDATA_M_reg;

//AW
// assign AWID_M    = `AXI_ID_BITS'd0;
// assign AWADDR_M  = addr_in; //don't care
// assign AWLEN_M   = `AXI_LEN_BITS'd0;
// assign AWSIZE_M  = `AXI_SIZE_BITS'b10;
// assign AWBURST_M = `AXI_BURST_INC;
// assign AWVALID_M = (cur_state == INIT) ? ( write & w ) : ( (cur_state == WRITEADDR) ? 1'b1 : 1'b0 ); 

//W
//length count
// logic [`AXI_LEN_BITS-1:0] len_cnt;
// always_ff @ (posedge clk)
// begin
// 	if (~rstn)
// 	begin
// 		len_cnt <= `AXI_LEN_BITS'd0;
// 	end 
// 	else
// 	begin
// 		if(W_last)
// 			len_cnt <= `AXI_LEN_BITS'd0;            
// 		else if (W_hs_done)
// 			len_cnt <= len_cnt + `AXI_LEN_BITS'd1;            
// 		else
// 			len_cnt <= len_cnt;
// 	end
// end


// assign WDATA_M  = data_in;
// assign WSTRB_M  = `AXI_STRB_BITS'b0000;
// assign WLAST_M  = ( (cur_state == WRITEDATA) && (len_cnt == AWLEN_M) ) ? 1'b1 : 1'b0;
// assign WVALID_M = (cur_state == WRITEDATA) ? 1'b1 : 1'b0;

//B
// assign BREADY_M = ( BVALID_M && (cur_state == WRITERESP) ) ? 1'b1 : 1'b0;

assign stall = (read & (~R_last));

endmodule