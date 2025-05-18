library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity stage_li_di is
    Port ( In_A : in STD_LOGIC_VECTOR (7 downto 0);
        In_B : in STD_LOGIC_VECTOR (7 downto 0);
        In_C : in STD_LOGIC_VECTOR (7 downto 0);
        In_Op : in STD_LOGIC_VECTOR (7 downto 0);
        Clk : in STD_LOGIC;
        Out_A : out STD_LOGIC_VECTOR (7 downto 0);
        Out_B : out STD_LOGIC_VECTOR (7 downto 0);
        Out_Op : out STD_LOGIC_VECTOR (7 downto 0);
        Out_C : out STD_LOGIC_VECTOR (7 downto 0)
    );
end stage_li_di;

architecture Behavioral of stage_li_di is
begin
    process(CLK)
    begin
        wait until clk'event and clk = '1';
            Out_A <= In_A;
            Out_B <= In_B;
            Out_C <= In_C;
            Out_Op <= In_Op;
    end process;
end Behavioral; 