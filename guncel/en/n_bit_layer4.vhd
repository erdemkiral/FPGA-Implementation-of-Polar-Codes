library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity n_bit_layer4 is
generic(
           
            c_datalength  : integer := 32;
            c_layernumber4 : integer := 4
);
port ( 
        lay_4_data_i : in std_logic_vector( c_datalength -1 downto 0 );
        lay_4_sys_en : in std_logic;
        lay_4_data_o : out std_logic_vector(c_datalength -1 downto 0)


);
end n_bit_layer4;

architecture Behavioral of n_bit_layer4 is

    constant layercount   : integer := (c_datalength) / (4*c_layernumber4);
    constant c_layercount : integer := layercount -1;
    
    
begin

    layer_4_xors : for i in 0 to c_layercount  generate

     lay_4_data_o(16*i +15 downto 16*i) <=  (lay_4_data_i(16*i + 15 downto 16*i +8) xor lay_4_data_i( 16*i +7 downto  16*i) ) & lay_4_data_i(16*i +7 downto  16*i)  when lay_4_sys_en = '1' else (others => '0'); 

    end generate;

end Behavioral;
