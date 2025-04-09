00 : ADD
01 : SOU
10 : MUL

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (
        A, B        : in  std_logic_vector(7 downto 0);
        Ctrl_Alu    : in  std_logic_vector(2 downto 0);
        S           : out std_logic_vector(7 downto 0);
        Z, N, O, C    : out std_logic
    );
end ALU;

architecture Behavioral of ALU is
    signal temp: std_logic_vector(15 down to 0)
    --signal result    : signed(8 downto 0); 
    signal A_s, B_s  : signed(7 downto 0);
begin

    A_s <= signed(A);
    B_s <= signed(B);

    process(A_s, B_s, Ctrl_Alu)
    begin
        case Ctrl_Alu is
            when "00" => -- ADD
                temp <= resize(A_s, 9) + resize(B_s, 9);
            when "01" => -- SOU
                temp <= resize(A_s, 9) - resize(B_s, 9);
            when "10" => -- MUL
                temp <= resize(A_s, 9) * resize(B_s, 9);
            when others =>
                temp <= (others => '0');
        end case;
    end process;

    S <= temp(7 downto 0);
    Z <= '1' when temp(7 downto 0) = "00000000" else '0';
    N <= temp(7); -- MSB = bit de signe
    O <= '1' when temp(8) /= temp(7) else '0'; -- overflow : si bit 8 != bit 7

end Behavioral;
