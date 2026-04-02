----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.04.2026 18:09:41
-- Design Name: 
-- Module Name: CooTuk_fftCore_inout_package - Behavioral
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
 

package CooTuk_fftCore_inout_package is
-- for begininig kep in and out bit length same later you may change 
    constant C_p_bit_len : integer := 12 ;
    constant C_w_bit_len : integer := 8 ;
    constant C_v_bit_len : integer := C_p_bit_len + C_w_bit_len;
    
    type pin_width is record 
            Pin  : signed(C_p_bit_len-1 downto 0) ;--12 bit  
            end record ;
    
    type pin_reel_img is record 
             reel , imag :   signed(C_p_bit_len-1 downto 0) ;--12 bit    
            end record ;
    
    type inout_1pin1_2fft_core is record 
            input , output :  pin_reel_img ;       
            end record ;
            
            
     type W_bit_width_min_max is record 
            WkN : signed(C_w_bit_len-1 downto 0) ; --8 bit
            end record ;
            
            
--    W_0_n32r  : W_bit_width_min_max := (  WkN  =>  X"7F" ) ;   -- bunu da deðiþtirebilirim 
--    W_0_n32i  : W_bit_width_min_max := (  WkN  =>  X"00" )
--    yerine 
    
    
--    W_0_n32r  : W_bit_width_min_max := (  WkN  =>  X"7F" ) ;   -- bunu da deðiþtirebilirim 
--    W_0_n32i  : W_bit_width_min_max := (  WkN  =>  X"00" )
    
--    type W_bit_width_min_max is record 
--            WkN : signed(C_w_bit_len-1 downto 0) ; --8 bit
--            end record ;
            
--     type W_reel_img is record  --
--             reel , imag :  W_bit_width_min_max ;       
--            end record ;
        
--      type Wbuffer is array ( integer range 0 to 1 )of  W_reel_img ;
--      Signal S_Wbuffer : Wbuffer :=( reel.Wkn=> x"7F" , imag.Wkn=> x"00" , reel.Wkn=> x"00" , imag.Wkn=> x"81" ); 
      
          
            
      type Var_width_min_max is record 
            Var: signed(C_v_bit_len downto 0) ;-- 19 wil be enouh 
            end record ;
            
     type Var_reel_img is record 
             reel , imag :  signed(C_v_bit_len downto 0) ;-- 19 wil be enouh      
            end record ;
     



end CooTuk_fftCore_inout_package;
