library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity instruction_pointer is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC; -- rst when 1
           LOAD : in STD_LOGIC;
           EN : in STD_LOGIC; -- enable when 0
           Din : in STD_LOGIC_VECTOR (7 downto 0);
           Dout : out STD_LOGIC_VECTOR (7 downto 0));
end instruction_pointer;

architecture Behavioral of instruction_pointer is
    signal aux: STD_LOGIC_VECTOR (7 downto 0) := x"00";
begin
    process
    begin
        wait until rising_edge(CLK);
        
        if (RST = '1') then
            aux <= x"00";
        elsif (LOAD = '1') then
            aux <= Din;
        elsif (EN = '0') then
            aux <= aux + x"01";
        end if;
    end process;
    Dout <= aux; 
end Behavioral;
