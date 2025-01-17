module WB_Stage (
    input  logic           WB_WB_data_sel,
    input  logic [`RegBus] WB_MEM_rd_data, //same as MEM_WB_rd_data
    input  logic [`RegBus] WB_DM_rd_data,
    output logic [`RegBus] WB_rd_data
);

assign WB_rd_data = (WB_WB_data_sel) ? WB_DM_rd_data : WB_MEM_rd_data;

endmodule