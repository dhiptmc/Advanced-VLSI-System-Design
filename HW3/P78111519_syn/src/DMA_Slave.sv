module DMA_Slave (
    input  logic        ACLK,
    input  logic        ARESETn,

    output logic        DMAEN,
    output logic [31:0] DMASRC,
    output logic [31:0] DMADST,
    output logic [31:0] DMALEN,

    AR_interface.DMA_S  S3_AR,
    R_interface.DMA_S   S3_R,
    AW_interface.DMA_S  S3_AW,
    W_interface.DMA_S   S3_W,
    B_interface.DMA_S   S3_B
);

//Handshake process check
logic  AR_hs_done;
logic  R_hs_done;
logic  AW_hs_done;
logic  W_hs_done;
logic  B_hs_done;

assign AR_hs_done = S3_AR.ARVALID & S3_AR.ARREADY; 
assign R_hs_done  = S3_R.RVALID   & S3_R.RREADY;
assign AW_hs_done = S3_AW.AWVALID & S3_AW.AWREADY;
assign W_hs_done  = S3_W.WVALID   & S3_W.WREADY;
assign B_hs_done  = S3_B.BVALID   & S3_B.BREADY;

//Last check
logic  R_last;
logic  W_last;
assign R_last = S3_R.RLAST & R_hs_done;
assign W_last = S3_W.WLAST & W_hs_done;

/*                  FSM                 */
logic [1:0] cur_state, nxt_state;
localparam [1:0]    ADDR  = 2'b00,
                    RDATA = 2'b01,
                    WDATA = 2'b10,
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
        if(AW_hs_done)
            nxt_state = WDATA;
        else if(AR_hs_done)
            nxt_state = RDATA;
        else
            nxt_state = ADDR;
    end

    RDATA:
        nxt_state = (R_last)    ? ADDR  : RDATA;
    
    WDATA:
        nxt_state = (W_last)    ? WRESP : WDATA;

    WRESP:
        nxt_state = (B_hs_done) ? ADDR  : WRESP; 
    endcase
end
/*                  FSM                 */

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
logic [ `AXI_IDS_BITS -1:0] AWID_S_reg;
logic [`AXI_ADDR_BITS -1:0] AWADDR_reg;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		AWID_S_reg <= `AXI_IDS_BITS'd0;
		AWADDR_reg <= `AXI_ADDR_BITS'd0;
	end
	else
	begin
		AWID_S_reg <= (AW_hs_done)  ? S3_AW.AWID_S : AWID_S_reg;
		AWADDR_reg <= (AW_hs_done)  ? S3_AW.AWADDR : AWADDR_reg;
	end
end

always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
		S3_AW.AWREADY <= 1'b0;
	else
	begin
		case(cur_state)
		ADDR:
			S3_AW.AWREADY <= (AW_hs_done) ? 1'b0 : 1'b1;
		default:
			S3_AW.AWREADY <= 1'b0;
		endcase
	end	
end

assign S3_W.WREADY   = (cur_state == WDATA);

//B-channel
assign  S3_B.BID_S   = AWID_S_reg; 
assign  S3_B.BRESP   = `AXI_RESP_OKAY;
assign  S3_B.BVALID  = (cur_state == WRESP);

//R-channel
logic [`AXI_IDS_BITS-1:0] ARID_S_reg;
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
		ARID_S_reg <= (AR_hs_done) ? S3_AR.ARID_S : ARID_S_reg;
		ARLEN_reg  <= (AR_hs_done) ? S3_AR.ARLEN  : ARLEN_reg;
	end
end

always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		S3_AR.ARREADY <= 1'b0;
	end
	else
	begin
		case(cur_state)
		ADDR:
			S3_AR.ARREADY <= (AR_hs_done) ? 1'b0 : 1'b1;
		default:
			S3_AR.ARREADY <= 1'b0;
		endcase
	end
end

assign S3_R.RID_S  = ARID_S_reg;
assign S3_R.RDATA  = `AXI_DATA_BITS'd0; //?
assign S3_R.RRESP  = `AXI_RESP_OKAY;
assign S3_R.RLAST  = ( (len_cnt == ARLEN_reg) && (cur_state == RDATA) );
assign S3_R.RVALID = (cur_state == RDATA);

//DMA output signal
always_ff @ (posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)
    begin
        DMAEN  <= 1'b0;
        DMASRC <= 32'd0;
        DMADST <= 32'd0;
        DMALEN <= 32'd0;
    end
    else if(W_hs_done)
    begin
        case(AWADDR_reg[15:0])
            16'h0100: DMAEN  <= S3_W.WDATA[0];
            16'h0200: DMASRC <= S3_W.WDATA;
            16'h0300: DMADST <= S3_W.WDATA;
            16'h0400: DMALEN <= S3_W.WDATA;
            default:
            begin
                DMAEN  <= DMAEN;
                DMASRC <= DMASRC;
                DMADST <= DMADST;
                DMALEN <= DMALEN;
            end
        endcase  
    end
    else
    begin
        DMAEN  <= DMAEN;
        DMASRC <= DMASRC;
        DMADST <= DMADST;
        DMALEN <= DMALEN;
    end
end

endmodule