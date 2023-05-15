LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY MEMWB IS
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

        OutPortValueIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        RegisterWrite : OUT STD_LOGIC;
        MemToRegister : OUT STD_LOGIC_vector(1 DOWNTO 0);
        MemDataOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        ALUOutput : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DestinationAddress : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        InPortValueOUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);

        OutPortValueOUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY MEMWB;

ARCHITECTURE MEMWBArch OF MEMWB IS
	
    COMPONENT Memory IS
        PORT (
            clk : IN STD_LOGIC;
            MEMW : IN STD_LOGIC;
            MEMR : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            datain : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            dataout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            SP : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
    END COMPONENT;

    COMPONENT Reg IS 
		GENERIC (N : integer := 16);
		PORT( Clk,Rst,en : IN std_logic;
			d : IN std_logic_vector(N-1 DOWNTO 0);
			q : OUT std_logic_vector(N-1 DOWNTO 0));
	END COMPONENT;

	--SIGNAL InPort : Ports := (OTHERS => (OTHERS => '0'));
	--SIGNAL OutPort : Ports := (OTHERS => (OTHERS => '0'));
	
	SIGNAL Data_Signal : STD_LOGIC_VECTOR(15 DOWNTO 0)          := (OTHERS => '0');
    SIGNAL Address_Signal : STD_LOGIC_VECTOR(9 DOWNTO 0)        := (OTHERS => '0');
    SIGNAL MemDataOutSig : STD_LOGIC_VECTOR(15 DOWNTO 0)        := (OTHERS => '0');

    SIGNAL SP_IN : STD_LOGIC_VECTOR(15 DOWNTO 0)                := (OTHERS => '0');
    SIGNAL SP_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0)               := (OTHERS => '0');

    SIGNAL InPortValueSig : STD_LOGIC_VECTOR(15 DOWNTO 0)       := (OTHERS => '0');
    SIGNAL MEMReadSig : STD_LOGIC  := '0';
    SIGNAL MEMWriteSig : STD_LOGIC := '0';
    SIGNAL RegWriteSig : STD_LOGIC := '0';
    SIGNAL MemTORegSig : STD_LOGIC_vector(1 DOWNTO 0)  := (OTHERS => '0');
    SIGNAL MemAddressSelectorSig : STD_LOGIC_vector(1 DOWNTO 0)  := (OTHERS => '0');
    SIGNAL MemDataSelectorSig : STD_LOGIC := '0';
    SIGNAL ALUSig : STD_LOGIC_VECTOR(15 DOWNTO 0)                := (OTHERS => '0');
    SIGNAL RSourceSig : STD_LOGIC_VECTOR(15 DOWNTO 0)            := (OTHERS => '0');
    SIGNAL RDestSig : STD_LOGIC_VECTOR(15 DOWNTO 0)              := (OTHERS => '0');
    SIGNAL DestAddrSig : STD_LOGIC_VECTOR(2 DOWNTO 0)            := (OTHERS => '0');
    SIGNAL OutPortValueSig : STD_LOGIC_VECTOR(15 DOWNTO 0)       := (OTHERS => '0');

    SIGNAL M1_M2_Buffer_input: std_logic_vector(90 DOWNTO 0);
    SIGNAL M1_M2_Buffer_result: std_logic_vector(90 DOWNTO 0);

    SIGNAL M2_WB_Buffer_input: std_logic_vector(69 DOWNTO 0);
    SIGNAL M2_WB_Buffer_result: std_logic_vector(69 DOWNTO 0);

BEGIN

    M1_M2_Buffer_input <= OutPortValueIN & InPortValueIN & MEMReadIN & MEMWriteIN & RegWriteIN & MemTORegIN & MemDataSelectorIN & MemAddressSelectorIN & ALUIN & RSourceIN & RDestIN & DestAddrIN;
    Mem1_Mem2_buffer : Reg GENERIC MAP (91) PORT MAP (clk, rst, Enable_M1Buffer, M1_M2_Buffer_input, M1_M2_Buffer_result);
    OutPortValueSig <= M1_M2_Buffer_result(90 DOWNTO 75);
    InPortValueSig <= M1_M2_Buffer_result(74 DOWNTO 59);
    MEMReadSig <= M1_M2_Buffer_result(58);
    MEMWriteSig <= M1_M2_Buffer_result(57);
    RegWriteSig <= M1_M2_Buffer_result(56);
    MemTORegSig <= M1_M2_Buffer_result(55 DOWNTO 54);
    MemDataSelectorSig <= M1_M2_Buffer_result(53);
    MemAddressSelectorSig <= M1_M2_Buffer_result(52 DOWNTO 51);
    ALUSig <= M1_M2_Buffer_result(50 DOWNTO 35);
    RSourceSig <= M1_M2_Buffer_result(34 DOWNTO 19);
    RDestSig <= M1_M2_Buffer_result(18 DOWNTO 3);
    DestAddrSig <= M1_M2_Buffer_result(2 DOWNTO 0);

    Data_Signal <= RSourceSig WHEN MemDataSelectorSig = '0' ELSE STD_LOGIC_VECTOR(unsigned(PC_signal) + 1);
    
    -- If SP then sp+=1 when pop
    SP_OUT <= STD_LOGIC_VECTOR(unsigned(SP_OUT) + 1) WHEN MemAddressSelectorSig = "00" AND MEMReadSig = '1' ELSE SP_OUT;
    
    Address_Signal <= SP_OUT(9 DOWNTO 0)    WHEN MemAddressSelectorSig = "00"            -- (Push/Pop/Call/Ret inst.)
        ELSE RSourceSig(9 DOWNTO 0)         WHEN MemAddressSelectorSig = "01"            -- (Load inst.)
        ELSE RDestSig(9 DOWNTO 0)           WHEN MemAddressSelectorSig = "10";           -- (Store inst.)
    

    DataMemory : Memory PORT MAP (clk, MEMWriteSig, MEMReadSig, Address_Signal, Data_Signal, MemDataOutSig, SP_IN);

    -- If SP then sp-=1 when push
    SP_IN <= STD_LOGIC_VECTOR(unsigned(SP_IN) - 1) WHEN MemAddressSelectorSig = "00" AND MEMWriteSig = '1' ELSE SP_IN;

    SP_Register : Reg GENERIC MAP (16) PORT MAP (clk, rst, '1', SP_IN, SP_OUT);

    M2_WB_Buffer_input <= OutPortValueSig & InPortValueSig & RegWriteSig & MemTORegSig & MemDataOutSig & ALUSig & DestAddrSig;
    Mem2_WB_buffer : Reg GENERIC MAP (70) PORT MAP (clk, rst, Enable_M2Buffer, M2_WB_Buffer_input, M2_WB_Buffer_result);
    OutPortValueOUT <= M2_WB_Buffer_result(69 DOWNTO 54);
    InPortValueOUT <= M2_WB_Buffer_result(53 DOWNTO 38);
    RegisterWrite <= M2_WB_Buffer_result(37);
    MemToRegister <= M2_WB_Buffer_result(36 DOWNTO 35);
    MemDataOut <= M2_WB_Buffer_result(34 DOWNTO 19);
    ALUOutput <= M2_WB_Buffer_result(18 DOWNTO 3);
    DestinationAddress <= M2_WB_Buffer_result(2 DOWNTO 0);

END MEMWBArch;
