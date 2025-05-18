----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2025 11:57:09 PM
-- Design Name: 
-- Module Name: register_bench_test - Simulation
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


entity register_bench_test is
end register_bench_test;

architecture Simulation of register_bench_test is

    signal addr_A, addr_B, addr_W : STD_LOGIC_VECTOR(3 downto 0);
    signal W, RST, CLK : STD_LOGIC := '0';
    signal DATA : STD_LOGIC_VECTOR(7 downto 0);
    signal QA, QB : STD_LOGIC_VECTOR(7 downto 0);

    component register_bench
        Port (
            addr_A : in STD_LOGIC_VECTOR (3 downto 0);
            addr_B : in STD_LOGIC_VECTOR (3 downto 0);
            addr_W : in STD_LOGIC_VECTOR (3 downto 0);
            W : in STD_LOGIC;
            DATA : in STD_LOGIC_VECTOR (7 downto 0);
            RST : in STD_LOGIC;
            CLK : in STD_LOGIC;
            QA : out STD_LOGIC_VECTOR (7 downto 0);
            QB : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

begin

    uut_test: register_bench
        port map (
            addr_A => addr_A,
            addr_B => addr_B,
            addr_W => addr_W,
            W => W,
            DATA => DATA,
            RST => RST,
            CLK => CLK,
            QA => QA,
            QB => QB
        );

    -- Clock process
    clk_process : process
    begin
        while now < 200 ns loop
            CLK <= '0';
            wait for 5 ns;
            CLK <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    -- process stimulus
    stim_proc: process
    begin
        -- Reset
        RST <= '1';
        wait for 10 ns;
        RST <= '0';
        wait for 10 ns;

        -- Ecriture de 0xAA dans le registre 1
        addr_W <= "0001";
        DATA <= x"AA";
        W <= '1';
        wait for 10 ns;
        W <= '0';
        wait for 10 ns;

        -- Lecture des registre 1 et 0 sur QA et QB
        addr_A <= "0001";
        addr_B <= "0000";
        wait for 10 ns;

        -- On ecrit 0x55 dans le registre 2 et on lit la valeur immediatemment (bypass)
        addr_W <= "0010";
        DATA <= x"55";
        W <= '1';
        addr_A <= "0010";
        wait for 10 ns;
        W <= '0';
        wait for 10 ns;

        -- End simulation
        wait;
    end process;

end Simulation;
