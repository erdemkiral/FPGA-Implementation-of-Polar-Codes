library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity awgn_out is
    Port ( clk,rst,ce : in STD_LOGIC;
           divide  : in signed(15 downto 0);
           data_out : out signed(15 downto 0)
           );
end awgn_out;

architecture outmod of awgn_out is
signal inverse_in : std_logic_vector (63 downto 0);
signal data, dataout : signed(15 downto 0);
signal clks : std_logic;
signal counter : unsigned(4 downto 0) := "00000";

begin

proc_name: process(clk)
begin
  if rising_edge(clk) then
    if counter <= "10101" then
    counter <= counter + 1;
  end if;
  end if;
end process proc_name;

proc_count: process(clk)
begin
   if counter < "10101" then
    clks <= clk;
    elsif counter >= "10110" then
      if ce = '1' then
        clks <= '1';
      elsif ce = '0' then
        clks <= '0';
      end if;
    else
      clks <= '0';
    end if;
end process proc_count;


--proc_clken: process(clk)
--begin
--  if counter >= "10101" then
--    if rising_edge(ce) then
--      clks <= clk;
--    elsif falling_edge(ce) then
--      clks <= '0';
--    end if;
--  end if;
--end process proc_clken;

tg_module: entity work.TG
  port map (
    clk  => clks,
    rst  => rst,
    data => inverse_in
  );

inverse_module: entity work.inverse
  port map (
    clk      => clks,
    rst      => rst,
    TG_INPUT => inverse_in,
    data_out => data
  );
  
  dataout <= (data / divide);
  
process(clks)
  begin
    if rising_edge(clks) then
        if rst = '0' then
        data_out <= "0000000000000000";
        else
        data_out <= dataout;
        end if;
    end if;
  end process;

end outmod;

