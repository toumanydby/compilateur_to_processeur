----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2025 10:18:25 AM
-- Design Name: 
-- Module Name: ALU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           Ctrl_Alu : in STD_LOGIC_VECTOR (2 downto 0);
           S : out STD_LOGIC_VECTOR (7 downto 0);
           N : out STD_LOGIC;
           O : out STD_LOGIC;
           C : out STD_LOGIC;
           Z : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

    signal temp: STD_LOGIC_VECTOR(15 downto 0);
    signal result : unsigned(8 downto 0); -- resultat sur 9bits pour ADD/SOU avec carry 
    signal a_unsigned, b_unsigned : unsigned(7 downto 0);
begin

    a_unsigned <= unsigned(A);
    b_unsigned <= unsigned(B);

    process(a_unsigned, b_unsigned, Ctrl_Alu)
    begin
        case Ctrl_Alu is
           when "000" =>  -- ADD
                result <= ('0' & a_unsigned) + ('0' & b_unsigned);
                temp <= (others => '0');
                temp(8 downto 0) <= std_logic_vector(result);
                C <= result(8);
                if result > 255 then 
                    O <= '1'; 
                else 
                    O <= '0'; 
                end if;

            when "001" => -- SOU
                result <= ('0' & a_unsigned) - ('0' & b_unsigned);
                temp <= (others => '0');
                temp(8 downto 0) <= std_logic_vector(result);
                C <= '0'; -- Optional: Borrow not handled
                if result > 255 then
                    O <= '1';
                else
                    O <= '0';
                end if; 
                
            when "010" =>  -- MUL
                temp <= std_logic_vector(a_unsigned * b_unsigned);
                C <= '0'; -- No carry for MUL
                if unsigned(temp) > 255 then
                    O <= '1';
                else
                    O <= '0';
                end if;
                
            when others =>
                temp <= (others => '0');
                C <= '0';
                O <= '0';
                
        end case;
    end process;

        
    S <= temp(7 downto 0);
    Z <= '1' when temp(7 downto 0) = "00000000" else '0';
    N <= temp(7); -- MSB = bit de signe

end Behavioral;

