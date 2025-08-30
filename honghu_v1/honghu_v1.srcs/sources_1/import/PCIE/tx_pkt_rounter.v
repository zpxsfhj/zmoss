`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/07/27 21:18
// File Name     : tx_pkt_rounter.v
// Moduel Name   : tx_pkt_rounter
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
module tx_pkt_rounter #(
    parameter DATA_WIDTH = 65 ,
    parameter HEAD_WIDTH = 128 
)(
    input wire  i_clk,
    input wire  i_rst,

    output wire                           s0_head_r_fifo_en   ,
    input  wire [HEAD_WIDTH - 1 : 0]      s0_head_r_fifo_data ,
    input  wire                           s0_head_r_empty     ,
    output wire                           s0_data_r_fifo_en   ,
    input  wire [DATA_WIDTH - 1 : 0]      s0_data_r_fifo_data ,
    input  wire                           s0_data_r_empty     ,

    output wire                           s1_head_r_fifo_en   ,
    input  wire [HEAD_WIDTH - 1 : 0]      s1_head_r_fifo_data ,
    input  wire                           s1_head_r_empty     ,
    output wire                           s1_data_r_fifo_en   ,
    input  wire [DATA_WIDTH - 1 : 0]      s1_data_r_fifo_data ,
    input  wire                           s1_data_r_empty     ,


    input wire                           m_tx_ready     ,
    output reg  [DATA_WIDTH/8 - 1 : 0]   m_tx_tkeep     ,
    output reg                           m_tx_tlast     ,
    output reg [3:0]                     m_tx_tuser     ,
    output reg                           m_tx_valid     ,
    output reg  [DATA_WIDTH - 1: 0]      m_tx_data       
    
);
//*******************DEFINE Variables************************************************/
    parameter MAX_NUM_PKT = 16 ;
    parameter  IDLE = 0    ;
    parameter ARBIT = 1    ;
    parameter HEAD_SEND0 = 2 ;
    parameter HEAD_SEND1 = 3 ;
    parameter DATA_SEND  = 4 ;
    parameter PKT_NUM_ADD = 5 ;

    reg [2:0] state, next_state ;


    reg [1:0] send_mark ;
    reg [7:0] send_port ;

    wire [1:0] tx_valid_vector ;
    
    assign tx_valid_vector = {s0_head_r_empty, s1_head_r_empty};

    reg [1:0] pkt_send_flag ;

    reg [7:0] pkt_send_num ;

    
//*******************PROGRAM AREA****************************************************/
    always @(posedge i_clk) begin
        if(i_rst)
            state <= ARBIT ;
        else
            state <= next_state ;
    end
    always @(*) begin
        case (state)
            IDLE:begin
                if(m_tx_ready)
                    next_state = HEAD_SEND0 ;
                else
                    next_state = state   ;
            end 
            ARBIT: begin
                if(tx_valid_vector != 0)
                    next_state = IDLE ;
                else
                    next_state = state ;
            end
            HEAD_SEND0: next_state = HEAD_SEND1;
            HEAD_SEND1: begin 
                if(m_tx_ready)
                    next_state = DATA_SEND ;
                else
                    next_state = state ;

            end
            DATA_SEND : begin
                if(s0_data_r_fifo_data[DATA_WIDTH - 1] && pkt_send_flag[0])
                    next_state = PKT_NUM_ADD ;
                if(s1_data_r_fifo_data[DATA_WIDTH - 1] && pkt_send_flag[1])
                    next_state = PKT_NUM_ADD ;
                else
                    next_state = state ;
            end
            PKT_NUM_ADD : begin
                if(pkt_send_num < MAX_NUM_PKT)begin
                    if(pkt_send_flag[0] && s0_head_r_empty )
                        next_state = IDLE ;
                    else if(pkt_send_flag[1] && s1_head_r_empty)
                        next_state = IDLE ;
                    else
                        next_state = ARBIT ;
                end
                else
                    next_state = ARBIT ;
            end
            default: ;
        endcase
    end
    
    always @(posedge i_clk) begin
        if(i_rst)
            pkt_send_flag <= 'd0;
        else if(state == ARBIT)begin
            if(tx_valid_vector & ~send_mark > 0)
                pkt_send_flag <= tx_valid_vector & ~send_mark ;
            else
                pkt_send_flag <= tx_valid_vector;
        end
    end
    always @(posedge i_clk) begin
        if(i_rst)
            pkt_send_num <= 'd0;
        else if(state == PKT_NUM_ADD )begin
            if(m_tx_valid && pkt_send_num < MAX_NUM_PKT)
                pkt_send_num <= 'd0;
            else
                pkt_send_num <= pkt_send_num + 1;
        end
        else 
            pkt_send_num <= pkt_send_num ;
    end
    always @(posedge i_clk) begin
        if(i_rst)
            m_tx_data <= 'd0;
        else if(state == HEAD_SEND0)begin
            if(pkt_send_flag[0])
                m_tx_data <= s0_head_r_fifo_data[DATA_WIDTH-2 : 0] ;
            else
                m_tx_data <= s1_head_r_fifo_data[DATA_WIDTH-2 : 0] ;
        end
        else if(state == HEAD_SEND1)begin
            if(pkt_send_flag[0])
                m_tx_data <= {s0_data_r_fifo_data[4*8 +:8],s0_data_r_fifo_data[5*8 +:8],
                            s0_data_r_fifo_data[6*8 +:8],s0_data_r_fifo_data[7*8 +:8],
                            s0_head_r_fifo_data[95:64]
                            };
            else
                m_tx_data <= s1_head_r_fifo_data[(DATA_WIDTH-1)*2 - 1 : DATA_WIDTH-1] ;
        end
        else if(state == DATA_SEND)begin
            if(pkt_send_flag[0])
                m_tx_data <= s0_data_r_fifo_data[DATA_WIDTH-2 : 0];
            else
                m_tx_data <= s1_data_r_fifo_data[DATA_WIDTH-2 : 0];
        end
        else
            m_tx_data <= m_tx_data ;
    end
    always @(posedge i_clk ) begin
        if(i_rst)
            m_tx_tlast <= 1'b0 ;
        else if(s0_head_r_fifo_en)
            m_tx_tlast <= 1'b1;
        else if(s1_head_r_fifo_en)
            m_tx_tlast <= 1'b1;
        else
            m_tx_tlast <= 1'b0 ;
    end

    always @(posedge i_clk) begin
        m_tx_tkeep <= {(DATA_WIDTH/8){1'b1}};
        m_tx_tuser <= 4'hf ;
    end

    always @(posedge i_clk) begin
        if(i_rst)
            m_tx_valid <= 1'b0;
        else if(state == HEAD_SEND0)
            m_tx_valid <= 1'b1;
        else if(s0_head_r_fifo_en | s1_head_r_fifo_en)
            m_tx_valid <= 1'b0;
        else
            m_tx_valid <= m_tx_valid ;
    end

    assign s0_data_r_fifo_en = pkt_send_flag[0] && (state == HEAD_SEND1 ||state == DATA_SEND ) && m_tx_ready;
    assign s1_data_r_fifo_en = pkt_send_flag[1] && ~pkt_send_flag[0] && state == DATA_SEND && m_tx_ready;

    assign s0_head_r_fifo_en = s0_data_r_fifo_en && s0_data_r_fifo_data[DATA_WIDTH - 1] ;
    assign s1_head_r_fifo_en = s1_data_r_fifo_en && s1_data_r_fifo_data[DATA_WIDTH - 1] ;

endmodule