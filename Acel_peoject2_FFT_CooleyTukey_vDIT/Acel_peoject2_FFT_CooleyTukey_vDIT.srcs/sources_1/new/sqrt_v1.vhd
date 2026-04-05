----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.04.2026 23:48:45
-- Design Name: 
-- Module Name: sqrt_v1 - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
 
entity sqrt_v1 is
    generic(
        DATA_WIDTH : integer := 25
    );
    Port (
        in_clk : in std_logic;
        in_rst : in std_logic;
        in_data : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        in_data_vld : in std_logic;
        out_data : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        out_data_vld : out std_logic
   
    );
end sqrt_v1;
 
architecture Behavioral of sqrt_v1 is
   
    function f_WIDTH_CNTRL (DATA_WIDTH : integer) return integer is
    begin
       if (DATA_WIDTH / 2) * 2 = DATA_WIDTH then
           return DATA_WIDTH;
       else
           return DATA_WIDTH + 1;
       end if;
    end f_WIDTH_CNTRL;
   
    function f_DATA_CNTRL(c_DATA_WIDTH, g_DATA_WIDTH : integer; in_data : std_logic_vector(DATA_WIDTH - 1 downto 0)) return std_logic_vector is
    begin
       if g_DATA_WIDTH = c_DATA_WIDTH then
           return in_data;
       else
           return ('0' & in_data);
       end if;
    end f_DATA_CNTRL;
   
    constant c_DATA_WIDTH : integer := f_WIDTH_CNTRL(DATA_WIDTH);
   
    type t_Cntrl is (IDLE, SHIFT_BIT, CHK_DATA, DONE);
    signal r_Cntrl : t_Cntrl := IDLE;
 
    signal r_data_in : std_logic_vector(c_DATA_WIDTH -1 downto 0) := (others => '0');
    signal r_res : std_logic_vector(c_DATA_WIDTH -1 downto 0) := (others => '0');
    signal r_bit : std_logic_vector(c_DATA_WIDTH -1 downto 0) := conv_std_logic_vector(2**(c_DATA_WIDTH - 2), c_DATA_WIDTH);
    signal r_data_vld : std_logic := '0';
   
   
 
begin
 
    out_data <= r_res(DATA_WIDTH - 1 downto 0);
    out_data_vld <= r_data_vld;
 
    process(in_rst, in_clk)
    begin
        if in_rst = '0' then
            r_Cntrl <= IDLE;
            r_data_in <= (others => '0');
            r_res <= (others => '0');
            r_bit <= conv_std_logic_vector(2**(c_DATA_WIDTH - 2), c_DATA_WIDTH);
            r_data_vld <= '0';
        elsif rising_edge(in_clk) then
            r_data_vld <= '0';
            case r_Cntrl is
                when IDLE =>                   
                    r_res <= (others => '0');
                    r_bit <= conv_std_logic_vector(2**(c_DATA_WIDTH - 2), c_DATA_WIDTH);
                    if in_data_vld = '1' then
                        r_data_in <= f_DATA_CNTRL(c_DATA_WIDTH, DATA_WIDTH, in_data);
                        r_Cntrl <= SHIFT_BIT;
                    end if;
                   
                when SHIFT_BIT =>
                    if r_bit > r_data_in then
                        r_bit <= "00" & r_bit(r_bit'high downto 2);                    
                    else
                        r_Cntrl <= CHK_DATA;
                    end if;
                   
                when CHK_DATA =>
                    if r_bit /= 0 then
                        if r_data_in >= (r_res + r_bit) then
                            r_data_in <= r_data_in - (r_res + r_bit) ;
                            r_res <= ('0' & r_res(r_res'high downto 1)) + r_bit;
                        else
                            r_res <= '0' & r_res(r_res'high downto 1);                             
                        end if;    
                        r_bit <= "00" & r_bit(r_bit'high downto 2);                        
                    else
                        r_data_vld <= '1';
                        r_Cntrl <= DONE;
                    end if;
                when others => NULL;
            end case;
           
        end if;
    end process;
 
 
end Behavioral;
