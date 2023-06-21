library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity n_bit_layer1 is
    generic (
        c_datalength     : integer := 32; -- can be configured
        c_layernumber1   : integer := 1   -- must stay as constant !!
);
port ( 

    lay1_data_i   : in  std_logic_vector(c_datalength -1 downto 0);
    sys_en_i      : in  std_logic;
    lay1_out      : out std_logic_vector(c_datalength - 1 downto 0)

);
end n_bit_layer1;

architecture Behavioral of n_bit_layer1 is

    component layer1_summing is
        port ( 
                lay1_vec_el1      : in std_logic;
                lay1_vec_el2     : in std_logic;
                lay_1en           : in std_logic;
                lay_vec_1to2      : out std_logic_vector(1 downto 0)
        );
        end component;

        constant layercount   : integer := (c_datalength) / (2**c_layernumber1);
        constant c_layercount : integer := layercount -1;

begin

    layer_1_xors : for i in 0 to c_layercount  generate

        u1 : layer1_summing 
            port map ( 
                    lay1_vec_el1     => lay1_data_i(2*i+1),
                    lay1_vec_el2     => lay1_data_i(2*i),
                    lay_1en          => sys_en_i,
                    lay_vec_1to2     => lay1_out(2*i+1 downto 2*i) 
            );
    end generate;


end Behavioral;
