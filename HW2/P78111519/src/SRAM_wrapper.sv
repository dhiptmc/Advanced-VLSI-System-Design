`include "../include/def.svh"
`include "../include/AXI_define.svh"

module SRAM_wrapper (
	input  logic                      ACLK,
	input  logic                      ARESETn,

	//WRITE ADDRESS
	input  logic [`AXI_IDS_BITS-1:0]  AWID_S,      
	input  logic [`AXI_ADDR_BITS-1:0] AWADDR_S,
	input  logic [`AXI_LEN_BITS-1:0]  AWLEN_S,
	input  logic [`AXI_SIZE_BITS-1:0] AWSIZE_S,
	input  logic [1:0]                AWBURST_S,
	input  logic                      AWVALID_S,
	output logic                      AWREADY_S,
	
	//WRITE DATA
	input  logic [`AXI_DATA_BITS-1:0] WDATA_S,
	input  logic [`AXI_STRB_BITS-1:0] WSTRB_S,
	input  logic                      WLAST_S,
	input  logic                      WVALID_S,
	output logic                      WREADY_S,
	
	//WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0]  BID_S,
	output logic [1:0]                BRESP_S,
	output logic                      BVALID_S,
	input  logic                      BREADY_S,

	//READ ADDRESS
	input  logic [`AXI_IDS_BITS-1:0]  ARID_S,
	input  logic [`AXI_ADDR_BITS-1:0] ARADDR_S,
	input  logic [`AXI_LEN_BITS-1:0]  ARLEN_S,
	input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_S,
	input  logic [1:0]                ARBURST_S,
	input  logic                      ARVALID_S,
	output logic                      ARREADY_S,
	
	//READ DATA
	output logic [`AXI_IDS_BITS-1:0]  RID_S,
	output logic [`AXI_DATA_BITS-1:0] RDATA_S,
	output logic [1:0]                RRESP_S,
	output logic                      RLAST_S,
	output logic                      RVALID_S,
	input  logic                      RREADY_S
);

//SRAM parameter
logic CEB;
logic WEB;
logic [31:0] BWEB;
logic [13:0] A;
logic [31:0] DI;
logic [31:0] DO;

//Handshake process check
logic AR_hs_done;
logic R_hs_done;
logic AW_hs_done;
logic W_hs_done;
logic B_hs_done;

assign AR_hs_done = ARVALID_S & ARREADY_S; 
assign R_hs_done  = RVALID_S  & RREADY_S ;
assign AW_hs_done = AWVALID_S & AWREADY_S;
assign W_hs_done  = WVALID_S  & WREADY_S ;
assign B_hs_done  = BVALID_S  & BREADY_S ;

//Last check
logic  R_last;
logic  W_last;
assign R_last = RLAST_S & R_hs_done;
assign W_last = WLAST_S & W_hs_done;

//FSM
logic [1:0] cur_state, nxt_state;
localparam [1:0] ADDR  = 2'b00,
				 READ  = 2'b01,
				 WRITE = 2'b10,
				 WRESP = 2'b11;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
		cur_state <= ADDR;
	else
		cur_state <= nxt_state;
end

always_comb
begin
	case(cur_state)
	ADDR:
	begin
		if(AR_hs_done)
			nxt_state = READ;
		else if(AW_hs_done)
			nxt_state = WRITE;
		else
			nxt_state = ADDR;
	end

	READ:
		nxt_state = (R_last)    ? ( (AW_hs_done) ? WRITE : ADDR ) : READ; //RW Problem
	
	WRITE:
		nxt_state = (W_last)    ? WRESP : WRITE;

	WRESP:
		nxt_state = (B_hs_done) ? ADDR  : WRESP;	
	endcase
end

//length count
logic [`AXI_LEN_BITS-1:0] len_cnt;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if (!ARESETn)
	begin
		len_cnt <= `AXI_LEN_BITS'd0;
	end 
	else
	begin
		if(R_last)
			len_cnt <= `AXI_LEN_BITS'd0;            
		else if (R_hs_done)
			len_cnt <= len_cnt + `AXI_LEN_BITS'd1;            
		else
			len_cnt <= len_cnt;
	end
end

//W-channel
logic [`AXI_IDS_BITS-1:0] AWID_reg;
logic [				13:0] AWADDR_reg;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		AWID_reg   <= `AXI_IDS_BITS'd0;
		AWADDR_reg <= 14'd0;
	end
	else
	begin
		AWID_reg   <= (AW_hs_done)  ? AWID_S 		 : AWID_reg;
		AWADDR_reg <= (AW_hs_done)  ? AWADDR_S[15:2] : AWADDR_reg;
	end
end

always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
		AWREADY_S <= 1'b0;
	else
	begin
		case(cur_state)
		ADDR:
			AWREADY_S <= (AW_hs_done) ? 1'b0 : 1'b1;
		default:
			AWREADY_S <= 1'b0;
		endcase
	end	
end

assign WREADY_S = (cur_state == WRITE) ? 1'b1 : 1'b0;

//B-channel
assign  BID_S     = AWID_reg; 
assign  BRESP_S   = `AXI_RESP_OKAY;
assign  BVALID_S  = (cur_state == WRESP) ? 1'b1 : 1'b0;

