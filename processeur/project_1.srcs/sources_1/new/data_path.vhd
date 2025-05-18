library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_path is
    Port (
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC
    );
end data_path;

architecture Behavioral of data_path is
    -- Compteur de programme (IP)
    signal IP : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    
    -- Signaux pour les mémoires
    signal instr_word : STD_LOGIC_VECTOR(31 downto 0); -- Sortie mémoire instructions
    
    -- Signaux banc de registres
    signal addr_A, addr_B, addr_W : STD_LOGIC_VECTOR(3 downto 0);
    signal W : STD_LOGIC := '0';
    signal DATA : STD_LOGIC_VECTOR(7 downto 0);
    signal QA, QB : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Registres du pipeline LI/DI
    signal LIDI_A : STD_LOGIC_VECTOR(7 downto 0); -- Opérande A
    signal LIDI_B : STD_LOGIC_VECTOR(7 downto 0); -- Opérande B
    signal LIDI_OP : STD_LOGIC_VECTOR(7 downto 0); -- Code opération
    signal LIDI_C : STD_LOGIC_VECTOR(3 downto 0); -- Registre destination
    
    -- Registres du pipeline DI/EX
    signal DIEX_A : STD_LOGIC_VECTOR(7 downto 0);
    signal DIEX_B : STD_LOGIC_VECTOR(7 downto 0);
    signal DIEX_OP : STD_LOGIC_VECTOR(7 downto 0);
    signal DIEX_C : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Registres du pipeline EX/MEM
    signal EXMEM_A : STD_LOGIC_VECTOR(7 downto 0);
    signal EXMEM_B : STD_LOGIC_VECTOR(7 downto 0);
    signal EXMEM_OP : STD_LOGIC_VECTOR(7 downto 0);
    signal EXMEM_C : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Registres du pipeline MEM/RE
    signal MEMRE_A : STD_LOGIC_VECTOR(7 downto 0);
    signal MEMRE_B : STD_LOGIC_VECTOR(7 downto 0);
    signal MEMRE_OP : STD_LOGIC_VECTOR(7 downto 0);
    signal MEMRE_C : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Signaux de contrôle pour le multiplexeur
    signal MUX_OUT : STD_LOGIC_VECTOR(7 downto 0);
    signal LC : STD_LOGIC := '0';
    
    -- Composants
    component instruction_memory
        Port (
            addr : in STD_LOGIC_VECTOR(7 downto 0);
            CLK : in STD_LOGIC;
            OUT_DATA : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component register_bench
        Port (
            addr_A : in STD_LOGIC_VECTOR(3 downto 0);
            addr_B : in STD_LOGIC_VECTOR(3 downto 0);
            addr_W : in STD_LOGIC_VECTOR(3 downto 0);
            W : in STD_LOGIC;
            DATA : in STD_LOGIC_VECTOR(7 downto 0);
            RST : in STD_LOGIC;
            CLK : in STD_LOGIC;
            QA : out STD_LOGIC_VECTOR(7 downto 0);
            QB : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
begin
    -- Mémoire d'instructions
    imem: instruction_memory
        port map (
            addr => IP,
            CLK => CLK,
            OUT_DATA => instr_word
        );
    
    -- Banc de registres
    regfile: register_bench
        port map (
            addr_A => addr_A,
            addr_B => addr_B,
            addr_W => MEMRE_C, -- Registre destination venant du pipeline
            W => LC,           -- Signal de contrôle d'écriture
            DATA => MEMRE_B,   -- Donnée à écrire
            RST => RST,
            CLK => CLK,
            QA => QA,
            QB => QB
        );
    
    -- Processus principal du pipeline
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                -- Reset du pipeline et de l'IP
                IP <= (others => '0');
                LIDI_A <= (others => '0');
                LIDI_B <= (others => '0');
                LIDI_OP <= (others => '0');
                LIDI_C <= (others => '0');
                DIEX_A <= (others => '0');
                DIEX_B <= (others => '0');
                DIEX_OP <= (others => '0');
                DIEX_C <= (others => '0');
                EXMEM_A <= (others => '0');
                EXMEM_B <= (others => '0');
                EXMEM_OP <= (others => '0');
                EXMEM_C <= (others => '0');
                MEMRE_A <= (others => '0');
                MEMRE_B <= (others => '0');
                MEMRE_OP <= (others => '0');
                MEMRE_C <= (others => '0');
                LC <= '0';
            else
                -- 1. Étage LI/DI - Lecture de l'instruction
                IP <= std_logic_vector(unsigned(IP) + 1);
                LIDI_OP <= instr_word(31 downto 24); -- Code opération
                LIDI_C <= instr_word(23 downto 20);  -- Registre destination
                LIDI_A <= instr_word(19 downto 12);  -- Opérande A ou registre source
                LIDI_B <= instr_word(11 downto 4);   -- Opérande B ou valeur immédiate
                
                -- Adresses pour la lecture des registres
                addr_A <= instr_word(19 downto 16);  -- Adresse du registre A
                addr_B <= instr_word(11 downto 8);   -- Adresse du registre B
                
                -- 2. Étage DI/EX - Décodage/Exécution
                DIEX_OP <= LIDI_OP;
                DIEX_C <= LIDI_C;
                DIEX_A <= LIDI_A;
                
                -- Multiplexeur pour B (selon illustration 2)
                -- Si COP (opcode 0x05), on choisit QA (valeur du registre)
                -- Si AFC (opcode 0x06), on prend la valeur immédiate
                if LIDI_OP = x"05" then  -- COP
                    DIEX_B <= QA;  -- Valeur lue du registre
                else  -- AFC ou autre
                    DIEX_B <= LIDI_B;  -- Valeur immédiate
                end if;
                
                -- 3. Étage EX/MEM - Exécution/Mémoire
                EXMEM_OP <= DIEX_OP;
                EXMEM_C <= DIEX_C;
                EXMEM_A <= DIEX_A;
                EXMEM_B <= DIEX_B;
                
                -- 4. Étage MEM/RE - Mémoire/Re-Écriture
                MEMRE_OP <= EXMEM_OP;
                MEMRE_C <= EXMEM_C;
                MEMRE_A <= EXMEM_A;
                MEMRE_B <= EXMEM_B;
                
                -- 5. Contrôle pour l'écriture dans le banc de registres
                -- Activer l'écriture si instruction AFC ou COP
                if MEMRE_OP = x"06" or MEMRE_OP = x"05" then
                    LC <= '1';
                else
                    LC <= '0';
                end if;
            end if;
        end if;
    end process;
    
end Behavioral; 