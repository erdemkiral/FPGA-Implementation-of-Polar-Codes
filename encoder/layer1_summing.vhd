library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity layer1_summing is
port ( 
        lay1_vec_el1      : in std_logic;
        lay1_vec_el2      : in std_logic;
        lay_1en           : in std_logic;
        lay_vec_1to2      : out std_logic_vector(1 downto 0)
);
end layer1_summing;

architecture Behavioral of layer1_summing is

begin

lay_vec_1to2 <=  (lay1_vec_el1 xor lay1_vec_el2) & lay1_vec_el2 when lay_1en = '1' else "00";

end Behavioral;
