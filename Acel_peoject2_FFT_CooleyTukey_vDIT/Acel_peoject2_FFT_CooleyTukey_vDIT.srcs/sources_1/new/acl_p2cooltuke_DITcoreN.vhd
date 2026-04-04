----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.04.2026 13:52:21
-- Design Name: 
-- Module Name: acl_p2cooltuke_DITcoreN - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity acl_p2cooltuke_DITcoreN is
    Generic(
    Lmax_int : integer range 0 to 9 := number_of_module_type_minus1 ;
    N_max_int : integer range 0 to 127 := number_of_pin_minus1 ;
    N_half_minus1 : integer range 0 to 31 := number_of_pin_div2_minus1 
     );
    Port ( 
    ena : in std_logic := '0' ;
    
    L_int : in integer range 0 to 9 := 4;
    M_int : in integer  range 0 to 63 := 31 ;
    
    M_N_main : inout ix ; -- çifter çifer doldurulsun lik bir döngüde uart yada ad den gelen veri doldurulmuþ olur 
        
        
        
    error_W_index_multiplier : out std_logic := '0' ;
        
    complete : out  std_logic := '0' ;
    
    rst : in std_logic := '1' ;
    clk : in STD_LOGIC  := '0' 
    );
end acl_p2cooltuke_DITcoreN;

architecture Behavioral of acl_p2cooltuke_DITcoreN is


Signal M_N : ix ;
Signal W : W_rom := (others=>(C_Wrom(0)  ));


Signal L_cntr : integer range 0 to 9 := 0 ;
Signal L_cntr_user_max : integer range 0 to 9 := Lmax_int ;
Signal M_cntr_user_max : integer range 0 to 63 := N_max_int  ;


type State_core_N is (St_Idle , 
                St_core2 , St_core4 , St_core8 , 
                St_core16 , St_core32 , St_core64 , 
                St_core_final ) ;

signal St_core_N  : State_core_N := St_Idle ;



signal S_fft_mdl_actv_02 : std_logic := '0' ;
signal S_fft_mdl_actv_04 : std_logic := '0' ;
signal S_fft_mdl_actv_08 : std_logic := '0' ;
signal S_fft_mdl_actv_16 : std_logic := '0' ;
signal S_fft_mdl_actv_32 : std_logic := '0' ;

Signal S_done : std_logic := '0' ;
Signal S_rst : std_logic := '0' ;
Signal ena_pre : std_logic := '0' ;

Shared Variable V_j_for  : std_logic_vector(7 downto 0) := (others=>'0') ;
Shared Variable V_ix_m  : std_logic_vector(6 downto 0) := (others=>'0') ;
Shared Variable V_sg_m  : std_logic_vector(1 downto 0) := (others=>'0') ;
Shared Variable V_W_m  : unsigned(7 downto 0) := (others=>'0') ;

Signal W_index_multiplier : integer range 1 to 8 := 4 ; 

begin

    
    GEN_FFTMODL_2 : for j in 0 to number_of_pin_div2_minus1 generate -- N = 32 için N/2 tanesi 16 tane FFTcore2 lazým 
      
      

        Mas_produce_FFTcore2 : entity work.acl_p1_cooltuke_DITcore_2
