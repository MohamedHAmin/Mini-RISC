library IEEE;
use IEEE.std_logic_1164.all;

--Used for the fetch_decode reg, decode_execute reg, writeback reg
ENTITY Reg IS 
GENERIC (N : integer := 16);
PORT( Clk,Rst,en : IN std_logic;
 d : IN std_logic_vector(N-1 DOWNTO 0);
 q : OUT std_logic_vector(N-1 DOWNTO 0));
END Reg;


ARCHITECTURE myReg OF Reg 
IS
BEGIN
PROCESS (Clk,Rst)
BEGIN
IF Rst = '1' THEN
q <= (OTHERS=>'0');
ELSIF rising_edge(Clk) AND en='1' THEN
        q <= d;
    
END IF;
END PROCESS;
END myReg;


