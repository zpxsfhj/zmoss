`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/01/10 09:16
// File Name     : config_register.v
// Moduel Name   : config_register
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
module config_register #(
    parameter AXIDATA_WIDTH = 32
)(
    input wire i_clk,
    input wire i_rst,

    //slave axi lite interface
    input wire  [31:0]                  saxi_lite_awaddr      ,
    output wire                          saxi_lite_awready     ,
    input wire                          saxi_lite_awvalid     ,

    input  wire [AXIDATA_WIDTH -1 :0]   saxi_lite_wdata       ,
    output wire                          saxi_lite_wready      ,
    input  wire [AXIDATA_WIDTH/8 -1:0]  saxi_lite_wstrb       ,
    input  wire                         saxi_lite_wvalid      ,

    input  wire                         saxi_lite_bready     ,
    output wire [1:0]                   saxi_lite_bresp      ,
    output wire                         saxi_lite_bvalid     ,

    input  wire[31:0]                   saxi_lite_araddr     ,
    output wire                         saxi_lite_arready    ,
    input  wire                         saxi_lite_arvalid    ,

    output reg  [AXIDATA_WIDTH -1 :0]   saxi_lite_rdata      ,
    input  wire                         saxi_lite_rready     ,
    output wire [1:0]                   saxi_lite_rresp      ,
    output wire                         saxi_lite_rvalid     , 

    //config interface
    output reg [31:0]                   o_edge_detect   ,
    output reg [31:0]                   o_smooth_filter ,
    output reg [31:0]                   o_bar_test             
    
);
//*******************DEFINE Variables************************************************/
    parameter IDLE = 0;
    parameter REG_WR_ADDR = 1;
    parameter REG_WR_DATA = 2;
    parameter REG_WR_RESPOND = 3;
    parameter REG_RD_ADDR = 4;
    parameter REG_RD_DATA = 5;

    parameter RESP_OKAY = 3'b000;

    reg [31:0] bar_test ;
    //{28'd0,en[0],operator[2:0]}
    /* 
        operator:
            3'd0:Roberts
            3'd1:Prewitt
            3'd2:Sobel
            3'd3:Laplacian
            3'd4:Canny
            ... :reserve
     */
    reg [31:0] edge_detect;

    //{en[0],window_size[7:0],operator[7:0]}
    /* 
        operator:
            8'd0:mean
            8'd1:median
            8'd2:Gaussian
            ... :reserve
        window_size:
            8'd3:3¡Á3
            8'd5:5¡Á5
            8'd7:7¡Á7
               ...
     */
    reg [31:0] smooth_filter;

    reg [2:0] state,next_state;

    reg [15:0] register_waddr ,register_raddr;

    parameter ADDR_BAR_TEST     = 16'h0001;
    parameter ADDR_EDGE_DETECT  = 16'h0002;
    parameter ADDR_SMOOTH_FILTER  = 16'h0003;
    
    
//*******************INSTANCE AREA***************************************************/
    
    
    
//*******************PROGRAM AREA****************************************************/
    always @(posedge i_clk) begin
        if(i_rst)
            state <= IDLE;
        else
            state <= next_state;
    end
    always @(*) begin
        case (state)
            IDLE: begin
                if(saxi_lite_awvalid)
                    next_state = REG_WR_ADDR;
                else if(saxi_lite_arvalid)
                    next_state = REG_RD_ADDR;
                else
                    next_state = state;
            end
            REG_WR_ADDR:begin
                if(saxi_lite_wvalid)
                    next_state = REG_WR_DATA;
                else
                    next_state = state;
            end
            REG_WR_DATA:
                next_state = REG_WR_RESPOND;
            REG_WR_RESPOND:begin
                if(saxi_lite_bready)
                    next_state = IDLE;
                else
                    next_state = state;
            end 
            REG_RD_ADDR:
                next_state = REG_RD_DATA;
            REG_RD_DATA:begin
                if(saxi_lite_rready)
                    next_state = IDLE;
                else
                    next_state = state;
            end
            default: next_state = IDLE;
        endcase
    end
    assign saxi_lite_awready = state == REG_WR_ADDR;
    assign saxi_lite_wready  = state == REG_WR_DATA;
    assign saxi_lite_bvalid  = state == REG_WR_RESPOND;
    assign saxi_lite_arready = state == REG_RD_ADDR ;
    assign saxi_lite_rvalid  = state == REG_RD_DATA ;

    assign saxi_lite_bresp  = 2'b00;
    assign saxi_lite_rresp   = 2'b00;

    always @(posedge i_clk) begin
        if(i_rst)
            register_waddr <= 'd0;
        else if(state == IDLE && saxi_lite_awvalid == 'd1)
            register_waddr <= saxi_lite_awaddr[15:0] ;
        else
            register_waddr <= register_waddr;
    end
    always @(posedge i_clk) begin
        if(i_rst)
            register_raddr <= 'd0;
        else if(state == IDLE && saxi_lite_arvalid == 'd1)
            register_raddr <= saxi_lite_araddr[15:0] ;
        else
            register_raddr <= register_raddr;
    end


    //configuration register write
    always @(posedge i_clk) begin
        if(i_rst)begin
            bar_test    <= 'd0;
            edge_detect <= 'd0;
            smooth_filter <= 'd0;
        end
        else if(state == REG_WR_ADDR && saxi_lite_wvalid == 'd1)begin
            case (register_waddr)
                ADDR_BAR_TEST       : bar_test      <= saxi_lite_wdata;
                ADDR_EDGE_DETECT    : edge_detect   <= saxi_lite_wdata;
                ADDR_SMOOTH_FILTER  : smooth_filter <= saxi_lite_wdata;
                default: ;
            endcase
        end
        else begin
            bar_test      <= bar_test     ; 
            edge_detect   <= edge_detect  ;
            smooth_filter <= smooth_filter;
        end
    end
    //configuration register read
    always @(posedge i_clk) begin
        if(i_rst)begin
            saxi_lite_rdata <= 'd0;
        end
        else if(state == REG_RD_ADDR && saxi_lite_rvalid == 'd1)begin
            case (register_raddr)
                ADDR_BAR_TEST       :   saxi_lite_rdata <= bar_test     ;
                ADDR_EDGE_DETECT    :   saxi_lite_rdata <= edge_detect  ;
                ADDR_SMOOTH_FILTER  :   saxi_lite_rdata <= smooth_filter;
                default: ;
            endcase
        end
        else begin
            saxi_lite_rdata <= saxi_lite_rdata; 
        end
    end


    //configuration output
    always @(posedge i_clk) begin
        if(i_rst)begin
            o_bar_test      <= 'd0;
            o_edge_detect   <= 'd0;
        end
        else begin
            o_bar_test      <= bar_test     ;
            o_edge_detect   <= edge_detect  ;
            o_smooth_filter <= smooth_filter;
        end
    end
    
    
endmodule