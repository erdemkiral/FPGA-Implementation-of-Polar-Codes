library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity g_function is
generic (
	bit_range       : integer := 64
);
port ( 
		in_1  : in integer range -bit_range to bit_range;
		in_2  : in integer range -bit_range to bit_range;
		in_3  : in std_logic;
		g_out : out integer range -bit_range to bit_range
);
end g_function;

architecture Behavioral of g_function is


begin

	g_out <= in_2 + in_1 when in_3 = '0' else 
			 in_2 - in_1;





end Behavioral;
