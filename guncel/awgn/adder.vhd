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
    Port ( clk : in std_logic;
           madderin : in signed (17 downto 0);
           maskin   : in unsigned (15 downto 0);
           mulout   : out signed (33 downto 0));
end adder;

architecture Behavioral of adder is
signal data : signed (15 downto 0);
signal outa : signed (17 downto 0);
signal tata : signed (33 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            data <= signed(maskin);
            outa <= madderin;
        end if;
    end process;


proc_add: process(clk)
begin
    if rising_edge(clk) then
            tata <=  data * outa;
    end if;
end process proc_add;

    mulout <= tata;
end Behavioral;
