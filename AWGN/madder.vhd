----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/31/2023 10:41:58 PM
-- Design Name: 
-- Module Name: madder - Behavioral
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

entity madder is
    Port ( clk,rst : in std_logic;
           coef2,coef1 : in unsigned (17 downto 0);
           maddout : out unsigned (32 downto 0);
           maskin : in unsigned (14 downto 0));
end madder;

architecture Behavioral of madder is
signal multiout : unsigned (32 downto 0);
signal addout : unsigned (32 downto 0);
signal multiout2 : unsigned (32 downto 0);

begin

    multiout <= coef2 * maskin;
    addout <= multiout + coef1;
    multiout2 <= addout(17 downto 0) * maskin;

proc_multy: process(clk)
begin
    if rising_edge(clk) then
        if rst = '0' then
            maddout <= to_unsigned(69, maddout'length);
        else
            maddout <= multiout2;
        end if;
    end if;
end process proc_multy;

end Behavioral;
