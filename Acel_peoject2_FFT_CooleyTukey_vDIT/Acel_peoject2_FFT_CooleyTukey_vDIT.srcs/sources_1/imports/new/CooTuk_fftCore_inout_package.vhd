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
    constant C_p_bit_len : integer := 10 ;
    constant C_w_bit_len : integer := 8 ;
    constant C_v_bit_len : integer := C_p_bit_len + C_w_bit_len;
    
    type pin_width_unsigned is record 
            Pin  : unsigned(C_p_bit_len-1 downto 0) ;--12 bit  
            end record ;
            
    type pin_width is record 
            Pin  : signed(C_p_bit_len-1 downto 0) ;--12 bit  
            end record ;
    
    type pin_reel_img is record 
             reel , imag :   pin_width ;    
            end record ;
    
    type inout_1pin1_2fft_core is record 
            input , output :   pin_reel_img ;       
            end record ;
          
    type segm is array (0 to 1) of inout_1pin1_2fft_core ;
    
    constant number_of_module_type_minus1 : integer range 0 to 9 := 4;
    constant number_of_pin_minus1 : integer range 0 to 63 := 31 ;
    constant number_of_pin_div2_minus1 : integer range 0 to 31 := 15;
    
    type ix  is array (0 to number_of_pin_div2_minus1) of segm ;
    
    
    type module_pins is array ( integer range 0 to number_of_pin_minus1 ) of pin_width ; -- 

    type module_pins_ri is array ( integer range 0 to 1 ) of module_pins ; -- 




      
            
     type W_bit_width_min_max is record 
            R : signed(C_w_bit_len-1 downto 0) ; --8 bit
            I : signed(C_w_bit_len-1 downto 0) ; --8 bit
            end record ;
      type W_rom  is array (0 to 63) of W_bit_width_min_max ;
       
      Constant C_Wrom : W_rom := ( --64lük ten yarýsýna kadar  N = 128 e kadar taþýr  
      
(R=> X"7F" , I=>X"00" ) ,  -- (k= 0 ,Dec: 127, 0j)
(R=> X"7F" , I=>X"FA" ) ,  -- (k= 1 ,Dec: 127, -6j)
(R=> X"7E" , I=>X"F4" ) ,  -- (k= 2 ,Dec: 126, -12j)
(R=> X"7E" , I=>X"ED" ) ,  -- (k= 3 ,Dec: 126, -19j)
(R=> X"7D" , I=>X"E7" ) ,  -- (k= 4 ,Dec: 125, -25j)
(R=> X"7B" , I=>X"E1" ) ,  -- (k= 5 ,Dec: 123, -31j)
(R=> X"7A" , I=>X"DB" ) ,  -- (k= 6 ,Dec: 122, -37j)
(R=> X"78" , I=>X"D5" ) ,  -- (k= 7 ,Dec: 120, -43j)
(R=> X"75" , I=>X"CF" ) ,  -- (k= 8 ,Dec: 117, -49j)
(R=> X"73" , I=>X"CA" ) ,  -- (k= 9 ,Dec: 115, -54j)
(R=> X"70" , I=>X"C4" ) ,  -- (k=10 ,Dec: 112, -60j)
(R=> X"6D" , I=>X"BF" ) ,  -- (k=11 ,Dec: 109, -65j)
(R=> X"6A" , I=>X"B9" ) ,  -- (k=12 ,Dec: 106, -71j)
(R=> X"66" , I=>X"B4" ) ,  -- (k=13 ,Dec: 102, -76j)
(R=> X"62" , I=>X"AF" ) ,  -- (k=14 ,Dec: 98, -81j)
(R=> X"5E" , I=>X"AB" ) ,  -- (k=15 ,Dec: 94, -85j)
(R=> X"5A" , I=>X"A6" ) ,  -- (k=16 ,Dec: 90, -90j)
(R=> X"55" , I=>X"A2" ) ,  -- (k=17 ,Dec: 85, -94j)
(R=> X"51" , I=>X"9E" ) ,  -- (k=18 ,Dec: 81, -98j)
(R=> X"4C" , I=>X"9A" ) ,  -- (k=19 ,Dec: 76, -102j)
(R=> X"47" , I=>X"96" ) ,  -- (k=20 ,Dec: 71, -106j)
(R=> X"41" , I=>X"93" ) ,  -- (k=21 ,Dec: 65, -109j)
(R=> X"3C" , I=>X"90" ) ,  -- (k=22 ,Dec: 60, -112j)
(R=> X"36" , I=>X"8D" ) ,  -- (k=23 ,Dec: 54, -115j)
(R=> X"31" , I=>X"8B" ) ,  -- (k=24 ,Dec: 49, -117j)
(R=> X"2B" , I=>X"88" ) ,  -- (k=25 ,Dec: 43, -120j)
(R=> X"25" , I=>X"86" ) ,  -- (k=26 ,Dec: 37, -122j)
(R=> X"1F" , I=>X"85" ) ,  -- (k=27 ,Dec: 31, -123j)
(R=> X"19" , I=>X"83" ) ,  -- (k=28 ,Dec: 25, -125j)
(R=> X"13" , I=>X"82" ) ,  -- (k=29 ,Dec: 19, -126j)
(R=> X"0C" , I=>X"82" ) ,  -- (k=30 ,Dec: 12, -126j)
(R=> X"06" , I=>X"81" ) ,  -- (k=31 ,Dec: 6, -127j)
(R=> X"00" , I=>X"81" ) ,  -- (k=32 ,Dec: 0, -127j)
(R=> X"FA" , I=>X"81" ) ,  -- (k=33 ,Dec: -6, -127j)
(R=> X"F4" , I=>X"82" ) ,  -- (k=34 ,Dec: -12, -126j)
(R=> X"ED" , I=>X"82" ) ,  -- (k=35 ,Dec: -19, -126j)
(R=> X"E7" , I=>X"83" ) ,  -- (k=36 ,Dec: -25, -125j)
(R=> X"E1" , I=>X"85" ) ,  -- (k=37 ,Dec: -31, -123j)
(R=> X"DB" , I=>X"86" ) ,  -- (k=38 ,Dec: -37, -122j)
(R=> X"D5" , I=>X"88" ) ,  -- (k=39 ,Dec: -43, -120j)
(R=> X"CF" , I=>X"8B" ) ,  -- (k=40 ,Dec: -49, -117j)
(R=> X"CA" , I=>X"8D" ) ,  -- (k=41 ,Dec: -54, -115j)
(R=> X"C4" , I=>X"90" ) ,  -- (k=42 ,Dec: -60, -112j)
(R=> X"BF" , I=>X"93" ) ,  -- (k=43 ,Dec: -65, -109j)
(R=> X"B9" , I=>X"96" ) ,  -- (k=44 ,Dec: -71, -106j)
(R=> X"B4" , I=>X"9A" ) ,  -- (k=45 ,Dec: -76, -102j)
(R=> X"AF" , I=>X"9E" ) ,  -- (k=46 ,Dec: -81, -98j)
(R=> X"AB" , I=>X"A2" ) ,  -- (k=47 ,Dec: -85, -94j)
(R=> X"A6" , I=>X"A6" ) ,  -- (k=48 ,Dec: -90, -90j)
(R=> X"A2" , I=>X"AB" ) ,  -- (k=49 ,Dec: -94, -85j)
(R=> X"9E" , I=>X"AF" ) ,  -- (k=50 ,Dec: -98, -81j)
(R=> X"9A" , I=>X"B4" ) ,  -- (k=51 ,Dec: -102, -76j)
(R=> X"96" , I=>X"B9" ) ,  -- (k=52 ,Dec: -106, -71j)
(R=> X"93" , I=>X"BF" ) ,  -- (k=53 ,Dec: -109, -65j)
(R=> X"90" , I=>X"C4" ) ,  -- (k=54 ,Dec: -112, -60j)
(R=> X"8D" , I=>X"CA" ) ,  -- (k=55 ,Dec: -115, -54j)
(R=> X"8B" , I=>X"CF" ) ,  -- (k=56 ,Dec: -117, -49j)
(R=> X"88" , I=>X"D5" ) ,  -- (k=57 ,Dec: -120, -43j)
(R=> X"86" , I=>X"DB" ) ,  -- (k=58 ,Dec: -122, -37j)
(R=> X"85" , I=>X"E1" ) ,  -- (k=59 ,Dec: -123, -31j)
(R=> X"83" , I=>X"E7" ) ,  -- (k=60 ,Dec: -125, -25j)
(R=> X"82" , I=>X"ED" ) ,  -- (k=61 ,Dec: -126, -19j)
(R=> X"82" , I=>X"F4" ) ,  -- (k=62 ,Dec: -126, -12j)
(R=> X"81" , I=>X"FA" )    -- (k=63 ,Dec: -127, -6j)



      
      );
            
            
      type Var_width_min_max is record 
            Var: signed(C_v_bit_len-1 downto 0) ;-- 19 wil be enouh 
            end record ;
            
     type Var_reel_img is record 
             reel , imag :  signed(C_v_bit_len-1 downto 0) ;-- 19 wil be enouh      
            end record ;
     



end CooTuk_fftCore_inout_package;
