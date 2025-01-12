`include "../include/def.svh"

`include "CPU.sv"
`include "SRAM_wrapper.sv"

module top (
    input logic clk,
    input logic rst
);

logic [`InstructionAddrBus] imem_addr;
logic [    `InstructionBus] imem_rdata;

// logic                       DM_CEB;
logic                       DM_CS;
// logic                       DM_WEB;
logic                       DM_OE;
logic [            `WEBBus] DM_WEB;
// logic [           `BWEBBus] DM_BWEB;
logic [       `DataAddrBus] dmem_addr;
logic [           `DataBus] dmem_wdata;
logic [           `DataBus] dmem_rdata;

CPU i_CPU (
    .clk(clk),
    .rst(rst),

    .Instruction_addr(imem_addr),
    .Instruciton_data(imem_rdata),

    // .DM_CEB(DM_CEB),
    // .DM_WEB(DM_WEB),
    // .DM_BWEB(DM_BWEB),
    .DM_CS(DM_CS),
    .DM_OE(DM_OE),
    .DM_WEB(DM_WEB),
    .Data_addr(dmem_addr),
    .Data_out(dmem_wdata),
    .Data_in(dmem_rdata)
);

// SRAM_wrapper IM1 (
//     .CLK(~clk),                 //System clock
//     .RST(rst),                  
//     .CEB(1'b0),                 //Chip enable (active low)
//     .WEB(1'b1),                 //read:active high , write:active low
//     .BWEB(32'hffff_ffff),       //Bit write enable (active low)
//     .A(imem_addr[15:2]),        //Address
//     .DI(`ZeroWord),             //Data input
//     .DO(imem_rdata)             //Data output
// );

// SRAM_wrapper DM1 (
//     .CLK(~clk),                 //System clock
//     .RST(rst),
//     .CEB(DM_CEB),               //Chip enable (active low)
//     .WEB(DM_WEB),               //read:active high , write:active low
//     .BWEB(DM_BWEB),             //Bit write enable (active low)
//     .A(dmem_addr[15:2]),        //Address
//     .DI(dmem_wdata),            //Data input
//     .DO(dmem_rdata)             //Data output
// );

SRAM_wrapper IM1(
    .CK(~clk),                     //System clock
    .CS(1'b1),                     //Chip select (active high)
    .OE(1'b1),                     //Output enable (active high)
    .WEB(4'b1111),                 //Write enable (active low)
    .A(imem_addr[15:2]),           //Address
    .DI(`ZeroWord),                //Data input
    .DO(imem_rdata)                //Data output
);

SRAM_wrapper DM1(
    .CK(~clk),                     //System clock
    .CS(DM_CS),                    //Chip select (active high)
    .OE(DM_OE),                    //Output enable (active high)
    .WEB(~DM_WEB),                 //Write enable (active low)
    .A(dmem_addr[15:2]),           //Address
    .DI(dmem_wdata),               //Data input
    .DO(dmem_rdata)                //Data output
);

endmodule