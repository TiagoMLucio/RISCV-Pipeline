-- riscvsingle.sv

-- RISC-V single-cycle processor
-- From Section 7.6 of Digital Design & Computer Architecture
-- 27 April 2020
-- David_Harris@hmc.edu 
-- Sarah.Harris@unlv.edu

-- run 210
-- Expect simulator to print "Simulation succeeded"
-- when the value 25 (0x19) is written to address 100 (0x64)

-- Single-cycle implementation of RISC-V (RV32I)
-- User-level Instruction Set Architecture V2.2 (May 7, 2017)
-- Implements a subset of the base integer instructions:
--    lw, sw
--    add, sub, and, or, slt, 
--    addi, andi, ori, slti
--    beq
--    jal
-- Exceptions, traps, and interrupts not implemented
-- little-endian memory

-- 31 32-bit registers x1-x31, x0 hardwired to 0
-- R-Type instructions
--   add, sub, and, or, slt
--   INSTR rd, rs1, rs2
--   Instr[31:25] = funct7 (funct7b5 & opb5 = 1 for sub, 0 for others)
--   Instr[24:20] = rs2
--   Instr[19:15] = rs1
--   Instr[14:12] = funct3
--   Instr[11:7]  = rd
--   Instr[6:0]   = opcode
-- I-Type Instructions
--   lw, I-type ALU (addi, andi, ori, slti)
--   lw:         INSTR rd, imm(rs1)
--   I-type ALU: INSTR rd, rs1, imm (12-bit signed)
--   Instr[31:20] = imm[11:0]
--   Instr[24:20] = rs2
--   Instr[19:15] = rs1
--   Instr[14:12] = funct3
--   Instr[11:7]  = rd
--   Instr[6:0]   = opcode
-- S-Type Instruction
--   sw rs2, imm(rs1) (store rs2 into address specified by rs1 + immm)
--   Instr[31:25] = imm[11:5] (offset[11:5])
--   Instr[24:20] = rs2 (src)
--   Instr[19:15] = rs1 (base)
--   Instr[14:12] = funct3
--   Instr[11:7]  = imm[4:0]  (offset[4:0])
--   Instr[6:0]   = opcode
-- B-Type Instruction
--   beq rs1, rs2, imm (PCTarget = PC + (signed imm x 2))
--   Instr[31:25] = imm[12], imm[10:5]
--   Instr[24:20] = rs2
--   Instr[19:15] = rs1
--   Instr[14:12] = funct3
--   Instr[11:7]  = imm[4:1], imm[11]
--   Instr[6:0]   = opcode
-- J-Type Instruction
--   jal rd, imm  (signed imm is multiplied by 2 and added to PC, rd = PC+4)
--   Instr[31:12] = imm[20], imm[10:1], imm[11], imm[19:12]
--   Instr[11:7]  = rd
--   Instr[6:0]   = opcode

--   Instruction  opcode    funct3    funct7
--   add          0110011   000       0000000
--   sub          0110011   000       0100000
--   and          0110011   111       0000000
--   or           0110011   110       0000000
--   slt          0110011   010       0000000
--   addi         0010011   000       immediate
--   andi         0010011   111       immediate
--   ori          0010011   110       immediate
--   slti         0010011   010       immediate
--   beq          1100011   000       immediate
--   lw           0000011   010       immediate
--   sw           0100011   010       immediate
--   jal          1101111   immediate immediate

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity riscv is -- pipelined RISC-V processor
  port (
    clk, reset             : in std_logic;
    PCF                    : out std_logic_vector(31 downto 0);
    InstrF                 : in std_logic_vector(31 downto 0);
    MemWriteM              : out std_logic;
    ALUResultM, WriteDataM : out std_logic_vector(31 downto 0);
    ReadDataM              : in std_logic_vector(31 downto 0)
  );
end;

architecture struct of riscv is
  component controller
    port (
      op                              : in std_logic_vector(6 downto 0);
      funct3                          : in std_logic_vector(2 downto 0);
      funct7b5, BranchE, JumpE, ZeroE : in std_logic;
      ResultSrcD                      : out std_logic_vector(1 downto 0);
      BranchD                         : out std_logic;
      MemWriteD                       : out std_logic;
      PCSrcE, ALUSrcD                 : out std_logic;
      RegWriteD, JumpD                : out std_logic;
      ImmSrcD                         : out std_logic_vector(1 downto 0);
      ALUControlD                     : out std_logic_vector(2 downto 0));
  end component;
  component datapath
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
      ReadDataM              : in std_logic_vector(31 downto 0));
  end component;

  signal ALUSrcD, RegWriteD, BranchD, JumpD, MemWriteD, BranchE, JumpE, ZeroE, PCSrcE : std_logic;
  signal ResultSrcD, ImmSrcD                                                          : std_logic_vector(1 downto 0);
  signal ALUControlD                                                                  : std_logic_vector(2 downto 0);
  signal InstrD                                                                       : std_logic_vector(31 downto 0);
begin
  c : controller port map(
    InstrD(6 downto 0), InstrD(14 downto 12),
    InstrD(30), BranchE, JumpE, ZeroE, ResultSrcD, BranchD, MemWriteD,
    PCSrcE, ALUSrcD, RegWriteD, JumpD,
    ImmSrcD, ALUControlD);
  dp : datapath port map(
    clk, reset, ResultSrcD, PCSrcE, ALUSrcD,
    RegWriteD, BranchD, JumpD, MemWriteD, ImmSrcD, ALUControlD, ZeroE, BranchE, JumpE, MemWriteM,
    PCF, InstrF, InstrD, ALUResultM, WriteDataM,
    ReadDataM);
end;
