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
// 1.recive mmem write request packet and write data to bar register or ddr bram
// 2.recive mmem read  request packet and read data from bar register or ddr bram, send read completion packet
// 3.recive IO write/read request packet and operate I/O(some interfaces with external device,such as cmera link)
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
module bar_engine #(
    parameter DATA_WIDTH = 64
)(
    input wire i_rx_pkt_clk,
    input wire i_tx_pkt_clk,
    input wire i_axi_clk,

    input wire                     wrReq_valid     ,
    input wire [DATA_WIDTH-1:0]    wrReq_data      ,
    input wire [9:0]               wrReq_dwlen     ,
    input wire [31:0]              wrReq_address   ,

    input wire                     rdReq_valid     ,
    input wire [31:0]              rdReq_address   ,


    output wire [31:0]              maxi_lite_awaddr      ,
    input  wire                     maxi_lite_awready     ,
    output wire                     maxi_lite_awvalid     ,

    output wire [DATA_WIDTH -1 :0]  maxi_lite_wdata       ,
    input  wire                     maxi_lite_wready      ,
    output wire [DATA_WIDTH/8 -1:0] maxi_lite_wstrb       ,
    output wire                     maxi_lite_wvalid      ,

    output wire                     maxi_lite_bready     ,
    input  wire [1:0]               maxi_lite_bresp      ,
    input  wire                     maxi_lite_bvalid     ,

    output wire [31:0]              maxi_lite_araddr     ,
    input  wire                     maxi_lite_arready    ,
    output wire                     maxi_lite_arvalid    ,

    input  wire [DATA_WIDTH -1 :0]  maxi_lite_rdata      ,
    output wire                     maxi_lite_rready     ,
    input  wire [1:0]               maxi_lite_rresp      ,
    input  wire                     maxi_lite_rvalid     
    
    
    
    
);
//*******************DEFINE Variables************************************************/
    
    
    
//*******************INSTANCE AREA***************************************************/
    
    
    
//*******************PROGRAM AREA****************************************************/
    
    
    
endmodule