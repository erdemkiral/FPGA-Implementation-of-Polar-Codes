library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.my_pkg.all;


entity bpsk_symbol_converter is
generic (
			code_length : integer := 4

);
port ( 
			codeword_i : in std_logic_vector(code_length -1 downto 0);
			symbol_out : out int_arr(code_length -1 downto 0)
);
end bpsk_symbol_converter;

architecture Behavioral of bpsk_symbol_converter is

begin


SYMBOL_GEN : for i in 0 to code_length -1 generate 

			symbol_out(i) <= -1 when codeword_i(i) = '1' else 1;

end generate SYMBOL_GEN;




end Behavioral;
