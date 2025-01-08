`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/01/08 09:52
// File Name     : bar_engine.v
// Moduel Name   : bar_engine
// Encoding      : GB2312
// Target Devices: 
// Tool Versions : 
// Called By     : 
// Abstract      : 
//
// Description:
//
// copyRight(c)2025,sichuan xianmei Technology co. Itd..
// All Rights Reserved
//
//***********************************************************************************/
//Modification History:
// 1. initial
//***********************************************************************************/
//**************************
//MODULE DEFINITION
//**************************
module bar_engine (
    input wire i_rx_pkt_clk,
    input wire i_tx_pkt_clk,
    input wire i_clk,

    input wire                     wrReq_valid     ,
    input wire [DATA_WIDTH-1:0]    wrReq_data      ,
    input wire                     wrReq_eof       ,
    input wire [31:0]              wrReq_address   ,

    output wire [31:0]             axi_awaddr      ,
    
);
//*******************DEFINE Variables************************************************/
    
    
    
//*******************INSTANCE AREA***************************************************/
    
    
    
//*******************PROGRAM AREA****************************************************/
    
    
    
endmodule