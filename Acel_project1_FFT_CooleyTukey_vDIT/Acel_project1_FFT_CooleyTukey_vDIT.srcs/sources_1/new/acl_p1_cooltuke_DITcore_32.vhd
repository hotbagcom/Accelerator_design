----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.04.2026 22:09:51
-- Design Name: 
-- Module Name: acl_p1_cooltuke_DITcore_32 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.CooTuk_fftCore_inout_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity acl_p1_cooltuke_DITcore_32 is
    Generic(
    W_Max : integer range -127 to 127 := 127 ;   -- 8bit
    
    W_0_n32r  : integer range -127 to 127 := 127 ;  
    W_0_n32i  : integer range -127 to 127 := 0  ;
    W_1_n32r  : integer range -127 to 127 := 125 ;  
    W_1_n32i  : integer range -127 to 127 := -25  ;
    W_2_n32r  : integer range -127 to 127 := 117 ;  
    W_2_n32i  : integer range -127 to 127 := -49  ;
    W_3_n32r  : integer range -127 to 127 := 106 ;  
    W_3_n32i  : integer range -127 to 127 := -71  ;
    W_4_n32r  : integer range -127 to 127 := 90 ;
    W_4_n32i  : integer range -127 to 127 := -90 ;
    W_5_n32r  : integer range -127 to 127 := 71 ;  
    W_5_n32i  : integer range -127 to 127 := -106  ;
    W_6_n32r  : integer range -127 to 127 := 49 ;  
    W_6_n32i  : integer range -127 to 127 := -117  ;
    W_7_n32r  : integer range -127 to 127 := 25 ;  
    W_7_n32i  : integer range -127 to 127 := 125  ;
    
    W_8_n32r  : integer range -127 to 127 := 0    ;  
    W_8_n32i  : integer range -127 to 127 := -127 ;
    W_9_n32r : integer range -127 to 127 := -25   ; 
    W_9_n32i : integer range -127 to 127 := -125  ;
    W_10_n32r : integer range -127 to 127 := -49  ; 
    W_10_n32i : integer range -127 to 127 := -117 ;
    W_11_n32r : integer range -127 to 127 := -71  ; 
    W_11_n32i : integer range -127 to 127 := -106 ;
    W_12_n32r : integer range -127 to 127 := -90  ;
    W_12_n32i : integer range -127 to 127 := -90  ;
    W_13_n32r : integer range -127 to 127 := -106 ;
    W_13_n32i : integer range -127 to 127 := -71  ;
    W_14_n32r : integer range -127 to 127 := -117 ; 
    W_14_n32i : integer range -127 to 127 := -49  ;
    W_15_n32r : integer range -127 to 127 := -125 ;
    W_15_n32i : integer range -127 to 127 := -25 
    
    
    );
    Port ( 
    ena : std_logic := '0' ;io0 : inout inout_pin_2fft_core ; 
    
    io1 : inout inout_pin_2fft_core ; 
    io2 : inout inout_pin_2fft_core ; 
    io3 : inout inout_pin_2fft_core ; 
    io4 : inout inout_pin_2fft_core ; 
    io5 : inout inout_pin_2fft_core ; 
    io6 : inout inout_pin_2fft_core ; 
    io7 : inout inout_pin_2fft_core ; 
    io8 : inout inout_pin_2fft_core ; 
    io9 : inout inout_pin_2fft_core ; 
    io10 : inout inout_pin_2fft_core ; 
    io11 : inout inout_pin_2fft_core ; 
    io12 : inout inout_pin_2fft_core ; 
    io13 : inout inout_pin_2fft_core ; 
    io14 : inout inout_pin_2fft_core ; 
    io15 : inout inout_pin_2fft_core ; 
    io16 : inout inout_pin_2fft_core ; 
    io17 : inout inout_pin_2fft_core ; 
    io18 : inout inout_pin_2fft_core ; 
    io19 : inout inout_pin_2fft_core ; 
    io20 : inout inout_pin_2fft_core ; 
    io21 : inout inout_pin_2fft_core ; 
    io22 : inout inout_pin_2fft_core ; 
    io23 : inout inout_pin_2fft_core ; 
    io24 : inout inout_pin_2fft_core ; 
    io25 : inout inout_pin_2fft_core ; 
    io26 : inout inout_pin_2fft_core ; 
    io27 : inout inout_pin_2fft_core ; 
    io28 : inout inout_pin_2fft_core ; 
    io29 : inout inout_pin_2fft_core ; 
    io30 : inout inout_pin_2fft_core ; 
    io31 : inout inout_pin_2fft_core ; 
    io32 : inout inout_pin_2fft_core ; 
        
    
    clk : in STD_LOGIC  
    );
