module ID_Gen_RegFile (
    input  logic clk,
    input  logic rst,

    //Control
    input  logic               regwrite,

    //I/O
    input  logic [`RegAddrBus] rs1_addr,
    output logic [`RegBus]     rs1_data,


    input  logic [`RegAddrBus] rs2_addr,
    output logic [`RegBus]     rs2_data,
    
    input  logic [`RegAddrBus] rd_addr,
    input  logic [`RegBus]     rd_data 
);

//integer
integer i;

//Register Size
logic   [`RegBus] gen_registers [`RegNum-1:0];

// Write register file //
always_ff @ (posedge clk or posedge rst) //load-use data hazard has been solved
begin
    if(rst)
    begin
        for( i = 0 ; i < `RegNum ; i = i + 1 )
        begin
            gen_registers[i] <= `ZeroWord;
        end        
    end
    else
    begin
        if((regwrite == `WriteEnable) && (rd_addr != `RegNumLog2'h0))
            gen_registers[rd_addr] <= rd_data;
    end 
end

// rs1
always_comb
begin
    if(rst)
        rs1_data = `ZeroWord;
    else if(rs1_addr == `RegNumLog2'h0)
        rs1_data = `ZeroWord;
    else if((regwrite == `WriteEnable) && (rd_addr == rs1_addr))
        rs1_data = rd_data;
    else
        rs1_data = gen_registers[rs1_addr];
end

// rs2
always_comb
begin
    if(rst)
        rs2_data = `ZeroWord;
    else if(rs1_addr == `RegNumLog2'h0)
        rs2_data = `ZeroWord;
    else if((regwrite == `WriteEnable) && (rd_addr == rs2_addr))
        rs2_data = rd_data;
    else
        rs2_data = gen_registers[rs2_addr];
end

endmodule