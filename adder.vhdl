library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all; 

entity adder is -- adder
  port(a, b: in  STD_LOGIC_VECTOR(31 downto 0);
       y:    out STD_LOGIC_VECTOR(31 downto 0));
end;

architecture behave of adder is
begin
  y <= std_logic_vector(unsigned(a) + unsigned(b));
end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity extend is -- extend unit
  port(instr:  in  STD_LOGIC_VECTOR(31 downto 7);
    immsrc: in  STD_LOGIC_VECTOR(1  downto 0);
    immext: out STD_LOGIC_VECTOR(31 downto 0));
end;
    
architecture behave of extend is
begin
  process(instr, immsrc) begin
    case immsrc is
      -- I-type
      when "00" =>
        immext <= (31 downto 12 => instr(31)) & instr(31 downto 20);
      -- S-types (stores)
      when "01" =>
        immext <= (31 downto 12 => instr(31)) & instr(31 downto 25) & instr(11 downto 7);
      -- B-type (branches)
      when "10" =>
        immext <= (31 downto 12 => instr(31)) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0';
      -- J-type (jal)
      when "11" =>
        immext <= (31 downto 20 => instr(31)) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0';
      when others =>
        immext <= (31 downto 0 => '-');
    end case;
  end process;
end;