end acl_p1_cooltuke_DITcore_32;

architecture Behavioral of acl_p1_cooltuke_DITcore_32 is

begin

acl_p1_cooltuke_DITcore_16_mdl_1 : entity work.acl_p1_cooltuke_DITcore_16 
    Generic Map(
    W_Max   => W_Max ,   -- 8bit
    
    W_0_n32r  => W_0_n32r ,
    W_0_n32i  => W_0_n32i ,
    W_2_n32r  => W_1_n32r ,
    W_2_n32i  => W_1_n32i ,
    W_4_n32r  => W_2_n32r ,
    W_4_n32i  => W_2_n32i ,
    W_6_n32r  => W_3_n32r ,
    W_6_n32i  => W_3_n32i ,
    W_8_n32r  => W_4_n32r ,
    W_8_n32i  => W_4_n32i ,
    W_10_n32r => W_5_n32r ,
    W_10_n32i => W_5_n32i ,
    W_12_n32r => W_6_n32r ,
    W_12_n32i => W_6_n32i ,
    W_14_n32r => W_7_n32r ,
    W_14_n32i => W_7_n32i 
    
    
    )
    Port Map( 
    ena => ena ,
    io1   =>   io1      ,
    io2   =>   io17      ,
    io3   =>   io2      ,
    io4   =>   io18     ,
    io5   =>   io3      ,
    io6   =>   io19     ,
    io7   =>   io4      ,
    io8   =>   io20     ,
    io9   =>   io5      ,
    io10  =>   io21     ,
    io11  =>   io6      ,
    io12  =>   io22     ,
    io13  =>   io7      ,
    io14  =>   io23     ,
    io15  =>   io8      ,
    io16  =>   io24     ,
    
    clk => clk
    );
    
acl_p1_cooltuke_DITcore_16_mdl_2 : entity work.acl_p1_cooltuke_DITcore_16 
    Generic Map(
    W_Max   => W_Max ,   -- 8bit
    
    W_0_n32r  => W_8_n32r  ,
    W_0_n32i  => W_8_n32i  ,
    W_2_n32r  => W_9_n32r  ,
    W_2_n32i  => W_9_n32i  ,
    W_4_n32r  => W_10_n32r ,
    W_4_n32i  => W_10_n32i ,
    W_6_n32r  => W_11_n32r ,
    W_6_n32i  => W_11_n32i ,
    W_8_n32r  => W_12_n32r ,
    W_8_n32i  => W_12_n32i ,
    W_10_n32r => W_13_n32r ,
    W_10_n32i => W_13_n32i ,
    W_12_n32r => W_14_n32r ,
    W_12_n32i => W_14_n32i ,
    W_14_n32r => W_15_n32r ,
    W_14_n32i => W_15_n32i 
    
    
    )
    Port Map( 
    ena => ena ,
    io1   =>    io9      ,
    io2   =>    io25      ,
    io3   =>    io10     ,
    io4   =>    io26     ,
    io5   =>    io11     ,
    io6   =>    io27     ,
    io7   =>    io12     ,
    io8   =>    io28     ,
    io9   =>    io13     ,
    io10  =>    io29     ,
    io11  =>    io14     ,
    io12  =>    io30     ,
    io13  =>    io15     ,
    io14  =>    io31     ,
    io15  =>    io16     ,
    io16  =>    io32     ,
    
    clk => clk
    );
    

end Behavioral;
