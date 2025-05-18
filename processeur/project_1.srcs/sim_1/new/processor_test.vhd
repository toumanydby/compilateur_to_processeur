library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_processor is
end tb_processor;

architecture Behavioral of tb_processor is
    -- Component Declaration
    component processor
        Port (
            CLK : in STD_LOGIC;
            RST : in STD_LOGIC;
            QA : out STD_LOGIC_VECTOR(7 downto 0);
            QB : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    -- Signals
    signal CLK : STD_LOGIC := '0';
    signal RST : STD_LOGIC := '0';
    signal QA, QB : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: processor port map (
        CLK => CLK,
        RST => RST,
        QA => QA,
        QB => QB
    );
    
    -- Clock process
    clk_process: process
    begin
        while now < 500 ns loop
            CLK <= '0';
            wait for CLK_PERIOD/2;
            CLK <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Reset initial
        RST <= '1';
        wait for 20 ns;
        RST <= '0';
        
        -- Attendre que le pipeline exécute les instructions
        -- Pour un pipeline à 5 étages, il faut au moins 5 cycles
        wait for 100 ns;
        
        -- Vérifier les résultats dans QA et QB
        -- Ces sorties devraient montrer le contenu des registres lus
        
        -- Fin de la simulation
        wait;
    end process;
    
end Behavioral;