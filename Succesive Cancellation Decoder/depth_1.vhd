library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package my_pkg is 

type int_arr is array (natural range <>) of integer range -64 to 64 ;


end package;

package body my_pkg is 

end package body;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.my_pkg.all;

entity depth_1 is
generic (
			bit_range       : integer := 64
	);
port ( 
		data_depth1_i  	     : in  int_arr(3 downto 0);
		belief_left_data_i   : in  std_logic_vector(1 downto 0);
		belief_right_data_i  : in  std_logic_vector(1 downto 0);
		transfer_vector_o	 : out std_logic_vector(3 downto 0);
		layer_left_o 	 	 : out int_arr(1 downto 0);
		layer_right_o 	 	 : out int_arr(1 downto 0)
);
end depth_1;

architecture Behavioral of depth_1 is


component minsum is
generic (
			bit_range       : integer := 64
	);
port ( 
		belief1      : in  integer range -bit_range to bit_range;
		belief2      : in  integer range -bit_range to bit_range;
		min_sum_o    : out integer range -bit_range to bit_range
);
end component;

component g_function is
generic (
			bit_range       : integer := 64
	);
port ( 
		in_1  : in  integer range -bit_range to bit_range;
		in_2  : in  integer range -bit_range to bit_range;
		in_3  : in  std_logic;
		g_out : out integer range -bit_range to bit_range
);
end component;



			
begin

	transfer_vector_o <= (belief_left_data_i xor belief_right_data_i) & belief_right_data_i;



g_func_gen : for i in 0 to 1 generate

	g_1 :  g_function
	generic map( bit_range => bit_range)
	port map  ( 
				in_1  => data_depth1_i(i+2),
				in_2  => data_depth1_i(i),
				in_3  => belief_left_data_i(i),
				g_out => layer_right_o(i)
		);
end generate;


minsum_gen : for i in 0 to 1 generate 

u1 : minsum
generic map( bit_range => bit_range)
port map ( 
		belief1      => data_depth1_i(i+2),
		belief2      => data_depth1_i(i),
		min_sum_o    => layer_left_o(i)
);

end generate;



	





end Behavioral;
