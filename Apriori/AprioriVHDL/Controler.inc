-- WARNING: Do NOT edit the input and output ports in this file in a text
-- editor if you plan to continue editing the block that represents it in
-- the Block Editor! File corruption is VERY likely to occur.

-- Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.


-- Generated by Quartus Prime Version 15.1 (Build Build 185 10/21/2015)
-- Created on Thu Feb 25 15:22:56 2021

FUNCTION Controler (clk_in, out_cont[7..0], saida_Mpf, saida1_Mend[7..0], saida2_Mend[7..0], verifPro1Sup1, verifPro2Sup2)
	WITH (n)
	RETURNS (enable_rom, enable_1itemap, reset_cont, enable_proc1_1item, enable_proc2_1item, enable1_MPF, enable2_MPF, enable3_MPF, enable4_MPF, enable_MPD1, enable_MPD2, enable_MPC, quant_totl[7..0], env_cem[7..0], end_proc1_1item[7..0], end_proc2_1item[7..0], suporte[7..0], end_rom[4..0], ena_wren, enderew_RAM[7..0], enable_MER1, enable_MER2, tam_palavra[8..0], ena_reden1, ena_reden2, enable_doisitem, ena_wren_RAM2, enable_rom_2, end_rom_2[4..0], enabProc1Sup1, enabProc2Sup2, k_item[7..0], enderew_RAM2[7..0]);
