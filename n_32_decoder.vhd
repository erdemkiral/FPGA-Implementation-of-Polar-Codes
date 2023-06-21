library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.my_pkg.all;


entity n_32_decoder is
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
end n_32_decoder;

architecture Behavioral of n_32_decoder is

    component LLR_16 is
		generic(
			bit_range : integer := 64
		);
        port ( 
                llr_16  	         : in  int_arr(15 downto 0);
                belief_left_data_i   : in  std_logic_vector(7 downto 0);
                belief_right_data_i  : in  std_logic_vector(7 downto 0);
                transfer_vector_o	 : out std_logic_vector(15 downto 0);
                layer_left_o 	 	 : out int_arr(7 downto 0);
                layer_right_o 	 	 : out int_arr(7 downto 0)
        );
    end component;

    component LLR_8 is
		generic(
			bit_range : integer := 64
		);
        port ( 
                llr_8  	             : in  int_arr(7 downto 0);
                belief_left_data_i   : in  std_logic_vector(3 downto 0);
                belief_right_data_i  : in  std_logic_vector(3 downto 0);
                transfer_vector_o	 : out std_logic_vector(7 downto 0);
                layer_left_o 	 	 : out int_arr(3 downto 0);
                layer_right_o 	 	 : out int_arr(3 downto 0)
        );
    end component;
  
    component depth_1 is
		generic(
			bit_range : integer := 64
		);
        port ( 
                data_depth1_i  	     : in  int_arr(3 downto 0);
                belief_left_data_i   : in  std_logic_vector(1 downto 0);
                belief_right_data_i  : in  std_logic_vector(1 downto 0);
                transfer_vector_o	 : out std_logic_vector(3 downto 0);
                layer_left_o 	 	 : out int_arr(1 downto 0);
                layer_right_o 	 	 : out int_arr(1 downto 0)
        );
    end component;


    component g_2_block is
        generic(
				bit_range : integer := 64;
                leaf_node_type  : std_logic_vector(1 downto 0) := "00"				    -- "00" frozen position & frozen position 
                -- leaf_node_type  : std_logic_vector(1 downto 0) := "01"				-- "01" frozen position & data position 
                -- leaf_node_type  : std_logic_vector(1 downto 0) := "10"				-- "10"  data           & frozen position 
                -- leaf_node_type  : std_logic_vector(1 downto 0) := "11"				-- "11"  data position   & data position 
        );
        port ( 
                data_1_i     : in integer range -bit_range to bit_range;
                data_2_i     : in integer range -bit_range to bit_range;
                transfer_o   : out std_logic_vector(1 downto 0);
                layer_o 	 : out int_arr(1 downto 0);
                leaf_node_o  : out std_logic_vector(1 downto 0)
        );
    end component;

	component minsum is
		generic(
			bit_range : integer := 64
		);
	port ( 
			belief1      : in  integer range -bit_range to bit_range;
			belief2      : in  integer range -bit_range to bit_range;
			min_sum_o    : out integer range -bit_range to bit_range
	);
	end component;
	
	component g_function is
		generic(
			bit_range : integer := 64
		);
	port ( 
			in_1  : in integer range -bit_range to bit_range;
			in_2  : in integer range -bit_range to bit_range;
			in_3  : in std_logic;
			g_out : out integer range -bit_range to bit_range
	);
	end component;


signal depth_5_input              : int_arr(31 downto 0) := (others => 0) ;  -- 2 Bitlik işlem
signal depth_5transfer_vector     : std_logic_vector(31 downto 0) := (others => '0') ;
signal depth_5layer_o             : int_arr(31 downto 0) := (others => 0) ;
signal depth_5estimate            : std_logic_vector(31 downto 0):= (others => '0') ;

signal  data_depth4_i  	             : int_arr(31 downto 0) := (others => 0) ; -- 4 Bitlik işlem
signal  depth_4belief_left_data_i    : std_logic_vector(15 downto 0) := (others => '0');
signal  depth_4belief_right_data_i   : std_logic_vector(15 downto 0) := (others => '0');
signal  depth_4transfer_vector_o	 : std_logic_vector(31 downto 0):= (others => '0') ;
signal  depth_4layer_o 	 	         : int_arr(31 downto 0) := (others => 0) ;


