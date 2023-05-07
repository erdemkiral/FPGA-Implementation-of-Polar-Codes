library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity polar_32_16 is
generic (
        code_length    : integer := 32; -- default
        data_length    : integer := 16;
		
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
end polar_32_16;

architecture Behavioral of polar_32_16 is

    component data_to_input_vector is
        generic (
                    code_length    : integer := 32; -- default
                    data_length    : integer := 16
        );
        port ( 
                    clk : in std_logic;
                    data_i : in std_logic_vector(15 downto 0);
                    vector_en : in std_logic;
                    input_vector_o : out std_logic_vector(31 downto 0);
                    vector_o_done  : out std_logic
        );
        end component;

        component n_bit_layer1 is
			generic (
				c_datalength     : integer := 32; -- can be configured
				c_layernumber1   : integer := 1   -- must stay as constant !!
			);
        port ( 
        
            lay1_data_i   : in  std_logic_vector(31 downto 0);
            sys_en_i   : in  std_logic;
            lay1_out : out std_logic_vector(31 downto 0)
        
        );
        end component;

        component n_bit_layer2 is
			generic (
				c_datalength    : integer := 32; -- can  be configured
				c_layernumber2   : integer := 2   -- must stay as constant !!
		);
            port ( 
        
                lay2_data_i   : in  std_logic_vector(c_datalength -1 downto 0);
                sys_en_i   : in  std_logic;
                lay2_out : out std_logic_vector(c_datalength -1  downto 0)
            
            );
        end component;

        component n_bit_layer3 is
			generic (
				c_datalength    : integer := 32; -- can be configured 8 16 32 64 128 256 512 1024 
				c_layernumber3   : integer := 3   -- must stay as constant !!
			);
          port (
                      lay3_data_i   : in std_logic_vector(c_datalength -1 downto 0);
                      lay3_sys_en_i : in std_logic;
                      lay_3_data_o  : out std_logic_vector(c_datalength -1 downto 0)
          );
        end component;


          component n_bit_layer4 is
			generic(
					
						c_datalength  : integer := 32;
						c_layernumber4 : integer := 4
			);
          port ( 
                    lay_4_data_i : in std_logic_vector( c_datalength -1 downto 0 );
                    lay_4_sys_en : in std_logic;
                    lay_4_data_o : out std_logic_vector(c_datalength -1 downto 0)
            
            
            );
            end component;


            component n_bit_layer5 is
				generic (
							c_datalength    : integer := 32; -- can be configured
							c_layernumber5   : integer := 5   -- must stay as constant !!
				);
            port (  
                lay_5_data_i : in std_logic_vector( c_datalength -1 downto 0 );
                lay_5_sys_en : in std_logic;
                lay_5_data_o : out std_logic_vector(c_datalength -1 downto 0)
            );
            end component;


--------------COMPONENT INSTANTIATION SIGNALS-------------

signal data_i         :  std_logic_vector(15 downto 0) := (others => '0') ;
signal vector_en      :  std_logic := '0';
signal input_vector_o :  std_logic_vector(31 downto 0) := (others => '0') ;
signal vector_o_done  :  std_logic;
--LAYER 1
signal lay1_data_i	:  std_logic_vector(31 downto 0) := (others => '0');
signal sys_en_i   	:   std_logic := '0';
signal lay1_out   	:  std_logic_vector(31 downto 0) := (others => '0');
-- LAYER 2
signal lay2_data_i   :  std_logic_vector(code_length -1 downto 0) := (others => '0');
signal lay2sys_en_i  :  std_logic := '0';
signal lay2_out 	  :  std_logic_vector(code_length -1  downto 0) := (others => '0');
--LAYER3
signal lay3_data_i    :  std_logic_vector(code_length -1 downto 0) := (others => '0');
signal lay3_sys_en_i  :  std_logic := '0';
signal lay_3_data_o   :  std_logic_vector(code_length -1  downto 0) := (others => '0');
--LAYER4
signal lay_4_data_i  :  std_logic_vector(code_length -1 downto 0) := (others => '0');
signal lay_4_sys_en  :  std_logic := '0';
signal lay_4_data_o  :  std_logic_vector(code_length -1  downto 0) := (others => '0');
-- LAYER5
signal lay_5_data_i :  std_logic_vector(code_length -1 downto 0) := (others => '0');
signal lay_5_sys_en :  std_logic := '0';
signal lay_5_data_o :  std_logic_vector(code_length -1  downto 0) := (others => '0');
-------------------------------------------------------------------------------------

-----------------PROGRAM SIGNALS------------------

type states is (S_IDLE,S_DATA,S_PROCESS,S_DONE);
signal state : states ;

signal internalcntr : integer range 0 to 7 :=  0;
signal process_en   : std_logic := '0';



begin


P_MAIN : process (clk) begin
 if rising_edge(clk) then
            
    case state is

        when S_IDLE =>

		vector_en <= '0';
		polar_o_tick <= '0';
		process_en <= '0';
		internalcntr <= 0;
		polar_o <= (others => '0');

		    if encode_en_i = '1' then
			data_i <= data_vector_i;
			vector_en <= '1';
			state <= S_DATA;
		    else 
			state <= S_IDLE;               
		    end if;
        
        when S_DATA =>

            if vector_o_done = '1' then
                lay1_data_i <= input_vector_o;
                process_en <= '1';
                internalcntr <= 0;
                state <= S_PROCESS;
                vector_en <= '0';
            else 
                state <= S_DATA;
            end if;

        when S_PROCESS =>

            if process_en = '1' then
                
                if internalcntr = 0 then

                    sys_en_i <= '1';
                    lay2_data_i <= lay1_out;
                    internalcntr <= 1;

                elsif internalcntr = 1 then

                    lay2sys_en_i <= '1';
                    lay2_data_i <= lay1_out;
                    internalcntr <= 2;

                elsif internalcntr = 2 then    

                    lay3_sys_en_i <= '1';
                    lay3_data_i <= lay2_out;
                    internalcntr <= 3;

                elsif internalcntr = 3 then

                    lay_4_sys_en <= '1';
                    lay_4_data_i <= lay_3_data_o;
                    internalcntr <= 4;

                elsif internalcntr = 4 then
		    lay_5_sys_en <= '1';
                    lay_5_data_i <= lay_4_data_o;
		    internalcntr <= 5;
					
		elsif internalcntr = 5 then
			polar_o <= lay_5_data_o;
			polar_o_tick <= '1';
                    state <= S_DONE;
                end if;

            else 
                state <= S_PROCESS;
            end if;
        
        when S_DONE =>
                sys_en_i <= '0';
                lay2sys_en_i <= '0';
                lay3_sys_en_i <= '0';
                lay_4_sys_en <= '0';
                lay_5_sys_en <= '0';
                state <= S_IDLE;
    end case;


end if; 
end process  P_MAIN;


    u1 : data_to_input_vector 
        generic map (
                    code_length    => code_length, -- default
                    data_length    => data_length
        )
        port map ( 
                    clk  => clk ,
                    data_i => data_i,
                    vector_en => vector_en,
                    input_vector_o => input_vector_o,
                    vector_o_done  => vector_o_done
        );
   
        u2 : n_bit_layer1 
            generic map (
                c_datalength    => code_length, -- can be configured
                c_layernumber1   => c_layer1number-- must stay as constant !!
        )
        port map ( 
        
            lay1_data_i => lay1_data_i  ,
            sys_en_i   	=> sys_en_i   	,
            lay1_out 	=> lay1_out 	
        
        );
       
	    u3 : n_bit_layer2 
            generic map (
                c_datalength   => code_length,   -- can be configured
                c_layernumber2  => c_layer2number -- must stay as constant !!
         )
            port map ( 
        
                lay2_data_i => lay2_data_i,
                sys_en_i   	=> lay2sys_en_i  ,
                lay2_out 	=> lay2_out 	
            
            );
    
		
		
		u4 : n_bit_layer3 
            generic  map (
              c_datalength   => code_length,    -- can be configured to 32 64 128 256 512 1024 
              c_layernumber3  => c_layer3number -- must stay as constant !!
          )
          port map  (
                      lay3_data_i   => lay3_data_i   ,
                      lay3_sys_en_i => lay3_sys_en_i ,
                      lay_3_data_o  => lay_3_data_o 
          );
          


          u5 : n_bit_layer4 
            generic map (
                        c_layernumber4 => c_layer4number,
                        c_datalength  => code_length 
                        
            )
            port map ( 
                    lay_4_data_i  => lay_4_data_i,
                    lay_4_sys_en  => lay_4_sys_en,
                    lay_4_data_o  => lay_4_data_o
           
            );


            u6 : n_bit_layer5 
             generic map (
                            c_datalength    => code_length,   -- can be configured
                            c_layernumber5   => c_layer5number -- must stay as constant !!
                )
            port map (  
                lay_5_data_i =>  lay_5_data_i  ,
                lay_5_sys_en =>  lay_5_sys_en  ,
                lay_5_data_o =>  lay_5_data_o
            );
          

end Behavioral;
