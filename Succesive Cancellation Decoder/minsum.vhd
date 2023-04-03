library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity minsum is
generic (
			bit_range       : integer := 64
	);
port ( 
		belief1      : in  integer range -bit_range to bit_range;
		belief2      : in  integer range -bit_range to bit_range;
		min_sum_o    : out integer range -bit_range to bit_range
);
end minsum;

architecture Behavioral of minsum is


component absolute_value is
generic (
			bit_range       : integer := 64
	);
Port(
		signed_in     : in  integer range -bit_range to bit_range;
		abs_out	      : out integer range -bit_range to bit_range 
);
end component;

component negative_converter is
generic (
			bit_range       : integer := 64
	);
port (
		signed_in 		  : in   integer range -bit_range to bit_range;
		negative_out	  : out  integer range -bit_range to bit_range 
 );
end component;


------------------SIGNALS FOR ABSOLUTE VALUE OPERATION BLOCKS------------

signal	abs_out_1	  	: integer range -bit_range to bit_range;
signal	abs_out_2		: integer range -bit_range to bit_range;

-------------------------------------------------------------------------

-------------------SIGNALS FOR POSITIVE TO NEGATIVE CONVERTER BLOCKS-----------------

signal	pn_neg_out_1	  	: integer range -bit_range to bit_range;
signal	pn_neg_out_2		: integer range -bit_range to bit_range;

------------------------------------------------------------------------------------

signal greater : std_logic;
signal equal   : std_logic;
signal lower   : std_logic;
signal zero    : std_logic;

signal process_vector : std_logic_vector(7 downto 0);
signal stage1 : std_logic_vector(3 downto 0);


begin


stage1(0) <= '1' when belief1 < 0 and belief2 < 0  else '0';
stage1(1) <= '1' when belief1 < 0 and belief2 > 0  else '0';
stage1(2) <= '1' when belief1 > 0 and belief2 < 0  else '0';
stage1(3) <= '1' when belief1 > 0 and belief2 > 0   else '0';


greater <=  '1' when abs_out_1 > abs_out_2 else '0';
lower 	<=  '1' when abs_out_1 < abs_out_2 else '0';
equal 	<=  '1' when abs_out_1 = abs_out_2 else '0';
zero    <=  '1' when (abs_out_1 = 0) or (abs_out_2 = 0) else '0'; 


process_vector <= stage1 & lower & greater  & equal & zero ;


process(process_vector,abs_out_1,abs_out_2,pn_neg_out_1,pn_neg_out_2,belief1,belief2) begin 
                                                                     
	case process_vector is 
	
		when "00011000" => min_sum_o <= abs_out_1;
		when "00010100" => min_sum_o <= abs_out_2;
		when "00010010" => min_sum_o <= abs_out_1;
		when "00010001" => min_sum_o <= 0;
		
		when "00101000" => min_sum_o <= pn_neg_out_1;
		when "00100100" => min_sum_o <= pn_neg_out_2;
		when "00100010" => min_sum_o <= pn_neg_out_1;
		when "00100001" => min_sum_o <=  0;
		
		when "01001000" => min_sum_o <= pn_neg_out_1;
		when "01000100" => min_sum_o <= pn_neg_out_2;
		when "01000010" => min_sum_o <= pn_neg_out_1;
		when "01000001" => min_sum_o <=  0;
		
		when "10001000" => min_sum_o <= belief1;
		when "10000100" => min_sum_o <= belief2;
		when "10000010" => min_sum_o <= belief2;
		when "10000001" => min_sum_o <= 0;
		when others     => min_sum_o <= 0;
	
	end case;

end process;





-- out_vector <= abs_out_1    when (stage1(0) = '1' and lower   = '1') else
			  -- abs_out_2    when (stage1(0) = '1' and greater = '1') else 
			  -- abs_out_1    when (stage1(0) = '1' and equal   = '1') else 
			  
			  -- pn_neg_out_1 when (stage1(1) = '1' and lower   = '1') else
			  -- pn_neg_out_2 when (stage1(1) = '1' and greater = '1') else
			  -- pn_neg_out_1 when (stage1(1) = '1' and equal   = '1') else
			  
			  -- pn_neg_out_1 when (stage1(2) = '1' and lower   = '1') else 
			  -- pn_neg_out_2 when (stage1(2) = '1' and greater = '1') else 
			  -- pn_neg_out_1 when (stage1(2) = '1' and equal   = '1') else 
			  
			  -- in_1         when (stage1(3) = '1' and lower   = '1') else
			  -- in_2   	   when (stage1(3) = '1' and greater = '1') else
			  -- in_2   	   when (stage1(3) = '1' and equal   = '1') else 
			  -- x"0000"      when  zero = '1';



			  u1 :  absolute_value
				generic map( bit_range => bit_range)
				Port map (
						signed_in    => belief1 ,
						abs_out	     =>  abs_out_1
				);
				

				u2 : absolute_value
				generic map( bit_range => bit_range)				
				Port map(
							signed_in    =>  belief2,
							abs_out	     =>  abs_out_2
					);
					

				u3 : negative_converter
				generic map( bit_range => bit_range)
				port map (
						signed_in 	  => belief1,  
						negative_out  => pn_neg_out_1
						);
				
		
				u4 : negative_converter
				generic map( bit_range => bit_range)
				port map (
						signed_in 	  => belief2,
						negative_out  => pn_neg_out_2
				 );
				







end Behavioral;
