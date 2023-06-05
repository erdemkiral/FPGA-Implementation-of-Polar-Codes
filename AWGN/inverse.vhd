----------------------------------------------------------------------------------
-- Company: 
-- Engineer: TYT
-- 
-- Create Date: 05/25/2023 11:03:26 PM
-- Design Name: 
-- Module Name: inverse - Behavioral
-- Project Name: tng
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
signal mask_in : unsigned (14 downto 0);
signal signb : std_logic; 
signal lzd_out : std_logic_vector (5 downto 0);
signal segment : std_logic_vector (7 downto 0);
signal mask, mask_out : unsigned (14 downto 0);
signal coef2,coef1 : unsigned (17 downto 0);
signal coef0 : unsigned (20 downto 0);
signal multi0 : unsigned (32 downto 0);
signal add0 : unsigned (15 downto 0);
begin

lzd_in <= TG_INPUT(63 downto 3);
ofsett <= TG_INPUT(2 downto 1);
mask_in <= UNSIGNED(TG_INPUT(17 downto 3));
signb <= TG_INPUT(0);

lzdmodule : entity work.lzd
  port map (
    data_in  => lzd_in,
    data_out => lzd_out
  );

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

madder_inst: entity work.madder
  port map (
    clk     => clk,
    rst     => rst,
    coef2   => coef2,
    coef1   => coef1,
    maddout => multi0,
    maskin  => mask_out
  );

adder_inst: entity work.adder
  port map (
    clk      => clk,
    rst      => rst,
    madderin => multi0,
    coef0    => coef0,
    addout   => add0
  );

proc_outmux: process(clk)
begin
    if rising_edge(clk) then
        if rst = '0' then
            data_out <= "0000000000000000";
        else
            case signb is
                when '0' =>
                    data_out <= SIGNED(add0);
                when '1' =>
                    data_out <= (b"1" & signed(add0(14 downto 1)) & b"1");
                when others =>
                    data_out <= "0000000000000000";
            end case;
        end if;
    end if;
end process proc_outmux;

end Behavioral;
