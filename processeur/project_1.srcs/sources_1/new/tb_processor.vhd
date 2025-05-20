library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_processor is
end tb_processor;

architecture Behavioral of tb_processor is
    -- Signaux pour le processeur
    signal CLK : STD_LOGIC := '0';
    signal RST : STD_LOGIC := '0';
    signal QA : STD_LOGIC_VECTOR(7 downto 0);
    signal QB : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Constante pour la période d'horloge
    constant CLK_PERIOD : time := 10 ns;
    
    -- Composant du processeur
    component processor
        Port (
            CLK : in STD_LOGIC;
            RST : in STD_LOGIC;
            QA : out STD_LOGIC_VECTOR(7 downto 0);
            QB : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
begin
    -- Instanciation du processeur
    UUT: processor
        port map (
            CLK => CLK,
            RST => RST,
            QA => QA,
            QB => QB
        );
    
    -- Génération de l'horloge
    CLK_process: process
    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;
        CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Processus de test
    stim_proc: process
    begin
        -- Reset initial
        RST <= '1';
        wait for CLK_PERIOD * 2;
        RST <= '0';
        wait for CLK_PERIOD * 2;
        
        -- Test AFC (Affectation) - AFC R1, 42
        -- Attendre que l'instruction soit exécutée
        wait for CLK_PERIOD * 5;
        
        -- Test ADD - ADD R2, R1, R1
        wait for CLK_PERIOD * 5;
        
        -- Test MUL - MUL R3, R2, R1
        wait for CLK_PERIOD * 5;
        
        -- Test SOU - SOU R4, R3, R1
        wait for CLK_PERIOD * 5;
        
        -- Test COP - COP R5, R4
        wait for CLK_PERIOD * 5;
        
        -- Test LOAD - LOAD R6, R1
        wait for CLK_PERIOD * 5;
        
        -- Test STORE - STORE R1, R6
        wait for CLK_PERIOD * 5;
        
        -- Fin de la simulation
        wait for CLK_PERIOD * 2;
        wait;
    end process;
    
end Behavioral; 