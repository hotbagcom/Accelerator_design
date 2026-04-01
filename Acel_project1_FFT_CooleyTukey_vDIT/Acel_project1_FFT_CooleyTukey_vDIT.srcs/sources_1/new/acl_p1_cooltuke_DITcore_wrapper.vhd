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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

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


type miniram is array( integer range 0 to 512-1 ) of integer range 0 to 4095 ;  -- Time and Freq , memory  

Signal S_time_in_ram : miniram  := (  others=>(1)  );
Signal S_time_in_ram_flag : std_logic := '0' ; --when 2^L-1 value collected push new value to fft core
Signal S_freq_out_ram : miniram := (  others=>(1)  );
Signal S_freq_out_ram_flag : std_logic := '0' ; -- High to get out from fft module 

                                   -- 512-8  tane w de?eri sakla N 16 den N 512 ye i?lem yaps?n 
                                   -- 16 den 512 ye W(up:0 to (n1/2)-1)(down:n1) n1::2 to 512
type mikroram is array( integer range 0 to 512-8 -1) of integer range 0 to 1023 ;  -- W value memory  
Signal S_NL_2_W : mikroram := (  others=>(5)  ); 

type State_4wraper is (Idle , Read_N_Set_W_4L , Run , Write ) ;
Signal St_wrapper : State_4wraper  := Idle ;


type input_4fft_module is record
            S_up : integer range 0 to 4095 ; -- 2^12 -1
            W_4down : integer range 0 to 1023 ;
            S_down : integer range 0 to 4095 ;  -- 2^12 -1
            end record;
type output_4fft_module is record
            S_up : integer range 0 to 4095 ; -- 2^12 -1
            S_down : integer range 0 to 4095 ;  -- 2^12 -1
            end record;
            
type input_couple_4fft is array(0 to 255) of input_4fft_module ;

-- 2 -> 4 -> 8 -> 16 -> 32 -> 64 -> 128 -> 256 -> 512
-- 0 -> 1 -> 2 -> 3 --> 4 --> 5 ---> 6 ---> 7 ---> 8 
type input_butterfly_4fft is array(0 to 8) of input_couple_4fft ;
Signal S_input_to_module : input_butterfly_4fft := (others=>(others=>(1 , 1 , 1))) ;


type output_couple_4fft is array(0 to 255) of output_4fft_module ;
type output_butterfly_4fft is array(0 to 8) of output_couple_4fft ;
Signal S_output_to_module : output_butterfly_4fft := (others=>(others=>(1 , 1))) ;


Signal S_N : std_logic_vector(9 downto 0) := (others=>'0'); -- 512+511 limit 
Signal S_N_half : std_logic_vector(9 downto 0) := (others=>'0'); -- 256+255 limit 

Signal S_N_pre : std_logic_vector(9 downto 0) := (others=>'0'); -- 512+511 limit 
Signal S_L_pre : integer range 1 to 10 := L ; 
Signal S_ready : std_logic := '0' ;
Signal S_L_pipline_counter : integer range 1 to 10 := 1 ;
            
Signal S_L_change_wait : integer range 1 to 10*4 := 0 ; -- split one fft butterfly to 4 part 
Signal S_fftout_valid : std_logic := '0' ;

begin

acl_p1_cooltuke_DITcore_2_mdl      -- to save space use upper wing and switch W value and use lower wing 
acl_p1_cooltuke_DITcore_4_mdl      -- to save space use upper wing and switch W value and use lower wing 
acl_p1_cooltuke_DITcore_8_mdl      -- to save space use upper wing and switch W value and use lower wing 
acl_p1_cooltuke_DITcore_16_mdl     -- to save space use upper wing and switch W value and use lower wing 
acl_p1_cooltuke_DITcore_32_mdl     -- to save space use upper wing and switch W value and use lower wing 
acl_p1_cooltuke_DITcore_64_mdl     -- to save space use upper wing and switch W value and use lower wing 

acl_p1_cooltuke_DITcore_128_mdl  -- piplinable aplly even quarter and odd quarter 2 save sesource
acl_p1_cooltuke_DITcore_256_mdl  -- piplinable aplly even quarter and odd quarter 2 save sesource


             
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
    
    GEN_FFTMODL :for j in 0 to 8 loop 
    if j < S_L_pre then
        
        if j = 0 then -- 2 giriþ 
            acl_p1_cooltuke_DITcore_2_mdl
        end if ;
    
    
        for i in 0 to 255 loop         -- feed by time_input 
        if i < to_integer(unsigned(S_N_half)) then 
        
            if S_L_pipline_counter <= S_L_pre then -- yeni L ile gelen veriyi ad?m ad?m sistemin W de?erlerini de?i?tirerek i?eri al
                S_L_pipline_counter <= S_L_pipline_counter +1;
          
                    S_002input_module(i).S_up    <= S_time_in_ram(i);
                    S_002input_module(i).W_4down <= S_NL_2_W( to_integer(unsigned(S_N)) );
                    S_002input_module(i).S_down  <= S_time_in_ram(i+to_integer(unsigned(S_N(9 downto 1)));
                    
                    
                    S_002output_module(i).S_up ;
            
            else 
                S_L_pipline_counter <= 0 ;
                
            end if ;
            
        end if ;       
        
        end loop;      
    end if ;
    end loop;                      
        
    
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
