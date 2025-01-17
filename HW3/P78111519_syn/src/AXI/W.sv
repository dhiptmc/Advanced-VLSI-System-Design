module W (
    input logic                      clk,
    input logic                      rstn,

    W_interface.M1                   M1,
    W_interface.M2                   M2,   
    W_interface.S1                   S1,
    W_interface.S2                   S2,
    W_interface.S3                   S3,
    W_interface.S4                   S4,
    W_interface.S5                   S5,
    W_interface.SDEFAULT             SDEFAULT,


    input logic [`AXI_IDS_BITS -1:0] AWID_S_S1,
    input logic [`AXI_IDS_BITS -1:0] AWID_S_S2,
    input logic [`AXI_IDS_BITS -1:0] AWID_S_S3,
    input logic [`AXI_IDS_BITS -1:0] AWID_S_S4,
    input logic [`AXI_IDS_BITS -1:0] AWID_S_S5,
    // input logic [`AXI_IDS_BITS -1:0] AWID_S_SDEFAULT,
    input logic                      AWVALID_S1,
    input logic                      AWVALID_S2,
    input logic                      AWVALID_S3,
    input logic                      AWVALID_S4,
    input logic                      AWVALID_S5,
    // input logic                      AWVALID_SDEFAULT
    AW_interface.SDEFAULT            AW_SDEFAULT  
);

