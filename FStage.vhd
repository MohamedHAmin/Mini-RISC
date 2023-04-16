LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Fetch IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		Enable_Buffer : IN STD_LOGIC;
		-- intr : IN STD_LOGIC;
		-- Ins : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- PC_Enable : IN STD_LOGIC;
        Family : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		OpCode : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		RS : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		RT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		RD : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		Imm : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END ENTITY Fetch;

ARCHITECTURE Fetch_IMP OF Fetch IS

	TYPE Instruction_cache IS ARRAY(0 TO 1023) of std_logic_vector(15 DOWNTO 0);
	

	COMPONENT Reg IS 
		GENERIC (N : integer := 16);
		PORT( Clk,Rst,en : IN std_logic;
			d : IN std_logic_vector(N-1 DOWNTO 0);
			q : OUT std_logic_vector(N-1 DOWNTO 0));
	END COMPONENT;

	SIGNAL Inst_signal : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL bufferOut : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- SIGNAL pcsigout : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
	-- SIGNAL pcsigin : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
	-- SIGNAL Enable : STD_LOGIC := '1';
	-- Signal temp1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	-- Signal temp2 : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

	PROCESS(clk,rst) IS
	
	VARIABLE Cache : Instruction_cache;

	VARIABLE pcsigout : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
	VARIABLE pcsigin : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
	VARIABLE Inst : STD_LOGIC_VECTOR(31 DOWNTO 0);

	VARIABLE temp1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	VARIABLE temp2 : STD_LOGIC_VECTOR(15 DOWNTO 0);

	BEGIN
		if rst = '1' then
			pcsigout := (OTHERS => '0');   -- reset pc to 0 (1st address of instruction cache)
			-- Enable <= '1';
			Family 	<= (OTHERS => '0');
			Opcode 	<= (OTHERS => '0');
			RS		<= (OTHERS => '0');
			RT 		<= (OTHERS => '0');
			RD 		<= (OTHERS => '0');
			IMM 	<= (OTHERS => '0');
		else
			IF rising_edge(clk) THEN  
				-- IF Enable = '1' THEN
				temp1 := Cache(to_integer(unsigned((pcsigout))));
				temp2 := Cache(to_integer(unsigned((pcsigout))) + 1);
				inst := temp1 & temp2;

				if inst(16) = '0' then
					pcsigin := STD_LOGIC_VECTOR(unsigned(pcsigout) + 1);
				elsif inst(16) = '1' then
					pcsigin := STD_LOGIC_VECTOR(unsigned(pcsigout) + 2);
				end if;
				
				pcsigout := pcsigin;
				-- END IF;
			END IF;
		end if;

		Inst_signal <= inst;
	END PROCESS;

	Fetch_Decode_buffer : Reg GENERIC MAP (32) PORT MAP (clk,rst,Enable_Buffer,Inst_signal,bufferOut);
	Family <= bufferOut(31 DOWNTO 30);
	Opcode <= bufferOut(29 DOWNTO 27);
    RS <= bufferOut(26 DOWNTO 24);
    RT <= bufferOut(23 DOWNTO 21);
    RD <= bufferOut(20 DOWNTO 18);
    IMM <= bufferOut(15 DOWNTO 0);

    
END Fetch_IMP;
