module DMA_Master (
    input  logic        ACLK,
    input  logic        ARESETn,

    input  logic        DMAEN,
    input  logic [31:0] DMASRC,
    input  logic [31:0] DMADST,
    input  logic [31:0] DMALEN,
    output logic        DMA_interrupt,

    AR_interface.DMA_M  M2_AR,
    R_interface.DMA_M   M2_R,
    AW_interface.DMA_M  M2_AW,
    W_interface.DMA_M   M2_W,
    B_interface.DMA_M   M2_B
);

//Handshake process check
logic  AR_hs_done;
logic  R_hs_done;
logic  AW_hs_done;
logic  W_hs_done;
logic  B_hs_done;

assign AR_hs_done = M2_AR.ARVALID & M2_AR.ARREADY; 
assign R_hs_done  = M2_R.RVALID   & M2_R.RREADY;
assign AW_hs_done = M2_AW.AWVALID & M2_AW.AWREADY;
assign W_hs_done  = M2_W.WVALID   & M2_W.WREADY;
assign B_hs_done  = M2_B.BVALID   & M2_B.BREADY;

//Last check
logic  R_last;
logic  W_last;
assign R_last = M2_R.RLAST & R_hs_done;
assign W_last = M2_W.WLAST & W_hs_done;

logic busy;
logic [`AXI_ADDR_BITS -1:0] slave_src;
logic [`AXI_ADDR_BITS -1:0] slave_dst;
logic [               31:0] total_data;
logic [               31:0] remain_data;
logic [                4:0] single_transfer_data;

//FSM
localparam [2:0]    PREPARE = 3'b000,
                    RADDR   = 3'b001,
                    RDATA   = 3'b010,
                    WADDR   = 3'b011,
                    WDATA   = 3'b100,
                    WRESP   = 3'b101,
                    FINISH  = 3'b110;

logic [2:0] cur_state, nxt_state;

always_ff @ (posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)
        cur_state <= PREPARE;
    else
        cur_state <= nxt_state;
end

always_comb
begin
    case(cur_state)
    PREPARE:
    begin
        if(DMAEN)
            nxt_state = RADDR;
        else
            nxt_state = PREPARE;
    end

    RADDR:
    begin
        if(AR_hs_done)
            nxt_state = RDATA;
        else
            nxt_state = RADDR;
    end

    RDATA:
    begin
        if(R_last)
            nxt_state = WADDR;
        else
            nxt_state = RDATA;
    end

    WADDR:
    begin
        if(AW_hs_done)
            nxt_state = WDATA;
        else
            nxt_state = WADDR;
    end

    WDATA:
    begin
        if(W_last)
            nxt_state = WRESP;
        else
            nxt_state = WDATA;
    end

    WRESP:
    begin
        if(B_hs_done)
            nxt_state = (busy) ? RADDR : FINISH;
        else
            nxt_state = WRESP;
    end

    FINISH:
    begin
        if(!DMAEN)
            nxt_state = PREPARE;
        else
            nxt_state = FINISH;
    end

    default:
        nxt_state = PREPARE;
    endcase
end

