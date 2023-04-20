LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Decode IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
        Enable_DBuffer : IN STD_LOGIC;
		--intr : IN STD_LOGIC;
        InPortValueIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		Family : IN STD_LOGIC_VECTOR(1 DOWNTO 0);  
        OpCode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        IsImmediate : IN STD_LOGIC;
        
        AddRS : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		AddRT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		AddRD : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		Imm : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        write_back_value : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        write_back_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);  -- address destination from write back buffer
        write_back_RegW : IN STD_LOGIC;                        -- RegWrite from the write back buffer (it is from the WB buffer output and will be input to RegFile in the integration phase)

        ALUsrc : OUT STD_LOGIC;
        ALUop : OUT STD_LOGIC_vector(4 DOWNTO 0);
		Branch : OUT STD_LOGIC; 
		MEMRead : OUT STD_LOGIC;
		MEMWrite : OUT STD_LOGIC;
		RegWrite : OUT STD_LOGIC;
        MemTOReg : OUT STD_LOGIC_vector(1 DOWNTO 0);
        MemAddressSelector : OUT STD_LOGIC_vector(1 DOWNTO 0); 
        MemDataSelector : OUT STD_LOGIC;

        Register1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Register2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Immediate : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        AddressDestination : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        JmpAddr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        InPortValueOUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
		
END ENTITY Decode;

ARCHITECTURE DecodeArch OF Decode IS
    COMPONENT CU IS
    PORT (
        Family : IN STD_LOGIC_VECTOR(1 DOWNTO 0);  
        OpCode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        IsImmediate : IN STD_LOGIC; 
        ALUsrc : OUT STD_LOGIC;
        ALUop : OUT STD_LOGIC_vector(4 DOWNTO 0);  
        Branch : OUT STD_LOGIC;    
        MEMRead : OUT STD_LOGIC;
        MEMWrite : OUT STD_LOGIC;
        RegWrite : OUT STD_LOGIC;
        MemTOReg : OUT STD_LOGIC_vector(1 DOWNTO 0);
        RegAddressSelector : OUT STD_LOGIC; 
        MemAddressSelector : OUT STD_LOGIC_vector(1 DOWNTO 0);
        MemDataSelector : OUT STD_LOGIC 
    );
    END COMPONENT;

    COMPONENT RegFile IS
	PORT (
		Add1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		Add2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		Wrt_Add : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		DataIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		RegWrite : IN STD_LOGIC;
		Clk : IN STD_LOGIC;
		DataOUT1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		DataOUT2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
    END COMPONENT;

    COMPONENT Reg IS 
		GENERIC (N : integer := 16);
		PORT( Clk,Rst,en : IN std_logic;
			d : IN std_logic_vector(N-1 DOWNTO 0);
			q : OUT std_logic_vector(N-1 DOWNTO 0));
	END COMPONENT;

	SIGNAL ALUsrcSsig : STD_LOGIC := '0';
	SIGNAL ALUopSig : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
	SIGNAL BranchSig : STD_LOGIC := '0';
	SIGNAL MemRsig : STD_LOGIC := '0';
	SIGNAL MemWsig : STD_LOGIC := '0';
	SIGNAL RegRsig : STD_LOGIC := '0';
	SIGNAL MemToRegSig : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL RegAddressSelectorSig : STD_LOGIC := '0';
	SIGNAL MemAddressSelectorSig : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL MemDataSelectorSig : STD_LOGIC := '0';

	SIGNAL input2RegFile : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
	SIGNAL Reg1Value : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL Reg2Value : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    signal D_E_Buffer_input: std_logic_vector(81 DOWNTO 0);
    signal D_E_Buffer_result: std_logic_vector(81 DOWNTO 0);
BEGIN
	ctrl : CU PORT MAP(Family, OpCode, IsImmediate, ALUsrcSsig, ALUopSig, BranchSig, MemRsig, MemWsig, RegRsig, MemToRegSig, RegAddressSelectorSig, MemAddressSelectorSig, MemDataSelectorSig);
	
    input2RegFile <= AddRD when RegAddressSelectorSig = '1' else AddRT;
    RegistFile : RegFile PORT MAP(AddRS, input2RegFile, write_back_address, write_back_value, write_back_RegW, clk, Reg1Value, Reg2Value);
	
    D_E_Buffer_input <= InPortValueIN & ALUsrcSsig & ALUopSig & BranchSig & MemRsig & MemWsig & RegRsig & MemToRegSig & MemAddressSelectorSig & MemDataSelectorSig & Reg1Value & Reg2Value & Imm & AddRD;
    Decode_Execute_buffer : Reg GENERIC MAP (82) PORT MAP (clk,rst,Enable_DBuffer,D_E_Buffer_input,D_E_Buffer_result);
    InPortValueOUT <= D_E_Buffer_result(81 DOWNTO 66);
    ALUsrc <= D_E_Buffer_result(65);
    ALUop <= D_E_Buffer_result(64 DOWNTO 60);
    Branch <= D_E_Buffer_result(59);
    MEMRead <= D_E_Buffer_result(58);
    MEMWrite <= D_E_Buffer_result(57);
    RegWrite <= D_E_Buffer_result(56);
    MemTOReg <= D_E_Buffer_result(55 DOWNTO 54);
    MemAddressSelector <= D_E_Buffer_result(53 DOWNTO 52);
    MemDataSelector <= D_E_Buffer_result(51);
    Register1 <= D_E_Buffer_result(50 DOWNTO 35);
    Register2 <= D_E_Buffer_result(34 DOWNTO 19);
    Immediate <= D_E_Buffer_result(18 DOWNTO 3);
    AddressDestination <= D_E_Buffer_result(2 DOWNTO 0);

    JmpAddr <= Reg2Value;
END DecodeArch;