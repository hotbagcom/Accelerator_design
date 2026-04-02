----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.03.2026 16:47:20
-- Design Name: 
-- Module Name: acl_p1_cooltuke_revrsordr - Behavioral
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


 function acl_p1_cooltuke_revrsordr (
                        L : in integer range 1 to 10 := 5 ;
                        index_in :in  std_logic_vector(9 downto 0) := (others=>'0') ; 
                         ) return std_logic_vector(9 downto 0) is
        variable v_temp : std_logic_vector(9 downto 0) := (others=>'0');
    begin
        
            for i in 0 to C_Max_L-1 loop
                if i < L then
                    v_temp((L-1) - i) := index_in(i);
                end if;
            end loop;
            
        return v_temp;
    end function;


entity acl_p1_cooltuke_revrsordr is
    Port ( 
        L : in integer range 1 to 10 := 5 ; 
        index_in  :     in  std_logic_vector(9 downto 0) := (others=>'0') ; 
            index_out : out std_logic_vector(9 downto 0) := (others=>'0') ; 
        
        rst : in std_logic := '1' 
    );
end acl_p1_cooltuke_revrsordr;

architecture Behavioral of acl_p1_cooltuke_revrsordr is

Constant C_Max_L : integer := 10 ;

begin
 
process(index_in, L, rst)
        variable v_temp : std_logic_vector(9 downto 0);
    begin
        if rst = '0' then
            index_out <= (others => '0');
        else
            v_temp := (others => '0');
            
            for i in 0 to C_Max_L-1 loop
                if i < L then
                    v_temp((L-1) - i) := index_in(i);
                end if;
            end loop;
            
            index_out <= v_temp;
            
        end if;
    end process;

end Behavioral;
