module MEM_WB_Reg (
    input  logic                     clk,
    input  logic                     rst,

    input  logic                     MEM_WB_Reg_Write,

    input  logic                     MEM_WB_gen_reg_write, 
    input  logic                     MEM_WB_fp_reg_write,
    input  logic                     MEM_WB_WB_data_sel,

    input  logic [      `RegAddrBus] MEM_WB_rd_addr,
    input  logic [          `RegBus] MEM_rd_data,
    input  logic [          `RegBus] DM_rd_data,

    output logic                     WB_gen_reg_write, 
    output logic                     WB_fp_reg_write,
    output logic                     WB_WB_data_sel,

    output logic [      `RegAddrBus] WB_rd_addr,
    output logic [          `RegBus] WB_MEM_rd_data,
    output logic [          `RegBus] WB_DM_rd_data,

    input  logic                     CSR_rst
);

always_ff @ (posedge clk or posedge rst)
begin
    if(rst)
    begin
        WB_gen_reg_write <= 1'b0;
        WB_fp_reg_write  <= 1'b0;
        WB_WB_data_sel   <= 1'b0;

        WB_rd_addr       <= `RegNumLog2'd0;
        WB_MEM_rd_data   <= `ZeroWord;
        WB_DM_rd_data    <= `ZeroWord;
    end
    else if(CSR_rst)
    begin
        WB_gen_reg_write <= 1'b0;
        WB_fp_reg_write  <= 1'b0;
        WB_WB_data_sel   <= 1'b0;

        WB_rd_addr       <= `RegNumLog2'd0;
        WB_MEM_rd_data   <= `ZeroWord;
        WB_DM_rd_data    <= `ZeroWord;
    end
    else if(MEM_WB_Reg_Write)
    begin
        WB_gen_reg_write <= MEM_WB_gen_reg_write;
        WB_fp_reg_write  <= MEM_WB_fp_reg_write;
        WB_WB_data_sel   <= MEM_WB_WB_data_sel;

        WB_rd_addr       <= MEM_WB_rd_addr;
        WB_MEM_rd_data   <= MEM_rd_data;
        WB_DM_rd_data    <= DM_rd_data;
    end
    else
    begin
        WB_gen_reg_write <= WB_gen_reg_write;
        WB_fp_reg_write  <= WB_fp_reg_write;
        WB_WB_data_sel   <= WB_WB_data_sel;

        WB_rd_addr       <= WB_rd_addr;
        WB_MEM_rd_data   <= WB_MEM_rd_data;
        WB_DM_rd_data    <= WB_DM_rd_data;
    end
end

endmodule