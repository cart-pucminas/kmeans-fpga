--|| Kmeans Processador 
--|| Desenvolvedor: Lucas Andrade Maciel
--|| Grupo: CArT - Computer Architecture and Parallel Processing Team
--|| Bloco: BufferEnOutControl - Kmodes CalcCentroidModule 
--|| Descricao: Este bloco determina e os calculos do  buffer terminaram e qual buffer sera considerado.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.all ;
use ieee.numeric_std.all;

Entity BufferEnOutControl is
    GENERIC (MaxCentroidsBits : INTEGER := 10); 
				  
	 PORT (
	  valueMap		   : in STD_LOGIC_VECTOR(MaxCentroidsBits-1 downto 0); --Valor do mapeamento do atual do dado
	  value_Buffer7   : in STD_LOGIC;	                                  --Valor calculado para o centroide do buffer 7 
	  value_Buffer6   : in STD_LOGIC;	                                  --Valor calculado para o centroide do buffer 6
	  value_Buffer5   : in STD_LOGIC;	                                  --Valor calculado para o centroide do buffer 5
	  value_Buffer4   : in STD_LOGIC;	                                  --Valor calculado para o centroide do buffer 4
	  value_Buffer3   : in STD_LOGIC;	                                  --Valor calculado para o centroide do buffer 3
	  value_Buffer2   : in STD_LOGIC;	                                  --Valor calculado para o centroide do buffer 2
	  value_Buffer1   : in STD_LOGIC;	                                  --Valor calculado para o centroide do buffer 1
	  value_Buffer0   : in STD_LOGIC;	                                  --Valor calculado para o centroide do buffer 0
	  end_Value: out STD_LOGIC	                                  --Valor atualiado do centroide avaliado
    );
END BufferEnOutControl;

ARCHITECTURE arch of BufferEnOutControl is

BEGIN
   PROCESS(valueMap, value_Buffer7, value_Buffer6, value_Buffer5, value_Buffer4, value_Buffer3, value_Buffer2, value_Buffer1, value_Buffer0)
   BEGIN  
		case valueMap is
			when "0000000000" => end_Value <= value_Buffer0;
			when "0000000001" => end_Value <= value_Buffer1;
			when "0000000010" => end_Value <= value_Buffer2;
			when "0000000011" => end_Value <= value_Buffer3;
			when "0000000100" => end_Value <= value_Buffer4;
			when "0000000101" => end_Value <= value_Buffer5;
			when "0000000110" => end_Value <= value_Buffer6;
			when "0000000111" => end_Value <= value_Buffer7;
			when others       => end_Value <= '0';
		end case;	
   END PROCESS;	
	
END arch;