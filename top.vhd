library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.my_pkg.all;




entity top is
    generic(

        --UART RX
        c_clkfreq  		        : integer := 100_000_000;
        c_baudrate 		        : integer := 115_200;
        c_stopbitcount          : integer := 2;
        c_buffer_depth          : integer := 512;
        c_buffer_data_length    : integer := 16;
        C_RAM_TYPE 		        : string  := "block";
        -- ENCODER & DECODER
        bit_range				: integer := 64;
        code_length             : integer := 32; -- default
        data_length             : integer := 16;
        c_layer1number          : integer := 1;
        c_layer2number          : integer := 2;
        c_layer3number          : integer := 3;
        c_layer4number          : integer := 4;
        c_layer5number          : integer := 5;
        data_data               : std_logic_vector(1 downto 0) := "11";				 
        frozen_data             : std_logic_vector(1 downto 0) := "01";				        
        data_frozen             : std_logic_vector(1 downto 0) := "10";				 
        frozen_frozen           : std_logic_vector(1 downto 0) := "00";
        -- UART TX
        clkfreq                 : integer := 100_000_000;
        baudrate                : integer := 115_200
    );
    Port ( 
        clk     : in std_logic;
        rx      : in std_logic;
        tx_o    : out std_logic
);
end top;

architecture Behavioral of top is


    component uart_rx_large_buffer is
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
            -- data_request   : in  std_logic;
            data_available : out std_logic;
            memory_out     : out std_logic_vector(c_buffer_data_length -1 downto 0)
    );
    end component;
    
    
    component uart_tx_memory is
        generic(
            c_clkfreq  		        : integer := 100_000_000;
            c_baudrate 		        : integer := 115_200;
            c_stopbitcount          : integer := 2;
            c_buffer_depth          : integer := 64;
            c_buffer_data_length    : integer := 32;
            C_RAM_TYPE 		        : string 	:= "block"  
    );
    port ( 
            clk                 : in  std_logic;
            data_i              : in  std_logic_vector(c_buffer_data_length-1 downto 0);
            w_addr              : in  integer range 0 to c_buffer_depth-1 := 0;
            write_en            : in  std_logic;
            tx_state_en         : in  std_logic;
            tx                  : out std_logic;
            interrupt           : out std_logic
    
    );
    end component;
    
    
    component polar_32_16 is
        generic (
                code_length      : integer := 32; -- default
                data_length      : integer := 16;
                c_layer1number   : integer := 1;
                c_layer2number   : integer := 2;
                c_layer3number   : integer := 3;
                c_layer4number   : integer := 4;
                c_layer5number   : integer := 5
        );
        port ( 
                    clk             : in  std_logic;
                    data_vector_i   : in  std_logic_vector(data_length-1 downto 0);
                    encode_en_i     : in  std_logic;
                    polar_o         : out std_logic_vector(code_length-1 downto 0);
                    polar_o_tick    : out std_logic
        );
    end component;

    component bpsk_symbol_converter is
        generic (
                    code_length : integer := 4
        
        );
        port ( 
                    codeword_i : in std_logic_vector(code_length -1 downto 0);
                    symbol_out : out int_arr(code_length -1 downto 0)
        );
    end component;



    component n_32_fsm is
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
    end component;
    
    signal rx_data_addr          : integer range 0 to c_buffer_depth-1 := 0;
    -- signal rx_data_request       : std_logic := '0';
    signal rx_data_available     : std_logic := '0';
    signal rx_memory_out         : std_logic_vector(c_buffer_data_length -1 downto 0) := (others => '0'); 
    

    signal encode_data_vector_i   : std_logic_vector(data_length-1 downto 0);
    signal encode_en_i            : std_logic;
    signal encode_polar_o         : std_logic_vector(code_length-1 downto 0);
    signal encode_polar_o_tick    : std_logic;

    signal codeword_i 			  :  std_logic_vector(code_length -1 downto 0);
    signal symbol_out 			  :  int_arr(code_length -1 downto 0);
    
    signal decode_en          	  : std_logic := '0';
    signal llr_i              	  : int_arr(31 downto 0) := (others => 0) ;
    signal estimate_data      	  : std_logic_vector(15 downto 0) := (others => '0') ;
    signal decode_op_done     	  : std_logic;
    
    signal data_i                 : std_logic_vector(c_buffer_data_length-1 downto 0) := (others => '0')  ;
    signal w_addr                 : integer range 0 to c_buffer_depth-1 := 0;
    signal write_en               : std_logic := '0';
    signal tx_state_en            : std_logic := '0';
    signal tx_r_addr              : integer range 0 to c_buffer_depth-1 := 2;
    signal interrupt              : std_logic := '0';
    
    signal encode_i_wea        	  : std_logic;
    
    signal decode_op_done_cntr    : integer range 0 to c_buffer_depth-1 := 0;
    signal input_packet_count     : integer range 0 to c_buffer_depth-1 := 0;
    signal sent_counter        	  : integer range 0 to c_buffer_depth-1 := 0;


    signal p_decode_en         : std_logic := '0';



