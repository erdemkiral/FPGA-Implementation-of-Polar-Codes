----------------------------------------------------------------------------------
-- Company: 
-- Engineer: TYT
-- 
-- Create Date: 05/27/2023 12:21:11 AM
-- Design Name: Modular lzd design based on Milenkovi´c
-- Module Name: lzd - Behavioral
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

entity lzd is
    Port ( data_in : in STD_LOGIC_VECTOR (60 downto 0);
           data_out : out STD_LOGIC_VECTOR (5 downto 0));
end lzd;

architecture Behavioral of lzd is

signal data : STD_LOGIC_VECTOR (63 downto 0);
signal a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15 : std_logic;
signal z0,z1,z2,z3,z4,z5,z6,z7,z8,z9,z10,z11,z12,z13,z14,z15 : std_logic_vector (1 downto 0);
signal Q0,Q1,Q : std_logic;
signal y0,y1,y2,y3,y4,y5 : std_logic;
signal NLZh,NLZl : std_logic_vector (4 downto 0);
signal sel0,sel1 : std_logic_vector (2 downto 0);

begin
    data <= (data_in(60 downto 0) & "111");

     a0 <= not (data(63) or data(62) or data(61) or data(60));
     z0(1) <= data(63) nor data(62);
     z0(0) <= data(63) nor ((not data(62)) and data(61));

     a1 <= not (data(59) or data(58) or data(57) or data(56));
     z1(1) <= data(59) nor data(58);
     z1(0) <= data(59) nor ((not data(58)) and data(57));

     a2 <= not (data(55) or data(54) or data(53) or data(52));
     z2(1) <= data(55) nor data(54);
     z2(0) <= data(55) nor ((not data(54)) and data(53));

     a3 <= not (data(51) or data(50) or data(49) or data(48));
     z3(1) <= data(51) nor data(50);
     z3(0) <= data(51) nor ((not data(50)) and data(49));

     a4 <= not (data(47) or data(46) or data(45) or data(44));
     z4(1) <= data(47) nor data(46);
     z4(0) <= data(47) nor ((not data(46)) and data(45));

     a5 <= not (data(43) or data(42) or data(41) or data(40));
     z5(1) <= data(43) nor data(42);
     z5(0) <= data(43) nor ((not data(42)) and data(41));

     a6 <= not (data(39) or data(38) or data(37) or data(36));
     z6(1) <= data(39) nor data(38);
     z6(0) <= data(39) nor ((not data(38)) and data(37));

     a7 <= not (data(35) or data(34) or data(33) or data(32));
     z7(1) <= data(35) nor data(34);
     z7(0) <= data(35) nor ((not data(34)) and data(33));

     a8 <= not (data(31) or data(30) or data(29) or data(28));
     z8(1) <= data(31) nor data(30);
     z8(0) <= data(31) nor ((not data(30)) and data(29));

     a9 <= not (data(27) or data(26) or data(25) or data(24));
     z9(1) <= data(27) nor data(26);
     z9(0) <= data(27) nor ((not data(26)) and data(25));

     a10 <= not (data(23) or data(22) or data(21) or data(20));
     z10(1) <= data(23) nor data(22);
     z10(0) <= data(23) nor ((not data(22)) and data(21));

     a11 <= not (data(19) or data(18) or data(17) or data(16));
     z11(1) <= data(19) nor data(18);
     z11(0) <= data(19) nor ((not data(18)) and data(17));

     a12 <= not (data(15) or data(14) or data(13) or data(12));
     z12(1) <= data(15) nor data(14);
     z12(0) <= data(15) nor ((not data(14)) and data(13));

     a13 <= not (data(11) or data(10) or data(9) or data(8));
     z13(1) <= data(11) nor data(10);
     z13(0) <= data(11) nor ((not data(10)) and data(9));

     a14 <= not (data(7) or data(6) or data(5) or data(4));
     z14(1) <= data(7) nor data(6);
     z14(0) <= data(7) nor ((not data(6)) and data(5));

     a15 <= not (data(3) or data(2) or data(1) or data(0));
     z15(1) <= data(3) nor data(2);
     z15(0) <= data(3) nor ((not data(2)) and data(1));


    Q0 <= not (((a0 nand a1) nor (a2 nand a3)) nand ((a4 nand a5) nor (a6 nand a7)));
    y2 <= (a0 nand a1) nor (a2 nand a3);
    y1 <= ((not (a2 nand a3)) and (a4 nand a5)) nor (a0 nand a1);
    y0 <= ((a5 nand (not a6)) nand (a0 and a2 and a4)) nand (not ((a1 nand a3) and ((not a2) nand a1) and a0));

    Q1 <= not (((a8 nand a9) nor (a10 nand a11)) nand ((a12 nand a13) nor (a14 nand a15)));
    y5 <= (a8 nand a9) nor (a10 nand a11);
    y4 <= ((not (a10 nand a11)) and (a12 nand a13)) nor (a8 nand a9);
    y3 <= ((a13 nand (not a14)) nand (a8 and a10 and a12)) nand (not ((a9 nand a11) and ((not a10) nand a9) and a8));

    sel0 <= y2 & y1 & y0;
    sel1 <= y5 & y4 & y3; 

    with sel0 select
      NLZh <= sel0 & z0 when "000",
              sel0 & z1 when "001",
              sel0 & z2 when "010",
              sel0 & z3 when "011",
              sel0 & z4 when "100",
              sel0 & z5 when "101",
              sel0 & z6 when "110",
              sel0 & z7 when "111",
               "00000" when others;

    with sel1 select
      NLZl <= sel1 & z8 when "000",
              sel1 & z9 when "001",
              sel1 & z10 when "010",
              sel1 & z11 when "011",
              sel1 & z12 when "100",
              sel1 & z13 when "101",
              sel1 & z14 when "110",
              sel1 & z15 when "111",
                "00000" when others;

    Q <= Q0 and Q1;

    data_out <= (Q & NLZh) when (Q0 = '0') else (Q0 & NLZl) when (Q0 = '1');

end Behavioral;
