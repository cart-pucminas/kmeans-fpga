--|| Kmeans Processador 
--|| Desenvolvedor: Lucas Andrade Maciel
--|| Grupo: CArT - Computer Architecture and Parallel Processing Team
--|| Bloco: Count Frequence Data - Kmodes CalcCentroidModule 
--|| Descricao: Este bloco calcula a frequencia que um atributo de um determinado ponto se repete no centroid vinulado.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.all ;
use ieee.numeric_std.all;

Entity CountFrequenceData is
    GENERIC ( Palavra      : INTEGER := 64;
			     TamanhoAtributo  : INTEGER := 8;
				  MaxCentroidsBits : INTEGER := 10;
				  MaxPontosBits    : INTEGER := 15); 
				  
	 PORT (
	  en_CountFreqData: in STD_LOGIC;  													--Habilita Inicializacao deste bloco
	  en_FindMaxValue : in STD_LOGIC;  													--Habilita Verificacao do maior elemento
	  valueDado		   : in STD_LOGIC_VECTOR(Palavra-1 downto 0);            --Valor do dado de entrada que sera analisado
	  valueMap		   : in STD_LOGIC_VECTOR(MaxCentroidsBits-1 downto 0);   --Valor do mapeamento do atual do dado
	  countCentroid   : in STD_LOGIC_VECTOR(MaxCentroidsBits-1 downto 0);   --Valor do centroid verificado
	  end_CalcFreq    : out STD_LOGIC;	                                    --Informa que a atualizacao das frequencias foi finalizada
	  end_CalcMode    : out STD_LOGIC;	                                    --Informa que a atualizacaodo centroid foi finalizada
	  newCentroidValue: out STD_LOGIC_VECTOR(Palavra-1 downto 0)            --Valor atualizado do centroid
    );
END CountFrequenceData;

ARCHITECTURE arch of CountFrequenceData is

--Cria uma matriz com com 256 colunas, 1024 * QtdAtributos linhas, com dados do tamanho maximo de pontos possiveis
TYPE matrix_t IS ARRAY ((8*TamanhoAtributo)-1 downto 0, 255 downto 0) OF STD_LOGIC_VECTOR(TamanhoAtributo-1 downto 0);

--Sinais de dados 
SIGNAL countMatrix       : matrix_t ;
SIGNAL centroidLine      : INTEGER RANGE 0 to 65536; 
SIGNAL s_end_CalcFreq    : STD_LOGIC := '0';
SIGNAL s_end_CalcMode    : STD_LOGIC := '0';
SIGNAL s_newCentroidValue: STD_LOGIC_VECTOR(Palavra-1 downto 0) := (others => '0');
SIGNAL maxValue          : STD_LOGIC_VECTOR(TamanhoAtributo-1 downto 0) := (others => '0');

BEGIN
   PROCESS(valueDado, valueMap, en_CountFreqData, countCentroid, en_FindMaxValue, countMatrix, centroidLine)
   BEGIN  
	      
			if (en_CountFreqData = '0' and en_FindMaxValue = '0') then
			   --Limpa a matriz de contagem
			   for i in 0 to (8*TamanhoAtributo)-1 loop
					for j in 0 to 255 loop
					  countMatrix(i,j) <= (others=>'0');
					end loop;  -- j
				 end loop;  -- i
			   
				s_end_CalcFreq <= '0';
				s_end_CalcMode <= '0';
				maxValue <= (others => '0');
				s_newCentroidValue<= (others => '0');
				
			elsif	(en_CountFreqData = '1') then		
			   s_end_CalcFreq <= '0';
								
				centroidLine <= conv_integer(valueMap) * TamanhoAtributo;
				
				countMatrix(centroidLine, conv_integer(valueDado(7 downto 0)))       <= countMatrix(centroidLine, conv_integer(valueDado(7 downto 0))) + 1;
				countMatrix(centroidLine + 1, conv_integer(valueDado(15 downto 8)))  <= countMatrix(centroidLine + 1, conv_integer(valueDado(15 downto 8))) + 1;
				countMatrix(centroidLine + 2, conv_integer(valueDado(23 downto 16))) <= countMatrix(centroidLine + 2, conv_integer(valueDado(23 downto 16))) + 1;
				countMatrix(centroidLine + 3, conv_integer(valueDado(31 downto 24))) <= countMatrix(centroidLine + 3, conv_integer(valueDado(31 downto 24))) + 1;
				countMatrix(centroidLine + 4, conv_integer(valueDado(39 downto 32))) <= countMatrix(centroidLine + 4, conv_integer(valueDado(39 downto 32))) + 1;
				countMatrix(centroidLine + 5, conv_integer(valueDado(47 downto 40))) <= countMatrix(centroidLine + 5, conv_integer(valueDado(47 downto 40))) + 1;
				countMatrix(centroidLine + 6, conv_integer(valueDado(55 downto 48))) <= countMatrix(centroidLine + 6, conv_integer(valueDado(55 downto 48))) + 1;
				countMatrix(centroidLine + 7, conv_integer(valueDado(63 downto 56))) <= countMatrix(centroidLine + 7, conv_integer(valueDado(63 downto 56))) + 1;
				
				s_end_CalcFreq <= '1';
				s_end_CalcMode <= '0';
				maxValue <= (others => '0');
				s_newCentroidValue<= (others => '0');
				
			elsif (en_FindMaxValue = '1') then
			   s_end_CalcFreq <= '0';	
			   s_end_CalcMode <= '0';		
				
				centroidLine <= conv_integer(countCentroid) * TamanhoAtributo;
				
				for i in centroidLine to centroidLine+7 loop
				  maxValue <= (others => '0');
				  for j in 0 to 255 loop
				    if(countMatrix(i,j) > maxValue) then
						maxValue <= countMatrix(i,j);
                end if;
			     end loop;		
				  
				   if (i = centroidLine) then
					   s_newCentroidValue(7 downto 0) <= maxValue;
					 elsif (i = centroidLine+1) then
					   s_newCentroidValue(15 downto 8) <= maxValue;
					 elsif (i = centroidLine+2) then
					   s_newCentroidValue(23 downto 16) <= maxValue;
					 elsif (i = centroidLine+3) then
					   s_newCentroidValue(31 downto 24) <= maxValue;
					 elsif (i = centroidLine+4) then
					   s_newCentroidValue(39 downto 32) <= maxValue;
					 elsif (i = centroidLine+5) then
					   s_newCentroidValue(47 downto 40) <= maxValue;
					 elsif (i = centroidLine+6) then
					   s_newCentroidValue(55 downto 48) <= maxValue;
					 elsif (i = centroidLine+7) then
					   s_newCentroidValue(63 downto 56) <= maxValue;
					 end if;  
					 
				 end loop;  
				
			   s_end_CalcMode <= '1';
				maxValue <= (others => '0');
				
	      end if;	
	     
   END PROCESS;	
	
end_CalcFreq <= s_end_CalcFreq;
end_CalcMode <= s_end_CalcMode;
newCentroidValue <= s_newCentroidValue;

END arch;