--            Generic(--            W_Max     : W_bit_width_min_max := (  WkN  =>  x"7f" ) ;   -- 8bit--            W_0_n32r  : W_bit_width_min_max := (  WkN  =>  x"7f" ) ;  --            W_0_n32i  : W_bit_width_min_max := (  WkN  => x"00" )--            );
            Port Map( 
--            ena     => S_ena ,
            
            io1   =>  M_N(j)(0)   ,
            
            W => W(j),
            
            io2   =>  M_N(j)(1)   ,
            done  => S_done ,
            rst    => S_rst  ,                                                
            clk     => clk     );
            
            
            
            
            
            
    end Generate;   
    
    
    process (clk) begin
    if rising_edge(clk) then
                    complete <= '0' ;
                    
                    
    if rst = '0' then 
    else 
                    S_rst <= '0' ;
    
        case (St_core_N) is 
            when  St_Idle   =>
                    
                    if L_cntr_user_max = Lmax_int then
                        L_cntr_user_max <= L_int ;
                    else 
                        L_cntr_user_max <= Lmax_int ;
                    end if ;
                    if M_cntr_user_max = N_max_int then
                        M_cntr_user_max <= M_int ;
                    else 
                        M_cntr_user_max <= N_max_int ;
                    end if ;
                    
                    
                ena_pre <= ena;
                if ena_pre = '0' and ena = '1' then
                    S_rst <= '1' ;
                    
                    
                    case M_cntr_user_max is 
                    when 31=> 
                        W_index_multiplier <= 2;
                    when 63=> 
                        W_index_multiplier <= 1;
                    when 127=> 
                        W_index_multiplier <= 0;
                    when others =>
                        null ;
                    error_W_index_multiplier <= '1' ;
                    end case ;
                    
                    
                     for i in 0 to 1 loop -- ilki w sýz olan ikincisi W ile çarpýlacak olan 
                         for j in 0 to number_of_pin_div2_minus1 loop -- N = 32 için N/2 tanesi 16 tane FFTcore2 lazým 
           
 if j*2 <M_cntr_user_max  then 
                           M_N(j)(i).input <= M_N_main(j)(i).input;
end if ;    
                         end loop ;
                     end loop ;
                    
                    St_core_N <= St_core2 ;
                     L_cntr <= 1 ;
                      
                end if ;
            
            
            
            
            
            
            
            
            when  St_core2  => -- L = 0
                
                
                if S_done = '1' then 
                    if  L_cntr <= L_cntr_user_max then 
                        L_cntr <= L_cntr + 1  ;-- 1 clk sonradan geliyor ve bu modüle ilk girdiðinde modüle 4lü giriþi  çalýþtýracak çünkü L= 1 , 
               
                    S_rst <= '1' ;
                        
                        for j in 0 to number_of_pin_div2_minus1 loop -- N = 32 için N/2 tanesi 16 tane FFTcore2 lazým 
                       

                                
                        for i in 0 to 1 loop -- ilki w sýz olan ikincisi W ile çarpýlacak olan 
 if j*2 <M_cntr_user_max and L_cntr_user_max <= Lmax_int then 
 
                            V_j_for :=  std_logic_vector(to_unsigned(   (i*(number_of_pin_div2_minus1+1) +j),Lmax_int+1  )) ;-- L is 0 
                            
                            if L_cntr = 0 then
                                V_ix_m  :=  V_j_for(Lmax_int downto 1) ;
                                V_W_m := (Others =>('0') ) ;
                            elsif L_cntr = Lmax_int then
                                V_ix_m  :=  V_j_for(Lmax_int-1 downto 0) ;
                                
                            else
                                V_ix_m :=  V_j_for(Lmax_int downto  L_cntr+1) & V_j_for(L_cntr-1 downto  0) ;
                                
--                                V_W_m := std_logic_vector(to_unsigned(j,Lmax_int+1)) ;--  sra Lmax_int ;
                                V_W_m := shift_left(to_unsigned(j, Lmax_int), Lmax_int - L_cntr+ W_index_multiplier);
                            end if ;
                            
                            V_sg_m := '0' & V_j_for(L_cntr) ;
                            
                            
                            
                            
                            W(j) <= C_Wrom( to_integer( V_W_m )  );
                            
                            M_N(j)(i).input <= M_N( to_integer(unsigned(V_ix_m)) )( to_integer(unsigned(V_sg_m)) ).output   ;
                        
 end if ;                       
                    
                        end loop ;
                        end loop ;
                    
                    
                    else
                        
                        for i in 0 to 1 loop -- ilki w sýz olan ikincisi W ile çarpýlacak olan 
                        for j in 0 to number_of_pin_div2_minus1 loop -- N = 32 için N/2 tanesi 16 tane FFTcore2 lazým 
                       
                            
                            M_N_main(j)(i).output <= M_N( j )( i ).output   ; -- verilerin çýkýþý da sýrasý ile olacak küçük olanlar 0 . index , te büyük olanlar 1. indexte 
                        
                        
                    
                        end loop ;
                        end loop ;
                    
                        complete <= '1' ;
                        St_core_N <= St_Idle;
                    end if ;
                    
                end if ;
                
                
                
       
            when others => 
            
            null ;
            
            
        end case ;
    end if ;
    end if ;
    end process ;
    
    
    
    
    
       

end Behavioral;
