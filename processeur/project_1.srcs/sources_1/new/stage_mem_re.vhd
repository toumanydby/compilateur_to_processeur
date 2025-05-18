library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Stage_mem_re is
    Port ( In_A : in STD_LOGIC_VECTOR (7 downto 0);
           In_B : in STD_LOGIC_VECTOR (7 downto 0);
           In_Op : in STD_LOGIC_VECTOR (7 downto 0);
           Clk : in STD_LOGIC;
           Out_A : out STD_LOGIC_VECTOR (7 downto 0);
           Out_B : out STD_LOGIC_VECTOR (7 downto 0);
           Out_Op : out STD_LOGIC_VECTOR (7 downto 0)
          );
end Stage_mem_re;

architecture Behavioral of Stage_mem_re is

begin
    process
    begin
        wait until clk'event and clk = '1';
        Out_A <= In_A;
        Out_B <= In_B;
        Out_Op <= In_Op;
    end process;

end Behavioral;