always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if (!ARESETn)
        remain_data <= 32'd0;
    else if(cur_state == PREPARE)
        remain_data <= total_data;
    else if(W_last)
        remain_data <= remain_data - {27'd0, single_transfer_data};
    else
        remain_data <= remain_data;
end

always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if (!ARESETn)
        single_transfer_data <= 5'd0;
    else if(cur_state == PREPARE)
        single_transfer_data <= (total_data < 32'd16)  ? total_data[4:0]  : 5'd16;
    else if(cur_state == WADDR)
        single_transfer_data <= (remain_data < 32'd16) ? remain_data[4:0] : 5'd16;
    else
        single_transfer_data <= single_transfer_data;
end

assign busy = |remain_data;

//length count
logic [`AXI_LEN_BITS:0] len_cnt;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
	if (!ARESETn)
	begin
		len_cnt <= 5'd0;
	end 
	else
	begin
		if(W_last)
			len_cnt <= 5'd0;            
		else if (W_hs_done)
			len_cnt <= len_cnt + 5'd1;            
		else
			len_cnt <= len_cnt;
	end
end

//W-channel
assign M2_AW.AWID    = `AXI_ID_BITS'd2;
assign M2_AW.AWADDR  =  slave_dst;
assign M2_AW.AWLEN   = `AXI_LEN_BITS'd15;
assign M2_AW.AWSIZE  = `AXI_SIZE_BITS'b10;
assign M2_AW.AWBURST = `AXI_BURST_INC;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)
        M2_AW.AWVALID <= 1'b0;
    else
    begin
        case(cur_state)
        WADDR:   M2_AW.AWVALID <= (AW_hs_done) ? 1'b0 : 1'b1;
        default: M2_AW.AWVALID <= 1'b0;
        endcase
    end
end

always_comb
begin
    if(len_cnt >= single_transfer_data)
        M2_W.WSTRB   = `AXI_STRB_BITS'd0; // if out of range, then stop transfer data
    else
        M2_W.WSTRB   = `AXI_STRB_BITS'hf;
end
assign M2_W.WLAST    =  ( (cur_state == WDATA) && (len_cnt == {1'b0,M2_AW.AWLEN}) ) ;
assign M2_W.WVALID   =  (cur_state == WDATA);

assign M2_B.BREADY   =  ( (cur_state == WDATA) || (cur_state == WRESP) ) ;  

//R-channel
assign M2_AR.ARID    = `AXI_ID_BITS'd2;
assign M2_AR.ARADDR  =  slave_src;
assign M2_AR.ARLEN   = `AXI_LEN_BITS'd15;
assign M2_AR.ARSIZE  = `AXI_SIZE_BITS'b10;
assign M2_AR.ARBURST = `AXI_BURST_INC;
always_ff @ (posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)
        M2_AR.ARVALID <= 1'b0;
    else
    begin
        case(cur_state)
        RADDR:   M2_AR.ARVALID <= (AR_hs_done) ? 1'b0 : 1'b1;
        default: M2_AR.ARVALID <= 1'b0;
        endcase
    end
end

assign M2_R.RREADY   = ( M2_R.RVALID && (cur_state == RDATA) );

//slave info for DMA
always_ff @ (posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)
    begin
        slave_src  <= `AXI_ADDR_BITS'd0;
        slave_dst  <= `AXI_ADDR_BITS'd0;
        total_data <= 32'd0;
    end
    else if(cur_state == PREPARE)
    begin
        slave_src  <= DMASRC;
        slave_dst  <= DMADST;
        total_data <= DMALEN;
    end
    else if(cur_state == WRESP)
    begin
        slave_src  <= slave_src + ((`AXI_ADDR_BITS'd16) << 2); //16 datas each move address 4
        slave_dst  <= slave_dst + ((`AXI_ADDR_BITS'd16) << 2);
    end
    else
    begin
        slave_src  <= slave_src;
        slave_dst  <= slave_dst;
        total_data <= total_data;
    end
end

//Store Data
integer i;
logic [`AXI_DATA_BITS -1: 0] data_buffer [15:0]; //burst length up to 15+1=16
always_ff @ (posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)
    begin
        for(i = 0; i <= 15; i = i + 1)
            data_buffer[i] <= `AXI_DATA_BITS'd0;
    end
    else
    begin
        if( (cur_state == RDATA) && R_hs_done )
        begin
            data_buffer[0] <= M2_R.RDATA;
            for(i = 0; i <= 14; i = i + 1)
                data_buffer[i+1] <= data_buffer[i];
        end
        else if( (cur_state == WDATA) && W_hs_done )
        begin
            data_buffer[0] <= `AXI_DATA_BITS'd0;
            for(i = 0; i <= 14; i = i + 1)
                data_buffer[i+1] <= data_buffer[i];
        end
    end
end

assign M2_W.WDATA = data_buffer[15];

//DMA output signal
always_ff @ (posedge ACLK or negedge ARESETn)
begin
    if(!ARESETn)
        DMA_interrupt <= 1'b0;
    else if(cur_state == FINISH)
        DMA_interrupt <= 1'b1;
    else
        DMA_interrupt <= 1'b0;
end

endmodule