library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity pipelineregisterM is
    port (
        clk                              : in std_logic;
        RegWriteE, MemWriteE             : in std_logic;
        ResultSrcE                       : in std_logic_vector(1 downto 0);
        RdE                              : in std_logic_vector(4 downto 0);
        ALUResultE, WriteDataE, PCPlus4E : in std_logic_vector(31 downto 0);
        RegWriteM, MemWriteM             : out std_logic;
        ResultSrcM                       : out std_logic_vector(1 downto 0);
        RdM                              : out std_logic_vector(4 downto 0);
        ALUResultM, WriteDataM, PCPlus4M : out std_logic_vector(31 downto 0)
    );
end;

architecture behave of pipelineregisterM is

    component flopr is
        generic (width : integer);
        port (
            clk, reset : in std_logic;
            d          : in std_logic_vector(width - 1 downto 0);
            q          : out std_logic_vector(width - 1 downto 0));
    end component;

    signal s_RegWriteE, s_MemWriteE : std_logic_vector(0 downto 0);
    signal s_RegWriteM, s_MemWriteM : std_logic_vector(0 downto 0);
begin

    RegWriteM      <= s_RegWriteM(0);
    MemWriteM      <= s_MemWriteM(0);
    s_RegWriteE(0) <= RegWriteE;
    s_MemWriteE(0) <= MemWriteE;

    regwriteregm  : flopr generic map(1) port map(clk, '0', s_RegWriteE, s_RegWriteM);
    memwriteregm  : flopr generic map(1) port map(clk, '0', s_MemWriteE, s_MemWriteM);
    resultsrcregm : flopr generic map(2) port map(clk, '0', ResultSrcE, ResultSrcM);
    rdregm        : flopr generic map(5) port map(clk, '0', RdE, RdM);
    aluresultregm : flopr generic map(32) port map(clk, '0', ALUResultE, ALUResultM);
    writedataregm : flopr generic map(32) port map(clk, '0', WriteDataE, WriteDataM);
    pcplus4regm   : flopr generic map(32) port map(clk, '0', PCPlus4E, PCPlus4M);

end;
