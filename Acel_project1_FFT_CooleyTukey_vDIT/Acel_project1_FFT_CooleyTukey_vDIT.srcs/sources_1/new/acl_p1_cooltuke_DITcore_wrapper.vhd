----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.03.2026 16:47:20
-- Design Name: 
-- Module Name: acl_p1_cooltuke_DITcore_wrapper - Behavioral
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
-- arithmetic functions with Signed or Unsigned values;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity acl_p1_cooltuke_DITcore_wrapper is
    Port ( -- target N is 512
    clk : in STD_LOGIC  := '0' ;
    
    ena         : in std_logic := '0' ;
    data_time   : in signed(11 downto 0) := (others=>'0') ; 
    addr_time   : in std_logic_vector(9 downto 0) := (others=>'0') ; 
    we_time     : in std_logic := '0' ;
        rdy_time : out std_logic := '0' ;
    L : in integer range 1 to 10 := 5 ; 
    
        data_freq   : out signed(11 downto 0) := (others=>'0') ;   
    addr_freq   : in std_logic_vector(9 downto 0) := (others=>'0') ;   
    re_freq      : in std_logic := '0' ;
        rdy_freq : out std_logic := '0' ;
    
    
    
    
        done        : out std_logic := '0' ;
        ready_data  : out std_logic := '0' ; -- when change on L value set 0 and when loading data
    rst : std_logic := '1' 
    );
end acl_p1_cooltuke_DITcore_wrapper;

architecture Behavioral of acl_p1_cooltuke_DITcore_wrapper is



                                   -- 512-8  tane w de?eri sakla N 16 den N 512 ye i?lem yaps?n 
                                   -- 16 den 512 ye W(up:0 to (n1/2)-1)(down:n1) n1::2 to 512

type State_4wraper is (Idle , Read_N_Set_W_4L , Run , Write ) ;
Signal St_wrapper : State_4wraper  := Idle ;



 function acl_p1_cooltuke_revrsordr (
                        L :  integer range 1 to 10 := 5 ;
                        index_in :  std_logic_vector(9 downto 0) := (others=>'0') 
                         )   return std_logic_vector is
        variable v_temp : std_logic_vector(9 downto 0) := (others=>'0');
    begin
        
            for i in 0 to 9 loop
                if i < L then
                    v_temp((L-1) - i) := index_in(i);
                end if;
            end loop;
            
        return v_temp;
    end function;



Signal S_Mass_conrol_Core_ena : std_logic_vector(9 downto 0 )  :=  (Others=>'0') ;-- for now use only =32 so that L-1 = "4" downtox"00"-- similar to N 
-- 2 -> 4 -> 8 -> 16 -> 32 -> 64 -> 128 -> 256 -> 512
-- 0 -> 1 -> 2 -> 3 --> 4 --> 5 ---> 6 ---> 7 ---> 8 
type module_pins is array ( integer range 0 to 31 ) of pin_width ; -- 
Signal S_time_in_ram_zero : pin_width := ( pin=>(others=> '0')) ;
Signal S_time_in_ram : module_pins   ;
Signal S_time_in_ram_flag : std_logic := '0' ; --when 2^L-1 value collected push new value to fft core
Signal S_freq_out_ram : module_pins  ;
Signal S_freq_out_ram_flag : std_logic := '0' ; -- High to get out from fft module 

type module_pins_ri is array ( integer range 0 to 31 ) of pin_reel_img ; -- 
type out_module_from is array (integer range 0 to 5 ) of module_pins_ri ;
Signal S_out_module_from_th : out_module_from ; -- 

 
Signal S_pipl_tracker : unsigned(9 downto 0) := (others=>'0'); 



Signal S_N : unsigned(10 downto 0) := (others=> '0');
Constant C_N_max : unsigned(10 downto 0) := "000" & x"20"; -- þimdilik 32




 
 
begin


 ----------------------------------------------------------------------------------------------------------------------------------------------------------------
    GEN_FFTMODL_2 : for j in 0 to 15 generate -- N = 32 için N/2 tanesi 16 tane FFTcore2 lazým 
        Mas_produce_FFTcore2 : entity work.acl_p1_cooltuke_DITcore_2
