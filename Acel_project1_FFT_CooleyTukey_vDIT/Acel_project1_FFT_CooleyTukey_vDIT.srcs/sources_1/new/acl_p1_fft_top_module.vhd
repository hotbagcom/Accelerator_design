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
Signal S_ena_DIT_FFT : std_logic := '0';
Signal S_rdy_d_DIT_FFT : std_logic := '0';
Signal S_rst_DIT_FFT : std_logic := '0';

Signal S_L : integer range 1 to 10 := 5 ; 
Signal S_data_time   : signed(11 downto 0) := (others=>'0' ) ;
Signal S_addr_time   : std_logic_vector(9 downto 0) := (others=>'0') ;
shared Variable Vs_addr_time   : unsigned(9 downto 0) := (others=>'0') ; 
Signal S_we_time : std_logic := '0';
Signal S_rdy_time : std_logic := '0';

Signal S_data_freq  : signed(11 downto 0) := (others=>'0') ; 
Signal S_addr_freq  : std_logic_vector(9 downto 0) := (others=>'0') ;
shared Variable Vs_addr_freq  : unsigned(9 downto 0) := (others=>'0') ; 
Signal S_re_freq : std_logic := '0';
Signal S_rdy_freq : std_logic := '0';

type FFT_packet_buffer is array ( integer range 0 to 31 ) of pin_width ; 
--Signal S_Time_buffer : FFT_packet_buffer  ;
signal S_Time_buffer : FFT_packet_buffer := (
     0 => (Pin => "011111111111"),
     1 => (Pin => "011110101001"),
     2 => (Pin => "011010110001"),
     3 => (Pin => "010100110110"),
     4 => (Pin => "001101100101"),
     5 => (Pin => "000101110101"),
     6 => (Pin => "111110011111"),
     7 => (Pin => "111000010111"),
     8 => (Pin => "110100000100"),
     9 => (Pin => "110001111101"),
    10 => (Pin => "110010000101"),
    11 => (Pin => "110100001101"),
    12 => (Pin => "110111110100"),
    13 => (Pin => "111100010000"),
    14 => (Pin => "000000110010"),
    15 => (Pin => "000100101011"),
    16 => (Pin => "000111010111"),
    17 => (Pin => "001000011111"),
    18 => (Pin => "000111111001"),
    19 => (Pin => "000101101110"),
    20 => (Pin => "000010010100"),
    21 => (Pin => "111110001010"),
    22 => (Pin => "111001110101"),
    23 => (Pin => "110101111000"),
    24 => (Pin => "110010101111"),
    25 => (Pin => "110000101110"),
    26 => (Pin => "101111111010"),
    27 => (Pin => "110000001110"),
    28 => (Pin => "110001011001"),
    29 => (Pin => "110011000100"),
    30 => (Pin => "110100110101"),
    31 => (Pin => "110110010110")
);





type FFT_packet_buffer_unsigned is array ( integer range 0 to 31 ) of pin_width_unsigned ; 
Signal S_Freq_buffer : FFT_packet_buffer_unsigned  ;


-- function unsigned_to_signed (
--                        msb_index : integer range 1 to 15 := 11 ;
--                        unsigned_value :  std_logic_vector(11 downto 0) := (others=>'0') 
--                         )   return signed is
--        variable v_temp_signed : std_logic_vector(11 downto 0) := (others=>'0');
--    begin
--        v_temp_signed := unsigned_value ;
--            v_temp_signed(msb_index) := not v_temp_signed(msb_index);
--        return  resize(signed(v_temp_signed),msb_index+1);
--    end function;
 function s_2_uns (
                        msb_index : integer range 1 to 15 := 11 ;
                        signed_value :  signed(11 downto 0) := (others=>'0') 
                         )   return unsigned is
        variable v_temp : std_logic_vector(11 downto 0) := (others=>'0');
    begin
            v_temp := std_logic_vector( signed_value ) ;
            v_temp(msb_index) := not v_temp(msb_index);
        return  unsigned(v_temp);
    end function;




 

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
    
    ena         => S_ena_DIT_FFT ,
    data_time   => S_data_time ,
    addr_time   => S_addr_time , --std_logic_vector(unsigned(S_addr_time ) -x"1" ),  -- S_addr_time , -- bi bu hali ile dene --
    we_time     => S_we_time ,
        rdy_time => S_rdy_time , 
        
    L => S_L ,-- Careless Wisper
    
        data_freq   => S_data_freq , -- out  signed(11 downto 0) := (others=>'0') ;  
    addr_freq       => S_addr_freq , -- in std_logic_vector(9 downto 0) := (others=>'0') ;   
    re_freq         => S_re_freq  ,
        rdy_freq    => S_rdy_freq , 
    
    
--        done        : out std_logic := '0' ;
    
        ready_data      => S_rdy_d_DIT_FFT , -- when change on L value set 0 and when loading data
    rst => S_rst_DIT_FFT
    );





--- dsp bloklarýn yetersi gelmesi durumunda fft corlarý stünlar halinde paylaþýmlý çaýþtýr  / 2 ye ya da 7 e bölebilirsin (gevelemeye baþladým :) ) 
                                       -- kare kök alma durumunu nasýl yaparsýn bilemiyorum artýk  ,,
                                       --  Çarpýmý topladýktan sonra resize yapýp msb kýsmýndan alýp iþleme sokabilirsin çýkýþ ta ona göre kaymýþ olur 
                                                                         
process (CLK_top)  
begin      
                                       
if rising_edge(CLK_top) then          

    
    if S_btn_deb_pre(0) ='0' and S_btn_deb(0) ='1' then    
            S_ena_DIT_FFT <= not S_ena_DIT_FFT ;      
    end if ;
    
    if S_btn_deb_pre(1) ='0' and S_btn_deb(1) ='1' then    
            S_rst_DIT_FFT <= not S_rst_DIT_FFT ;   
    end if ;
    
    if S_btn_deb_pre(2) ='0' and S_btn_deb(2) ='1' then      
            Vs_addr_time:= (others=> '0') ;   
    elsif Vs_addr_time < "0000100000" and S_rdy_time ='1' then  -- L =5 -> N =32 için 
        S_we_time <= '1' ;
        S_data_time <=  S_Time_buffer(  to_integer((Vs_addr_time)) ).Pin;
        Vs_addr_time := ( (Vs_addr_time)  +  (x"1") )  ;
        S_addr_time <= std_logic_vector(Vs_addr_time) ;
    else 
        S_we_time <= '0' ;
    end if ;
        
    
    
    
    if S_btn_deb_pre(3) ='0' and S_btn_deb(3) ='1' then      
            Vs_addr_freq := (others=> '0') ;   
    elsif Vs_addr_freq <= "0000100010" and S_rdy_freq ='1' then  -- L =5 -> N =32 için  -- zaman kaymasýndan dolayý 
        S_re_freq <= '1' ;
            if Vs_addr_freq > "0000000000" then
                
                S_Freq_buffer(  to_integer(Vs_addr_freq-X"1") ).Pin <= s_2_uns(11 ,S_data_freq ); -- data kullanýlabilir formuna 
            end if ;
        Vs_addr_freq := ( (Vs_addr_freq)  +  (x"1") )  ;
        S_addr_freq <= std_logic_vector(Vs_addr_freq) ;
        
    else 
        S_re_freq <= '0' ;
    end if ;
    
    
    
    
    -- adc write to unsigned std_logic_vector --->   S_Time_buffer <= unsigned_to_signed(11 , ADC_VALUE_ÝN )
    
end if ;
end process ;





end Behavioral;
