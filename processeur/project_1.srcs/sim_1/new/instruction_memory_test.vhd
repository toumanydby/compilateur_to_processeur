library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_memory_test is
end instruction_memory_test;

architecture Simulation of instruction_memory_test is
    signal addr     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal CLK      : STD_LOGIC := '0';
    signal OUT_DATA : STD_LOGIC_VECTOR(31 downto 0);

    component instruction_memory
        Port (
            addr     : in  STD_LOGIC_VECTOR(7 downto 0);
            CLK      : in  STD_LOGIC;
            OUT_DATA : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
begin
    uut: instruction_memory
        port map (
            addr     => addr,
            CLK      => CLK,
            OUT_DATA => OUT_DATA
        );

    -- Clock process
    clk_process : process
    begin
        while now < 100 ns loop
            CLK <= '0';
            wait for 5 ns;
            CLK <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Lecture à l'adresse 0
        addr <= x"00";
        wait for 10 ns;

        -- Lecture à l'adresse 1
        addr <= x"01";
        wait for 10 ns;

        -- Lecture à l'adresse 2
        addr <= x"02";
        wait for 10 ns;

        -- Lecture à l'adresse 3
        addr <= x"03";
        wait for 10 ns;

        wait;
    end process;
end Simulation;