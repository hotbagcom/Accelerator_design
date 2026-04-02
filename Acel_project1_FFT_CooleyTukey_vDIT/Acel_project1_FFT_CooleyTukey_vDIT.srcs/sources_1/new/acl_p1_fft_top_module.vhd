----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.03.2026 16:47:20
-- Design Name: 
-- Module Name: acl_p1_fft_top_module - Behavioral
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

entity acl_p1_fft_top_module is
    Port ( 
        CLK_top : in std_logic := '0';
    
        SEGMENT4_top :  out std_logic_vector(3 downto 0) := X"f" ;
        SEGMENT7_top  : out std_logic_vector(7 downto 0) := X"00" ;
         
         
        
    BTN_top : in std_logic_vector(4 downto 0)   := "00000" ;
    SW_top : in std_logic_vector( 15 downto 0 )   := X"0000" ;
        LED_top : out std_logic_vector( 15 downto 0 )   := X"0000" 
    
    );
end acl_p1_fft_top_module;

architecture Behavioral of acl_p1_fft_top_module is

-- debounce
signal S_btn_deb_pre : std_logic_vector(4 downto 0)   := "00000" ;
signal S_btn_deb : std_logic_vector(4 downto 0)   := "00000" ;
signal S_sw_deb : std_logic_vector( 15 downto 0 ) := X"0000" ;

constant C_500msecond : integer := 50_000_000 ;

Signal S_mid_btn_2 : integer range 0 to 4*C_500msecond := 0 ;
Signal S_lft_btn_2 : integer range 0 to 4*C_500msecond := 0 ;
Signal S_rht_btn_2 : integer range 0 to 4*C_500msecond := 0 ;
Signal S_dwn_btn_2 : integer range 0 to 4*C_500msecond := 0 ;



-- 47segment
signal S_hex4 : std_logic_vector( 15 downto 0 ) := X"0000" ;



---------DIT_FFT_Wrapper
Signal S_L : integer range 1 to 10 := 5 ; 
Signal S_data_time   : signed(11 downto 0) := (others=>'0') ; 
Signal S_addr_time   : std_logic_vector(9 downto 0) := (others=>'0') ; 
Signal S_we_time : std_logic := '0';

type FFT_packet_buffer is array ( integer range 0 to 31 ) of pin_width ; 
Signal S_Time_buffer : FFT_packet_buffer  :=(



) ;


Signal S_Freq_buffer : FFT_packet_buffer  ;




begin

--set sempling freq 
-- set window width 
-- optional -- display certain freq on LEd -- you can implement DTMF aplication -- certain treshold cause to longer bright moment 


-- get adc 
-- manage packets 
-- put send incremantal adress and data to wrapper fft 
-- get freq value on write enable  signal when done high put itinside a buffer 
-- display freq value and time value if necesery 


acl_p1_cooltuke_DITcore_wrapper_mdl :entity work.acl_p1_cooltuke_DITcore_wrapper 
    Port Map ( -- target N is 32 in the future will be 512
    clk => CLK_top ,
    
    ena         => S_btn_deb ,
    data_time   => S_data_time ,
    addr_time   => 
    we_time     => S_we_time ,
    
    L => S_L ,
    
        data_freq   : out std_logic_vector(11 downto 0) := (others=>'0') ;   
    addr_freq   : in std_logic_vector(9 downto 0) := (others=>'0') ;   
    re_freq      : in std_logic := '0' ;
        done        : out std_logic := '0' ;
    
    
    
    
        ready        : out std_logic := '0' ; -- when change on L value set 0 and when loading data
    rst : std_logic := '1' 
    );



                                       
                                                                         
process (CLK_top) begin                                             
if rising_edge(CLK_top) then          

    if S_btn_deb_pre(0) ='0' then    
        if S_mid_btn_2 = C_500msecond*4-5 then 
            S_cam_pdwn <= not S_cam_pdwn ;        
               
        end if ;
        
        if S_mid_btn_2 < C_500msecond*4-3 then
        S_mid_btn_2 <= S_mid_btn_2 +1 ;                          
        end if;                 
                               
    else                                               
        if S_mid_btn_2 > C_500msecond*4-4 then
            S_mid_btn_2 <= 0;   
        elsif S_mid_btn_2 > 5 then  
            S_cntr_miniram_system <= 0 ;    
            if S_cam_Y = 200 and S_cam_X = 119 then
            S_mid_btn_2 <= 3;
            end if ;
        elsif S_mid_btn_2 > 1 then      
        
            if  S_cam_valid_in_pre = '0' and S_cam_valid_in = '1' then
                if S_cntr_miniram_system < S_cntr_miniram_max then
                    S_cntr_miniram_system <= S_cntr_miniram_system +1 ;
                else 
                    S_mid_btn_2 <= 0; 
                end if ;
            S_miniram(S_cntr_miniram_system) <= S_cam_color_rgb ; --(15 downto 0) ;
        
                                               
            end if ;            
        
                                   
        
        end if ; 
    end if ;

    
    
    
    
    end if ;


end process ;





end Behavioral;
