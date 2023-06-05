----------------------------------------------------------------------------------
-- Company: 
-- Engineer: TYT
-- 
-- Create Date: 05/23/2023 10:48:06 PM
-- Design Name: 
-- Module Name: awgn_top - topmod
-- Project Name: tng
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

entity awgn_top is
    Port ( clk,rst : in STD_LOGIC;
           data_out : out signed (15 downto 0);
           data_in : in signed (15 downto 0));
end awgn_top;

architecture topmod of awgn_top is
--signal signb : std_logic;
signal inverse_in : std_logic_vector (63 downto 0);
signal data, inverse_out : signed (15 downto 0);
begin

tg_module: entity work.TG
  port map (
    clk  => clk,
    rst  => rst,
    data => inverse_in
  );

inverse_module: entity work.inverse
  port map (
    clk      => clk,
    rst      => rst,
    TG_INPUT => inverse_in,
    data_out => inverse_out
  );
  
--signb <= not (inverse_out(15));
  
data <= data_in + inverse_out;
   
process(clk)
  begin
    if rising_edge(clk) then
        if rst = '0' then
        data_out <= "0000000000000000";
        else
        data_out <= data;
        end if;
    end if;
  end process;

end topmod;

