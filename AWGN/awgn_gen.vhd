library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.my_pkg.all;

entity awgn_gen is
Port ( 

        clk       : in std_logic;
        rst       : in std_logic;
        bpsk_i    : in int_arr(31 downto 0);
        channel_o : out int_arr(31 downto 0)

);
end awgn_gen;

architecture Behavioral of awgn_gen is

    component awgn_top is
        Port ( clk,rst : in STD_LOGIC;
               data_out : out integer;
               data_in : in integer
               );
    end component;
    
begin


    awgn_gen : for i in 0 to 31 generate

        i_awgn : awgn_top 
        Port map ( 
                clk       => clk,
                 rst      => rst,
                 data_in   => bpsk_i(i),
                 data_out  => channel_o(i)
            );

    end generate;



    



end Behavioral;
