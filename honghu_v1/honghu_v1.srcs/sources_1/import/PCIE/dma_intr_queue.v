`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/07/06 20:54
// File Name     : dma_intr_queue.v
// Moduel Name   : dma_intr_queue
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
module dma_intr_queue (
    input wire i_clk    ,
    input wire i_rst    ,

    //interrup interface
    //interrupt request signal
    output reg          cfg_interrupt           ,
    //interrupt ready
    input  wire         cfg_interrupt_rdy       ,
    //be used to    Multi-Vector Interrupts
    output wire [7:0]   cfg_interrupt_di        ,
    input wire [2:0]    cfg_interrupt_mmenable  ,
    input wire          cfg_interrupt_msienable ,

    //interupt status
    output reg [31:0]   interrupt_status,
    //interrupt message queue read 
    input  wire         c2h_fifo_rd_en  ,
    output wire [63:0]  c2h_fifo_rd_data, // {24'd0,l_s,chn,len}

    input   wire        chn0_req_tx_len_valid   ,
    input   wire [31:0] chn0_req_tx_len         ,
    input   wire [1:0]  chn0_req_tx_status      ,
    output  wire        chn0_req_tx_len_ready   
    
);
//*******************DEFINE Variables************************************************/
    localparam IDLE  =   4'b0001;
    localparam INTRARBIT =   4'b0010;
    localparam INTRC2H =   4'b0100;
    localparam INTRWAIT=   4'b1000;
    
    reg [2:0] state, next_state;

    wire [1:0]ch_valid_vector;

    reg c2h_dma_done_hold ;

    wire c2h_fifo_full;

    reg c2h_fifo_wr_en;

    reg [63:0] c2h_fifo_wr_data ;
    
    wire c2h_fifo_empty ;

    wire [15:0] intr_req ;

    reg [15:0] intr_complete ;
//*******************INSTANCE AREA***************************************************/
    async_fifo_fwft #(
        .C_WIDTH(64),
        .C_DEPTH(128)
    ) 
    async_fifo_fwft_c2h (
        .RD_CLK   (i_clk),
        .RD_RST   (i_rst),
        .WR_CLK   (i_clk),
        .WR_RST   (i_rst),
        .WR_DATA  (c2h_fifo_wr_data),
        .WR_EN    (c2h_fifo_wr_en),
        .RD_DATA  (c2h_fifo_rd_data),
        .RD_EN    (c2h_fifo_rd_en),
        .WR_FULL  (c2h_fifo_full ),
        .RD_EMPTY (c2h_fifo_empty)
    );
    
    
//*******************PROGRAM AREA****************************************************/
    assign chn0_req_tx_len_ready = c2h_fifo_full ;
    assign intr_req = {15'd0,~c2h_fifo_empty};
    always @(posedge i_clk) begin
        if(i_rst)
            c2h_fifo_wr_en <= 1'b0;
        else if(chn0_req_tx_len_valid && chn0_req_tx_len_ready)
            c2h_fifo_wr_en <= 1'b1;
        else
            c2h_fifo_wr_en <= 1'b0;
    end

    always @(posedge i_clk) begin
        if(i_rst)
            c2h_fifo_wr_data <= 'd0;
        else
            c2h_fifo_wr_data <= {24'd0,chn0_req_tx_status,6'd0,chn0_req_tx_len};
    end
    always @(posedge i_clk) begin
        if(i_rst)
            interrupt_status <= 'd0;
        else if(state == INTRARBIT && intr_req > 0)
            interrupt_status <= {16'd0, intr_req};
        else
            interrupt_status <= interrupt_status ;
    end

    always @(posedge i_clk) begin
        if(i_rst)
            cfg_interrupt <= 'd0;
        else if(state == INTRARBIT && intr_req > 0)
            cfg_interrupt <= 1'b1;
        else if(state == INTRC2H && cfg_interrupt_rdy)
            cfg_interrupt <= 1'b0 ;
    end

    always @(posedge i_clk) begin
        if(i_rst)
            intr_complete <= 'd0;
        else if(state == INTRC2H)
            intr_complete <= {interrupt_status[15:1], 1'b0} ;
        else if(state == INTRWAIT && c2h_fifo_rd_en == 1'b1)
            intr_complete <= {intr_complete[15:1], 1'b1};
        else
            intr_complete <= intr_complete ;
    end
    always @(posedge i_clk) begin
        if(i_rst)
            state <= IDLE;
        else
            state <= next_state ;
    end
    always @(*) begin
        case (state)
            IDLE: next_state = INTRARBIT;
            INTRARBIT:begin
                if(intr_req)
                    next_state = INTRC2H ;
                else 
                    next_state = state ;
            end 
            INTRC2H: begin
                if(cfg_interrupt_rdy)
                    next_state = INTRWAIT ;
                else
                    next_state = state ;
            end
            INTRWAIT: begin
                if(intr_complete == interrupt_status)
                    next_state = INTRARBIT ;
                else
                    next_state = state ;
            end
            default: next_state = IDLE ;
        endcase
    end
    assign cfg_interrupt_di = 'd0 ;
endmodule