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

Signal S_upp_btn_2 : integer range 0 to 4*C_500msecond := 0 ;
Signal S_mid_btn_2 : integer range 0 to 4*C_500msecond := 0 ;
Signal S_lft_btn_2 : integer range 0 to 4*C_500msecond := 0 ;
Signal S_dwn_btn_2 : integer range 0 to 4*C_500msecond := 0 ;
Signal S_rht_btn_2 : integer range 0 to 4*C_500msecond := 0 ;

Signal S_fre_buffer_indx_cntr : integer range 0 to 31  := 0 ;
Signal S_fre_buffer_indx_value : pin_width_unsigned    := (Pin => (others=>'0' ) ) ;


-- 47segment
signal S_hex4 : std_logic_vector( 15 downto 0 ) := X"0000" ;



---------DIT_FFT_Wrapper
Signal S_ena_DIT_FFT : std_logic := '0';
Signal S_rdy_d_DIT_FFT : std_logic := '0';
Signal S_rst_DIT_FFT : std_logic := '0';

Signal S_L : integer range 1 to 10 := 4 ; 
Signal S_data_time   : pin_width := (Pin=>(others=>'0' )) ;
Signal S_addr_time   : std_logic_vector(8 downto 0) := (others=>'0') ;
shared Variable Vs_addr_time   : unsigned(8 downto 0) := (others=>'0') ; 
Signal S_we_time : std_logic := '0';
Signal S_rdy_time : std_logic := '0';

Signal S_data_freq  : pin_reel_img := (reel=> (Pin=>(others=>'0' )) , imag=>(Pin=>(others=>'0' ))) ; 
Signal S_addr_freq  : std_logic_vector(8 downto 0) := (others=>'0') ;
shared Variable Vs_addr_freq  : unsigned(8 downto 0) := (others=>'0') ; 
Signal S_re_freq : std_logic := '0';
Signal S_rdy_freq : std_logic := '0';

Signal S_re_run_fft : std_logic := '0' ;
Signal S_run_fft : std_logic := '0' ;
       
       

type FFT_packet_buffer is array ( integer range 0 to 31 ) of pin_width ; 
--Signal S_Time_buffer : FFT_packet_buffer  ;
signal S_Time_buffer : FFT_packet_buffer := (
     0 => (Pin => "0111111111"),   --11
     1 => (Pin => "0111101010"),   --01
     2 => (Pin => "0110101100"),   --01
     3 => (Pin => "0101001101"),   --10
     4 => (Pin => "0011011001"),   --01
     5 => (Pin => "0001011101"),   --01
     6 => (Pin => "1111100111"),   --11
     7 => (Pin => "1110000101"),   --11
     8 => (Pin => "1101000001"),   --00
     9 => (Pin => "1100011111"),   --01
    10 => (Pin => "1100100001"),   --01
    11 => (Pin => "1101000011"),   --01
    12 => (Pin => "1101111101"),   --00
    13 => (Pin => "1111000100"),   --00
    14 => (Pin => "0000001100"),   --10
    15 => (Pin => "0001001010"),   --11
    16 => (Pin => "0001110101"),   --11
    17 => (Pin => "0010000111"),   --11
    18 => (Pin => "0001111110"),   --01
    19 => (Pin => "0001011011"),   --10
    20 => (Pin => "0000100101"),   --00
    21 => (Pin => "1111100010"),   --10
    22 => (Pin => "1110011101"),   --01
    23 => (Pin => "1101011110"),   --00
    24 => (Pin => "1100101011"),   --11
    25 => (Pin => "1100001011"),   --10
    26 => (Pin => "1011111110"),   --10
    27 => (Pin => "1100000011"),   --10
    28 => (Pin => "1100010110"),   --01
    29 => (Pin => "1100110001"),   --00
    30 => (Pin => "1101001101"),   --01
    31 => (Pin => "1101100101")    --10
);





