library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.my_pkg.all;

entity top is
    generic(
        bpsk_range          : integer := 128;
        bit_range			: integer := 4096;
        data_data           : std_logic_vector(1 downto 0) := "11";				 
        frozen_data         : std_logic_vector(1 downto 0) := "01";				        
        data_frozen         : std_logic_vector(1 downto 0) := "10";				 
        frozen_frozen       : std_logic_vector(1 downto 0) := "00";
        code_length      : integer := 32; -- default
        data_length      : integer := 16;
        c_layer1number   : integer := 1;
        c_layer2number   : integer := 2;
        c_layer3number   : integer := 3;
        c_layer4number   : integer := 4;
        c_layer5number   : integer := 5
);
port (
            clk,rst   : in std_logic;
            en        : in std_logic;
            data      : in std_logic_vector(15 downto 0);
            divider   : in std_logic_vector(15 downto 0);
            estimate  : out std_logic_vector(15 downto 0);
            noise     : out std_logic_vector(15 downto 0);
            symbol    : out std_logic_vector(15 downto 0);
            interrupt : out std_logic

 );
end top;

architecture Behavioral of top is


    component bpsk_symbol_converter is
        generic (
                    code_length : integer := 4;
                    bpsk_range  : integer := 1024
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


        component awgn_gen is
            Port ( 
            
                    clk       : in std_logic;
                    rst       : in std_logic;
                    awgndata  : in signed(15 downto 0);
                    bpsk_i    : in int_arr(31 downto 0);
                    channel_o : out int_arr(31 downto 0)
            
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



    signal        polar_o         : std_logic_vector(code_length-1 downto 0);
     signal  polar_o_tick    :  std_logic;
     signal tick : std_logic := '1';
     signal encodeen : std_logic := '0';
     signal decdone : std_logic  := '0';
     signal symbol_out :  int_arr(code_length -1 downto 0);
     signal channel_out :  int_arr(code_length -1 downto 0);
     signal awgndata : signed(15 downto 0);
signal  decode_en    :  std_logic;

begin
    noise <= std_logic_vector(awgndata);
    symbol <= std_logic_vector(to_signed(symbol_out(0), symbol'length));
    
    i_polar_32_16 : polar_32_16 
        generic map (
                code_length      => code_length   , -- default
                data_length      => data_length   ,
                c_layer1number   => c_layer1number,
                c_layer2number   => c_layer2number,
                c_layer3number   => c_layer3number,
                c_layer4number   => c_layer4number,
                c_layer5number   => c_layer5number
        )
        port map  ( 
                    clk             => clk,
                    data_vector_i   => data,
                    encode_en_i     => encodeen,
                    polar_o         => polar_o,
                    polar_o_tick    => polar_o_tick
        );

        awgn_out_inst: entity work.awgn_out
          port map (
            clk      => clk,
            ce       => polar_o_tick,
            rst      => rst,
            divide   => signed(divider),
            data_out => awgndata
          );
          

        i_bpsk_symbol_converter : bpsk_symbol_converter 
            generic map(
                        code_length => code_length,
                        bpsk_range  => bpsk_range
            )
            port map ( 
                        codeword_i => polar_o,
                        symbol_out => symbol_out
            );
       

                
        i_awgn_gen : awgn_gen 
            Port map( 
            
                    clk      => clk,
                    rst       => rst,
                    awgndata  => awgndata,
                    bpsk_i    => symbol_out,
                    channel_o  => channel_out
            
            );
        
            i_n_32_fsm :  n_32_fsm 
                generic map (
                    bit_range			=> bit_range	,
                    data_data           => data_data    ,			 
                    frozen_data         => frozen_data  ,			        
                    data_frozen         => data_frozen  ,			 
                    frozen_frozen       => frozen_frozen			
            )
            port map ( 
                        clk               => clk          ,
                        decode_en         => decode_en ,
                        llr_i             => channel_out  ,
                        estimate_data     => estimate     ,
                        decode_op_done    => decdone
            );
            
		    process (clk)
		    begin
		    if en = '1' then
			encodeen <= decdone or tick;
			tick <= '0';
			elsif en = '0' then
			encodeen <= '0';
			tick <= '1';
			end if;
			end process;
			
			interrupt <= decdone;
			
		     process (clk)
            begin
                if rising_edge(clk) then

                    if polar_o_tick = '1' then
                        decode_en <= '1';
                    else 
                        decode_en <= '0';
                    end if;
                    
                end if;
            end process;
        


end Behavioral;
