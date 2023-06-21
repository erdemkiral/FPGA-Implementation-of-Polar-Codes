----------------------------------------------------------------------------------
-- Company: 
-- Engineer: TYT
-- 
-- Create Date: 05/25/2023 11:03:26 PM
-- Design Name: 
-- Module Name: inverse - Behavioral
-- Project Name: tng.vc
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity inverse is
  Port (clk, rst : in std_logic; 
        TG_INPUT : in std_logic_vector (63 downto 0);
        data_out : out signed (15 downto 0));
end inverse;

architecture Behavioral of inverse is

signal lzd_in : std_logic_vector (60 downto 0);
signal ofsett : std_logic_vector (1 downto 0);
signal mask_in,mask_in2 : unsigned (14 downto 0);
signal maske1,maske2 : unsigned (15 downto 0);
signal signb : std_logic_vector (8 downto 0) := "000000000";
signal lzd_out : std_logic_vector (5 downto 0);
signal segment : std_logic_vector (7 downto 0);
signal mask, mask_out, mask_out1, mask_out2, mask_out3 : unsigned (14 downto 0);
signal coef2 : unsigned (17 downto 0);
signal coef1, coef1_1 : signed (17 downto 0);
signal coef1t : signed (36 downto 0);
signal coef0, coef0_1, coef0_2, coef0_3, coef0_4, coef0_5 : unsigned (18 downto 0);
signal multi0 : signed (37 downto 0);
signal multi1 : signed (33 downto 0);
signal add0   : signed (18 downto 0);
signal add0rnd : unsigned (14 downto 0);
signal signout : unsigned (15 downto 0);
signal unsignedout : unsigned (15 downto 0);
begin

lzd_in <= TG_INPUT(63 downto 3);

lzdmodule : entity work.lzd
  port map (
    data_in  => lzd_in,
    data_out => lzd_out
  );

  proc_maskinput: process(clk)
  begin
      if rising_edge(clk) then
        mask_in2 <= UNSIGNED(TG_INPUT(17 downto 3));
      end if;
  end process proc_maskinput;

  proc_sign: process(clk)
  begin
      if rising_edge(clk) then
        signb <= (signb(7 downto 0) & TG_INPUT(0));
      end if;
  end process proc_sign;

  proc_ofset: process(clk)
  begin
      if rising_edge(clk) then
        ofsett <= TG_INPUT(2 downto 1);
      end if;
  end process proc_ofset;

process(clk)
  begin
    if rising_edge(clk) then
        if rst = '0' then
            segment <= "00000000";
        else
            segment <= lzd_out & ofsett;
        end if;
    end if;
  end process;


  proc_maskinpipe: process(clk)
  begin
      if rising_edge(clk) then
      mask_in <= mask_in2;
      end if;
  end process proc_maskinpipe;

coef_module: entity work.coef
  port map (
    clk     => clk,
    segment => segment,
    c0      => coef0,
    c1      => coef1,
    c2      => coef2
  );

proc_mask: process(clk)
begin
    if rising_edge(clk) then
        if rst = '0' then
            mask <= "111111111111111";
        else
            case lzd_out is
                when "111101" => 
                    mask <= "111111111111111";
                when "111100" =>
                    mask <= "011111111111111";
                when "111011" => 
                    mask <= "101111111111111";
                when "111010" => 
                    mask <= "110111111111111";
                when "111001" => 
                    mask <= "111011111111111";
                when "111000" => 
                    mask <= "111101111111111";
                when "110111" => 
                    mask <= "111110111111111";
                when "110110" => 
                    mask <= "111111011111111";
                when "110101" => 
                    mask <= "111111101111111";
                when "110100" => 
                    mask <= "111111110111111";
                when "110011" => 
                    mask <= "111111111011111";
                when "110010" => 
                    mask <= "111111111101111";
                when "110001" => 
                    mask <= "111111111110111";
                when "110000" => 
                    mask <= "111111111111011";
                when "101111" => 
                    mask <= "111111111111101";
                when "101110" => 
                    mask <= "111111111111110";
                when others => 
                    mask <= "111111111111111";
            end case;
        end if;
    end if;
end process proc_mask;

proc_maskadd: process(clk)
begin
    if rising_edge(clk) then
        if rst = '0' then
            mask_out <= mask_in;
        else
            mask_out <= mask_in and mask;
        end if;
    end if;
end process proc_maskadd; 

proc_maskpipe: process(clk)
begin
    if rising_edge(clk) then
    mask_out1 <= mask_out;
    mask_out2 <= mask_out1;
    mask_out3 <= mask_out2;
    end if;
end process proc_maskpipe;

proc_coef1pipe: process(clk)
begin
    if rising_edge(clk) then
    coef1_1 <= coef1;
    end if;
end process proc_coef1pipe;

proc_coef0pipe: process(clk)
begin
    if rising_edge(clk) then
    coef0_1 <= coef0;
    coef0_2 <= coef0_1;
    coef0_3 <= coef0_2;
    coef0_4 <= coef0_3;
    coef0_5 <= coef0_4;
    end if;
end process proc_coef0pipe;

    maske1 <= (b"0" & mask_out);
    coef1t <= (coef1_1 & b"0000000000000000000");
    
madder_inst: entity work.madder
  port map (
    clk     => clk,
    coef2   => coef2,
    coef1   => coef1t,
    maddout => multi0,
    maskin  => maske1
  );
    maske2 <= (b"0" & mask_out3);
adder_inst: entity work.adder
  port map (
    clk      => clk,
    madderin => multi0(37 downto 20),
    maskin    => maske2,
    mulout   => multi1
  );

  proc_add: process(clk)
  begin
      if rising_edge(clk) then
      add0 <= signed(coef0_5)+ multi1(32 downto 19);
      end if;
  end process proc_add;

  proc_rnd: process(clk)
  begin
      if rising_edge(clk) then
      add0rnd <= unsigned(add0(17 downto 3)+ add0(2 downto 1));
      end if;
  end process proc_rnd;

  signout <= (b"0" & add0rnd);
  unsignedout <= ((b"1" & (not(add0rnd))) + b"1");
  
proc_outmux: process(clk)
begin
    if rising_edge(clk) then
            case signb(8) is
                when '0' =>
                    data_out <= signed(signout);
                when '1' =>
                    data_out <= signed(unsignedout);
                when others =>
                    data_out <= "0000000000000000";
            end case;
    end if;
end process proc_outmux;

end Behavioral;
