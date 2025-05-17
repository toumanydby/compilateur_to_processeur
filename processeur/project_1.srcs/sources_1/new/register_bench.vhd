----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2025 09:50:40 AM
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
    
    -- DEFINIR LES DIFFERENTS SIGNAUX ET AUTRES ET ASSIGNATION SI IL FAUT 
    type register_array is array(0 to 15) of STD_LOGIC_VECTOR(7 downto 0);
    signal regs: register_array := ( others => (others => '0'));
begin

    
    -- lecture
    process(regs)
    begin    
        if W = '0' then 
            QA <= regs[addr_A];
            QB <= regs[addr_B];
        end if;
    end process;
    
    -- ecriture
    process(regs)
    begin
        if W = '1' then
            regs[addr_W] <= DATA;
    end process;   
    
    RST <= '0';

end Behavioral;
