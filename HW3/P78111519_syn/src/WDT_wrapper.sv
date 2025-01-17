`include "WDT.sv"

module WDT_wrapper (
    input  logic     clk,
    input  logic     rstn,
    input  logic     clk2,
    input  logic     rstn2,

    AR_interface.WDT S4_AR,
    R_interface.WDT  S4_R,
    AW_interface.WDT S4_AW,
    W_interface.WDT  S4_W,
    B_interface.WDT  S4_B,

    output logic     WTO
);

logic        WDEN;
logic        WDLIVE;
logic [31:0] WTOCNT;

//Handshake process check
logic AR_hs_done;
logic R_hs_done;
logic AW_hs_done;
logic W_hs_done;
logic B_hs_done;

assign AR_hs_done = S4_AR.ARVALID & S4_AR.ARREADY; 
assign R_hs_done  = S4_R.RVALID   & S4_R.RREADY;
assign AW_hs_done = S4_AW.AWVALID & S4_AW.AWREADY;
assign W_hs_done  = S4_W.WVALID   & S4_W.WREADY;
assign B_hs_done  = S4_B.BVALID   & S4_B.BREADY;

//Last check
logic  R_last;
logic  W_last;
assign R_last = S4_R.RLAST & R_hs_done;
assign W_last = S4_W.WLAST & W_hs_done;

//FSM
logic [1:0] cur_state, nxt_state;
localparam [1:0]    ADDR  = 2'b00,
                    READ  = 2'b01,
                    WRITE = 2'b10,
                    WRESP = 2'b11;

always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
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
        nxt_state = (   R_last) ? ADDR  : READ;

    WRITE:
        nxt_state = (   W_last) ? WRESP : WRITE; 

    WRESP:
        nxt_state = (B_hs_done) ? ADDR  : WRESP;
    endcase    
end

//length count
logic [`AXI_LEN_BITS -1:0] len_cnt;
always_ff @ (posedge clk or negedge rstn)
begin
	if (!rstn)
	begin
		len_cnt <= `AXI_LEN_BITS'd0;
	end 
	else
	begin
		if(R_last || W_last)
			len_cnt <= `AXI_LEN_BITS'd0;            
		else if (R_hs_done || W_hs_done)
			len_cnt <= len_cnt + `AXI_LEN_BITS'd1;            
		else
			len_cnt <= len_cnt;
	end
end

//W-channel
logic [ `AXI_IDS_BITS -1:0] AWID_S_reg;
logic [`AXI_ADDR_BITS -1:0] AWADDR_reg;
always_ff @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		AWID_S_reg <= `AXI_IDS_BITS'd0;
		AWADDR_reg <= `AXI_ADDR_BITS'd0;
	end
	else
	begin
		AWID_S_reg <= (AW_hs_done)  ? S4_AW.AWID_S : AWID_S_reg;
		AWADDR_reg <= (AW_hs_done)  ? S4_AW.AWADDR : AWADDR_reg;
	end
end

always_ff @ (posedge clk or negedge rstn)
begin
	if(!rstn)
		S4_AW.AWREADY <= 1'b0;
	else
	begin
		case(cur_state)
		ADDR:
			S4_AW.AWREADY <= (AW_hs_done) ? 1'b0 : 1'b1;
		default:
			S4_AW.AWREADY <= 1'b0;
		endcase
	end	
end

assign S4_W.WREADY = (cur_state == WRITE);

//B-channel
assign S4_B.BID_S   = AWID_S_reg; 
assign S4_B.BRESP   = `AXI_RESP_OKAY;
assign S4_B.BVALID  = (cur_state == WRESP);

//R-channel
logic [`AXI_IDS_BITS-1:0] ARID_S_reg;
logic [`AXI_LEN_BITS-1:0] ARLEN_reg;
always_ff @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		ARID_S_reg <= `AXI_IDS_BITS'd0;
		ARLEN_reg  <= `AXI_LEN_BITS'd0;
	end
	else
	begin
		ARID_S_reg <= (AR_hs_done) ? S4_AR.ARID_S : ARID_S_reg;
		ARLEN_reg  <= (AR_hs_done) ? S4_AR.ARLEN  : ARLEN_reg;
	end
end

always_ff @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		S4_AR.ARREADY <= 1'b0;
	end
	else
	begin
		case(cur_state)
		ADDR:
			S4_AR.ARREADY <= (AR_hs_done) ? 1'b0 : 1'b1;
		default:
			S4_AR.ARREADY <= 1'b0;
		endcase
	end
end

assign S4_R.RID_S  =  ARID_S_reg;
assign S4_R.RDATA  = `AXI_DATA_BITS'd0; //?
assign S4_R.RRESP  = `AXI_RESP_OKAY;
assign S4_R.RLAST  = ( (len_cnt == ARLEN_reg) && (cur_state == READ) );
assign S4_R.RVALID = (cur_state == READ);

//WDT
always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        WDEN   <= 1'b0;
        WDLIVE <= 1'b0;
        WTOCNT <= 32'd0;
    end
    else if(W_hs_done)
    begin
        case(AWADDR_reg[15:0])
        16'h0100: WDEN   <= S4_W.WDATA[0];
        16'h0200: WDLIVE <= S4_W.WDATA[0];
        16'h0300: WTOCNT <= S4_W.WDATA;
        default:
        begin
            WDEN   <= WDEN;
            WDLIVE <= WDLIVE;
            WTOCNT <= WTOCNT;
        end
        endcase
    end
    else
    begin
        WDEN   <= WDEN;
        WDLIVE <= WDLIVE;
        WTOCNT <= WTOCNT;
    end
end

logic WTOCNT_load; //WTOCNT_load 的主要用途是協調多位元信號 WTOCNT 的跨時鐘域同步，確保 clk 域的 WTOCNT 值在 clk2 域中被正確且穩定地捕獲。
always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
        WTOCNT_load <= 1'b0;
    else if(W_hs_done && (AWADDR_reg[15:0] == 16'h0300))
        WTOCNT_load <= 1'b1;
    else
        WTOCNT_load <= WTOCNT_load;
end

logic WTO_clk2;
logic WTO_clk1_stage1, WTO_clk1_stage2;
// Double-flop synchronizer for single-bit signal WTO_clk2_result
// Ensures metastability resolution and signal stability when crossing clock domains
always_ff @ (posedge clk or negedge rstn) //單位元信號跨時鐘域同步
begin
    if(!rstn)
    begin
        WTO_clk1_stage1 <= 1'b0;
        WTO_clk1_stage2 <= 1'b0;
    end
    else
    begin
        WTO_clk1_stage1 <= WTO_clk2;
        WTO_clk1_stage2 <= WTO_clk1_stage1;
    end
end

assign WTO = WTO_clk1_stage2;

WDT i_WDT (
    .clk        (clk),
    .rstn       (rstn),
    .clk2       (clk2),
    .rstn2      (rstn2),
    
    .WTOCNT_load(WTOCNT_load),

    .WDEN       (WDEN),
    .WDLIVE     (WDLIVE),
    .WTOCNT     (WTOCNT),
    .WTO        (WTO_clk2)
);

endmodule