module CSR (
    input  logic clk,
    input  logic rst,
    
    input  logic [`FUNCTION_3 - 1:0] funct3,
    input  logic [          `RegBus] EXE_rs1_data,
    input  logic [          `RegBus] Imm_CSR,

    input  logic                     lw_use,
    input  logic                     Hazardstall_flag,
    input  logic [       `PCTypeBus] PCSrc, // See if branch or not

    output logic [          `RegBus] CSR_rd_data
);

localparam                     [2:0] CSRRW     = 3'b001,
                                     CSRRS     = 3'b010,
                                     CSRRC     = 3'b011,
                                     CSRRWI    = 3'b101,
                                     CSRRSI    = 3'b110,
                                     CSRRCI    = 3'b111;

logic [         `CSR_REG_WIDTH -1:0] instret;
logic [         `CSR_REG_WIDTH -1:0] cycle;

always_ff @ (posedge clk or posedge rst)
begin
    if(rst)
        cycle       <= `CSR_REG_WIDTH'd0;
    else
        cycle       <= cycle + `CSR_REG_WIDTH'd1;
end

logic [1:0] adjust;
always_ff @ (posedge clk or posedge rst)
begin
    if(rst)
        adjust      <= 2'b00;
    else
    begin
        if( (adjust == 2'd2) || Hazardstall_flag )
            adjust  <= adjust;
        else
            adjust  <= adjust + 2'b01;
    end
end

always_ff @ (posedge clk or posedge rst)
begin
    if(rst)
        instret     <= `CSR_REG_WIDTH'd0;
    else
    begin
        if( (adjust == 2'd2) && (!Hazardstall_flag) )
        begin
            if(lw_use)
                instret <= instret;
            else if (PCSrc != 2'b00)
                instret <= instret - `CSR_REG_WIDTH'd1; // Add 1 when branch instruction is executing, Minus 2 for flush 2 instructions in IF,ID stage ( 1 - 2 = -1 )
            else
                instret <= instret + `CSR_REG_WIDTH'd1; 
        end
    end
end

always_comb
begin
    case (Imm_CSR[11:0])
        12'hc82:  CSR_rd_data  =  instret[63:32]; //RDINSTRETH
        12'hc02:  CSR_rd_data  =  instret[31:0];  //RDINSTRET
        12'hc80:  CSR_rd_data  =  cycle  [63:32]; //RDCYCLEH
        12'hc00:  CSR_rd_data  =  cycle  [31:0];  //RDCYCLE
        default:  CSR_rd_data  =  `ZeroWord;
    endcase
end

endmodule