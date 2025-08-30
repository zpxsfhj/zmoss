`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/07/27 10:14
// File Name     : c2h0_channel.v
// Moduel Name   : c2h0_channel
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
module c2h0_channel #(
    parameter TAP_SEL  =  16,
    parameter BIT_SEL  =  12,
    parameter DATA_WIDTH = 64
)(
    input wire i_clk,
    input wire i_rst,

    input wire        i_dma_en   ,
    input wire [15:0] i_width    ,
    input wire [15:0] i_height   ,
    input wire [15:0] i_bit_mode ,
    input wire [31:0] i_dma_addr ,

    input wire                           i_fval,
    input wire                           i_lval,
    input wire [TAP_SEL*BIT_SEL - 1 : 0] i_data,

    output  reg         o_chn0_req_tx_len_valid  ,
    output  reg [31:0]  o_chn0_req_tx_len         ,
    output  reg  [1:0]  o_chn0_req_tx_status     ,
    input  wire         i_chn0_req_tx_len_ready  ,

    output reg         o_dma_start  ,
    output reg  [31:0] o_dma_dwlen  ,
    output reg  [63:0] o_dma_address,
    input  wire        i_dma_done   ,

    input    wire                      i_dma_dreq,
    input    wire [15:0]               i_dma_dreq_len,
    
    output   reg                       o_dma_dvlid,
    output   reg  [DATA_WIDTH - 1 : 0] o_dma_data
    
);
//*******************DEFINE Variables************************************************/
    reg [15:0] r_width    ;
    reg [15:0] r_height   ;
    reg [15:0] r_bit_mode ;
    reg [31:0] r_dma_addr  ;
    reg        r_dma_en   ;

    reg [15:0] width    ;
    reg [15:0] height   ;
    reg [15:0] bit_mode ;
    reg [31:0] dma_addr  ;
    reg        dma_en   ;
    
    wire  [TAP_SEL*BIT_SEL - 1 : 0] sync_fifo_fwft_din ;
    wire                            sync_fifo_fwft_wr_en ;
    reg                           sync_fifo_fwft_rd_en ;
    wire
     [TAP_SEL*BIT_SEL - 1 : 0] sync_fifo_fwft_dout ;
    wire                          sync_fifo_fwft_full ;
    wire                          sync_fifo_fwft_empty;

    reg                           r1_fval, r2_fval;
    reg                           r1_lval, r2_lval;
    reg [TAP_SEL*BIT_SEL - 1 : 0] r1_data, r2_data;
    
    reg frame_end_flag ;

    reg [15:0]         cnt_dout;
    reg [15:0]         max_cnt_dout ;
    reg                add_cnt_dout;
    wire                end_cnt_dout;

    reg [15:0]         cnt_fifo_dout;
    reg [15:0]         max_cnt_fifo_dout ;
    wire                add_cnt_fifo_dout;
    wire                end_cnt_fifo_dout;
//*******************INSTANCE AREA***************************************************/
    sync_fifo_fwft_d192 sync_fifo_fwft_d192_inst (
        .clk(i_clk),      // input wire clk
        .srst(i_rst),    // input wire srst
        .din(sync_fifo_fwft_din),      // input wire [191 : 0] din
        .wr_en(sync_fifo_fwft_wr_en),  // input wire wr_en
        .rd_en(sync_fifo_fwft_rd_en),  // input wire rd_en
        .dout (sync_fifo_fwft_dout),    // output wire [191 : 0] dout
        .full (sync_fifo_fwft_full ),    // output wire full
        .empty(sync_fifo_fwft_empty)  // output wire empty
    );
    
    
//*******************PROGRAM AREA****************************************************/
    always @(posedge i_clk) begin
        if(i_rst) begin
            r_width    <= 'd0 ;
            r_height   <= 'd0 ;
            r_bit_mode <= 'd0 ;
            r_dma_en   <= 'd0 ;
            r_dma_addr <= 'd0 ;
            dma_en     <= 'd0 ;
        end
        else begin
            r_width    <= i_width    ;
            r_height   <= i_height   ;
            r_bit_mode <= i_bit_mode ;
            r_dma_addr <= i_dma_addr ;
            r_dma_en   <= i_dma_en   ;
            dma_en     <= r_dma_en   ;
        end
    end
    always @(posedge i_clk) begin
        if(i_rst) begin
            width    <= 'd0 ;
            height   <= 'd0 ;
            bit_mode <= 'd0 ;
            dma_addr <= 'd0;
        end
        else if(~dma_en) begin
            width    <= r_width    ;
            height   <= r_height   ;
            bit_mode <= r_bit_mode ;
            dma_addr <= r_dma_addr ;
        end
    end
    
    always @(posedge i_clk) begin
        if(i_rst)begin
            r1_fval <= 'd0 ;
            r1_lval <= 'd0 ;
            r1_data <= 'd0 ;
            r2_fval <= 'd0 ;
            r2_lval <= 'd0 ;
            r2_data <= 'd0 ;

        end
        else begin
            r1_fval <= i_fval ;
            r1_lval <= i_lval ;
            r1_data <= i_data ;
            r2_fval <= r1_fval;
            r2_lval <= r1_lval;
            r2_data <= r1_data;
        end
    end
    assign sync_fifo_fwft_din = r2_data;
    assign sync_fifo_fwft_wr_en = r2_lval & r2_fval ;
    always @(posedge i_clk) begin
        if(i_rst)
            frame_end_flag <= 'd0 ;
        else if(r2_fval & ~r1_fval)
            frame_end_flag <= 1'b1 ;
        else if(sync_fifo_fwft_empty)
            frame_end_flag <= 1'b0 ;
    end
    always @(posedge i_clk) begin
        if(i_rst)
            o_chn0_req_tx_len_valid <= 'd0;
        else if(i_chn0_req_tx_len_ready)
            o_chn0_req_tx_len_valid <= 1'b0;
        /* else if(r_dma_en & ~dma_en)
            o_chn0_req_tx_len_valid <= 1'b1; */
        else if(i_dma_done)
            o_chn0_req_tx_len_valid <= 1'b1;
        else
            o_chn0_req_tx_len_valid <= o_chn0_req_tx_len_valid;

    end

    always @(posedge i_clk) begin
        if(i_rst)
            o_chn0_req_tx_status <= 1'b01;
        /* else if(r_dma_en & ~dma_en)
            o_chn0_req_tx_status <= 2'b01; */
        else if(i_dma_done)
            o_chn0_req_tx_status <= 2'b10;
        else
            o_chn0_req_tx_status <= o_chn0_req_tx_status ;
    end

    always @(posedge i_clk) begin
        if(i_rst)
            o_chn0_req_tx_len <= 'd0;
        else if(r_dma_en & ~dma_en)
            o_chn0_req_tx_len <= (width*height) << (bit_mode != 16'd8);
        else
            o_chn0_req_tx_len <= o_chn0_req_tx_len ;
    end
    
    always @(posedge i_clk) begin
        if(i_rst)
            o_dma_address <= 'd0;
        else if(r_dma_en & ~dma_en)
            o_dma_address <= dma_addr;
        else
            o_dma_address <= o_dma_address ;
    end
    always @(posedge i_clk) begin
        if(i_rst)begin
            o_dma_start <= 1'b0;
            o_dma_dwlen <= 'd0 ;
        end
        else if(r1_fval & ~r2_fval)begin
            o_dma_start <= 1'b1;
            o_dma_dwlen <= o_chn0_req_tx_len >> 2 ;
        end
        else begin
            o_dma_start <= 1'b0 ;
            o_dma_dwlen <= o_dma_dwlen ;
        end
    end
    

    always @(posedge i_clk) begin
        if(i_rst)
            cnt_dout <= 16'd0;
        else if(add_cnt_dout) begin
            if(end_cnt_dout)
                cnt_dout <= 16'd0;
            else
                cnt_dout <= cnt_dout + 1'b1;
        end
        else
            cnt_dout <= cnt_dout;
    end
    always @(posedge i_clk) begin
        if(i_rst)
            add_cnt_dout <= 'd0 ;
        else if(i_dma_dreq)
            add_cnt_dout <= 1'b1;
        else if(end_cnt_dout)
            add_cnt_dout <= 1'b0;
        else 
            add_cnt_dout <= add_cnt_dout ;
    end
    always @(posedge i_clk) begin
        if(i_rst)
            add_cnt_dout <= 'd0 ;
        else if(i_dma_dreq)
            max_cnt_dout <= i_dma_dreq_len - 1'b1;
        else 
            max_cnt_dout <= max_cnt_dout;
    end
    assign end_cnt_dout = add_cnt_dout && (cnt_dout == max_cnt_dout);

    
    always @(posedge i_clk) begin
        if(i_rst)
            cnt_fifo_dout <= 16'd0;
        else if(add_cnt_fifo_dout) begin
            if(end_cnt_fifo_dout)
                cnt_fifo_dout <= 16'd0;
            else
                cnt_fifo_dout <= cnt_fifo_dout + 1'b1;
        end
        else
            cnt_fifo_dout <= cnt_fifo_dout;
    end
    assign add_cnt_fifo_dout = add_cnt_dout;
    always @(posedge i_clk) begin
        if (bit_mode == 16'd8)
            max_cnt_fifo_dout <= TAP_SEL/DATA_WIDTH*8 - 1 ;
        else
            max_cnt_fifo_dout <= TAP_SEL/DATA_WIDTH*16 - 1 ;
    end
    assign end_cnt_fifo_dout = add_cnt_fifo_dout && (cnt_fifo_dout == max_cnt_fifo_dout);
    always @(posedge i_clk) begin
        if(i_rst)
            sync_fifo_fwft_rd_en <= 'd0;
        else
            sync_fifo_fwft_rd_en <=  end_cnt_fifo_dout ;
    end
    always @(posedge i_clk) begin
        if(i_rst)
            o_dma_dvlid <= 1'b0;
        else 
            o_dma_dvlid <= add_cnt_dout ;
    end
    always @(posedge i_clk) begin
        if(i_rst)
            o_dma_data <= 'd0 ;
        else if(bit_mode == 8)begin
            case (cnt_fifo_dout)
                16'd0: o_dma_data <= {sync_fifo_fwft_dout[ 7*12 +: 8],sync_fifo_fwft_dout[ 6*12 +: 8],
                                      sync_fifo_fwft_dout[ 5*12 +: 8],sync_fifo_fwft_dout[ 4*12 +: 8],
                                      sync_fifo_fwft_dout[ 3*12 +: 8],sync_fifo_fwft_dout[ 2*12 +: 8],
                                      sync_fifo_fwft_dout[ 1*12 +: 8],sync_fifo_fwft_dout[ 0*12 +: 8]};
                16'd1: o_dma_data <= {sync_fifo_fwft_dout[15*12 +: 8],sync_fifo_fwft_dout[14*12 +: 8],
                                      sync_fifo_fwft_dout[13*12 +: 8],sync_fifo_fwft_dout[12*12 +: 8],
                                      sync_fifo_fwft_dout[11*12 +: 8],sync_fifo_fwft_dout[10*12 +: 8],
                                      sync_fifo_fwft_dout[ 9*12 +: 8],sync_fifo_fwft_dout[ 8*12 +: 8]};
                default: ;
            endcase
        end
        else begin
            case (cnt_fifo_dout)
                16'd0: o_dma_data <= {sync_fifo_fwft_dout[ 3*12 +: 8],4'd0,sync_fifo_fwft_dout[ 2*12 +: 8],4'd0,
                                      sync_fifo_fwft_dout[ 1*12 +: 8],4'd0,sync_fifo_fwft_dout[ 0*12 +: 8],4'd0};
                16'd1: o_dma_data <= {sync_fifo_fwft_dout[ 7*12 +: 8],4'd0,sync_fifo_fwft_dout[ 6*12 +: 8],4'd0,
                                      sync_fifo_fwft_dout[ 5*12 +: 8],4'd0,sync_fifo_fwft_dout[ 4*12 +: 8],4'd0};
                16'd2: o_dma_data <= {sync_fifo_fwft_dout[11*12 +: 8],4'd0,sync_fifo_fwft_dout[10*12 +: 8],4'd0,
                                      sync_fifo_fwft_dout[ 9*12 +: 8],4'd0,sync_fifo_fwft_dout[ 8*12 +: 8],4'd0 };                      
                16'd3: o_dma_data <= {sync_fifo_fwft_dout[15*12 +: 8],4'd0,sync_fifo_fwft_dout[14*12 +: 8],4'd0,
                                      sync_fifo_fwft_dout[13*12 +: 8],4'd0,sync_fifo_fwft_dout[12*12 +: 8],4'd0};
                default: ;
            endcase
        end
    end
endmodule