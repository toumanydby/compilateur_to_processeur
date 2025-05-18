library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory_test is
end data_memory_test;

architecture Simulation of data_memory_test is
    signal addr     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal IN_DATA  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal RW       : STD_LOGIC := '1'; -- 1: lecture, 0: écriture
    signal RST      : STD_LOGIC := '0';
    signal CLK      : STD_LOGIC := '0';
    signal OUT_DATA : STD_LOGIC_VECTOR(7 downto 0);

    component data_memory
        Port (
            addr     : in  STD_LOGIC_VECTOR(7 downto 0);
            IN_DATA  : in  STD_LOGIC_VECTOR(7 downto 0);
            RW       : in  STD_LOGIC;
            RST      : in  STD_LOGIC;
            CLK      : in  STD_LOGIC;
            OUT_DATA : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
begin
    uut: data_memory
        port map (
            addr     => addr,
            IN_DATA  => IN_DATA,
            RW       => RW,
            RST      => RST,
            CLK      => CLK,
            OUT_DATA => OUT_DATA
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

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset
        RST <= '1';
        wait for 10 ns;
        RST <= '0';
        wait for 10 ns;

        -- Ecriture à l'adresse 0x10 de la valeur AA
        addr <= x"10";
        IN_DATA <= x"AA";
        RW <= '0'; -- écriture
        wait for 10 ns;

        -- Ecriture à l'adresse 0x20 de la valeur 55
        addr <= x"20";
        IN_DATA <= x"55";
        RW <= '0';
        wait for 10 ns;

        -- Lecture à l'adresse 0x10
        addr <= x"10";
        RW <= '1'; -- lecture
        wait for 10 ns;

        -- Lecture à l'adresse 0x20
        addr <= x"20";
        RW <= '1';
        wait for 10 ns;

        wait;
    end process;
end Simulation;
