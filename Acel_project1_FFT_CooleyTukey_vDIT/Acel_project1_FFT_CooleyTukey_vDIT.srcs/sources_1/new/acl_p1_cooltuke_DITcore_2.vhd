----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.04.2026 16:14:49
-- Design Name: 
-- Module Name: acl_p1_cooltuke_DITcore_2 - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity acl_p1_cooltuke_DITcore_2 is
    Generic(
    W_Max : integer range -127 to 127 := 127 ;   -- 8bit
    W_0_n32r  : integer range -127 to 127 := 127 ;  
    W_0_n32i : integer range -127 to 127 := 0 
    );
    Port ( 
    ena : std_logic := '0' ;
    io1 : inout inout_pin_2fft_core ;
    io2 : inout inout_pin_2fft_core ;
    
    clk : in STD_LOGIC  
    
    );
end acl_p1_cooltuke_DITcore_2;

architecture Behavioral of acl_p1_cooltuke_DITcore_2 is

begin

process (clk) 
variable V1r  : integer range -262144 to 262144 ;
variable V1i : integer range -262144 to 262144 ;

variable V2rr : integer range -262144 to 262144 ;
variable V2ri : integer range -262144 to 262144 ;
variable V2ii : integer range -262144 to 262144 ;
variable V2ir : integer range -262144 to 262144 ;

begin 
    if rising_edge(clk) then
        if ena ='1' then
        
        
        V1r   := W_Max*io1.in1  ;
        V1i  := W_Max*io1.in1j ;
        V2rr := io2.in1 *W_0_n32r ;
        V2ri := io2.in1 *W_0_n32i ;
        V2ii := io2.in1j*W_0_n32i ;
        V2ir := io2.in1j*W_0_n32r ;
        
        -- 128 ile çarpýp 128 ile bölmeyi dene optimizasyon seçeneði 
        io1.out1  <=  ( V1r  + ( V2rr - V2ii )   )/256 ; -- 128 çarpým bazý iki sayý toplandýðý için iki katýna çýkýyor iki de oradan bölünüyor
        io1.out1j <=  ( V1i  + ( V2ir + V2ri )   )/256 ; -- 128 çarpým bazý iki sayý toplandýðý için iki katýna çýkýyor iki de oradan bölünüyor
        io2.out1  <=  ( V1r  - ( V2rr - V2ii )   )/256 ; -- 128 çarpým bazý iki sayý toplandýðý için iki katýna çýkýyor iki de oradan bölünüyor
        io2.out1j <=  ( V1i  - ( V2ir + V2ri )   )/256 ; -- 128 çarpým bazý iki sayý toplandýðý için iki katýna çýkýyor iki de oradan bölünüyor
        
        
        
        
        else
        io1.out1  <= io1.in1   ;
        io1.out1j <= io1.in1j  ;
        io2.out1  <= io2.in1   ;
        io2.out1j <= io2.in1j  ;
        
        
        
        end if ;
    end if ;
end process ;

end Behavioral;
