LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU IS
	PORT (
		A : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		op : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		Enable : IN STD_LOGIC;
		SETC : IN STD_LOGIC;
		Result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		Carry : OUT STD_LOGIC;
		Zero : OUT STD_LOGIC;
		Negative : OUT STD_LOGIC);
END ENTITY ALU;

ARCHITECTURE ALU_IMP OF ALU IS

END ALU_IMP;
