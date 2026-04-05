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
    data_time   : in  pin_width := (Pin=>(others=>'0' )) ; 
    addr_time   : in std_logic_vector(8 downto 0) := (others=>'0') ; 
    we_time     : in std_logic := '0' ;
        rdy_time : out std_logic := '0' ;
    userL_int : in integer range 0 to 9 := 4 ; 
    
        data_freq   : out  pin_reel_img := (reel=> (Pin=>(others=>'0' )) , imag=>(Pin=>(others=>'0' ))) ; 
    addr_freq   : in std_logic_vector(8 downto 0) := (others=>'0') ;   
    re_freq      : in std_logic := '0' ;
        rdy_freq : out std_logic := '0' ;
    
--    byte3 : in std_logic_vector(3 downto 0) := x"0" ;
--    byte2 : in std_logic_vector(3 downto 0) := x"0" ;
--    byte1 : in std_logic_vector(3 downto 0) := x"0" ;
--    byte0 : in std_logic_vector(3 downto 0) := x"0" ;
    
    re_run_fft : in std_logic := '0' ;
    run_fft  : in std_logic := '0' ;
        ready_data  : out std_logic := '0' ; -- when change on L value set 0 and when loading data
    rst : std_logic := '1' 
    );
end acl_p1_cooltuke_DITcore_wrapper;

architecture Behavioral of acl_p1_cooltuke_DITcore_wrapper is



                                   -- 512-8  tane w de?eri sakla N 16 den N 512 ye i?lem yaps?n 
                                   -- 16 den 512 ye W(up:0 to (n1/2)-1)(down:n1) n1::2 to 512

type State_4wraper is (St_Idle , St_Write , St_Run , St_Read  , St_Done) ;
Signal St_wrapper : State_4wraper  := St_Idle ;



 function acl_p1_cooltuke_revrsordr (
                        L :  integer range 1 to 8  ;
                        index_in :  std_logic_vector(8 downto 0)  
                         )   return std_logic_vector is
        variable v_temp : std_logic_vector(8 downto 0) := (others=>'0');
    begin
        
            for i in 0 to 7 loop
                if i < L then
                    v_temp((L-1) - i) := index_in(i);
                end if;
            end loop;
            
        return v_temp;
    end function;


-- 2 -> 4 -> 8 -> 16 -> 32 -> 64 -> 128 -> 256 -> 512
-- 0 -> 1 -> 2 -> 3 --> 4 --> 5 ---> 6 ---> 7 ---> 8 

Signal S_time_in_ram_zero : module_pins := (others=>( pin=>(others=> '0'))) ;
--Signal S_time_in_ram : module_pins   ;
Signal S_time_in_ram_flag : std_logic := '0' ; --when 2^L-1 value collected push new value to fft core
Signal S_M_N_main : ix ;
--Signal S_freq_out_ram : module_pins  ;
Signal S_freq_out_ram_flag : std_logic := '0' ; -- High to get out from fft module 


type module_pins_ri is array ( integer range 0 to 31 ) of pin_reel_img ; -- 


 Signal S_re_freq_pre : std_logic := '0' ;



constant N : integer range 0 to 31 := 0;
constant qN : integer range 0 to 31 := 8; -- seçili olan N deðerine göre qurter þimdilik 32 yi seçtim 
 
 
type M_block_ram is array (integer range 0 to 5 )of unsigned(9 downto 0) ;

Signal S_M_select_blockram : M_block_ram := (
"0000000001",
"0000000011",
"0000000111",
"0000001111",
"0000011111",
"0000111111"--,
--"0001111111",
--"0011111111",
--"0111111111",
--"1111111111"


) ;



 Signal S_userL_int : integer range 0 to 9 := 4;
 Signal S_userM_int : integer  range 0 to 63 := to_integer (S_M_select_blockram(S_userL_int) );
 
 
 
 
Signal S_ena_CoreN : std_logic := '0' ;
Signal S_coreN_complete : std_logic := '0' ;
Signal S_wraper_rst : std_logic := '0' ;
Signal M_clk : std_logic := '0' ;

begin




    acl_p2cooltuke_DITcoreN_mdl : entity Work.acl_p2cooltuke_DITcoreN   
--    Generic(
--    Lmax_int : integer range 0 to 9 := number_of_module_type_minus1 ;
--    N_max_int : integer range 0 to 63 := number_of_pin_minus1 ;
--    N_half_minus1 : integer range 0 to 31 := number_of_pin_div2_minus1 
--     );
    Port Map( 
    ena         => S_ena_CoreN ,
    
    L_int  => S_userL_int ,
    M_int  => S_userM_int ,
    
    M_N_main => S_M_N_main ,  -- çifter çifer doldurulsun lik bir döngüde uart yada ad den gelen veri doldurulmuþ olur 
        
--    error_W_index_multiplier : in std_logic := '0' ;
        
    complete => S_coreN_complete , --impulse
    
    rst => S_wraper_rst ,
    clk => M_clk 
    );
                                   
                                                       
                                                        
