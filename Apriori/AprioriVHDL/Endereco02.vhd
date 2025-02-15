library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


	Entity Endereco02 is 
	generic(n: integer := 8); --tamanho da memoria
		Port (
		 clk_in :  in std_logic;
		 enable : in std_logic;
		 reset  : in bit;
		 contador : in integer range 0 to 128;
		 tam_Ram : in integer range 0 to 256;
		 saida : out integer range 0 to 128
		
		 );
	end Entity;
	
	Architecture cont1ador of Endereco02 is  
   Begin
	Process(enable, clk_in, contador, reset)
	variable cont1, cont2: integer range 0 to 128;
		Begin
		   
		   if clk_in'event and clk_in = '1' and enable = '1' then
			 if cont2 = 0 then
				 cont1 := contador + 1;	 
			 end if;
			 cont2 := cont2 + 1;
          if cont2 > 1 then
			    cont1 := cont1 + 1;
				 if cont1 = tam_Ram - 1 then
					 cont2 := 0;
				  end if;
			 end if;
			 if contador > tam_Ram  then
				cont1 := 0;
			 end if;
			end if;
		 saida <= cont1 + 1;
		end Process;
   end cont1ador;	