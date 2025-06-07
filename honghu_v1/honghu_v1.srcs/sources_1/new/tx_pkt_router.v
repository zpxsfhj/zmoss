`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/01/13 10:45
// File Name     : tx_pkt_router.v
// Moduel Name   : tx_pkt_router
// Encoding      : GB2312
// Target Devices: 
// Tool Versions : 
// Called By     : 
// Abstract      : 
//
// Description:
//
// copyRight(c)2025,ZPING Technology co. Itd..
// All Rights Reserved
//
//***********************************************************************************/
//Modification History:
// 1. initial
//***********************************************************************************/
//**************************
//MODULE DEFINITION
//**************************
module tx_pkt_router #(
    parameter DATA_WIDTH = 32,
    parameter PCIE_DATA_WIDTH = 64
)(
    input wire i_clk    ,
    input wire i_rst    ,
    
    input wire i_tx_clk,
    input wire i_tx_rst,

    input wire                              s_axis_tx_tready    ,
    output wire [PCIE_DATA_WIDTH/8 - 1 : 0] s_axis_tx_tkeep     ,
    output wire                             s_axis_tx_tlast     ,
    output wire [3:0]                       s_axis_tx_tuser     ,
    output reg                              s_axis_tx_tvalid    ,
    output reg  [PCIE_DATA_WIDTH - 1: 0]    s_axis_tx_tdata     ,
    //cpld packt
    input wire                      rdCpld_eof      ,
    input wire                      rdCpld_valid    ,
    input wire  [9:0]               rdCpld_dwLen    ,
    input wire  [7:0]               rdCpld_tag      ,
    input wire  [2:0]               rdCpld_TC       ,
    input wire  [2:0]               rdCpld_attr     ,
    input wire  [1:0]               rdCpld_at       ,
    input wire  [11:0]              rdCpld_bytecnt  ,
    input wire  [6:0]               rdCpld_lowaddr  ,
    input wire  [DATA_WIDTH -1 :0]  rdCpld_data     ,
    input wire  [15:0]              rdCpld_reqid    ,
    input wire  [15:0]              rdCpld_cplid    ,
    input wire  [2:0]               rdCpld_status   
    
);
//*******************DEFINE Variables************************************************/
    parameter IDLE    = 0;
    parameter CPL_SEND = 1;
    parameter rd_DMA_H2C = 2;
    parameter wr_DMA_H2C = 3;
    parameter rd_DMA_H2C = 4;
    parameter wr_DMA_H2C = 5;

    
    
//*******************INSTANCE AREA***************************************************/
    
    
    
//*******************PROGRAM AREA****************************************************/
    
    
    
endmodule