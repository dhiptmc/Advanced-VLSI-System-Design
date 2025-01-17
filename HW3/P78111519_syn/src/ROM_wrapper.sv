module ROM_wrapper (
    input  logic        ACLK,
    input  logic        ARESETn,

    input  logic [31:0] ROM_out,        //Data from ROM
	output logic 		ROM_read,		//ROM output enable
	output logic 		ROM_enable,		//Enable ROM
	output logic [11:0] ROM_address,	//Address to ROM

    AR_interface.ROM    S0_AR,
    R_interface.ROM     S0_R
);

//Handshake process check
logic  AR_hs_done;
logic  R_hs_done;

assign AR_hs_done = S0_AR.ARVALID & S0_AR.ARREADY; 
assign R_hs_done  = S0_R.RVALID   & S0_R.RREADY;

//Last check
logic  R_last;
assign R_last = S0_R.RLAST & R_hs_done;

//FSM
logic  cur_state, nxt_state;
localparam  ADDR = 1'b0,
            READ = 1'b1;

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
    ADDR: nxt_state = (AR_hs_done) ? READ : ADDR;
    READ: nxt_state = (    R_last) ? ADDR : READ;
    endcase
end

//length count
logic [`AXI_LEN_BITS-1:0] len_cnt;
logic [`AXI_LEN_BITS-1:0] incr;
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

assign incr = len_cnt; //?

//R-channel
logic [`AXI_IDS_BITS-1:0] ARID_S_reg;
logic [				13:0] ARADDR_reg;
logic [`AXI_LEN_BITS-1:0] ARLEN_reg;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		ARID_S_reg <= `AXI_IDS_BITS'd0;
		ARADDR_reg <= 14'd0;
		ARLEN_reg  <= `AXI_LEN_BITS'd0;
	end
	else
	begin
		ARID_S_reg <= (AR_hs_done) ? S0_AR.ARID_S 	    : ARID_S_reg;
		ARADDR_reg <= (AR_hs_done) ? S0_AR.ARADDR[15:2] : ARADDR_reg;
		ARLEN_reg  <= (AR_hs_done) ? S0_AR.ARLEN  	    : ARLEN_reg;
	end
end

always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		S0_AR.ARREADY <= 1'b0;
	end
	else
	begin
		case(cur_state)
		ADDR:
			S0_AR.ARREADY <= (AR_hs_done) ? 1'b0 : 1'b1;
		default:
			S0_AR.ARREADY <= 1'b0;
		endcase
	end
end

assign S0_R.RID_S  = ARID_S_reg;
assign S0_R.RDATA  = ROM_out; //ROM(DO)
assign S0_R.RRESP  = `AXI_RESP_OKAY;
assign S0_R.RLAST  = ( (len_cnt == ARLEN_reg) && (cur_state == READ) );
assign S0_R.RVALID = (cur_state == READ);

//ROM signals
//ROM(OE)
always_comb
begin
    case(cur_state)
        ADDR: ROM_read = AR_hs_done;
        READ: ROM_read = 1'b1;
    endcase
end
//ROM(CS)
assign ROM_enable = (cur_state == ADDR) ? (S0_AR.ARVALID) : 1'b0;
//ROM(A)
always_comb
begin
    case(cur_state)
        ADDR: ROM_address = S0_AR.ARADDR[15:2];
        READ: ROM_address = ARADDR_reg + {10'd0,incr}; //offset for burst incr. type ??
    endcase
end

endmodule