--            Generic(--            W_Max     : W_bit_width_min_max := (  WkN  =>  x"7f" ) ;   -- 8bit--            W_0_n32r  : W_bit_width_min_max := (  WkN  =>  x"7f" ) ;  --            W_0_n32i  : W_bit_width_min_max := (  WkN  => x"00" )--            );
            Port Map( 
            ena     => S_Mass_conrol_Core_ena(0) ,
            
            io1.input.reel   =>  S_time_in_ram(2*j).pin  ,
            io1.input.imag   =>  S_time_in_ram_zero.pin   ,
            io2.input.reel   =>  S_time_in_ram(2*j+1).pin ,
            io2.input.imag   =>  S_time_in_ram_zero.pin   ,
            
            io1.output.reel   =>  S_out_module_from_th(0)(2*j).reel ,
            io1.output.imag   =>  S_out_module_from_th(0)(2*j).imag ,
            io2.output.reel   =>  S_out_module_from_th(0)(2*j+1).reel ,
            io2.output.imag   =>  S_out_module_from_th(0)(2*j+1).imag ,
                                                               
            clk     => clk     );
            
    end Generate;                      
 
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------
    GEN_FFTMODL_4 : for j in 0 to 7 generate -- N = 32 için N/4 tanesi 8 tane FFTcore4 lazým 
        Mas_produce_FFTcore4 : entity work.acl_p1_cooltuke_DITcore_4
