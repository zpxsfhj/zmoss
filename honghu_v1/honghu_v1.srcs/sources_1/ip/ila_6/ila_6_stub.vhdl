-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
-- Date        : Sun Jul  6 10:57:44 2025
-- Host        : LAPTOP-1HJSIG13 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub E:/zmoss/honghu_v1/honghu_v1.srcs/sources_1/ip/ila_6/ila_6_stub.vhdl
-- Design      : ila_6
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tfgg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_6 is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe1 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    probe2 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe3 : in STD_LOGIC_VECTOR ( 2 downto 0 );
    probe4 : in STD_LOGIC_VECTOR ( 2 downto 0 );
    probe5 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    probe6 : in STD_LOGIC_VECTOR ( 11 downto 0 );
    probe7 : in STD_LOGIC_VECTOR ( 6 downto 0 );
    probe8 : in STD_LOGIC_VECTOR ( 63 downto 0 );
    probe9 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    probe10 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    probe11 : in STD_LOGIC_VECTOR ( 2 downto 0 );
    probe12 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe13 : in STD_LOGIC_VECTOR ( 0 to 0 )
  );

end ila_6;

architecture stub of ila_6 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[0:0],probe1[9:0],probe2[7:0],probe3[2:0],probe4[2:0],probe5[1:0],probe6[11:0],probe7[6:0],probe8[63:0],probe9[15:0],probe10[15:0],probe11[2:0],probe12[3:0],probe13[0:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "ila,Vivado 2019.1";
begin
end;
