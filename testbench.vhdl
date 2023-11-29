library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity testbench is -- RISC-V testbench
end;

architecture test of testbench is
  component top
    port (
      clk, reset         : in std_logic;
      WriteData, DataAdr : out std_logic_vector(31 downto 0);
      MemWrite           : out std_logic);

  end component;
  signal WriteData, DataAdr   : std_logic_vector(31 downto 0);
  signal clk, reset, MemWrite : std_logic;
begin
  -- instantiate device to be tested
  dut : top port map(clk, reset, WriteData, DataAdr, MemWrite);

  -- Generate clock with 10 ns period
  process begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;

  -- Generate reset for first two clock cycles
  process begin
    reset <= '1';
    wait for 22 ns;
    reset <= '0';
    wait;
  end process;

  -- check that 25 gets written to address 100 at end of program
  process (clk) begin
    if (clk'event and clk = '0' and MemWrite = '1') then
      if (to_integer(unsigned(DataAdr)) = 100 and to_integer(unsigned(writedata)) = 25) then
        report "NO ERRORS: Simulation succeeded" severity failure;
      elsif (unsigned(DataAdr) /= 96) then
        report "Simulation failed" severity failure;
      end if;
    end if;
  end process;
end;
