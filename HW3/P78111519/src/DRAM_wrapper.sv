/*                                                                  */
/*   Memory slower then SRAM, storing programs to load in HW3       */
/*  Excluded outside of top module, need to write FSM to control    */
/*                                                                  */
module DRAM_wrapper (
    input  logic        ACLK,
    input  logic        ARESETn,

	output logic 		DRAM_CSn,		//DRAM Chip Select (active low)
	output logic [3:0]	DRAM_WEn,		//DRAM Write Enable (active low)
	output logic 		DRAM_RASn,		//DRAM Row Access Strobe (active low)
	output logic 		DRAM_CASn,		//DRAM Column Access Strobe (active low)
	output logic [10:0] DRAM_A,			//Address to DRAM
	output logic [31:0] DRAM_D,			//Data to DRAM
	input  logic [31:0] DRAM_Q,			//Data from DRAM
	input  logic		DRAM_valid,		//DRAM output data valid

    AR_interface.DRAM   S5_AR,
    R_interface.DRAM    S5_R,
    AW_interface.DRAM   S5_AW,
    W_interface.DRAM    S5_W,
    B_interface.DRAM    S5_B
);

typedef enum logic [2:0] { IDLE , ACT , READ , WRITE , PRE } DRAM_state;
DRAM_state cur_state, nxt_state;

localparam  CSn_ENB  = 1'b0, CSn_DIS  = 1'b1,
            WEn_ENB  = 1'b0, WEn_DIS  = 1'b1,
            RASn_ENB = 1'b0, RASn_DIS = 1'b1,
            CASn_ENB = 1'b0, CASn_DIS = 1'b1;

//Handshake process check
logic  AR_hs_done;
logic  R_hs_done;
logic  AW_hs_done;
logic  W_hs_done;
logic  B_hs_done;

assign AR_hs_done = S5_AR.ARVALID & S5_AR.ARREADY; 
assign R_hs_done  = S5_R.RVALID   & S5_R.RREADY;
assign AW_hs_done = S5_AW.AWVALID & S5_AW.AWREADY;
assign W_hs_done  = S5_W.WVALID   & S5_W.WREADY;
assign B_hs_done  = S5_B.BVALID   & S5_B.BREADY;

//Last check
logic  R_last;
logic  W_last;
assign R_last = S5_R.RLAST & R_hs_done;
assign W_last = S5_W.WLAST & W_hs_done;

logic [`AXI_DATA_BITS -1:0] RDATA_reg;
logic [ `AXI_LEN_BITS -1:0] ARLEN_reg, AWLEN_reg;
logic [ `AXI_LEN_BITS -1:0] counter_read, counter_write;
logic [ `AXI_IDS_BITS -1:0] ARID_S_reg, AWID_S_reg;