//R-channel
logic [`AXI_IDS_BITS-1:0] ARID_reg;
logic [				13:0] ARADDR_reg;
logic [`AXI_LEN_BITS-1:0] ARLEN_reg;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		ARID_reg   <= `AXI_IDS_BITS'd0;
		ARADDR_reg <= 14'd0;
		ARLEN_reg  <= `AXI_LEN_BITS'd0;
	end
	else
	begin
		ARID_reg   <= (AR_hs_done) ? ARID_S   		: ARID_reg;
		ARADDR_reg <= (AR_hs_done) ? ARADDR_S[15:2] : ARADDR_reg;
		ARLEN_reg  <= (AR_hs_done) ? ARLEN_S  		: ARLEN_reg;
	end
end

always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		ARREADY_S <= 1'b0;
	end
	else
	begin
		case(cur_state)
		ADDR:
			ARREADY_S <= (AR_hs_done) ? 1'b0 : 1'b1;
		default:
			ARREADY_S <= 1'b0;
		endcase
	end
end

assign RID_S    = ARID_reg;
assign RDATA_S  = DO;
assign RRESP_S  = `AXI_RESP_OKAY;
assign RLAST_S  = (len_cnt == ARLEN_reg) ? 1'b1 : 1'b0;
assign RVALID_S = (cur_state == READ)    ? 1'b1 : 1'b0;


always_comb //Chip enable (active low)
begin
	CEB = 1'b1;
	if( (cur_state == ADDR) || (cur_state == READ) || (cur_state == WRITE) )
		CEB = 1'b0;
	else
		CEB = 1'b1;
end

always_comb //read:active high , write:active low
begin
	case(cur_state)
	WRITE:   WEB = 1'b0;
	default: WEB = 1'b1;
	endcase
end

assign BWEB = ~{ {8{WSTRB_S[3]}} , {8{WSTRB_S[2]}} , {8{WSTRB_S[1]}} , {8{WSTRB_S[0]}} }; //Bit write enable (active low)

always_comb //Address
begin
	case(cur_state)
	ADDR:    A = (AW_hs_done) ? AWADDR_S[15:2] : ARADDR_S[15:2]; //don't really care
	READ:    A = ARADDR_reg;
	WRITE:   A = AWADDR_reg;
	default: A = 14'd0;
	endcase
end

assign DI = WDATA_S;

TS1N16ADFPCLLLVTA512X45M4SWSHOD i_SRAM (
  	.SLP(1'b0),
  	.DSLP(1'b0),
  	.SD(1'b0),
  	.PUDELAY(),
  	.CLK(ACLK),
	.CEB(CEB),
	.WEB(WEB),
  	.A(A),
	.D(DI),
  	.BWEB(BWEB),
  	.RTSEL(2'b01),
  	.WTSEL(2'b01),
  	.Q(DO)
);

endmodule