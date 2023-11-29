library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity maindec is -- main control decoder
  port(op:             in  STD_LOGIC_VECTOR(6 downto 0);
       ResultSrc:      out STD_LOGIC_VECTOR(1 downto 0);
       MemWrite:       out STD_LOGIC;
       Branch, ALUSrc: out STD_LOGIC;
       RegWrite, Jump: out STD_LOGIC;
       ImmSrc:         out STD_LOGIC_VECTOR(1 downto 0);
       ALUOp:          out STD_LOGIC_VECTOR(1 downto 0));
end;

architecture behave of maindec is
  signal controls: STD_LOGIC_VECTOR(10 downto 0);
begin
  process(op) begin
    case op is
      when "0000011" => controls <= "10010010000"; -- lw
      when "0100011" => controls <= "00111000000"; -- sw
      when "0110011" => controls <= "1--00000100"; -- R-type
      when "1100011" => controls <= "01000001010"; -- beq
      when "0010011" => controls <= "10010000100"; -- I-type ALU
      when "1101111" => controls <= "11100100001"; -- jal
      when others    => controls <= "-----------"; -- not valid
    end case;
  end process;

  (RegWrite, ImmSrc(1), ImmSrc(0), ALUSrc, MemWrite,
   ResultSrc(1), ResultSrc(0), Branch, ALUOp(1), ALUOp(0), Jump) <= controls;
end;