type FFT_packet_buffer_unsigned is array ( integer range 0 to 31 ) of pin_width_unsigned ; 
Signal S_Freq_buffer_reel : FFT_packet_buffer_unsigned  ;
Signal S_Freq_buffer_imag : FFT_packet_buffer_unsigned  ;
signal S_freq_buffer_magnit : FFT_packet_buffer_unsigned ;

 function s_2_uns (     msb_index : integer range 1 to 15 ;
                        signed_value :  signed(C_p_bit_len-1 downto 0) := (others=>'0') 
                         )   return unsigned is
        variable v_temp : std_logic_vector(C_p_bit_len-1 downto 0) := (others=>'0');
    begin
            v_temp := std_logic_vector( signed_value ) ;
            v_temp(msb_index) := not v_temp(msb_index);
        return  unsigned(v_temp);
    end function;


type spr_data_buffer is array (integer range 0 to 7 )of std_logic_vector(C_p_bit_len*2-1 downto 0)  ;


Signal S_rst_sqr             : std_logic := '1' ; 
Signal S_datain_sqr          : spr_data_buffer :=    (others=>(others=>'0')) ;
Signal S_datain_sqr_valid    : std_logic := '0' ;
Signal S_dataout_sqr         : spr_data_buffer :=    (others=>(others=>'0')) ; 
Signal S_dataout_sqr_valid   : std_logic_vector(7 downto 0) := (others=>'0') ;



Signal S_sqr_cntr : integer range 0 to 63  := 31;
Signal S_rdy_freq_pre : std_logic := '0' ;


begin


p3_08_debounce_mdl : entity work.acl_p1_debounce    
    Generic Map(
        refresh_rate => 1_000_000,  -- 10 ms
        X_clk => 100_000_000
    )
    Port Map( 
        clk => CLK_top ,
        ena => '1' ,
        
        actv_btn => '1' , --for better energy consumption only necessery typeswill be activated 
        actv_sw  => '1' ,
        
        btn => BTN_top ,
          btn_deb  => S_btn_deb ,
        sw => SW_top ,
          sw_deb => S_sw_deb ,
        
        rst => '1'
    );


p3_08_47segment_mdl : entity work.acl_p1_47segment 
    Port Map ( 
    clk => CLK_top ,
    ena => '1'  ,
    hex4 => S_hex4 ,
        SEGMENT4_top => SEGMENT4_top ,
        SEGMENT7_top => SEGMENT7_top 
    );
                                     
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
        
    userL_int => S_L ,-- Careless Wisper
    
        data_freq   => S_data_freq , -- out  signed(11 downto 0) := (others=>'0') ;  
    addr_freq       => S_addr_freq , -- in std_logic_vector(9 downto 0) := (others=>'0') ;   
    re_freq         => S_re_freq  ,
        rdy_freq    => S_rdy_freq , 
    
--byte3 => S_sw_deb(15 downto 12) ,
--byte2 => S_sw_deb(11 downto 8) ,
--byte1 => S_sw_deb(7 downto 4) ,
--byte0 => S_sw_deb(3 downto 0) ,

re_run_fft => S_re_run_fft ,
run_fft => S_run_fft ,
        ready_data      => S_rdy_d_DIT_FFT , -- when change on L value set 0 and when loading data
    rst => S_rst_DIT_FFT
    );





--- dsp bloklar?n yetersi gelmesi durumunda fft corlar? st?nlar halinde payla??ml? ?a??t?r  / 2 ye ya da 7 e b?lebilirsin (gevelemeye ba?lad?m :) ) 
                                       -- kare k?k alma durumunu nas?l yapars?n bilemiyorum art?k  ,,
                                       --  ?arp?m? toplad?ktan sonra resize yap?p msb k?sm?ndan al?p i?leme sokabilirsin ??k?? ta ona g?re kaym?? olur 
                       
