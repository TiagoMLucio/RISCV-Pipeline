library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity regfile is -- three-port register file
  port (
    clk        : in std_logic;
    we3        : in std_logic;
    a1, a2, a3 : in std_logic_vector(4 downto 0);
    wd3        : in std_logic_vector(31 downto 0);
    rd1, rd2   : out std_logic_vector(31 downto 0));
end;

architecture behave of regfile is
  type ramtype is array (31 downto 0) of std_logic_vector(31 downto 0);
  signal mem : ramtype;
begin
  -- three ported register file
  -- read two ports combinationally (A1/RD1, A2/RD2)
  -- write third port on rising edge of clock (A3/WD3/WE3)
  -- register 0 hardwired to 0
  process (clk) begin
    if falling_edge(clk) then
      if we3 = '1' then
        mem(to_integer(unsigned(a3))) <= wd3;
      end if;
    end if;
  end process;
  process (clk, a1, a2, mem) begin
    if (to_integer(unsigned(a1)) = 0) then
      rd1 <= X"00000000";
    else
      rd1 <= mem(to_integer(unsigned(a1)));
    end if;
    if (to_integer(unsigned(a2)) = 0) then
      rd2 <= X"00000000";
    else
      rd2 <= mem(to_integer(unsigned(a2)));
    end if;
  end process;
end;
