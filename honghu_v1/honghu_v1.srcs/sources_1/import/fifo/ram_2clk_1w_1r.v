// -----------------------------------------------------------------------------
// Copyright (c) 2014-2024 All rights reserved
// -----------------------------------------------------------------------------
// Author : youkaiyuan v3eduyky@126.com
// Wechat : 15921999232
// File   : ram_2clk_1w_1r.v
// Create : 2024-08-25 14:58:25
// Revise : 2024-08-25 14:58:25
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------

`timescale 1ns/1ns

module ram_2clk_1w_1r 
    #(
      parameter C_RAM_WIDTH = 32,
      parameter C_RAM_DEPTH = 1024
      )
    (
     input                           CLKA,
     input                           CLKB,
     input                           WEA,
     input [clog2s(C_RAM_DEPTH)-1:0] ADDRA,
     input [clog2s(C_RAM_DEPTH)-1:0] ADDRB,
     input [C_RAM_WIDTH-1:0]         DINA,
     output [C_RAM_WIDTH-1:0]        DOUTB
     );
     `include "functions.vh"
    //Local parameters
    localparam C_RAM_ADDR_BITS = clog2s(C_RAM_DEPTH);
    reg [C_RAM_WIDTH-1:0]            rRAM [C_RAM_DEPTH-1:0];
    reg [C_RAM_WIDTH-1:0]            rDout;   
    assign DOUTB = rDout;
    always @(posedge CLKA) begin
        if (WEA)
            rRAM[ADDRA] <= #1 DINA;
    end
    always @(posedge CLKB) begin
        rDout <= #1 rRAM[ADDRB];
    end
endmodule
