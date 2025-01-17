`include "CLZ.sv"

module EXE_ALU (
    //Control
    input  logic [    4:0] ALU_ctrl,

    //I/O
    input  logic [`RegBus] rs1,
    input  logic [`RegBus] rs2,
    output logic [`RegBus] ALU_out,

    //Output control signal
    output logic           branch_taken_flag
);

//------------------------- parameter -------------------------//
localparam [        4:0] ALU_add     = 5'd0, //R-type instructions
                         ALU_sub     = 5'd1,
                         ALU_sll     = 5'd2,
                         ALU_slt     = 5'd3,
                         ALU_sltu    = 5'd4,
                         ALU_xor     = 5'd5,
                         ALU_srl     = 5'd6,
                         ALU_sra     = 5'd7,
                         ALU_or      = 5'd8,
                         ALU_and     = 5'd9,
//--------------------------multiply --------------------------//
                         ALU_mul     = 5'd10,
                         ALU_mulh    = 5'd11,
                         ALU_mulhsu  = 5'd12,
                         ALU_mulhu   = 5'd13,

                         
                         ALU_jalr    = 5'd14,

//----------------------------branch----------------------------//                         
                         ALU_beq     = 5'd15, //B-type instructions
                         ALU_bne     = 5'd16,
                         ALU_blt     = 5'd17,
                         ALU_bge     = 5'd18,
                         ALU_bltu    = 5'd19,
                         ALU_bgeu    = 5'd20,
                         
                         ALU_lui     = 5'd21, //imm
                         
                         ALU_fadd_s  = 5'd22, //F-type instructions
                         ALU_fsub_s  = 5'd23;


//------------------------------------------------------------ general ------------------------------------------------------------//
logic signed [              `RegBus] signed_rs1;
logic signed [              `RegBus] signed_rs2;
logic        [              `RegBus] sum;
logic signed [`Mult_DataWidth - 1:0] Mult_rd_ss; //signed*signed
logic signed [`Mult_DataWidth - 1:0] Mult_rd_su; //signed*unsigned
logic        [`Mult_DataWidth - 1:0] Mult_rd_uu; //unsigned*unsigned

