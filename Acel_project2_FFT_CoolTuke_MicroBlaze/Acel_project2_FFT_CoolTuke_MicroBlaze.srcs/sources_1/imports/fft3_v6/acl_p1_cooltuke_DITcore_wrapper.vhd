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
    addr_freq_wish   : in std_logic_vector(8 downto 0) := (others=>'0') ;   
    addr_freq_getten   : out std_logic_vector(8 downto 0) := (others=>'0') ;   
    re_freq      : in std_logic := '0' ;
        rdy_freq : out std_logic := '0' ;
    
    run_fft  : in std_logic := '0' ;
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
                if i <= L then
                    v_temp(L - i) := index_in(i);
                end if;
            end loop;
            
        return v_temp;
    end function;




Signal S_inout_reg : inout_1pin1_no2_W_fft_core :=  (
    input  => (others => (others => (reel => (Pin => (others => '0')), 
                                     imag => (Pin => (others => '0'))))),
    output => (others => (others => (reel => (Pin => (others => '0')), 
                                     imag => (Pin => (others => '0')))))
);


--( input=>(others=>(others=>(
--                                                                            reel => (Pin=>(others=>'0')), 
--                                                                            imag => (Pin=>(others=>'0')), 
--                                                                            ) ))  , 
--                                                      output=>(others=>(others=>(
--                                                                            reel => (Pin=>(others=>'0')), 
--                                                                            imag => (Pin=>(others=>'0'))), 
--                                                                            ) )) );
                                                        
 
 Signal S_re_freq_pre : std_logic := '0' ;


Signal S_userL_int : integer range 0 to 9 := 4 ; 
type M_block_ram is array (integer range 0 to 5 )of std_logic_vector(8 downto 0) ;
Signal S_M_select_blockram : M_block_ram := (
"000000001",
"000000011",
"000000111",
"000001111",
"000011111",
"000111111"--,
--"0001111111",
--"0011111111",
--"0111111111",
--"1111111111"


) ;

  
Signal S_ena_CoreN : std_logic := '0' ;
Signal S_coreN_complete : std_logic := '0' ;
Signal S_CoreN_rst : std_logic := '0' ;

begin




    acl_p2cooltuke_DITcoreN_mdl : entity Work.acl_p2cooltuke_DITcoreN   
--    Generic(
--    Lmax_int : integer range 0 to 9 := number_of_module_type_minus1 ;
--    N_max_int : integer range 0 to 63 := number_of_pin_minus1 ;
--    N_half_minus1 : integer range 0 to 31 := number_of_pin_div2_minus1 
--     );
    Port Map( 
    ena         => S_ena_CoreN ,
    
    L_userint  => userL_int ,
    
    input_Nover2   => S_inout_reg.input   , -- : in  ix ;
    output_Nover2  => S_inout_reg.output  , -- :out  ix ;
    
    
--    error_W_index_multiplier : out std_logic := '0' ;
        
    complete => S_coreN_complete , --pulse
    
    rst => S_CoreN_rst ,
    clk => clk 
    );
                                   
                                                       
                                                        
-- 2 -> 4 -> 8 -> 16 -> 32 -> 64 -> 128 -> 256 -> 512      module 
-- 0 -> 1 -> 2 -> 3 --> 4 --> 5 ---> 6 ---> 7 ---> 8       enable index of module                               
-- 1 -> 2 -> 3 -> 4 --> 5 --> 6 ---> 7 ---> 8 ---> 9       L number
              --  0     0     1       2     3     4        rst index of module        
              
            
                               
              
process (clk ) 

variable V_time_adress : std_logic_vector(9 downto 0) ;
begin                
 
                                                        
                                                              
                                                        
if rising_edge(clk) then


    S_re_freq_pre <= re_freq;

    if rst = '0' then
    
        rdy_time <= '1' ;
        rdy_freq <= '0' ;
        S_CoreN_rst <= '0' ; 
        S_ena_CoreN <= '0' ;
        St_wrapper <= St_Idle ;
        
    else
    
        case St_wrapper is 
        when St_Idle  => 
            
            S_ena_CoreN <= '0' ;
            S_CoreN_rst <= '1' ; 
            
            
            if ena = '1' then
                S_userL_int <= userL_int ;
                rdy_time <= '1' ;
                rdy_freq <= '0' ;
                St_wrapper <= St_Write ;
            end if ;
                                                     
        when St_Write  =>     
            
                if we_time ='1' then -- ilerleyen zamanlarda tek seferde daha fazla veri al 
--                    user defined bölgelere gelince segmenti ibir üste geçir 
                    if addr_time <= "001111111" then
                        V_time_adress := '0' & acl_p1_cooltuke_revrsordr(  S_userL_int , addr_time and S_M_select_blockram(S_userL_int) ) ;
                        if V_time_adress(0) = '0' then
                            S_inout_reg.input(    to_integer(unsigned(  V_time_adress(S_userL_int downto 1) )) )(0).reel  <= data_time ;
                        else
                            S_inout_reg.input(    to_integer(unsigned(  V_time_adress(S_userL_int downto 1) )) )(1).reel  <= data_time ;
                        end if ;
                        
                    end if;
                    --ix(x:0)(x+1).input.reel.pin
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
                S_CoreN_rst <= '1' ; 
                St_wrapper <= St_Read ;            
            end if ;              
                                     
        when St_Read  =>                               
                        rdy_time <= '0' ;
                        rdy_freq <= '1' ;   
                if re_freq ='1' then -------------------L 
                    addr_freq_getten <= addr_freq_wish ;
                    if addr_freq_wish(number_of_module_type_minus1) = '0' then        
                        data_freq <=  S_inout_reg.output(to_integer(  resize( unsigned ( addr_freq_wish  ),  number_of_module_type_minus1) )  )(0)  ;
                    else
                        data_freq <=  S_inout_reg.output(to_integer(  resize( unsigned ( addr_freq_wish  ),  number_of_module_type_minus1) )  )(1)  ;
                    end if ;   
                    
                end if ;
                
        
        when others =>                                 
                       
        end case ;                              
                               
       --signed ve unsigned dönüþünde bitler deðiþiyor mu sadece yoksa taným olarak unsigned olarak mý tanýmlanýyor 
         
    end if ;
    

end if ;
end process ;



end Behavioral;
