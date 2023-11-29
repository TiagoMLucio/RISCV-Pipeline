library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity datapath is -- RISC-V datapath
  --   port(clk, reset:           in     STD_LOGIC;
  --        ResultSrc:            in     STD_LOGIC_VECTOR(1  downto 0);
  --        PCSrc, ALUSrc:        in     STD_LOGIC;
  --        RegWrite:             in     STD_LOGIC;
  --        ImmSrc:               in     STD_LOGIC_VECTOR(1  downto 0);
  --        ALUControl:           in     STD_LOGIC_VECTOR(2  downto 0);
  --        Zero:                 out    STD_LOGIC;
  --        PC:                   buffer STD_LOGIC_VECTOR(31 downto 0);
  --        Instr:                in     STD_LOGIC_VECTOR(31 downto 0);
  --        ALUResult, WriteData: buffer STD_LOGIC_VECTOR(31 downto 0);
  --        ReadData:             in     STD_LOGIC_VECTOR(31 downto 0));
  -- end;
  port (
    clk, reset             : in std_logic;
    ResultSrcD             : in std_logic_vector(1 downto 0);
    PCSrcE, ALUSrcD        : in std_logic;
    RegWriteD              : in std_logic;
    BranchD                : in std_logic;
    JumpD                  : in std_logic;
    MemWriteD              : in std_logic;
    ImmSrcD                : in std_logic_vector(1 downto 0);
    ALUControlD            : in std_logic_vector(2 downto 0);
    ZeroE, BranchE, JumpE  : out std_logic;
    MemWriteM              : out std_logic;
    PCF                    : out std_logic_vector(31 downto 0);
    InstrF                 : in std_logic_vector(31 downto 0);
    InstrD                 : out std_logic_vector(31 downto 0);
    ALUResultM, WriteDataM : out std_logic_vector(31 downto 0);
    ReadDataM              : in std_logic_vector(31 downto 0)
  );
end;

architecture struct of datapath is
  component flopenr is
    generic (width : integer); -- flip-flop with synchronous reset and enable
    port (
      clk, reset, en : in std_logic;
      d              : in std_logic_vector(width - 1 downto 0);
      q              : out std_logic_vector(width - 1 downto 0));
  end component;
  component adder
    port (
      a, b : in std_logic_vector(31 downto 0);
      y    : out std_logic_vector(31 downto 0));
  end component;
  component mux2
    generic (width : integer);
    port (
      d0, d1 : in std_logic_vector(width - 1 downto 0);
      s      : in std_logic;
      y      : out std_logic_vector(width - 1 downto 0));
  end component;
  component mux3
    generic (width : integer);
    port (
      d0, d1, d2 : in std_logic_vector(width - 1 downto 0);
      s          : in std_logic_vector(1 downto 0);
      y          : out std_logic_vector(width - 1 downto 0));
  end component;
  component regfile
    port (
      clk        : in std_logic;
      we3        : in std_logic;
      a1, a2, a3 : in std_logic_vector(4 downto 0);
      wd3        : in std_logic_vector(31 downto 0);
      rd1, rd2   : out std_logic_vector(31 downto 0));
  end component;
  component extend
    port (
      instr  : in std_logic_vector(31 downto 7);
      immsrc : in std_logic_vector(1 downto 0);
      immext : out std_logic_vector(31 downto 0));
  end component;
  component alu
    port (
      a, b       : in std_logic_vector(31 downto 0);
      ALUControl : in std_logic_vector(2 downto 0);
      ALUResult  : buffer std_logic_vector(31 downto 0);
      Zero       : out std_logic);
  end component;
  component pipelineregisterD is
    port (
      clk, EN, CLR          : in std_logic;
      RD, PCF, PCPlus4F     : in std_logic_vector(31 downto 0);
      InstrD, PCD, PCPlus4D : out std_logic_vector(31 downto 0)
    );
  end component;
  component pipelineregisterE is
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
  end component;
  component pipelineregisterM is
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
  end component;
  component pipelineregisterW is
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
  end component;
  component hazardunit is
    port (
      RegWriteM, RegWriteW, ResultSrcE0, PCSrcE : in std_logic;
      RdW, RdM, Rs1E, Rs2E, RdE, Rs1D, Rs2D     : in std_logic_vector(4 downto 0);
      StallF, StallD, FlushD, FlushE            : out std_logic;
      ForwardAE, ForwardBE                      : out std_logic_vector(1 downto 0)
    );
  end component;

  signal RegWriteE, MemWriteE, ALUSrcE, RegWriteM, RegWriteW                                                                                                                                                             : std_logic;
  signal ResultSrcE, ResultSrcM, ResultSrcW                                                                                                                                                                              : std_logic_vector(1 downto 0);
  signal ALUControlE                                                                                                                                                                                                     : std_logic_vector(2 downto 0);
  signal Rs1D, Rs2D, RdD, Rs1E, Rs2E, RdE, RdM, RdW                                                                                                                                                                      : std_logic_vector(4 downto 0);
  signal PCFNext, s_PCF, PCPlus4F, PCTargetE, s_InstrD, PCD, PCPlus4D, RD1D, RD2D, ImmExtD, RD1E, RD2E, PCE, ImmExtE, PCPlus4E, ALUResultE, WriteDataE, s_ALUResultM, PCPlus4M, ALUResultW, ReadDataW, PCPlus4W, ResultW : std_logic_vector(31 downto 0);
  signal SrcAE, SrcBE                                                                                                                                                                                                    : std_logic_vector(31 downto 0);
  signal ResultSrcE0, StallF, notStallF, StallD, notStallD, FlushD, FlushE                                                                                                                                               : std_logic;
  signal ForwardAE, ForwardBE                                                                                                                                                                                            : std_logic_vector(1 downto 0);

