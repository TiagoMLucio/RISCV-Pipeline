library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all; 

entity top is -- top-level design for testing
  port (
    clk, reset         : in std_logic;
    WriteData, DataAdr : buffer std_logic_vector(31 downto 0);
    MemWrite           : buffer std_logic);
end;

architecture test of top is
  component riscv
    port (
      clk, reset             : in std_logic;
      PCF                    : out std_logic_vector(31 downto 0);
      InstrF                 : in std_logic_vector(31 downto 0);
      MemWriteM              : out std_logic;
      ALUResultM, WriteDataM : out std_logic_vector(31 downto 0);
      ReadDataM              : in std_logic_vector(31 downto 0)
    );
  end component;
  component imem
    port (
      a  : in std_logic_vector(31 downto 0);
      rd : out std_logic_vector(31 downto 0));
  end component;
  component dmem
    port (
      clk, we : in std_logic;
      a, wd   : in std_logic_vector(31 downto 0);
      rd      : out std_logic_vector(31 downto 0));
  end component;

  signal PCF, InstrF, ReadDataM : std_logic_vector(31 downto 0);
begin
  -- instantiate processor and memories
  rvsingle : riscv port map(clk, reset, PCF, InstrF, MemWrite, DataAdr, WriteData, ReadDataM);
  imem1    : imem port map(PCF, InstrF);
  dmem1    : dmem port map(clk, MemWrite, DataAdr, WriteData, ReadDataM);
end;
