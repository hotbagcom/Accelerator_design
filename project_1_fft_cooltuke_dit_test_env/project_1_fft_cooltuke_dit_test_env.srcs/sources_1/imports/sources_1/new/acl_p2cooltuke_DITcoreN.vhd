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
    Lmax_int : integer range 0 to 9 := number_of_module_type_minus1 
--    Mmax_int : integer range 0 to 127 := number_of_pin_minus1 ;
--    Mhalf_minus1 : integer range 0 to 63 := number_of_pin_div2_minus1 
     );
    Port ( 
    ena : in std_logic := '0' ;
    
    L_userint : in integer range 0 to 9 := 4;
    
    
    input_Nover2  : in  ix ;
    output_Nover2 :out  ix ;
        
        
    error_W_index_multiplier : out std_logic := '0' ;
        
    complete : out  std_logic := '0' ; -- pulse
    
    rst : in std_logic := '1' ;
    clk : in STD_LOGIC  := '0' 
    );
end acl_p2cooltuke_DITcoreN;

architecture Behavioral of acl_p2cooltuke_DITcoreN is


Signal M_N : inout_1pin1_no2_W_fft_core ;
Signal W : W_rom := (others=>(C_Wrom(0)  ));


Signal L_cntr : integer range 0 to 9 := 3 ;
Signal L_cntr_user_max : integer range 0 to 9 := Lmax_int ;
Signal M_cntr_user_max : integer range 0 to 127 := 0  ;
Signal M_cntr_user_Hmax : integer range 0 to 63 := 0  ;


type State_core_N is (St_Idle , 
                St_core2 , St_core4 , St_core8 , 
                St_core16 , St_core32 , St_core64 , 
                St_core_final ) ;

signal St_core_N  : State_core_N := St_Idle ;




Signal S_done : std_logic_vector(number_of_pin_div2_minus1 downto 0) := (others=> '0') ;
Signal S_rst : std_logic_vector(number_of_pin_div2_minus1 downto 0) := (others=> '0') ;
Signal ena_pre : std_logic := '0' ;

Shared Variable V_j_for  : std_logic_vector(9 downto 0) := (others=>'0') ;
Shared Variable V_ix_m  : std_logic_vector(8 downto 0) := (others=>'0') ;
Shared Variable V_sg_m  : std_logic_vector(1 downto 0) := (others=>'0') ;
Shared Variable V_W_m  : unsigned(7 downto 0) := (others=>'0') ;

Signal W_index_multiplier : integer range 0 to 8 := 4 ; --128/32 -- 128 : depodaki  -- 32: sistemin aktif tst N deðeri 

begin

    
    GEN_FFTMODL_2 : for j in 0 to number_of_pin_div2_minus1 generate -- N = 32 için N/2 tanesi 16 tane FFTcore2 lazým 
        Mas_produce_FFTcore2 : entity work.acl_p1_cooltuke_DITcore_2
--            Generic(    W_Max     : signed(C_w_bit_len-1 downto 0) := x"7f"   -- 8bit    ); 
            Port Map( 
--            ena     => to_unsigned(L_cntr_user_max,Lmax_int+1 )(j) ,
            input =>  M_N.input(j)   , -- : in segm ; -- 0 w ile çapýmdan toplanan giriþ , 1 w ile çarpýlan giriþ 
            W => W(j),
                output   =>  M_N.output(j)   ,
            rst    => S_rst(j)  ,
                done  => S_done(j) ,       -- impulse                                    
            clk     => clk     
            );
    end Generate;   
    
    
    process (clk) begin
    if rising_edge(clk) then
            
                    
                    
    if rst = '0' then 
            if L_userint <= Lmax_int then
                L_cntr_user_max <= L_userint   ; 
            else 
                L_cntr_user_max <= Lmax_int;
            end if ; 
            