begin
  PCF        <= s_PCF;
  InstrD     <= s_InstrD;
  ALUResultM <= s_AluresultM;

  ResultSrcE0 <= ResultSrcE(0);
  notStallF   <= not StallF;
  notStallD   <= not StallD;

  -- next PC logic
  pcreg       : flopenr generic map(32) port map(clk, reset, notStallF, PCFNext, s_PCF);
  pcadd4      : adder port map(s_PCF, X"00000004", PCPlus4F);
  pcaddbranch : adder port map(PCE, ImmExtE, PCTargetE);
  pcmux       : mux2 generic map(32) port map(PCPlus4F, PCTargetE, PCSrcE, PCFNext);

  -- register file logic
  rf : regfile port map(
    clk, RegWriteW, s_InstrD(19 downto 15), s_InstrD(24 downto 20),
    RdW, ResultW, RD1D, RD2D);
  ext : extend port map(s_InstrD(31 downto 7), ImmSrcD, ImmExtD);

  -- ALU logic
  srcamux      : mux3 generic map(32) port map(RD1E, ResultW, s_ALUResultM, ForwardAE, SrcAE);
  writedatamux : mux3 generic map(32) port map(RD2E, ResultW, s_ALUResultM, ForwardBE, WriteDataE);
  srcbmux      : mux2 generic map(32) port map(WriteDataE, ImmExtE, ALUSrcE, SrcBE);
  mainalu      : alu port map(SrcAE, SrcBE, ALUControlE, ALUResultE, ZeroE);
  resultmux    : mux3 generic map(32) port map(ALUResultW, ReadDataW, PCPlus4W, ResultSrcW, ResultW);

  --
  RdD  <= s_InstrD(11 downto 7);
  Rs1D <= s_InstrD(19 downto 15);
  Rs2D <= s_InstrD(24 downto 20);

  -- PiplenlineRegisters
  regsD   : pipelineregisterD port map(clk, notStallD, FlushD, InstrF, s_PCF, PCPlus4F, s_InstrD, PCD, PCPlus4D);
  regsE   : pipelineregisterE port map(clk, FlushE, RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD, ResultSrcD, ALUControlD, Rs1D, Rs2D, RdD, RD1D, RD2D, PCD, ImmExtD, PCPlus4D, RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE, ResultSrcE, ALUControlE, Rs1E, Rs2E, RdE, RD1E, RD2E, PCE, ImmExtE, PCPlus4E);
  regsM   : pipelineregisterM port map(clk, RegWriteE, MemWriteE, ResultSrcE, RdE, ALUResultE, WriteDataE, PCPlus4E, RegWriteM, MemWriteM, ResultSrcM, RdM, s_ALUResultM, WriteDataM, PCPlus4M);
  regsW   : pipelineregisterW port map(clk, RegWriteM, ResultSrcM, RdM, s_ALUResultM, ReadDataM, PCPlus4M, RegWriteW, ResultSrcW, RdW, ALUResultW, ReadDataW, PCPlus4W);
  hazunit : hazardunit port map(RegWriteM, RegWriteW, ResultSrcE0, PCSrcE, RdW, RdM, Rs1E, Rs2E, RdE, Rs1D, Rs2D, StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE);
end;
