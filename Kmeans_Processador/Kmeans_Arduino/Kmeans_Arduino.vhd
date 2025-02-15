library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all ;
--use ieee.std_logic_signed.all;

entity Kmeans_Arduino is
	generic (
	SLAVE_ADDR: std_logic_vector(6 downto 0) := "0000001" ); -- Endereço do slave
	
	port(
		--I2C IO Signals
		scl               : inout std_logic;
		sda               : inout std_logic; 
		
		--Transação em progresso
		in_progress       : out   std_logic;
		
		--Comandos Leitura Signals
		tx_done           : out   std_logic;
		-- Variavel pode ser somente 'in' caso receba entrada externa, 
		-- ou poderá ser inout caso a entrada seja colocada no código ou por entrada externa
        tx_byte           : inout    std_logic_vector(7 downto 0); 
		
		--Comandos Escrita Signals
		  rx_byte           : out   std_logic_vector(7 downto 0); 
        rx_data_rdy       : out   std_logic;
        
         --Reset do sistema
        rst				  : in    std_logic;
		  
		  --Dado de entrada pra ser enviado para o master
		  dado : in std_logic_vector(7 downto 0);
		  readDone : out STD_LOGIC;
        
        --Clock do sistema
        clk               : in    std_logic); 
		  
		
		  
		
end Kmeans_Arduino;

architecture arch of Kmeans_Arduino is
	--Signals de saída
    signal sda_out_en          : std_logic := '0';
    signal sda_o               : std_logic := '0';
    signal rx_data_rdy_reg     : std_logic                    := '0';
    signal tx_byte_buf         : std_logic_vector(7 downto 0) := (others => '0'); 
    
	--Signals do pipeline SDA e SCL
	signal scl_d    : std_logic := '1';
    signal scl_d2   : std_logic := '1';
    signal sda_d    : std_logic := '1';
    signal sda_d2   : std_logic := '1';
    
    --Signals de bordas do SCL e Start/Stop bits
    signal start_strobe       : std_logic := '0';
    signal stop_strobe        : std_logic := '0';
    signal scl_rising_strobe  : std_logic := '0';
    signal scl_falling_strobe : std_logic := '0';
    
     --I2C FSM Signals de controle
    type state_t is (IDLE, READ_ADDRESS, SEND_ACK_1, WRITE_CMD,
                     READ_CMD, WAIT_ACK_1, WAIT_ACK_2, WAIT_STOP);
               
    signal state            : state_t              := IDLE; --Estado atual da máquina
    signal state_fut        : state_t              := IDLE; --Estado futuro 
    signal rw_command       : std_logic            := '0';  --Define se o comando será de Read ou write 
    signal bit_counter      : integer range 0 to 8 := 0;    --Conta o número de bits por transação
    signal continue_read    : std_logic            := '0';  --Informa se o comando Read deverá continuar 

    --Signals para armazenar endereço/dados do master
    signal addr_buf     : std_logic_vector(6 downto 0)    := (others => '0');
    signal rx_data_buf  : std_logic_vector(7 downto 0) := (others => '0');
    
    --Contador utilizado para que o slave envie dados para o Master
    signal count : STD_LOGIC_VECTOR (7 downto 0) :=(others => '0');
begin

--Programação sequencial da FSM
process(clk, rst) is
begin
	if rst = '0' then
		state <= IDLE;		
	elsif rising_edge(clk) then
		state <= state_fut;
	end if;
end process;

