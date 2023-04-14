LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Memory IS
	PORT (
		clk : IN STD_LOGIC;
		MEMW : IN STD_LOGIC;
		MEMR : IN STD_LOGIC;
		address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		datain : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		dataout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END ENTITY Memory;

ARCHITECTURE Memory_IMP OF Memory IS
	TYPE memory_type IS ARRAY(0 TO 1023) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL Memory : memory_type := (OTHERS => (OTHERS => '0'));

BEGIN
	PROCESS (clk) IS
	BEGIN
		IF falling_edge(clk) THEN
			IF MEMW = '1' THEN
				Memory(to_integer(unsigned(address))) <= datain;
			END IF;
		END IF;
	END PROCESS;
	dataout <= Memory(to_integer(unsigned(address)));
END Memory_IMP;