logic [2:0] delay_cnt;
logic       delay_done;
assign      delay_done = (delay_cnt == 3'd5);
logic       return_flag;
always_ff @ (posedge ACLK or negedge ARESETn) //modified
begin
    if(!ARESETn)
        delay_cnt <= 3'd0;
    else if(return_flag)
        delay_cnt <= 3'd0;
    else if(delay_cnt == 3'd5)
        if(nxt_state == READ)
            delay_cnt <= 3'd0;
        else
            delay_cnt <= delay_cnt; 
    else
        delay_cnt <= delay_cnt + 3'd1;
end

assign S5_R.RID_S = (AR_hs_done) ? S5_AR.ARID_S : ARID_S_reg;
assign S5_R.RDATA = ( (cur_state == READ) && DRAM_valid ) ? DRAM_Q : RDATA_reg;
assign S5_R.RRESP = `AXI_RESP_OKAY;
assign S5_R.RLAST = ( (cur_state == READ) && (counter_read == ARLEN_reg) && (delay_cnt == 3'd5) );
assign S5_B.BID_S = (AW_hs_done) ? S5_AW.AWID_S : AWID_S_reg;
assign S5_B.BRESP = `AXI_RESP_OKAY;

//keep RDATA stable
always_ff @ (posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)
        RDATA_reg <= `AXI_DATA_BITS'd0;
    else
    begin
        RDATA_reg <= ( (cur_state == READ) && DRAM_valid ) ? DRAM_Q : RDATA_reg;
    end
end

//get LEN and ID
always_ff @ (posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)
    begin
        ARLEN_reg  <= `AXI_LEN_BITS'd0;
        AWLEN_reg  <= `AXI_LEN_BITS'd0;
        ARID_S_reg <= `AXI_IDS_BITS'd0;
        AWID_S_reg <= `AXI_IDS_BITS'd0;
    end
    else
    begin
        ARLEN_reg  <= (AR_hs_done) ? S5_AR.ARLEN  : ARLEN_reg;
        AWLEN_reg  <= (AW_hs_done) ? S5_AW.AWLEN  : AWLEN_reg;
        ARID_S_reg <= (AR_hs_done) ? S5_AR.ARID_S : ARID_S_reg;
        AWID_S_reg <= (AW_hs_done) ? S5_AW.AWID_S : AWID_S_reg;
    end
end

//get counters and address
logic [`AXI_ADDR_BITS -1:0] ADDR_reg;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)
    begin
        counter_read  <= `AXI_LEN_BITS'd0;
        counter_write <= `AXI_LEN_BITS'd0;
        ADDR_reg      <= `AXI_ADDR_BITS'd0;
    end
    else if(cur_state == IDLE)
    begin
        if(AW_hs_done)
            ADDR_reg <= S5_AW.AWADDR;        
        else if(AR_hs_done)
            ADDR_reg <= S5_AR.ARADDR;
        else
            ADDR_reg <= ADDR_reg;
    end
    else if(cur_state == READ)
    begin
        if(R_hs_done)
        begin
            if(counter_read == ARLEN_reg)
                counter_read <= `AXI_LEN_BITS'd0;
            else
            begin
                counter_read <= counter_read + `AXI_LEN_BITS'd1;
                ADDR_reg     <= ADDR_reg + `AXI_ADDR_BITS'd4;
            end
        end
        else
        begin
            counter_read  <= counter_read;
            ADDR_reg      <= ADDR_reg;
        end
    end
    else if(cur_state == WRITE)
    begin
        if(W_hs_done)
        begin
            if(counter_write == AWLEN_reg)
                counter_write <= `AXI_LEN_BITS'd0;
            else
            begin
                counter_write <= counter_write + `AXI_LEN_BITS'd1;
                ADDR_reg      <= ADDR_reg + `AXI_ADDR_BITS'd4;
            end
        end
        else
        begin
            counter_write <= counter_write;
            ADDR_reg      <= ADDR_reg;
        end
    end
    else
    begin
        counter_read  <= counter_read;
        counter_write <= counter_write;
        ADDR_reg      <= ADDR_reg;
    end
end

logic diff_row_detect_READ;
always_comb
begin
    if( (cur_state == READ) && (DRAM_A == 11'h3ff) && (counter_read != ARLEN_reg) )
        diff_row_detect_READ = 1'b1;
    else
        diff_row_detect_READ = 1'b0;
end

logic  diff_row_detect_WRITE;
always_comb
begin
    if( (cur_state == WRITE) && (DRAM_A == 11'h3ff) && (counter_write != AWLEN_reg) )
        diff_row_detect_WRITE = 1'b1;
    else
        diff_row_detect_WRITE = 1'b0;
end

logic rw; //read(1'b1) write(1'b0)
always_ff @ (posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)
        rw <= 1'b0;
    else
        rw <= (AW_hs_done) ? 1'b0 : ( (AR_hs_done) ? 1'b1 : rw ); 
end


/*                  FSM                 */
always_ff @ (posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)
        cur_state <= IDLE;
    else
        cur_state <= nxt_state;
end

always_comb
begin
    return_flag = 1'b0;

    case(cur_state)
    IDLE:
    begin
        if( (delay_done) && ( (AR_hs_done) || (AW_hs_done) ) )
        begin
            return_flag = 1'b1;
            nxt_state = ACT;
        end
        else
            nxt_state = IDLE;
    end

    ACT:
    begin
        if(delay_done)
        begin
            return_flag = 1'b1;

            if(rw)
                nxt_state = READ;
            else
                nxt_state = WRITE;      
        end
        else
            nxt_state = ACT;
    end

    READ:
    begin
        if(delay_done)
        begin
            return_flag = 1'b1;
            if(R_last)
                nxt_state = PRE;
            else if(R_hs_done && !diff_row_detect_READ)
                nxt_state = READ;
            else if(diff_row_detect_READ)
                nxt_state = PRE;
            else
                nxt_state = READ;
        end
        else
            nxt_state = READ;
    end

    WRITE:
    begin
        if(delay_done)
        begin
            return_flag = 1'b1;
            if(W_last)
                nxt_state = PRE;
            else if(W_hs_done && !diff_row_detect_WRITE)
                nxt_state = WRITE;
            else if(diff_row_detect_WRITE)
                nxt_state = PRE;
            else
                nxt_state = WRITE;
        end
        else
            nxt_state = WRITE;
    end

    PRE:
    begin
        if(delay_done)
        begin
            return_flag = 1'b1;
            if( (counter_read != `AXI_LEN_BITS'd0) || (counter_write != `AXI_LEN_BITS'd0) )
                nxt_state = ACT;
            else
                nxt_state = IDLE;
        end
        else
            nxt_state = PRE;
    end

    default:
    begin
        nxt_state = IDLE;
    end
    endcase
