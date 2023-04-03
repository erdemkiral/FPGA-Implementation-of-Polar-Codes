library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.my_pkg.all;


entity n_32_enc_dec_top is
    generic(

            code_length    : integer := 32; -- default
            data_length    : integer := 16;
   
            c_layer1number   : integer := 1;
            c_layer2number   : integer := 2;
            c_layer3number   : integer := 3;
            c_layer4number   : integer := 4;
            c_layer5number   : integer := 5;
		bit_range			 : integer := 64;
        data_data           : std_logic_vector(1 downto 0) := "11";				 
        frozen_data         : std_logic_vector(1 downto 0) := "01";				        
        data_frozen         : std_logic_vector(1 downto 0) := "10";				 
        frozen_frozen       : std_logic_vector(1 downto 0) := "00"				
);
 Port ( 
    clk             : in  std_logic;
    data_i          : in  std_logic_vector(data_length-1 downto 0);
    sys_en_i        : in  std_logic;
    estiamte_data   : out  std_logic_vector(data_length-1 downto 0);
    tick            : out std_logic


 );
end n_32_enc_dec_top;

architecture Behavioral of n_32_enc_dec_top is

    component polar_32_16 is
generic (
        code_length    : integer := 32; -- default
        data_length    : integer := 16;

        c_datalength     : integer := 32;
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
			bit_range			: integer  := 64;
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
    
signal polar_o         : std_logic_vector(code_length-1 downto 0);
signal polar_o_tick    : std_logic;
signal symbol_out      : int_arr(code_length -1 downto 0);

begin

i_polar_32_16 :  polar_32_16 
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
                data_vector_i   => data_i,
                encode_en_i     => sys_en_i,
                polar_o         => polar_o    , 
                polar_o_tick    => polar_o_tick
    );
    
    
    i_bpsk : bpsk_symbol_converter 
        generic map (
                    code_length  =>  code_length
        
        )
        port map ( 
                    codeword_i => polar_o,
                    symbol_out => symbol_out
        );
    
        i_n_32_fsm : n_32_fsm 
            generic map (
				bit_range			    => bit_range	,		
                data_data           	=> data_data    ,				 
                frozen_data         	=> frozen_data  ,				        
                data_frozen         	=> data_frozen  ,				 
                frozen_frozen       	=> frozen_frozen			
        )
        port map ( 
                    clk                => clk,
                    decode_en          => polar_o_tick,
                    llr_i              => symbol_out,
                    estimate_data      => estiamte_data,
                    decode_op_done     => tick         
        );














end Behavioral;
