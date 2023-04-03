library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity uart_rx_large_buffer is
    generic(
        clkfreq                 : integer := 100_000_000;
        baudrate                : integer := 115_200;
        c_buffer_depth          : integer := 64;
        c_buffer_data_length    : integer := 256
);
port ( 
        clk            : in  std_logic;
        rx_i           : in  std_logic;
        addr           : in  integer range 0 to c_buffer_depth-1 := 0;
        data_available : out std_logic;
        memory_out     : out std_logic_vector(c_buffer_data_length -1 downto 0)

);
end uart_rx_large_buffer;

architecture Behavioral of uart_rx_large_buffer is


    component uart_rx is
        generic(
                clkfreq  : integer := 100_000_000;
                baudrate : integer := 115_200
        );
        port ( 
                clk 	: in  std_logic;
                rx_i	: in  std_logic;
                data	: out std_logic_vector(7 downto 0);
                rx_done	: out std_logic
        );
    end component;
        
signal rx_data	: std_logic_vector(7 downto 0);
signal rx_done	: std_logic;


type buffer_arr is array (0 to c_buffer_depth -1) of std_logic_vector(c_buffer_data_length -1 downto 0);
signal databuff         : buffer_arr := (others => (others => '0') ) ;
signal rx_addr_cntr     : integer range 0 to 2048 := 0;
signal data_sig         : std_logic_vector(c_buffer_data_length-1 downto 0) := (others => '0') ;

constant rx_byte_counter_lim : integer := c_buffer_data_length/8;
signal  rx_byte_counter : integer range 0 to rx_byte_counter_lim  := rx_byte_counter_lim ;

begin


         N_8 : if c_buffer_data_length  = 8 generate

               P_TAMPON : process (clk) begin
                       if rising_edge(clk) then
                               if rx_done = '1' then
                                       databuff(rx_addr_cntr)  <= rx_data;
                                       data_available <= '1';
                               else 
                                       data_available <= '0';
                               end if;
                       end if;
               end process P_TAMPON;

        P_WRITE_COUNTER: process (clk)
               begin
                       if rising_edge(clk) then

                               if rx_done = '1' then
                                       rx_addr_cntr <= rx_addr_cntr + 1;
                               else 
                                       rx_addr_cntr <= rx_addr_cntr;
                               end if;
                       end if;
               end process P_WRITE_COUNTER;
         end generate;

        N_GREATER_8 : if c_buffer_data_length > 8 generate

                P_TAMPON : process (clk) begin
                        if rising_edge(clk) then
                                
                                if rx_done = '1' then
                                        databuff(rx_addr_cntr)(8*rx_byte_counter-1 downto 8*(rx_byte_counter-1)) <= rx_data;
                                        rx_byte_counter <= rx_byte_counter - 1;
                                else 
                                        if rx_byte_counter = 0 then

                                                if rx_addr_cntr = c_buffer_depth-1 then
                                                        rx_byte_counter <= rx_byte_counter_lim;
                                                        data_available <= '1';
                                                        rx_addr_cntr <= 0;
                                                else 
                                                        rx_byte_counter <= rx_byte_counter_lim;
                                                        data_available <= '1';
                                                        rx_addr_cntr <= rx_addr_cntr +1;
                                                end if;
                                        else 
                                                data_available <= '0';
                                        end if;
                                end if;

                        end if;
                end process P_TAMPON;
                
        end generate;

        P_MEM_OUT : process (clk)
        begin
                if rising_edge(clk) then
                                memory_out <= databuff(addr)(c_buffer_data_length -1 downto 0);
                end if;
        end process P_MEM_OUT;
        
    i_uart_rx :  uart_rx 
        generic map (
                clkfreq  => clkfreq ,
                baudrate => baudrate
        )
        port map ( 
                clk 	=> clk ,
                rx_i	=> rx_i,
                data	=> rx_data,
                rx_done	=> rx_done
        );
   

end Behavioral;
