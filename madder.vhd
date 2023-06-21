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
    Port ( clk     : in std_logic;
           coef2   : in unsigned (17 downto 0);
           coef1   : in signed (36 downto 0);
           maddout : out signed (37 downto 0);
           maskin  : in unsigned (15 downto 0));
end madder;

architecture Behavioral of madder is
signal multiout :signed (33 downto 0);
signal addout : signed (37 downto 0);
signal coef22 : signed (17 downto 0);
signal coef11 : signed (36 downto 0);
signal mask   : signed (15 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            coef22 <= signed(coef2);
            coef11 <= coef1;
            mask   <= signed(maskin);
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            multiout <= coef22 * mask;
        end if;
    end process;
    
    addout <= (b"0" & (multiout + coef11));

proc_multy: process(clk)
begin
    if rising_edge(clk) then
            maddout <= addout;
    end if;
end process proc_multy;

end Behavioral;
