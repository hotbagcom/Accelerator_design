--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
--Date        : Thu Apr  9 00:16:09 2026
--Host        : DESKTOP-VQ00TNA running 64-bit major release  (build 9200)
--Command     : generate_target design_1_3_wrapper.bd
--Design      : design_1_3_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_3_wrapper is
  port (
    BTN_top_0 : in STD_LOGIC_VECTOR ( 4 downto 0 );
    CLK_top : in STD_LOGIC;
    LED_top_0 : out STD_LOGIC_VECTOR ( 15 downto 0 );
    RsRx : in STD_LOGIC;
    RsTx : out STD_LOGIC;
    SEGMENT4_top_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    SEGMENT7_top_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    SW_top_0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    reset : in STD_LOGIC
  );
end design_1_3_wrapper;

architecture STRUCTURE of design_1_3_wrapper is
  component design_1_3 is
  port (
    CLK_top : in STD_LOGIC;
    reset : in STD_LOGIC;
    SEGMENT4_top_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    SW_top_0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    BTN_top_0 : in STD_LOGIC_VECTOR ( 4 downto 0 );
    SEGMENT7_top_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    LED_top_0 : out STD_LOGIC_VECTOR ( 15 downto 0 );
    RsRx : in STD_LOGIC;
    RsTx : out STD_LOGIC
  );
  end component design_1_3;
begin
design_1_3_i: component design_1_3
     port map (
      BTN_top_0(4 downto 0) => BTN_top_0(4 downto 0),
      CLK_top => CLK_top,
      LED_top_0(15 downto 0) => LED_top_0(15 downto 0),
      RsRx => RsRx,
      RsTx => RsTx,
      SEGMENT4_top_0(3 downto 0) => SEGMENT4_top_0(3 downto 0),
      SEGMENT7_top_0(7 downto 0) => SEGMENT7_top_0(7 downto 0),
      SW_top_0(15 downto 0) => SW_top_0(15 downto 0),
      reset => reset
    );
end STRUCTURE;
