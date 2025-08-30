`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/07/13 07:52
// File Name     : tx_mwr_pkt.v
// Moduel Name   : tx_mwr_pkt
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
module tx_mwr_pkt # (
    parameter DATA_WIDTH = 64 ,
    parameter HEAD_WIDTH = 128 
)(
    input wire i_clk_din     ,
    input wire i_clk_dout    ,
    input wire i_rst         ,

    input wire        i_dma_start  ,
    input wire [31:0] i_dma_dwlen  ,
    input wire [63:0] i_dma_address,
    output wire       o_dma_done   ,

    output reg                      o_dma_dreq    ,
    output wire [15:0]              o_dma_dreq_len,
    input  wire                     i_dma_dvlid,
    input wire [DATA_WIDTH - 1 : 0] i_dma_data,

    input wire [2:0] i_MaxPayloadSize, //3'b000:128byte, 3'b001:256byte, 3'b010:512byte, 3'b011:1024byte
    input wire [15:0] i_req_id ,

    output wire [HEAD_WIDTH - 1 : 0]      head_r_fifo_data ,
    input  wire                           head_r_fifo_en   ,
    output wire                           head_r_empty     ,
    input  wire                           data_r_fifo_en   ,
    output wire [DATA_WIDTH - 1 : 0]      data_r_fifo_data ,
    output wire                           data_r_empty     
);
//*******************DEFINE Variables************************************************/
    
    parameter DATA_DWLEN = DATA_WIDTH/32 ;
    function integer clogb2(input integer size);
        begin
            size = size - 1;
            for(clogb2=0; size>0; clogb2=clogb2+1)begin
                size = size >> 1;
            end
        end
    endfunction
    parameter DATA_DWLEN_BIT = clogb2(DATA_DWLEN);
    reg [31:0] head_dw0,head_dw1 ,head_dw2, head_dw3 ;

    wire [2:0] fmt ;
    wire [4:0] type ;
    wire [2:0] tc;
    wire [2:0] attr ;
    wire th, td, ep;
    wire [1:0] at;
    wire [7:0] tag ;
    wire [7:0] dw_be ;

    

    reg [9:0] pkt_dw_lenth ;
    reg       pkt_last     ;
    reg       pkt_busy     ;

    reg [31:0] dma_dwlen ;
    reg [63:0] dma_address_r ;
    reg [63:0] dma_address ;

    reg [31:0] max_pkt_dw_lenth ;
    reg        dma_start_r ;
    reg        dma_start ;

    reg [2:0] MaxPayloadSize[1:0] ;

    wire almost_data_w_full ;
    wire data_w_fifo_en     ;
    reg [DATA_WIDTH - 1 : 0] data_w_fifo_data ;

    reg head_w_fifo_en ;
    wire [HEAD_WIDTH - 1 : 0] head_w_fifo_data ;

    

    wire                           head_w_full      ;
    reg   [2:0] head_r_empty_sc ;
    

    reg [9:0]         cnt_pkt_dw;
    reg                add_cnt_pkt_dw;
    wire                end_cnt_pkt_dw;
    wire [9:0]           max_cnt_pkt_dw ;

    parameter MAX_CNT_EMPTY = 7 ;




    

    
//*******************INSTANCE AREA***************************************************/
    async_fifo_fwft #(
        .C_WIDTH(HEAD_WIDTH),
        .C_DEPTH(1024)
    ) inst_head_async_fifo_fwft (
        .RD_CLK   (i_clk_dout),
        .RD_RST   (i_rst),
        .WR_CLK   (i_clk_din),
        .WR_RST   (i_rst),
        .WR_DATA  (head_w_fifo_data),
        .WR_EN    (head_w_fifo_en),
        .RD_DATA  (head_r_fifo_data),
        .RD_EN    (head_r_fifo_en  ),
        .WR_FULL  (head_w_full     ),
        .RD_EMPTY (head_r_empty    )
    );
    
    async_fifo_fwft #(
        .C_WIDTH(DATA_WIDTH),
        .C_DEPTH(1024)
    ) inst_data_async_fifo_fwft (
        .RD_CLK   (i_clk_dout),
        .RD_RST   (i_rst),
        .WR_CLK   (i_clk_din),
        .WR_RST   (i_rst),
        .WR_DATA  (data_w_fifo_data),
        .WR_EN    (data_w_fifo_en),
        .RD_DATA  (data_r_fifo_data),
        .RD_EN    (data_r_fifo_en),
        .WR_FULL  (data_w_full),
        .RD_EMPTY (data_r_empty)
    );
    
//*******************PROGRAM AREA****************************************************/
    always @(posedge i_clk_din) begin
        if(i_rst)begin
            MaxPayloadSize[0] <= 'd0;
            MaxPayloadSize[1] <= 'd0;
            dma_start_r         <= 'd0;
            data_w_fifo_data  <= 'd0;
            dma_start         <= 'd0;
        end
        else begin
            MaxPayloadSize[0] <= i_MaxPayloadSize;
            MaxPayloadSize[1] <= MaxPayloadSize[0];
            dma_start_r         <= i_dma_start ;
            data_w_fifo_data  <= i_dma_data ;
            dma_start         <= ~dma_start_r & i_dma_start ;
        end
    end

    always @(posedge i_clk_din) begin
        if(i_rst)
            dma_address_r <= 'd0;
        else if(i_dma_start)
            dma_address_r <= dma_address ;
        else
            dma_address_r <= dma_address_r ;
    end

    always @(posedge i_clk_din) begin
        if(i_rst)
            dma_dwlen <= 'd0;
        else if(i_dma_start) 
            dma_dwlen <= i_dma_dwlen ;
        else if(dma_start | end_cnt_pkt_dw)begin
            if(dma_dwlen > max_pkt_dw_lenth)
                dma_dwlen <= dma_dwlen - max_pkt_dw_lenth;
            else
                dma_dwlen <= 'd0;
        end
        else
            dma_dwlen <= dma_dwlen ;
    end

    
    
    assign max_cnt_pkt_dw = (pkt_dw_lenth >>DATA_DWLEN_BIT) - 1'b1 ;
    always @(posedge i_clk_din) begin
        if(i_rst)
            cnt_pkt_dw <= 10'd0;
        else if(add_cnt_pkt_dw) begin
            if(end_cnt_pkt_dw)
                cnt_pkt_dw <= 10'd0;
            else
                cnt_pkt_dw <= cnt_pkt_dw + 1'b1;
        end
        else
            cnt_pkt_dw <= cnt_pkt_dw;
    end

    always @(posedge i_clk_din) begin
        if(i_rst)
            add_cnt_pkt_dw <= 'd0;
        else
            add_cnt_pkt_dw <= ~almost_data_w_full & i_dma_dvlid;
    end
    assign data_w_fifo_en = add_cnt_pkt_dw ;
    reg pkt_flag;
    always @(posedge i_clk_din) begin
        if(i_rst)
            pkt_flag <= 'd0;
        else if(end_cnt_pkt_dw)
            pkt_flag <= 1'b0;
        else if(add_cnt_pkt_dw)
            pkt_flag <= 1'b1;
        else
            pkt_flag <= pkt_flag ;
    end
    always @(posedge i_clk_din) begin
        if(i_rst)
            o_dma_dreq <= 'd0;
        else if(~pkt_flag && ~head_w_full)
            o_dma_dreq <= 1'b1;
        else if(pkt_flag)
            o_dma_dreq <= 'd0;
        else
            o_dma_dreq <= o_dma_dreq;
    end
    assign end_cnt_pkt_dw = add_cnt_pkt_dw && (cnt_pkt_dw == max_cnt_pkt_dw);
    always @(posedge i_clk_din) begin
        if(i_rst)
            pkt_dw_lenth <= 'd0;
        else if(dma_start | end_cnt_pkt_dw)begin
            if(dma_dwlen >= max_pkt_dw_lenth)
                pkt_dw_lenth <= max_pkt_dw_lenth;
            else
                pkt_dw_lenth <= dma_dwlen;
        end
        else
            pkt_dw_lenth <= pkt_dw_lenth;
    end
    assign o_dma_dreq_len = pkt_dw_lenth ;
    always @(posedge i_clk_din) begin
        if(i_rst)
            dma_address <= 'd0;
        else if(dma_start)
            dma_address <= dma_address_r ;
        else if(end_cnt_pkt_dw)
           dma_address  <= dma_address + max_pkt_dw_lenth ;
        else
            dma_address <= dma_address;
    end

    always @(posedge i_clk_din) begin
        if(i_rst)
            head_w_fifo_en <= 'd0;
        else if(end_cnt_pkt_dw)
            head_w_fifo_en <= 1'b1;
        else
            head_w_fifo_en <= 1'b0;
    end


    always @(posedge i_clk_din) begin
        if(i_rst)
            head_r_empty_sc <= 'd0;
        else
            head_r_empty_sc <= {head_r_empty_sc[1:0], head_r_empty};
    end

    always @(posedge i_clk_din) begin
        if(i_rst)
            pkt_last <= 'd0;
        else if(end_cnt_pkt_dw && dma_dwlen == 'd0)
            pkt_last <= 1'b1;
        else if(~head_r_empty_sc[2] & head_r_empty_sc[1])
            pkt_last <= 'd0;
        else
            pkt_last <= pkt_last ;
    end
    reg [3:0]         cnt_empty;
    reg                 add_cnt_empty;
    wire                end_cnt_empty;
    always @(posedge i_clk_din) begin
        if(i_rst)
            add_cnt_empty <= 'd0;
        else if(pkt_last && ~head_r_empty_sc[2] & head_r_empty_sc[1])
            add_cnt_empty <= 1'b1;
        else if(end_cnt_empty)
            add_cnt_empty <= 1'b0;
        else
            add_cnt_empty <= add_cnt_empty ;
    end
    always @(posedge i_clk_din) begin
        if(i_rst)
            cnt_empty <= 4'd0;
        else if(add_cnt_empty) begin
            if(end_cnt_empty)
                cnt_empty <= 4'd0;
            else
                cnt_empty <= cnt_empty + 1'b1;
        end
        else
            cnt_empty <= cnt_empty;
    end
    assign end_cnt_empty = add_cnt_empty && (cnt_empty == MAX_CNT_EMPTY);
    assign o_dma_done = end_cnt_empty;
    always @(posedge i_clk_din) begin
        
    end
    always @(posedge i_clk_din) begin
        if(i_rst)
            pkt_busy <= 1'b0;
        else if(dma_start)
            pkt_busy <= 1'b1;
        else if(pkt_last && end_cnt_pkt_dw)
            pkt_busy <= 1'b0;
        else
            pkt_busy <= pkt_busy ;
    end
    always @(posedge i_clk_din) begin
        if(i_rst)
            max_pkt_dw_lenth <= 'd0;
        else if(MaxPayloadSize[1] == 3'b000)
            max_pkt_dw_lenth <= 'd32 ;
        else if(MaxPayloadSize[1] == 3'b001)
            max_pkt_dw_lenth <= 'd64 ;
        else if(MaxPayloadSize[1] == 3'b010)
            max_pkt_dw_lenth <= 'd128;
        else if(MaxPayloadSize[1] == 3'b011)
            max_pkt_dw_lenth <= 'd256;
        else
            max_pkt_dw_lenth <= 'd32 ;
    end

    assign fmt = 3'b011 ;
    assign type = 5'd0;
    assign tc = 3'd0;
    assign attr = 3'd0;
    assign th = 1'b0;
    assign td = 1'b0;
    assign ep = 1'b0;

    assign tag = 8'd0;
    assign dw_be = 8'hff;

    always @(posedge i_clk_din) begin
        if(i_rst)begin
            head_dw0 <= 'd0;
            head_dw1 <= 'd0;
            head_dw2 <= 'd0;
            head_dw3 <= 'd0;
        end
        else begin
            head_dw0 <= {fmt,type, 1'b0,tc,1'b0,attr[2],1'b0,th,td,ep,attr[1:0],at,pkt_dw_lenth}    ;
            head_dw1 <= {i_req_id, tag, dw_be}                                                      ;
            head_dw2 <= dma_address[63 : 32]                                                        ;
            head_dw3 <= {dma_address[31 : 2], 2'b00}                                                ;
        end
            
    end
    assign head_w_fifo_data = {head_dw3, head_dw2, head_dw1, head_dw0};
    

    

endmodule