generate_sqr_mdl : for j in 0 to 7 generate 
sqrt_v1_mdl : entity work.sqrt_v1 
    generic Map(
        DATA_WIDTH => C_p_bit_len*2
    )
    Port  Map(
        in_clk => CLK_top ,
        in_rst => S_rst_sqr ,
        in_data => S_datain_sqr(j) ,
        in_data_vld => S_datain_sqr_valid ,
        out_data => S_dataout_sqr(j) ,          
        out_data_vld => S_dataout_sqr_valid(j) 
   
    );   
    end generate ;                     
    
    
    
    
    
    
    
    
    
    
    
    
    
                                                                         
process (CLK_top)  
begin      
                                       
if rising_edge(CLK_top) then          
S_btn_deb_PRE <= S_btn_deb ;
S_rdy_freq_pre <= S_rdy_freq ;
    if S_btn_deb(0) ='1' then
        if S_upp_btn_2 <= C_500msecond*4-5  then
        S_upp_btn_2 <= S_upp_btn_2 +1 ;
            if   S_upp_btn_2 = C_500msecond*4-5 then
                S_rst_DIT_FFT <= not S_rst_DIT_FFT ; 
            end if ;  
        end if ;
    
    else    
        if S_upp_btn_2 > 5 then 
            if  S_upp_btn_2 <= C_500msecond*4-5 then
            S_ena_DIT_FFT <= not S_ena_DIT_FFT ;    
            end if ;
                S_upp_btn_2 <= 0;
        end if ;
    end if ;
    
    
    
    
                                          
    if S_btn_deb_pre(2)='1'  then
     S_lft_btn_2 <= S_lft_btn_2 +1 ;                
        if S_lft_btn_2 = C_500msecond*4-5 then 
            
            if S_fre_buffer_indx_cntr < 31-3 then  
            S_fre_buffer_indx_cntr <= S_fre_buffer_indx_cntr + 4 ;
            end if;
            S_lft_btn_2 <= C_500msecond*2;                              
        end if;      
     else 
        if S_lft_btn_2 > 5 and S_lft_btn_2 < C_500msecond*2 then  
            if S_fre_buffer_indx_cntr < 31 then  
                S_fre_buffer_indx_cntr <= S_fre_buffer_indx_cntr + 1 ;
            end if;
        end if ;
            S_lft_btn_2 <= 0;  
        
    end if ;                               
    if S_btn_deb_pre(4)='1'  then
     S_rht_btn_2 <= S_rht_btn_2 +1 ;                
        if S_rht_btn_2 = C_500msecond*4-5 then 
            
            if S_fre_buffer_indx_cntr >= 4 then  
            S_fre_buffer_indx_cntr <= S_fre_buffer_indx_cntr - 4 ;
            end if;
            S_rht_btn_2 <= C_500msecond*2;                              
        end if;      
     else 
        if S_rht_btn_2 > 5 and S_rht_btn_2 < C_500msecond*2 then  
            if S_fre_buffer_indx_cntr >= 1 then  
            S_fre_buffer_indx_cntr <= S_fre_buffer_indx_cntr - 1 ;
            end if;
        end if ;
            S_rht_btn_2 <= 0;  
        
    end if ;
   
    
   -- bir de?er in art?m ve azalt?m?n? yaparak hex ve bit  de?erlerini de?i?tiir 
 ---   S_hex4 <= anf 4 hex 
  --  led <= any 16 bit 
    S_fre_buffer_indx_value <= S_Freq_buffer_magnit(S_fre_buffer_indx_cntr) ;
    
    S_hex4(9 downto 0) <= std_logic_vector( S_fre_buffer_indx_value.Pin ) ;
    
    S_hex4(15 downto 12)  <=  std_logic_vector(to_unsigned(S_fre_buffer_indx_cntr,4))  ;
    
    
    
    
    
    if S_btn_deb_pre(1) ='0' and S_btn_deb(1) ='1' then    
    end if ;
    
    if S_btn_deb_pre(2) ='0' and S_btn_deb(2) ='1' then      
            Vs_addr_time:= (others=> '0') ;   
            S_re_run_fft <= '1' ;
    elsif S_rdy_time ='1' then  -- L =5 -> N =32 i?in 
        if Vs_addr_time < shift_left(x"01",S_L) then
            S_re_run_fft <= '0' ;
            S_we_time <= '1' ;
            S_data_time.pin <=  S_Time_buffer(  to_integer((Vs_addr_time)) ).Pin;
            Vs_addr_time := ( (Vs_addr_time)  +  (x"1") )  ;
            S_addr_time <= std_logic_vector(Vs_addr_time) ;
            if Vs_addr_time = (shift_left(x"01",S_L)-x"1") then -- son veriyle birlikte run komutunu gönderiyorum
                S_run_fft <= '1' ;
            end if ;
        end if ;
    else 
        S_run_fft <= '0' ;
        S_we_time <= '0' ;
    end if ;
        
    
    
    
    if S_btn_deb_pre(3) ='0' and S_btn_deb(3) ='1' then      
            Vs_addr_freq := (others=> '0') ;   
            
            
            -- resize(shift_left(x"01",S_L)+"10", 9) 
    elsif Vs_addr_freq <="000010010" and S_rdy_freq ='1' then  -- L =5 -> N =32 i?in  -- zaman kaymas?ndan dolay? 
        S_re_freq <= '1' ;
            if Vs_addr_freq > "000000000" then
                
                S_Freq_buffer_reel(  to_integer(Vs_addr_freq-X"1") ).Pin <= s_2_uns(C_p_bit_len-1 ,S_data_freq.reel.pin ); -- data kullan?labilir formuna 
                S_Freq_buffer_imag(  to_integer(Vs_addr_freq-X"1") ).Pin <= s_2_uns(C_p_bit_len-1 ,S_data_freq.imag.pin ); -- data kullan?labilir formuna 
                
            end if ;
        Vs_addr_freq := ( (Vs_addr_freq)  +  (x"1") )  ;
        S_addr_freq <= std_logic_vector(Vs_addr_freq) ;
        
    else 
        S_re_freq <= '0' ;
    end if ;
    
    
    
    if S_dataout_sqr_valid = x"ff" then 
        S_rst_sqr <= '0' ;
    elsif S_dataout_sqr_valid = x"00" then 
        S_rst_sqr <= '1' ;
    end if ;
    
    
    if S_sqr_cntr = 0 or  (S_sqr_cntr <= 4 and S_dataout_sqr_valid = x"ff" ) then
    
        for i in 0 to 7 loop 
            if S_sqr_cntr <4 then
                S_datain_sqr(i) <=  std_logic_vector(   ( S_Freq_buffer_reel(i + 8*S_sqr_cntr).pin)* (S_Freq_buffer_reel(i + 8*S_sqr_cntr).pin) + ( S_Freq_buffer_imag(i + 8*S_sqr_cntr).pin)* (S_Freq_buffer_imag(i + 8*S_sqr_cntr).pin)  );
                S_datain_sqr_valid <= '1' ;
             else 
                S_datain_sqr_valid <= '0' ;
             end if ;
                
            if S_sqr_cntr >0 then
                S_Freq_buffer_magnit(i + 8*(S_sqr_cntr-1)).pin <= unsigned(S_dataout_sqr(i)(C_p_bit_len*2-1 downto C_p_bit_len) )  ;  
            end if ;
        end loop ;
     
     
        if S_sqr_cntr = 0 then
            S_sqr_cntr <= 1 ;
        else 
            S_sqr_cntr <= S_sqr_cntr + 1 ;
            
        end if ;
        
    
    elsif S_rdy_freq = '0' and S_rdy_freq_pre = '1' then
    S_sqr_cntr <= 0 ;
    
    end if ;
    
    
    
    
    
    
    
    
    -- adc write to unsigned std_logic_vector --->   S_Time_buffer <= unsigned_to_signed(11 , ADC_VALUE_?N )
    
end if ;
end process ;





end Behavioral;
