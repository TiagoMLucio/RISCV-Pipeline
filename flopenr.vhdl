library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity flopenr is
  generic (width : integer); -- flip-flop with synchronous reset and enable
  port (
    clk, reset, en : in std_logic;
    d              : in std_logic_vector(width - 1 downto 0);
    q              : out std_logic_vector(width - 1 downto 0));
end;

architecture asynchronous of flopenr is
begin
  process (clk, reset, en) begin
    if rising_edge(clk) and reset = '1' then
      q <= (others => '0');
    elsif rising_edge(clk) and en = '1' then
      q <= d;
    end if;
  end process;
end;
