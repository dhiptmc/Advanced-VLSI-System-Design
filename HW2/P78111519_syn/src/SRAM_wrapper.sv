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
// logic CEB;
// logic WEB;
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
// 		WRITE:   WEB = 1'b0;
// 		default: WEB = 1'b1;
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

// assign BWEB = ~{ {8{WSTRB_S[3]}} , {8{WSTRB_S[2]}} , {8{WSTRB_S[1]}} , {8{WSTRB_S[0]}} }; //Bit write enable (active low)
always_comb //Write enable (active low)
begin
	WEB = 4'b1111;
	case (cur_state)
		READ:
			WEB = 4'b1111;
		WRITE:
			WEB = ~WSTRB_S;
		default:
			WEB = 4'b1111;
	endcase
end

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