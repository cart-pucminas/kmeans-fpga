library ieee;
use ieee.std_logic_1164.all;

Entity Buf is 
generic (n : integer := 11); --tamanho da palavra;
	Port(
		entrada1: in  bit;
		entrada2: in  bit;
		entradaend1: in std_logic_vector(11 downto 0);
		entradaend2: in std_logic_vector(11 downto 0);
		ativa: in integer range 0 to 2;
		saida_enable: out bit;
		saida_ender: out std_logic_vector(11 downto 0)
	);
end Entity;


ARCHITECTURE arch of Buf is
	Begin
   saida_enable <= entrada1 when ativa = 1 else
	              entrada2 when ativa = 2 else
					  '0';
	saida_ender <= entradaend1 when ativa = 1 else
	            entradaend2 when ativa = 2 else
	            (others => '0');
	
end arch;
