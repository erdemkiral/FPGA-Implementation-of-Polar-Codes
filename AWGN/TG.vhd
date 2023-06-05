----------------------------------------------------------------------------------
-- Company: 
-- Engineer: TYT
-- 
-- Create Date: 05/20/2023 07:41:08 PM
-- Design Name: 
-- Module Name: TG
-- Project Name: 
-- Target Devices: tng
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
use IEEE.numeric_std.all;

entity TG is
    generic ( seed1 : std_logic_vector(63 downto 0):= "1111011100011110101000010000000000011111111000111011110111101110";
              seed2 : std_logic_vector(63 downto 0):= "1111100001110000001111001111111111111100001100010011000111111111";
              seed3 : std_logic_vector(63 downto 0):= "1010001100101011101111111111011001111001110010011010100010010111");
            
    Port ( clk,rst : in STD_LOGIC;
           data : out std_logic_vector(63 downto 0));
end TG;

architecture Behavioral of TG is
signal s1,s2,s3,s1n,s2n,s3n : std_logic_vector(63 downto 0);
begin
  s1n <= (s1(39 downto 1) & (s1(58 downto 34) xor s1(63 downto 39)));
  s2n <= (s2(50 downto 6) & (s2(44 downto 26) xor s2(63 downto 45)));
  s3n <= (s3(56 downto 9) & (s3(39 downto 24) xor s3(63 downto 48)));

  process(clk,rst)
  begin
   if (rst = '0') then
       s1 <= seed1;
       s2 <= seed2;
       s3 <= seed3;
   elsif (clk'event and clk='1') then
       s1 <= s1n;
       s2 <= s2n;
       s3 <= s3n;
   end if;
  end process;

 process(clk)
 begin
  if rising_edge(clk) then
  data <= s1 xor s2 xor s3;
  end if;
 end process;


end Behavioral;
