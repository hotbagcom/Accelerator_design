----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.04.2026 22:09:51
-- Design Name: 
-- Module Name: acl_p1_cooltuke_DITcore_16 - Behavioral
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

entity acl_p1_cooltuke_DITcore_16 is
    Generic(
    W_Max : integer range -127 to 127 := 127 ;   -- 8bit
    
    W_0_n32r  : integer range -127 to 127 := 127 ;  
    W_0_n32i  : integer range -127 to 127 := 0  ;
    W_2_n32r  : integer range -127 to 127 := 117 ;  
    W_2_n32i  : integer range -127 to 127 := -49  ;
    W_4_n32r  : integer range -127 to 127 := 90 ;
    W_4_n32i  : integer range -127 to 127 := -90 ;
    W_6_n32r  : integer range -127 to 127 := 49 ;  
    W_6_n32i  : integer range -127 to 127 := -117  ;
    
    W_8_n32r  : integer range -127 to 127 := 0 ;    
    W_8_n32i  : integer range -127 to 127 := -127 ;
    W_10_n32r : integer range -127 to 127 := -49 ;  
    W_10_n32i : integer range -127 to 127 := -117  ;
    W_12_n32r : integer range -127 to 127 := -90 ;
    W_12_n32i : integer range -127 to 127 := -90 ;
    W_14_n32r : integer range -127 to 127 := -117 ;  
    W_14_n32i : integer range -127 to 127 := -49  
    
    
    );
    Port ( 
    ena : std_logic := '0' ;
    io1  : inout inout_pin_2fft_core ;
    io2  : inout inout_pin_2fft_core ;
    io3  : inout inout_pin_2fft_core ;
    io4  : inout inout_pin_2fft_core ;
    io5  : inout inout_pin_2fft_core ;
    io6  : inout inout_pin_2fft_core ;
    io7  : inout inout_pin_2fft_core ;
    io8  : inout inout_pin_2fft_core ;
    io9  : inout inout_pin_2fft_core ;
    io10 : inout inout_pin_2fft_core ;
    io11 : inout inout_pin_2fft_core ;
    io12 : inout inout_pin_2fft_core ;
    io13 : inout inout_pin_2fft_core ;
    io14 : inout inout_pin_2fft_core ;
    io15 : inout inout_pin_2fft_core ;
    io16 : inout inout_pin_2fft_core ;
    
    
    clk : in STD_LOGIC  
    );
end acl_p1_cooltuke_DITcore_16;

architecture Behavioral of acl_p1_cooltuke_DITcore_16 is

begin

acl_p1_cooltuke_DITcore_8_mdl_1 : entity work.acl_p1_cooltuke_DITcore_8 
    Generic Map(
    W_Max => W_Max ,
    
    W_0_n32r  => W_0_n32r , 
    W_0_n32i  => W_0_n32i ,
    W_4_n32r  => W_2_n32r ,
    W_4_n32i  => W_2_n32i ,
    W_8_n32r  => W_4_n32r , 
    W_8_n32i  => W_4_n32i ,
    W_12_n32r => W_6_n32r ,
    W_12_n32i => W_6_n32i 
    
    )
    Port Map( 
    ena => ena , 
    io1 => io1  ,
    io2 => io9  ,
    io3 => io2  ,
    io4 => io10 ,
    io5 => io3  ,
    io6 => io11 ,
    io7 => io4  ,
    io8 => io12 ,
    
    clk => clk 
    );
    
acl_p1_cooltuke_DITcore_8_mdl_2 : entity work.acl_p1_cooltuke_DITcore_8 
    Generic Map(
    W_Max => W_Max ,
    
    W_0_n32r  => W_8_n32r  , 
    W_0_n32i  => W_8_n32i  ,
    W_4_n32r  => W_10_n32r ,
    W_4_n32i  => W_10_n32i ,
    W_8_n32r  => W_12_n32r , 
    W_8_n32i  => W_12_n32i ,
    W_12_n32r => W_14_n32r ,
    W_12_n32i => W_14_n32i 
    
    )
    Port Map( 
    ena => ena , 
    io1 => io1  ,
    io2 => io9  ,
    io3 => io2  ,
    io4 => io10 ,
    io5 => io3  ,
    io6 => io11 ,
    io7 => io4  ,
    io8 => io12 ,
    
    clk => clk 
    );
    
    
    
    
    
    
    
    
    
end Behavioral;