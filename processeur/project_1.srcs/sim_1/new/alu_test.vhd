----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2025 10:25:36 PM
-- Design Name: 
-- Module Name: alu_test - Simulation
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu_test is
end alu_test;

architecture Simulation of alu_test is
    component ALU is
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           S : out STD_LOGIC_VECTOR (7 downto 0);
           Ctrl_Alu : in STD_LOGIC_VECTOR (2 downto 0);
           N : out STD_LOGIC;
           O : out STD_LOGIC;
           Z : out STD_LOGIC;
           C : out STD_LOGIC);
    end component ALU;
    
    signal S_t, A_t, B_t : STD_LOGIC_VECTOR (7 downto 0);
    signal Ctrl_Alu_Test : STD_LOGIC_VECTOR (2 downto 0);
    signal N_t , O_t, Z_t, C_t : STD_LOGIC;

begin
    
    map_to_test: ALU port map(
        A => A_t,
        B => B_t,
        S => S_t,
        Ctrl_Alu => Ctrl_Alu_Test,
        N => N_t,
        O => O_t,
        Z => Z_t,
        C => C_t
    );
    
    test_op : process
        begin
            A_t <= x"08";
            B_t <= x"04";
            
            Ctrl_Alu_Test <= "000"; -- ADD
            wait for 10 ns;
            
            Ctrl_Alu_Test <= "001"; -- SUB
            wait for 10 ns;
            
            Ctrl_Alu_Test <= "010"; -- MUL 
            wait for 10 ns;
            
            Ctrl_Alu_Test <= "011"; -- DIV 
            wait for 10 ns;
            
            wait;
        end process;
end Simulation;
