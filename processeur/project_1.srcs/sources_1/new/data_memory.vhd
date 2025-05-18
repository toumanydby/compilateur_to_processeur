----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2025 09:18:25 AM
-- Design Name: 
-- Module Name: data_memory - Behavioral
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

entity data_memory is
    Port (
        addr : in STD_LOGIC_VECTOR(7 downto 0);
        IN_DATA : in STD_LOGIC_VECTOR(7 downto 0);
        RW : in STD_LOGIC; -- 1: lecture, 0: écriture
        RST : in STD_LOGIC;
        CLK : in STD_LOGIC;
        OUT_DATA : out STD_LOGIC_VECTOR(7 downto 0)
    );
end data_memory;

architecture Behavioral of data_memory is
    type ram_type is array(0 to 255) of STD_LOGIC_VECTOR(7 downto 0);
    signal memory : ram_type := (others => (others => '0'));
    signal out_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin
    process(CLK)
    begin
        wait until clk'event and clk = '1';
        if RST = '1' then
            memory <= (others => (others => '0'));
            out_reg <= (others => '0');
        elsif RW = '0' then -- écriture
            memory(to_integer(unsigned(addr))) <= IN_DATA;
        else -- lecture
            out_reg <= memory(to_integer(unsigned(addr)));
        end if;
    end process;
    OUT_DATA <= out_reg;
end Behavioral; 