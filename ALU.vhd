LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU IS
	PORT (
		A : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		op : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		-- Enable : IN STD_LOGIC;
		SETC : IN STD_LOGIC;
		Result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		Carry : OUT STD_LOGIC;
		Zero : OUT STD_LOGIC;
		Negative : OUT STD_LOGIC);
END ENTITY ALU;

ARCHITECTURE ALU_IMP OF ALU IS

BEGIN

	Result <= STD_LOGIC_VECTOR(unsigned(NOT A)) 		  WHEN op = ("00011")  			-- NOT
		ELSE
			STD_LOGIC_VECTOR(unsigned(A) + 1)			  WHEN op = ("00100")  			-- INC
		ELSE
			STD_LOGIC_VECTOR(unsigned(A) - 1) 		   	  WHEN op = ("00101")  			-- DEC
		ELSE
			A   										  WHEN op = ("01000")  			-- MOV
		ELSE
			STD_LOGIC_VECTOR(unsigned(A) OR unsigned(B))  WHEN op = ("01001")  			-- OR
		ELSE
			STD_LOGIC_VECTOR(unsigned(A) + unsigned(B))   WHEN op = ("01010") OR op = ("01101")  -- ADD/ IADD
		ELSE
			STD_LOGIC_VECTOR(unsigned(A) - unsigned(B))   WHEN op = ("01011")  			-- SUB
		ELSE
			STD_LOGIC_VECTOR(unsigned(A) AND unsigned(B)) WHEN op = ("01100");  			-- AND
                              
	
	Carry <= '1' WHEN (STD_LOGIC_VECTOR(unsigned(A) + unsigned(B)) < A) AND (op = ("01010") OR op = ("01101") OR op = ("00100"))  -- ADD/ IADD / INC
		--		For illustration:    11100
		--			               + 00110			
		--							-------           
		--			             (1) 00010    
		ELSE                                                                           													
			'1' WHEN (A < B) AND (op = ("01011") OR op = ("00101"))  -- SUB/ DEC      
		ELSE
			'1' WHEN SETC = '1'
		ELSE '0';

	Negative <= Result(15);

	Zero <= '1' WHEN Result = x"0000"  ELSE '0';

END ALU_IMP;
