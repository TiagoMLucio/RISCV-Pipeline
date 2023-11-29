library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity pipelineregisterW is
    port (
        clk                             : in std_logic;
        RegWriteM                       : in std_logic;
        ResultSrcM                      : in std_logic_vector(1 downto 0);
        RdM                             : in std_logic_vector(4 downto 0);
        ALUResultM, ReadDataM, PCPlus4M : in std_logic_vector(31 downto 0);
        RegWriteW                       : out std_logic;
        ResultSrcW                      : out std_logic_vector(1 downto 0);
        RdW                             : out std_logic_vector(4 downto 0);
        ALUResultW, ReadDataW, PCPlus4W : out std_logic_vector(31 downto 0)
    );
end;

architecture behave of pipelineregisterW is

    component flopr is
        generic (width : integer);
        port (
            clk, reset : in std_logic;
            d          : in std_logic_vector(width - 1 downto 0);
            q          : out std_logic_vector(width - 1 downto 0));
    end component;

    signal s_RegWriteM : std_logic_vector(0 downto 0);
    signal s_RegWriteW : std_logic_vector(0 downto 0);
begin

    RegWriteW      <= s_RegWriteW(0);
    s_RegWriteM(0) <= RegWriteM;

    regwriteregw  : flopr generic map(1) port map(clk, '0', s_RegWriteM, s_RegWriteW);
    resultsrcregw : flopr generic map(2) port map(clk, '0', ResultSrcM, ResultSrcW);
    rdregw        : flopr generic map(5) port map(clk, '0', RdM, RdW);
    aluresultregw : flopr generic map(32) port map(clk, '0', ALUResultM, ALUResultW);
    readdataregw  : flopr generic map(32) port map(clk, '0', ReadDataM, ReadDataW);
    pcplus4regw   : flopr generic map(32) port map(clk, '0', PCPlus4M, PCPlus4W);

end;
