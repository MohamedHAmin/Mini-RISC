LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CPU IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
        InPort : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		-- intr : IN STD_LOGIC;
		Result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		Carry : OUT STD_LOGIC;
		Zero : OUT STD_LOGIC;
		Negative : OUT STD_LOGIC);
END ENTITY CPU;

ARCHITECTURE CPUArch OF CPU IS
	
    COMPONENT Fetch IS
    PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		Enable_FBuffer : IN STD_LOGIC;

		InPortValueIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		JumpAddress : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		CheckedJump : IN STD_LOGIC;
		-- intr : IN STD_LOGIC;
		-- Ins : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- PC_Enable : IN STD_LOGIC;
        Family : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		OpCode : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		RS : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		RT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		RD : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		IsImmediate : OUT STD_LOGIC;
		Imm : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);

		PC : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		InPortValueOUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
    END COMPONENT;

    COMPONENT Decode IS
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
		
    END COMPONENT;

    COMPONENT Execute IS
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

        MEMReadOut : OUT STD_LOGIC;
		MEMWriteOut : OUT STD_LOGIC;
		RegWriteOut : OUT STD_LOGIC;
        MemTORegOut : OUT STD_LOGIC_vector(1 DOWNTO 0);
        MemAddressSelectorOut : OUT STD_LOGIC_vector(1 DOWNTO 0); 
        MemDataSelectorOut : OUT STD_LOGIC;

        CCR_Flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

        ALUOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        RSourceOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        RDestOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DestAddrOut : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        InPortValueOUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
    END COMPONENT;

    COMPONENT MEMWB IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
        Enable_M1Buffer : IN STD_LOGIC;
        Enable_M2Buffer : IN STD_LOGIC;
		-- intr : IN STD_LOGIC;
        InPortValueIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		MEMReadIN : IN STD_LOGIC;
		MEMWriteIN : IN STD_LOGIC;
		RegWriteIN : IN STD_LOGIC;
        MemTORegIN : IN STD_LOGIC_vector(1 DOWNTO 0);
        MemAddressSelectorIN : IN STD_LOGIC_vector(1 DOWNTO 0); 
        MemDataSelectorIN : IN STD_LOGIC;
        ALUIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        RSourceIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        RDestIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        DestAddrIN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        PC_signal : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        RegisterWrite : OUT STD_LOGIC;
        MemToRegister : OUT STD_LOGIC_vector(1 DOWNTO 0);
        MemDataOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        ALUOutput : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DestinationAddress : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        InPortValueOUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
    END COMPONENT;

    SIGNAL JmpAddrSig : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL CheckJmpSig : STD_LOGIC := '0';
    SIGNAL FamilySig : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL OpCodeSig : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Source_From_Fetch : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Target_From_Fetch : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Dest_From_Fetch : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Immediate_From_Fetch : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL IsImmediateSig : STD_LOGIC := '0';
    SIGNAL PCSig : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL InPort_from_Fetch : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    SIGNAL ALUsrc_from_Decode : STD_LOGIC := '0';
    SIGNAL ALUop_from_Decode : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Branch_from_Decode : STD_LOGIC := '0';
    SIGNAL MEMRead_from_Decode : STD_LOGIC := '0';
    SIGNAL MEMWrite_from_Decode : STD_LOGIC := '0';
    SIGNAL RegWrite_from_Decode : STD_LOGIC := '0';
    SIGNAL MemToReg_from_Decode : STD_LOGIC_vector(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MemAddressSelector_from_Decode : STD_LOGIC_vector(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MemDataSelector_from_Decode : STD_LOGIC := '0';
    SIGNAL Register1_from_Decode : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Register2_from_Decode : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Immediate_from_Decode : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL DestAddr_from_Decode : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL InPort_from_Decode : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    SIGNAL MEMREADOut_from_Execute : STD_LOGIC := '0';
    SIGNAL MEMWRITEOut_from_Execute : STD_LOGIC := '0';
    SIGNAL REGWRITEOut_from_Execute : STD_LOGIC := '0';
    SIGNAL MEMTOREGOut_from_Execute : STD_LOGIC_vector(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MEMADDRESSSELECTOROut_from_Execute : STD_LOGIC_vector(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MEMDATASELECTOROut_from_Execute : STD_LOGIC := '0';
    SIGNAL ALUOUT_from_Execute : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL RSOURCEOUT_from_Execute : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL RDESTOUT_from_Execute : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL DESTADDROUT_from_Execute : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL CCR_FLAGS_from_Execute : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL InPort_from_Execute : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    SIGNAL RegisterWrite_from_MemWB : STD_LOGIC := '0';
    SIGNAL MemToRegister_from_MemWB : STD_LOGIC_vector(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MemDataOut_from_MemWB : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ALUOutput_from_MemWB : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL DestinationAddress_from_MemWB : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL InPort_from_MemWB : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    SIGNAL WB_value_Sig : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL WB_address_Sig : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    

BEGIN
	
    CheckJmpSig <= Branch_from_Decode OR (Branch_from_Decode AND CCR_FLAGS_from_Execute(0)) OR (Branch_from_Decode AND CCR_FLAGS_from_Execute(2));
    
    WB_value_Sig <= MemDataOut_from_MemWB WHEN MemToRegister_from_MemWB = "10" 
    ELSE ALUOutput_from_MemWB             WHEN MemToRegister_from_MemWB = "01" 
    ELSE InPort_from_MemWB                WHEN MemToRegister_from_MemWB = "11"
    ELSE (OTHERS => '0');

    WB_address_Sig <= DestinationAddress_from_MemWB;

    fetch1 : Fetch PORT MAP (clk, rst, '1', InPort, JmpAddrSig, CheckJmpSig, FamilySig, OpCodeSig, Source_From_Fetch, 
                            Target_From_Fetch, Dest_From_Fetch, IsImmediateSig, Immediate_From_Fetch, PCSig, InPort_from_Fetch); 
    
    decode1 : Decode PORT MAP (clk, rst, '1', InPort_from_Fetch, FamilySig, OpCodeSig, IsImmediateSig, Source_From_Fetch, 
                              Target_From_Fetch, Dest_From_Fetch, Immediate_From_Fetch, WB_value_Sig, WB_address_Sig, 
                              RegisterWrite_from_MemWB, ALUsrc_from_Decode, ALUop_from_Decode, Branch_from_Decode,
                              MEMRead_from_Decode, MEMWrite_from_Decode, RegWrite_from_Decode, MemToReg_from_Decode,
                              MemAddressSelector_from_Decode, MemDataSelector_from_Decode, Register1_from_Decode,
                              Register2_from_Decode, Immediate_from_Decode, DestAddr_from_Decode, JmpAddrSig, InPort_from_Decode);
    
    execute1 : Execute PORT MAP (clk, rst, '1', InPort_from_Decode, Register1_from_Decode, Register2_from_Decode, Immediate_from_Decode, 
                                DestAddr_from_Decode, ALUop_from_Decode, ALUsrc_from_Decode, Branch_from_Decode, 
                                MEMRead_from_Decode, MEMWrite_from_Decode, RegWrite_from_Decode, MemToReg_from_Decode,
                                MemAddressSelector_from_Decode, MemDataSelector_from_Decode, MEMREADOut_from_Execute,
                                MEMWRITEOut_from_Execute, REGWRITEOut_from_Execute, MEMTOREGOut_from_Execute,
                                MEMADDRESSSELECTOROut_from_Execute, MEMDATASELECTOROut_from_Execute, CCR_FLAGS_from_Execute,
                                ALUOUT_from_Execute, RSOURCEOUT_from_Execute, RDESTOUT_from_Execute, DESTADDROUT_from_Execute, InPort_from_Execute);
    
    memwb1 : MEMWB PORT MAP (clk, rst, '1', '1', InPort_from_Execute, MEMREADOut_from_Execute, MEMWRITEOut_from_Execute, REGWRITEOut_from_Execute,
                            MEMTOREGOut_from_Execute, MEMADDRESSSELECTOROut_from_Execute, MEMDATASELECTOROut_from_Execute,
                            ALUOUT_from_Execute, RSOURCEOUT_from_Execute, RDESTOUT_from_Execute, DESTADDROUT_from_Execute,
                            PCSig , RegisterWrite_from_MemWB, MemToRegister_from_MemWB, MemDataOut_from_MemWB,
                            ALUOutput_from_MemWB, DestinationAddress_from_MemWB, InPort_from_MemWB);
	
    Result <= ALUOUT_from_Execute;
    Carry <= CCR_FLAGS_from_Execute(2);
    Negative <= CCR_FLAGS_from_Execute(1);
    Zero <= CCR_FLAGS_from_Execute(0);

    -- PROCESS (rst, clk)
	-- BEGIN
	-- 	IF rising_edge(rst) THEN
	-- 		rstsig <= '1';
	-- 	ELSIF falling_edge(clk) AND rst = '0' THEN
	-- 		rstsig <= '0';
	-- 	END IF;
	-- END PROCESS;
	-- PROCESS (intr, clk)
	-- BEGIN
	-- 	IF rising_edge(intr) THEN
	-- 		intrsig <= '1';
	-- 	ELSIF falling_edge(clk) AND intr = '0' THEN
	-- 		intrsig <= '0';
	-- 	END IF;
	-- END PROCESS;
	-- PROCESS (clk)
	-- BEGIN
	-- 	IF rising_edge(clk) THEN
	-- 		intrinssig <= MemDataOut;
	-- 	END IF;
	-- END PROCESS;
END CPUArch;
