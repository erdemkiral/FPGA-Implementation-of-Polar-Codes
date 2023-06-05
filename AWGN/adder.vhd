----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/31/2023 10:41:58 PM
-- Design Name: 
-- Module Name: adder - Behavioral
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

entity adder is
    Port ( clk,rst : in std_logic;
           madderin : in unsigned (32 downto 0);
           coef0 : in unsigned (20 downto 0);
           addout : out unsigned (15 downto 0));
end adder;

architecture Behavioral of adder is
signal data : unsigned (32 downto 0);

begin
data <= madderin + coef0;

proc_add: process(clk)
begin
    if rising_edge(clk) then
        if rst = '0' then
            addout <= to_unsigned(315, addout'length);
        else
            addout <= data(15 downto 0);
        end if;
    end if;
end process proc_add;

end Behavioral;
