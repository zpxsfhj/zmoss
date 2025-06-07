// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Sun Mar  2 09:18:19 2025
// Host        : LAPTOP-1HJSIG13 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               e:/zmoss/honghu_v1/honghu_v1.srcs/sources_1/ip/vio_saxi/vio_saxi_stub.v
// Design      : vio_saxi
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tfgg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2019.1" *)
module vio_saxi(clk, probe_in0, probe_out0, probe_out1, 
  probe_out2, probe_out3, probe_out4)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_in0[0:0],probe_out0[63:0],probe_out1[7:0],probe_out2[0:0],probe_out3[0:0],probe_out4[3:0]" */;
  input clk;
  input [0:0]probe_in0;
  output [63:0]probe_out0;
  output [7:0]probe_out1;
  output [0:0]probe_out2;
  output [0:0]probe_out3;
  output [3:0]probe_out4;
endmodule
