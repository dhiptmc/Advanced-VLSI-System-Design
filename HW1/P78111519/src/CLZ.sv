`include "../include/def.svh"

module CLZ (
    input  logic [`RegBus]         number,
    output logic [`RegNumLog2 : 0] CLZ_result //max 32
);

logic [15:0] number_16bit;
logic [ 7:0] number_8bit;
logic [ 3:0] number_4bit;
logic [ 1:0] number_2bit;

logic [ 5:0] count_16;
logic [ 5:0] count_8;
logic [ 5:0] count_4;
logic [ 5:0] count_2;
logic [ 5:0] count_1;

always_comb
begin
    if((number & 32'hffff_0000) == 32'd0)
    begin
        count_16     = 6'd16;
        number_16bit = number[15:0];
    end
    else
    begin
        count_16     = 6'd0;
        number_16bit = number[31:16];
    end
end

always_comb
begin
    if((number_16bit & 16'hff00) == 16'd0)
    begin
        count_8     = 6'd8;
        number_8bit = number_16bit[7:0];
    end
    else
    begin
        count_8     = 6'd0;
        number_8bit = number_16bit[15:8];
    end
end

always_comb
begin
    if((number_8bit & 8'hf0) == 8'd0)
    begin
        count_4     = 6'd4;
        number_4bit = number_8bit[3:0];
    end
    else
    begin
        count_4     = 6'd0;
        number_4bit = number_8bit[7:4];
    end
end

always_comb
begin
    if((number_4bit & 4'hc) == 4'd0)
    begin
        count_2     = 6'd2;
        number_2bit = number_4bit[1:0];
    end
    else
    begin
        count_2     = 6'd0;
        number_2bit = number_4bit[3:2];
    end
end

always_comb
begin
    if((number_2bit & 2'h2) == 2'd0)
        count_1     = 6'd1;
    else
        count_1     = 6'd0;
end

assign CLZ_result = (number != `DataWidth'd0) ? ( (count_16 + count_8 ) + (count_4 + count_2 ) + count_1 ) : 6'd32;

endmodule