--    Generic(                                                                     W_0_n32r  : W_bit_width_min_max := (  WkN  =>  X"7F"  ) ;  W_8_n32r  : W_bit_width_min_max := (  WkN  =>  X"00"  ) ;       
--    W_Max     : W_bit_width_min_max := (  WkN  =>  X"7F"  ) ;   -- 8bit          W_0_n32i  : W_bit_width_min_max := (  WkN  =>  X"00"  ) ;  W_8_n32i  : W_bit_width_min_max := (  WkN  =>  X"81"  )     );  

            Port Map( 
            ena     => S_Mass_conrol_Core_ena(1) ,
            
            io1.input.reel   =>  S_out_module_from_th(0)(4*j).reel ,
            io1.input.imag   =>  S_out_module_from_th(0)(4*j).imag ,
            io2.input.reel   =>  S_out_module_from_th(0)(4*j+1).reel ,  
            io2.input.imag   =>  S_out_module_from_th(0)(4*j+1).imag ,  
            io3.input.reel   =>  S_out_module_from_th(0)(4*j+2).reel ,
            io3.input.imag   =>  S_out_module_from_th(0)(4*j+2).imag ,
            io4.input.reel   =>  S_out_module_from_th(0)(4*j+3).reel ,  
            io4.input.imag   =>  S_out_module_from_th(0)(4*j+3).imag ,  
                                                 
            io1.output.reel   =>  S_out_module_from_th(1)(4*j).reel ,              
            io1.output.imag   =>  S_out_module_from_th(1)(4*j).imag ,              
            io2.output.reel   =>  S_out_module_from_th(1)(4*j+1).reel ,            
            io2.output.imag   =>  S_out_module_from_th(1)(4*j+1).imag ,            
            io3.output.reel   =>  S_out_module_from_th(1)(4*j+2).reel ,            
            io3.output.imag   =>  S_out_module_from_th(1)(4*j+2).imag ,               
            io4.output.reel   =>  S_out_module_from_th(1)(4*j+3).reel ,                                     
            io4.output.imag   =>  S_out_module_from_th(1)(4*j+3).imag ,                                     
                                                      
            clk     => clk    );
    end Generate;                      
 
 
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------
    GEN_FFTMODL_8 : for j in 0 to 3 generate -- N = 32 için N/8 tanesi 4 tane FFTcore8 lazým 
        Mas_produce_FFTcore8 : entity work.acl_p1_cooltuke_DITcore_8
            Port Map( 
            ena     => S_Mass_conrol_Core_ena(2) ,
            
            io1.input.reel   =>  S_out_module_from_th(1)(8*j).reel ,
            io1.input.imag   =>  S_out_module_from_th(1)(8*j).imag ,
            io2.input.reel   =>  S_out_module_from_th(1)(8*j+1).reel ,  
            io2.input.imag   =>  S_out_module_from_th(1)(8*j+1).imag ,  
            io3.input.reel   =>  S_out_module_from_th(1)(8*j+2).reel ,
            io3.input.imag   =>  S_out_module_from_th(1)(8*j+2).imag ,
            io4.input.reel   =>  S_out_module_from_th(1)(8*j+3).reel ,  
            io4.input.imag   =>  S_out_module_from_th(1)(8*j+3).imag ,  
            io5.input.reel   =>  S_out_module_from_th(1)(8*j+4).reel ,
            io5.input.imag   =>  S_out_module_from_th(1)(8*j+4).imag ,
            io6.input.reel   =>  S_out_module_from_th(1)(8*j+5).reel ,  
            io6.input.imag   =>  S_out_module_from_th(1)(8*j+5).imag ,  
            io7.input.reel   =>  S_out_module_from_th(1)(8*j+6).reel ,
            io7.input.imag   =>  S_out_module_from_th(1)(8*j+6).imag ,
            io8.input.reel   =>  S_out_module_from_th(1)(8*j+7).reel ,  
            io8.input.imag   =>  S_out_module_from_th(1)(8*j+7).imag ,  
                                                     
            io1.output.reel   =>  S_out_module_from_th(2)(8*j).reel ,
            io1.output.imag   =>  S_out_module_from_th(2)(8*j).imag ,
            io2.output.reel   =>  S_out_module_from_th(2)(8*j+1).reel ,  
            io2.output.imag   =>  S_out_module_from_th(2)(8*j+1).imag ,  
            io3.output.reel   =>  S_out_module_from_th(2)(8*j+2).reel ,
            io3.output.imag   =>  S_out_module_from_th(2)(8*j+2).imag ,
            io4.output.reel   =>  S_out_module_from_th(2)(8*j+3).reel ,  
            io4.output.imag   =>  S_out_module_from_th(2)(8*j+3).imag ,  
            io5.output.reel   =>  S_out_module_from_th(2)(8*j+4).reel ,
            io5.output.imag   =>  S_out_module_from_th(2)(8*j+4).imag ,
            io6.output.reel   =>  S_out_module_from_th(2)(8*j+5).reel ,  
            io6.output.imag   =>  S_out_module_from_th(2)(8*j+5).imag ,  
            io7.output.reel   =>  S_out_module_from_th(2)(8*j+6).reel ,
            io7.output.imag   =>  S_out_module_from_th(2)(8*j+6).imag ,
            io8.output.reel   =>  S_out_module_from_th(2)(8*j+7).reel ,  
            io8.output.imag   =>  S_out_module_from_th(2)(8*j+7).imag ,  
                                                                                         
                                                      
            clk     => clk    );
    end Generate;                      
 
 
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------
    GEN_FFTMODL_16 : for j in 0 to 1 generate -- N = 32 için N/16 tanesi 2 tane FFTcore16 lazým 
        Mas_produce_FFTcore16 : entity work.acl_p1_cooltuke_DITcore_16
            Port Map( 
            ena     => S_Mass_conrol_Core_ena(3) ,
            
            io1.input.reel    =>  S_out_module_from_th(2)(16*j+0).reel  ,                                                        
            io1.input.imag    =>  S_out_module_from_th(2)(16*j+0).imag  ,
            io2.input.reel    =>  S_out_module_from_th(2)(16*j+1).reel  ,
            io2.input.imag    =>  S_out_module_from_th(2)(16*j+1).imag  ,
            io3.input.reel    =>  S_out_module_from_th(2)(16*j+2).reel  ,
            io3.input.imag    =>  S_out_module_from_th(2)(16*j+2).imag  ,
            io4.input.reel    =>  S_out_module_from_th(2)(16*j+3).reel  ,
            io4.input.imag    =>  S_out_module_from_th(2)(16*j+3).imag  ,
            io5.input.reel    =>  S_out_module_from_th(2)(16*j+4).reel  ,
            io5.input.imag    =>  S_out_module_from_th(2)(16*j+4).imag  ,
            io6.input.reel    =>  S_out_module_from_th(2)(16*j+5).reel  ,
            io6.input.imag    =>  S_out_module_from_th(2)(16*j+5).imag  ,
            io7.input.reel    =>  S_out_module_from_th(2)(16*j+6).reel  ,
            io7.input.imag    =>  S_out_module_from_th(2)(16*j+6).imag  ,
            io8.input.reel    =>  S_out_module_from_th(2)(16*j+7).reel  ,
            io8.input.imag    =>  S_out_module_from_th(2)(16*j+7).imag  ,
            io9.input.reel    =>  S_out_module_from_th(2)(16*j+8).reel  ,
            io9.input.imag    =>  S_out_module_from_th(2)(16*j+8).imag  ,
            io10.input.reel   =>  S_out_module_from_th(2)(16*j+9).reel  ,
            io10.input.imag   =>  S_out_module_from_th(2)(16*j+9).imag  ,
            io11.input.reel   =>  S_out_module_from_th(2)(16*j+10).reel ,
            io11.input.imag   =>  S_out_module_from_th(2)(16*j+10).imag ,
            io12.input.reel   =>  S_out_module_from_th(2)(16*j+11).reel ,
            io12.input.imag   =>  S_out_module_from_th(2)(16*j+11).imag ,
            io13.input.reel   =>  S_out_module_from_th(2)(16*j+12).reel ,
            io13.input.imag   =>  S_out_module_from_th(2)(16*j+12).imag ,
            io14.input.reel   =>  S_out_module_from_th(2)(16*j+13).reel ,
            io14.input.imag   =>  S_out_module_from_th(2)(16*j+13).imag ,
            io15.input.reel   =>  S_out_module_from_th(2)(16*j+14).reel ,
            io15.input.imag   =>  S_out_module_from_th(2)(16*j+14).imag ,
            io16.input.reel   =>  S_out_module_from_th(2)(16*j+15).reel ,
            io16.input.imag   =>  S_out_module_from_th(2)(16*j+15).imag ,  
                                                     
            
            io1.output.reel    =>  S_out_module_from_th(3)(16*j+0).reel  ,                                                        
            io1.output.imag    =>  S_out_module_from_th(3)(16*j+0).imag  ,
            io2.output.reel    =>  S_out_module_from_th(3)(16*j+1).reel  ,
            io2.output.imag    =>  S_out_module_from_th(3)(16*j+1).imag  ,
            io3.output.reel    =>  S_out_module_from_th(3)(16*j+2).reel  ,
            io3.output.imag    =>  S_out_module_from_th(3)(16*j+2).imag  ,
            io4.output.reel    =>  S_out_module_from_th(3)(16*j+3).reel  ,
            io4.output.imag    =>  S_out_module_from_th(3)(16*j+3).imag  ,
            io5.output.reel    =>  S_out_module_from_th(3)(16*j+4).reel  ,
            io5.output.imag    =>  S_out_module_from_th(3)(16*j+4).imag  ,
            io6.output.reel    =>  S_out_module_from_th(3)(16*j+5).reel  ,
            io6.output.imag    =>  S_out_module_from_th(3)(16*j+5).imag  ,
            io7.output.reel    =>  S_out_module_from_th(3)(16*j+6).reel  ,
            io7.output.imag    =>  S_out_module_from_th(3)(16*j+6).imag  ,
            io8.output.reel    =>  S_out_module_from_th(3)(16*j+7).reel  ,
            io8.output.imag    =>  S_out_module_from_th(3)(16*j+7).imag  ,
            io9.output.reel    =>  S_out_module_from_th(3)(16*j+8).reel  ,
            io9.output.imag    =>  S_out_module_from_th(3)(16*j+8).imag  ,
            io10.output.reel   =>  S_out_module_from_th(3)(16*j+9).reel  ,
            io10.output.imag   =>  S_out_module_from_th(3)(16*j+9).imag  ,
            io11.output.reel   =>  S_out_module_from_th(3)(16*j+10).reel ,
            io11.output.imag   =>  S_out_module_from_th(3)(16*j+10).imag ,
            io12.output.reel   =>  S_out_module_from_th(3)(16*j+11).reel ,
            io12.output.imag   =>  S_out_module_from_th(3)(16*j+11).imag ,
            io13.output.reel   =>  S_out_module_from_th(3)(16*j+12).reel ,
            io13.output.imag   =>  S_out_module_from_th(3)(16*j+12).imag ,
            io14.output.reel   =>  S_out_module_from_th(3)(16*j+13).reel ,
            io14.output.imag   =>  S_out_module_from_th(3)(16*j+13).imag ,
            io15.output.reel   =>  S_out_module_from_th(3)(16*j+14).reel ,
            io15.output.imag   =>  S_out_module_from_th(3)(16*j+14).imag ,
            io16.output.reel   =>  S_out_module_from_th(3)(16*j+15).reel ,
            io16.output.imag   =>  S_out_module_from_th(3)(16*j+15).imag ,  
                                                                                         
                                                        
            clk     => clk    );                        
    end Generate;                                       
                                                        
       
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                   
       GEN_FFTMODL_32 : for j in 0 to 0 generate            -- N = 32 için N/16 tanesi 1 tane FFTcore16 lazým                                   
           Mas_produce_FFTcore32 : entity work.acl_p1_cooltuke_DITcore_32
