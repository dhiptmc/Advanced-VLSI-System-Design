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
// logic 		 CEB;
// logic 		 WEB;
// logic [31:0] BWEB;
// logic [13:0] A;
// logic [31:0] DI;
// logic [31:0] DO;

logic        CK;  //System clock
logic        CS;  //Chip select   (active high)
logic        OE;  //Output enable (active high)
logic [ 3:0] WEB; //Write enable  (active low)
logic [13:0] A;   //Address
logic [31:0] DI;  //Data input
logic [31:0] DO;  //Data output

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

logic [`AXI_DATA_BITS-1:0] RDATA_reg;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
		RDATA_reg <= `AXI_DATA_BITS'd0;
	else
		RDATA_reg <= (R_hs_done) ? DO : RDATA_reg;
end

//length count
logic [`AXI_LEN_BITS-1:0] len_cnt;

//W-channel
logic [`AXI_IDS_BITS-1:0] AWID_S_reg;
logic [				13:0] AWADDR_reg;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
		AWID_S_reg   <= `AXI_IDS_BITS'd0;
	else
		AWID_S_reg <= (AW_hs_done) ? S_AW.AWID_S : AWID_S_reg;
end

always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
		AWADDR_reg <= 14'd0;
	else if(cur_state == ADDR)
		AWADDR_reg <= (AW_hs_done) ? S_AW.AWADDR[15:2] : AWADDR_reg;
	else if(cur_state == WRITE)
	begin
		if(W_hs_done)
		begin
			AWADDR_reg <= AWADDR_reg + 14'd1;
		end
		else
			AWADDR_reg <= AWADDR_reg;
	end 
	else
		AWADDR_reg <= AWADDR_reg;
end

assign S_AW.AWREADY = (cur_state == ADDR);

assign S_W.WREADY = (cur_state == WRITE);

//B-channel
assign  S_B.BID_S   = AWID_S_reg; 
assign  S_B.BRESP   = `AXI_RESP_OKAY;
assign  S_B.BVALID  = (cur_state == WRESP);

//R-channel
logic [`AXI_IDS_BITS-1:0] ARID_S_reg;
logic [				13:0] ARADDR_reg;
logic [`AXI_LEN_BITS-1:0] ARLEN_reg;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		ARID_S_reg <= `AXI_IDS_BITS'd0;
		ARLEN_reg  <= `AXI_LEN_BITS'd0;
	end
	else
	begin
		ARID_S_reg <= (AR_hs_done) ? S_AR.ARID_S : ARID_S_reg;
		ARLEN_reg  <= (AR_hs_done) ? S_AR.ARLEN : ARLEN_reg;
	end
end

always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		ARADDR_reg <= 14'd0;
		len_cnt <= `AXI_LEN_BITS'd0;
	end
	else if(cur_state == ADDR)
		ARADDR_reg <= (AR_hs_done) ? S_AR.ARADDR[15:2] : ARADDR_reg;
	else if(cur_state == READ)
	begin
		if(R_hs_done)
		begin
			ARADDR_reg <= ARADDR_reg + 14'd1;
			if(len_cnt == ARLEN_reg)
				len_cnt <= `AXI_LEN_BITS'd0;
			else
				len_cnt <= len_cnt + `AXI_LEN_BITS'd1;
		end
		else
			ARADDR_reg <= ARADDR_reg;
	end 
	else
		ARADDR_reg <= ARADDR_reg;
end

assign S_AR.ARREADY = (cur_state == ADDR) ? ~S_AW.AWVALID : 1'b0; //modified

assign S_R.RID_S  = ARID_S_reg;
assign S_R.RDATA  = (R_hs_done) ? DO : RDATA_reg;
assign S_R.RRESP  = `AXI_RESP_OKAY;
assign S_R.RLAST  = ( (len_cnt == ARLEN_reg) && (cur_state == READ) );
assign S_R.RVALID = (cur_state == READ);

assign CK = ~ACLK;

// always_comb //Chip enable (active low)
// begin
// 	CEB = 1'b1;
// 	if( (cur_state == ADDR) || (cur_state == READ) || (cur_state == WRITE) )
// 		CEB = 1'b0;
// 	else
// 		CEB = 1'b1;
// end

always_comb //Chip select (active high)
begin
	CS = 1'b0;
	if( (cur_state == ADDR) || (cur_state == READ) || (cur_state == WRITE) )
		CS = 1'b1;
	else
		CS = 1'b0;
end

// always_comb //read:active high , write:active low
// begin
// 	case(cur_state)
// 	WRITE:   WEB = 1'b0;
// 	default: WEB = 1'b1;
// 	endcase
// end

always_comb //Output enable (active high)
begin
	OE = 1'b0;
	case(cur_state)
		READ, WRITE: OE = 1'b1;
		default:     OE = 1'b0;
	endcase
end

// assign BWEB = ~{ {8{S_W.WSTRB[3]}} , {8{S_W.WSTRB[2]}} , {8{S_W.WSTRB[1]}} , {8{S_W.WSTRB[0]}} }; //Bit write enable (active low)

always_comb //Write enable (active low)
begin
	WEB = 4'b1111;
	case (cur_state)
		READ:
			WEB = 4'b1111;
		WRITE:
			WEB = ~S_W.WSTRB;
		default:
			WEB = 4'b1111;
	endcase
end

always_comb //Address
begin
	case(cur_state)
	ADDR:    A = (AW_hs_done) ? S_AW.AWADDR[15:2] : ( (AR_hs_done) ? S_AR.ARADDR[15:2] : 14'd0);
	READ:    A = ARADDR_reg;
	WRITE:   A = AWADDR_reg;
	default: A = 14'd0;
	endcase
end

assign DI = S_W.WDATA;

// TS1N16ADFPCLLLVTA512X45M4SWSHOD i_SRAM (
//   	.SLP(1'b0),
//   	.DSLP(1'b0),
//   	.SD(1'b0),
//   	.PUDELAY(),
//   	.CLK(ACLK),
// 	.CEB(CEB),
// 	.WEB(WEB),
//   	.A(A),
// 	.D(DI),
//   	.BWEB(BWEB),
//   	.RTSEL(2'b01),
//   	.WTSEL(2'b01),
//   	.Q(DO)
// );

  SRAM i_SRAM (
    .A0   (A[0]  ),
    .A1   (A[1]  ),
    .A2   (A[2]  ),
    .A3   (A[3]  ),
    .A4   (A[4]  ),
    .A5   (A[5]  ),
    .A6   (A[6]  ),
    .A7   (A[7]  ),
    .A8   (A[8]  ),
    .A9   (A[9]  ),
    .A10  (A[10] ),
    .A11  (A[11] ),
    .A12  (A[12] ),
    .A13  (A[13] ),
    .DO0  (DO[0] ),
    .DO1  (DO[1] ),
    .DO2  (DO[2] ),
    .DO3  (DO[3] ),
    .DO4  (DO[4] ),
    .DO5  (DO[5] ),
    .DO6  (DO[6] ),
    .DO7  (DO[7] ),
    .DO8  (DO[8] ),
    .DO9  (DO[9] ),
    .DO10 (DO[10]),
    .DO11 (DO[11]),
    .DO12 (DO[12]),
    .DO13 (DO[13]),
    .DO14 (DO[14]),
    .DO15 (DO[15]),
    .DO16 (DO[16]),
    .DO17 (DO[17]),
    .DO18 (DO[18]),
    .DO19 (DO[19]),
    .DO20 (DO[20]),
    .DO21 (DO[21]),
    .DO22 (DO[22]),
    .DO23 (DO[23]),
    .DO24 (DO[24]),
    .DO25 (DO[25]),
    .DO26 (DO[26]),
    .DO27 (DO[27]),
    .DO28 (DO[28]),
    .DO29 (DO[29]),
    .DO30 (DO[30]),
    .DO31 (DO[31]),
    .DI0  (DI[0] ),
    .DI1  (DI[1] ),
    .DI2  (DI[2] ),
    .DI3  (DI[3] ),
    .DI4  (DI[4] ),
    .DI5  (DI[5] ),
    .DI6  (DI[6] ),
    .DI7  (DI[7] ),
    .DI8  (DI[8] ),
    .DI9  (DI[9] ),
    .DI10 (DI[10]),
    .DI11 (DI[11]),
    .DI12 (DI[12]),
    .DI13 (DI[13]),
    .DI14 (DI[14]),
    .DI15 (DI[15]),
    .DI16 (DI[16]),
    .DI17 (DI[17]),
    .DI18 (DI[18]),
    .DI19 (DI[19]),
    .DI20 (DI[20]),
    .DI21 (DI[21]),
    .DI22 (DI[22]),
    .DI23 (DI[23]),
    .DI24 (DI[24]),
    .DI25 (DI[25]),
    .DI26 (DI[26]),
    .DI27 (DI[27]),
    .DI28 (DI[28]),
    .DI29 (DI[29]),
    .DI30 (DI[30]),
    .DI31 (DI[31]),
    .CK   (CK    ),
    .WEB0 (WEB[0]),
    .WEB1 (WEB[1]),
    .WEB2 (WEB[2]),
    .WEB3 (WEB[3]),
    .OE   (OE    ),
    .CS   (CS    )
  );

endmodule