assign sum        = rs1 + rs2;
assign signed_rs1 = $signed(rs1);
assign signed_rs2 = $signed(rs2);
assign Mult_rd_ss = signed_rs1 * signed_rs2;
assign Mult_rd_su = signed_rs1 * $signed({1'b0,rs2});
assign Mult_rd_uu = rs1 * rs2;

logic                   sign_out;
logic [`EXPONENT - 1:0] exponent_out;
logic [`FRACTION - 1:0] fraction_out;

always_comb
begin
    case(ALU_ctrl)
        ALU_add:    ALU_out = sum;
        ALU_sub:    ALU_out = rs1 - rs2;
        ALU_sll:    ALU_out = rs1 << rs2[4:0];
        ALU_slt:    ALU_out = (signed_rs1 < signed_rs2) ? 32'd1 : 32'd0;
        ALU_sltu:   ALU_out = (rs1 < rs2) ? 32'd1 : 32'd0;
        ALU_xor:    ALU_out = rs1 ^ rs2;
        ALU_srl:    ALU_out = rs1 >> rs2[4:0];
        ALU_sra:    ALU_out = signed_rs1 >>> rs2[4:0];
        ALU_or:     ALU_out = rs1 | rs2;
        ALU_and:    ALU_out = rs1 & rs2;

        ALU_mul:    ALU_out = Mult_rd_ss[31:0]; //?
        ALU_mulh:   ALU_out = Mult_rd_ss[63:32];
        ALU_mulhsu: ALU_out = Mult_rd_su[63:32];
        ALU_mulhu:  ALU_out = Mult_rd_uu[63:32];

        ALU_jalr:   ALU_out = {sum[31:1],1'b0};
        
        ALU_lui:    ALU_out = rs2;

        ALU_fadd_s: ALU_out = {sign_out , exponent_out , fraction_out};
        ALU_fsub_s: ALU_out = {sign_out , exponent_out , fraction_out};
        
        default:    ALU_out = `ZeroWord;
    endcase
end

always_comb
begin
    case(ALU_ctrl)
        ALU_beq : branch_taken_flag = (rs1 == rs2) ? 1'b1: 1'b0;
        ALU_bne : branch_taken_flag = (rs1 != rs2) ? 1'b1: 1'b0;
        ALU_blt : branch_taken_flag = (signed_rs1 <  signed_rs2) ? 1'b1: 1'b0;
        ALU_bge : branch_taken_flag = (signed_rs1 >= signed_rs2) ? 1'b1: 1'b0;
        ALU_bltu: branch_taken_flag = (rs1 <  rs2) ? 1'b1: 1'b0;
        ALU_bgeu: branch_taken_flag = (rs1 >= rs2) ? 1'b1: 1'b0;
        default:  branch_taken_flag = 1'b0;
    endcase    
end

//--------------------------------------------------------- floating point ---------------------------------------------------------//
logic           compare_flag;
logic [`RegBus] fp_rs1;
logic [`RegBus] fp_rs2;

assign          compare_flag = rs1[30:0] >= rs2[30:0];
always_comb     //compare absolute value, change the order of the operand
begin
    if(compare_flag)
    begin
        fp_rs1 = rs1;
        fp_rs2 = rs2;
    end
    else
    begin
        fp_rs1 = rs2;
        fp_rs2 = rs1;
    end
end

logic [`RegBus] significand_rs1;
logic [`RegBus] significand_rs2;
logic [    7:0] shift;
logic [`RegBus] significand_rs2_shift;
assign significand_rs1       = (fp_rs1[30:23] == 8'd0) ? {1'b0 , fp_rs1[22:0] , 8'd0} : {1'b1 , fp_rs1[22:0] , 8'd0};
assign significand_rs2       = (fp_rs2[30:23] == 8'd0) ? {1'b0 , fp_rs2[22:0] , 8'd0} : {1'b1 , fp_rs2[22:0] , 8'd0};
assign shift                 = fp_rs1[30:23] - fp_rs2[30:23];
assign significand_rs2_shift = significand_rs2 >> shift;

logic [`EXPONENT - 1:0] exponent_add;
logic [`EXPONENT - 1:0] exponent_sub;
logic [`FRACTION - 1:0] fraction_add;
logic [`FRACTION - 1:0] fraction_sub;
logic                   fp_real_type;

assign sign_out     = ((ALU_ctrl == ALU_fsub_s) && !compare_flag) ? (!fp_rs1[31]) : fp_rs1[31]; //such as -1 < 3, but we want -1-3 = (-)4
assign exponent_out = (fp_real_type) ? exponent_add : exponent_sub;
assign fraction_out = (fp_real_type) ? fraction_add : fraction_sub;

//operation type: 1 for add type, 0 for sub type
// for add: 2 +  1,  -2 + -1 -> type 1
//          2 + -1 =  2 -  1 -> type 0
//         -2 +  1 = -2 - -1 -> type 0
// for sub: 2 -  1,  -2 - -1 -> type 0
//          2 - -1 =  2 +  1 -> type 1
//         -2 -  1 = -2 + -1 -> type 1
always_comb
begin
    case (ALU_ctrl)
        ALU_fadd_s: fp_real_type = !(fp_rs1[31] ^ fp_rs2[31]);
        ALU_fsub_s: fp_real_type = fp_rs1[31] ^ fp_rs2[31];
        default:    fp_real_type = 1'b1;
    endcase
end

//----------------------------- addition -----------------------------//
logic [`DataWidth:0] significand_add;
assign significand_add = {1'b0,significand_rs1} + {1'b0,significand_rs2_shift};

always_comb
begin
    if(significand_add[32])
    begin
        exponent_add = fp_rs1[30:23] + `EXPONENT'd1; //after shift, sum the significand, if significand overflows, exponent + 1
        
        if(significand_add[8:7] == 2'b11) // {Guard,Round}
        begin
            fraction_add = significand_add[31:9] + `FRACTION'd1;
        end
        else if(significand_add[8:7] == 2'b10)
        begin
            //sticky bit + LSB(round to nearest even)
            if( (|significand_add[6:0]) || significand_add[9])
            begin
                fraction_add = significand_add[31:9] + `FRACTION'd1;
            end
            else
            begin
                fraction_add = significand_add[31:9];
            end
        end
        else
        begin
            fraction_add = significand_add[31:9];
        end
    end
    else
    begin
        exponent_add = fp_rs1[30:23];

        if(significand_add[7:6] == 2'b11) // {Guard,Round}
        begin
            fraction_add = significand_add[30:8] + `FRACTION'd1;
        end
        else if(significand_add[7:6] == 2'b10)
        begin
            //sticky bit + LSB(round to nearest even)
            if( (|significand_add[5:0]) || significand_add[8])
            begin
                fraction_add = significand_add[30:8] + `FRACTION'd1;
            end
            else
            begin
                fraction_add = significand_add[30:8];
            end
        end
        else
        begin
            fraction_add = significand_add[30:8];
        end
    end
end

//----------------------------- subtraction -----------------------------//
logic [`DataWidth - 1:0] significand_sub;
assign significand_sub = significand_rs1 - significand_rs2_shift;

logic [   `RegNumLog2:0] sub_shift;
logic [`DataWidth - 1:0] significand_sub_normalize;

CLZ i_CLZ(
    .number(significand_sub),
    .CLZ_result(sub_shift)
);

assign  exponent_sub              =   fp_rs1[30:23] - sub_shift;
assign  significand_sub_normalize =   significand_sub << sub_shift;

always_comb
begin
    if(significand_sub_normalize[7:6] == 2'b11) // {Guard,Round}
    begin
        fraction_sub = significand_sub_normalize[30:8] + `FRACTION'd1;
    end
    else if(significand_sub_normalize[7:6] == 2'b10)
    begin
        //sticky bit + LSB(round to nearest even)
        if( (|significand_sub_normalize[5:0]) || significand_sub_normalize[8])
        begin
            fraction_sub = significand_sub_normalize[30:8] + `FRACTION'd1;
        end
        else
        begin
            fraction_sub = significand_sub_normalize[30:8];
        end
    end
    else
    begin
        fraction_sub = significand_sub_normalize[30:8];
    end
end

endmodule