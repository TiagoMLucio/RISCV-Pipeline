library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity pipelineregisterE is
    port (
        clk, CLR                                      : in std_logic;
        RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD : in std_logic;
        ResultSrcD                                    : in std_logic_vector(1 downto 0);
        ALUControlD                                   : in std_logic_vector(2 downto 0);
        Rs1D, Rs2D, RdD                               : in std_logic_vector(4 downto 0);
        RD1D, RD2D, PCD, ImmExtD, PCPlus4D            : in std_logic_vector(31 downto 0);
        RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE : out std_logic;
        ResultSrcE                                    : out std_logic_vector(1 downto 0);
        ALUControlE                                   : out std_logic_vector(2 downto 0);
        Rs1E, Rs2E, RdE                               : out std_logic_vector(4 downto 0);
        RD1E, RD2E, PCE, ImmExtE, PCPlus4E            : out std_logic_vector(31 downto 0)
    );
end;

architecture behave of pipelineregisterE is

    component flopr is
        generic (width : integer);
        port (
            clk, reset : in std_logic;
            d          : in std_logic_vector(width - 1 downto 0);
            q          : out std_logic_vector(width - 1 downto 0));
    end component;

    signal s_RegWriteD, s_MemWriteD, s_JumpD, s_BranchD, s_ALUSrcD : std_logic_vector(0 downto 0);
    signal s_RegWriteE, s_MemWriteE, s_JumpE, s_BranchE, s_ALUSrcE : std_logic_vector(0 downto 0);

begin

    RegWriteE      <= s_RegWriteE(0);
    MemWriteE      <= s_MemWriteE(0);
    JumpE          <= s_JumpE(0);
    BranchE        <= s_BranchE(0);
    ALUSrcE        <= s_ALUSrcE(0);
    s_RegWriteD(0) <= RegWriteD;
    s_MemWriteD(0) <= MemWriteD;
    s_JumpD(0)     <= JumpD;
    s_BranchD(0)   <= BranchD;
    s_ALUSrcD(0)   <= AlusrcD;

    regwriterege   : flopr generic map(1) port map(clk, CLR, s_RegWriteD, s_RegWriteE);
    memwriterege   : flopr generic map(1) port map(clk, CLR, s_MemWriteD, s_MemWriteE);
    jumprege       : flopr generic map(1) port map(clk, CLR, s_JumpD, s_JumpE);
    branchrege     : flopr generic map(1) port map(clk, CLR, s_BranchD, s_BranchE);
    alusrcrege     : flopr generic map(1) port map(clk, CLR, s_ALUSrcD, s_ALUSrcE);
    resultsrcrege  : flopr generic map(2) port map(clk, CLR, ResultSrcD, ResultSrcE);
    alucontrolrege : flopr generic map(3) port map(clk, CLR, ALUControlD, ALUControlE);
    rs1rege        : flopr generic map(5) port map(clk, CLR, Rs1D, Rs1E);
    rs2rege        : flopr generic map(5) port map(clk, CLR, Rs2D, Rs2E);
    rdrege         : flopr generic map(5) port map(clk, CLR, RdD, RdE);
    rd1rege        : flopr generic map(32) port map(clk, CLR, RD1D, RD1E);
    rd2rege        : flopr generic map(32) port map(clk, CLR, RD2D, RD2E);
    pcrege         : flopr generic map(32) port map(clk, CLR, PCD, PCE);
    immextrege     : flopr generic map(32) port map(clk, CLR, ImmExtD, ImmExtE);
    pcplus4rege    : flopr generic map(32) port map(clk, CLR, PCPlus4D, PCPlus4E);

end;
