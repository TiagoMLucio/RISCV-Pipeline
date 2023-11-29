library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity controller is -- single-cycle controller
  port (
    op                              : in std_logic_vector(6 downto 0);
    funct3                          : in std_logic_vector(2 downto 0);
    funct7b5, ZeroE, BranchE, JumpE : in std_logic;
    ResultSrcD                      : out std_logic_vector(1 downto 0);
    BranchD                         : out std_logic;
    MemWriteD                       : out std_logic;
    PCSrcE, ALUSrcD                 : out std_logic;
    RegWriteD                       : out std_logic;
    JumpD                           : out std_logic;
    ImmSrcD                         : out std_logic_vector(1 downto 0);
    ALUControlD                     : out std_logic_vector(2 downto 0));
end;

architecture struct of controller is
  component maindec
    port (
      op             : in std_logic_vector(6 downto 0);
      ResultSrc      : out std_logic_vector(1 downto 0);
      MemWrite       : out std_logic;
      Branch, ALUSrc : out std_logic;
      RegWrite, Jump : out std_logic;
      ImmSrc         : out std_logic_vector(1 downto 0);
      ALUOp          : out std_logic_vector(1 downto 0));
  end component;
  component aludec
    port (
      opb5       : in std_logic;
      funct3     : in std_logic_vector(2 downto 0);
      funct7b5   : in std_logic;
      ALUOp      : in std_logic_vector(1 downto 0);
      ALUControl : out std_logic_vector(2 downto 0));
  end component;

  signal ALUOp   : std_logic_vector(1 downto 0);
begin
  md : maindec port map(
    op, ResultSrcD, MemWriteD, BranchD,
    ALUSrcD, RegWriteD, JumpD, ImmSrcD, ALUOp);
  ad : aludec port map(op(5), funct3, funct7b5, ALUOp, ALUControlD);

  PCSrcE <= (BranchE and ZeroE) or JumpE;
end;
