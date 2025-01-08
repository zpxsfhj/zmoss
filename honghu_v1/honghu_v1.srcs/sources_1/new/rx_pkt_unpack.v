`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/01/06 11:21
// File Name     : rx_unpack.v
// Moduel Name   : rx_unpack
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
module rx_pkt_unpack #(
    parameter DATA_WIDTH = 64
)(
    input wire i_clk,
    input wire i_rst,

    input wire        rx_in_valid,
    input wire [DATA_WIDTH-1:0] rx_in_data,
    input wire        rx_in_sof,
    input wire        rx_in_eof,
    input wire [3:0]   rx_in_eof_index,

    output reg                     wrReq_valid     ,
    output reg [DATA_WIDTH-1:0]    wrReq_data      ,
    output reg                     wrReq_eof       ,
    output reg [3:0]               wrReq_lastBe    ,
    output reg [3:0]               wrReq_firstBe   ,
    output reg                     wrReq_fmt       ,
    output reg                     wrReq_type      ,
    output reg [15:0]              wrReq_reqid     ,
    output reg [63:0]              wrReq_address   ,
    output reg [7:0]               wrReq_tag       ,
    output reg [9:0]               wrReq_dwlen     ,
    output reg [2:0]               wrReq_tc        ,
    output reg [2:0]               wrReq_attr      ,
    output reg [1:0]               wrReq_at        ,

    output reg                     rdReq_valid     ,
    output reg [DATA_WIDTH-1:0]    rdReq_data      ,
    output reg                     rdReq_eof       ,
    output reg [3:0]               rdReq_lastBe    ,
    output reg [3:0]               rdReq_firstBe   ,
    output reg                     rdReq_fmt       ,
    output reg                     rdReq_type      ,
    output reg [15:0]              rdReq_reqid     ,
    output reg [63:0]              rdReq_address   ,
    output reg [7:0]               rdReq_tag       ,
    output reg [9:0]               rdReq_dwlen     ,
    output reg [2:0]               rdReq_tc        ,
    output reg [2:0]               rdReq_attr      ,
    output reg [1:0]               rdReq_at 
    
);
//*******************DEFINE Variables************************************************/
    parameter DATA_WIDTH_BYTE = DATA_WIDTH/8;

    localparam PKT_MWR3DW_WDATA = 7'b10_00000;
    localparam PKT_MWR4DW_WDATA = 7'b11_00000;
    localparam PKT_MRD3DW 		= 7'b00_00000;
    localparam PKT_MRD4DW 		= 7'b01_00000;

    reg [4:0]               tlp_type      ;
    reg [1:0]               tlp_fmt       ;
    reg [2:0]               tlp_attr      ;
    reg [2:0]               tlp_tc        ;
    reg [1:0]               tlp_at        ;
    reg [9:0]               tlp_dwlen     ;
    reg [3:0]               tlp_firstBe   ;
    reg [3:0]               tlp_lastBe    ;
    reg [15:0]              tlp_reqid     ;
    reg [7:0]               tlp_tag       ;

    reg [63:0]              tlp_address   ;
    
    reg [4:0]               tlp_type_r      ;
    reg [1:0]               tlp_fmt_r       ;
    reg [2:0]               tlp_attr_r      ;
    reg [2:0]               tlp_tc_r        ;
    reg [1:0]               tlp_at_r        ;
    reg [9:0]               tlp_dwlen_r     ;
    reg [3:0]               tlp_firstBe_r   ;
    reg [3:0]               tlp_lastBe_r    ;
    reg [15:0]              tlp_reqid_r     ;
    reg [7:0]               tlp_tag_r       ;



    wire [DATA_WIDTH - 1: 0] rx_data_swap;
    reg [DATA_WIDTH*2 -1 : 0] rx_data_2r;
    wire [DATA_WIDTH - 1: 0]   rx_data_realign;

    wire data_realign_flag;

    wire rx_data_valid;
    wire rx_in_eof_flag ;

    reg [3:0] rx_out_eof_index ;
    reg [3:0] rx_in_eof_index_r, rx_in_eof_index_rr ;

    reg [1:0] rx_in_valid_r;

    reg [1:0]rx_in_eof_r;
    reg [2:0] rx_in_sof_r;

    wire rx_data_eof; 
//*******************PROGRAM AREA****************************************************/
    //
    genvar i,j;
    generate
        for(i = 0;i < DATA_WIDTH_BYTE/4 ; i=i+1)begin:swap_loop0
            for (j = 0 ; j < 4 ; j=j+1)begin:swap_loop1
                assign rx_data_swap[8*(i*4 + j) +:8] = rx_in_data[ 8*(i*4 +3 - j) +:8];
            end
        end
    endgenerate

    always @(posedge i_clk) begin
        if(i_rst)begin
            tlp_type      <= 'd0;
            tlp_fmt       <= 'd0;
            tlp_attr      <= 'd0;
            tlp_tc        <= 'd0;
            tlp_at        <= 'd0;
            tlp_dwlen     <= 'd0;
            tlp_firstBe   <= 'd0;
            tlp_lastBe    <= 'd0;
            tlp_tag       <= 'd0;
            tlp_reqid     <= 'd0; 
        end
        else if(rx_in_valid & rx_in_sof)begin
            tlp_type      <= rx_in_data[4:0];
            tlp_fmt       <= rx_in_data[6:5];
            tlp_attr      <= {rx_in_data[10],rx_in_data[21:20]};
            tlp_tc        <= rx_in_data[14:12];
            tlp_at        <= rx_in_data[19:18];
            tlp_dwlen     <= {rx_in_data[17:16],rx_in_data[31:24]};
            tlp_firstBe   <= rx_in_data[59:56];
            tlp_lastBe    <= rx_in_data[63:60];
            tlp_reqid     <= {rx_in_data[39:32],rx_in_data[47:40]};
            tlp_tag       <= rx_in_data[55:48];
        end
    end
    always @(posedge i_clk) begin
        if(i_rst)begin
            tlp_type_r    <= 'd0;
            tlp_fmt_r     <= 'd0;
            tlp_attr_r    <= 'd0;
            tlp_tc_r      <= 'd0;
            tlp_at_r      <= 'd0;
            tlp_dwlen_r   <= 'd0;
            tlp_firstBe_r <= 'd0;
            tlp_lastBe_r  <= 'd0;
            tlp_reqid_r   <= 'd0;
            tlp_tag_r     <= 'd0;
        end
        else begin
            tlp_type_r    <= tlp_type   ;
            tlp_fmt_r     <= tlp_fmt    ;
            tlp_attr_r    <= tlp_attr   ;
            tlp_tc_r      <= tlp_tc     ;
            tlp_at_r      <= tlp_at     ;
            tlp_dwlen_r   <= tlp_dwlen  ;
            tlp_firstBe_r <= tlp_firstBe;
            tlp_lastBe_r  <= tlp_lastBe ;
            tlp_reqid_r   <= tlp_reqid  ;
            tlp_tag_r     <= tlp_tag    ;
        end
    end
    always @(posedge i_clk) begin
        if(i_rst)
            rx_data_2r <= 'd0;
        else if(rx_in_valid)
            rx_data_2r <= {rx_data_swap,rx_data_2r[DATA_WIDTH*2 -1 :DATA_WIDTH]};
        else
            rx_data_2r <= rx_data_2r ;
    end
    assign data_realign_flag = ~tlp_fmt_r[0];
    

    always @(posedge i_clk) begin
        if(i_rst)begin
            rx_in_eof_index_r  <= 'd0;
            rx_in_eof_index_rr <= 'd0;
        end
        else begin
            rx_in_eof_index_r  <= rx_in_eof_index ;
            rx_in_eof_index_rr <= rx_in_eof_index_r ;
        end
    end
    always @(posedge i_clk) begin
        if(i_rst)begin
            rx_in_valid_r <= 'd0;
            rx_in_eof_r   <= 'd0;
            rx_in_sof_r   <= 'd0;
        end
        else begin
            rx_in_valid_r <= {rx_in_valid_r[0],rx_in_valid};
            rx_in_eof_r   <= {rx_in_eof_r[0], rx_in_eof & rx_in_valid};
            rx_in_sof_r   <= {rx_in_sof_r[1:0], rx_in_sof & rx_in_valid};
        end
    end
    generate
        if(DATA_WIDTH == 64)begin:DATA_WIDTH0
            always @(posedge i_clk) begin
                if(i_rst)
                    tlp_address <= 'd0;
                else if(rx_in_valid_r[0] & rx_in_sof_r[0] & tlp_fmt[0])
                    tlp_address <= {2'd1,rx_in_data[39:32],rx_in_data[47:40], rx_in_data[55:48],rx_in_data[63:56],
                                    rx_in_data[7:0],rx_in_data[15:8], rx_in_data[23:16],rx_in_data[31:26]};
                else if(rx_in_valid_r[0] & rx_in_sof_r[0] & ~tlp_fmt[0])
                    tlp_address <= {34'd1,rx_in_data[7:0],rx_in_data[15:8], rx_in_data[23:16],rx_in_data[31:26]};
                else
                    tlp_address <= tlp_address;
            end
            assign rx_data_valid = tlp_dwlen_r == 16'd0 ? rx_in_sof_r[1] & rx_in_valid_r[1] 
                        : (tlp_fmt_r[0] ? (~rx_in_sof_r[1] | ~rx_in_sof_r[2]) & rx_in_valid_r[1]
                            : ~rx_in_sof_r[1] & rx_in_valid_r[1]);
            assign rx_data_realign = data_realign_flag ? rx_data_2r[32 +:DATA_WIDTH]:rx_data_2r[0 +:DATA_WIDTH];
            always @(posedge i_clk) begin
                if(i_rst)
                    rx_out_eof_index <= 'd0;
                else if(rx_in_valid_r[0] && rx_in_eof_r[0] && data_realign_flag && 4 > rx_in_eof_index)
                    rx_out_eof_index <= DATA_WIDTH_BYTE + rx_in_eof_index - 4;
                else 
                    rx_out_eof_index <= rx_in_eof_index_r;
            end
            assign rx_in_eof_flag = ~(rx_data_valid && rx_in_eof_r[1] && data_realign_flag &&  4 > rx_in_eof_index_rr);
            assign rx_data_eof    = rx_data_valid && (rx_in_eof_r[0] && data_realign_flag &&  12 > rx_in_eof_index_r
                                                    || rx_in_eof_flag);
        end
        else if(DATA_WIDTH == 128)begin:DATA_WIDTH1
            always @(posedge i_clk) begin
                if(i_rst)
                    tlp_address <= 'd0;
                else if(rx_in_valid_r[0] & rx_in_sof_r[0] & tlp_fmt[0])
                    tlp_address <= {2'd1,rx_in_data[DATA_WIDTH +12*8 +:8],rx_in_data[DATA_WIDTH +13*8 +:8], 
                                    rx_in_data[DATA_WIDTH +14*8 +:8],rx_in_data[DATA_WIDTH +15*8 +:8],
                                    rx_in_data[DATA_WIDTH + 8*8 +:8],rx_in_data[DATA_WIDTH + 9*8 +:8], 
                                    rx_in_data[DATA_WIDTH +10*8 +:8],rx_in_data[DATA_WIDTH +90 +:6]};
                else if(rx_in_valid_r[0] & rx_in_sof_r[0] & ~tlp_fmt[0])
                    tlp_address <= {34'd1,rx_in_data[DATA_WIDTH + 8*8 +:8],rx_in_data[DATA_WIDTH + 9*8 +:8], 
                                    rx_in_data[DATA_WIDTH +10*8 +:8],rx_in_data[DATA_WIDTH +90 +:6]};
                else
                    tlp_address <= tlp_address;
            end
            assign rx_data_valid = tlp_dwlen_r == 16'd0 ? rx_in_sof_r[1] & rx_in_valid_r[1] 
                        : (tlp_fmt_r[0] ? ~rx_in_sof_r[1] & rx_in_valid_r[1]
                            : rx_in_valid_r[1]);
            assign rx_data_realign = data_realign_flag ? rx_data_2r[96 +:DATA_WIDTH]:rx_data_2r[0 +:DATA_WIDTH];
            assign rx_in_eof_flag = ~(rx_data_valid && rx_in_eof_r[1] && data_realign_flag &&  12 > rx_in_eof_index_rr);
            assign rx_data_eof    = rx_data_valid && (rx_in_eof_r[0] && data_realign_flag &&  12 > rx_in_eof_index_r
                                                    || rx_in_eof_flag);
            always @(posedge i_clk) begin
                if(i_rst)
                    rx_out_eof_index <= 'd0;
                else if(rx_in_valid_r[0] && rx_in_eof_r[0] && data_realign_flag && 12 > rx_in_eof_index)
                    rx_out_eof_index <= DATA_WIDTH_BYTE + rx_in_eof_index - 12;
                else 
                    rx_out_eof_index <= rx_in_eof_index_r;
            end
        end
    endgenerate


    always @(posedge i_clk) begin
        if(i_rst)begin
            wrReq_data    <= 'd0;
            wrReq_eof     <= 'd0;
            wrReq_lastBe  <= 'd0;
            wrReq_firstBe <= 'd0;
            wrReq_fmt     <= 'd0;
            wrReq_type    <= 'd0;
            wrReq_reqid   <= 'd0;
            wrReq_address <= 'd0;
            wrReq_tag     <= 'd0;
            wrReq_dwlen   <= 'd0;
            wrReq_tc      <= 'd0;
            wrReq_attr    <= 'd0;
            wrReq_at      <= 'd0;
            wrReq_valid   <= 'd0;
        end
        else begin
            wrReq_data    <= rx_data_realign      ;
            wrReq_eof     <= rx_data_eof          ;
            wrReq_lastBe  <= tlp_lastBe_r         ;
            wrReq_firstBe <= tlp_firstBe_r        ;
            wrReq_fmt     <= tlp_fmt_r            ;
            wrReq_type    <= tlp_type_r           ;
            wrReq_reqid   <= tlp_reqid_r          ;
            wrReq_address <= tlp_address          ;
            wrReq_tag     <= tlp_tag_r            ;
            wrReq_dwlen   <= tlp_dwlen_r          ;
            wrReq_tc      <= tlp_tc_r             ;
            wrReq_attr    <= tlp_attr_r           ;
            wrReq_at      <= tlp_at_r             ;
            wrReq_valid   <= rx_data_valid 
                && ({tlp_fmt_r,tlp_type_r} == PKT_MWR3DW_WDATA )
                && ({tlp_fmt_r,tlp_type_r} == PKT_MWR4DW_WDATA );
        end
    end

    always @(posedge i_clk) begin
        if(i_rst)begin
            rdReq_data    <= 'd0;
            rdReq_eof     <= 'd0;
            rdReq_lastBe  <= 'd0;
            rdReq_firstBe <= 'd0;
            rdReq_fmt     <= 'd0;
            rdReq_type    <= 'd0;
            rdReq_reqid   <= 'd0;
            rdReq_address <= 'd0;
            rdReq_tag     <= 'd0;
            rdReq_dwlen   <= 'd0;
            rdReq_tc      <= 'd0;
            rdReq_attr    <= 'd0;
            rdReq_at      <= 'd0;
            rdReq_valid   <= 'd0;
        end
        else begin
            rdReq_data    <= rx_data_realign      ;
            rdReq_eof     <= rx_data_eof          ;
            rdReq_lastBe  <= tlp_lastBe_r         ;
            rdReq_firstBe <= tlp_firstBe_r        ;
            rdReq_fmt     <= tlp_fmt_r            ;
            rdReq_type    <= tlp_type_r           ;
            rdReq_reqid   <= tlp_reqid_r          ;
            rdReq_address <= tlp_address          ;
            rdReq_tag     <= tlp_tag_r            ;
            rdReq_dwlen   <= tlp_dwlen_r          ;
            rdReq_tc      <= tlp_tc_r             ;
            rdReq_attr    <= tlp_attr_r           ;
            rdReq_at      <= tlp_at_r             ;
            rdReq_valid   <= rx_data_valid 
                && ({tlp_fmt_r,tlp_type_r} == PKT_MRD3DW )
                && ({tlp_fmt_r,tlp_type_r} == PKT_MRD4DW );
        end
    end
endmodule

