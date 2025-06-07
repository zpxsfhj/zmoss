`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/06/01 19:28
// File Name     : status_ctl.v
// Moduel Name   : status_ctl
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
module status_ctl #(
    parameter CLK_FRE = 100 //MHZ
)(
    input wire i_clk,
    input wire i_rst,

    input wire pcie_link_up,
    input wire pcie_app_rdy,

    output wire [3:0] led   
);
//*******************DEFINE Variables************************************************/
    parameter MAX_CNT_500MS = 10e6*500/CLK_FRE ;
    parameter MAX_CNT_1S = 10e9/CLK_FRE ;
    
    reg pcie_link_status ;
    
//*******************INSTANCE AREA***************************************************/
    
    
    
//*******************PROGRAM AREA****************************************************/
    reg [31:0]         cnt_500ms;
    wire                add_cnt_500ms;
    wire                end_cnt_500ms;
    always @(posedge i_clk) begin
        if(i_rst)
            cnt_500ms <= 32'd0;
        else if(add_cnt_500ms) begin
            if(end_cnt_500ms)
                cnt_500ms <= 32'd0;
            else
                cnt_500ms <= cnt_500ms + 1'b1;
        end
        else
            cnt_500ms <= 'd0;
    end
    assign add_cnt_500ms = 1'b1;
    assign end_cnt_500ms = add_cnt_500ms && (cnt_500ms == MAX_CNT_500MS - 1'b1);

    
    always @(posedge i_clk) begin
        if(i_rst)
            pcie_link_status <= 'd0;
        else if(pcie_link_up)begin
            if(end_cnt_500ms)
                pcie_link_status <= ~pcie_link_status;
            else
                pcie_link_status <= pcie_link_status ;
        end
        else 
            pcie_link_status <= pcie_link_status ;
    end
    
endmodule