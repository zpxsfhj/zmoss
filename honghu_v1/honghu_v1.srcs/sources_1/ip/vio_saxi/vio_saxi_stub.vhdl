-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
-- Date        : Sun Mar  2 09:18:19 2025
-- Host        : LAPTOP-1HJSIG13 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               e:/zmoss/honghu_v1/honghu_v1.srcs/sources_1/ip/vio_saxi/vio_saxi_stub.vhdl
-- Design      : vio_saxi
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tfgg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vio_saxi is
  Port ( 
    clk : in STD_LOGIC;
    probe_in0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out0 : out STD_LOGIC_VECTOR ( 63 downto 0 );
    probe_out1 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    probe_out2 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out3 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out4 : out STD_LOGIC_VECTOR ( 3 downto 0 )
  );

end vio_saxi;

architecture stub of vio_saxi is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe_in0[0:0],probe_out0[63:0],probe_out1[7:0],probe_out2[0:0],probe_out3[0:0],probe_out4[3:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "vio,Vivado 2019.1";
begin
end;
