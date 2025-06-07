`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/06/01 19:02
// File Name     : project_top.v
// Moduel Name   : project_top
// Encoding      : GB2312
// Target Devices: 
// Tool Versions : 
// Called By     : 
// Abstract      : 
//
// Description:
//
// copyRight(c)2025,zping Technology co. Itd..
// All Rights Reserved
//
//***********************************************************************************/
//Modification History:
// 1. initial
//***********************************************************************************/
//**************************
//MODULE DEFINITION
//**************************
module project_top #(
    parameter C_NUM_LANES = 2,
    parameter C_PCI_DATA_WIDTH = 64
)(
    //sys clock and reset
    input wire i_sys_clk_200m_p ,
    input wire i_sys_clk_200m_n ,

    //pcie interface
    output wire [C_NUM_LANES - 1 : 0] o_pcie_txp ,
    output wire [C_NUM_LANES - 1 : 0] o_pcie_txn ,
    input  wire [C_NUM_LANES - 1 : 0] i_pcie_rxp ,
    input  wire [C_NUM_LANES - 1 : 0] i_pcie_rxn ,
    
    input wire                        i_pcie_refclk_p ,
    input wire                        i_pcie_refclk_n ,
    input wire                        i_pcie_reset_n  ,

    output wire [3:0]                 o_led 
    
    
);
//*******************DEFINE Variables************************************************/
    wire [31:0]  axi_lite_awaddr  ;
    wire         axi_lite_awready ;
    wire         axi_lite_awvalid ;
    wire [31 :0] axi_lite_wdata   ;
    wire         axi_lite_wready  ;
    wire [3:0]   axi_lite_wstrb   ;
    wire         axi_lite_wvalid  ;
    wire         axi_lite_bready  ;
    wire [1:0]   axi_lite_bresp   ;
    wire         axi_lite_bvalid  ;
    wire [31:0]  axi_lite_araddr  ;
    wire         axi_lite_arready ;
    wire         axi_lite_arvalid ;
    wire [31 :0] axi_lite_rdata   ;
    wire         axi_lite_rready  ;
    wire [1:0]   axi_lite_rresp   ;
    wire         axi_lite_rvalid  ;

    wire sys_clk_100m ;
    wire sys_rst      ;
    
    wire mmcm_locked_i ;

    wire clk_100m ;
    wire clk_200m ;

    wire [31:0] edge_detect   ;
    wire [31:0] smooth_filter ;
    wire [31:0] bar_test      ;
//*******************INSTANCE AREA***************************************************/
    clock_mode #(
        .MULT          (5),
        .DIVIDE        (1),
        .CLK_PERIOD    (5.000),
        .OUT0_DIVIDE   (25),
        .OUT1_DIVIDE   (10),
        .OUT2_DIVIDE   (8 ),
        .OUT3_DIVIDE   (5 ),
        .OUT4_DIVIDE   (4 )
    )
    clock_mode_isnt(// Clock in ports
        .CLK_IN_P     (i_sys_clk_200m_p),
        .CLK_IN_N     (i_sys_clk_200m_n),
        // Clock out ports
        .CLK0_OUT   (),
        .CLK1_OUT   (clk_100m),
        .CLK2_OUT   (),
        .CLK3_OUT   (clk_200m),
        .CLK4_OUT   (),
        // Status and control signals
        .MMCM_RESET_IN      (1'b0 ),
        .MMCM_LOCKED_OUT    (mmcm_locked_i)
    );

    honghu_pcie_top #(
        .C_NUM_LANES        (C_NUM_LANES     ),
        .C_PCI_DATA_WIDTH   (C_PCI_DATA_WIDTH)
    )(
        .o_pcie_txp (o_pcie_txp) , //output wire [C_NUM_LANES - 1 : 0] 
        .o_pcie_txn (o_pcie_txn) , //output wire [C_NUM_LANES - 1 : 0] 
        .i_pcie_rxp (i_pcie_rxp) , //input  wire [C_NUM_LANES - 1 : 0] 
        .i_pcie_rxn (i_pcie_rxn) , //input  wire [C_NUM_LANES - 1 : 0] 

        .i_pcie_refclk_p (i_pcie_refclk_p) , //input wire                        
        .i_pcie_refclk_n (i_pcie_refclk_n) , //input wire                        
        .i_pcie_reset_n  (i_pcie_reset_n ) , //input wire                        

        //AXI lite bus for parameter configuration
        .cfg_axi_clk       (clk_100m) , //input  wire         
        .cfg_axi_rst       (sys_rst     ) , //input  wire         

        .maxi_lite_awaddr  (axi_lite_awaddr ), //output wire [31:0]  
        .maxi_lite_awready (axi_lite_awready), //input  wire         
        .maxi_lite_awvalid (axi_lite_awvalid), //output wire         
        .maxi_lite_wdata   (axi_lite_wdata ) , //output wire [31 :0] axi_lite_wdata 
        .maxi_lite_wready  (axi_lite_wready) , //input  wire         axi_lite_wready
        .maxi_lite_wstrb   (axi_lite_wstrb ) , //output wire [3:0]   axi_lite_wstrb 
        .maxi_lite_wvalid  (axi_lite_wvalid) , //output wire         axi_lite_wvalid
        .maxi_lite_bready  (axi_lite_bready ) , //output  wire         axi_lite_bready 
        .maxi_lite_bresp   (axi_lite_bresp  ) , //input   wire [1:0]   axi_lite_bresp  
        .maxi_lite_bvalid  (axi_lite_bvalid ) , //input   wire         axi_lite_bvalid 
        .maxi_lite_araddr  (axi_lite_araddr ) , ///output wire [31:0]  axi_lite_araddr 
        .maxi_lite_arready (axi_lite_arready) , ///input  wire         axi_lite_arready
        .maxi_lite_arvalid (axi_lite_arvalid) , ///output wire         axi_lite_arvalid
        .maxi_lite_rdata   (axi_lite_rdata  ) , //input   wire [31 :0] axi_lite_rdata  
        .maxi_lite_rready  (axi_lite_rready ) , //output  wire         axi_lite_rready 
        .maxi_lite_rresp   (axi_lite_rresp  ) , //input   wire [1:0]   axi_lite_rresp  
        .maxi_lite_rvalid  (axi_lite_rvalid ) , //input   wire         axi_lite_rvalid 

        .user_lnk_up  () , //output wire         
        .user_app_rdy ()   //output wire         
        );

    config_register #(
        .AXIDATA_WIDTH  (32)
    )
    config_register_inst(
        .i_clk (clk_100m) , //input wire 
        .i_rst (sys_rst     ) , //input wire 

        //slave axi lite interface
        .saxi_lite_awaddr    (axi_lite_awaddr )  , //input  wire  [31:0]  saxi_lite_awaddr 
        .saxi_lite_awready   (axi_lite_awready)  , //output wire          saxi_lite_awready
        .saxi_lite_awvalid   (axi_lite_awvalid)  , //input  wire          saxi_lite_awvalid
        .saxi_lite_wdata     (axi_lite_wdata  ) , //input  wire [AXIDATA_WIDTH -1 :0]   saxi_lite_wdata 
        .saxi_lite_wready    (axi_lite_wready ) , //output wire                         saxi_lite_wready
        .saxi_lite_wstrb     (axi_lite_wstrb  ) , //input  wire [AXIDATA_WIDTH/8 -1:0]  saxi_lite_wstrb 
        .saxi_lite_wvalid    (axi_lite_wvalid ) , //input  wire                         saxi_lite_wvalid
        .saxi_lite_bready    (axi_lite_bready ) , //input  wire       saxi_lite_bready                 
        .saxi_lite_bresp     (axi_lite_bresp  ) , //output wire [1:0] saxi_lite_bresp                  
        .saxi_lite_bvalid    (axi_lite_bvalid ) , //output wire       saxi_lite_bvalid                 
        .saxi_lite_araddr    (axi_lite_araddr ) , //input  wire[31:0] saxi_lite_araddr                   
        .saxi_lite_arready   (axi_lite_arready) , //output wire       saxi_lite_arready                  
        .saxi_lite_arvalid   (axi_lite_arvalid) , //input  wire       saxi_lite_arvalid                  
        .saxi_lite_rdata     (axi_lite_rdata  ) , //output reg  [AXIDATA_WIDTH -1 :0] saxi_lite_rdata   
        .saxi_lite_rready    (axi_lite_rready ) , //input  wire                       saxi_lite_rready  
        .saxi_lite_rresp     (axi_lite_rresp  ) , //output wire [1:0]                 saxi_lite_rresp   
        .saxi_lite_rvalid    (axi_lite_rvalid ) , //output wire                       saxi_lite_rvalid  

        //config interface
        .o_edge_detect      (edge_detect  ) , //output reg [31:0]                  
        .o_smooth_filter    (smooth_filter) , //output reg [31:0]                  
        .o_bar_test         (bar_test     )   //output reg [31:0]                  
    
    );

    ila_5 ila_parameter(
        .clk(clk_100m),
        .probe0(edge_detect  ),
        .probe1(smooth_filter),
        .probe2(bar_test     )
    );
    ila_4 ila_lite_axi(
        .clk(clk_100m),
        .probe0  (axi_lite_awaddr ), //32
        .probe1  (axi_lite_awready), //1
        .probe2  (axi_lite_awvalid), //1
        .probe3  (axi_lite_wdata  ), //32
        .probe4  (axi_lite_wready ), //1
        .probe5  (axi_lite_wstrb  ), //4
        .probe6  (axi_lite_wvalid ), //1
        .probe7  (axi_lite_bready ), //1
        .probe8  (axi_lite_bresp  ), //2
        .probe9  (axi_lite_bvalid ), //1
        .probe10 (axi_lite_araddr ), //32
        .probe11 (axi_lite_arready), //1
        .probe12 (axi_lite_arvalid), //1
        .probe13 (axi_lite_rdata  ), //32
        .probe14 (axi_lite_rready ), //1
        .probe15 (axi_lite_rresp  ), //2
        .probe16 (axi_lite_rvalid )  //1
    );

    
//*******************PROGRAM AREA****************************************************/
    assign sys_rst = ~mmcm_locked_i ;
    
    
endmodule