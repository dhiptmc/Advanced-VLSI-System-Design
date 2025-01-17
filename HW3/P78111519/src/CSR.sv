module CSR (
    input  logic                     clk,
    input  logic                     rst,
    
    input  logic [`FUNCTION_3 - 1:0] funct3,
    input  logic [`FUNCTION_7 - 1:0] funct7,

    input  logic [          `RegBus] EXE_PC_out,
    input  logic [      `RegAddrBus] EXE_rs1_addr,
    input  logic [          `RegBus] ALU_rs1_data,
    input  logic [          `RegBus] Imm_CSR,

    input  logic [             11:0] EXE_csr_addr,
    input  logic                     EXE_CSR_sel,
    input  logic [              1:0] EXE_CSR_type,

    input  logic                     Hazardstall_flag,
    input  logic [       `PCTypeBus] PCSrc, // See if branch or not

    input  logic                     DMA_interrupt,
    input  logic                     WDT_timeout,

    output logic [          `RegBus] CSR_return_PC,
    output logic [          `RegBus] CSR_ISR_PC,
    output logic                     CSR_stall,
    output logic                     CSR_interrupt,
    output logic                     CSR_ret,
    output logic                     CSR_rst,

    output logic [          `RegBus] CSR_rd_data
);

logic [31:0] cycleh, cycle, instreth, instret;

