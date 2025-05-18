library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity processor is
    Port (
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        QA : out STD_LOGIC_VECTOR(7 downto 0);
        QB : out STD_LOGIC_VECTOR(7 downto 0)
    );
end processor;

architecture Behavioral of processor is
    -- Signaux pour le compteur d'instructions
    signal IP_out : STD_LOGIC_VECTOR(7 downto 0);
    signal IP_load : STD_LOGIC := '0';
    signal IP_en : STD_LOGIC := '0';
    signal IP_din : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    
    -- Signaux pour la mémoire d'instructions
    signal instr_word : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Signaux pour la mémoire de données
    signal data_addr : STD_LOGIC_VECTOR(7 downto 0);
    signal data_in : STD_LOGIC_VECTOR(7 downto 0);
    signal data_out : STD_LOGIC_VECTOR(7 downto 0);
    signal data_rw : STD_LOGIC := '1'; -- 1: lecture, 0: écriture
    
    -- Signaux de décodage
    signal op_code : STD_LOGIC_VECTOR(7 downto 0);
    signal reg_dest : STD_LOGIC_VECTOR(7 downto 0);
    signal operand_A : STD_LOGIC_VECTOR(7 downto 0);
    signal operand_B : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Signaux du banc de registres
    signal addr_A, addr_B : STD_LOGIC_VECTOR(3 downto 0);
    signal addr_W : STD_LOGIC_VECTOR(3 downto 0);
    signal W : STD_LOGIC := '0';
    signal DATA : STD_LOGIC_VECTOR(7 downto 0);
    signal QA_internal, QB_internal : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Signaux pour les étages du pipeline
    -- LI/DI
    signal LIDI_A_out, LIDI_B_out, LIDI_C_out, LIDI_OP_out : STD_LOGIC_VECTOR(7 downto 0);
    
    -- DI/EX
    signal DIEX_A_out, DIEX_B_out, DIEX_C_out, DIEX_OP_out : STD_LOGIC_VECTOR(7 downto 0);
    
    -- EX/MEM
    signal EXMEM_A_out, EXMEM_B_out, EXMEM_OP_out : STD_LOGIC_VECTOR(7 downto 0);
    
    -- MEM/RE
    signal MEMRE_A_out, MEMRE_B_out, MEMRE_OP_out : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Signaux des multiplexeurs
    signal MUX1_OUT : STD_LOGIC_VECTOR(7 downto 0); -- DI/EX: QA, QB ou imm
    signal MUX2_OUT : STD_LOGIC_VECTOR(7 downto 0); -- EX/MEM: ALU_S ou DIEX_B
    signal MUX3_OUT : STD_LOGIC_VECTOR(7 downto 0); -- MEM/RE: data_out ou EXMEM_B
    signal MUX4_OUT : STD_LOGIC_VECTOR(7 downto 0); -- Pour adresse data_memory
    
    -- Signaux pour l'ALU
    signal ALU_A, ALU_B : STD_LOGIC_VECTOR(7 downto 0);
    signal ALU_S : STD_LOGIC_VECTOR(7 downto 0);
    signal ALU_Ctrl : STD_LOGIC_VECTOR(2 downto 0);
    signal ALU_N, ALU_O, ALU_C, ALU_Z : STD_LOGIC;
    
    -- Signal du LC (contrôle d'écriture)
    signal LC : STD_LOGIC := '0';
    
    -- Déclaration des composants
    component instruction_pointer
        Port (
            CLK : in STD_LOGIC;
            RST : in STD_LOGIC;
            LOAD : in STD_LOGIC;
            EN : in STD_LOGIC;
            Din : in STD_LOGIC_VECTOR(7 downto 0);
            Dout : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    component instruction_memory
        Port (
            addr : in STD_LOGIC_VECTOR(7 downto 0);
            CLK : in STD_LOGIC;
            OUT_DATA : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component data_memory
        Port (
            addr : in STD_LOGIC_VECTOR(7 downto 0);
            IN_DATA : in STD_LOGIC_VECTOR(7 downto 0);
            RW : in STD_LOGIC;
            RST : in STD_LOGIC;
            CLK : in STD_LOGIC;
            OUT_DATA : out STD_LOGIC_VECTOR(7 downto 0)
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
    
    component ALU
        Port (
            A : in STD_LOGIC_VECTOR(7 downto 0);
            B : in STD_LOGIC_VECTOR(7 downto 0);
            Ctrl_Alu : in STD_LOGIC_VECTOR(2 downto 0);
            S : out STD_LOGIC_VECTOR(7 downto 0);
            N : out STD_LOGIC;
            O : out STD_LOGIC;
            C : out STD_LOGIC;
            Z : out STD_LOGIC
        );
    end component;
    
    component stage_li_di
        Port (
            In_A : in STD_LOGIC_VECTOR(7 downto 0);
            In_B : in STD_LOGIC_VECTOR(7 downto 0);
            In_C : in STD_LOGIC_VECTOR(7 downto 0);
            In_Op : in STD_LOGIC_VECTOR(7 downto 0);
            Clk : in STD_LOGIC;
            Out_A : out STD_LOGIC_VECTOR(7 downto 0);
            Out_B : out STD_LOGIC_VECTOR(7 downto 0);
            Out_Op : out STD_LOGIC_VECTOR(7 downto 0);
            Out_C : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    component Stage_di_ex
        Port (
            In_A : in STD_LOGIC_VECTOR(7 downto 0);
            In_B : in STD_LOGIC_VECTOR(7 downto 0);
            In_C : in STD_LOGIC_VECTOR(7 downto 0);
            In_Op : in STD_LOGIC_VECTOR(7 downto 0);
            Clk : in STD_LOGIC;
            Out_A : out STD_LOGIC_VECTOR(7 downto 0);
            Out_B : out STD_LOGIC_VECTOR(7 downto 0);
            Out_Op : out STD_LOGIC_VECTOR(7 downto 0);
            Out_C : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    component Stage_ex_mem
        Port (
            In_A : in STD_LOGIC_VECTOR(7 downto 0);
            In_B : in STD_LOGIC_VECTOR(7 downto 0);
            In_Op : in STD_LOGIC_VECTOR(7 downto 0);
            Clk : in STD_LOGIC;
            Out_A : out STD_LOGIC_VECTOR(7 downto 0);
            Out_B : out STD_LOGIC_VECTOR(7 downto 0);
            Out_Op : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    component Stage_mem_re
        Port (
            In_A : in STD_LOGIC_VECTOR(7 downto 0);
            In_B : in STD_LOGIC_VECTOR(7 downto 0);
            In_Op : in STD_LOGIC_VECTOR(7 downto 0);
            Clk : in STD_LOGIC;
            Out_A : out STD_LOGIC_VECTOR(7 downto 0);
            Out_B : out STD_LOGIC_VECTOR(7 downto 0);
            Out_Op : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
begin
    -- Instanciation du compteur de programme
    IP: instruction_pointer
        port map (
            CLK => CLK,
            RST => RST,
            LOAD => IP_load,
            EN => IP_en,
            Din => IP_din,
            Dout => IP_out
        );
    
    -- Instanciation de la mémoire d'instructions
    IMEM: instruction_memory
        port map (
            addr => IP_out,
            CLK => CLK,
            OUT_DATA => instr_word
        );
    
    -- Décodage de l'instruction
    op_code <= instr_word(31 downto 24);
    reg_dest <= "0000" & instr_word(23 downto 20);
    operand_A <= instr_word(19 downto 12);
    operand_B <= instr_word(11 downto 4);
    
    -- Étage LI/DI
    LIDI: stage_li_di
        port map (
            In_A => operand_A,
            In_B => operand_B,
            In_C => reg_dest,
            In_Op => op_code,
            Clk => CLK,
            Out_A => LIDI_A_out,
            Out_B => LIDI_B_out,
            Out_C => LIDI_C_out,
            Out_Op => LIDI_OP_out
        );
    
    -- Banc de registres (accès en lecture à l'étage DI)
    addr_A <= LIDI_A_out(3 downto 0); -- Registre source A pour COP, ADD, etc.
    addr_B <= LIDI_B_out(3 downto 0); -- Registre source B pour ADD, etc.
    
    -- MUX1: Multiplexeur pour choisir entre QA (pour COP) ou operand_B (pour AFC) ou QB (pour instr. arithmétiques)
    -- Logique du MUX1:
    --   COP (0x05) -> QA_internal (valeur du registre source A)
    --   ADD/SOU/MUL/DIV (0x01/0x02/0x03/0x04) -> QB_internal (valeur du registre source B)
    --   AFC (0x06) ou autres -> LIDI_B_out (valeur immédiate)
    process(LIDI_OP_out, QA_internal, QB_internal, LIDI_B_out)
    begin
        case LIDI_OP_out is
            when x"05" => -- COP
                MUX1_OUT <= QA_internal;
            when x"01" | x"02" | x"03" | x"04" => -- ADD, SOU, MUL, DIV
                MUX1_OUT <= QB_internal;
            when others => -- AFC et autres
                MUX1_OUT <= LIDI_B_out;
        end case;
    end process;
    
    -- Étage DI/EX
    DIEX: Stage_di_ex
        port map (
            In_A => LIDI_A_out,
            In_B => MUX1_OUT, -- Sortie du multiplexeur MUX1
            In_C => LIDI_C_out,
            In_Op => LIDI_OP_out,
            Clk => CLK,
            Out_A => DIEX_A_out,
            Out_B => DIEX_B_out,
            Out_C => DIEX_C_out,
            Out_Op => DIEX_OP_out
        );
    
    -- UAL - Configuration et instanciation
    ALU_A <= QA_internal; -- Première opérande (registre A)
    ALU_B <= DIEX_B_out;  -- Deuxième opérande (sortie du MUX1)
    
    -- Configuration du Ctrl_ALU en fonction de l'opcode
    process(DIEX_OP_out)
    begin
        case DIEX_OP_out is
            when x"01" => ALU_Ctrl <= "000"; -- ADD
            when x"02" => ALU_Ctrl <= "010"; -- MUL
            when x"03" => ALU_Ctrl <= "001"; -- SOU
            when x"04" => ALU_Ctrl <= "011"; -- DIV
            when others => ALU_Ctrl <= "111"; -- Opération non définie
        end case;
    end process;
    
    -- Instanciation de l'ALU
    ALU_UNIT: ALU
        port map (
            A => ALU_A,
            B => ALU_B,
            Ctrl_Alu => ALU_Ctrl,
            S => ALU_S,
            N => ALU_N,
            O => ALU_O,
            C => ALU_C,
            Z => ALU_Z
        );
    
    -- MUX2: Multiplexeur pour choisir entre DIEX_B_out (pour AFC/COP) ou ALU_S (pour instr. arithmétiques)
    -- Logique du MUX2:
    --   ADD/SOU/MUL/DIV (0x01/0x02/0x03/0x04) -> ALU_S (résultat de l'ALU)
    --   AFC/COP (0x06/0x05) -> DIEX_B_out (valeur directe ou de registre)
    process(DIEX_OP_out, DIEX_B_out, ALU_S)
    begin
        case DIEX_OP_out is
            when x"01" | x"02" | x"03" | x"04" => -- ADD, SOU, MUL, DIV
                MUX2_OUT <= ALU_S;
            when others => -- AFC, COP et autres
                MUX2_OUT <= DIEX_B_out;
        end case;
    end process;
    
    -- Étage EX/MEM
    EXMEM: Stage_ex_mem
        port map (
            In_A => DIEX_A_out,
            In_B => MUX2_OUT, -- Sortie du multiplexeur MUX2
            In_Op => DIEX_OP_out,
            Clk => CLK,
            Out_A => EXMEM_A_out,
            Out_B => EXMEM_B_out,
            Out_Op => EXMEM_OP_out
        );
    
    -- MUX4: Multiplexeur pour déterminer l'adresse mémoire (pour LOAD/STORE)
    -- Pour LOAD (0x07): l'adresse est dans EXMEM_B_out
    -- Pour STORE (0x08): l'adresse est dans EXMEM_A_out
    process(EXMEM_OP_out, EXMEM_A_out, EXMEM_B_out)
    begin
        if EXMEM_OP_out = x"08" then -- STORE
            MUX4_OUT <= EXMEM_A_out;
        else -- LOAD ou autres
            MUX4_OUT <= EXMEM_B_out;
        end if;
    end process;
    
    -- Contrôle RW pour la mémoire de données
    process(EXMEM_OP_out)
    begin
        if EXMEM_OP_out = x"08" then -- STORE
            data_rw <= '0'; -- Mode écriture
        else
            data_rw <= '1'; -- Mode lecture par défaut
        end if;
    end process;
    
    -- Configuration pour la mémoire de données
    data_addr <= MUX4_OUT;
    data_in <= QA_internal when EXMEM_OP_out = x"08" else (others => '0'); -- Donnée à écrire pour STORE
    
    -- Instanciation de la mémoire de données
    DMEM: data_memory
        port map (
            addr => data_addr,
            IN_DATA => data_in,
            RW => data_rw,
            RST => RST,
            CLK => CLK,
            OUT_DATA => data_out
        );
    
    -- MUX3: Multiplexeur pour choisir entre EXMEM_B_out ou data_out (pour LOAD)
    -- Logique du MUX3:
    --   LOAD (0x07) -> data_out (valeur lue de la mémoire)
    --   Autres -> EXMEM_B_out
    process(EXMEM_OP_out, EXMEM_B_out, data_out)
    begin
        if EXMEM_OP_out = x"07" then -- LOAD
            MUX3_OUT <= data_out;
        else
            MUX3_OUT <= EXMEM_B_out;
        end if;
    end process;
    
    -- Étage MEM/RE
    MEMRE: Stage_mem_re
        port map (
            In_A => EXMEM_A_out,
            In_B => MUX3_OUT, -- Sortie du multiplexeur MUX3
            In_Op => EXMEM_OP_out,
            Clk => CLK,
            Out_A => MEMRE_A_out,
            Out_B => MEMRE_B_out,
            Out_Op => MEMRE_OP_out
        );
    
    -- Banc de registres (écriture à l'étage RE)
    REGS: register_bench
        port map (
            addr_A => addr_A,
            addr_B => addr_B,
            addr_W => MEMRE_A_out(3 downto 0), -- Registre destination
            W => LC,
            DATA => MEMRE_B_out, -- Donnée à écrire 
            RST => RST,
            CLK => CLK,
            QA => QA_internal,
            QB => QB_internal
        );
    
    -- Logique de contrôle pour l'écriture dans le banc de registres (LC)
    process(MEMRE_OP_out)
    begin
        case MEMRE_OP_out is
            when x"01" | x"02" | x"03" | x"04" | x"05" | x"06" | x"07" => -- ADD, MUL, SOU, DIV, COP, AFC, LOAD
                LC <= '1';
            when others => -- STORE et autres
                LC <= '0'; 
        end case;
    end process;
    
    -- IP toujours actif (pas de saut pour l'instant)
    IP_en <= '0';
    
    -- Sorties vers l'extérieur
    QA <= QA_internal;
    QB <= QB_internal;
    
end Behavioral; 