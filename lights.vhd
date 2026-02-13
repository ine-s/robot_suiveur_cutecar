LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY lights IS
	PORT (
		SW : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		CLOCK_50 : IN STD_LOGIC;
		MTRR_P, MTRR_N : OUT STD_LOGIC;      
      MTRL_P, MTRL_N : OUT STD_LOGIC;      
      MTR_Sleep_n : OUT STD_LOGIC;         
      VCC3P3_PWRON_n : OUT STD_LOGIC;
		DRAM_CLK, DRAM_CKE : OUT STD_LOGIC;
		DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		DRAM_BA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		DRAM_CS_N, DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N : OUT STD_LOGIC;
		DRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		DRAM_DQM : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) );
	END lights;
	
ARCHITECTURE Structure OF lights IS
	COMPONENT niosII_v1
		PORT (
			clk_clk : IN STD_LOGIC;
			reset_reset_n : IN STD_LOGIC;
			moteur_r_export  : out   std_logic_vector(15 downto 0); 
			moteur_l_export  : out   std_logic_vector(15 downto 0);         
			sw_export : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			sdram_wire_addr : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
			sdram_wire_ba : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			sdram_wire_cas_n : OUT STD_LOGIC;
			sdram_wire_cke : OUT STD_LOGIC;
			sdram_wire_cs_n : OUT STD_LOGIC;
			sdram_wire_dq : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			sdram_wire_dqm : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			sdram_wire_ras_n : OUT STD_LOGIC;
			sdram_wire_we_n : OUT STD_LOGIC;
			sdram_clk_clk    : out   std_logic 	);
	END COMPONENT;
	

	COMPONENT PWM_generation
		PORT (
			 clk, reset_n : IN STD_LOGIC;
			 s_writedataR, s_writedataL : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
			 dc_motor_p_R, dc_motor_n_R, dc_motor_p_L, dc_motor_n_L : OUT STD_LOGIC
		);
	END COMPONENT;
	
	SIGNAL cmd_motor_R_sig : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL cmd_motor_L_sig : STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	BEGIN
	VCC3P3_PWRON_n <= '0';
	MTR_Sleep_n <= '1';

		NiosII: niosII_v1
			PORT MAP (
				clk_clk => CLOCK_50,
				sdram_clk_clk => DRAM_CLK,
				moteur_l_export  => cmd_motor_R_sig,
				moteur_r_export  => cmd_motor_L_sig,
				reset_reset_n => KEY(0),
				sw_export => SW,
				sdram_wire_addr => DRAM_ADDR,
				sdram_wire_ba => DRAM_BA,
				sdram_wire_cas_n => DRAM_CAS_N,
				sdram_wire_cke => DRAM_CKE,
				sdram_wire_cs_n => DRAM_CS_N,
				sdram_wire_dq => DRAM_DQ,
				sdram_wire_dqm => DRAM_DQM,
				sdram_wire_ras_n => DRAM_RAS_N,
				sdram_wire_we_n => DRAM_WE_N );
				
		PWM_inst: PWM_generation
			PORT MAP (
				clk => CLOCK_50,
				reset_n => KEY(0),
				s_writedataR => cmd_motor_R_sig(13 DOWNTO 0),
				s_writedataL => cmd_motor_L_sig(13 DOWNTO 0),
				dc_motor_p_R => MTRR_P,
				dc_motor_n_R => MTRR_N,
				dc_motor_p_L => MTRL_P,
				dc_motor_n_L => MTRL_N
			);
	END Structure;