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
    output wire [3:0]                 o_led 
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

    wire pcie_user_clk;

    assign s_axis_tx_tready = 1'b1;
    assign s_axis_tx_tvalid = 1'b0;

    assign m_axis_rx_tready = 1'b1;

    assign cfg_interrupt = 1'b0;




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
      .pcie_drp_en  (pcie_drp_en  ), // input wire pcie_drp_en
      .pcie_drp_we  (pcie_drp_we  ), // input wire pcie_drp_we
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
      .cfg_dsn(cfg_dsn),                                      // input wire [63 : 0] cfg_dsn
      
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
endmodule