-- 2 -> 4 -> 8 -> 16 -> 32 -> 64 -> 128 -> 256 -> 512      module 
-- 0 -> 1 -> 2 -> 3 --> 4 --> 5 ---> 6 ---> 7 ---> 8       enable index of module                               
-- 1 -> 2 -> 3 -> 4 --> 5 --> 6 ---> 7 ---> 8 ---> 9       L number
              --  0     0     1       2     3     4        rst index of module        
              
 process (clk) begin 
 if rising_edge(clk) then
 M_clk <= not M_clk ;
 
 end if ;
 end process ;             
                               
              
process (M_clk ) 

variable V_time_adress : std_logic_vector(9 downto 0) ;
begin                
 
                                                        
                                                              
                                                        
if rising_edge(M_clk) then


    S_re_freq_pre <= re_freq;

    if rst = '0' then
    
        rdy_time <= '0' ;
        rdy_freq <= '0' ;
        
    else
    
        case St_wrapper is 
        when St_Idle  => 
            
            S_ena_CoreN <= '0' ;
            S_wraper_rst <= '1' ; 
            
            
            
            if ena = '1' then
            
            
            rdy_time <= '1' ;
            rdy_freq <= '0' ;
            
            S_userL_int  <= userL_int ;
            S_userM_int <= to_integer(S_M_select_blockram(userL_int) );
            
            
            St_wrapper <= St_Write ;
            end if ;
                                                     
        when St_Write  =>              
            rdy_time <= '1' ;
            rdy_freq <= '0' ;
                if we_time ='1' then -- ilerleyen zamanlarda tek seferde daha fazla veri al 
                    
--                    user defined bölgelere gelince segmenti ibir üste geçir 
                    V_time_adress := '0' & acl_p1_cooltuke_revrsordr( userL_int , addr_time ) ;
                    S_M_N_main( to_integer(unsigned(  V_time_adress(number_of_module_type_minus1-1 downto number_of_module_type_minus1 )) )    )(to_integer(  unsigned(  V_time_adress(number_of_module_type_minus1-1 downto 0) )     )).input.reel.pin  <= data_time.pin ;
                    
                elsif run_fft = '1' then -- son veriyle birlikte run komutu geldi 
                    St_wrapper <= St_Run ; 
                     
                    
                    
                    
            S_ena_CoreN <= '1' ;
            
            
                end if ;
                
--            S_Mass_conrol_Core_rst_main <= (others=>'0') ;
                
                                                                              
                                                                           
        when St_Run  =>             

            rdy_time <= '0' ;  
            rdy_freq <= '0' ;
            
            
-- 2 -> 4 -> 8 -> 16 -> 32 -> 64 -> 128 -> 256 -> 512       module                        
-- 0 -> 1 -> 2 -> 3 --> 4 --> 5 ---> 6 ---> 7 ---> 8        enable index of module       
-- 0    1    2    3     4     5        rst index of module    
--                Kaynak Hesplamasý ve yapýlan tahminler 64 e kadar hizmet verebileceðimi söylüyor  -- The Sweet Escape 

                
            --set input of freq buffer
            
            
            if S_coreN_complete = '1' then   
                S_ena_CoreN <= '0' ;
                S_wraper_rst <= '1' ; 
                St_wrapper <= St_Read ;            
            end if ;              
                                     
        when St_Read  =>                               
                        rdy_time <= '0' ;
                        rdy_freq <= '1' ;   
                if re_freq ='1' then -------------------L 
                
                if addr_freq(number_of_module_type_minus1) = '0' then
                    data_freq <=  S_M_N_main( 0  )(to_integer( unsigned (  addr_freq(number_of_module_type_minus1-1 downto 0) )     )).output  ;
                else
                    data_freq <=  S_M_N_main( 0  )(to_integer( unsigned (  addr_freq(number_of_module_type_minus1-1 downto 0) )     )).output  ;
                end if ;   
                    
                elsif (S_re_freq_pre ='1' and re_freq ='0') or (addr_freq = "000100000" )then -- N = 32
                    St_wrapper <= St_Done ; 
                end if ;
                
                
--                S_Mass_conrol_Core_rst_main <= (others=>'0') ;
                -- 
--                enable is  short circit     ,, to fast forward  next module    dis enable module                     
--                rst is disconneted , to read disconnect modüle              
        
        
        when St_Done =>
            rdy_time <= '1' ;  
            rdy_freq <= '0' ;
            if re_run_fft = '1' then
                St_wrapper <= St_Idle ; 
            end if ;
        
        
        when others =>                                 
        
                                              
        end case ;                              
                                        
     
    
        
       
       --signed ve unsigned dönüþünde bitler deðiþiyor mu sadece yoksa taným olarak unsigned olarak mý tanýmlanýyor 
         
    end if ;
    

end if ;
end process ;



end Behavioral;