--    Generic(                                                                     W_0_n32r  : W_bit_width_min_max := (  WkN  =>  X"7F"  ) ;  W_8_n32r  : W_bit_width_min_max := (  WkN  =>  X"00"  ) ;       
--    W_Max     : W_bit_width_min_max := (  WkN  =>  X"7F"  ) ;   -- 8bit          W_0_n32i  : W_bit_width_min_max := (  WkN  =>  X"00"  ) ;  W_8_n32i  : W_bit_width_min_max := (  WkN  =>  X"81"  )     );  

            Port Map( 
            ena     => S_Mass_conrol_Core_ena(4) ,
            io1.input.reel    =>  S_out_module_from_th(3)(32*j+0).reel ,
            io1.input.imag    =>  S_out_module_from_th(3)(32*j+0).imag ,
            io2.input.reel    =>  S_out_module_from_th(3)(32*j+1).reel ,
            io2.input.imag    =>  S_out_module_from_th(3)(32*j+1).imag ,
            io3.input.reel    =>  S_out_module_from_th(3)(32*j+2).reel ,
            io3.input.imag    =>  S_out_module_from_th(3)(32*j+2).imag ,
            io4.input.reel    =>  S_out_module_from_th(3)(32*j+3).reel ,
            io4.input.imag    =>  S_out_module_from_th(3)(32*j+3).imag ,
            io5.input.reel    =>  S_out_module_from_th(3)(32*j+4).reel ,
            io5.input.imag    =>  S_out_module_from_th(3)(32*j+4).imag ,
            io6.input.reel    =>  S_out_module_from_th(3)(32*j+5).reel ,
            io6.input.imag    =>  S_out_module_from_th(3)(32*j+5).imag ,
            io7.input.reel    =>  S_out_module_from_th(3)(32*j+6).reel ,
            io7.input.imag    =>  S_out_module_from_th(3)(32*j+6).imag ,
            io8.input.reel    =>  S_out_module_from_th(3)(32*j+7).reel ,
            io8.input.imag    =>  S_out_module_from_th(3)(32*j+7).imag ,
            io9.input.reel    =>  S_out_module_from_th(3)(32*j+8).reel ,
            io9.input.imag    =>  S_out_module_from_th(3)(32*j+8).imag ,
            io10.input.reel   =>  S_out_module_from_th(3)(32*j+9).reel ,
            io10.input.imag   =>  S_out_module_from_th(3)(32*j+9).imag ,
            io11.input.reel   =>  S_out_module_from_th(3)(32*j+10).reel ,
            io11.input.imag   =>  S_out_module_from_th(3)(32*j+10).imag ,
            io12.input.reel   =>  S_out_module_from_th(3)(32*j+11).reel ,
            io12.input.imag   =>  S_out_module_from_th(3)(32*j+11).imag ,
            io13.input.reel   =>  S_out_module_from_th(3)(32*j+12).reel ,
            io13.input.imag   =>  S_out_module_from_th(3)(32*j+12).imag ,
            io14.input.reel   =>  S_out_module_from_th(3)(32*j+13).reel ,
            io14.input.imag   =>  S_out_module_from_th(3)(32*j+13).imag ,
            io15.input.reel   =>  S_out_module_from_th(3)(32*j+14).reel ,
            io15.input.imag   =>  S_out_module_from_th(3)(32*j+14).imag ,
            io16.input.reel   =>  S_out_module_from_th(3)(32*j+15).reel ,
            io16.input.imag   =>  S_out_module_from_th(3)(32*j+15).imag ,
            io17.input.reel   =>  S_out_module_from_th(3)(32*j+16).reel ,
            io17.input.imag   =>  S_out_module_from_th(3)(32*j+16).imag ,
            io18.input.reel   =>  S_out_module_from_th(3)(32*j+17).reel ,
            io18.input.imag   =>  S_out_module_from_th(3)(32*j+17).imag ,
            io19.input.reel   =>  S_out_module_from_th(3)(32*j+18).reel ,
            io19.input.imag   =>  S_out_module_from_th(3)(32*j+18).imag ,
            io20.input.reel   =>  S_out_module_from_th(3)(32*j+19).reel ,
            io20.input.imag   =>  S_out_module_from_th(3)(32*j+19).imag ,
            io21.input.reel   =>  S_out_module_from_th(3)(32*j+20).reel ,
            io21.input.imag   =>  S_out_module_from_th(3)(32*j+20).imag ,
            io22.input.reel   =>  S_out_module_from_th(3)(32*j+21).reel ,
            io22.input.imag   =>  S_out_module_from_th(3)(32*j+21).imag ,
            io23.input.reel   =>  S_out_module_from_th(3)(32*j+22).reel ,
            io23.input.imag   =>  S_out_module_from_th(3)(32*j+22).imag ,
            io24.input.reel   =>  S_out_module_from_th(3)(32*j+23).reel ,
            io24.input.imag   =>  S_out_module_from_th(3)(32*j+23).imag ,
            io25.input.reel   =>  S_out_module_from_th(3)(32*j+24).reel ,
            io25.input.imag   =>  S_out_module_from_th(3)(32*j+24).imag ,
            io26.input.reel   =>  S_out_module_from_th(3)(32*j+25).reel ,
            io26.input.imag   =>  S_out_module_from_th(3)(32*j+25).imag ,
            io27.input.reel   =>  S_out_module_from_th(3)(32*j+26).reel ,
            io27.input.imag   =>  S_out_module_from_th(3)(32*j+26).imag ,
            io28.input.reel   =>  S_out_module_from_th(3)(32*j+27).reel ,
            io28.input.imag   =>  S_out_module_from_th(3)(32*j+27).imag ,
            io29.input.reel   =>  S_out_module_from_th(3)(32*j+28).reel ,
            io29.input.imag   =>  S_out_module_from_th(3)(32*j+28).imag ,
            io30.input.reel   =>  S_out_module_from_th(3)(32*j+29).reel ,
            io30.input.imag   =>  S_out_module_from_th(3)(32*j+29).imag ,
            io31.input.reel   =>  S_out_module_from_th(3)(32*j+30).reel ,
            io31.input.imag   =>  S_out_module_from_th(3)(32*j+30).imag ,
            io32.input.reel   =>  S_out_module_from_th(3)(32*j+31).reel ,
            io32.input.imag   =>  S_out_module_from_th(3)(32*j+31).imag ,
                                                       
            io1.output.reel    =>  S_out_module_from_th(4)(32*j+0).reel ,
            io1.output.imag    =>  S_out_module_from_th(4)(32*j+0).imag ,
            io2.output.reel    =>  S_out_module_from_th(4)(32*j+1).reel ,
            io2.output.imag    =>  S_out_module_from_th(4)(32*j+1).imag ,
            io3.output.reel    =>  S_out_module_from_th(4)(32*j+2).reel ,
            io3.output.imag    =>  S_out_module_from_th(4)(32*j+2).imag ,
            io4.output.reel    =>  S_out_module_from_th(4)(32*j+3).reel ,
            io4.output.imag    =>  S_out_module_from_th(4)(32*j+3).imag ,
            io5.output.reel    =>  S_out_module_from_th(4)(32*j+4).reel ,
            io5.output.imag    =>  S_out_module_from_th(4)(32*j+4).imag ,
            io6.output.reel    =>  S_out_module_from_th(4)(32*j+5).reel ,
            io6.output.imag    =>  S_out_module_from_th(4)(32*j+5).imag ,
            io7.output.reel    =>  S_out_module_from_th(4)(32*j+6).reel ,
            io7.output.imag    =>  S_out_module_from_th(4)(32*j+6).imag ,
            io8.output.reel    =>  S_out_module_from_th(4)(32*j+7).reel ,
            io8.output.imag    =>  S_out_module_from_th(4)(32*j+7).imag ,
            io9.output.reel    =>  S_out_module_from_th(4)(32*j+8).reel ,
            io9.output.imag    =>  S_out_module_from_th(4)(32*j+8).imag ,
            io10.output.reel   =>  S_out_module_from_th(4)(32*j+9).reel ,
            io10.output.imag   =>  S_out_module_from_th(4)(32*j+9).imag ,
            io11.output.reel   =>  S_out_module_from_th(4)(32*j+10).reel ,
            io11.output.imag   =>  S_out_module_from_th(4)(32*j+10).imag ,
            io12.output.reel   =>  S_out_module_from_th(4)(32*j+11).reel ,
            io12.output.imag   =>  S_out_module_from_th(4)(32*j+11).imag ,
            io13.output.reel   =>  S_out_module_from_th(4)(32*j+12).reel ,
            io13.output.imag   =>  S_out_module_from_th(4)(32*j+12).imag ,
            io14.output.reel   =>  S_out_module_from_th(4)(32*j+13).reel ,
            io14.output.imag   =>  S_out_module_from_th(4)(32*j+13).imag ,
            io15.output.reel   =>  S_out_module_from_th(4)(32*j+14).reel ,
            io15.output.imag   =>  S_out_module_from_th(4)(32*j+14).imag ,
            io16.output.reel   =>  S_out_module_from_th(4)(32*j+15).reel ,
            io16.output.imag   =>  S_out_module_from_th(4)(32*j+15).imag ,
            io17.output.reel   =>  S_out_module_from_th(4)(32*j+16).reel ,
            io17.output.imag   =>  S_out_module_from_th(4)(32*j+16).imag ,
            io18.output.reel   =>  S_out_module_from_th(4)(32*j+17).reel ,
            io18.output.imag   =>  S_out_module_from_th(4)(32*j+17).imag ,
            io19.output.reel   =>  S_out_module_from_th(4)(32*j+18).reel ,
            io19.output.imag   =>  S_out_module_from_th(4)(32*j+18).imag ,
            io20.output.reel   =>  S_out_module_from_th(4)(32*j+19).reel ,
            io20.output.imag   =>  S_out_module_from_th(4)(32*j+19).imag ,
            io21.output.reel   =>  S_out_module_from_th(4)(32*j+20).reel ,
            io21.output.imag   =>  S_out_module_from_th(4)(32*j+20).imag ,
            io22.output.reel   =>  S_out_module_from_th(4)(32*j+21).reel ,
            io22.output.imag   =>  S_out_module_from_th(4)(32*j+21).imag ,
            io23.output.reel   =>  S_out_module_from_th(4)(32*j+22).reel ,
            io23.output.imag   =>  S_out_module_from_th(4)(32*j+22).imag ,
            io24.output.reel   =>  S_out_module_from_th(4)(32*j+23).reel ,
            io24.output.imag   =>  S_out_module_from_th(4)(32*j+23).imag ,
            io25.output.reel   =>  S_out_module_from_th(4)(32*j+24).reel ,
            io25.output.imag   =>  S_out_module_from_th(4)(32*j+24).imag ,
            io26.output.reel   =>  S_out_module_from_th(4)(32*j+25).reel ,
            io26.output.imag   =>  S_out_module_from_th(4)(32*j+25).imag ,
            io27.output.reel   =>  S_out_module_from_th(4)(32*j+26).reel ,
            io27.output.imag   =>  S_out_module_from_th(4)(32*j+26).imag ,
            io28.output.reel   =>  S_out_module_from_th(4)(32*j+27).reel ,
            io28.output.imag   =>  S_out_module_from_th(4)(32*j+27).imag ,
            io29.output.reel   =>  S_out_module_from_th(4)(32*j+28).reel ,
            io29.output.imag   =>  S_out_module_from_th(4)(32*j+28).imag ,
            io30.output.reel   =>  S_out_module_from_th(4)(32*j+29).reel ,
            io30.output.imag   =>  S_out_module_from_th(4)(32*j+29).imag ,
            io31.output.reel   =>  S_out_module_from_th(4)(32*j+30).reel ,
            io31.output.imag   =>  S_out_module_from_th(4)(32*j+30).imag ,
            io32.output.reel   =>  S_out_module_from_th(4)(32*j+31).reel ,
            io32.output.imag   =>  S_out_module_from_th(4)(32*j+31).imag ,
            clk     => clk    );                                                  
                              
    end Generate;                                                
                                                        
                                                        
                                                        
                                                        
                                                        
                                                        
                                                        
                                                        
                                                        
                                                        
                                                        
