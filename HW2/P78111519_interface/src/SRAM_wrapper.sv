module SRAM_wrapper (
	input logic 	  ACLK,
	input logic 	  ARESETn,

	AR_interface.SRAM S_AR,
	R_interface.SRAM  S_R,
	AW_interface.SRAM S_AW,
	W_interface.SRAM  S_W,
	B_interface.SRAM  S_B
);

//SRAM parameter
logic 		 CEB;
logic 		 WEB;
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

assign AR_hs_done = S_AR.ARVALID & S_AR.ARREADY; 
assign R_hs_done  = S_R.RVALID   & S_R.RREADY;
assign AW_hs_done = S_AW.AWVALID & S_AW.AWREADY;
assign W_hs_done  = S_W.WVALID   & S_W.WREADY;
assign B_hs_done  = S_B.BVALID   & S_B.BREADY;

//Last check
logic  R_last;
logic  W_last;
assign R_last = S_R.RLAST & R_hs_done;
assign W_last = S_W.WLAST & W_hs_done;

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
		AWID_reg   <= (AW_hs_done)  ? S_AW.AWID_S 		: AWID_reg;
		AWADDR_reg <= (AW_hs_done)  ? S_AW.AWADDR[15:2] : AWADDR_reg;
	end
end

always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
		S_AW.AWREADY <= 1'b0;
	else
	begin
		case(cur_state)
		ADDR:
			S_AW.AWREADY <= (AW_hs_done) ? 1'b0 : 1'b1;
		default:
			S_AW.AWREADY <= 1'b0;
		endcase
	end	
end

assign S_W.WREADY = (cur_state == WRITE) ? 1'b1 : 1'b0;

//B-channel
assign  S_B.BID_S   = AWID_reg; 
assign  S_B.BRESP   = `AXI_RESP_OKAY;
assign  S_B.BVALID  = (cur_state == WRESP) ? 1'b1 : 1'b0;

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
		ARID_reg   <= (AR_hs_done) ? S_AR.ARID_S 	   : ARID_reg;
		ARADDR_reg <= (AR_hs_done) ? S_AR.ARADDR[15:2] : ARADDR_reg;
		ARLEN_reg  <= (AR_hs_done) ? S_AR.ARLEN  	   : ARLEN_reg;
	end
end

always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		S_AR.ARREADY <= 1'b0;
	end
	else
	begin
		case(cur_state)
		ADDR:
			S_AR.ARREADY <= (AR_hs_done) ? 1'b0 : 1'b1;
		default:
			S_AR.ARREADY <= 1'b0;
		endcase
	end
end

assign S_R.RID_S  = ARID_reg;
assign S_R.RDATA  = DO;
assign S_R.RRESP  = `AXI_RESP_OKAY;
assign S_R.RLAST  = (len_cnt == ARLEN_reg) ? 1'b1 : 1'b0;
assign S_R.RVALID = (cur_state == READ)    ? 1'b1 : 1'b0;


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

assign BWEB = ~{ {8{S_W.WSTRB[3]}} , {8{S_W.WSTRB[2]}} , {8{S_W.WSTRB[1]}} , {8{S_W.WSTRB[0]}} }; //Bit write enable (active low)

always_comb //Address
begin
	case(cur_state)
	ADDR:    A = (AW_hs_done) ? S_AW.AWADDR[15:2] : S_AR.ARADDR[15:2]; //don't really care
	READ:    A = ARADDR_reg;
	WRITE:   A = AWADDR_reg;
	default: A = 14'd0;
	endcase
end

assign DI = S_W.WDATA;

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