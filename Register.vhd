LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY Register IS
	PORT (
		d : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		clk, rst, enable : IN STD_LOGIC;
		q : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END ENTITY Reg;
ARCHITECTURE Reg_IMP OF Register IS
	SIGNAL wire : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
BEGIN
	wire <= d;
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1'THEN
			q <= (OTHERS => '0');
		ELSIF falling_edge(clk) AND enable = '1' THEN
			q <= wire;
		END IF;
	END PROCESS;
END Reg_IMP;