end
/*                  FSM                 */

//Store activate row for precharge
logic [10:0] row;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
		row <= 11'd0;
	else if(cur_state == ACT)
		row <= ADDR_reg[22:12];
	else 
		row <= row;
end

//DRAM signals
always_comb
begin
    case(cur_state)
    IDLE:
    begin
	    DRAM_CSn    = CSn_DIS;
	    DRAM_WEn    = {4{WEn_DIS}};
	    DRAM_RASn   = RASn_DIS;
	    DRAM_CASn   = CASn_DIS;
	    DRAM_A      = (AW_hs_done) ? S5_AW.AWADDR[22:12] : ( (AR_hs_done) ? S5_AR.ARADDR[22:12] : 11'd0 );
	    DRAM_D      = 32'd0;
    end

    ACT:
    begin
	    DRAM_CSn    = CSn_ENB;
	    DRAM_WEn    = {4{WEn_DIS}};
	    DRAM_RASn   = (delay_cnt == 3'd0) ? RASn_ENB : RASn_DIS;
	    DRAM_CASn   = CASn_DIS;
	    DRAM_A      = ADDR_reg[22:12];
	    DRAM_D      = 32'd0;
    end

    READ:
    begin
	    DRAM_CSn    = CSn_ENB;
	    DRAM_WEn    = {4{WEn_DIS}};
	    DRAM_RASn   = RASn_DIS;
	    DRAM_CASn   = (delay_cnt == 3'd0) ? CASn_ENB : CASn_DIS;
	    DRAM_A      = {1'b0, ADDR_reg[11:2]};
	    DRAM_D      = 32'd0;
    end

    WRITE:
    begin
	    DRAM_CSn    = CSn_ENB;
	    DRAM_WEn    = (delay_cnt == 3'd0) ? ~S5_W.WSTRB : {4{WEn_DIS}};
	    DRAM_RASn   = RASn_DIS;
	    DRAM_CASn   = (delay_cnt == 3'd0) ? CASn_ENB : CASn_DIS;
	    DRAM_A      = {1'b0, ADDR_reg[11:2]};
	    DRAM_D      = S5_W.WDATA;
    end

    PRE:
    begin
	    DRAM_CSn    = CSn_ENB;
	    DRAM_WEn    = (delay_cnt == 3'd0) ? {4{WEn_ENB}} : {4{WEn_DIS}}; 
	    DRAM_RASn   = (delay_cnt == 3'd0) ? RASn_ENB : RASn_DIS;
	    DRAM_CASn   = CASn_DIS;
	    DRAM_A      = row;
	    DRAM_D      = 32'd0;
    end

    default:
    begin
	    DRAM_CSn    = CSn_DIS;
	    DRAM_WEn    = {4{WEn_DIS}};;
	    DRAM_RASn   = RASn_DIS;
	    DRAM_CASn   = CASn_DIS;
	    DRAM_A      = 11'd0;
	    DRAM_D      = 32'd0;
    end
    endcase
end

//AXI signals
always_comb
begin
    case(cur_state)
    IDLE:
    begin
        S5_AR.ARREADY = (delay_done) ? ~S5_AW.AWVALID : 1'b0; //if want to write, write first
        S5_R.RVALID   = 1'b0;
        S5_AW.AWREADY = (delay_done);
        S5_W.WREADY   = 1'b0;
    end

    ACT:
    begin
        S5_AR.ARREADY = 1'b0;
        S5_R.RVALID   = 1'b0;
        S5_AW.AWREADY = 1'b0;
        S5_W.WREADY   = 1'b0;
    end

    READ:
    begin
        S5_AR.ARREADY = 1'b0;
        S5_R.RVALID   = (delay_done); 
        S5_AW.AWREADY = 1'b0;
        S5_W.WREADY   = 1'b0;
    end

    WRITE:
    begin
        S5_AR.ARREADY = 1'b0;
        S5_R.RVALID   = 1'b0;
        S5_AW.AWREADY = 1'b0;
        S5_W.WREADY   = (delay_done); 
    end

    PRE:
    begin
        S5_AR.ARREADY = 1'b0;
        S5_R.RVALID   = 1'b0;
        S5_AW.AWREADY = 1'b0;
        S5_W.WREADY   = 1'b0;
    end

    default:
    begin
        S5_AR.ARREADY = 1'b0;
        S5_R.RVALID   = 1'b0;
        S5_AW.AWREADY = 1'b0;
        S5_W.WREADY   = 1'b0;
    end
    endcase
end

always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
        S5_B.BVALID <= 1'b0;
    else
    begin
        if(W_last)
            S5_B.BVALID <= 1'b1;
        else if(B_hs_done)
            S5_B.BVALID <= 1'b0;
        else
            S5_B.BVALID <= S5_B.BVALID;
    end
end

endmodule