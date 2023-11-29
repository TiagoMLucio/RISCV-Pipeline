library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity hazardunit is
    port (
        RegWriteM, RegWriteW, ResultSrcE0, PCSrcE : in std_logic;
        RdW, RdM, Rs1E, Rs2E, RdE, Rs1D, Rs2D     : in std_logic_vector(4 downto 0);
        StallF, StallD, FlushD, FlushE            : out std_logic;
        ForwardAE, ForwardBE                      : out std_logic_vector(1 downto 0)
    );
end;

architecture behave of hazardunit is

    signal lwStall : std_logic;

begin

    ForwardAE <= "10" when ((Rs1E = RdM) and RegWriteM = '1' and (Rs1E /= "00000")) else
        "01" when ((Rs1E = RdW) and RegWriteW = '1' and (Rs1E /= "00000")) else
        "00";

    ForwardBE <= "10" when ((Rs2E = RdM) and RegWriteM = '1' and (Rs2E /= "00000")) else
        "01" when ((Rs2E = RdW) and RegWriteW = '1' and (Rs2E /= "00000")) else
        "00";

    lwStall <= '1' when ResultSrcE0 = '1' and ((Rs1D = RdE) or (Rs2D = RdE)) else
        '0';
    StallF <= lwStall;
    StallD <= lwStall;

    FlushD <= PCSrcE;
    FLushE <= '1' when lwStall = '1' or PCSrcE = '1' else
        '0';

end;
