library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_to_input_vector is
generic (
            code_length    : integer := 32; -- default
            data_length    : integer := 16
);
port ( 
            clk            : in std_logic;
            data_i         : in std_logic_vector(15 downto 0);
            vector_en 	   : in std_logic;
            input_vector_o : out std_logic_vector(31 downto 0);
            vector_o_done  : out std_logic
);
end data_to_input_vector;

architecture Behavioral of data_to_input_vector is

type reliability_sequence is array (0 to 31) of integer;

constant bit_positions  : reliability_sequence := (0,1,2,4,8,16,3,5,9,6,17,10,18,12,20,24,7,11,19,13,14,21,26,25,22,28,15,23,27,29,30,31);
constant frozenbitcount : integer := code_length - data_length;

signal reg_to_input_vector_o  : std_logic_vector(31 downto 0);
signal cntr  : integer range 0 to 32 := 0;
signal cntr2 : integer range 0 to 15 := 15;

type states is (S_IDLE,S_FREEZE,S_DATA,S_DONE);
signal state : states := S_IDLE;

    

begin



process (clk) begin
    if rising_edge(clk) then
    
        case  state is
            when S_IDLE =>

                    vector_o_done <= '0';
                    cntr2 <= 15;
                    cntr <= 0;
                    reg_to_input_vector_o <= (others => '0'); input_vector_o <= (others => '0');
                    if vector_en = '1' then
                        state <= S_FREEZE;
                    end if;
            when S_FREEZE =>

                    if(cntr = frozenbitcount) then 
                         state <= S_DATA;
                    else 
                        reg_to_input_vector_o(31 - bit_positions(cntr)) <= '0';
                        cntr <= cntr + 1 ;
                    end if;


            when S_DATA =>

                    if(cntr = 32) then 
                        cntr <= 0; cntr2 <= 0; state <= S_DONE; input_vector_o <= reg_to_input_vector_o;
                    else
                        reg_to_input_vector_o(31-bit_positions(cntr)) <= data_i(cntr2);
                        cntr <= cntr + 1;
                        cntr2 <= cntr2 -1;
                    end if;


            when S_DONE =>
                    input_vector_o <= reg_to_input_vector_o ;
                    vector_o_done <= '1';
                    state <= S_IDLE;
        end case;

        
    end if;
end process;

end Behavioral;
