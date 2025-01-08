`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2024/12/21 15:44
// File Name     : rx_rounter_tb.v
// Moduel Name   : rx_rounter_tb
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
module rx_rounter_tb ();
//*******************DEFINE Variables************************************************/
    parameter DATA_WIDTH = 64 ;
    reg pcie_axi_clk;//125Mhz
    reg i_rst       ;
    
    wire [DATA_WIDTH-1 : 0] m_axis_rx_data   ;
    wire [7:0]              m_axis_rx_tkeep  ;
    wire                    m_axis_rx_tlast  ;
    wire                    m_axis_rx_tready ;
    wire [21:0]             m_axis_rx_tuser  ;
    wire                    m_axis_rx_tvalid ;

    wire                     rx_bar0_valid     ;
    wire                     rx_bar0_sof       ;
    wire [3:0]               rx_bar0_sof_index ;
    wire                     rx_bar0_eof       ;
    wire [3:0]               rx_bar0_eof_index ;
    wire [DATA_WIDTH-1 : 0]  rx_bar0_data      ;

    wire                     rx_bar1_valid     ;
    wire                     rx_bar1_sof       ;
    wire [3:0]               rx_bar1_sof_index ;
    wire                     rx_bar1_eof       ;
    wire [3:0]               rx_bar1_eof_index ;
    wire [DATA_WIDTH-1 : 0]  rx_bar1_data      ;

    wire                     rx_bar2_valid     ;
    wire                     rx_bar2_sof       ;
    wire [3:0]               rx_bar2_sof_index ;
    wire                     rx_bar2_eof       ;
    wire [3:0]               rx_bar2_eof_index ;
    wire [DATA_WIDTH-1 : 0]  rx_bar2_data      ;

    wire                     rx_bar3_valid     ;
    wire                     rx_bar3_sof       ;
    wire [3:0]               rx_bar3_sof_index ;
    wire                     rx_bar3_eof       ;
    wire [3:0]               rx_bar3_eof_index ;
    wire [DATA_WIDTH-1 : 0]  rx_bar3_data      ;

    wire                     rx_bar4_valid     ;
    wire                     rx_bar4_sof       ;
    wire [3:0]               rx_bar4_sof_index ;
    wire                     rx_bar4_eof       ;
    wire [3:0]               rx_bar4_eof_index ;
    wire [DATA_WIDTH-1 : 0]  rx_bar4_data      ;

    wire                     rx_bar5_valid     ;
    wire                     rx_bar5_sof       ;
    wire [3:0]               rx_bar5_sof_index ;
    wire                     rx_bar5_eof       ;
    wire [3:0]               rx_bar5_eof_index ;
    wire [DATA_WIDTH-1 : 0]  rx_bar5_data      ;

    reg [75:0]mem[0:119];

    reg pcie_rx_flag;

    parameter MAX_TLP = 120;

    wire        rx_sof_flag         ;
    wire        rx_eof_flag         ;
    wire [3:0]  rx_sof_byte_index   ;
    wire [3:0]  rx_eof_byte_index   ;
    wire [7:0]  rx_bar_hit          ;
    wire        rx_err_fwd          ;
    wire        rx_err_ecrc         ;
    
//*******************INSTANCE AREA***************************************************/
    rx_pkt_router #(
        .DATA_WIDTH  (DATA_WIDTH),
        .BAR_NUM     (1 )
    )
    rx_pkt_router_inst(
        .i_clk       (pcie_axi_clk  ), //input wire 
        .i_rst       (i_rst         ), //input wire 

        .m_axis_rx_data   (m_axis_rx_data  ) ,//input  wire [DATA_WIDTH-1 : 0] m_axis_rx_data   
        .m_axis_rx_tkeep  (m_axis_rx_tkeep ) ,//input  wire [7:0]              m_axis_rx_tkeep  
        .m_axis_rx_tlast  (m_axis_rx_tlast ) ,//input  wire                    m_axis_rx_tlast  
        .m_axis_rx_tready (m_axis_rx_tready) ,//output wire                    m_axis_rx_tready 
        .m_axis_rx_tuser  (m_axis_rx_tuser ) ,//input  wire [21:0]             m_axis_rx_tuser  
        .m_axis_rx_tvalid (m_axis_rx_tvalid) ,//input  wire                    m_axis_rx_tvalid 

        .rx_bar0_valid      (rx_bar0_valid    ) , //output reg                     rx_bar0_valid     
        .rx_bar0_sof        (rx_bar0_sof      ) , //output reg                     rx_bar0_sof       
        .rx_bar0_sof_index  (rx_bar0_sof_index) , //output reg [3:0]               rx_bar0_sof_index 
        .rx_bar0_eof        (rx_bar0_eof      ) , //output reg                     rx_bar0_eof       
        .rx_bar0_eof_index  (rx_bar0_eof_index) , //output reg [3:0]               rx_bar0_eof_index 
        .rx_bar0_data       (rx_bar0_data     ) , //output reg [DATA_WIDTH-1 : 0]  rx_bar0_data      

        .rx_bar1_valid      (rx_bar1_valid    ) , //output reg                      
        .rx_bar1_sof        (rx_bar1_sof      ) , //output reg                      
        .rx_bar1_sof_index  (rx_bar1_sof_index) , //output reg [3:0]                
        .rx_bar1_eof        (rx_bar1_eof      ) , //output reg                      
        .rx_bar1_eof_index  (rx_bar1_eof_index) , //output reg [3:0]                
        .rx_bar1_data       (rx_bar1_data     ) , //output reg [DATA_WIDTH-1 : 0]   

        .rx_bar2_valid      (rx_bar2_valid      ) , //output reg                      
        .rx_bar2_sof        (rx_bar2_sof        ) , //output reg                      
        .rx_bar2_sof_index  (rx_bar2_sof_index  ) , //output reg [3:0]                
        .rx_bar2_eof        (rx_bar2_eof        ) , //output reg                      
        .rx_bar2_eof_index  (rx_bar2_eof_index  ) , //output reg [3:0]                
        .rx_bar2_data       (rx_bar2_data       ) , //output reg [DATA_WIDTH-1 : 0]   
        
        .rx_bar3_valid      (rx_bar3_valid      ) , //output reg                      
        .rx_bar3_sof        (rx_bar3_sof        ) , //output reg                      
        .rx_bar3_sof_index  (rx_bar3_sof_index  ) , //output reg [3:0]                
        .rx_bar3_eof        (rx_bar3_eof        ) , //output reg                      
        .rx_bar3_eof_index  (rx_bar3_eof_index  ) , //output reg [3:0]                
        .rx_bar3_data       (rx_bar3_data       ) , //output reg [DATA_WIDTH-1 : 0]   
        
        .rx_bar4_valid      (rx_bar4_valid      ) , //output reg                      
        .rx_bar4_sof        (rx_bar4_sof        ) , //output reg                      
        .rx_bar4_sof_index  (rx_bar4_sof_index  ) , //output reg [3:0]                
        .rx_bar4_eof        (rx_bar4_eof        ) , //output reg                      
        .rx_bar4_eof_index  (rx_bar4_eof_index  ) , //output reg [3:0]                
        .rx_bar4_data       (rx_bar4_data       ) , //output reg [DATA_WIDTH-1 : 0]   
        
        .rx_bar5_valid      (rx_bar5_valid      ) , //output reg                      
        .rx_bar5_sof        (rx_bar5_sof        ) , //output reg                      
        .rx_bar5_sof_index  (rx_bar5_sof_index  ) , //output reg [3:0]                
        .rx_bar5_eof        (rx_bar5_eof        ) , //output reg                      
        .rx_bar5_eof_index  (rx_bar5_eof_index  ) , //output reg [3:0]                
        .rx_bar5_data       (rx_bar5_data       )   //output reg [DATA_WIDTH-1 : 0]   
);
    rx_pkt_realign #(
        .DATA_WIDTH (DATA_WIDTH)
    )
    rx_pkt_realign_inst0(
        .i_clk  (pcie_axi_clk), //input   wire    
        .i_rst  (i_rst       ), //input   wire    

        .i_rx_in_valid     (rx_bar0_valid    ), //input   wire                      
        .i_rx_in_data      (rx_bar0_data), //input   wire    [DATA_WIDTH -1:0] 
        .i_rx_in_sof       (rx_bar0_sof      ), //input   wire                      
        .i_rx_in_sof_index (rx_bar0_sof_index), //input   wire    [3:0]             
        .i_rx_in_eof       (rx_bar0_eof      ), //input   wire                      
        .i_rx_in_eof_index (rx_bar0_eof_index), //input   wire    [3:0]             

        .rx_out_valid     (), //output  wire                      
        .rx_out_sof       (), //output  reg                       
        .rx_out_eof       (), //output  reg                       
        .rx_out_eof_index (), //output  reg 	[3:0]             
        .rx_out_data	  ()  //output  reg 	[DATA_WIDTH -1:0] 
    
    );
    
    
//*******************PROGRAM AREA****************************************************/
    initial begin
        $readmemh("E:/PCIE/honghu_v1/honghu_v1.srcs/sim_1/new/tlp_realign.txt",mem);
    end
    initial begin
        pcie_axi_clk = 1'b1;
        i_rst        = 1'b1;
        #200
        i_rst        = 1'b0;
    end
    always #4 pcie_axi_clk <= ~pcie_axi_clk;

    initial begin
        pcie_rx_flag = 1'b0;
        #2000
        @(posedge pcie_axi_clk)
        `DLY
        pcie_rx_flag = 1'b1;
        #(8*2)
        pcie_rx_flag = 1'b0;
        #(8*4)
        pcie_rx_flag = 1'b1;
        #(8*9)
        pcie_rx_flag = 1'b0;
        #(8*40)
        pcie_rx_flag = 1'b1;
    end
    reg [7:0]         cnt_tlp;
    wire                add_cnt_tlp;
    wire                end_cnt_tlp;
    always @(posedge pcie_axi_clk) begin
        if(i_rst)
            cnt_tlp <= `DLY 8'd0;
        else if(add_cnt_tlp) begin
            if(end_cnt_tlp)
                cnt_tlp <= `DLY 8'd0;
            else
                cnt_tlp <= `DLY cnt_tlp + 1'b1;
        end
        else
            cnt_tlp <= `DLY cnt_tlp;
    end
    assign add_cnt_tlp = m_axis_rx_tready;
    assign end_cnt_tlp = add_cnt_tlp && (cnt_tlp == MAX_TLP - 1'b1);

    assign m_axis_rx_data = mem[cnt_tlp][75:12];
    assign m_axis_rx_tkeep = 8'hff;
    assign m_axis_rx_tlast = mem[cnt_tlp][11];
    assign m_axis_rx_tvalid = mem[cnt_tlp][10] ;
    assign m_axis_rx_tuser = {rx_eof_flag,rx_eof_byte_index,2'd0,rx_sof_flag,rx_sof_byte_index,rx_bar_hit,rx_err_fwd,rx_err_ecrc};

    assign rx_sof_flag = mem[cnt_tlp][8];
    assign rx_sof_byte_index = mem[cnt_tlp][7:4];
    assign rx_bar_hit = 8'd1;
    assign rx_eof_flag = mem[cnt_tlp][9];
    assign rx_eof_byte_index = mem[cnt_tlp][3:0];
    assign rx_err_fwd = 1'b0;
    assign rx_err_ecrc = 1'b0;

endmodule