-- 2 -> 4 -> 8 -> 16 -> 32 -> 64 -> 128 -> 256 -> 512
-- 0 -> 1 -> 2 -> 3 --> 4 --> 5 ---> 6 ---> 7 ---> 8 
                case L_cntr_user_max is 
                when 4=> 
                    M_cntr_user_max <= 31 ;
                    M_cntr_user_Hmax <= 15;
                    W_index_multiplier <= 2;
                when 5=> 
                    M_cntr_user_max <= 63 ;
                    M_cntr_user_Hmax <= 31;
                    W_index_multiplier <= 1;
                when 6=> 
                    M_cntr_user_max <= 127 ;
                    M_cntr_user_Hmax <= 63;
                    W_index_multiplier <= 0;
                when others => 
                    error_W_index_multiplier <= '1' ;
                end case ;    
                St_core_N <= St_Idle ;
                
    else 
                    S_rst <=  (others=>'0');
    
        case (St_core_N) is 
            when  St_Idle   =>
                   
                    
                ena_pre <= ena;
                if ena_pre = '0' and ena = '1' then
                            complete <= '0' ;
                    
                        for j in 0 to number_of_pin_div2_minus1 loop -- N = 32 için N/2 tanesi 16 tane FFTcore2 lazým 
                        
                            if j <= M_cntr_user_Hmax  then 
                                M_N.input(j) <= input_Nover2(j)  ;    -- olasý bir user ve sistemin farklý sayýda sampling sayýsý tanýmlamasý durumunda user en  fazla sistein izin verdiði miktarda kullanýr , user ve sistem þu an 32 
                                S_rst(j) <= '1' ; 
                            end if ;   
                             
                        end loop ;
                       
                        
                    St_core_N <= St_core2 ;
                    L_cntr <= 1 ;
                      
                end if ;
            
            
            
            
            
            
            
            
            when  St_core2  => -- L = 0
                
                
                if S_done(0) = '1' then -- aktif tüm modüller done olursa -- hepsi ayný anda done olsa iyi olur 
                
                    if  L_cntr <= L_cntr_user_max then 
                        L_cntr <= L_cntr + 1  ;-- 1 clk sonradan geliyor ve bu modüle ilk girdiðinde modüle 4lü giriþi  çalýþtýracak çünkü L= 1 , 
               
                    
                        for j in 0 to number_of_pin_div2_minus1 loop -- N = 32 için N/2 tanesi 16 tane FFTcore2 lazým 
                        

                        for i in 0 to 1 loop -- ilki w sýz olan ikincisi W ile çarpýlacak olan 
                                
 if j <= M_cntr_user_Hmax and L_cntr_user_max <= Lmax_int then 
 
 S_rst(j) <= '1' ;
                            V_j_for :=  std_logic_vector(to_unsigned(   (i*(M_cntr_user_Hmax+1) +j),10 )); -- L_cntr_user_max+1  )) ; -- (L_cntr_user_max downto 0) ;-- L is 0 
                            
                            if L_cntr = 0 then
                                V_W_m := (Others =>('0') ) ;
                                 
                            else 
--                                V_W_m := std_logic_vector(to_unsigned(j,Lmax_int+1)) ;--  sra Lmax_int ;
                                V_W_m := shift_left(to_unsigned(j, 8), L_cntr_user_max - L_cntr+ W_index_multiplier); -- Lmax_int -L_cntr
                            end if ;
                            
                            
                            if L_cntr = 0 then
                                V_ix_m :=  V_j_for(9 downto 1) ;                                 
                            elsif L_cntr = 1 then
                                V_ix_m :=  V_j_for(9 downto  2)  & V_j_for(  0) ;                         
                            elsif L_cntr = 2 then
                                V_ix_m :=  V_j_for(9 downto  3)  & V_j_for( 1 downto  0) ;                         
                            elsif L_cntr = 3 then
                                V_ix_m :=  V_j_for(9 downto  4)  & V_j_for( 2 downto 0) ;                         
                            elsif L_cntr = 4 then
                                V_ix_m :=  V_j_for(9 downto  5)  & V_j_for( 3 downto 0) ;                
                            elsif L_cntr = 5 then
                                V_ix_m :=  V_j_for(9 downto  6)  & V_j_for( 4 downto  0) ;                         
                            elsif L_cntr = 6 then
                                V_ix_m :=  V_j_for(9 downto  7)  & V_j_for( 5 downto 0) ;                         
                            elsif L_cntr = 7 then
                                V_ix_m :=  V_j_for(9 downto  8)  & V_j_for( 6 downto 0) ; 
                                                     
                            elsif L_cntr = 8 then
                                V_ix_m :=  V_j_for(9)  & V_j_for( 7 downto 0) ; 
                            else
                                V_ix_m :=  V_j_for(8 downto  0) ;
                                 
                            end if ;
                            
                            
                            
                            
                            V_sg_m := '0' & V_j_for(L_cntr) ;
                            
                            
                            
                            
                            W(j) <= C_Wrom( to_integer( V_W_m(L_cntr_user_max downto 0) )  );
                            
                            M_N.input(j)(i) <= M_N.output( to_integer(unsigned(V_ix_m)) )( to_integer(unsigned(V_sg_m)) )   ;
                        
 end if ;                       
                    
                        end loop ;
                        end loop ;
                    
                    
                    else
                        
                            
                            output_Nover2 <= M_N.output   ; -- verilerin çýkýþý da sýrasý ile olacak küçük olanlar 0 . index , te büyük olanlar 1. indexte 
                        
                        
                    
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
