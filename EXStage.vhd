LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Execute IS
	PORT (
        clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
        Enable_EBuffer : IN STD_LOGIC;
		-- intr : IN STD_LOGIC;
        InPortValueIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		RSource : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        RDest : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Imm_16 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        DestAddr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        ALUOp : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        ALUsrc : IN STD_LOGIC;
		Branch : IN STD_LOGIC; 
		MEMRead : IN STD_LOGIC;
		MEMWrite : IN STD_LOGIC;
		RegWrite : IN STD_LOGIC;
        MemTOReg : IN STD_LOGIC_vector(1 DOWNTO 0);
        MemAddressSelector : IN STD_LOGIC_vector(1 DOWNTO 0); 
        MemDataSelector : IN STD_LOGIC;
        LDM : IN STD_LOGIC;

        OutPorValuetIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        MEMReadOut : OUT STD_LOGIC;
		MEMWriteOut : OUT STD_LOGIC;
		RegWriteOut : OUT STD_LOGIC;
        MemTORegOut : OUT STD_LOGIC_vector(1 DOWNTO 0);
        MemAddressSelectorOut : OUT STD_LOGIC_vector(1 DOWNTO 0); 
        MemDataSelectorOut : OUT STD_LOGIC;

        CCR_Flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

        ALUOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- either ALU output or Immediate value
        RSourceOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        RDestOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DestAddrOut : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        InPortValueOUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);

        OutPortValueOUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY Execute;

ARCHITECTURE ExArch OF Execute IS

	COMPONENT ALU IS
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
    END COMPONENT;

    COMPONENT Reg IS 
		GENERIC (N : integer := 16);
		PORT( Clk,Rst,en : IN std_logic;
			d : IN std_logic_vector(N-1 DOWNTO 0);
			q : OUT std_logic_vector(N-1 DOWNTO 0));
	END COMPONENT;

    SIGNAL op2Sig : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ALUOutsig : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL ALU_C, ALU_Z, ALU_N : STD_LOGIC := '0';

	SIGNAL E_M1_Buffer_input: std_logic_vector(90 DOWNTO 0);
    SIGNAL E_M1_Buffer_result: std_logic_vector(90 DOWNTO 0);
    SIGNAL tempCCR : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    
BEGIN

    op2Sig <= RDest when ALUsrc = '0' else Imm_16;

    ALU1 : ALU PORT MAP(RSource, op2Sig, ALUOp, '0', ALUOutsig, ALU_C, ALU_Z, ALU_N);

    --To handle the case of LDM
    AluOutsig <= Imm_16 when LDM = '1' else ALUOutsig;

    tempCCR <= (ALU_C & ALU_N & ALU_Z );
    
    CCR : Reg GENERIC MAP(3) PORT MAP (clk, rst, Enable_EBuffer, tempCCR, CCR_Flags);

    E_M1_Buffer_input <= OutPorValuetIN &InPortValueIN & MEMRead & MEMWrite & RegWrite & MemTOReg & MemAddressSelector & MemDataSelector & ALUOutsig & RSource & RDest & DestAddr;
    Execute_Mem1_buffer : Reg GENERIC MAP(91) PORT MAP (clk, rst, Enable_EBuffer, E_M1_Buffer_input, E_M1_Buffer_result);
    OutPortValueOUT <= E_M1_Buffer_result(90 DOWNTO 75);
    InPortValueOUT <= E_M1_Buffer_result(74 DOWNTO 59);
    MEMReadOut <= E_M1_Buffer_result(58);
    MEMWriteOut <= E_M1_Buffer_result(57);
    RegWriteOut <= E_M1_Buffer_result(56);
    MemTORegOut <= E_M1_Buffer_result(55 DOWNTO 54);
    MemAddressSelectorOut <= E_M1_Buffer_result(53 DOWNTO 52);
    MemDataSelectorOut <= E_M1_Buffer_result(51);
    ALUOut <= E_M1_Buffer_result(50 DOWNTO 35);
    RSourceOut <= E_M1_Buffer_result(34 DOWNTO 19);
    RDestOut <= E_M1_Buffer_result(18 DOWNTO 3);
    DestAddrOut <= E_M1_Buffer_result(2 DOWNTO 0);
	
END ExArch;
