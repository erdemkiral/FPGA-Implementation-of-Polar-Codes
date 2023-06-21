-- Engineer    : ERDEM KIRAL 
-- Create Date : 10.10.2022 15:10:58
-- Design Name : 
-- Module Name : n_bit_layer2 - Behavioral
-- Project Name: Implemetation of encoder and decoder for polar codes with awgn noise on fpga



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity n_bit_layer2 is
    generic (
        c_datalength    : integer := 32; -- can  be configured
        c_layernumber2   : integer := 2   -- must stay as constant !!
);
    port ( 

        lay2_data_i   : in  std_logic_vector(c_datalength -1 downto 0);
        sys_en_i      : in  std_logic;
        lay2_out      : out std_logic_vector(c_datalength -1  downto 0)
    
    );
end n_bit_layer2;

architecture Behavioral of n_bit_layer2 is


constant layercount   : integer := (c_datalength) / (2**c_layernumber2);
constant c_layercount : integer := layercount -1;

begin


    layer_2_xors : for i in 0 to c_layercount generate

        lay2_out(4*i +3 downto 4*i) <= (lay2_data_i(4*i + 3 downto 4*i +2) xor lay2_data_i( 4*i +1 downto  4*i) ) & lay2_data_i(4*i + 1 downto 4*i)  when sys_en_i = '1' else (others => '0'); 

    end generate;






end Behavioral;
