module Default_Slave (
    input  logic               clk,
    input  logic               rstn,

    AR_interface.Default_Slave DS_AR,    
    R_interface.Default_Slave  DS_R,
    AW_interface.Default_Slave DS_AW,
    W_interface.Default_Slave  DS_W,
    B_interface.Default_Slave  DS_B
);

//Handshake process check
logic AR_hs_done;
logic R_hs_done;
logic AW_hs_done;
logic W_hs_done;
logic B_hs_done;

assign AR_hs_done = DS_AR.ARVALID & DS_AR.ARREADY; 
assign R_hs_done  = DS_R.RVALID   & DS_R.RREADY;
assign AW_hs_done = DS_AW.AWVALID & DS_AW.AWREADY;
assign W_hs_done  = DS_W.WVALID   & DS_W.WREADY;
assign B_hs_done  = DS_B.BVALID   & DS_B.BREADY;

logic [1:0] slave_state, nxt_state;
localparam [1:0] ADDR  = 2'b00,
                 READ  = 2'b01,
                 WRITE = 2'b10,
                 RESP  = 2'b11;

always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
        slave_state <= ADDR;
    else
        slave_state <= nxt_state;
end

always_comb
begin
    case(slave_state)
    ADDR:
    begin
        if(AR_hs_done)
            nxt_state = READ;
        else if (AW_hs_done)
            nxt_state = WRITE;
        else
            nxt_state = ADDR;
    end

    READ:
    begin
        if(R_hs_done)
            nxt_state = ADDR;
        else
            nxt_state = READ;
    end

    WRITE:
    begin
        if(W_hs_done && DS_W.WLAST)
            nxt_state = RESP;
        else
            nxt_state = WRITE;
    end

    RESP:
    begin
        if(B_hs_done)
            nxt_state = ADDR;
        else
            nxt_state = RESP;        
    end
    endcase
end

//AR
assign DS_AR.ARREADY = (DS_AR.ARVALID && (slave_state == ADDR));

//R
always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        DS_R.RID_S <= `AXI_IDS_BITS'd0;
    end
    else
    begin
        DS_R.RID_S <= (AR_hs_done) ? DS_AR.ARID_S: DS_R.RID_S;
    end
end

assign DS_R.RDATA  = `AXI_DATA_BITS'd0;
assign DS_R.RRESP  = `AXI_RESP_DECERR;
assign DS_R.RLAST  = 1'b1;
assign DS_R.RVALID = (slave_state == READ); //VALID signal must not be dependent on the READY signal in the transaction!!

//AW
assign DS_AW.AWREADY = (DS_AW.AWVALID && (slave_state == ADDR));

//W
assign DS_W.WREADY   = (DS_W.WVALID && (slave_state == WRITE));

//B
always_ff @(posedge clk or negedge rstn)
begin
    if(!rstn)
        DS_B.BID_S <= `AXI_IDS_BITS'd0;
    else
        DS_B.BID_S <= (AW_hs_done) ? DS_AW.AWID_S : DS_B.BID_S;
end

assign DS_B.BRESP  = `AXI_RESP_DECERR;
assign DS_B.BVALID = (slave_state == RESP); //VALID signal must not be dependent on the READY signal in the transaction!!

endmodule