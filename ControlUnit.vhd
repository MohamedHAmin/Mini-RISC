LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CU IS
	PORT (
		Family : IN STD_LOGIC_VECTOR(1 DOWNTO 0);  
        OpCode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        IsImmediate : IN STD_LOGIC;  -- It is the instr(16) bit, used to determine if the instruction is immediate or not

        -- 11 Control Signals
		ALUsrc : OUT STD_LOGIC;
        ALUop : OUT STD_LOGIC_vector(4 DOWNTO 0);  
        -- RegDst : OUT STD_LOGIC;
		Branch : OUT STD_LOGIC;    -- for jmp instructions
        
		MEMRead : OUT STD_LOGIC;
		MEMWrite : OUT STD_LOGIC;

		RegWrite : OUT STD_LOGIC;
        MemTOReg : OUT STD_LOGIC_vector(1 DOWNTO 0);

        RegAddressSelector : OUT STD_LOGIC; --control signal for the mux selector that selects the address 
        -- of the 2nd input to the register file, if the instruction is a jmp instruction then choose Rdst, else choose Rsrc2
        -- will and the 2 bits of the family to get the 1 bit selector of the MUX

        MemAddressSelector : OUT STD_LOGIC_vector(1 DOWNTO 0); --control signal for the mux selector that selects the address
        -- of the data memory, the selector is 2 bits which are opcode(2) and opcode(1)
        -- if 00 then choose SP (Push/Pop/Call/Ret inst.), if 01 choose Rsrc1 (Load inst.), if 10 choose Rsrc2 (Store inst.)

        MemDataSelector : OUT STD_LOGIC --control signal for the mux selector that selects the data
        -- of the data memory, the selector is 1 bit which is family(0)
        -- of 0 then choose Rsrc1 (Push/Store inst.), if 1 choose PC + 1 (Call inst.)
);
END ENTITY CU;

ARCHITECTURE CUArch OF CU IS
	-- SIGNAL jmp : STD_LOGIC := '0';
	-- SIGNAL PortEn : STD_LOGIC := '0';
BEGIN

	ALUsrc <= IsImmediate;
    ALUop <= Family & OpCode;
    
    Branch <= Family(1) and Family(0);  -- if family = 11 then branch = 1 (jmp instruction), else branch = 0

    MEMRead <= '1' when (Family = "10" and OpCode = "011") or (Family = "10" and OpCode = "001") or (Family = "11" and OpCode = "001") or (Family = "11" and OpCode = "101") -- when load, pop, Ret,RTI instruction
    else '0'; 
    MEMWrite <= '1' when (Family = "10" and OpCode = "100") or (Family = "10" and OpCode = "000") or (Family = "11" and OpCode = "000") -- when store, push, Call instruction
    else '0';

    RegWrite <= '1' when (Family = "00" and OpCode = "011") -- when NOT
                    or   (Family = "00" and OpCode = "100") -- when INC
                    or   (Family = "00" and OpCode = "101") -- when DEC
                    or   (Family = "00" and OpCode = "110") -- when IN
                    or   (Family = "01")  -- when R-type instructions
                    or   (Family = "10" and OpCode = "001") -- when POP
                    or   (Family = "10" and OpCode = "010") -- when LDM
                    or   (Family = "10" and OpCode = "011") -- when LDD
    else '0';     
    
    MemTOReg <= "10" when (Family = "10" and OpCode = "001") -- when POP
                     or   (Family = "10" and OpCode = "011") -- when LDD
    else "11"        WHEN (Family = "00" and OpCode = "110") -- when IN
    else "00"        WHEN (Family = "00" and OpCode = "000") -- when NOP
    else "01";                                               -- when ALU

    RegAddressSelector <= Family(1) and Family(0);
    MemAddressSelector <= OpCode(2) & OpCode(1);
    MemDataSelector <= Family(0);
END CUArch;