-- 2 -> 4 -> 8 -> 16 -> 32 -> 64 -> 128 -> 256 -> 512      module 
-- 0 -> 1 -> 2 -> 3 --> 4 --> 5 ---> 6 ---> 7 ---> 8       enable index of module                               
-- 1 -> 2 -> 3 -> 4 --> 5 --> 6 ---> 7 ---> 8 ---> 9       L number
process (clk) 
begin                                     
                                                        
if rising_edge(clk) then

    ready_data <= S_pipl_tracker(5) ;
    S_pipl_tracker(9 downto 1) <= S_pipl_tracker(8 downto 0) ;

    if rst = '0' then
    
    S_N <= resize( x"2"sll L , 11 ) ;
    S_Mass_conrol_Core_ena(L-1 downto 0) <= (others=>'1');
    
    S_pipl_tracker(0) <= '0' ;
    
    
    elsif ena = '1' then
    
        case St_wrapper is 
        when Idle  => 
        rdy_time <= '1' ;
        St_wrapper <= Read_N_Set_W_4L ;
        
        S_pipl_tracker(0) <= '0' ;
        
                                                    
                                                    
        when Read_N_Set_W_4L  =>                    
        S_pipl_tracker(0) <= '0' ;
         -- async reset yapýp kullanlmayan modüllerde giriþlreden çýkýþlara direk baðlantý yapabilirsin 
         -- tavsiye edilmez : düþündüðümü belirtmek için yazdým 
         
         
         
                                                                           
                                                                           
        when Run  =>                            --
        rdy_time <= '0' ;                       --
        S_pipl_tracker(0) <= '1' ;
        -- The Sweet Escape 
        
                if we_time ='1' then
                    S_time_in_ram(to_integer(  unsigned(acl_p1_cooltuke_revrsordr( L , addr_time ))  )).pin  <= data_time ;
                end if ;
                
                
                --set input of freq buffer
                for j in 0 to to_integer(C_N_max)-1 loop
                 S_freq_out_ram(j).pin  <= S_out_module_from_th(4)(j).imag;
                end loop ;
                
        
                if re_freq ='1' then -------------------L 
                    data_freq <=  S_out_module_from_th(4)(    to_integer(unsigned(addr_freq))    ).reel ;
                end if ;
                rdy_freq <= S_pipl_tracker(4) ; -- insteaad of 5 for N= 32 to I chech 1 clk early and get the data on next cycle 
               
                
                
                
        
                                                
                                                     
                                                      
        --when Write  =>                               
                                                     
                             
        
        
        when others =>                                 
        
        S_pipl_tracker(0) <= '0' ;
                        
                                              
        end case ;                              
                                        
     
    
        
       
       --signed ve unsigned dönüþünde bitler deðiþiyor mu sadece yoksa taným olarak unsigned olarak mý tanýmlanýyor 
        
    else -- ena = '0' 
    
    
    S_pipl_tracker(0) <= '0' ;
    
    end if ;
    

end if ;
end process ;



end Behavioral;