signal  data_depth3_i  	             : int_arr(31 downto 0) := (others => 0) ; -- 8 Bitlik işlem
signal  depth3_belief_left_data_i    : std_logic_vector(15 downto 0) := (others => '0') ;
signal  depth3_belief_right_data_i   : std_logic_vector(15 downto 0) := (others => '0') ;
signal  depth3_transfer_vector_o	 : std_logic_vector(31 downto 0) := (others => '0') ;
signal  depth3_layer_o 	 	         : int_arr(31 downto 0) := (others => 0) ;

signal data_depth2_i  	             : int_arr(31 downto 0) := (others => 0) ; -- 16 Bitlik işlem
signal depth2_belief_left_data_i     : std_logic_vector(15 downto 0) := (others => '0') ;
signal depth2_belief_right_data_i    : std_logic_vector(15 downto 0) := (others => '0') ;
signal depth2_transfer_vector_o	     : std_logic_vector(31 downto 0) := (others => '0') ;
signal depth2_layer_o 	 	         : int_arr(31 downto 0) := (others => 0) ;

signal data_depth1_i  	             : int_arr(31 downto 0) := (others => 0) ;
signal depth1_belief_left_data_i     : std_logic_vector(15 downto 0) := (others => '0') ;
signal depth1_layer_o 	 	         : int_arr(31 downto 0) := (others => 0) ;

begin

    P_PIPELINE : process (clk)
    begin
        if rising_edge(clk) then

            data_depth1_i <= channel_llr_i;
            data_depth2_i(31 downto 16) <= depth1_layer_o(31 downto 16);
            data_depth3_i(31 downto 24)  <= depth2_layer_o(31 downto 24);
            data_depth4_i(31 downto 28) <= depth3_layer_o(31 downto 28);
            depth_5_input(31 downto 30) <= depth_4layer_o(31 downto 30);

            depth_4belief_left_data_i (15 downto 14) <= depth_5transfer_vector(31 downto 30);

            depth_5_input(29 downto 28) <= depth_4layer_o(29 downto 28);

            depth_4belief_right_data_i (15 downto 14) <= depth_5transfer_vector(29 downto 28);
            depth3_belief_left_data_i(15 downto 12) <= depth_4transfer_vector_o(31 downto 28);

            data_depth4_i(27 downto 24) <= depth3_layer_o (27 downto 24);
            depth_5_input(27 downto 26) <= depth_4layer_o(27 downto 26);

            depth_4belief_left_data_i (13 downto 12) <= depth_5transfer_vector(27 downto 26);
            depth_5_input(25 downto 24) <= depth_4layer_o(25 downto 24);
            depth_4belief_right_data_i(13 downto 12) <= depth_5transfer_vector(25 downto 24);
            depth3_belief_right_data_i(15 downto 12) <= depth_4transfer_vector_o(27 downto 24);
            depth2_belief_left_data_i (15 downto 8) <= depth3_transfer_vector_o(31 downto 24);

            data_depth3_i(23 downto 16) <= depth2_layer_o(23 downto 16);
            data_depth4_i(23 downto 20) <= depth3_layer_o(23 downto 20);
            depth_5_input(23 downto 22)  <= depth_4layer_o(23 downto 22);

            depth_4belief_left_data_i (11 downto 10) <= depth_5transfer_vector(23 downto 22);
            depth_5_input(21 downto 20) <= depth_4layer_o(21 downto 20);
            depth_4belief_right_data_i(11 downto 10) <= depth_5transfer_vector(21 downto 20);
            depth3_belief_left_data_i(11 downto 8) <= depth_4transfer_vector_o(23 downto 20);
            data_depth4_i(19 downto 16) <= depth3_layer_o (19 downto 16);
            depth_5_input(19 downto 18) <= depth_4layer_o(19 downto 18);
            depth_4belief_left_data_i (9 downto 8) <= depth_5transfer_vector(19 downto 18);
            depth_5_input(17 downto 16) <=depth_4layer_o(17 downto 16);
            depth_4belief_right_data_i(9 downto 8) <= depth_5transfer_vector(17 downto 16);
            depth3_belief_right_data_i(11 downto 8) <= depth_4transfer_vector_o(19 downto 16);
            depth2_belief_right_data_i(15 downto 8) <= depth3_transfer_vector_o(23 downto 16);

            data_depth1_i <= channel_llr_i;
            depth1_belief_left_data_i <= depth2_transfer_vector_o(31 downto 16);

            data_depth2_i(15 downto 0) <= depth1_layer_o(15 downto 0);
            data_depth3_i(15 downto 8) <= depth2_layer_o(15 downto 8);
            data_depth4_i(15 downto 12) <= depth3_layer_o(15 downto 12);
            depth_5_input(15 downto 14) <= depth_4layer_o(15 downto 14);
            depth_4belief_left_data_i (7 downto 6) <= depth_5transfer_vector(15 downto 14);
            depth_5_input(13 downto 12) <= depth_4layer_o(13 downto 12);
            depth_4belief_right_data_i(7 downto 6) <= depth_5transfer_vector(13 downto 12);
            depth3_belief_left_data_i(7 downto 4) <= depth_4transfer_vector_o(15 downto 12);
            data_depth4_i(11 downto 8) <= depth3_layer_o (11 downto 8);
            depth_5_input(11 downto 10) <=  depth_4layer_o(11 downto 10);
            depth_4belief_left_data_i (5 downto 4) <= depth_5transfer_vector(11 downto 10);

            depth_5_input(9 downto 8) <= depth_4layer_o(9 downto 8);
            depth_4belief_right_data_i(5 downto 4) <= depth_5transfer_vector(9 downto 8);
            depth3_belief_right_data_i(7 downto 4) <=depth_4transfer_vector_o(11 downto 8);
            depth2_belief_left_data_i (7 downto 0) <= depth3_transfer_vector_o(15 downto 8);
            data_depth3_i(7 downto 0) <= depth2_layer_o(7 downto 0);
            data_depth4_i(7 downto 4) <= depth3_layer_o(7 downto 4);
            depth_5_input(7 downto 6) <= depth_4layer_o(7 downto 6);
            depth_4belief_left_data_i (3 downto 2) <= depth_5transfer_vector(7 downto 6);
            depth_5_input(5 downto 4) <= depth_4layer_o(5 downto 4);
            depth_4belief_right_data_i(3 downto 2) <= depth_5transfer_vector(5 downto 4);
            depth3_belief_left_data_i(3 downto 0) <= depth_4transfer_vector_o(7 downto 4);
            data_depth4_i(3 downto 0) <= depth3_layer_o (3 downto 0);
            depth_5_input(3 downto 2) <= depth_4layer_o(3 downto 2);
            depth_4belief_left_data_i (1 downto 0) <= depth_5transfer_vector(3 downto 2);
            depth_5_input(1 downto 0) <= depth_4layer_o(1 downto 0);

        end if;
    end process P_PIPELINE;

 
 --SOL KISIM

 i_min_gen  : for i in 0 to 15 generate
    i_min : minsum
		generic map( bit_range => bit_range)
    port map ( 
            belief1    =>  data_depth1_i (i+16),
            belief2    =>  data_depth1_i (i),
            min_sum_o  =>  depth1_layer_o (i+16)   
    );
