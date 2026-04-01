----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.04.2026 16:14:49
-- Design Name: 
-- Module Name: acl_p1_cooltuke_DITcore_4 - Behavioral
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

entity acl_p1_cooltuke_DITcore_4 is
    Generic(
    W_Max : integer range -127 to 127 := 127 ;   -- 8bit
    W_0_n32r  : integer range -127 to 127 := 127 ;  
    W_0_n32i : integer range -127 to 127 := 0  ;
    W_8_n32r: integer range -127 to 127 := 0 ;    
    W_8_n32i: integer range -127 to 127 := -127 
    );
    Port ( 
    ena : std_logic := '0' ;
    io1 : inout inout_pin_2fft_core ;
    io2 : inout inout_pin_2fft_core ;
    io3 : inout inout_pin_2fft_core ;
    io4 : inout inout_pin_2fft_core ;
    
    clk : in STD_LOGIC  
    );
end acl_p1_cooltuke_DITcore_4;

architecture Behavioral of acl_p1_cooltuke_DITcore_4 is


begin

acl_p1_cooltuke_DITcore_2_mdl_1 : entity work.acl_p1_cooltuke_DITcore_2 
    Generic MAP(
    W_0_n32r => W_0_n32r ,
    W_0_n32i => W_0_n32i
    )
    Port MAP( 
    ena => ena ,
    io1 => io1 ,
    io2 => io3 ,
    
    clk => clk 
    
    );
acl_p1_cooltuke_DITcore_2_mdl_2 : entity work.acl_p1_cooltuke_DITcore_2 
    Generic MAP(
    W_0_n32r => W_8_n32r,
    W_0_n32i => W_8_n32i
    )
    Port MAP( 
    ena => ena ,
    io1 => io2 ,
    io2 => io4 ,
    
    clk => clk 
    
    );
    
    

end Behavioral;
