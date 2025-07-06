`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/26 17:46:56
// Design Name: 
// Module Name: honghu_pcie_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module honghu_pcie_top #(
    parameter C_NUM_LANES = 2,
    parameter C_PCI_DATA_WIDTH = 64
)(
    output wire [C_NUM_LANES - 1 : 0] o_pcie_txp ,
    output wire [C_NUM_LANES - 1 : 0] o_pcie_txn ,
    input  wire [C_NUM_LANES - 1 : 0] i_pcie_rxp ,
    input  wire [C_NUM_LANES - 1 : 0] i_pcie_rxn ,

    input wire                        i_pcie_refclk_p ,
    input wire                        i_pcie_refclk_n ,
    input wire                        i_pcie_reset_n  ,

    //AXI lite bus for parameter configuration
    input  wire         cfg_axi_clk        ,
    input  wire         cfg_axi_rst        ,
    output wire [31:0]  maxi_lite_awaddr  ,
    input  wire         maxi_lite_awready ,
    output wire         maxi_lite_awvalid ,

    output wire [31 :0] maxi_lite_wdata  ,
    input  wire         maxi_lite_wready ,
    output wire [3:0]   maxi_lite_wstrb  ,
    output wire         maxi_lite_wvalid ,

    output wire         maxi_lite_bready ,
    input  wire [1:0]   maxi_lite_bresp  ,
    input  wire         maxi_lite_bvalid ,

    output wire [31:0] maxi_lite_araddr  ,
    input  wire        maxi_lite_arready ,
    output wire        maxi_lite_arvalid ,

    input  wire [31 :0] maxi_lite_rdata  ,
    output wire         maxi_lite_rready ,
    input  wire [1:0]   maxi_lite_rresp  ,
    input  wire         maxi_lite_rvalid ,


    output wire         user_lnk_up  ,
    output wire         user_app_rdy 
    );

    wire [63:0] cfg_dsn ;
    wire rx_np_ok ;
    wire rx_np_req ;
    wire tx_cfg_gnt;

    wire [1 : 0]  cfg_pm_force_state    ;
    wire          cfg_pm_force_state_en ;
    wire          cfg_pm_halt_aspm_l0s  ;
    wire          cfg_pm_halt_aspm_l1   ;
    wire          cfg_pm_send_pme_to    ;
    wire          cfg_pm_wake           ;

    wire [11 : 0] fc_cpld ;
    wire [7 : 0]  fc_cplh ;
    wire [11 : 0] fc_npd  ;
    wire [7 : 0]  fc_nph  ;
    wire [11 : 0] fc_pd   ;
    wire [7 : 0]  fc_ph   ;
    wire [2 : 0]  fc_sel  ;
    wire pcie_reset_n ;
    wire pcie_refclk ;

    wire          s_axis_tx_tready  ;
    wire [63 : 0] s_axis_tx_tdata   ;
    wire [7 : 0]  s_axis_tx_tkeep   ;
    wire          s_axis_tx_tlast   ;
    wire          s_axis_tx_tvalid  ;
    wire [3 : 0]  s_axis_tx_tuser   ;

    wire [63 : 0] m_axis_rx_tdata   ;
    wire [7 : 0]  m_axis_rx_tkeep   ;
    wire          m_axis_rx_tlast   ;
    wire          m_axis_rx_tvalid  ;
    wire          m_axis_rx_tready  ;
    wire [21 : 0] m_axis_rx_tuser   ;

    wire          cfg_interrupt               ;
    wire          cfg_interrupt_rdy           ;
    wire          cfg_interrupt_assert        ;
    wire [7 : 0]  cfg_interrupt_di            ;
    wire [7 : 0]  cfg_interrupt_do            ;
    wire [2 : 0]  cfg_interrupt_mmenable      ;
    wire          cfg_interrupt_msienable     ;
    wire          cfg_interrupt_msixenable    ;
    wire          cfg_interrupt_msixfm        ;
    wire          cfg_interrupt_stat          ;

    wire [7 : 0] cfg_bus_number      ;
    wire [4 : 0] cfg_device_number   ;
    wire [2 : 0] cfg_function_number ;
    wire [2 : 0] cfg_pcie_link_state ;

    wire [15:0] localID ;
    
    wire pcie_user_clk;
    wire cfg_trn_pending ;

    //assign m_axis_rx_tready = 1'b1;
    wire  cfg_turnoff_ok ;

    wire                            rx_bar0_valid     ;
    wire                            rx_bar0_sof       ;
    wire [3:0]                      rx_bar0_sof_index ;
    wire                            rx_bar0_eof       ;
    wire [3:0]                      rx_bar0_eof_index ;
    wire [C_PCI_DATA_WIDTH-1 : 0]   rx_bar0_data      ;

    wire                            rx_out_valid     ;
    wire                            rx_out_sof       ;
    wire                            rx_out_eof       ;
    wire    [3:0]                   rx_out_eof_index ;
    wire    [C_PCI_DATA_WIDTH -1:0] rx_out_data       ;

    wire                  wrReq_valid    ;
    wire [C_PCI_DATA_WIDTH-1:0] wrReq_data     ;
    wire                  wrReq_eof      ;
    wire [3:0]            wrReq_lastBe   ;
    wire [3:0]            wrReq_firstBe  ;
    wire                  wrReq_fmt      ;
    wire                  wrReq_type     ;
    wire [15:0]           wrReq_reqid    ;
    wire [63:0]           wrReq_address  ;
    wire [7:0]            wrReq_tag      ;
    wire [9:0]            wrReq_dwlen    ;
    wire [2:0]            wrReq_tc       ;
    wire [2:0]            wrReq_attr     ;
    wire [1:0]            wrReq_at       ;

    wire                   rdReq_valid   ;
    wire [C_PCI_DATA_WIDTH-1:0]  rdReq_data    ;
    wire                   rdReq_eof     ;
    wire [3:0]             rdReq_lastBe  ;
    wire [3:0]             rdReq_firstBe ;
    wire                   rdReq_fmt     ;
    wire                   rdReq_type    ;
    wire [15:0]            rdReq_reqid   ;
    wire [63:0]            rdReq_address ;
    wire [7:0]             rdReq_tag     ;
    wire [9:0]             rdReq_dwlen   ;
    wire [2:0]             rdReq_tc      ;
    wire [2:0]             rdReq_attr    ;
    wire [1:0]             rdReq_at      ;

    wire  [3:0]     rdCpld_eof_index ;
    wire            rdCpld_eof       ;
    wire            rdCpld_valid     ;
    wire  [9:0]     rdCpld_dwLen     ;
    wire  [7:0]     rdCpld_tag       ;
    wire  [2:0]     rdCpld_TC        ;
    wire  [2:0]     rdCpld_attr      ;
    wire  [1:0]     rdCpld_at        ;
    wire  [11:0]    rdCpld_bytecnt   ;
    wire  [6:0]     rdCpld_lowaddr   ;
    wire  [C_PCI_DATA_WIDTH-1 : 0]   rdCpld_data      ;
    wire  [15:0]    rdCpld_reqid     ;
    wire  [15:0]    rdCpld_cplid     ;
    wire  [2:0]     rdCpld_status    ;

//*******************INSTANCE AREA***************************************************/

    IBUF pcie_reset_n_ibuf(
      .O(pcie_reset_n),
      .I(i_pcie_reset_n)
    );

    IBUFDS_GTE2 refclk_ibuf (
      .O(pcie_refclk),
      .ODIV2(),
      .I(i_pcie_refclk_p),
      .IB(i_pcie_refclk_n),
      .CEB(1'b0)
    );

    pcie_7x_x2 pcie_7x_x2_inst (
      //PCI Express Interface
      .pci_exp_txp(o_pcie_txp), // output wire [1 : 0] pci_exp_txp
      .pci_exp_txn(o_pcie_txn), // output wire [1 : 0] pci_exp_txn
      .pci_exp_rxp(i_pcie_rxp), // input wire  [1 : 0] pci_exp_rxp
      .pci_exp_rxn(i_pcie_rxn), // input wire  [1 : 0] pci_exp_rxn

      .sys_clk  (pcie_refclk ), // input wire sys_clk
      .sys_rst_n(pcie_reset_n), // input wire sys_rst_n

      .pcie_drp_clk (pcie_drp_clk ), // input wire pcie_drp_clk
      .pcie_drp_en  (1'b0  ), // input wire pcie_drp_en
      .pcie_drp_we  (1'b0  ), // input wire pcie_drp_we
      .pcie_drp_addr(pcie_drp_addr), // input wire [8 : 0] pcie_drp_addr
      .pcie_drp_di  (pcie_drp_di  ), // input wire [15 : 0] pcie_drp_di
      .pcie_drp_do  (pcie_drp_do  ), // output wire [15 : 0] pcie_drp_do
      .pcie_drp_rdy (pcie_drp_rdy ), // output wire pcie_drp_rdy

      //common
      .user_clk_out  (pcie_user_clk  ), // output wire user_clk_out
      .user_reset_out(user_reset_out), // output wire user_reset_out
      .user_lnk_up   (user_lnk_up   ), // output wire user_lnk_up
      .user_app_rdy  (user_app_rdy  ), // output wire user_app_rdy

      //AXI-S Interface
      .s_axis_tx_tready(s_axis_tx_tready), // output wire s_axis_tx_tready          
      .s_axis_tx_tdata (s_axis_tx_tdata ), // input  wire [63 : 0] s_axis_tx_tdata  
      .s_axis_tx_tkeep (s_axis_tx_tkeep ), // input  wire [7 : 0] s_axis_tx_tkeep   
      .s_axis_tx_tlast (s_axis_tx_tlast ), // input  wire s_axis_tx_tlast           
      .s_axis_tx_tvalid(s_axis_tx_tvalid), // input  wire s_axis_tx_tvalid          
      .s_axis_tx_tuser (s_axis_tx_tuser ), // input  wire [3 : 0] s_axis_tx_tuser   

      .m_axis_rx_tdata (m_axis_rx_tdata ), // output wire [63 : 0] m_axis_rx_tdata
      .m_axis_rx_tkeep (m_axis_rx_tkeep ), // output wire [7 : 0] m_axis_rx_tkeep
      .m_axis_rx_tlast (m_axis_rx_tlast ), // output wire m_axis_rx_tlast
      .m_axis_rx_tvalid(m_axis_rx_tvalid), // output wire m_axis_rx_tvalid
      .m_axis_rx_tready(m_axis_rx_tready), // input  wire m_axis_rx_tready
      .m_axis_rx_tuser (m_axis_rx_tuser ), // output wire [21 : 0] m_axis_rx_tuser

      //configuration control
      //cfg for root port this is used in TLPs generated inside the core

      .cfg_ds_bus_number     (8'd0     ), // input wire [7 : 0] cfg_ds_bus_number
      .cfg_ds_device_number  (5'd0     ), // input wire [4 : 0] cfg_ds_device_number
      .cfg_ds_function_number(3'd0     ), // input wire [2 : 0] cfg_ds_function_number
      //configuration Device serial number
      .cfg_dsn(64'd0),                                      // input wire [63 : 0] cfg_dsn
      
      //power managent
      .cfg_pm_force_state   (cfg_pm_force_state   ), // input wire [1 : 0] cfg_pm_force_state
      .cfg_pm_force_state_en(cfg_pm_force_state_en), // input wire cfg_pm_force_state_en
      .cfg_pm_halt_aspm_l0s (cfg_pm_halt_aspm_l0s ), // input wire cfg_pm_halt_aspm_l0s
      .cfg_pm_halt_aspm_l1  (cfg_pm_halt_aspm_l1  ), // input wire cfg_pm_halt_aspm_l1
      .cfg_pm_send_pme_to   (cfg_pm_send_pme_to   ), // input wire cfg_pm_send_pme_to
      .cfg_pm_wake          (cfg_pm_wake          ), // input wire cfg_pm_wake
      
      //some types of tlp send enable
      .rx_np_ok (rx_np_ok ), // input wire rx_np_ok
      .rx_np_req(rx_np_req), // input wire rx_np_req
      .tx_cfg_gnt (tx_cfg_gnt), // input wire tx_cfg_gnt

      //flow control Interface
      .fc_cpld(fc_cpld),  // output wire [11 : 0] fc_cpld 
      .fc_cplh(fc_cplh),  // output wire [7 : 0]  fc_cplh 
      .fc_npd (fc_npd ),  // output wire [11 : 0] fc_npd  
      .fc_nph (fc_nph ),  // output wire [7 : 0]  fc_nph  
      .fc_pd  (fc_pd  ),  // output wire [11 : 0] fc_pd   
      .fc_ph  (fc_ph  ),  // output wire [7 : 0]  fc_ph   
      .fc_sel (fc_sel ),  // input  wire [2 : 0]  fc_sel  

      //interrupt control interface
      .cfg_interrupt            (cfg_interrupt            ),  // input  wire          cfg_interrupt
      .cfg_interrupt_rdy        (cfg_interrupt_rdy        ),  // output wire          cfg_interrupt_rdy
      .cfg_interrupt_assert     (cfg_interrupt_assert     ),  // input  wire          cfg_interrupt_assert
      .cfg_interrupt_di         (cfg_interrupt_di         ),  // input  wire [7 : 0]  cfg_interrupt_di
      .cfg_interrupt_do         (cfg_interrupt_do         ),  // output wire [7 : 0]  cfg_interrupt_do
      .cfg_interrupt_mmenable   (cfg_interrupt_mmenable   ),  // output wire [2 : 0]  cfg_interrupt_mmenable
      .cfg_interrupt_msienable  (cfg_interrupt_msienable  ),  // output wire          cfg_interrupt_msienable
      .cfg_interrupt_msixenable (cfg_interrupt_msixenable ),  // output wire          cfg_interrupt_msixenable
      .cfg_interrupt_msixfm     (cfg_interrupt_msixfm     ),  // output wire          cfg_interrupt_msixfm
      .cfg_interrupt_stat       (cfg_interrupt_stat       ),  // input  wire          cfg_interrupt_stat
      
      //config status interface
      .cfg_status                   (cfg_status                   ), // output wire [15 : 0] cfg_status -- this bus is not supported
      .cfg_command                  (cfg_command                  ), // output wire [15 : 0] cfg_command
      .cfg_dstatus                  (cfg_dstatus                  ), // output wire [15 : 0] cfg_dstatus
      .cfg_dcommand                 (cfg_dcommand                 ), // output wire [15 : 0] cfg_dcommand
      .cfg_lstatus                  (cfg_lstatus                  ), // output wire [15 : 0] cfg_lstatus
      .cfg_lcommand                 (cfg_lcommand                 ),  // output wire [15 : 0] cfg_lcommand
      .cfg_dcommand2                (cfg_dcommand2                ),  // output wire [15 : 0] cfg_dcommand2
      .cfg_pcie_link_state          (cfg_pcie_link_state          ),  // output wire [2 : 0] cfg_pcie_link_state
      .cfg_pmcsr_pme_en             (cfg_pmcsr_pme_en             ),  // output wire cfg_pmcsr_pme_en
      .cfg_pmcsr_powerstate         (cfg_pmcsr_powerstate         ),  // output wire [1 : 0] cfg_pmcsr_powerstate
      .cfg_pmcsr_pme_status         (cfg_pmcsr_pme_status         ),  // output wire cfg_pmcsr_pme_status
      .cfg_received_func_lvl_rst    (cfg_received_func_lvl_rst    ),  // output wire cfg_received_func_lvl_rst
      .cfg_trn_pending              (cfg_trn_pending              ),  // input wire cfg_trn_pending
      .cfg_pciecap_interrupt_msgnum (cfg_pciecap_interrupt_msgnum ),  // input wire [4 : 0] cfg_pciecap_interrupt_msgnum
      .cfg_to_turnoff               (cfg_to_turnoff               ),  // output wire cfg_to_turnoff
      .cfg_turnoff_ok               (cfg_turnoff_ok               ),  // input wire cfg_turnoff_ok
      .cfg_bus_number               (cfg_bus_number               ),  // output wire [7 : 0] cfg_bus_number      
      .cfg_device_number            (cfg_device_number            ),  // output wire [4 : 0] cfg_device_number   
      .cfg_function_number          (cfg_function_number          ),  // output wire [2 : 0] cfg_function_number 
      
      .cfg_bridge_serr_en(cfg_bridge_serr_en),                      // output wire cfg_bridge_serr_en
      .cfg_slot_control_electromech_il_ctl_pulse(cfg_slot_control_electromech_il_ctl_pulse),    // output wire cfg_slot_control_electromech_il_ctl_pulse
      .cfg_root_control_syserr_corr_err_en(cfg_root_control_syserr_corr_err_en),                // output wire cfg_root_control_syserr_corr_err_en
      .cfg_root_control_syserr_non_fatal_err_en(cfg_root_control_syserr_non_fatal_err_en),      // output wire cfg_root_control_syserr_non_fatal_err_en
      .cfg_root_control_syserr_fatal_err_en(cfg_root_control_syserr_fatal_err_en),              // output wire cfg_root_control_syserr_fatal_err_en
      .cfg_root_control_pme_int_en(cfg_root_control_pme_int_en),                                // output wire cfg_root_control_pme_int_en
      .cfg_aer_rooterr_corr_err_reporting_en(cfg_aer_rooterr_corr_err_reporting_en),            // output wire cfg_aer_rooterr_corr_err_reporting_en
      .cfg_aer_rooterr_non_fatal_err_reporting_en(cfg_aer_rooterr_non_fatal_err_reporting_en),  // output wire cfg_aer_rooterr_non_fatal_err_reporting_en
      .cfg_aer_rooterr_fatal_err_reporting_en(cfg_aer_rooterr_fatal_err_reporting_en),          // output wire cfg_aer_rooterr_fatal_err_reporting_en
      .cfg_aer_rooterr_corr_err_received(cfg_aer_rooterr_corr_err_received),                    // output wire cfg_aer_rooterr_corr_err_received
      .cfg_aer_rooterr_non_fatal_err_received(cfg_aer_rooterr_non_fatal_err_received),          // output wire cfg_aer_rooterr_non_fatal_err_received
      .cfg_aer_rooterr_fatal_err_received(cfg_aer_rooterr_fatal_err_received),                  // output wire cfg_aer_rooterr_fatal_err_received
      .cfg_vc_tcvc_map(cfg_vc_tcvc_map), // output wire [6 : 0] cfg_vc_tcvc_map
      .tx_buf_av  (tx_buf_av   ),            // output wire [5 : 0] tx_buf_av
      .tx_cfg_req (tx_cfg_req  ),              // output wire tx_cfg_req
      .tx_err_drop(tx_err_drop)            // output wire tx_err_drop
  );

    /* vio_saxi vio_saxi_inst (
        .clk(pcie_user_clk),                // input wire clk
        .probe_in0 (s_axis_tx_tready),    // input wire [0 : 0] probe_in0
        .probe_out0(s_axis_tx_tdata ),  // output wire [63 : 0] probe_out0
        .probe_out1(s_axis_tx_tkeep ),  // output wire [7 : 0] probe_out1
        .probe_out2(s_axis_tx_tlast ),  // output wire [0 : 0] probe_out2
        .probe_out3(s_axis_tx_tvalid),  // output wire [0 : 0] probe_out3
        .probe_out4(s_axis_tx_tuser )  // output wire [3 : 0] probe_out4
    ); */
    ila_1 ila_saxi(
        .clk(pcie_user_clk),
        .probe0(s_axis_tx_tready ),
        .probe1(s_axis_tx_tdata ),
        .probe2(s_axis_tx_tkeep ),
        .probe3(s_axis_tx_tlast ),
        .probe4(s_axis_tx_tvalid),
        .probe5(s_axis_tx_tuser )
    );

    ila_0 ila_pcie_number (
        .clk   (pcie_user_clk), // input wire clk
        .probe0(cfg_bus_number     ), // input wire [7:0]  probe0  
        .probe1(cfg_device_number  ), // input wire [4:0]  probe1 
        .probe2(cfg_function_number), // input wire [2:0]  probe2 
        .probe3(cfg_pcie_link_state) // input wire [2:0]  probe3
    );
    ila_maxi ila_maxi_inst(
        .clk(pcie_user_clk),
        .probe0(m_axis_rx_tdata ),
        .probe1(m_axis_rx_tkeep ),
        .probe2(m_axis_rx_tlast ),
        .probe3(m_axis_rx_tvalid),
        .probe4(m_axis_rx_tready),
        .probe5(m_axis_rx_tuser )
    );
    
    rx_pkt_router #(
        .DATA_WIDTH  (C_PCI_DATA_WIDTH)
    )
    rx_pkt_router_inst(
        .i_clk       (pcie_user_clk  ), //input wire 
        .i_rst       (user_reset_out ), //input wire 

        .m_axis_rx_data   (m_axis_rx_tdata  ) ,//input  wire [DATA_WIDTH-1 : 0] m_axis_rx_data   
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
        .DATA_WIDTH (C_PCI_DATA_WIDTH)
    )
    rx_pkt_realign_inst0(
        .i_clk  (pcie_user_clk ), //input   wire    
        .i_rst  (user_reset_out), //input   wire    

        .i_rx_in_valid     (rx_bar0_valid    ), //input   wire                      
        .i_rx_in_data      (rx_bar0_data     ), //input   wire    [DATA_WIDTH -1:0] 
        .i_rx_in_sof       (rx_bar0_sof      ), //input   wire                      
        .i_rx_in_sof_index (rx_bar0_sof_index), //input   wire    [3:0]             
        .i_rx_in_eof       (rx_bar0_eof      ), //input   wire                      
        .i_rx_in_eof_index (rx_bar0_eof_index), //input   wire    [3:0]             

        .rx_out_valid     (rx_out_valid    ), //output  wire                  
        .rx_out_sof       (rx_out_sof      ), //output  reg                   
        .rx_out_eof       (rx_out_eof      ), //output  reg                   
        .rx_out_eof_index (rx_out_eof_index), //output  reg     [3:0]         
        .rx_out_data      (rx_out_data       )  //output  reg     [DATA_WIDTH -1:0] 
    );

    /* ila_2 ila_realign_in(
        .clk(pcie_user_clk),
        .probe0(rx_bar0_valid    ),
        .probe1(rx_bar0_data     ),
        .probe2(rx_bar0_sof      ),
        .probe3(rx_bar0_sof_index),
        .probe4(rx_bar0_eof      ),
        .probe5(rx_bar0_eof_index)
    ); */


    /* ila_1 ila_realign(
        .clk(pcie_user_clk),
        .probe0(rx_out_valid    ),
        .probe1(rx_out_sof      ),
        .probe2(rx_out_eof      ),
        .probe3(rx_out_eof_index),
        .probe4(rx_out_data       )
    ); */

    rx_pkt_unpack #(
        .DATA_WIDTH (C_PCI_DATA_WIDTH)
    )
    rx_pkt_unpack_inst(
        .i_clk (pcie_user_clk) , //input wire 
        .i_rst (user_reset_out) , //input wire 

        .rx_in_valid     (rx_out_valid    ) , //input wire                  
        .rx_in_data      (rx_out_data     ) , //input wire [DATA_WIDTH-1:0] 
        .rx_in_sof       (rx_out_sof      ) , //input wire                  
        .rx_in_eof       (rx_out_eof      ) , //input wire                  
        .rx_in_eof_index (rx_out_eof_index) , //input wire [3:0]            

        .wrReq_valid    (wrReq_valid  ) , //output reg                     
        .wrReq_data     (wrReq_data   ) , //output reg [DATA_WIDTH-1:0]    
        .wrReq_eof      (wrReq_eof    ) , //output reg                     
        .wrReq_lastBe   (wrReq_lastBe ) , //output reg [3:0]               
        .wrReq_firstBe  (wrReq_firstBe) , //output reg [3:0]               
        .wrReq_fmt      (wrReq_fmt    ) , //output reg                     
        .wrReq_type     (wrReq_type   ) , //output reg                     
        .wrReq_reqid    (wrReq_reqid  ) , //output reg [15:0]              
        .wrReq_address  (wrReq_address) , //output reg [63:0]              
        .wrReq_tag      (wrReq_tag    ) , //output reg [7:0]               
        .wrReq_dwlen    (wrReq_dwlen  ) , //output reg [9:0]               
        .wrReq_tc       (wrReq_tc     ) , //output reg [2:0]               
        .wrReq_attr     (wrReq_attr   ) , //output reg [2:0]               
        .wrReq_at       (wrReq_at     ) , //output reg [1:0]               

        .rdReq_valid    (rdReq_valid  ) , //output reg                   rdReq_valid    
        .rdReq_data     (rdReq_data   ) , //output reg [DATA_WIDTH-1:0]  rdReq_data     
        .rdReq_eof      (rdReq_eof    ) , //output reg                   rdReq_eof      
        .rdReq_lastBe   (rdReq_lastBe ) , //output reg [3:0]             rdReq_lastBe   
        .rdReq_firstBe  (rdReq_firstBe) , //output reg [3:0]             rdReq_firstBe  
        .rdReq_fmt      (rdReq_fmt    ) , //output reg                   rdReq_fmt      
        .rdReq_type     (rdReq_type   ) , //output reg                   rdReq_type     
        .rdReq_reqid    (rdReq_reqid  ) , //output reg [15:0]            rdReq_reqid    
        .rdReq_address  (rdReq_address) , //output reg [63:0]            rdReq_address  
        .rdReq_tag      (rdReq_tag    ) , //output reg [7:0]             rdReq_tag      
        .rdReq_dwlen    (rdReq_dwlen  ) , //output reg [9:0]             rdReq_dwlen    
        .rdReq_tc       (rdReq_tc     ) , //output reg [2:0]             rdReq_tc       
        .rdReq_attr     (rdReq_attr   ) , //output reg [2:0]             rdReq_attr     
        .rdReq_at       (rdReq_at     )   //output reg [1:0]             rdReq_at       
    );

    ila_3 ila_upkt_wr(
        .clk(pcie_user_clk),
        .probe0  (wrReq_valid  ), //width:1
        .probe1  (wrReq_data   ), //width:64
        .probe2  (wrReq_eof    ), //width:1
        .probe3  (wrReq_lastBe ), //width:4
        .probe4  (wrReq_firstBe), //width:4
        .probe5  (wrReq_fmt    ), //width:1
        .probe6  (wrReq_type   ), //width:1
        .probe7  (wrReq_reqid  ), //width:16
        .probe8  (wrReq_address), //width:64
        .probe9  (wrReq_tag    ), //width:8
        .probe10 (wrReq_dwlen  ), //width:10
        .probe11 (wrReq_tc     ), //width:3
        .probe12 (wrReq_attr   ), //width:3
        .probe13 (wrReq_at     )  //width:2
    );

    ila_3 ila_upkt_rd(
        .clk(pcie_user_clk),
        .probe0  (rdReq_valid  ), //width:1
        .probe1  (rdReq_data   ), //width:64
        .probe2  (rdReq_eof    ), //width:1
        .probe3  (rdReq_lastBe ), //width:4
        .probe4  (rdReq_firstBe), //width:4
        .probe5  (rdReq_fmt    ), //width:1
        .probe6  (rdReq_type   ), //width:1
        .probe7  (rdReq_reqid  ), //width:16
        .probe8  (rdReq_address), //width:64
        .probe9  (rdReq_tag    ), //width:8
        .probe10 (rdReq_dwlen  ), //width:10
        .probe11 (rdReq_tc     ), //width:3
        .probe12 (rdReq_attr   ), //width:3
        .probe13 (rdReq_at     )  //width:2
    );

    bar_engine #(
        .DATA_WIDTH     (C_PCI_DATA_WIDTH) ,
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

        .rdReq_valid    (rdReq_valid  ) , //input wire                      
        .rdReq_address  (rdReq_address) , //input wire [31:0]               
        .rdReq_reqid    (rdReq_reqid  ) , //input    wire       [15:0]          
        .rdReq_tag      (rdReq_tag    ) , //input    wire      [7:0]           
        .rdReq_dwlen    (rdReq_dwlen  ) , //input    wire      [9:0]           
        .rdReq_TC       (rdReq_tc     ) , //input    wire      [2:0]           
        .rdReq_attr     (rdReq_attr   ) , //input    wire      [2:0]           
        .rdReq_at       (rdReq_at     ) , //input    wire      [1:0]           


        .maxi_lite_awaddr     (maxi_lite_awaddr ) , //output reg  [31:0] maxi_lite_awaddr  
        .maxi_lite_awready    (maxi_lite_awready) , //input  wire        maxi_lite_awready 
        .maxi_lite_awvalid    (maxi_lite_awvalid) , //output reg         maxi_lite_awvalid 

        .maxi_lite_wdata   (maxi_lite_wdata ) , //output reg  [AXIDATA_WIDTH -1 :0]   
        .maxi_lite_wready  (maxi_lite_wready) , //input  wire                         
        .maxi_lite_wstrb   (maxi_lite_wstrb ) , //output wire [AXIDATA_WIDTH/8 -1:0]  
        .maxi_lite_wvalid  (maxi_lite_wvalid) , //output reg                          

        .maxi_lite_bready    (maxi_lite_bready) , //output wire               
        .maxi_lite_bresp     (maxi_lite_bresp ) , //input  wire [1:0]         
        .maxi_lite_bvalid    (maxi_lite_bvalid) , //input  wire               

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
        .rdCpld_eof_index   (rdCpld_eof_index), //input wire  [3:0]               
        .rdCpld_eof         (rdCpld_eof      ), //input wire        
        .rdCpld_valid       (rdCpld_valid    ) , //output reg                  
        .rdCpld_dwLen       (rdCpld_dwLen    ) , //output reg  [9:0]           
        .rdCpld_tag         (rdCpld_tag      ) , //output reg  [7:0]           
        .rdCpld_TC          (rdCpld_TC       ) , //output reg  [2:0]           
        .rdCpld_attr        (rdCpld_attr     ) , //output reg  [2:0]           
        .rdCpld_at          (rdCpld_at       ) , //output reg  [1:0]           
        .rdCpld_bytecnt     (rdCpld_bytecnt  ) , //output reg  [11:0]          
        .rdCpld_lowaddr     (rdCpld_lowaddr  ) , //output reg  [6:0]           
        .rdCpld_data        (rdCpld_data     ) , //output reg  [63:0]         
        .rdCpld_reqid       (rdCpld_reqid    ) , //output reg  [15:0]          
        .rdCpld_cplid       (rdCpld_cplid    ) , //output reg  [15:0]          
        .rdCpld_status      (rdCpld_status   )   //output reg  [2:0]           
    );

    ila_6 ila_cpld(
        .clk(cfg_axi_clk), // input wire clk
        .probe0 (rdCpld_valid  ), // width:  1  
        .probe1 (rdCpld_dwLen  ), // width: 10 
        .probe2 (rdCpld_tag    ), // width:  8  
        .probe3 (rdCpld_TC     ), // width:  3  
        .probe4 (rdCpld_attr   ), // width:  3  
        .probe5 (rdCpld_at     ), // width:  2  
        .probe6 (rdCpld_bytecnt), // width: 12 
        .probe7 (rdCpld_lowaddr), // width:  7  
        .probe8 (rdCpld_data   ), // width: 64 
        .probe9 (rdCpld_reqid  ), // width: 16 
        .probe10(rdCpld_cplid  ), // width: 16 
        .probe11(rdCpld_status ),  // width:  3  
        .probe12(rdCpld_eof_index),
        .probe13(rdCpld_eof      )
    );

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

    /* bar_cpl_buffer #(
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
 */

//*******************PROGRAM AREA****************************************************/
  assign cfg_pm_force_state    = 2'd0 ;
  assign cfg_pm_force_state_en = 1'd0 ;
  assign cfg_pm_halt_aspm_l0s  = 1'd0 ;
  assign cfg_pm_halt_aspm_l1   = 1'd0 ;
  assign cfg_pm_send_pme_to    = 1'd0 ;
  assign cfg_pm_wake           = 1'd0 ;
  assign rx_np_ok = 1'b1;//always ready receive non-posted tlp
  assign rx_np_req = 1'b1;//always ready receive non-posted request tlp
  assign tx_cfg_gnt = 1'b1  ; //allow the core to transmit an internally generated tlp

  assign fc_sel = 3'b001;

  assign o_led = 4'b1111;

    assign cfg_interrupt = 1'b0;//Assert to request an interrupt. Leave asserted until the cfg_interrupt_rdy =1
    assign cfg_interrupt_assert = 1'b0;//Assert and Deassert messages for Legacy interrupts Not used for MSI interrupts.
    assign cfg_interrupt_di = 8'd0;//Configuration Interrupt Data In
    assign cfg_interrupt_stat = 1'b0;//=0 Clears when interrupt is cleared by the Interrupt handler.=1  user set interrupt status
    assign cfg_trn_pending = 0; 
    assign cfg_turnoff_ok = 0;

    assign localID = {cfg_bus_number,cfg_device_number,cfg_function_number};

endmodule
