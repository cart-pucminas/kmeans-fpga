Kmeans_MapRamMemory_inst : Kmeans_MapRamMemory PORT MAP (
		aclr	 => aclr_sig,
		address	 => address_sig,
		clock	 => clock_sig,
		data	 => data_sig,
		wren	 => wren_sig,
		q	 => q_sig
	);
