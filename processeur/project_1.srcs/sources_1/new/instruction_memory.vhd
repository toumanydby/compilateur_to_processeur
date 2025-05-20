----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2025 10:43:05 AM
-- Design Name: 
-- Module Name: instruction_memory - Behavioral
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

entity instruction_memory is
    Port (
        addr : in STD_LOGIC_VECTOR(7 downto 0);
        CLK : in STD_LOGIC;
        OUT_DATA : out STD_LOGIC_VECTOR(31 downto 0)
    );
end instruction_memory;

architecture Behavioral of instruction_memory is
    type mem_type is array(0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    signal memory : mem_type := (
        -- AFC R1, 42
        0 => x"0600002A",  -- AFC R1, 42
        
        -- ADD R2, R1, R1
        1 => x"01010102",  -- ADD R2, R1, R1
        
        -- MUL R3, R2, R1
        2 => x"02020103",  -- MUL R3, R2, R1
        
        -- SOU R4, R3, R1
        3 => x"03030104",  -- SOU R4, R3, R1
        
        -- COP R5, R4
        4 => x"05040005",  -- COP R5, R4
        
        -- LOAD R6, R1
        5 => x"07010006",  -- LOAD R6, R1
        
        -- STORE R1, R6
        6 => x"08060001",  -- STORE R1, R6
        
        others => (others => '0')
    );
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            OUT_DATA <= memory(to_integer(unsigned(addr)));
        end if;
    end process;
end Behavioral; 