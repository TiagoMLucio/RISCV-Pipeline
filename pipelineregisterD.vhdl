library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity pipelineregisterD is
    port (
        clk, EN, CLR          : in std_logic;
        RD, PCF, PCPlus4F     : in std_logic_vector(31 downto 0);
        InstrD, PCD, PCPlus4D : out std_logic_vector(31 downto 0));
end;

architecture behave of pipelineregisterD is

    component flopenr is
        generic (width : integer);
        port (
            clk, reset, en : in std_logic;
            d              : in std_logic_vector(width - 1 downto 0);
            q              : out std_logic_vector(width - 1 downto 0));
    end component;

begin

    pcreg      : flopenr generic map(32) port map(clk, CLR, EN, PCF, PCD);
    pcplus4reg : flopenr generic map(32) port map(clk, CLR, EN, PCPlus4F, PCPlus4D);
    instrreg   : flopenr generic map(32) port map(clk, CLR, EN, RD, InstrD);

end;
