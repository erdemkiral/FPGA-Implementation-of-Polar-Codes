library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



entity negative_converter is
generic (
			bit_range       : integer := 64
	);
port (
		signed_in 	  : in   integer range -bit_range to bit_range;
		negative_out	  : out  integer range -bit_range to bit_range 
 );
end negative_converter;

architecture Behavioral of negative_converter is

begin

negative_out <= -signed_in when signed_in > 0 else signed_in ;


end Behavioral;
