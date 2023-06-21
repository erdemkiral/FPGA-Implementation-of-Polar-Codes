library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity absolute_value is
generic (
			bit_range       : integer := 64
	);
Port(
		signed_in     : in  integer range -bit_range to bit_range;
		abs_out	      : out integer range -bit_range to bit_range 
);
end absolute_value;

architecture Behavioral of absolute_value is


begin

abs_out <= -signed_in when signed_in < 0 else signed_in ;


end Behavioral;