always_ff @ (posedge clk or posedge rst)
begin
    if(rst)
    begin
        {cycleh, cycle}     <= 64'd0;
        {instreth, instret} <= 64'd0;
    end
    else
    begin
        {cycleh, cycle}     <= {cycleh, cycle} + 64'd1;
        if( ({cycleh, cycle} > 64'd1) && (!Hazardstall_flag) )
        begin
            // if(lw_use)
            //     {instreth, instret} <= {instreth, instret};
            // else if (PCSrc != 2'b00)
            //     {instreth, instret} <= {instreth, instret} - 64'd1; // Add 1 when branch instruction is executing, Minus 2 for flush 2 instructions in IF,ID stage ( 1 - 2 = -1 )
            // else
            //     {instreth, instret} <= {instreth, instret} + 64'd1;
            
            //note: above is wrong.

            case(EXE_CSR_type)
            2'd0:
                {instreth, instret} <= {instreth, instret} - 64'd1; // Add 1 when branch instruction is executing, Minus 2 for flush 2 instructions in IF,ID stage ( 1 - 2 = -1 )
            2'd1:
                {instreth, instret} <= {instreth, instret};
            default:
                {instreth, instret} <= {instreth, instret} + 64'd1;
            endcase
        end
        else
            {instreth, instret} <= {instreth, instret};
    end
end

logic [31:0] mstatus; 
logic [31:0] mie;      
logic [31:0] mtvec;
logic [31:0] mepc; 
logic [31:0] mip;      

assign mtvec = 32'h0001_0000; //mtvec is hardwire to 0x0001_0000.
assign mip = {20'b0 , DMA_interrupt , 3'b0 , WDT_timeout , 7'b0};

assign CSR_return_PC = mepc;
assign CSR_ISR_PC    = mtvec;
always_ff @ (posedge clk or posedge rst)
begin
    if(rst)
        CSR_stall <= 1'b0;
    else if(!Hazardstall_flag)
    begin
        if(DMA_interrupt)
            CSR_stall <= 1'b0;
        else if((funct3 == 3'b000) && (funct7 == 7'b000_1000) && (EXE_CSR_sel))
            CSR_stall <= 1'b1;
        else
            CSR_stall <= CSR_stall;
    end
end
assign CSR_interrupt = DMA_interrupt;
assign CSR_ret       = ((funct3 == 3'b000) && (funct7 == 7'b001_1000) && (EXE_CSR_sel));
assign CSR_rst       = WDT_timeout;

//index of CSRs register
parameter [3:0] MPP  = 4'd11,
                MPIE = 4'd7,
                MIE  = 4'd3,
                MEIP = 4'd11,
                MTIP = 4'd7,
                MEIE = 4'd11,
                MTIE = 4'd7;

always_ff @ (posedge clk or posedge rst)
begin
    if(rst)
    begin
        mstatus <= 32'd0;
        mie     <= 32'd0;
        mepc    <= 32'd0;
    end
    else if( (funct3 == 3'b000) && EXE_CSR_sel ) //MRET or WFI
    begin
        if(funct7 == 7'b001_1000) //MRET -> interrupt is return
        begin
            mstatus[MPP+:2] <= 2'b11;
            mstatus[MPIE]   <= 1'b1;
            mstatus[MIE]    <= mstatus[MPIE];
        end
        else //WFI
            mepc <= EXE_PC_out + 32'd4;
    end
    else if(DMA_interrupt && (!Hazardstall_flag))   //external interrupt is taken
    begin
        mstatus[MPP+:2] <= (mip[MEIP]) ? 2'b11 : mstatus[MPP+:2];
        mstatus[MPIE]   <= (mip[MEIP]) ? mstatus[MIE] : mstatus[MPIE];
        mstatus[MIE]    <= (mip[MEIP]) ? 1'b0  : mstatus[MIE];
    end
    else if(WDT_timeout && (!Hazardstall_flag))     //timeout interrupt is taken
    begin
        mstatus[MPP+:2] <= (mip[MTIP]) ? 2'b11 : mstatus[MPP+:2];
        mstatus[MPIE]   <= (mip[MTIP]) ? mstatus[MIE] : mstatus[MPIE];
        mstatus[MIE]    <= (mip[MTIP]) ? 1'b0  : mstatus[MIE];  
    end
    else
    begin
        if(EXE_CSR_sel && (!Hazardstall_flag))
        begin
            case(EXE_csr_addr)
            12'h300:
            begin
                case(funct3)
                3'b001: //CSRRW
                begin
                    mstatus[MPP+:2] <= ALU_rs1_data[MPP+:2];
                    mstatus[MPIE]   <= ALU_rs1_data[MPIE];
                    mstatus[MIE]    <= ALU_rs1_data[MIE];
                end
                
                3'b010: //CSRRS
                begin
                    if(ALU_rs1_data != `DataWidth'd0)
                    begin
                        mstatus[MPP+:2] <= mstatus[MPP+:2] | ALU_rs1_data[MPP+:2];
                        mstatus[MPIE]   <= mstatus[MPIE]   | ALU_rs1_data[MPIE];
                        mstatus[MIE]    <= mstatus[MIE]    | ALU_rs1_data[MIE];
                    end
                    else
                        mstatus <= mstatus;
                end

                3'b011: //CSRRC
                begin
                    if(ALU_rs1_data != `DataWidth'd0)
                    begin
                        mstatus[MPP+:2] <= mstatus[MPP+:2] & ~ALU_rs1_data[MPP+:2];
                        mstatus[MPIE]   <= mstatus[MPIE]   & ~ALU_rs1_data[MPIE];
                        mstatus[MIE]    <= mstatus[MIE]    & ~ALU_rs1_data[MIE];
                    end
                    else
                        mstatus <= mstatus;
                end

                3'b101: //CSRRWI
                begin
                    mstatus[MPP+:2] <= Imm_CSR[MPP+:2];
                    mstatus[MPIE]   <= Imm_CSR[MPIE];
                    mstatus[MIE]    <= Imm_CSR[MIE];
                end

                3'b110: //CSRRSI
                begin
                    if(Imm_CSR != `DataWidth'd0)
                    begin
                        mstatus[MPP+:2] <= mstatus[MPP+:2] | Imm_CSR[MPP+:2];
                        mstatus[MPIE]   <= mstatus[MPIE]   | Imm_CSR[MPIE];
                        mstatus[MIE]    <= mstatus[MIE]    | Imm_CSR[MIE];
                    end
                    else
                        mstatus <= mstatus;
                end

                3'b111: //CSRRCI
                begin
                    if(Imm_CSR != `DataWidth'd0)
                    begin
                        mstatus[MPP+:2] <= mstatus[MPP+:2] & ~Imm_CSR[MPP+:2];
                        mstatus[MPIE]   <= mstatus[MPIE]   & ~Imm_CSR[MPIE];
                        mstatus[MIE]    <= mstatus[MIE]    & ~Imm_CSR[MIE];
                    end
                    else
                        mstatus <= mstatus;
                end

                default:
                    mstatus <= mstatus;
                endcase
            end

            12'h304:
            begin
                case(funct3)
                3'b001:
                    mie[MEIE] <= ALU_rs1_data[MEIE];
                
                3'b010:
                begin
                    if(ALU_rs1_data != `DataWidth'd0)
                        mie[MEIE] <= mie[MEIE] | ALU_rs1_data[MEIE];
                    else
                        mie <= mie;
                end

                3'b011:
                begin
                    if(ALU_rs1_data != `DataWidth'd0)
                    begin
                        mie[MEIE] <= mie[MEIE] & ~ALU_rs1_data[MEIE];
                    end
                    else
                        mie <= mie;
                end

                3'b101:
                    mie[MEIE] <= Imm_CSR[MEIE];

                3'b110:
                begin
                    if(Imm_CSR != `DataWidth'd0)
                        mie[MEIE] <= mie[MEIE] | Imm_CSR[MEIE];
                    else
                        mie <= mie;
                end

                3'b111:
                begin
                    if(Imm_CSR != `DataWidth'd0)
                    begin
                        mie[MEIE] <= mie[MEIE] & ~Imm_CSR[MEIE];
                    end
                    else
                        mie <= mie;
                end

                default:
                    mie <= mie;
                endcase
            end

            12'h341:
            begin
                case(funct3)
                3'b001:
                    mepc <= ALU_rs1_data;
                
                3'b010:
                begin
                    if(ALU_rs1_data != `DataWidth'd0)
                        mepc <= mepc | ALU_rs1_data;
                    else
                        mepc <= mepc;
                end

                3'b011:
                begin
                    if(ALU_rs1_data != `DataWidth'd0)
                    begin
                        mepc <= mepc & ~ALU_rs1_data;
                    end
                    else
                        mepc <= mepc;
                end

                3'b101:
                    mepc <= Imm_CSR;

                3'b110:
                begin
                    if(Imm_CSR != `DataWidth'd0)
                        mepc <= mepc | Imm_CSR;
                    else
                        mepc <= mepc;
                end

                3'b111:
                begin
                    if(Imm_CSR != `DataWidth'd0)
                    begin
                        mepc <= mepc & ~Imm_CSR;
                    end
                    else
                        mepc <= mepc;
                end

                default:
                    mepc <= mepc;
                endcase
            end

            default:
            begin
                mstatus <= mstatus;
                mie     <= mie;
                mepc    <= mepc;
            end
            endcase
        end
    end
end

always_comb
begin
    case(EXE_csr_addr)
    12'h300: CSR_rd_data = mstatus;
    12'h304: CSR_rd_data = mie;
    12'h305: CSR_rd_data = mtvec;
    12'h341: CSR_rd_data = mepc;
    12'h344: CSR_rd_data = mip;
    12'hb00: CSR_rd_data = cycle;
    12'hb02: CSR_rd_data = instret;
    12'hb80: CSR_rd_data = cycleh;
    12'hb82: CSR_rd_data = instreth;
    default: CSR_rd_data = 32'd0;
    endcase
end

endmodule