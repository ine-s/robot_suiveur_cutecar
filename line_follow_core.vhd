LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY line_follow_core IS
PORT (
    SW : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- switch
    KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0); -- reset 
    CLOCK_50 : IN STD_LOGIC;
    LED : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- led 
    DRAM_CLK, DRAM_CKE : OUT STD_LOGIC;
    DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
    DRAM_BA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    DRAM_CS_N, DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N : OUT STD_LOGIC;
    DRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    DRAM_DQM : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    MTRR_P, MTRR_N, MTRL_P, MTRL_N : OUT STD_LOGIC;
	 LTC_ADC_CONVST, LTC_ADC_SCK,LTC_ADC_SDI : OUT STD_LOGIC;
	 LTC_ADC_SDO : IN STD_LOGIC;
	 VCC3P3_PWRON_n : OUT STD_LOGIC
);
END line_follow_core;

ARCHITECTURE Structure OF line_follow_core IS

    -- Internal aliases with V1/V2/V3-style naming for branch continuity.
    SIGNAL cmd_motor_left, cmd_motor_right : STD_LOGIC_VECTOR(13 DOWNTO 0);
     SIGNAL clk_40mhz, clk_2khz : std_LOGIC;
     SIGNAL sensor_data0 : STD_LOGIC_VECTOR(7 DOWNTO 0);
     SIGNAL sensor_data_ready : STD_LOGIC;
     SIGNAL sensor_threshold  : STD_LOGIC_VECTOR(7 DOWNTO 0);
     SIGNAL sensor_vector     : STD_LOGIC_VECTOR(6 DOWNTO 0);
	 
	 

    COMPONENT nios_system
    PORT (
        SIGNAL clk_clk : IN STD_LOGIC;
        SIGNAL reset_reset_n : IN STD_LOGIC;
        SIGNAL leds_export : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL switches_export : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL sdram_wire_addr : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
        SIGNAL sdram_wire_ba : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        SIGNAL sdram_wire_cas_n : OUT STD_LOGIC;
        SIGNAL sdram_wire_cke : OUT STD_LOGIC;
        SIGNAL sdram_wire_cs_n : OUT STD_LOGIC;
        SIGNAL sdram_wire_dq : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        SIGNAL sdram_wire_dqm : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        SIGNAL sdram_wire_ras_n : OUT STD_LOGIC;
        SIGNAL sdram_wire_we_n : OUT STD_LOGIC;
        SIGNAL cntrl_left_export  : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);                    
        SIGNAL cntrl_right_export : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
		  SIGNAL data_0r_external_connection_export      : in    std_logic_vector(7 downto 0)  := (others => '0'); --      data_0r_external_connection.export
		  SIGNAL data_ready_r_external_connection_export : in    std_logic                     := '0';              -- data_ready_r_external_connection.export
		  SIGNAL vect_cap_external_connection_export     : in    std_logic_vector(6 downto 0)  := (others => '0'); --     vect_cap_external_connection.export
		  SIGNAL niveau_external_connection_export       : out   std_logic_vector(7 downto 0)                     --       niveau_external_connection.export
    );                     
    END COMPONENT;

    COMPONENT PWM_generation 
    PORT (
        clk, reset_n : IN STD_LOGIC;
        s_writedataR, s_writedataL : IN STD_LOGIC_VECTOR(13 DOWNTO 0);        
        -- Le bit13 : bit de go(1)/stop(0). 
        -- Le bit12: bit de forward(0)/backward(1). 
        -- Les bits 11 à 0: vitesse = durée état haut
        dc_motor_p_R, dc_motor_n_R, dc_motor_p_L, dc_motor_n_L : OUT STD_LOGIC
    );
    END COMPONENT;
	 
	 COMPONENT pll_2freqs 
    PORT (
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC 
    );
    END COMPONENT;
		
	 COMPONENT capteurs_sol_seuil
    PORT (
	   clk	: in  std_logic;	-- max 40mhz
		reset_n	: in  std_logic;
	--
		data_capture	: in  std_logic;	-- rise edge to trigger
		data_readyr	: out std_logic;
		data0r	: out std_logic_vector(7 downto 0);
		data1r	: out std_logic_vector(7 downto 0);
		data2r	: out std_logic_vector(7 downto 0);
		data3r	: out std_logic_vector(7 downto 0);
		data4r	: out std_logic_vector(7 downto 0);
		data5r	: out std_logic_vector(7 downto 0);
		data6r	: out std_logic_vector(7 downto 0);
		-- data7 n'est pas un capteur
--		data7r	: out std_logic_vector(7 downto 0);
	-- entree/sortie signaux seuilles
	   NIVEAU : in std_logic_vector(7 downto 0);
		vect_capt : out std_logic_vector(6 downto 0);
	-- spi 
		ADC_CONVSTr	: out std_logic;
		ADC_SCK	: out std_logic;
		ADC_SDIr	: out std_logic;
		ADC_SDO	: in  std_logic 
    );
    END COMPONENT;

BEGIN
    VCC3P3_PWRON_n <= '0';
    -- Instanciation du composant nios_system
    NiosII: nios_system
    PORT MAP (
        clk_clk => CLOCK_50,
        reset_reset_n => KEY(0),
        switches_export => SW,
        sdram_wire_addr => DRAM_ADDR,
        sdram_wire_ba => DRAM_BA,
        sdram_wire_cas_n => DRAM_CAS_N,
        sdram_wire_cke => DRAM_CKE,
        sdram_wire_cs_n => DRAM_CS_N,
        sdram_wire_dq => DRAM_DQ,
        sdram_wire_dqm => DRAM_DQM,
        sdram_wire_ras_n => DRAM_RAS_N,
        sdram_wire_we_n => DRAM_WE_N,
        cntrl_left_export => cmd_motor_left, 
        cntrl_right_export => cmd_motor_right,
		  
          data_0r_external_connection_export => sensor_data0,
          data_ready_r_external_connection_export => sensor_data_ready,
          niveau_external_connection_export => sensor_threshold,
          vect_cap_external_connection_export => sensor_vector
    );
    
    DRAM_CLK <= CLOCK_50;

    -- Instanciation du composant PWM_generation
    PMW: PWM_generation
    PORT MAP (
        clk => CLOCK_50,
        reset_n => KEY(0),
        s_writedataL => cmd_motor_left,
        s_writedataR => cmd_motor_right,
        dc_motor_p_R => MTRR_P,
        dc_motor_n_R => MTRR_N,
        dc_motor_p_L => MTRL_P,
        dc_motor_n_L => MTRL_N
    );  

	PLL : pll_2freqs
    PORT MAP (
        inclk0 => CLOCK_50,
        areset => NOT KEY(0),
          c0 => clk_40mhz,
          c1 => clk_2khz
    );
	 
	 
	CAPTEUR : capteurs_sol_seuil
    PORT MAP (
          clk => clk_40mhz,
		  reset_n => KEY(0),
          data_capture => clk_2khz,
		  
          data_readyr => sensor_data_ready,
          niveau => sensor_threshold,
          vect_capt => sensor_vector,
		  
		  ADC_SCK  => LTC_ADC_SCK,	
		  ADC_CONVSTr => LTC_ADC_CONVST,	
		  ADC_SDIr =>	LTC_ADC_SDI,
		  ADC_SDO => LTC_ADC_SDO
		  
    );

     LED(6 DOWNTO 0) <= sensor_vector;
     LED(7) <= sensor_data_ready;
    
END Structure;