end generate;

    depth_2_left_llr_16 : LLR_16
		generic map( bit_range => bit_range)
    port map ( 
            llr_16  	         => data_depth2_i(31 downto 16),
            belief_left_data_i   => depth2_belief_left_data_i (15 downto 8),
            belief_right_data_i  => depth2_belief_right_data_i(15 downto 8),
            transfer_vector_o	 => depth2_transfer_vector_o(31 downto 16),
            layer_left_o 	 	 => depth2_layer_o(31 downto 24),
            layer_right_o 	 	 => depth2_layer_o(23 downto 16)
    );
     
    d_3_1 : LLR_8 
		generic map( bit_range => bit_range)
        port map  ( 
                llr_8  	             => data_depth3_i(31 downto 24),
                belief_left_data_i   => depth3_belief_left_data_i(15 downto 12),
                belief_right_data_i  => depth3_belief_right_data_i(15 downto 12),
                transfer_vector_o	 => depth3_transfer_vector_o(31 downto 24),
                layer_left_o 	 	 => depth3_layer_o(31 downto 28),
                layer_right_o 	 	 => depth3_layer_o (27 downto 24)           
            );
    


    d_4_1 : depth_1 
		generic map( bit_range => bit_range)
    port map ( 
            data_depth1_i  	     => data_depth4_i(31 downto 28), 
            belief_left_data_i   => depth_4belief_left_data_i (15 downto 14),
            belief_right_data_i  => depth_4belief_right_data_i(15 downto 14),
            transfer_vector_o	 => depth_4transfer_vector_o(31 downto 28)	 , 
            layer_left_o 	 	 => depth_4layer_o(31 downto 30),
            layer_right_o 	 	 => depth_4layer_o(29 downto 28)
    );
    


    d_4u1 : g_2_block generic map (bit_range => bit_range, leaf_node_type => frozen_frozen)
        port map (  data_1_i    =>depth_5_input(31),  data_2_i =>depth_5_input(30),  transfer_o =>depth_5transfer_vector(31 downto 30),layer_o => depth_5layer_o(31 downto 30), leaf_node_o  =>estimate(31 downto 30) );
     
    d_4u2 : g_2_block generic map (bit_range => bit_range, leaf_node_type => frozen_frozen)
        port map (  data_1_i =>depth_5_input(29),  data_2_i =>depth_5_input(28), transfer_o =>depth_5transfer_vector(29 downto 28), layer_o => depth_5layer_o(29 downto 28), leaf_node_o  =>estimate(29 downto 28) );

    d_4_2 : depth_1 
		generic map( bit_range => bit_range)
    port map ( 
        data_depth1_i  	     => data_depth4_i(27 downto 24), 
        belief_left_data_i   => depth_4belief_left_data_i (13 downto 12),
        belief_right_data_i  => depth_4belief_right_data_i(13 downto 12),
        transfer_vector_o	 => depth_4transfer_vector_o(27 downto 24)	 , 
        layer_left_o 	 	 => depth_4layer_o(27 downto 26),
        layer_right_o 	 	 => depth_4layer_o(25 downto 24)
    );

    d_4u3 : g_2_block generic map (bit_range => bit_range, leaf_node_type => frozen_frozen)
        port map (data_1_i    =>depth_5_input(27),  data_2_i =>depth_5_input(26),   transfer_o =>depth_5transfer_vector(27 downto 26),layer_o => depth_5layer_o(27 downto 26),leaf_node_o  =>estimate(27 downto 26) );

    d_4u4 : g_2_block generic map (bit_range => bit_range, leaf_node_type => frozen_data)
         port map (data_1_i    =>depth_5_input(25),  data_2_i =>depth_5_input(24),  transfer_o =>depth_5transfer_vector(25 downto 24),layer_o => depth_5layer_o(25 downto 24),leaf_node_o  =>estimate(25 downto 24));
    


    d_3_2 : LLR_8
	generic map( bit_range => bit_range)
    port map  ( 
            llr_8  	             => data_depth3_i(23 downto 16),
            belief_left_data_i   => depth3_belief_left_data_i(11 downto 8),
            belief_right_data_i  => depth3_belief_right_data_i(11 downto 8),
            transfer_vector_o	 => depth3_transfer_vector_o(23 downto 16),
            layer_left_o 	 	 => depth3_layer_o(23 downto 20),
            layer_right_o 	 	 => depth3_layer_o (19 downto 16)           
        );

     d_4_3 : depth_1 
	 	generic map( bit_range => bit_range)
     port map ( 
         data_depth1_i  	    => data_depth4_i(23 downto 20), 
         belief_left_data_i     => depth_4belief_left_data_i (11 downto 10),
         belief_right_data_i    => depth_4belief_right_data_i(11 downto 10),
         transfer_vector_o	    => depth_4transfer_vector_o(23 downto 20)	 , 
         layer_left_o 	 	    => depth_4layer_o(23 downto 22),
         layer_right_o 	 	    => depth_4layer_o(21 downto 20)
     );

     d_4u5 : g_2_block generic map (bit_range => bit_range, leaf_node_type => frozen_frozen)
        port map ( data_1_i    =>depth_5_input(23),  data_2_i =>depth_5_input(22),   transfer_o =>depth_5transfer_vector(23 downto 22),layer_o => depth_5layer_o(23 downto 22),leaf_node_o  =>estimate(23 downto 22));

    d_4u6 : g_2_block generic map (bit_range => bit_range, leaf_node_type => frozen_data)
        port map ( data_1_i    =>depth_5_input(21),  data_2_i =>depth_5_input(20), transfer_o =>depth_5transfer_vector(21 downto 20),layer_o => depth_5layer_o(21 downto 20),leaf_node_o  =>estimate(21 downto 20));
    
    d_4_4 : depth_1 
		generic map( bit_range => bit_range)
        port map ( 
            data_depth1_i  	       => data_depth4_i(19 downto 16), 
            belief_left_data_i     => depth_4belief_left_data_i (9 downto 8),
            belief_right_data_i    => depth_4belief_right_data_i(9 downto 8),
            transfer_vector_o	   => depth_4transfer_vector_o(19 downto 16), 
            layer_left_o 	 	   => depth_4layer_o(19 downto 18),
            layer_right_o 	 	   => depth_4layer_o(17 downto 16)
        );


    d_4u7 : g_2_block generic map (bit_range => bit_range, leaf_node_type => frozen_data)
        port map (data_1_i    =>depth_5_input(19),  data_2_i =>depth_5_input(18), transfer_o =>depth_5transfer_vector(19 downto 18),layer_o => depth_5layer_o(19 downto 18),leaf_node_o  =>estimate(19 downto 18));

    d_4u8 : g_2_block generic map (bit_range => bit_range, leaf_node_type => data_data)
        port map (  data_1_i    =>depth_5_input(17),  data_2_i =>depth_5_input(16),  transfer_o =>depth_5transfer_vector(17 downto 16),layer_o => depth_5layer_o(17 downto 16),leaf_node_o =>estimate(17 downto 16));



        i_g_gen  : for i in 0 to 15 generate
            i_g : g_function 
            generic map ( bit_range => bit_range)
            port map ( 
                    in_1  => data_depth1_i(i+16),
                    in_2  => data_depth1_i(i),
                    in_3  => depth1_belief_left_data_i(i),
                    g_out => depth1_layer_o(i)
            );
        end generate;
        
    
    
    
        depth_2_right_llr_16 : LLR_16 
            generic map ( bit_range => bit_range)
            port map ( 
                    llr_16  	         => data_depth2_i(15 downto 0),
                    belief_left_data_i   => depth2_belief_left_data_i (7 downto 0),
                    belief_right_data_i  => depth2_belief_right_data_i(7 downto 0),
                    transfer_vector_o	 => depth2_transfer_vector_o(15 downto 0),
                    layer_left_o 	 	 => depth2_layer_o(15 downto 8),
                    layer_right_o 	 	 => depth2_layer_o(7 downto 0)
            );
        
        d_3_3 :  LLR_8
        generic map ( bit_range => bit_range)
        port map  ( 
            llr_8  	             => data_depth3_i(15 downto 8),
            belief_left_data_i   => depth3_belief_left_data_i(7 downto 4),
            belief_right_data_i  => depth3_belief_right_data_i(7 downto 4),
            transfer_vector_o	 => depth3_transfer_vector_o(15 downto 8),
            layer_left_o 	 	 => depth3_layer_o(15 downto 12),
            layer_right_o 	 	 => depth3_layer_o (11 downto 8)           
        );
        
        d_4_5 : depth_1
        generic map ( bit_range => bit_range)
        port map ( 
            data_depth1_i  	       => data_depth4_i(15 downto 12), 
            belief_left_data_i     => depth_4belief_left_data_i (7 downto 6),
            belief_right_data_i    => depth_4belief_right_data_i(7 downto 6),
            transfer_vector_o	   => depth_4transfer_vector_o(15 downto 12), 
            layer_left_o 	 	   => depth_4layer_o(15 downto 14),
            layer_right_o 	 	   => depth_4layer_o(13 downto 12)
        );
    
    
    
            d_4u9 : g_2_block generic map ( bit_range => bit_range, leaf_node_type => frozen_frozen)
                port map (  data_1_i    =>depth_5_input(15),  data_2_i =>depth_5_input(14),  transfer_o =>depth_5transfer_vector(15 downto 14),layer_o => depth_5layer_o(15 downto 14), leaf_node_o  =>estimate(15 downto 14) );
             
            d_4u10 : g_2_block generic map (bit_range => bit_range, leaf_node_type => frozen_data)
                port map (  data_1_i =>depth_5_input(13),  data_2_i =>depth_5_input(12), transfer_o =>depth_5transfer_vector(13 downto 12), layer_o => depth_5layer_o(13 downto 12), leaf_node_o  =>estimate(13 downto 12) );
            
            
    
    
            d_4_6 : depth_1
            generic map ( bit_range => bit_range)
            port map ( 
                data_depth1_i  	       => data_depth4_i(11 downto 8), 
                belief_left_data_i     => depth_4belief_left_data_i (5 downto 4),
                belief_right_data_i    => depth_4belief_right_data_i(5 downto 4),
                transfer_vector_o	   => depth_4transfer_vector_o(11 downto 8), 
                layer_left_o 	 	   => depth_4layer_o(11 downto 10),
                layer_right_o 	 	   => depth_4layer_o(9 downto 8)
            );
    
    
            d_4u11 : g_2_block generic map (bit_range => bit_range, leaf_node_type => frozen_data)
                port map (data_1_i    =>depth_5_input(11),  data_2_i =>depth_5_input(10),   transfer_o =>depth_5transfer_vector(11 downto 10),layer_o => depth_5layer_o(11 downto 10),leaf_node_o  =>estimate(11 downto 10) );
        
            d_4u12 : g_2_block generic map (bit_range => bit_range, leaf_node_type => data_data)
                 port map (data_1_i    =>depth_5_input(9),  data_2_i =>depth_5_input(8),  transfer_o =>depth_5transfer_vector(9 downto 8),layer_o => depth_5layer_o(9 downto 8),leaf_node_o  =>estimate(9 downto 8));
                
                 d_3_4 : LLR_8
                 generic map ( bit_range => bit_range)
                 port map  ( 
                     llr_8  	          => data_depth3_i(7 downto 0),
                     belief_left_data_i   => depth3_belief_left_data_i(3 downto 0),
                     belief_right_data_i  => depth3_belief_right_data_i(3 downto 0),
                     transfer_vector_o	  => depth3_transfer_vector_o(7 downto 0),
                     layer_left_o 	 	  => depth3_layer_o(7 downto 4),
                     layer_right_o 	 	  => depth3_layer_o (3 downto 0)           
                 );
         
    
    
             d_4_7 : depth_1
             generic map ( bit_range => bit_range)
             port map ( 
                 data_depth1_i  	   => data_depth4_i(7 downto 4), 
                 belief_left_data_i    => depth_4belief_left_data_i (3 downto 2),
                 belief_right_data_i   => depth_4belief_right_data_i(3 downto 2),
                 transfer_vector_o	   => depth_4transfer_vector_o(7 downto 4), 
                 layer_left_o 	 	   => depth_4layer_o(7 downto 6),
                 layer_right_o 	 	   => depth_4layer_o(5 downto 4)
             );
    
             d_4u13 : g_2_block generic map (bit_range => bit_range, leaf_node_type => frozen_data)
                port map ( data_1_i    =>depth_5_input(7),  data_2_i =>depth_5_input(6),   transfer_o =>depth_5transfer_vector(7 downto 6),layer_o => depth_5layer_o(7 downto 6),leaf_node_o  =>estimate(7 downto 6));
        
            d_4u14 : g_2_block generic map (bit_range => bit_range, leaf_node_type => data_data)
                port map ( data_1_i    =>depth_5_input(5),  data_2_i =>depth_5_input(4), transfer_o =>depth_5transfer_vector(5 downto 4),layer_o => depth_5layer_o(5 downto 4), leaf_node_o  =>estimate(5 downto 4));
            
    
    
             d_4_8 : depth_1
             generic map ( bit_range => bit_range)
             port map ( 
                 data_depth1_i  	   => data_depth4_i(3 downto 0), 
                 belief_left_data_i    => depth_4belief_left_data_i (1 downto 0),
                 belief_right_data_i   => depth_4belief_right_data_i(1 downto 0),
                 transfer_vector_o	   => depth_4transfer_vector_o(3 downto 0), 
                 layer_left_o 	 	   => depth_4layer_o(3 downto 2),
                 layer_right_o 	 	   => depth_4layer_o(1 downto 0)
             );
    
    
    
            d_4u15 : g_2_block generic map (bit_range => bit_range, leaf_node_type => data_data)
                port map (data_1_i    =>depth_5_input(3),  data_2_i =>depth_5_input(2), transfer_o =>depth_5transfer_vector(3 downto 2),layer_o => depth_5layer_o(3 downto 2), leaf_node_o  =>estimate(3 downto 2));
        
            d_4u16 : g_2_block generic map (bit_range => bit_range, leaf_node_type => data_data)
                port map (  data_1_i    =>depth_5_input(1),  data_2_i =>depth_5_input(0),  transfer_o =>depth_5transfer_vector(1 downto 0),layer_o => depth_5layer_o(1 downto 0),leaf_node_o =>estimate(1 downto 0));



end Behavioral;