--I2C Máquina de Estados	
process(clk) is
begin
	if rising_edge(clk) then
	 -- Valores default 
        sda_o       <= '0';
        sda_out_en  <= '0';
        rx_data_rdy_reg <= '0';
		  tx_byte <= dado;
		  readDone <='0';
        
        case state is
            --Estado Idle  (Possui funcionalidade semelhante ao STOP)
            when IDLE =>
                if start_strobe = '1' then
                    state_fut          <= READ_ADDRESS;
                    bit_counter <= 0;
                end if;
                
            --Lê os 7 bits de endereço do slave informados pelo master
            when READ_ADDRESS =>
                if scl_rising_strobe = '1' then
                    if bit_counter < 7 then
                        --Armazena os 7 primeiros bits lidos em um endereço de buffer
                        bit_counter             <= bit_counter + 1;
                        addr_buf(6-bit_counter) <= sda_d;
                    elsif bit_counter = 7 then
                        --O próximo bit indica se o comando será de write ou read
                        bit_counter     <= bit_counter + 1;
                        rw_command      <= sda_d;
                    end if;
                end if;

                if bit_counter = 8 and scl_falling_strobe = '1' then
                    bit_counter <= 0;
                    --Verifica se o endereço informado pelo master é o mesmo do slave. Caso verdadeiro, 
                    --envia acknowledge, caso contrário espera belo bit de stop.
                    if addr_buf = SLAVE_ADDR then 
                        state_fut <= SEND_ACK_1;
                        if rw_command = '1' then 
                            tx_byte_buf <= tx_byte;  -- Utilizado para o envio de dados de entrada da variavel tx_byte
                            --As duas linhas abaixo são utilizadas para incrementar o contador para enviar o valor para o master
                            count <= count + 1; 
                            --tx_byte_buf <= count ;
									 --tx_byte_buf <= dado(7 downto 0);
                        end if;
                    else
                        state_fut <= IDLE;
                    end if;
                end if;

            --Envia o bit ACK  mantendo o SDA baixo através de um ciclo do SCL 
            when SEND_ACK_1 =>
                sda_out_en <= '1';
                sda_o   <= '0';
                if scl_falling_strobe = '1' then
                    if rw_command = '0' then
                        state_fut <= WRITE_CMD;
                    else
                        state_fut <= READ_CMD;
                    end if;
                end if;

            --Espera pelo acknowledge do master
            when WAIT_ACK_1 =>
                if scl_rising_strobe = '1' then
                    state_fut <= WAIT_ACK_2;
                    
                    if sda_d = '1' then
                        --NACK recebido, para a transmissão e espera pelo bit de STOP
                        continue_read <= '0';
                    else
                        --ACK recebido, continua a transmissão
                        continue_read       <= '1';
                        tx_byte_buf <= tx_byte;
                    end if;
                end if;
                
            --Espera pelo acknowledge do master
            --Requer 2 estados de espera para que todo o ciclo do SCL passe
            when WAIT_ACK_2 =>
                if scl_falling_strobe = '1' then
                    if continue_read = '1' then
                        if rw_command = '0' then
                            state_fut <= WRITE_CMD;
                        else
                            state_fut <= READ_CMD;
                        end if;
                    else
                        state_fut <= WAIT_STOP;
                    end if;
                end if;
                
            --Comando Write (Escreve do master para o slave)
            when WRITE_CMD =>
				--Em cada borda de subida é realizada a leitura de cada bit de dados recebidos pelo SDA e são armazenados
                --No rx_data_buf
                if scl_rising_strobe = '1' then
                    if bit_counter <= 7 then
                        rx_data_buf(7-bit_counter)  <= sda_d;
                        bit_counter                 <= bit_counter + 1;
                    end if;
                    if bit_counter = 7 then
                        rx_data_rdy_reg     <= '1';
                    end if;
                end if;

                --Quando for recebido um byte, o ACK é enviado
                if scl_falling_strobe = '1' and bit_counter = 8 then
                    state_fut           <= SEND_ACK_1;
                    bit_counter     <= 0;
                end if;

            --Comando Read (Master realiza a leitura de dados do slave)
            when READ_CMD =>
                sda_out_en <= '1';
                sda_o   <= tx_byte_buf(7-bit_counter);
                
				--O valor do SDA deverá ser definido antes da borda de subida do SCL.
                --Portanto, deverá ser condigurado na borda de descida do ciclo anterior SCL.
                if scl_falling_strobe = '1' then
                    if bit_counter < 7 then
                        bit_counter <= bit_counter + 1;
                    elsif bit_counter = 7 then
                        --Espera pelo ACK depois de enviar um byte
                        state_fut          <= WAIT_ACK_1;
                        bit_counter <= 0;
                    end if;
                end if;

            --NACK recebido durante o comando de Read, espera pelo envio do Stop bit.
            when WAIT_STOP =>
                tx_done     <= '1';
					 readDone   <= '1';
                null;
        end case;

        --Reset quando na transmissão parar (stop) ou iniciar (start)
        if start_strobe = '1' then
            tx_done     <= '0';
            bit_counter <= 0;
            state_fut       <= READ_ADDRESS;
        end if;

        if stop_strobe = '1' then
            tx_done     <= '0';
            bit_counter <= 0;
            state_fut       <= IDLE;
        end if;

    end if;
end process;

--Lógica de eventos ocorridos (Strobe)
process (clk) is
begin
    if rising_edge(clk) then
        --Signals de pipeline do SDA e SCL 
        scl_d       <= scl;
        scl_d2      <= scl_d;
        sda_d       <= sda;
        sda_d2      <= sda_d;
        
        --Lógica do SCL da detecção de bordas disparadas (strobes)
        scl_rising_strobe <= '0';
        scl_falling_strobe <= '0';
        
        if scl_d2 = '0' and scl_d = '1' then
            scl_rising_strobe <= '1';
        end if;
     
        if scl_d2 = '1' and scl_d = '0' then
            scl_falling_strobe <= '1';
        end if;

        --Lógica de detecção dos bits de Start e stop  
        start_strobe <= '0';
        stop_strobe  <= '0';
        
        if scl_d = '1' and scl_d2 = '1' and sda_d2 = '1' and sda_d = '0' then
            start_strobe <= '1';
            stop_strobe  <= '0';
        end if;

        if scl_d2 = '1' and scl_d = '1' and sda_d2 = '0' and sda_d = '1' then
            start_strobe <= '0';
            stop_strobe  <= '1';
        end if;
    end if;
end process;

--Saídas de SDA e SCL
sda     <= sda_o when sda_out_en = '1' else 'Z';  
scl     <= 'Z';

--Unidades locais de saída
rx_data_rdy     <= rx_data_rdy_reg;
rx_byte         <= rx_data_buf;

--Signal em progresso
in_progress     <= '0' when state_fut = IDLE else '1';
end arch;