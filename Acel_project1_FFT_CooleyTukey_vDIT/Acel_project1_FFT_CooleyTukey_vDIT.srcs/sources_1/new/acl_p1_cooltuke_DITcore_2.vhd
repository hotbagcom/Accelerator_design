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
    W_Max     : W_bit_width_min_max := (  WkN  =>  X"7F" ) ;   -- 8bit
    W_0_n32r  : W_bit_width_min_max := (  WkN  =>  X"7F" ) ;   -- bunu da deðiþtirebilirim 
    W_0_n32i  : W_bit_width_min_max := (  WkN  =>  X"00" )
    );
    Port ( 
    ena : std_logic := '0' ;
    io1 : inout inout_1pin1_2fft_core ;
    io2 : inout inout_1pin1_2fft_core ;
    
    clk : in STD_LOGIC  := '0' 
    
    );
end acl_p1_cooltuke_DITcore_2;

architecture Behavioral of acl_p1_cooltuke_DITcore_2 is

begin

process (clk) 
variable V  :  Var_reel_img  ;
variable V1 : Var_reel_img  ;
variable V2 : Var_reel_img  ;

begin 
    if rising_edge(clk) then
        if ena ='1' then
        
        
        V.reel  := W_Max. WkN   * io1.input.reel  ;
        V.imag  := W_Max. WkN   * io1.input.imag ;
        V1.reel := io2.input.reel * W_0_n32r. WkN  ;
        V1.imag := io2.input.reel * W_0_n32i. WkN  ;
        V2.reel := io2.input.imag * W_0_n32i. WkN  ; -- 2 imaginary make negative number
        V2.imag := io2.input.imag * W_0_n32r. WkN  ;
        
        -- 128 ile çarpýp 128 ile bölmeyi dene optimizasyon seçeneði 
        io1.output.reel  <=  resize ( ( V.reel  + ( V1.reel - V2.reel )   ) srl 6  , 12) ; -- 12 bit sizze ,  6->256 <= 128 çarpým bazý iki sayý toplandýðý için iki katýna çýkýyor iki de oradan bölünüyor
        io1.output.imag  <=  resize ( ( V.imag  + ( V1.imag + V2.imag )   ) srl 6  , 12) ; -- 128 çarpým bazý iki sayý toplandýðý için iki katýna çýkýyor iki de oradan bölünüyor
        io2.output.reel  <=  resize ( ( V.reel  - ( V1.reel - V2.reel )   ) srl 6  , 12) ; -- 128 çarpým bazý iki sayý toplandýðý için iki katýna çýkýyor iki de oradan bölünüyor
        io2.output.imag  <=  resize ( ( V.imag  - ( V1.imag + V2.imag )   ) srl 6  , 12) ; -- 128 çarpým bazý iki sayý toplandýðý için iki katýna çýkýyor iki de oradan bölünüyor
        
        
        
        
        else
        io1.output  <= io1.input   ;
        io2.output  <= io2.input   ;
        
        
        
        end if ;
    end if ;
end process ;

end Behavioral;
