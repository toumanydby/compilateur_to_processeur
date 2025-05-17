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

    signal temp: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal a_unsigned, b_unsigned : unsigned(7 downto 0);
begin

    a_unsigned <= unsigned(A);
    b_unsigned <= unsigned(B);

    process(a_unsigned, b_unsigned, Ctrl_Alu)
    begin
        case Ctrl_Alu is
           when "000" =>  -- ADD
                temp(8 downto 0) <= std_logic_vector(('0' & a_unsigned) + ('0' & b_unsigned));


            when "001" => -- SOU
                temp(8 downto 0) <= std_logic_vector(('0' & a_unsigned) - ('0' & b_unsigned));
            
            when "010" =>  -- MUL
                temp <= std_logic_vector(a_unsigned * b_unsigned);
                
            when "011" => -- DIV
                if b_unsigned = 0 then
                else
                    -- On convertit le type de a et b en integer, la division ensuite convertie en unsigned avec le bon nombre de bits
                    -- puis on fait un conversion en std_logic_vector
                    temp <= std_logic_vector(to_unsigned((to_integer(a_unsigned) / to_integer(b_unsigned)), 16));
                end if;
                    
            when others =>
                temp <= (others => '0');
        end case;
    end process;

    C <= '1' when (Ctrl_Alu = "000" or Ctrl_Alu = "001") and temp(8) = '1' else '0'; 
    O <= '1' when (Ctrl_Alu = "010") and unsigned(temp) > 255 else '0'; 
    S <= temp(7 downto 0);
    Z <= '1' when temp(7 downto 0) = "00000000" else '0';
    N <= temp(7); -- MSB = bit de signe

end Behavioral;

