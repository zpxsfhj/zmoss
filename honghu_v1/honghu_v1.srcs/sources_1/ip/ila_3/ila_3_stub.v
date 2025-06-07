// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Sat May 31 21:00:11 2025
// Host        : LAPTOP-1HJSIG13 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub e:/zmoss/honghu_v1/honghu_v1.srcs/sources_1/ip/ila_3/ila_3_stub.v
// Design      : ila_3
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tfgg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2019.1" *)
module ila_3(clk, probe0, probe1, probe2, probe3, probe4, probe5, 
  probe6, probe7, probe8, probe9, probe10, probe11, probe12, probe13)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[0:0],probe1[63:0],probe2[0:0],probe3[3:0],probe4[3:0],probe5[0:0],probe6[0:0],probe7[15:0],probe8[63:0],probe9[7:0],probe10[9:0],probe11[2:0],probe12[2:0],probe13[1:0]" */;
  input clk;
  input [0:0]probe0;
  input [63:0]probe1;
  input [0:0]probe2;
  input [3:0]probe3;
  input [3:0]probe4;
  input [0:0]probe5;
  input [0:0]probe6;
  input [15:0]probe7;
  input [63:0]probe8;
  input [7:0]probe9;
  input [9:0]probe10;
  input [2:0]probe11;
  input [2:0]probe12;
  input [1:0]probe13;
endmodule
