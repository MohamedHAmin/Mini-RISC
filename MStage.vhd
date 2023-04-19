LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY MemoryStage IS
    PORT(
        clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;

    );
END Memory;

ARCHITECTURE MArch OF MemoryStage IS
    
    COMPONENT Reg IS 
    GENERIC (N : integer := 16);
    PORT( 
        Clk,Rst,en : IN std_logic;
        d : IN std_logic_vector(N-1 DOWNTO 0);
        q : OUT std_logic_vector(N-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT Memory IS
	PORT (
		clk : IN STD_LOGIC;
		MEMW : IN STD_LOGIC;
		MEMR : IN STD_LOGIC;
		address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		datain : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		dataout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
    END COMPONENT;

    BEGIN

END MArch; 