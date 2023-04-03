library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE std.textio.all;




entity uart_tx_memory is
    generic(
		c_clkfreq  		        : integer := 100_000_000;
		c_baudrate 		        : integer := 115_200;
		c_stopbitcount          : integer := 2;
        c_buffer_depth          : integer := 64;
        c_buffer_data_length    : integer := 32;
        C_RAM_TYPE 		        : string 	:= "block"  
);
port ( 
        clk            : in  std_logic;
        data_i         : in  std_logic_vector(c_buffer_data_length-1 downto 0);
       
        w_addr         : in  integer range 0 to c_buffer_depth-1 := 0;
        write_en       : in  std_logic;
        tx_state_en    : in  std_logic;
        tx             : out std_logic;
        interrupt      : out std_logic

);
end uart_tx_memory;

architecture Behavioral of uart_tx_memory is


    component uart_tx is
        generic(
                c_clkfreq  		: integer := 100_000_000;
                c_baudrate 		: integer := 115_200;
                c_stopbitcount  : integer := 2
        );
        port( 
              clk 	       : in std_logic;
              tx_data      : in std_logic_vector(7 downto 0);
              tx_start     : in std_logic;
              tx_o	       : out std_logic; 
              tx_done_tick : out std_logic
              );
    end component;

constant tx_byte  : integer := c_buffer_data_length/8;
signal   txcntr   : integer range 0 to tx_byte := tx_byte;

type buffer_arr is array (0 to c_buffer_depth -1) of std_logic_vector(c_buffer_data_length -1 downto 0);
signal databuff   : buffer_arr := (others => (others => '0') ) ;


signal tx_data      : std_logic_vector(7 downto 0) := (others => '0') ;
signal tx_start     : std_logic := '0';
signal tx_o	        : std_logic; 
signal tx_done_tick : std_logic;


attribute ram_style : string;
attribute ram_style of databuff : signal is C_RAM_TYPE;

signal tx_databuffer   : std_logic_vector(c_buffer_data_length -1 downto 0) := (others => '0');
signal r_addr          : integer range 0 to c_buffer_depth-1 := 0 ;
type states is (S_IDLE,S_TRANSMIT,S_DONE);
signal state : states;


begin


    P_WRITE : process (clk)
    begin
        if rising_edge(clk) then

                if write_en = '1' then
                    databuff(w_addr) <= data_i;
                end if;

            end if;
    end process;
	
	
    P_TRANSMIT : process (clk)
    begin
        if rising_edge(clk) then
  
            case state is

                when S_IDLE =>

                    interrupt <= '0';

                    if tx_state_en = '1' then

                        if r_addr = c_buffer_depth-1 then
                            r_addr <= 0;
                        end if;

                        tx_data <= databuff(r_addr)((txcntr*8)-1 downto (txcntr-1)*8);
                        txcntr <= tx_byte - 1 ;
                        tx_start <= '1';
                        state <= S_TRANSMIT;

                    else 
                        state <= S_IDLE;
                    end if;
                
                when S_TRANSMIT =>

                    if txcntr = 0 then 
                        
                        tx_start <= '0';
				    	if tx_done_tick = '1' then
				    		tx_start <= '0';
                            txcntr <= tx_byte;
				    	    state <= S_DONE;
                            r_addr <= r_addr + 1;
				    	else 
				    		tx_data <= databuff(r_addr)(7 downto 0);
				    	end if;

				    else 
                    
				    	if(tx_done_tick = '1') then 
				    		txcntr <= txcntr - 1;
				    	else 
				    		tx_data <= databuff(r_addr)((txcntr*8)-1 downto (txcntr-1)*8);
				    	end if;		
                    
				    end if;
            
                when S_DONE => 

                    interrupt <= '1'; 
                    state <= S_IDLE;

            end case;
        end if;
    end process;


    u_tx :  uart_tx 
        generic map (
                c_clkfreq  		=> c_clkfreq,
                c_baudrate 		=> c_baudrate,
                c_stopbitcount  => c_stopbitcount
        )
        port map( 
              clk 	       => clk,
              tx_data      => tx_data     ,
              tx_start     => tx_start    ,
              tx_o	       => tx	      , 
              tx_done_tick => tx_done_tick
              );


 






end Behavioral;
