--|| Kmeans Processador 
--|| Desenvolvedor: Lucas Andrade Maciel
--|| Grupo: CArT - Computer Architecture and Parallel Processing Team
--|| Bloco: SeparaDadoXY- CalcCentroidModuleFP
--|| Descricao: Este bloco recebe um dado  de 64 bits contendo XY e o separa em dois dados.
        


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.all ;
use ieee.numeric_std.all;

Entity SeparaDadoXY is
    GENERIC ( Palavra      : INTEGER := 64;
			     PalavraXY	   : INTEGER := 32); 
				  
	 PORT (	 
	  valueDado		  : in STD_LOGIC_VECTOR(Palavra-1 downto 0);     --Valor XY do dado de entrada que sera analisado
	  o_valueX		  : out STD_LOGIC_VECTOR(PalavraXY-1 downto 0);  --Valor dado(x)
	  o_valueY 	     : out STD_LOGIC_VECTOR(PalavraXY-1 downto 0)   --Valor dado(y)
    );
END SeparaDadoXY;

ARCHITECTURE arch of SeparaDadoXY is
BEGIN
	o_valueX <= valueDado(Palavra-1 downto PalavraXY);			
	o_valueY <= valueDado(PalavraXY-1 downto 0);

END arch;