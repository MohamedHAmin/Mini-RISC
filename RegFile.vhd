LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY RegFile IS
	PORT (
		Add1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		Add2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		Wrt_Add : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		DataIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		RegWrite : IN STD_LOGIC;
		Clk : IN STD_LOGIC;
		DataOUT1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		DataOUT2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END ENTITY RegFile;

ARCHITECTURE RegFile_IMP OF RegFile IS
	TYPE OutBus IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL DataOut : OutBus := (OTHERS => (OTHERS => '0'));
	
BEGIN
	PROCESS (clk)
	BEGIN
		IF falling_edge(clk) THEN
			IF RegWrite = '1' THEN
				DataOut(to_integer(unsigned(Wrt_Add))) <= DataIN;
			END IF;
		END IF;
	END PROCESS;
	DataOUT1 <= DataOut(to_integer(unsigned(Add1)));
	DataOUT2 <= DataOut(to_integer(unsigned(Add2)));
END RegFile_IMP;