logic WVALID_S1_reg, WVALID_S2_reg, WVALID_S3_reg, WVALID_S4_reg, WVALID_S5_reg, WVALID_SDEFAULT_reg;
logic [`AXI_IDS_BITS -1:0] AWID_S_reg;

logic [3:0] master;
logic [5:0] slave;

logic [`AXI_DATA_BITS-1:0] WDATA_M;
logic [`AXI_STRB_BITS-1:0] WSTRB_M;
logic                      WLAST_M;
logic                      WVALID_M;

logic READY;

// signals to slaves
// slave 1
assign S1.WDATA       = WDATA_M;
assign S1.WSTRB       = (S1.WVALID) ? WSTRB_M : `AXI_STRB_BITS'b0000;
assign S1.WLAST       = WLAST_M;
// slave 2
assign S2.WDATA       = WDATA_M;
assign S2.WSTRB       = (S2.WVALID) ? WSTRB_M : `AXI_STRB_BITS'b0000;
assign S2.WLAST       = WLAST_M;
// slave 3
assign S3.WDATA       = WDATA_M;
assign S3.WSTRB       = (S3.WVALID) ? WSTRB_M : `AXI_STRB_BITS'b0000;
assign S3.WLAST       = WLAST_M;
// slave 4
assign S4.WDATA       = WDATA_M;
assign S4.WSTRB       = (S4.WVALID) ? WSTRB_M : `AXI_STRB_BITS'b0000;
assign S4.WLAST       = WLAST_M;
// slave 5
assign S5.WDATA       = WDATA_M;
assign S5.WSTRB       = (S5.WVALID) ? WSTRB_M : `AXI_STRB_BITS'b0000;
assign S5.WLAST       = WLAST_M;
// DEFAULT slave
assign SDEFAULT.WDATA = WDATA_M;
assign SDEFAULT.WSTRB = (SDEFAULT.WVALID) ? WSTRB_M : `AXI_STRB_BITS'b0000;
assign SDEFAULT.WLAST = WLAST_M;

assign slave = {(WVALID_SDEFAULT_reg | AW_SDEFAULT.AWVALID) , (WVALID_S5_reg | AWVALID_S5) , (WVALID_S4_reg | AWVALID_S4) , (WVALID_S3_reg | AWVALID_S3) , (WVALID_S2_reg | AWVALID_S2) , (WVALID_S1_reg | AWVALID_S1)};

always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        WVALID_S1_reg       <= 1'b0;
        WVALID_S2_reg       <= 1'b0;
        WVALID_S3_reg       <= 1'b0;
        WVALID_S4_reg       <= 1'b0;
        WVALID_S5_reg       <= 1'b0;
        WVALID_SDEFAULT_reg <= 1'b0;
    end
    else
    begin		
		if(AWVALID_S1 && ~READY)
			WVALID_S1_reg <= AWVALID_S1;
		else if(WVALID_M && READY && WLAST_M)
			WVALID_S1_reg <= 1'b0;
		else 
			WVALID_S1_reg <= WVALID_S1_reg;

		if(AWVALID_S2 && ~READY)
			WVALID_S2_reg <= AWVALID_S2;
		else if(WVALID_M && READY && WLAST_M)
			WVALID_S2_reg <= 1'b0;
		else 
			WVALID_S2_reg <= WVALID_S2_reg;

		if(AWVALID_S3 && ~READY)
			WVALID_S3_reg <= AWVALID_S3;
		else if(WVALID_M && READY && WLAST_M)
			WVALID_S3_reg <= 1'b0;
		else 
			WVALID_S3_reg <= WVALID_S3_reg;

		if(AWVALID_S4 && ~READY)
			WVALID_S4_reg <= AWVALID_S4;
		else if(WVALID_M && READY && WLAST_M)
			WVALID_S4_reg <= 1'b0;
		else 
			WVALID_S4_reg <= WVALID_S4_reg;

		if(AWVALID_S5 && ~READY)
			WVALID_S5_reg <= AWVALID_S5;
		else if(WVALID_M && READY && WLAST_M)
			WVALID_S5_reg <= 1'b0;
		else 
			WVALID_S5_reg <= WVALID_S5_reg;

		if(AW_SDEFAULT.AWVALID && ~READY)
			WVALID_SDEFAULT_reg <= AW_SDEFAULT.AWVALID;
		else if(WVALID_M && READY && WLAST_M)
			WVALID_SDEFAULT_reg <= 1'b0;
		else 
			WVALID_SDEFAULT_reg <= WVALID_SDEFAULT_reg;
    end
end

always_ff @ (posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        AWID_S_reg <= `AXI_IDS_BITS'd0;
    end
    else
    begin
        if(AWVALID_S1)
            AWID_S_reg <= AWID_S_S1;
        else if(AWVALID_S2)
            AWID_S_reg <= AWID_S_S2;
        else if(AWVALID_S3)
            AWID_S_reg <= AWID_S_S3;
        else if(AWVALID_S4)
            AWID_S_reg <= AWID_S_S4;
        else if(AWVALID_S5)
            AWID_S_reg <= AWID_S_S5;
        else if(AW_SDEFAULT.AWVALID)
            AWID_S_reg <= AW_SDEFAULT.AWID_S;
        else
            AWID_S_reg <= AWID_S_reg;
    end
end

always_comb
begin
    case(master)
    4'b0010:
    begin
        // signals from master 1
        WDATA_M   = M1.WDATA;
        WSTRB_M   = M1.WSTRB;
        WLAST_M   = M1.WLAST;
        WVALID_M  = M1.WVALID;
        // signals to master 1
        M1.WREADY = READY & WVALID_M;
        M2.WREADY = 1'b0;
    end

    4'b0100:
    begin
        // signals from DMA
        WDATA_M   = M2.WDATA;
        WSTRB_M   = M2.WSTRB;
        WLAST_M   = M2.WLAST;
        WVALID_M  = M2.WVALID;
        // signals to DMA
        M1.WREADY = 1'b0;
        M2.WREADY = READY & WVALID_M;
    end

    default:
    begin
        WDATA_M   = `AXI_DATA_BITS'd0;
        WSTRB_M   = `AXI_STRB_BITS'd0;
        WLAST_M   = 1'b0;
        WVALID_M  = 1'b0;

        M1.WREADY = 1'b0;
        M2.WREADY = 1'b0;
    end
    endcase
end

always_comb
begin
    case(slave)
        // slave 1
        6'b00_0001:
        begin
            master = AWID_S_reg[7:4];
            READY  = S1.WREADY;
            {SDEFAULT.WVALID , S5.WVALID , S4.WVALID , S3.WVALID , S2.WVALID , S1.WVALID} = {5'b0_0000, WVALID_M};
        end
        // slave 2
        6'b00_0010:
        begin
            master = AWID_S_reg[7:4];
            READY  = S2.WREADY;
            {SDEFAULT.WVALID , S5.WVALID , S4.WVALID , S3.WVALID , S2.WVALID , S1.WVALID} = {4'b0000, WVALID_M , 1'b0};
        end
        // slave 3
        6'b00_0100:
        begin
            master = AWID_S_reg[7:4];
            READY  = S3.WREADY;
            {SDEFAULT.WVALID , S5.WVALID , S4.WVALID , S3.WVALID , S2.WVALID , S1.WVALID} = {3'b000, WVALID_M, 2'b00};
        end
        //slave 4
        6'b00_1000:
        begin
            master = AWID_S_reg[7:4];
            READY  = S4.WREADY;
            {SDEFAULT.WVALID , S5.WVALID , S4.WVALID , S3.WVALID , S2.WVALID , S1.WVALID} = {2'b00, WVALID_M, 3'b000};
        end
        //slave 5
        6'b01_0000:
        begin
            master = AWID_S_reg[7:4];
            READY  = S5.WREADY;
            {SDEFAULT.WVALID , S5.WVALID , S4.WVALID , S3.WVALID , S2.WVALID , S1.WVALID} = {1'b0, WVALID_M , 4'b0000};
        end
        //DEFAULT slave
        6'b10_0000:
        begin
            master = AWID_S_reg[7:4];
            READY  = SDEFAULT.WREADY;
            {SDEFAULT.WVALID , S5.WVALID , S4.WVALID , S3.WVALID , S2.WVALID , S1.WVALID} = {WVALID_M, 5'b0_0000};
        end

        default:
        begin
            master = 4'b0000;
            READY  = 1'b0;
            {SDEFAULT.WVALID , S5.WVALID , S4.WVALID , S3.WVALID , S2.WVALID , S1.WVALID} = 6'b00_0000;
        end
    endcase
end

endmodule