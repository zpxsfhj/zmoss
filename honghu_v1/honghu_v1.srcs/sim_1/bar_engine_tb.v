`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/06/06 20:17
// File Name     : bar)engine_tb.v
// Moduel Name   : bar)engine_tb
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
module bar_engine_tb (
    
);
//*******************DEFINE Variables************************************************/
    reg pcie_user_clk  ;
    reg user_reset_out ;
    
    reg cfg_axi_clk ;
    reg cfg_axi_rst ;

    reg        wrReq_valid   ; 
    reg [63:0] wrReq_data    ; 
    reg [9:0]  wrReq_dwlen   ; 
    reg [31:0] wrReq_address ; 

    reg            rdReq_valid   ;
    reg    [31:0]  rdReq_address ;
    reg    [15:0]  rdReq_reqid   ;
    reg    [7:0]   rdReq_tag     ;
    reg    [9:0]   rdReq_dwlen   ;
    reg    [2:0]   rdReq_tc      ;
    reg    [2:0]   rdReq_attr    ;
    reg    [1:0]   rdReq_at      ;

    wire [31:0] maxi_lite_awaddr  ;
    wire        maxi_lite_awready ;
    wire        maxi_lite_awvalid ;

    wire [31:0] maxi_lite_wdata  ;
    wire        maxi_lite_wready ;
    wire [3:0]  maxi_lite_wstrb  ;
    wire        maxi_lite_wvalid ;

    wire        maxi_lite_bready ;
    wire [1:0]  maxi_lite_bresp  ;
    wire        maxi_lite_bvalid ;

    wire [31:0] maxi_lite_araddr  ;
    wire        maxi_lite_arready ;
    wire        maxi_lite_arvalid ;

    wire [31:0] maxi_lite_rdata  ;
    wire        maxi_lite_rready ;
    wire [1:0]  maxi_lite_rresp  ;
    wire        maxi_lite_rvalid ;

    wire [15:0] localID ;

    reg   [3:0]rdCpld_eof_index ;
    reg        rdCpld_eof       ;
    reg          rdCpld_valid   ;
    reg  [9:0]   rdCpld_dwLen   ;
    reg  [7:0]   rdCpld_tag     ;
    reg  [2:0]   rdCpld_TC      ;
    reg  [2:0]   rdCpld_attr    ;
    reg  [1:0]   rdCpld_at      ;
    reg  [11:0]  rdCpld_bytecnt ;
    reg  [6:0]   rdCpld_lowaddr ;
    reg  [63:0]  rdCpld_data    ;
    reg  [15:0]  rdCpld_reqid   ;
    reg  [15:0]  rdCpld_cplid   ;
    reg  [2:0]   rdCpld_status  ;

    reg             s_axis_tx_tready;
    wire [7 : 0]    s_axis_tx_tkeep ;
    wire            s_axis_tx_tlast ;
    wire [3:0]      s_axis_tx_tuser ;
    wire            s_axis_tx_tvalid;
    wire [63: 0]    s_axis_tx_tdata ;

    

//*******************INSTANCE AREA***************************************************/
    /* bar_engine #(
        .DATA_WIDTH     (64) ,
        .AXIDATA_WIDTH  (32)  
    )
    bar_engine_inst(
        .i_rx_pkt_clk  (pcie_user_clk ) , //input wire 
        .i_rx_pkt_rst  (user_reset_out) , //input wire 
        .i_axi_clk     (cfg_axi_clk) , //input wire 
        .i_axi_rst     (cfg_axi_rst) , //input wire 

        .wrReq_valid    (wrReq_valid  ) , //input wire                     
        .wrReq_data     (wrReq_data   ) , //input wire [DATA_WIDTH-1:0]    
        .wrReq_dwlen    (wrReq_dwlen  ) , //input wire [9:0]               
        .wrReq_address  (wrReq_address) , //input wire [31:0]              

        .rdReq_valid    (rdReq_valid  ) , //input   wire           rdReq_valid         
        .rdReq_address  (rdReq_address) , //input   wire [31:0]    rdReq_address       
        .rdReq_reqid    (rdReq_reqid  ) , //input    wire       [15:0] rdReq_reqid         
        .rdReq_tag      (rdReq_tag    ) , //input    wire      [7:0]  rdReq_tag           
        .rdReq_dwlen    (rdReq_dwlen  ) , //input    wire      [9:0]  rdReq_dwlen         
        .rdReq_TC       (rdReq_tc     ) , //input    wire      [2:0]  rdReq_tc            
        .rdReq_attr     (rdReq_attr   ) , //input    wire      [2:0]  rdReq_attr          
        .rdReq_at       (rdReq_at     ) , //input    wire      [1:0]  rdReq_at            


        .maxi_lite_awaddr     (maxi_lite_awaddr ) , //output reg  [31:0] maxi_lite_awaddr  
        .maxi_lite_awready    (maxi_lite_awready) , //input  wire        maxi_lite_awready 
        .maxi_lite_awvalid    (maxi_lite_awvalid) , //output reg         maxi_lite_awvalid 

        .maxi_lite_wdata   (maxi_lite_wdata ) , //output reg  [AXIDATA_WIDTH -1 :0]  
        .maxi_lite_wready  (maxi_lite_wready) , //input  wire                        
        .maxi_lite_wstrb   (maxi_lite_wstrb ) , //output wire [AXIDATA_WIDTH/8 -1:0] 
        .maxi_lite_wvalid  (maxi_lite_wvalid) , //output reg                         

        .maxi_lite_bready    (maxi_lite_bready) , //output wire        maxi_lite_bready      
        .maxi_lite_bresp     (maxi_lite_bresp ) , //input  wire [1:0]  maxi_lite_bresp       
        .maxi_lite_bvalid    (maxi_lite_bvalid) , //input  wire        maxi_lite_bvalid      

        .maxi_lite_araddr    (maxi_lite_araddr ) , //output reg  [31:0]    
        .maxi_lite_arready   (maxi_lite_arready) , //input  wire           
        .maxi_lite_arvalid   (maxi_lite_arvalid) , //output reg            

        .maxi_lite_rdata     (maxi_lite_rdata ) , //input  wire [AXIDATA_WIDTH -1 :0]   
        .maxi_lite_rready    (maxi_lite_rready) , //output reg                          
        .maxi_lite_rresp     (maxi_lite_rresp ) , //input  wire [1:0]                   
        .maxi_lite_rvalid    (maxi_lite_rvalid) , //input  wire                         

        //local id 
        .localID            (localID) ,// input   wire [15:0] { bus dev func id}

        //rdre11q to cpld  buffer               
        .rdCpld_valid       (rdCpld_valid    ) , //output reg                  
        .rdCpld_dwLen       (rdCpld_dwLen    ) , //output reg  [9:0]           
        .rdCpld_tag         (rdCpld_tag      ) , //output reg  [7:0]           
        .rdCpld_TC          (rdCpld_TC       ) , //output reg  [2:0]           
        .rdCpld_attr        (rdCpld_attr     ) , //output reg  [2:0]           
        .rdCpld_at          (rdCpld_at       ) , //output reg  [1:0]           
        .rdCpld_bytecnt     (rdCpld_bytecnt  ) , //output reg  [11:0]          
        .rdCpld_lowaddr     (rdCpld_lowaddr  ) , //output reg  [6:0]           
        .rdCpld_data        (rdCpld_data     ) , //output reg  [127:0]         
        .rdCpld_reqid       (rdCpld_reqid    ) , //output reg  [15:0]          
        .rdCpld_cplid       (rdCpld_cplid    ) , //output reg  [15:0]          
        .rdCpld_status      (rdCpld_status   )   //output reg  [2:0]           
    );
    
    config_register #(
        .AXIDATA_WIDTH  (32)
    )
    config_register_inst(
        .i_clk (cfg_axi_clk) , //input wire 
        .i_rst (cfg_axi_rst) , //input wire 

        //slave axi lite interface
        .saxi_lite_awaddr    (maxi_lite_awaddr )  , //input  wire  [31:0]  saxi_lite_awaddr 
        .saxi_lite_awready   (maxi_lite_awready)  , //output wire          saxi_lite_awready
        .saxi_lite_awvalid   (maxi_lite_awvalid)  , //input  wire          saxi_lite_awvalid
        .saxi_lite_wdata     (maxi_lite_wdata  ) , //input  wire [AXIDATA_WIDTH -1 :0]   saxi_lite_wdata 
        .saxi_lite_wready    (maxi_lite_wready ) , //output wire                         saxi_lite_wready
        .saxi_lite_wstrb     (maxi_lite_wstrb  ) , //input  wire [AXIDATA_WIDTH/8 -1:0]  saxi_lite_wstrb 
        .saxi_lite_wvalid    (maxi_lite_wvalid ) , //input  wire                         saxi_lite_wvalid
        .saxi_lite_bready    (maxi_lite_bready ) , //input  wire       saxi_lite_bready                 
        .saxi_lite_bresp     (maxi_lite_bresp  ) , //output wire [1:0] saxi_lite_bresp                  
        .saxi_lite_bvalid    (maxi_lite_bvalid ) , //output wire       saxi_lite_bvalid                 
        .saxi_lite_araddr    (maxi_lite_araddr ) , //input  wire[31:0] saxi_lite_araddr                   
        .saxi_lite_arready   (maxi_lite_arready) , //output wire       saxi_lite_arready                  
        .saxi_lite_arvalid   (maxi_lite_arvalid) , //input  wire       saxi_lite_arvalid                  
        .saxi_lite_rdata     (maxi_lite_rdata  ) , //output reg  [AXIDATA_WIDTH -1 :0] saxi_lite_rdata   
        .saxi_lite_rready    (maxi_lite_rready ) , //input  wire                       saxi_lite_rready  
        .saxi_lite_rresp     (maxi_lite_rresp  ) , //output wire [1:0]                 saxi_lite_rresp   
        .saxi_lite_rvalid    (maxi_lite_rvalid ) , //output wire                       saxi_lite_rvalid  

        //config interface
        .o_edge_detect      () , //output reg [31:0]                   
        .o_smooth_filter    () , //output reg [31:0]                   
        .o_bar_test         ()   //output reg [31:0]                   
    
    ); */

    bar_cpl_buffer #(
        .DATA_WIDTH      (32) , //parameter 
        .PCIE_DATA_WIDTH (64)   //parameter 
    )
    bar_cpl_buffer_inst(
        .i_clk   (cfg_axi_clk) ,//input wire 
        .i_rst   (cfg_axi_rst) ,//input wire 

        .i_tx_clk  (pcie_user_clk ), //input wire 
        .i_tx_rst  (user_reset_out), //input wire 

        .tx_ready   (s_axis_tx_tready) , //input  wire                             tx_ready
        .tx_tkeep   (s_axis_tx_tkeep ) , //output wire [PCIE_DATA_WIDTH/8 - 1 : 0] tx_tkeep
        .tx_tlast   (s_axis_tx_tlast ) , //output wire                             tx_tlast
        .tx_tuser   (s_axis_tx_tuser ) , //output wire [3:0]                       tx_tuser
        .tx_valid   (s_axis_tx_tvalid) , //output reg                              tx_valid
        .tx_data    (s_axis_tx_tdata ) , //output reg  [PCIE_DATA_WIDTH - 1: 0]    tx_data 
        //cpld packt
        .rdCpld_eof_index (rdCpld_eof_index), //input wire  [3:0]               
        .rdCpld_eof       (rdCpld_eof      ), //input wire                      
        .rdCpld_valid     (rdCpld_valid    ), //input wire                      
        .rdCpld_dwLen     (rdCpld_dwLen    ), //input wire  [9:0]               
        .rdCpld_tag       (rdCpld_tag      ), //input wire  [7:0]               
        .rdCpld_TC        (rdCpld_TC       ), //input wire  [2:0]               
        .rdCpld_attr      (rdCpld_attr     ), //input wire  [2:0]               
        .rdCpld_at        (rdCpld_at       ), //input wire  [1:0]               
        .rdCpld_bytecnt   (rdCpld_bytecnt  ), //input wire  [11:0]              
        .rdCpld_lowaddr   (rdCpld_lowaddr  ), //input wire  [6:0]               
        .rdCpld_data      (rdCpld_data     ), //input wire  [DATA_WIDTH -1 :0]  
        .rdCpld_reqid     (rdCpld_reqid    ), //input wire  [15:0]              
        .rdCpld_cplid     (rdCpld_cplid    ), //input wire  [15:0]              
        .rdCpld_status    (rdCpld_status   )  //input wire  [2:0]               

    );
    
//*******************PROGRAM AREA****************************************************/
    initial begin
        user_reset_out = 1;
        cfg_axi_rst    = 1;

        #200
        user_reset_out = 0;
        #402
        cfg_axi_rst    = 0 ;
    end
    initial begin
        pcie_user_clk = 1;
        while (1) begin
            #2.5
            pcie_user_clk = ~pcie_user_clk ;
        end
    end
    initial begin
        cfg_axi_clk = 1;
        #1
        while (1) begin
            #5
            cfg_axi_clk = ~cfg_axi_clk ;
        end
    end

    initial begin
        wrReq_valid   = 'd0 ;
        wrReq_data    = 64'h78563412 ;
        wrReq_dwlen   = 10'd1 ;
        wrReq_address = 32'hfbe00008 ;
        #1000
        @(posedge pcie_user_clk)
        wrReq_valid = `DLY 1 ;
        @(posedge pcie_user_clk)
        wrReq_valid = `DLY 0 ;
        #3000
        @(posedge pcie_user_clk)
        wrReq_data    = 64'h9a785634 ;
        wrReq_address = 32'hfbe00004 ;
        wrReq_valid = `DLY 1 ;
        @(posedge pcie_user_clk)
        wrReq_valid = `DLY 0 ;
        #3000
        @(posedge pcie_user_clk)
        wrReq_data    = 64'hbc9a7856 ;
        wrReq_address = 32'hfbe00000 ;
        wrReq_valid = `DLY 1 ;
        @(posedge pcie_user_clk)
        wrReq_valid = `DLY 0 ;

    end

    initial begin
        rdReq_valid   = 0 ;
        rdReq_address = 32'hfbe00008 ;
        rdReq_reqid   = 18 ;
        rdReq_tag     = 0 ;
        rdReq_dwlen   = 1 ;
        rdReq_tc      = 0 ;
        rdReq_attr    = 0 ;
        rdReq_at      = 0 ;

        #20000
        @(posedge pcie_user_clk)
        rdReq_valid = `DLY 1 ;
        @(posedge pcie_user_clk)
        rdReq_valid = `DLY 0 ;
        #4000
        @(posedge pcie_user_clk)
        rdReq_address = 32'hfbe00000 ;
        rdReq_valid = `DLY 1 ;
        @(posedge pcie_user_clk)
        rdReq_valid = `DLY 0 ;
        #4000
        @(posedge pcie_user_clk)
        rdReq_address = 32'hfbe00004 ;
        rdReq_valid = `DLY 1 ;
        @(posedge pcie_user_clk)
        rdReq_valid = `DLY 0 ;
    end

    /* initial begin
        maxi_lite_awready = 1;
        maxi_lite_wready  = 1;
        maxi_lite_bresp   = 0;
        maxi_lite_bvalid  = 1;
        maxi_lite_arready = 1;

        maxi_lite_rdata   = 1 ;
        maxi_lite_rresp   = 0 ;
        maxi_lite_rvalid  = 1 ;
    end */
    assign localID = 16'h1234 ;

    initial begin
        s_axis_tx_tready = 1;
    end

    initial begin
        rdCpld_eof_index = 'd0;
        rdCpld_eof       = 'd0;
        rdCpld_valid     = 'd0;
        rdCpld_dwLen     = 'd0;
        rdCpld_tag       = 'd0;
        rdCpld_TC        = 'd0;
        rdCpld_attr      = 'd0;
        rdCpld_at        = 'd0;
        rdCpld_bytecnt   = 'd0;
        rdCpld_lowaddr   = 'd0;
        rdCpld_data      = 'd0;
        rdCpld_reqid     = 'd0;
        rdCpld_cplid     = 'd0;
        rdCpld_status    = 'd0;
        /* #3000
        @(posedge cfg_axi_clk)
        rdCpld_eof_index = `DLY  4'd3;
        rdCpld_eof       = `DLY  1'd1;
        rdCpld_valid     = `DLY  1'd1;
        rdCpld_dwLen     = `DLY 10'd1;
        rdCpld_tag       = `DLY  8'd0;
        rdCpld_TC        = `DLY  3'd0;
        rdCpld_attr      = `DLY  3'd0;
        rdCpld_at        = `DLY  2'd0;
        rdCpld_bytecnt   = `DLY 12'd4;
        rdCpld_lowaddr   = `DLY  7'd8;
        rdCpld_data      = `DLY 64'h12345678;
        rdCpld_reqid     = `DLY 16'd12;
        rdCpld_cplid     = `DLY 16'd18;
        rdCpld_status    = `DLY  3'd0;
        #3000
        @(posedge cfg_axi_clk)
        rdCpld_eof_index = `DLY  4'd7;
        rdCpld_eof       = `DLY  1'd1;
        rdCpld_valid     = `DLY  1'd1;
        rdCpld_dwLen     = `DLY 10'd2;
        rdCpld_tag       = `DLY  8'd0;
        rdCpld_TC        = `DLY  3'd0;
        rdCpld_attr      = `DLY  3'd0;
        rdCpld_at        = `DLY  2'd0;
        rdCpld_bytecnt   = `DLY 12'd8;
        rdCpld_lowaddr   = `DLY  7'd8;
        rdCpld_data      = `DLY 64'h0102030405060708;
        rdCpld_reqid     = `DLY 16'd12;
        rdCpld_cplid     = `DLY 16'd18;
        rdCpld_status    = `DLY  3'd0;
 */
        #3000
        @(posedge cfg_axi_clk)
        `DLY
        rdCpld_eof_index =   4'd3;
        rdCpld_eof       =   1'd0;
        rdCpld_valid     =   1'd1;
        rdCpld_dwLen     =  10'd5;
        rdCpld_tag       =   8'd0;
        rdCpld_TC        =   3'd0;
        rdCpld_attr      =   3'd0;
        rdCpld_at        =   2'd0;
        rdCpld_bytecnt   =  12'd20;
        rdCpld_lowaddr   =   7'd8;
        rdCpld_data      =  64'h0102030405060708;
        rdCpld_reqid     =  16'd12;
        rdCpld_cplid     =  16'd18;
        rdCpld_status    =   3'd0;
        @(posedge cfg_axi_clk)
        `DLY
        rdCpld_eof_index =  4'd3;
        rdCpld_eof       =  1'd0;
        rdCpld_valid     =  1'd1;
        rdCpld_dwLen     = 10'd5;
        rdCpld_tag       =  8'd0;
        rdCpld_TC        =  3'd0;
        rdCpld_attr      =  3'd0;
        rdCpld_at        =  2'd0;
        rdCpld_bytecnt   = 12'd20;
        rdCpld_lowaddr   =  7'd8;
        rdCpld_data      = 64'h0001020304050607;
        rdCpld_reqid     = 16'd12;
        rdCpld_cplid     = 16'd18;
        rdCpld_status    =  3'd0;
        @(posedge cfg_axi_clk)
        `DLY
        rdCpld_eof_index =  4'd3;
        rdCpld_eof       =  1'd1;
        rdCpld_valid     =  1'd1;
        rdCpld_dwLen     = 10'd5;
        rdCpld_tag       =  8'd0;
        rdCpld_TC        =  3'd0;
        rdCpld_attr      =  3'd0;
        rdCpld_at        =  2'd0;
        rdCpld_bytecnt   = 12'd20;
        rdCpld_lowaddr   =  7'd8;
        rdCpld_data      = 64'h0800010203040506;
        rdCpld_reqid     = 16'd12;
        rdCpld_cplid     = 16'd18;
        rdCpld_status    =  3'd0;
        @(posedge cfg_axi_clk)
        `DLY
        rdCpld_eof_index =  4'd3;
        rdCpld_eof       =  1'd1;
        rdCpld_valid     =  1'd0;
        rdCpld_dwLen     = 10'd5;
        rdCpld_tag       =  8'd0;
        rdCpld_TC        =  3'd0;
        rdCpld_attr      =  3'd0;
        rdCpld_at        =  2'd0;
        rdCpld_bytecnt   = 12'd20;
        rdCpld_lowaddr   =  7'd8;
        rdCpld_data      = 64'h0800010203040506;
        rdCpld_reqid     = 16'd12;
        rdCpld_cplid     = 16'd18;
        rdCpld_status    =  3'd0;
        #3000
        @(posedge cfg_axi_clk)
        `DLY
        rdCpld_eof_index =   4'd7;
        rdCpld_eof       =  1'd0;
        rdCpld_valid     =  1'd1;
        rdCpld_dwLen     = 10'd6;
        rdCpld_tag       =  8'd0;
        rdCpld_TC        =  3'd0;
        rdCpld_attr      =  3'd0;
        rdCpld_at        =  2'd0;
        rdCpld_bytecnt   = 12'd24;
        rdCpld_lowaddr   =  7'd8;
        rdCpld_data      = 64'h0102030405060708;
        rdCpld_reqid     = 16'd12;
        rdCpld_cplid     = 16'd18;
        rdCpld_status    =  3'd0;
        @(posedge cfg_axi_clk)
        `DLY
        rdCpld_eof_index =  4'd7;
        rdCpld_eof       =  1'd0;
        rdCpld_valid     =  1'd1;
        rdCpld_dwLen     = 10'd6;
        rdCpld_tag       =  8'd0;
        rdCpld_TC        =  3'd0;
        rdCpld_attr      =  3'd0;
        rdCpld_at        =  2'd0;
        rdCpld_bytecnt   = 12'd24;
        rdCpld_lowaddr   =  7'd8;
        rdCpld_data      = 64'h0001020304050607;
        rdCpld_reqid     = 16'd12;
        rdCpld_cplid     = 16'd18;
        rdCpld_status    =  3'd0;
        @(posedge cfg_axi_clk)
        `DLY
        rdCpld_eof_index =  4'd7;
        rdCpld_eof       =  1'd1;
        rdCpld_valid     =  1'd1;
        rdCpld_dwLen     = 10'd6;
        rdCpld_tag       =  8'd0;
        rdCpld_TC        =  3'd0;
        rdCpld_attr      =  3'd0;
        rdCpld_at        =  2'd0;
        rdCpld_bytecnt   = 12'd24;
        rdCpld_lowaddr   =  7'd8;
        rdCpld_data      = 64'h0800010203040506;
        rdCpld_reqid     = 16'd12;
        rdCpld_cplid     = 16'd18;
        rdCpld_status    =  3'd0;
        @(posedge cfg_axi_clk)
        `DLY
        rdCpld_eof_index =  4'd3;
        rdCpld_eof       =  1'd1;
        rdCpld_valid     =  1'd0;
        rdCpld_dwLen     = 10'd5;
        rdCpld_tag       =  8'd0;
        rdCpld_TC        =  3'd0;
        rdCpld_attr      =  3'd0;
        rdCpld_at        =  2'd0;
        rdCpld_bytecnt   = 12'd20;
        rdCpld_lowaddr   =  7'd8;
        rdCpld_data      = 64'h0800010203040506;
        rdCpld_reqid     = 16'd12;
        rdCpld_cplid     = 16'd18;
        rdCpld_status    =  3'd0;
    end

endmodule