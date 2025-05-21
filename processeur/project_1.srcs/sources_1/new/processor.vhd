library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity processor is
    Port (
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC
    );
end processor;

architecture Behavioral of processor is
    -- Mémoire d'instructions
    component instruction_memory
        Port (
            addr : in STD_LOGIC_VECTOR(7 downto 0);
            CLK  : in STD_LOGIC;
            OUT_DATA : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    -- Banc de registres
    component register_bench
        Port (
            addr_A : in STD_LOGIC_VECTOR(3 downto 0);
            addr_B : in STD_LOGIC_VECTOR(3 downto 0);
            addr_W : in STD_LOGIC_VECTOR(3 downto 0);
            W      : in STD_LOGIC;
            DATA   : in STD_LOGIC_VECTOR(7 downto 0);
            RST    : in STD_LOGIC;
            CLK    : in STD_LOGIC;
            QA     : out STD_LOGIC_VECTOR(7 downto 0);
            QB     : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- ALU
    component ALU
        Port (
            A    : in  STD_LOGIC_VECTOR(7 downto 0);
            B    : in  STD_LOGIC_VECTOR(7 downto 0);
            CTRL_ALU : in  STD_LOGIC_VECTOR(2 downto 0);
            S    : out STD_LOGIC_VECTOR(7 downto 0);
            N    : out STD_LOGIC;
            O    : out STD_LOGIC;
            C    : out STD_LOGIC;
            Z    : out STD_LOGIC
        );
    end component;

    -- data memory
    component data_memory is
        Port (
            addr : in STD_LOGIC_VECTOR(7 downto 0);
            IN_DATA : in STD_LOGIC_VECTOR(7 downto 0);
            RW : in STD_LOGIC; -- 1: lecture, 0: écriture
            RST : in STD_LOGIC;
            CLK : in STD_LOGIC;
            OUT_DATA : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    -- Stages pipeline
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

    -- PC et instruction courante
    signal PC : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal instr_word : STD_LOGIC_VECTOR(31 downto 0);

    -- Signaux pipeline
    signal LI_OP, LI_A, LI_B, LI_C : STD_LOGIC_VECTOR(7 downto 0);
    signal DI_OP, DI_A, DI_B, DI_C : STD_LOGIC_VECTOR(7 downto 0);
    signal EX_OP, EX_A, EX_B : STD_LOGIC_VECTOR(7 downto 0);
    signal MEM_OP, MEM_A, MEM_B : STD_LOGIC_VECTOR(7 downto 0);
    signal RE_OP, RE_A, RE_B : STD_LOGIC_VECTOR(7 downto 0);

    -- Banc de registres
    signal ADDR_A, ADDR_B, ADDR_W : STD_LOGIC_VECTOR(3 downto 0);
    signal W : STD_LOGIC := '0';
    signal DATA : STD_LOGIC_VECTOR(7 downto 0);
    signal QA_signal, QB_signal : STD_LOGIC_VECTOR(7 downto 0);

    -- ALU
    signal ALU_A, ALU_B, ALU_S : STD_LOGIC_VECTOR(7 downto 0);
    signal CTRL_ALU : STD_LOGIC_VECTOR(2 downto 0);
    signal ALU_N, ALU_O, ALU_C, ALU_Z : STD_LOGIC;

    -- Mémoire de données
    signal LC_MEMDONNEES : STD_LOGIC;
    signal MEMDOUT, MENDINDATA : STD_LOGIC_VECTOR(7 downto 0);
    signal ADDR_MEM : STD_LOGIC_VECTOR(7 downto 0);
    -- Signaux pour les multiplexeurs
    signal MUX_A_EX, MUX_B_EX, MUX_LOAD_MEM, MUX_STORE_MEM : STD_LOGIC_VECTOR(7 downto 0);
    signal MUX_DATA_RE : STD_LOGIC_VECTOR(7 downto 0);

begin
    -- Mémoire d'instructions
    IMEM: instruction_memory
        port map (
            addr => PC,
            CLK => CLK,
            OUT_DATA => instr_word
        );

    -- Pipeline LI/DI
    STAGE_LIDI: stage_li_di
        port map (
            In_A => instr_word(23 downto 16),
            In_B => instr_word(15 downto 8),
            In_C => instr_word(7 downto 0),
            In_Op => instr_word(31 downto 24),
            Clk => CLK,
            Out_A => LI_A,
            Out_B => LI_B,
            Out_C => LI_C,
            Out_Op => LI_OP
        );

    -- Pipeline DI/EX
    STAGE_DIEX: Stage_di_ex
        port map (
            In_A => LI_A,
            In_B => MUX_A_EX,
            In_C => LI_C,
            In_Op => LI_OP,
            Clk => CLK,
            Out_A => DI_A,
            Out_B => DI_B,
            Out_C => DI_C,
            Out_Op => DI_OP
        );

    -- Pipeline EX/MEM
    STAGE_EXMEM: Stage_ex_mem
        port map (
            In_A => DI_A,
            In_B => MUX_B_EX,
            In_Op => DI_OP,
            Clk => CLK,
            Out_A => EX_A,
            Out_B => EX_B,
            Out_Op => EX_OP
        );

    -- Pipeline MEM/RE
    STAGE_MEMRE: Stage_mem_re
        port map (
            In_A => EX_A,
            In_B => MUX_LOAD_MEM,
            In_Op => EX_OP,
            Clk => CLK,
            Out_A => MEM_A,
            Out_B => MEM_B,
            Out_Op => MEM_OP
        );

    -- Pipeline RE (registre final)
    process(CLK)
    begin
        if rising_edge(CLK) then
            RE_A <= MEM_A;
            RE_B <= MEM_B;
            RE_OP <= MEM_OP;
            -- Incrémentation du PC
            PC <= std_logic_vector(unsigned(PC) + 1);
        end if;
    end process;

    -- Sélection des adresses pour le banc de registres
    ADDR_A <= LI_B(3 downto 0); -- Source principale (pour instructions arithmétiques et COP)
    ADDR_B <= LI_C(3 downto 0); -- Source secondaire (pour instructions arithmétiques)

    -- MUX1 (entrée A de l'ALU à l'étage EX)
    MUX_A_EX <= QA_signal when LI_OP = x"01" or LI_OP = x"02" or LI_OP = x"03" or LI_OP= x"04" or LI_OP= x"05" else -- arithmétique and COP
                    LI_B when LI_OP = x"06" or LI_OP = x"07" or LI_OP = x"08" else
                    (others => '0');


    -- MUX2 (entrée B de l'ALU à l'étage EX)
    MUX_A_EX <= ALU_S when DI_OP = x"01" or DI_OP = x"02" or DI_OP = x"03" or DI_OP= x"04" else -- arithmétique 
                    DI_B when DI_OP = x"05" or DI_OP= x"06" or DI_OP = x"07" or DI_OP = x"08"  else -- AFC COP LOAD STORE (valeur du registre source propagée)
                    (others => '0');
                        
    CTRL_ALU <=   "000" when DI_OP = x"01" else  --Addition
            "010" when DI_OP = x"02" else  -- Multiplication
             "001" when DI_OP = x"03" else  -- Sustraction
             "000";
       

    -- Connexion à l'ALU
    ALU_A <= DI_B;
    ALU_B <= DI_C;

    -- Instanciation de l'ALU
    ALU_UNIT: ALU
        port map (
            A        => ALU_A,
            B        => ALU_B,
            CTRL_ALU => CTRL_ALU,
            S        => ALU_S,
            N        => ALU_N,
            O        => ALU_O,
            C        => ALU_C,
            Z        => ALU_Z
        );

    -- LC mem donnees
    LC_MEMDONNEES <= '0' when EX_OP = x"07" else '1';
    
    MUX_LOAD_MEM <= MEMDOUT when EX_OP = x"07" else EX_B;
   
    MENDINDATA <= EX_A when EX_OP = x"08" else EX_B;
    

    -- Mémoire de données : lecture/écriture de données en mémoire
    DMEMORY : data_memory
        port map (
            addr => MENDINDATA,
            IN_DATA => EX_B ,
            RW => LC_MEMDONNEES, -- 1: lecture, 0: écriture
            RST => RST,
            CLK => CLK,
            OUT_DATA => MEMDOUT
        );
       
            
    ADDR_W <= RE_A(3 downto 0); -- Registre destination à l'étage RE

    -- Signal d'écriture LC MEM/RE
    W <= '1' when (RE_OP = x"05" or RE_OP = x"06" or RE_OP = x"01" or RE_OP = x"02" or RE_OP = x"03" or RE_OP = x"04") else '0';

    DATA <= RE_B;

    -- Banc de registres
    REGS: register_bench
        port map (
            addr_A => ADDR_A,
            addr_B => ADDR_B,
            addr_W => ADDR_W,
            W      => W,
            DATA   => DATA,
            RST    => RST,
            CLK    => CLK,
            QA     => QA_signal,
            QB     => QB_signal
        );

end Behavioral;