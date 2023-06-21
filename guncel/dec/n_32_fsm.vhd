library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.my_pkg.all;




entity n_32_fsm is
    generic(
		bit_range			: integer := 64;
        data_data           : std_logic_vector(1 downto 0) := "11";				 
        frozen_data         : std_logic_vector(1 downto 0) := "01";				        
        data_frozen         : std_logic_vector(1 downto 0) := "10";				 
        frozen_frozen       : std_logic_vector(1 downto 0) := "00"				
);
port ( 
            clk                : in std_logic;
            decode_en          : in std_logic;
            llr_i              : in int_arr(31 downto 0);
            estimate_data      : out std_logic_vector(15 downto 0);
            decode_op_done     : out std_logic
);
end n_32_fsm;

architecture Behavioral of n_32_fsm is


component n_32_decoder is
        generic(
            bit_range			: integer := 64;
            data_data           : std_logic_vector(1 downto 0) := "11";				 
            frozen_data         : std_logic_vector(1 downto 0) := "01";				        
            data_frozen         : std_logic_vector(1 downto 0) := "10";				 
            frozen_frozen       : std_logic_vector(1 downto 0) := "00"				
    );
    port ( 
                clk           : in std_logic;
                channel_llr_i : in int_arr(31 downto 0);
                estimate      : out std_logic_vector(31 downto 0)
    );
    end component;

    
signal channel_llr_i : int_arr(31 downto 0);
signal estimate      : std_logic_vector(31 downto 0);

type states is (S_IDLE,S_WAIT,S_DONE);
signal state : states;

signal cntr     : integer range 0 to 63 := 0;


begin



    P_MAIN : process (clk) begin
        if rising_edge(clk) then
            
            case state is

                when S_IDLE =>
                
                decode_op_done <= '0';
                estimate_data <= (others => '0');
                if decode_en = '1' then
                    channel_llr_i <= llr_i;
                    state <= S_WAIT;
                end if;

                when S_WAIT =>

                    if cntr = 45 then
                        cntr <= 0; state <= S_DONE;
                    else 
                        cntr <= cntr + 1;
                    end if;

                when S_DONE =>
                
                 decode_op_done <= '1';
                 state <= S_IDLE;
                 estimate_data <= estimate(24)&estimate(20)&estimate(12)&estimate(18)&estimate(17)&estimate(10)&estimate(5)&estimate(6)&estimate(9)&estimate(3)&estimate(16)&estimate(8)&
                        estimate(4)&estimate(2)&estimate(1)&estimate(0);

            end case;

            end if;
        end process P_MAIN;


    i_n32dec : n_32_decoder 
        generic map(
			bit_range 		=> bit_range,
            data_data       => data_data    , 				 
            frozen_data     => frozen_data  , 				        
            data_frozen     => data_frozen  , 				 
            frozen_frozen   => frozen_frozen			
    )
    port map ( 
                clk           => clk,
                channel_llr_i => channel_llr_i,
                estimate      => estimate     
    );
    




end Behavioral;
