----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2025 09:50:40 AM
-- Design Name: 
-- Module Name: register_bench - Behavioral
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

entity register_bench is
    Port ( addr_A : in STD_LOGIC_VECTOR (3 downto 0);
           addr_B : in STD_LOGIC_VECTOR (3 downto 0);
           addr_W : in STD_LOGIC_VECTOR (3 downto 0);
           W : in STD_LOGIC;
           DATA : in STD_LOGIC_VECTOR (7 downto 0);
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           QA : out STD_LOGIC_VECTOR (7 downto 0);
           QB : out STD_LOGIC_VECTOR (7 downto 0));
end register_bench;

architecture Behavioral of register_bench is
    type register_array is array(0 to 15) of STD_LOGIC_VECTOR(7 downto 0);
    signal regs: register_array := (others => (others => '0'));
begin

    -- Processus synchrone pour reset et écriture
    process(CLK)
    begin
        wait until clk'event and clk = '1';
        if RST = '1' then
            regs <= (others => (others => '0'));
        elsif W = '1' then
            regs(to_integer(unsigned(addr_W))) <= DATA;
        end if;
    end process;

    -- Processus asynchrone pour la lecture avec Bypass D -> Q 
    process(regs, addr_A, addr_B, W, addr_W, DATA)
    begin
        -- Lecture port A 
        if (W = '1' and addr_A = addr_W) then
            QA <= DATA;
        else
            QA <= regs(to_integer(unsigned(addr_A)));
        end if;

        -- Lecture port B
        if (W = '1' and addr_B = addr_W) then
            QB <= DATA;
        else
            QB <= regs(to_integer(unsigned(addr_B)));
        end if;
    end process;

end Behavioral;
