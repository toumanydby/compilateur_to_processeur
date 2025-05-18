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
    type rom_type is array(0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    signal rom : rom_type := (
        -- Programme de test pour AFC, COP, opérations arithmétiques, LOAD et STORE
        -- Format: [OPCODE(8bits)][Rdest(4bits)][Rsrc/imm1(8bits)][Rb/imm2(8bits)]
        
        -- AFC R1, 0x42 (Charge la valeur 0x42 dans R1)
        -- Opcode AFC = 0x06, R1 = 0x1, val = 0x42
        0 => x"06010042",
        
        -- AFC R2, 0x24 (Charge la valeur 0x24 dans R2)
        -- Opcode AFC = 0x06, R2 = 0x2, val = 0x24
        1 => x"06020024",
        
        -- COP R3, R1 (Copie le contenu de R1 dans R3)
        -- Opcode COP = 0x05, R3 = 0x3, R1 = 0x1
        2 => x"05030100",
        
        -- ADD R4, R1, R2 (R4 = R1 + R2)
        -- Opcode ADD = 0x01, R4 = 0x4, R1 = 0x1, R2 = 0x2
        3 => x"01040102",
        
        -- SOU R5, R1, R2 (R5 = R1 - R2)
        -- Opcode SOU = 0x03, R5 = 0x5, R1 = 0x1, R2 = 0x2
        4 => x"03050102",
        
        -- MUL R6, R1, R2 (R6 = R1 * R2)
        -- Opcode MUL = 0x02, R6 = 0x6, R1 = 0x1, R2 = 0x2
        5 => x"02060102",
        
        -- DIV R7, R1, R2 (R7 = R1 / R2)
        -- Opcode DIV = 0x04, R7 = 0x7, R1 = 0x1, R2 = 0x2
        6 => x"04070102",
        
        -- AFC R8, 0x10 (Définit l'adresse mémoire 0x10)
        7 => x"06080010",
        
        -- STORE @R8, R1 (Stocke R1 à l'adresse @R8)
        -- Opcode STORE = 0x08, @R8 = 0x8, R1 = 0x1
        8 => x"08080100",
        
        -- LOAD R9, @R8 (Charge dans R9 la valeur à l'adresse @R8)
        -- Opcode LOAD = 0x07, R9 = 0x9, @R8 = 0x8
        9 => x"07090800",
        
        -- AFC R10, 0x20 (Définit une autre adresse mémoire 0x20)
        10 => x"060A0020",
        
        -- STORE @R10, R2 (Stocke R2 à l'adresse @R10)
        11 => x"080A0200",
        
        -- LOAD R11, @R10 (Charge dans R11 la valeur à l'adresse @R10)
        12 => x"070B0A00",
        
        -- Instructions supplémentaires (boucle sur NOP)
        others => x"00000000" -- NOP ou instruction invalide
    );
    signal out_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            out_reg <= rom(to_integer(unsigned(addr)));
        end if;
    end process;
    OUT_DATA <= out_reg;
end Behavioral; 