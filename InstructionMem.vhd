
library ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity Instruction_cache is
port(
	Add: in std_logic_vector (9 downto 0);
	PortOut1: out std_logic_vector(15 downto 0);
    PortOut2: out std_logic_vector(15 downto 0)
);
end entity;



architecture Instruction_cache_IMP of Instruction_cache is
TYPE reg_type IS ARRAY(0 TO 1023) of std_logic_vector(15 DOWNTO 0);
    signal reg : reg_type;

begin
    PortOut1 <= reg(to_integer(unsigned((Add))));
    PortOut2 <= reg(to_integer(unsigned((Add))) + 1);
end Instruction_cache_IMP;