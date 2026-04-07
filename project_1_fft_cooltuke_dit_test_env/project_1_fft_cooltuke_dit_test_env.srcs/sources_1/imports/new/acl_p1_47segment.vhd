----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.04.2026 03:40:00
-- Design Name: 
-- Module Name: acl_p1_47segment - Behavioral
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

entity acl_p1_47segment is
    Port ( 
    clk : in std_logic := '0' ;
    ena : in std_logic := '0' ;
    hex4 : in std_logic_vector(15 downto 0) := X"0000";
        SEGMENT4_top :  out std_logic_vector(3 downto 0) := X"1" ;
        SEGMENT7_top  : out std_logic_vector(7 downto 0) := X"00" 
    );
end acl_p1_47segment;

architecture Behavioral of acl_p1_47segment is

type rom_typ7 is array(0 to 17) of std_logic_vector(7 downto 0)  ;-- msb is dot
constant ROM7seg : rom_typ7 := (
    "11111100", -- 0: Segment A, B, C, D, E, F open (dot close )
    "01100000", -- 1: Segment B, C open
    "11011010", -- 2: Segment A, B, G, E, D open
    "11110010", -- 3: Segment A, B, G, C, D open
    "01100110", -- 4: Segment F, G, B, C open
    "10110110", -- 5: Segment A, F, G, C, D open
    "10111110", -- 6: Segment A, F, G, E, C, D open
    "11100000", -- 7: Segment A, B, C open
    "11111110", -- 8: All segments open (dot close )
    "11110110", -- 9: Segment A, B, C, D, F, G open
    "00111010", -- A: Segment A, B, C, E, F, G open
    "00111110", -- B: Segment F, E, G, C, D open
    "00011010", -- C: Segment A, F, E, D open
    "01111010", -- D: Segment B, C, D, E, G open
    "10011110", -- E: Segment A, F, G, E, D open
    "10001110", -- F: Segment A, F, G, E open
    "00000000", -- 16: Blank (All segments close )
    "01101101"  -- 17: All segments and dot open
);
signal S_refresh_counter : unsigned (15 downto 0) := x"0000";
signal S_segment_counter : unsigned (1 downto 0) := "00";

begin


process ( clk ) begin 
    if (rising_edge(clk) ) then 
        if ena = '1' then 
            S_refresh_counter <= S_refresh_counter + x"1" ;  
            
            if(S_refresh_counter = X"f000" ) then 
                S_segment_counter <= S_segment_counter + "01" ; 
                case ( S_segment_counter ) is 
                when "00" =>
                    SEGMENT4_top <= not X"1";
                    SEGMENT7_top <= not ROM7seg( to_integer(unsigned( hex4(3 downto 0) )) );
                when "01" =>
                    SEGMENT4_top <= not X"2"; 
                    SEGMENT7_top <= not ROM7seg( to_integer(unsigned( hex4(7 downto 4) )) );
                when "10" =>
                    SEGMENT4_top <= not X"4"; 
                    SEGMENT7_top <= not ROM7seg( to_integer(unsigned( hex4(11 downto 8) )) );
                when "11" =>
                    SEGMENT4_top <= not X"8"; 
                    SEGMENT7_top <= not ROM7seg( to_integer(unsigned( hex4(15 downto 12) )) );
                when others =>
                    SEGMENT4_top <= X"0";
                    SEGMENT7_top <= not ROM7seg( 17 );
                end case ;
            end if;
        
        else 
        
            SEGMENT4_top <= X"0";
            SEGMENT7_top <= not ROM7seg( 16 );    
        end if ;
    end if ;
end process ;




end Behavioral;
