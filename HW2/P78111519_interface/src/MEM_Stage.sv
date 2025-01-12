module MEM_Stage (
    //----------------From EXE/MEM Register----------------//

    //------------ Control signals------------//
    input  logic [              1:0] MEM_MEM_rd_sel,
    input  logic                     MEM_MemRead,
    input  logic                     MEM_MemWrite,
    input  logic                     MEM_gen_reg_write, 
    input  logic                     MEM_fp_reg_write,
    input  logic                     MEM_WB_data_sel, 
    //------------ Control signals------------//

    input  logic [`FUNCTION_3 - 1:0] MEM_funct3,
    input  logic [      `RegAddrBus] MEM_rd_addr,

    input  logic [          `RegBus] MEM_PC_sel_out,
    input  logic [          `RegBus] MEM_ALU_out,
    input  logic [          `RegBus] MEM_EXE_mux_rs2_data,

    input  logic [          `RegBus] MEM_CSR_rd_data,

    //----------------From EXE/MEM Register----------------//

    //-----Output Control signals for later stages...-----//
    output logic                     MEM_WB_gen_reg_write, 
    output logic                     MEM_WB_fp_reg_write,
    output logic                     MEM_WB_WB_data_sel, 
    //-----Output Control signals for later stages...-----//

    //---------------------Data Memory---------------------//
    output logic                     DM_CEB,        //Chip enable (active low)
    output logic                     DM_WEB,        //read:active high , write:active low
    output logic [         `BWEBBus] DM_BWEB,       //Bit write enable (active low)
    output logic [     `DataAddrBus] Data_addr,
    input  logic [         `DataBus] Data_in,
    output logic [         `DataBus] Data_out,      
    //---------------------Data Memory---------------------//

    // below are output signals or data
    output logic [      `RegAddrBus] MEM_WB_rd_addr,
    output logic [          `RegBus] MEM_rd_data,   /*one of the final outputs, offers forwarding*/
    output logic [          `RegBus] DM_rd_data     /*one of the final outputs*/
);

localparam [                    1:0] from_ALU    = 2'b00,
                                     from_PC     = 2'b01,
                                     from_CSR    = 2'b10;

assign MEM_WB_gen_reg_write = MEM_gen_reg_write;
assign MEM_WB_fp_reg_write  = MEM_fp_reg_write;
assign MEM_WB_WB_data_sel   = MEM_WB_data_sel;

//DM
assign DM_CEB    = !(MEM_MemRead | MEM_MemWrite);

always_comb
begin
    if(MEM_MemRead)
        DM_WEB = 1'b1;
    else if(MEM_MemWrite)
        DM_WEB = 1'b0;
    else
        DM_WEB = 1'b1;
end

always_comb
begin
    DM_BWEB = `INACTIVE;
    
    if(MEM_MemWrite)
    begin
        case (MEM_funct3)
            3'b000:  DM_BWEB[{MEM_ALU_out[1:0] , 3'd0} +: 8]  = 8'd0;      //SB           when Data_addr moves 32'd1, it moves 1byte(8bits)
            3'b001:  DM_BWEB[{MEM_ALU_out[1]   , 4'd0} +:16]  = 16'd0;     //SH
            3'b010:  DM_BWEB                                  = `ZeroWord; //SW & FSW
            default: DM_BWEB                                  = `INACTIVE;
        endcase
    end
    else
        DM_BWEB = `INACTIVE;
end

assign Data_addr = MEM_ALU_out;

always_comb
begin
    Data_out = `ZeroWord; //reset value

    if(MEM_MemWrite)
    begin
        case (MEM_funct3)
            3'b000:  Data_out[{MEM_ALU_out[1:0] , 3'd0} +: 8] = MEM_EXE_mux_rs2_data[7:0];  //SB
            3'b001:  Data_out[{MEM_ALU_out[1]   , 4'd0} +:16] = MEM_EXE_mux_rs2_data[15:0]; //SH
            3'b010:  Data_out = MEM_EXE_mux_rs2_data;                                       //SW & FSW
            default: Data_out = `ZeroWord;
        endcase
    end
    else
        Data_out = `ZeroWord;
end

//

assign MEM_WB_rd_addr = MEM_rd_addr;

always_comb
begin
    case(MEM_MEM_rd_sel)
        from_ALU: MEM_rd_data = MEM_ALU_out;
        from_PC : MEM_rd_data = MEM_PC_sel_out;
        from_CSR: MEM_rd_data = MEM_CSR_rd_data;
        default : MEM_rd_data = `ZeroWord;
    endcase
end

always_comb
begin
    DM_rd_data = `ZeroWord;

    if(MEM_MemRead)
    begin
        case (MEM_funct3)
            3'b000:  DM_rd_data = {{24{Data_in[7]}} ,  Data_in[7:0]};      //LB(signed)
            3'b001:  DM_rd_data = {{16{Data_in[15]}} , Data_in[15:0]};     //LH
            3'b010:  DM_rd_data = Data_in;                                 //LW & FLW
            3'b100:  DM_rd_data = {24'd0 , Data_in[7:0]};                  //LBU
            3'b101:  DM_rd_data = {16'd0 , Data_in[15:0]};                 //LHU
            default: DM_rd_data = `ZeroWord;
        endcase
    end
    else
        DM_rd_data = `ZeroWord;
end

endmodule