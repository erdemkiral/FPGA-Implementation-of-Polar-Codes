library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity n_bit_layer3 is
  generic (
    c_datalength    : integer := 32; -- can be configured 8 16 32 64 128 256 512 1024 
    c_layernumber3   : integer := 3   -- must stay as constant !!
);
port (
            lay3_data_i   : in std_logic_vector(c_datalength -1 downto 0);
            lay3_sys_en_i : in std_logic;
            lay_3_data_o  : out std_logic_vector(c_datalength -1 downto 0)
);
end n_bit_layer3;

architecture Behavioral of n_bit_layer3 is


  constant layer3count   : integer := (c_datalength) / (2**c_layernumber3);
  constant c_layer3count : integer := layer3count -1;


begin

  n_bitlayer :  for k in 0 to c_layer3count generate

        lay_3_data_o(8*k+7 downto 8*k) <=  (lay3_data_i(8*k + 7 downto 8*k +4) xor lay3_data_i(8*k + 3 downto 8*k)) & lay3_data_i(8*k + 3 downto 8*k)  when lay3_sys_en_i = '1' else (others => '0')  ;

    end generate ;    

    

end Behavioral;
