`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2024/12/26 09:12
// File Name     : rx_pkt_realign.v
// Moduel Name   : rx_pkt_realign
// Encoding      : GB2312
// Target Devices: 
// Tool Versions : 
// Called By     : 
// Abstract      : 
//
// Description:
//
// copyRight(c)2024,sichuan xianmei Technology co. Itd..
// All Rights Reserved
//
//***********************************************************************************/
//Modification History:
// 1. initial
//***********************************************************************************/
//**************************
//MODULE DEFINITION
//**************************
module rx_pkt_realign #(
    parameter DATA_WIDTH = 64
)(
    input   wire    i_clk,
    input   wire    i_rst,

    input   wire                      i_rx_in_valid     ,
    input   wire    [DATA_WIDTH -1:0] i_rx_in_data      ,
    input   wire                      i_rx_in_sof       ,
    input   wire    [3:0]             i_rx_in_sof_index ,
    input   wire                      i_rx_in_eof       ,
    input   wire    [3:0]             i_rx_in_eof_index ,

    output  reg                       rx_out_valid    ,
    output  reg                       rx_out_sof      ,
    output  reg                       rx_out_eof      ,
    output  reg 	[3:0]             rx_out_eof_index,
    output  reg 	[DATA_WIDTH -1:0] rx_out_data	     
    
);
//*******************DEFINE Variables************************************************/
    parameter DATA_WIDTH_BYTE = DATA_WIDTH/8;

    //对输入模块的信号进行打拍，有利于时序约束
    reg                      rx_in_valid     ;
    reg                      rx_in_sof       ;
    reg    [3:0]             rx_in_sof_index ;
    reg                      rx_in_eof       ;
    reg    [3:0]             rx_in_eof_index ;
    reg    [DATA_WIDTH -1:0] rx_in_data      ;

    wire [DATA_WIDTH -1:0]     rx_data_swap;
    reg [DATA_WIDTH*2 -1 : 0] rx_data_2r;

    reg rx_in_eof_flag ,realign_flag_r;
    reg [3:0] rx_in_sof_index_r;
    reg [3:0] rx_sof_index_r,rx_sof_index_2r;
    wire [3:0] rx_sof_index;
    reg rx_in_eof_r ;
    reg rx_in_valid_r;
    
    reg [3:0] rx_eof_index_realign;
//*******************INSTANCE AREA***************************************************/
    
    
    
//*******************PROGRAM AREA****************************************************/
    always @(posedge i_clk) begin
        if(i_rst)begin
            rx_in_valid     <= 'd0 ;
            rx_in_sof       <= 'd0 ;
            rx_in_sof_index <= 'd0 ;
            rx_in_eof       <= 'd0 ;
            rx_in_eof_index <= 'd0 ;
            rx_in_data      <= 'd0 ;
        end
        else begin
            rx_in_valid     <= i_rx_in_valid     ;
            rx_in_sof       <= i_rx_in_sof       ;
            rx_in_sof_index <= i_rx_in_sof_index ;
            rx_in_eof       <= i_rx_in_eof       ;
            rx_in_eof_index <= i_rx_in_eof_index ;
            rx_in_data      <= i_rx_in_data      ;
        end
    end
    //调整字节序
    genvar i,j;
    generate
        for(i = 0;i < DATA_WIDTH_BYTE/4 ; i=i+1)begin:swap_loop0
            for (j = 0 ; j < 4 ; j=j+1)begin:swap_loop1
                assign rx_data_swap[8*(i*4 + j) +:8] = rx_in_data[ 8*(i*4 +3 - j) +:8];
            end
        end
    endgenerate
    
    //对输入数据进行移位存储，用于字节对齐
    always @(posedge i_clk) begin
        if(i_rst)
            rx_data_2r <= 'd0;
        else
            rx_data_2r <= {rx_data_swap,rx_data_2r[DATA_WIDTH*2 - 1 : DATA_WIDTH]};
    end

    //rx_sof_index 在rx_valid 期间内有效
    assign rx_sof_index = rx_in_sof ? rx_in_sof_index : rx_in_sof_index_r;
    always @(posedge i_clk) begin
        if(i_rst)
            rx_in_eof_flag <= 1'b0;
        else if(rx_in_valid && rx_in_eof && rx_sof_index <= rx_in_eof_index)
            rx_in_eof_flag <= 1'b1;
        else
            rx_in_eof_flag <= 1'b0 ;
    end

    always @(posedge i_clk) begin
        if(i_rst)
            rx_out_eof <= 1'b0;
        else if(rx_in_eof_flag)
            rx_out_eof <= 1'b1 ;
        else if(rx_in_valid && rx_in_eof && rx_sof_index > rx_in_eof_index)
            rx_out_eof <= 1'b1 ;
        else
            rx_out_eof <= 1'b0;
    end
    reg rx_in_sof_r;

    always @(posedge i_clk) begin
        if(i_rst)begin
            rx_in_eof_r   <= 'd0;
            rx_in_valid_r <= 'd0 ;
            rx_out_valid  <= 'd0;
            rx_in_sof_r   <= 'd0;
            rx_out_sof    <= 'd0;
        end
        else begin
            rx_in_eof_r <= rx_in_eof ;
            rx_in_valid_r <= rx_in_valid & (~rx_in_eof | rx_in_sof);
            rx_out_valid <= rx_in_valid_r | rx_in_eof_flag;
            rx_in_sof_r  <= rx_in_sof ;
            rx_out_sof   <= rx_in_sof_r;

        end
    end

    always @(posedge i_clk) begin
        if(i_rst)
            rx_eof_index_realign <= 'd0;
        else
            rx_eof_index_realign <= rx_in_eof_index - rx_sof_index;
    end
    reg [3:0] rx_eof_index_realign_r ;
    //对齐后的包少一个周期的情况
    always @(posedge i_clk) begin
        if(i_rst)
            rx_out_eof_index <= 'd0;
        else if(rx_in_valid && rx_in_eof && rx_sof_index > rx_in_eof_index)
            rx_out_eof_index <= DATA_WIDTH_BYTE + rx_in_eof_index - rx_sof_index;
        else 
            rx_out_eof_index <= rx_eof_index_realign;
    end

    always @(posedge i_clk) begin
        if(i_rst)
            rx_in_sof_index_r <= 'd0;
        else if(rx_in_valid && rx_in_sof)
            rx_in_sof_index_r <= rx_in_sof_index ;
        else
            rx_in_sof_index_r <= rx_in_sof_index_r;
    end
    always @(posedge i_clk) begin
        if(i_rst)begin
            rx_sof_index_r  <= 'd0;
            rx_sof_index_2r <= 'd0;
        end
        else begin
            rx_sof_index_r  <= rx_sof_index;
            rx_sof_index_2r <= rx_sof_index_r;
        end
    end

    generate
        if(DATA_WIDTH_BYTE > 8)
            always @(*) begin
                case (rx_sof_index_2r)
                    4'd0: rx_out_data = rx_data_2r[DATA_WIDTH - 1    : 0];
                    4'd4: rx_out_data = rx_data_2r[DATA_WIDTH - 1 +4*8 : +4*8];
                    4'd8: rx_out_data = rx_data_2r[DATA_WIDTH - 1 +8*8 : +8*8];
                    4'd12: rx_out_data = rx_data_2r[DATA_WIDTH - 1 +12*8 : +12*8];
                    default: rx_out_data = rx_data_2r[DATA_WIDTH - 1 : 0];
                endcase
            end
        else
            always @(*) begin
                case (rx_sof_index_2r)
                    4'd0: rx_out_data = rx_data_2r[DATA_WIDTH - 1 : 0];
                    4'd4: rx_out_data = rx_data_2r[DATA_WIDTH - 1 +4*8 : 4*8];
                    default: rx_out_data = rx_data_2r[DATA_WIDTH - 1 : 0];
                endcase
            end
    endgenerate

    
endmodule