begin


		P_RX_AV : process (clk)
		begin
			if rising_edge(clk) then
				
				if  rx_data_available = '1' then
						encode_i_wea <= '1';
				else 
					    encode_i_wea <= '0';
				end if;
		
			end if;
		end   process;
		
		process (clk)
		begin
			if rising_edge(clk) then
		
				if  encode_i_wea = '1' then

					if input_packet_count = c_buffer_depth-1 then
						encode_data_vector_i <= rx_memory_out;
						encode_en_i <= '1';
						rx_data_addr <= 0;
						input_packet_count <= 0;
					else 
						encode_data_vector_i <= rx_memory_out;
						encode_en_i <= '1';
						rx_data_addr <= rx_data_addr + 1;
						input_packet_count <= input_packet_count + 1;
					end if;
				else 
						encode_data_vector_i <= rx_memory_out;
						encode_en_i <= '0';
						rx_data_addr <= rx_data_addr;
						input_packet_count <= input_packet_count;
				end if;

			end if;
		end process;
		
		P_ENCODE_DONE_CHECK : process (clk)
		begin
			if rising_edge(clk) then
		
				if encode_polar_o_tick = '1' then
					codeword_i <= encode_polar_o;
					llr_i      <= symbol_out;
					p_decode_en <= '1';
				else 
					p_decode_en <= '0';
				end if;
		
			end if;
		end process;
		
		process (clk)
		begin
			if rising_edge(clk) then
		
				if p_decode_en = '1' then
					decode_en  <= '1';
				else 
					decode_en <= '0';
				end if;
				
			end if;
		end process;
		
		
		P_DECODE_CHECK : process (clk) begin
			if rising_edge(clk) then
				

					if decode_op_done = '1' then

						if decode_op_done_cntr = c_buffer_depth-1 then
							write_en <= '1';
							decode_op_done_cntr <= 0;
						else 
							write_en <= '1';
							decode_op_done_cntr <= decode_op_done_cntr + 1;    
						end if;
            
					else 
						write_en <= '0';
						decode_op_done_cntr <= decode_op_done_cntr;                
					end if;


		
			end if;
		end process;
		
		P_UART_TX_WRITE : process (clk)
		begin
			if rising_edge(clk) then

				
				if write_en = '1' then



					if w_addr = c_buffer_depth -1 then
						w_addr <= 0;
						data_i  <= estimate_data;
					else 
						data_i  <= estimate_data;
						w_addr  <= w_addr + 1;						
					end if;
	
				else 
					data_i   <= estimate_data;
					w_addr   <= w_addr;
	
				end if;
	
			end if;
		end process;
		
		
		
		TX : process (clk)
		begin
			if rising_edge(clk) then
		

				if decode_op_done_cntr >= 1 then
					
					if sent_counter = c_buffer_depth -1 then
						sent_counter <= 0;
						tx_state_en <= '0';
					else 
						if interrupt = '1' then
							tx_state_en <= '0';
							sent_counter <= sent_counter + 1;
						else 
							tx_state_en <= '1';
						end if;
					end if;
				else 
						if sent_counter > decode_op_done_cntr then
						
							if sent_counter = c_buffer_depth-1  then
								sent_counter <= 0;
								tx_state_en <= '0';
							else 
								if interrupt = '1' then
									tx_state_en <= '0';
									sent_counter <= sent_counter + 1;
								else 
									tx_state_en <= '1';
									sent_counter <= sent_counter;
								end if;
							end if;

						end if;
				end if;

			end if;
		end process;
		
		
		urxmem :  uart_rx_large_buffer 
			generic map (
				clkfreq                => clkfreq             , 
				baudrate               => baudrate            , 
				c_buffer_depth         => c_buffer_depth      , 
				c_buffer_data_length   => c_buffer_data_length
		)
		port map ( 
				clk            => clk,
				rx_i           => rx,
				addr           => rx_data_addr     ,
				data_available => rx_data_available,
				memory_out     => rx_memory_out    
		);
		
		
		i_encoder : polar_32_16 
			generic map (
					code_length      => code_length   ,  -- default
					data_length      => data_length   , 
					c_layer1number   => c_layer1number, 
					c_layer2number   => c_layer2number, 
					c_layer3number   => c_layer3number, 
					c_layer4number   => c_layer4number, 
					c_layer5number   => c_layer5number
			)
			port map ( 
						clk             => clk,
						data_vector_i   => encode_data_vector_i,
						encode_en_i     => encode_en_i         ,
						polar_o         => encode_polar_o      ,
						polar_o_tick    => encode_polar_o_tick 
			);
		
		
		i_bpsk : bpsk_symbol_converter 
			generic map (code_length  =>  code_length)
			port map ( 
						codeword_i =>  codeword_i,
						symbol_out =>  symbol_out 
			);
		
		
		i_decoder : n_32_fsm 
			generic map (
				bit_range			=> bit_range,
				data_data           => data_data    ,				 
				frozen_data         => frozen_data  ,				        
				data_frozen         => data_frozen  ,				 
				frozen_frozen       => frozen_frozen			
			)
			port map ( 
						clk                =>  clk,
						decode_en          =>  decode_en,
						llr_i              =>   llr_i         ,
						estimate_data      => estimate_data ,
						decode_op_done     =>  decode_op_done
			);
		
		u_txmem :  uart_tx_memory 
			generic map(
				c_clkfreq  		        =>  c_clkfreq  		    ,
				c_baudrate 		        =>  c_baudrate 		    ,
				c_stopbitcount          =>  c_stopbitcount      ,
				c_buffer_depth          =>  c_buffer_depth      ,
				c_buffer_data_length    =>  c_buffer_data_length,
				C_RAM_TYPE 		        =>  C_RAM_TYPE 		     
		)
		port map ( 
				clk                 => clk          ,
				data_i              => data_i       ,
				w_addr              => w_addr       ,
				write_en            => write_en     ,
				tx_state_en         => tx_state_en  ,
				tx                  => tx_o         ,
				interrupt           => interrupt      
		);

end Behavioral;
