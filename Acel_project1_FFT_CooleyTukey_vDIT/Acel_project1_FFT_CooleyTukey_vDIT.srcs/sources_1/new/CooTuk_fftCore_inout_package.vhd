----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.04.2026 18:09:41
-- Design Name: 
-- Module Name: CooTuk_fftCore_inout_package - Behavioral
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

--use IEEE.NUMERIC_STD.ALL;
 

package CooTuk_fftCore_inout_package is
-- for begininig kep in and out bit length same later you may change 
    
    
    
    type inout_pin_2fft_core is record 
            in1  ,in1j  :  integer range -2047 to 2047 ;--12 bit 
            out1,out1j:  integer range -2047 to 2047 ;
            
            end record ;
--    type inout_pin_4fft_core is record 
--            in1 , in2 ,in1j , in2j  :  integer range -2047 to 2048 ;
--            out1,out2,out1j,out2j :  integer range -2047 to 2048 ;
            
--            end record ;



end CooTuk_fftCore_inout_package;
