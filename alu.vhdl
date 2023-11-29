library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all; 

entity alu is
    port (
        a, b       : in std_logic_vector(31 downto 0);
        ALUControl : in std_logic_vector(2 downto 0);
        ALUResult  : buffer std_logic_vector(31 downto 0);
        Zero       : out std_logic);
end;

architecture behave of alu is
    signal condinvb, sum : std_logic_vector(31 downto 0);
    signal v, isAddSub   : std_logic;
begin
    condinvb <= not b when Alucontrol(0) = '1' else
        b;
    sum      <= std_logic_vector(unsigned(a) + unsigned(condinvb) + unsigned(Alucontrol(0 downto 0)));
    isAddSub <= (not ALUControl(2) and not ALUControl(1)) or
        (not ALUControl(1) and ALUControl(0));

    process (a, b, ALUControl, sum, v) begin
        case Alucontrol is
            when "000" => ALUResult  <= sum;
            when "001" => ALUResult  <= sum;
            when "010" => ALUResult  <= a and b;
            when "011" => ALUResult  <= a or b;
            when "101" => ALUResult  <= (0 => (sum(31) xor v), others => '0');
            when others => ALUResult <= (others => 'X');
        end case;
    end process;

    Zero <= '1' when ALUResult = X"00000000" else
        '0';
    v <= not(ALUControl(0) xor a(31) xor b(31)) and (a(31) xor sum(31)) and isAddSub;
end;
