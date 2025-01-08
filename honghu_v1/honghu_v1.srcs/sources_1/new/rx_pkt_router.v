`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2024/12/19 17:53
// File Name     : rx_pkt_router.v
// Moduel Name   : rx_pkt_router
// Encoding      : GB2312
// Target Devices: 
// Tool Versions : 
// Called By     : 
// Abstract      : 
//
// Description:
//
// copyRight(c)2024,henshi co. Itd..
// All Rights Reserved
//
//***********************************************************************************/
//Modification History:
// 1. initial
//***********************************************************************************/
//**************************
//MODULE DEFINITION
//**************************
module rx_pkt_router #(
    parameter DATA_WIDTH = 64,
    parameter BAR_NUM    = 1
)(
    input wire i_clk,
    input wire i_rst,

    input  wire [DATA_WIDTH-1 : 0]  m_axis_rx_data   ,
    input  wire [7:0]               m_axis_rx_tkeep  ,
    input  wire                     m_axis_rx_tlast  ,
    output wire                     m_axis_rx_tready ,
    input  wire [21:0]              m_axis_rx_tuser  ,
    input  wire                     m_axis_rx_tvalid ,

    output wire                      rx_bar0_valid       ,
    output wire                      rx_bar0_sof         ,
    output wire [3:0]                rx_bar0_sof_index   ,
    output wire                      rx_bar0_eof         ,
    output wire [3:0]                rx_bar0_eof_index   ,
    output wire [DATA_WIDTH-1 : 0]   rx_bar0_data        ,

    output wire                      rx_bar1_valid       ,
    output wire                      rx_bar1_sof         ,
    output wire [3:0]                rx_bar1_sof_index   ,
    output wire                      rx_bar1_eof         ,
    output wire [3:0]                rx_bar1_eof_index   ,
    output wire [DATA_WIDTH-1 : 0]   rx_bar1_data        ,

    output wire                      rx_bar2_valid       ,
    output wire                      rx_bar2_sof         ,
    output wire [3:0]                rx_bar2_sof_index   ,
    output wire                      rx_bar2_eof         ,
    output wire [3:0]                rx_bar2_eof_index   ,
    output wire [DATA_WIDTH-1 : 0]   rx_bar2_data        ,

    output wire                      rx_bar3_valid       ,
    output wire                      rx_bar3_sof         ,
    output wire [3:0]                rx_bar3_sof_index   ,
    output wire                      rx_bar3_eof         ,
    output wire [3:0]                rx_bar3_eof_index   ,
    output wire [DATA_WIDTH-1 : 0]   rx_bar3_data        ,

    output wire                      rx_bar4_valid       ,
    output wire                      rx_bar4_sof         ,
    output wire [3:0]                rx_bar4_sof_index   ,
    output wire                      rx_bar4_eof         ,
    output wire [3:0]                rx_bar4_eof_index   ,
    output wire [DATA_WIDTH-1 : 0]   rx_bar4_data        ,

    output wire                      rx_bar5_valid       ,
    output wire                      rx_bar5_sof         ,
    output wire [3:0]                rx_bar5_sof_index   ,
    output wire                      rx_bar5_eof         ,
    output wire [3:0]                rx_bar5_eof_index   ,
    output wire [DATA_WIDTH-1 : 0]   rx_bar5_data
);
//*******************DEFINE Variables************************************************/
    parameter IDLE = 4'b0000;
    parameter FIRST_CYCLE = 4'b0001;
    parameter MIDDLE_CYCLE = 4'b0010;
    parameter LAST_CYCLE   = 4'b0100;
    parameter SINGLE_CYCLE = 4'b0101;
    parameter STRADDLE_CYCLE = 4'b0110;
    
    wire        rx_sof_flag         ;
    wire        rx_eof_flag         ;
    wire [3:0]  rx_sof_byte_index   ;
    wire [3:0]  rx_eof_byte_index   ;
    wire [7:0]  rx_bar_hit          ;
    wire        rx_err_fwd          ;
    wire        rx_err_ecrc         ;

    reg [3:0] state,next_state;
    
    reg [3:0]               rx_sof_byte_index_r   ;
    reg [3:0]               rx_eof_byte_index_r   ;
    reg [7:0]               rx_bar_hit_r          ;
    reg [DATA_WIDTH-1 : 0]  m_axis_rx_data_r      ;
//*******************INSTANCE AREA***************************************************/
    
    
    
//*******************PROGRAM AREA****************************************************/
    //asserted when a packet is ending
    assign rx_eof_flag          = m_axis_rx_tuser[21]       ;
    //Indicates byte location of start of new packet
    assign rx_eof_byte_index    = m_axis_rx_tuser[20:17]    ;
    //asserted when a new packet is present
    assign rx_sof_flag          = m_axis_rx_tuser[14]       ;
    //Indicates byte location of end of the packet
    assign rx_sof_byte_index    = m_axis_rx_tuser[13:10]    ;
    /*Indicates BAR(s) targeted by the current receive transaction. Asserted from 
    the beginning of thepacket to m_axis_rx_tlast.
    bit0 ~ bit5 : bar0 ~bar5
    bit6        : Expansion ROW Address
    bit7        : is reserved for future use
    */
    assign rx_bar_hit           = m_axis_rx_tuser[9:2]      ;
    /* **************not understand************* */
    assign rx_err_fwd           = m_axis_rx_tuser[1]        ;
    assign rx_err_ecrc          = m_axis_rx_tuser[0]        ;

    always @(posedge i_clk) begin
        if(i_rst)
            state <=`DLY IDLE ;
        else
            state <=`DLY next_state;
    end

    always @(*) begin
        case (state)
            IDLE:begin
                if(rx_sof_flag & m_axis_rx_tvalid)begin
                    if(rx_eof_flag && rx_eof_byte_index > rx_sof_byte_index)
                        next_state = SINGLE_CYCLE;
                    else if(~rx_eof_flag)
                        next_state = FIRST_CYCLE;
                    else
                        next_state = IDLE;
                end
                else
                    next_state = IDLE ;
            end 
            SINGLE_CYCLE : begin
                if(rx_sof_flag & m_axis_rx_tvalid)begin
                    if(rx_eof_flag && rx_eof_byte_index > rx_sof_byte_index)
                        next_state = SINGLE_CYCLE;
                    else if(~rx_eof_flag)
                        next_state = FIRST_CYCLE;
                    else
                        next_state = IDLE;
                end
                else
                    next_state = IDLE ;
            end
            FIRST_CYCLE : begin
                if(rx_eof_flag)begin
                    if(rx_sof_flag && rx_eof_byte_index > rx_sof_byte_index)
                        next_state = IDLE;
                    else
                        next_state = LAST_CYCLE;
                end
                else
                    next_state = MIDDLE_CYCLE;
            end
            MIDDLE_CYCLE :begin
                if(rx_eof_flag)begin
                    if(rx_sof_flag && rx_eof_byte_index > rx_sof_byte_index)
                        next_state = IDLE;
                    else
                        next_state = LAST_CYCLE;
                end
                else
                    next_state = state;
            end
            LAST_CYCLE :begin
                if(m_axis_rx_tvalid)
                    next_state = FIRST_CYCLE;
                else
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    assign m_axis_rx_tready = (state == FIRST_CYCLE || state == MIDDLE_CYCLE) && rx_eof_flag &&
                            rx_sof_flag && rx_eof_byte_index < rx_sof_byte_index ? 1'b0 : 1'b1;
    
    always @(posedge i_clk) begin
        if(i_rst)begin
            rx_sof_byte_index_r <= 'd0 ;
            rx_eof_byte_index_r <= 'd0 ;
            rx_bar_hit_r        <= 'd0 ;
            m_axis_rx_data_r    <= 'd0 ;
        end
        else begin
            rx_sof_byte_index_r <= rx_sof_byte_index ;
            rx_eof_byte_index_r <= rx_eof_byte_index ;
            rx_bar_hit_r        <= rx_bar_hit        ;
            m_axis_rx_data_r    <= m_axis_rx_data    ;
        end
    end
    
    assign rx_bar0_valid     = rx_bar_hit_r != 8'd1 ? 'd0 : state != IDLE ;
    assign rx_bar0_sof       = rx_bar_hit_r != 8'd1 ? 'd0 : state == FIRST_CYCLE || state == SINGLE_CYCLE;
    assign rx_bar0_sof_index = rx_bar_hit_r != 8'd1 ? 'd0 : rx_sof_byte_index_r ;
    assign rx_bar0_eof       = rx_bar_hit_r != 8'd1 ? 'd0 : state == LAST_CYCLE || state == SINGLE_CYCLE;
    assign rx_bar0_eof_index = rx_bar_hit_r != 8'd1 ? 'd0 : rx_eof_byte_index_r  ;
    assign rx_bar0_data      = rx_bar_hit_r != 8'd1 ? 'd0 : m_axis_rx_data_r     ;

    assign rx_bar1_valid     = rx_bar_hit_r != 8'd2 ? 'd0 : state != IDLE ;
    assign rx_bar1_sof       = rx_bar_hit_r != 8'd2 ? 'd0 : state == FIRST_CYCLE || state == SINGLE_CYCLE;
    assign rx_bar1_sof_index = rx_bar_hit_r != 8'd2 ? 'd0 : rx_sof_byte_index_r ;
    assign rx_bar1_eof       = rx_bar_hit_r != 8'd2 ? 'd0 : state == LAST_CYCLE || state == SINGLE_CYCLE;
    assign rx_bar1_eof_index = rx_bar_hit_r != 8'd2 ? 'd0 : rx_eof_byte_index_r  ;
    assign rx_bar1_data      = rx_bar_hit_r != 8'd2 ? 'd0 : m_axis_rx_data_r     ;

    assign rx_bar2_valid     = rx_bar_hit_r != 8'd4 ? 'd0 : state != IDLE ;
    assign rx_bar2_sof       = rx_bar_hit_r != 8'd4 ? 'd0 : state == FIRST_CYCLE || state == SINGLE_CYCLE;
    assign rx_bar2_sof_index = rx_bar_hit_r != 8'd4 ? 'd0 : rx_sof_byte_index_r ;
    assign rx_bar2_eof       = rx_bar_hit_r != 8'd4 ? 'd0 : state == LAST_CYCLE || state == SINGLE_CYCLE;
    assign rx_bar2_eof_index = rx_bar_hit_r != 8'd4 ? 'd0 : rx_eof_byte_index_r  ;
    assign rx_bar2_data      = rx_bar_hit_r != 8'd4 ? 'd0 : m_axis_rx_data_r     ;

    assign rx_bar3_valid     = rx_bar_hit_r != 8'd8 ? 'd0 : state != IDLE ;
    assign rx_bar3_sof       = rx_bar_hit_r != 8'd8 ? 'd0 : state == FIRST_CYCLE || state == SINGLE_CYCLE;
    assign rx_bar3_sof_index = rx_bar_hit_r != 8'd8 ? 'd0 : rx_sof_byte_index_r ;
    assign rx_bar3_eof       = rx_bar_hit_r != 8'd8 ? 'd0 : state == LAST_CYCLE || state == SINGLE_CYCLE;
    assign rx_bar3_eof_index = rx_bar_hit_r != 8'd8 ? 'd0 : rx_eof_byte_index_r  ;
    assign rx_bar3_data      = rx_bar_hit_r != 8'd8 ? 'd0 : m_axis_rx_data_r     ;

    assign rx_bar4_valid     = rx_bar_hit_r != 8'd16 ? 'd0 : state != IDLE ;
    assign rx_bar4_sof       = rx_bar_hit_r != 8'd16 ? 'd0 : state == FIRST_CYCLE || state == SINGLE_CYCLE;
    assign rx_bar4_sof_index = rx_bar_hit_r != 8'd16 ? 'd0 : rx_sof_byte_index_r ;
    assign rx_bar4_eof       = rx_bar_hit_r != 8'd16 ? 'd0 : state == LAST_CYCLE || state == SINGLE_CYCLE;
    assign rx_bar4_eof_index = rx_bar_hit_r != 8'd16 ? 'd0 : rx_eof_byte_index_r  ;
    assign rx_bar4_data      = rx_bar_hit_r != 8'd16 ? 'd0 : m_axis_rx_data_r     ;

    assign rx_bar5_valid     = rx_bar_hit_r != 8'd32 ? 'd0 : state != IDLE ;
    assign rx_bar5_sof       = rx_bar_hit_r != 8'd32 ? 'd0 : state == FIRST_CYCLE || state == SINGLE_CYCLE;
    assign rx_bar5_sof_index = rx_bar_hit_r != 8'd32 ? 'd0 : rx_sof_byte_index_r ;
    assign rx_bar5_eof       = rx_bar_hit_r != 8'd32 ? 'd0 : state == LAST_CYCLE || state == SINGLE_CYCLE;
    assign rx_bar5_eof_index = rx_bar_hit_r != 8'd32 ? 'd0 : rx_eof_byte_index_r  ;
    assign rx_bar5_data      = rx_bar_hit_r != 8'd32 ? 'd0 : m_axis_rx_data_r     ;
endmodule