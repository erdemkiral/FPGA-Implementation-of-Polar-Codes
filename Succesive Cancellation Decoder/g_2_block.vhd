library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.my_pkg.all;


entity g_2_block is
generic(	
		bit_range       : integer := 64;
		leaf_node_type  : std_logic_vector(1 downto 0) := "00" 		-- "00" frozen position & frozen position 
		-- leaf_node_type  : std_logic_vector(1 downto 0) := "01"	-- "01" frozen position & data position 
		-- leaf_node_type  : std_logic_vector(1 downto 0) := "10"	-- "10"  data           & frozen position 
		-- leaf_node_type  : std_logic_vector(1 downto 0) := "11"	-- "11"  data position   & data position 
);
port ( 
		data_1_i     : in integer range -bit_range to bit_range;
		data_2_i     : in integer range -bit_range to bit_range;
		transfer_o   : out std_logic_vector(1 downto 0);
		layer_o      : out int_arr(1 downto 0);
		leaf_node_o  : out std_logic_vector(1 downto 0)
);
end g_2_block;

architecture Behavioral of g_2_block is

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
				in_1  : in integer range -bit_range to bit_range;
				in_2  : in integer range -bit_range to bit_range;
				in_3  : in std_logic;
				g_out : out integer range -bit_range to bit_range
		);
	end component;


component threshold is
	generic (
		bit_range       : integer := 64
	);
	port ( 
	
		in1_i  : in  integer range -bit_range to bit_range;
		logic_o :out std_logic
	);
end component;



signal threshold1 : std_logic;
signal threshold2 : std_logic;
signal min_sum_o  : integer range -bit_range to bit_range := 0;


signal f_out : integer range -bit_range to bit_range := 0;




begin

----------------LEAF NODE 00----------------------------------

leaf_node_00  : if leaf_node_type = "00" generate 

leaf_00_m :  minsum
generic map (bit_range => bit_range) 
port map ( 
		belief1      => data_1_i  ,
		belief2      => data_2_i  ,
		min_sum_o    => layer_o(1)
);

leaf_00_1 : threshold
generic map (bit_range => bit_range)  
port map ( 

		in1_i   => conv_integer(0), 
		logic_o => threshold1
);

leaf_00_g : g_function
generic map (bit_range => bit_range)  
port map ( 
		in_1  => data_1_i ,
		in_2  => data_2_i ,
		in_3  => '0' ,
		g_out => layer_o(0)
);

leaf_01_2 : threshold
generic map (bit_range => bit_range)  
port map ( 

		in1_i   => conv_integer(0), 
		logic_o => threshold2
);

transfer_o <= (threshold1 xor threshold2) & threshold2 ;
leaf_node_o <= threshold1 & threshold2 ;


end generate leaf_node_00 ;





--------------------- LEAF NODE 01--------------------------------

leaf_node_01  :if leaf_node_type = "01" generate 

leaf_01_m :  minsum
generic map (bit_range => bit_range)  
port map ( 
		belief1      => data_1_i  ,
		belief2      => data_2_i  ,
		min_sum_o    => min_sum_o
);

leaf_01_1 : threshold
generic map (bit_range => bit_range)  
port map ( 

		in1_i   => conv_integer(0), 
		logic_o => threshold1
);



leaf_01_g : g_function
generic map (bit_range => bit_range)  
port map ( 
	in_1  => data_1_i ,
	in_2  => data_2_i ,
	in_3  => '0' ,
	g_out => f_out
);

leaf_01_2 : threshold
generic map (bit_range => bit_range)  
port map ( 

		in1_i   => f_out, 
		logic_o => threshold2
);


layer_o(0) <= f_out;
layer_o(1) <= min_sum_o;

transfer_o <= (threshold1 xor threshold2) & threshold2 ;
leaf_node_o <= threshold1 & threshold2 ;

end generate leaf_node_01 ;

leaf_node_10  : if leaf_node_type = "10" generate 


leaf_10_m :  minsum
generic map (bit_range => bit_range)  
port map ( 
		belief1      => data_1_i  ,
		belief2      => data_2_i  ,
		min_sum_o    => min_sum_o
);

leaf_10_d : threshold
generic map (bit_range => bit_range)  
port map ( 

		in1_i   => min_sum_o, 
		logic_o => threshold1
);


leaf_10_g : g_function
generic map (bit_range => bit_range)  
port map ( 
	in_1  => data_1_i ,
	in_2  => data_2_i ,
	in_3  => threshold1 ,
	g_out => f_out
);

leaf_10_d2 : threshold
generic map (bit_range => bit_range)  
port map ( 

		in1_i   => 0, 
		logic_o => threshold2
);

layer_o(0) <= f_out;
layer_o(1) <= min_sum_o;

transfer_o <= (threshold1 xor threshold2) & threshold2 ;
leaf_node_o <= threshold1 & threshold2 ;





end generate leaf_node_10 ;


leaf_node_11 : if leaf_node_type = "11" generate 

leaf_11_m :  minsum
generic map (bit_range => bit_range)  
port map ( 
		belief1      => data_1_i  ,
		belief2      => data_2_i  ,
		min_sum_o    => min_sum_o
);

leaf_11_d : threshold
generic map (bit_range => bit_range)  
port map ( 

		in1_i   => min_sum_o, 
		logic_o => threshold1
);

layer_o(1) <= min_sum_o;

leaf_11_g : g_function
generic map (bit_range => bit_range)  
port map ( 
	in_1  => data_1_i ,
	in_2  => data_2_i ,
	in_3  => threshold1,
	g_out => f_out
);

leaf_11_d2 : threshold
generic map (bit_range => bit_range)  
port map ( 

		in1_i   => f_out, 
		logic_o => threshold2
);

layer_o(0) <= f_out;

transfer_o <= (threshold1 xor threshold2) & threshold2 ;
leaf_node_o <= threshold1 & threshold2 ;

end generate leaf_node_11 ;



end Behavioral;
