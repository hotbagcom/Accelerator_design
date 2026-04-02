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
    data_time   : in std_logic_vector(11 downto 0) := (others=>'0') ; 
    addr_time   : in std_logic_vector(9 downto 0) := (others=>'0') ; 
    we_time     : in std_logic := '0' ;
    
    L : in integer range 1 to 10 := 3 ; 
    
    data_freq   : out std_logic_vector(11 downto 0) := (others=>'0') ;   
    addr_freq   : out std_logic_vector(9 downto 0) := (others=>'0') ;   
    we_out      : out std_logic := '0' ;
    done        : out std_logic := '0' ;
    
    
    
    
    ready        : out std_logic := '0' ; -- when change on L value set 0 and when loading data
    rst : std_logic := '1' 
    );
end acl_p1_cooltuke_DITcore_wrapper;

architecture Behavioral of acl_p1_cooltuke_DITcore_wrapper is



                                   -- 512-8  tane w de?eri sakla N 16 den N 512 ye i?lem yaps?n 
                                   -- 16 den 512 ye W(up:0 to (n1/2)-1)(down:n1) n1::2 to 512

type State_4wraper is (Idle , Read_N_Set_W_4L , Run , Write ) ;
Signal St_wrapper : State_4wraper  := Idle ;




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



--type output_couple_4fft is array(0 to 255) of output_4fft_module ;
--type output_butterfly_4fft is array(0 to 8) of output_couple_4fft ;
--Signal S_output_to_module : output_butterfly_4fft := (others=>(others=>(1 , 1))) ;


--Signal S_N : std_logic_vector(9 downto 0) := (others=>'0'); -- 512+511 limit 
--Signal S_N_half : std_logic_vector(9 downto 0) := (others=>'0'); -- 256+255 limit 

--Signal S_N_pre : std_logic_vector(9 downto 0) := (others=>'0'); -- 512+511 limit 
--Signal S_L_pre : integer range 1 to 10 := L ; 
Signal S_ready : std_logic := '0' ;
--Signal S_L_pipline_counter : integer range 1 to 10 := 1 ;
            
--Signal S_L_change_wait : integer range 1 to 10*4 := 0 ; -- split one fft butterfly to 4 part 
Signal S_fftout_valid : std_logic := '0' ;


Signal est : integer range -2047 to 2047 := 0; 

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
        Mas_produce_FFTcore4 : entity work.acl_p1_cooltuke_DITcore_8
--    Generic(                                                                     W_0_n32r  : W_bit_width_min_max := (  WkN  =>  X"7F"  ) ;  W_8_n32r  : W_bit_width_min_max := (  WkN  =>  X"00"  ) ;       
--    W_Max     : W_bit_width_min_max := (  WkN  =>  X"7F"  ) ;   -- 8bit          W_0_n32i  : W_bit_width_min_max := (  WkN  =>  X"00"  ) ;  W_8_n32i  : W_bit_width_min_max := (  WkN  =>  X"81"  )     );  

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
                                                     
            io1.output.reel   =>  S_out_module_from_th(1)(8*j).reel ,
            io1.output.imag   =>  S_out_module_from_th(1)(8*j).imag ,
            io2.output.reel   =>  S_out_module_from_th(1)(8*j+1).reel ,  
            io2.output.imag   =>  S_out_module_from_th(1)(8*j+1).imag ,  
            io3.output.reel   =>  S_out_module_from_th(1)(8*j+2).reel ,
            io3.output.imag   =>  S_out_module_from_th(1)(8*j+2).imag ,
            io4.output.reel   =>  S_out_module_from_th(1)(8*j+3).reel ,  
            io4.output.imag   =>  S_out_module_from_th(1)(8*j+3).imag ,  
            io5.output.reel   =>  S_out_module_from_th(1)(8*j+4).reel ,
            io5.output.imag   =>  S_out_module_from_th(1)(8*j+4).imag ,
            io6.output.reel   =>  S_out_module_from_th(1)(8*j+5).reel ,  
            io6.output.imag   =>  S_out_module_from_th(1)(8*j+5).imag ,  
            io7.output.reel   =>  S_out_module_from_th(1)(8*j+6).reel ,
            io7.output.imag   =>  S_out_module_from_th(1)(8*j+6).imag ,
            io8.output.reel   =>  S_out_module_from_th(1)(8*j+7).reel ,  
            io8.output.imag   =>  S_out_module_from_th(1)(8*j+7).imag ,  
                                                                                         
                                                      
            clk     => clk    );
    end Generate;                      
 
 
 
 
 
 
ready <= S_ready ;

process (clk) begin 

if rising_edge(clk) then

if rst = '0' then
    St_wrapper <= Idle ;
    S_ready <= '0' ;
    S_fftout_valid <= '0' ;
    S_N <= (others=>'0');
    S_N_half <= (others=>'0');

elsif ena = '1' then
    if S_L_pre /= L then  -- datalar yeni girmi? oluyor o y?zden busy bayra??? kald?r 
        S_ready <= '0' ;
        if S_L_pre > L then -- Lpre = 3 , L = 2  wait for 1 cycle 
            S_L_change_wait <= ( S_L_pre - L)  ; -- * active segment amount or siplited butterfly amount
        else
            S_L_change_wait <= 0 ;
        end if ;
    S_N <= (others=>'0');
    S_N_half <= (others=>'0');
    S_N_pre <= S_N;
        S_L_pipline_counter <= 1 ;
    end if ;
    
    case St_wrapper is 
    when Idle => 
        S_L_pre <= L ;
        
        if S_L_change_wait > 1 then 
            S_L_change_wait <= S_L_change_wait -1 ;
        else -- S_L_change_wait = 1 by getting into this condition check , it waited for 1 more cyle 
            St_wrapper <= Read_N_Set_W_4L ;
        end if ;
        S_N(L) <= '1' ; 
        S_N_half(L-1)  <='1' ;
        
    when Read_N_Set_W_4L => 
    -- set w value according to new L value 
    
    -- first no change on L value then adapt L change scenaerio 
           
    
    when Run => 
    
    
    
    when Write =>  
    
    
    
    end case ;




S_L_pre <= L ;

if S_L_pre /= L then
S_L_pre <= L ;






else -- ena = '0' 


end if ;
S_fftout_valid <= '0' ;

end if ;
end process ;



end Behavioral;
