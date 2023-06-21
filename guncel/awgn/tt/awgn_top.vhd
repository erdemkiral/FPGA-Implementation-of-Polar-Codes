library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity awgn_top is
    Port ( clk,rst : in STD_LOGIC;
           data_out : out integer;
           data_in : in integer;
           awgndata_in : in signed (15 downto 0)
           );
end awgn_top;

architecture topmod of awgn_top is
signal data : integer; 
begin
 
data <= data_in + to_integer(awgndata_in);
   
process(clk)
  begin
    if rising_edge(clk) then
        if rst = '0' then
        data_out <= 0;
        else
        data_out <= data;
        end if;
    end if;
  end process;

end topmod;

