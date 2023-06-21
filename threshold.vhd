library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



entity threshold is
	generic (
		bit_range       : integer := 64
	);
	port ( 
	
		in1_i  : in  integer range -bit_range to bit_range;
		logic_o :out std_logic
	);
end entity;

architecture Behavioral of threshold is

begin

process (in1_i) begin 

	if(in1_i < 0 ) then 
		logic_o <= '1';
	else 
		logic_o <= '0';
	end if;

end process;

end Behavioral;
