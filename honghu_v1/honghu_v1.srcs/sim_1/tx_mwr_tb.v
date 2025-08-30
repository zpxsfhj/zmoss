`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/08/10 02:03
// File Name     : tx_mwr_tb.v
// Moduel Name   : tx_mwr_tb
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
module tx_mwr_tb (
    
);
//*******************DEFINE Variables************************************************/

    parameter DATA_WIDTH = 64 ;

    parameter TAP        = 16  ;
    parameter LINE_GAP   = 200 ;
    parameter IMAG_TYPE  = 5   ;
    parameter YLENGTH    = 512 ;
    parameter XLENGTH    = 512 ;
    
    reg clk_200m ;
    reg sys_rst  ;
    
    reg img_trig ;

    wire                        test_fval ;
    wire                        test_lval ;
    wire    [TAP * 16 - 1 : 0]  test_data ;

    wire        chn0_req_tx_len_valid   ;
    wire [31:0] chn0_req_tx_len         ;
    wire [1:0]  chn0_req_tx_status      ;
    wire        chn0_req_tx_len_ready   ;

    wire        dma_start   ;
    wire [31:0] dma_dwlen   ;
    wire [63:0] dma_address ;
    wire        dma_done    ;

    wire              dma_dready ;
    wire               dma_dreq     ;
    wire [15:0]        dma_dreq_len ;
    wire              dma_dvlid  ;
    wire [64 - 1 : 0] dma_data   ;

    wire [15:0] bit_mode ;
    wire [31:0] dma_addr ;

    wire [127 : 0]            head_r_fifo_data ;
    wire                      head_r_fifo_en   ;
    wire                      head_r_empty     ;
    wire                      data_r_fifo_en   ;
    wire [DATA_WIDTH - 1 : 0] data_r_fifo_data ;
    wire                      data_r_empty     ;

    reg dma_en;
//*******************INSTANCE AREA***************************************************/
    //to generate the image for test
    test_pix_gen#(
        .TAP   (TAP)      ,
        .BIT   (12)      
    )
    test_pix_gen_inst(
        .i_clk      (clk_200m) , //input   wire                            
        .i_rst      (sys_rst ) , //input   wire                            
        .i_trig     (img_trig) , //input   wire                            

        .i_line_gap   (LINE_GAP ) , //input   wire    [15:0] 
        .i_imag_type  (IMAG_TYPE) , //input   wire    [3:0]  
        .i_ylength    (YLENGTH  ) , //input   wire    [15:0] 
        .i_xlength    (XLENGTH  ) , //input   wire    [15:0] 

        .o_fval     (test_fval) , //output  wire                      
        .o_lval     (test_lval) , //output  wire                      
        .o_data     (test_data)   //output  wire    [TAP * 16 - 1 : 0]

    );
    
    //1. request dma start for image from client to host 
    //2. request dma end for a frame of image from client to host
    //3. image interface to dma data  interface
    c2h0_channel #(
       .TAP_SEL      (16),
       .BIT_SEL      (12),
       .DATA_WIDTH   (DATA_WIDTH)
    )
    c2h0_cha_inst(
        .i_clk  (clk_200m), //input wire 
        .i_rst  (sys_rst), //input wire 

        .i_dma_en    (dma_en), //input wire        
        .i_width     (XLENGTH), //input wire [15:0] 
        .i_height    (YLENGTH), //input wire [15:0] 
        .i_bit_mode  (bit_mode), //input wire [15:0] bit_mode
        .i_dma_addr  (dma_addr), //input wire [31:0] dma_addr

        .i_fval      (test_fval), //input wire                           
        .i_lval      (test_lval), //input wire                           
        .i_data      (test_data), //input wire [TAP_SEL*BIT_SEL - 1 : 0] 

        .o_chn0_req_tx_len_valid  (chn0_req_tx_len_valid), //output  wire        chn0_req_tx_len_valid
        .o_chn0_req_tx_len        (chn0_req_tx_len      ), //output  wire [31:0] chn0_req_tx_len      
        .o_chn0_req_tx_status     (chn0_req_tx_status   ), //output  wire [1:0]  chn0_req_tx_status   
        .i_chn0_req_tx_len_ready  (chn0_req_tx_len_ready), //input   wire        chn0_req_tx_len_ready

        .o_dma_start   (dma_start  ), //output wire        dma_start  
        .o_dma_dwlen   (dma_dwlen  ), //output wire [31:0] dma_dwlen  
        .o_dma_address (dma_address), //output wire [63:0] dma_address
        .i_dma_done    (dma_done   ), //input  wire        dma_done   

        .i_dma_dreq     (dma_dreq    ) , //input    wire         dmaB_dreq                 
        .i_dma_dreq_len (dma_dreq_len) , //input    wire [15:0]  dma_dreq_len           
        .o_dma_dvlid    (dma_dvlid   ), //output   wire                      dma_dvlid 
        .o_dma_data     (dma_data    )  //output   wire [DATA_WIDTH - 1 : 0] dma_data  
    
    );
    
    tx_mwr_pkt # (
        .DATA_WIDTH (DATA_WIDTH),
        .HEAD_WIDTH (128) 
    )
    tx_mwr_pkt_inst(
        .i_clk_din    (clk_200m) , //input wire 
        .i_clk_dout   (clk_200m) , //input wire 
        .i_rst        (sys_rst ) , //input wire 

        .i_dma_start    (dma_start), //input wire        
        .i_dma_dwlen    (dma_dwlen  ), //input wire [31:0] 
        .i_dma_address  (dma_address), //input wire [63:0] 
        .o_dma_done     (dma_done   ), //output wire       

        .o_dma_dreq      (dma_dreq    ) ,
        .o_dma_dreq_len  (dma_dreq_len) , //output wire [15:0] 

        .i_dma_dvlid   (dma_dvlid ) , //input  wire                     
        .i_dma_data    (dma_data  ) , //input wire [DATA_WIDTH - 1 : 0] 

        .i_MaxPayloadSize  (3'b011  ) , //input wire [2:0]  
        .i_req_id          (16'h0123) , //input wire [15:0] 

        .head_r_fifo_data (head_r_fifo_data) , //output wire [HEAD_WIDTH - 1 : 0] head_r_fifo_data     
        .head_r_fifo_en   (head_r_fifo_en  ) , //input  wire                      head_r_fifo_en       
        .head_r_empty     (head_r_empty    ) , //output wire                      head_r_empty         
        .data_r_fifo_en   (data_r_fifo_en  ) , //input  wire                      data_r_fifo_en       
        .data_r_fifo_data (data_r_fifo_data) , //output wire [DATA_WIDTH - 1 : 0] data_r_fifo_data     
        .data_r_empty     (data_r_empty    )   //output wire                      data_r_empty         
    );

    tx_pkt_rounter #(
        .DATA_WIDTH (65 ),
        .HEAD_WIDTH (128) 
    )
    tx_pkt_rounter_inst(
        .i_clk  (clk_200m), //input wire  
        .i_rst  (sys_rst ), //input wire  

        .s0_head_r_fifo_en   (head_r_fifo_data) , //output wire                           
        .s0_head_r_fifo_data (head_r_fifo_en  ) , //input  wire [HEAD_WIDTH - 1 : 0]      
        .s0_head_r_empty     (head_r_empty    ) , //input  wire                           
        .s0_data_r_fifo_en   (data_r_fifo_en  ) , //output wire                           
        .s0_data_r_fifo_data (data_r_fifo_data) , //input  wire [DATA_WIDTH - 1 : 0]      
        .s0_data_r_empty     (data_r_empty    ) , //input  wire                           

        .s1_head_r_fifo_en   () , //output wire                           
        .s1_head_r_fifo_data () , //input  wire [HEAD_WIDTH - 1 : 0]      
        .s1_head_r_empty     (0) , //input  wire                           
        .s1_data_r_fifo_en   () , //output wire                           
        .s1_data_r_fifo_data () , //input  wire [DATA_WIDTH - 1 : 0]      
        .s1_data_r_empty     (0) , //input  wire                           


        .m_tx_ready    () , //input wire                           
        .m_tx_tkeep    () , //output reg  [DATA_WIDTH/8 - 1 : 0]   
        .m_tx_tlast    () , //output reg                           
        .m_tx_tuser    () , //output reg [3:0]                     
        .m_tx_valid    () , //output reg                           
        .m_tx_data     ()   //output reg  [DATA_WIDTH - 1: 0]      

    );
//*******************PROGRAM AREA****************************************************/
    initial begin
        clk_200m = 1;
        sys_rst  = 1;

        #300
        sys_rst  = 0;
    end
    always #2.5 clk_200m <= ~ clk_200m ;
    initial begin
        img_trig = 0;
        #4000
        img_trig = 1;
        #20
        img_trig = 0;
    end
    assign bit_mode = 12 ;
    assign dma_addr = 32'h80000000;

    initial begin
        dma_en = 0;
        #2000
        dma_en = 1;
    end
    assign chn0_req_tx_len_ready = 1 ;
endmodule