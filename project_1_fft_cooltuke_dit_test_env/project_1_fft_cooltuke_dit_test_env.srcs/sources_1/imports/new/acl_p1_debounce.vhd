----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.04.2026 03:40:00
-- Design Name: 
-- Module Name: acl_p1_debounce - Behavioral
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

entity acl_p1_debounce is
    Generic (
        refresh_rate : integer := 1_000_000;  -- 10 ms
        X_clk : integer := 100_000_000
    );
    Port ( 
        clk : in std_logic := '0';
        ena : in std_logic := '0';
        
        actv_btn : in std_logic := '0'; --for better energy consumption only necessery typeswill be activated 
        actv_sw  : in std_logic := '0';
        
        btn : in std_logic_vector(4 downto 0)   := "00000" ;
          btn_deb : out std_logic_vector(4 downto 0) := "00001"  ;
        sw : in std_logic_vector( 15 downto 0 )   := X"0000" ;
          sw_deb : out std_logic_vector( 15 downto 0)  := X"0000" ;
        
        rst : in std_logic := '1'
    );
    
end acl_p1_debounce;

architecture Behavioral of acl_p1_debounce is

constant Si_refresh_max : integer range 0 to 25_000_000 := X_clk/refresh_rate ;
signal Si_refresh_counter : integer range 0 to 25_000_000 := 0 ;
--signal Si_btn_deb : std_logic_vector(4 downto 0)  := "00000";
--signal Si_sw_deb : std_logic_vector( 15 downto 0)  := X"0000" ;

begin

--btn_deb <= Si_btn_deb ;
--sw_deb  <= Si_sw_deb  ;

process ( clk ) begin 

    if rising_edge(clk) then
        if ( rst = '0' ) then 
            Si_refresh_counter <= 0 ;
            
        elsif (ena = '1' ) then
        
            if ( Si_refresh_counter < Si_refresh_max ) then
                Si_refresh_counter <= Si_refresh_counter + 1 ;
            elsif ( Si_refresh_counter = Si_refresh_max ) then
                Si_refresh_counter <= 1 ;
                
                if (actv_btn='1') then
--                    Si_
                    btn_deb <= btn ;
                end if ;
                if (actv_sw='1') then
--                    Si_
                    sw_deb <= sw ;
                end if ;
                
            end if ;
        end if ;
    end if ;

end process ;



end Behavioral;
