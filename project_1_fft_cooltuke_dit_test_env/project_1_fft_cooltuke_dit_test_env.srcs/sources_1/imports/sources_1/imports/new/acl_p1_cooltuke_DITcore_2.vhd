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
    W_Max     : signed(C_w_bit_len-1 downto 0) := x"7f"   -- 8bit
    );
    Port ( 
    ena : std_logic := '0' ;
    
    input : in segm ; -- 0 w ile çapýmdan toplanan giriþ , 1 w ile çarpýlan giriþ 
    W : in W_bit_width_min_max  ;
    
    output  : out segm ;
    
    rst : in std_logic := '1' ;
    done : out std_logic := '0' ;-- impulse
    clk : in STD_LOGIC  := '0' 
    
    );
end acl_p1_cooltuke_DITcore_2;

architecture Behavioral of acl_p1_cooltuke_DITcore_2 is

begin


 
process (clk) 
variable V  : Var_reel_img  ;
variable V1 : Var_reel_img  ;
variable V2 : Var_reel_img  ;

begin 
    if rising_edge(clk) then
            
            done <= '0' ;
        if rst = '0' then 
        
        -- input output baðlantýsýný kes , çýkýþ güncellenmesin
        elsif ena ='1' then
        
        V.reel  := W_Max  * input(0).reel.Pin  ; -- çarpma iþleminin yükünü azaltmak içiçn idela ,, e biraz eroro yapacak ama deðerlendirilevbilinir yüksek N deðerleri içn 
        V.imag  := W_Max  * input(0).imag.Pin  ;--resize ( ( V.reel  + ( V1.reel - V2.reel )   ) srl 8  , C_p_bit_len) ;
        V1.reel := input(1).reel.Pin * W.R  ;
        V1.imag := input(1).reel.Pin * W.I  ;
        V2.reel := input(1).imag.Pin * W.I  ; -- 2 imaginary make negative number
        V2.imag := input(1).imag.Pin * W.R  ;
        
        
       
        
        -- 128 ile çarpýp 128 ile bölmeyi dene optimizasyon seçeneði 
        output(0).reel.Pin  <=  resize ( ( V.reel  + ( V1.reel - V2.reel )   ) srl 8  , C_p_bit_len) ; -- 12 bit sizze ,  6->256 <= 128 çarpým bazý iki sayý toplandýðý için iki katýna çýkýyor iki de oradan bölünüyor
        output(0).imag.Pin  <=  resize ( ( V.imag  + ( V1.imag + V2.imag )   ) srl 8  , C_p_bit_len) ; -- 128 çarpým bazý iki sayý toplandýðý için iki katýna çýkýyor iki de oradan bölünüyor
        output(1).reel.Pin  <=  resize ( ( V.reel  - ( V1.reel - V2.reel )   ) srl 8  , C_p_bit_len) ; -- 128 çarpým bazý iki sayý toplandýðý için iki katýna çýkýyor iki de oradan bölünüyor
        output(1).imag.Pin  <=  resize ( ( V.imag  - ( V1.imag + V2.imag )   ) srl 8  , C_p_bit_len) ; -- 128 çarpým bazý iki sayý toplandýðý için iki katýna çýkýyor iki de oradan bölünüyor
                                                                            
                                                                            
        done <= '1' ;
        
        
        else 
        output  <= input   ;                                        
        done <= '1' ;
         -- async reset yapýp kullanlmayan modüllerde giriþlreden çýkýþlara direk baðlantý yapabilirsin 
         -- tavsiye edilmez : düþündüðümü belirtmek için yazdým 
         end if ;
         
    end if ;
end process ;

end Behavioral;
