library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity n_bit_layer5 is
    generic (
                c_datalength    : integer := 32; -- can be configured
                c_layernumber5   : integer := 5   -- must stay as constant !!
    );
port (  
    lay_5_data_i : in std_logic_vector( c_datalength -1 downto 0 );
    lay_5_sys_en : in std_logic;
    lay_5_data_o : out std_logic_vector(c_datalength -1 downto 0)
);
end n_bit_layer5;

architecture Behavioral of n_bit_layer5 is

    constant layercount   : integer := (c_datalength) / (2**c_layernumber5);
    constant c_layercount : integer := layercount -1;

begin


single_lay : if layercount = 1 generate
    lay_5_data_o <=  (lay_5_data_i(31 downto 16) xor lay_5_data_i(15 downto 0)) & lay_5_data_i(15 downto 0)  when lay_5_sys_en = '1' else (others => '0'); 
end generate;

multiple_lay : if layercount > 1 generate

        lay5_xors : for i in 0 to c_layercount generate
            lay_5_data_o(32*i+31 downto 32*i) <= (lay_5_data_i(32*i+31 downto 32*i+16) xor lay_5_data_i(32*i+15 downto 32*i))& lay_5_data_i(32*i+15 downto 32*i) & when lay_5_sys_en = '1' else (others => '0'); 
       
        end generate;


end generate;


end Behavioral;
