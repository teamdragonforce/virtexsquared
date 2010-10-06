`define BUS_ICACHE 1
`define BUS_DCACHE 0

module System(input clk, input rst
`ifdef verilator
`else
	, output wire [8:0] sys_odata,
	input [8:0] sys_idata,
	output wire sys_tookdata,

	output wire cr_nADV, cr_nCE, cr_nOE, cr_nWE, cr_CRE, cr_nLB, cr_nUB, cr_CLK,
	inout wire [15:0] cr_DQ,
	output wire [22:0] cr_A,
	output wire st_nCE
`endif
	);

`include "fsab_defines.vh"
`include "spam_defines.vh"
	
	wire [31:0] decode_out_op0, decode_out_op1, decode_out_op2, decode_out_spsr, decode_out_cpsr;
	wire decode_out_carry;
	
	wire [3:0] regfile_read_0, regfile_read_1, regfile_read_2, regfile_read_3;
	wire [31:0] regfile_rdata_0, regfile_rdata_1, regfile_rdata_2, regfile_rdata_3, regfile_spsr;
	wire regfile_write;
	wire [3:0] regfile_write_reg;
	wire [31:0] regfile_write_data;
	
	wire execute_out_write_reg;
	wire [3:0] execute_out_write_num;
	wire [31:0] execute_out_write_data;
	wire [31:0] execute_out_op0, execute_out_op1, execute_out_op2;
	wire [31:0] execute_out_cpsr, execute_out_spsr;
	wire execute_out_cpsrup;
	
	wire jmp_out_execute, jmp_out_writeback;
	wire [31:0] jmppc_out_execute, jmppc_out_writeback;
	wire jmp = jmp_out_execute | jmp_out_writeback;
	wire [31:0] jmppc = jmppc_out_execute | jmppc_out_writeback;
	
	wire memory_out_write_reg;
	wire [3:0] memory_out_write_num;
	wire [31:0] memory_out_write_data;
	wire [31:0] memory_out_cpsr, memory_out_spsr;
	wire memory_out_cpsrup;
	
	wire [31:0] writeback_out_cpsr, writeback_out_spsr;

	wire cp_req;
	wire [31:0] cp_insn;
	wire cp_ack = 0;
	wire cp_busy = 0;
	wire cp_rnw;
	wire [31:0] cp_read = 0;
	wire [31:0] cp_write;
	
	wire stall_cause_issue;
	wire stall_cause_execute;
	wire stall_cause_memory;
	wire bubble_out_fetch;
	wire bubble_out_issue;
	wire bubble_out_execute;
	wire bubble_out_memory;
	wire [31:0] insn_out_fetch;
	wire [31:0] insn_out_issue;
	wire [31:0] insn_out_execute;
	wire [31:0] insn_out_memory;
	wire [31:0] pc_out_fetch;
	wire [31:0] pc_out_issue;
	wire [31:0] pc_out_execute;
	wire [31:0] pc_out_memory;
	
	wire Nrst = ~rst;
	
	/*AUTOWIRE*/
	// Beginning of automatic wires (for undeclared instantiated-module outputs)
	wire		Ncorerst;		// From preload of FSABPreload.v
	wire		bubble_1a;		// From fetch of Fetch.v
	wire		bubble_2a;		// From issue of Issue.v
	wire		bubble_3a;		// From execute of Execute.v
	wire		carry_2a;		// From decode of Decode.v
	wire		cio__spami_busy_b;	// From conio of SPAM_ConsoleIO.v
	wire [SPAM_DATA_HI:0] cio__spami_data;	// From conio of SPAM_ConsoleIO.v
	wire [31:0]	cpsr_2a;		// From decode of Decode.v
	wire [31:0]	cpsr_3a;		// From execute of Execute.v
	wire		cpsrup_3a;		// From execute of Execute.v
	wire [31:0]	dc__addr_3a;		// From memory of Memory.v
	wire [2:0]	dc__data_size_3a;	// From memory of Memory.v
	wire [FSAB_ADDR_HI:0] dc__fsabo_addr;	// From dcache of DCache.v
	wire		dc__fsabo_credit;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DATA_HI:0] dc__fsabo_data;	// From dcache of DCache.v
	wire [FSAB_DID_HI:0] dc__fsabo_did;	// From dcache of DCache.v
	wire [FSAB_LEN_HI:0] dc__fsabo_len;	// From dcache of DCache.v
	wire [FSAB_MASK_HI:0] dc__fsabo_mask;	// From dcache of DCache.v
	wire [FSAB_REQ_HI:0] dc__fsabo_mode;	// From dcache of DCache.v
	wire [FSAB_DID_HI:0] dc__fsabo_subdid;	// From dcache of DCache.v
	wire		dc__fsabo_valid;	// From dcache of DCache.v
	wire [31:0]	dc__rd_data_3a;		// From dcache of DCache.v
	wire		dc__rd_req_3a;		// From memory of Memory.v
	wire		dc__rw_wait_3a;		// From dcache of DCache.v
	wire [31:0]	dc__wr_data_3a;		// From memory of Memory.v
	wire		dc__wr_req_3a;		// From memory of Memory.v
	wire [FSAB_DATA_HI:0] fsabi_data;	// From simmem of FSABSimMemory.v
	wire [FSAB_DID_HI:0] fsabi_did;		// From simmem of FSABSimMemory.v
	wire [FSAB_DID_HI:0] fsabi_subdid;	// From simmem of FSABSimMemory.v
	wire		fsabi_valid;		// From simmem of FSABSimMemory.v
	wire [FSAB_ADDR_HI:0] fsabo_addr;	// From fsabarbiter of FSABArbiter.v
	wire		fsabo_credit;		// From simmem of FSABSimMemory.v
	wire [FSAB_DATA_HI:0] fsabo_data;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DID_HI:0] fsabo_did;		// From fsabarbiter of FSABArbiter.v
	wire [FSAB_LEN_HI:0] fsabo_len;		// From fsabarbiter of FSABArbiter.v
	wire [FSAB_MASK_HI:0] fsabo_mask;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_REQ_HI:0] fsabo_mode;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DID_HI:0] fsabo_subdid;	// From fsabarbiter of FSABArbiter.v
	wire		fsabo_valid;		// From fsabarbiter of FSABArbiter.v
	wire [FSAB_ADDR_HI:0] ic__fsabo_addr;	// From icache of ICache.v
	wire		ic__fsabo_credit;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DATA_HI:0] ic__fsabo_data;	// From icache of ICache.v
	wire [FSAB_DID_HI:0] ic__fsabo_did;	// From icache of ICache.v
	wire [FSAB_LEN_HI:0] ic__fsabo_len;	// From icache of ICache.v
	wire [FSAB_MASK_HI:0] ic__fsabo_mask;	// From icache of ICache.v
	wire [FSAB_REQ_HI:0] ic__fsabo_mode;	// From icache of ICache.v
	wire [FSAB_DID_HI:0] ic__fsabo_subdid;	// From icache of ICache.v
	wire		ic__fsabo_valid;	// From icache of ICache.v
	wire [31:0]	ic__rd_addr_0a;		// From fetch of Fetch.v
	wire [31:0]	ic__rd_data_1a;		// From icache of ICache.v
	wire		ic__rd_req_0a;		// From fetch of Fetch.v
	wire		ic__rd_wait_0a;		// From icache of ICache.v
	wire [31:0]	insn_1a;		// From fetch of Fetch.v
	wire [31:0]	insn_2a;		// From issue of Issue.v
	wire [31:0]	insn_3a;		// From execute of Execute.v
	wire [31:0]	op0_2a;			// From decode of Decode.v
	wire [31:0]	op0_3a;			// From execute of Execute.v
	wire [31:0]	op1_2a;			// From decode of Decode.v
	wire [31:0]	op1_3a;			// From execute of Execute.v
	wire [31:0]	op2_2a;			// From decode of Decode.v
	wire [31:0]	op2_3a;			// From execute of Execute.v
	wire [31:0]	pc_1a;			// From fetch of Fetch.v
	wire [31:0]	pc_2a;			// From issue of Issue.v
	wire [31:0]	pc_3a;			// From execute of Execute.v
	wire [FSAB_ADDR_HI:0] pre__fsabo_addr;	// From preload of FSABPreload.v
	wire		pre__fsabo_credit;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DATA_HI:0] pre__fsabo_data;	// From preload of FSABPreload.v
	wire [FSAB_DID_HI:0] pre__fsabo_did;	// From preload of FSABPreload.v
	wire [FSAB_LEN_HI:0] pre__fsabo_len;	// From preload of FSABPreload.v
	wire [FSAB_MASK_HI:0] pre__fsabo_mask;	// From preload of FSABPreload.v
	wire [FSAB_REQ_HI:0] pre__fsabo_mode;	// From preload of FSABPreload.v
	wire [FSAB_DID_HI:0] pre__fsabo_subdid;	// From preload of FSABPreload.v
	wire		pre__fsabo_valid;	// From preload of FSABPreload.v
	wire [31:0]	rf__rdata_0_1a;		// From regfile of RegFile.v
	wire [31:0]	rf__rdata_1_1a;		// From regfile of RegFile.v
	wire [31:0]	rf__rdata_2_1a;		// From regfile of RegFile.v
	wire [31:0]	rf__rdata_3_3a;		// From regfile of RegFile.v
	wire [3:0]	rf__read_0_1a;		// From decode of Decode.v
	wire [3:0]	rf__read_1_1a;		// From decode of Decode.v
	wire [3:0]	rf__read_2_1a;		// From decode of Decode.v
	wire [3:0]	rf__read_3_3a;		// From memory of Memory.v
	wire [SPAM_ADDR_HI:0] spamo_addr;	// From dcache of DCache.v
	wire [SPAM_DATA_HI:0] spamo_data;	// From dcache of DCache.v
	wire [SPAM_DID_HI:0] spamo_did;		// From dcache of DCache.v
	wire		spamo_r_nw;		// From dcache of DCache.v
	wire		spamo_valid;		// From dcache of DCache.v
	wire [31:0]	spsr_2a;		// From decode of Decode.v
	wire [31:0]	spsr_3a;		// From execute of Execute.v
	wire		stall_0a;		// From issue of Issue.v
	wire [31:0]	write_data_3a;		// From execute of Execute.v
	wire [3:0]	write_num_3a;		// From execute of Execute.v
	wire		write_reg_3a;		// From execute of Execute.v
	// End of automatics

	wire execute_out_backflush;
	wire writeback_out_backflush;

	/* ICache AUTO_TEMPLATE (
		.clk(clk),
		.Nrst(Ncorerst | Nrst),
		); */
	ICache icache(
		/*AUTOINST*/
		      // Outputs
		      .ic__rd_wait_0a	(ic__rd_wait_0a),
		      .ic__rd_data_1a	(ic__rd_data_1a[31:0]),
		      .ic__fsabo_valid	(ic__fsabo_valid),
		      .ic__fsabo_mode	(ic__fsabo_mode[FSAB_REQ_HI:0]),
		      .ic__fsabo_did	(ic__fsabo_did[FSAB_DID_HI:0]),
		      .ic__fsabo_subdid	(ic__fsabo_subdid[FSAB_DID_HI:0]),
		      .ic__fsabo_addr	(ic__fsabo_addr[FSAB_ADDR_HI:0]),
		      .ic__fsabo_len	(ic__fsabo_len[FSAB_LEN_HI:0]),
		      .ic__fsabo_data	(ic__fsabo_data[FSAB_DATA_HI:0]),
		      .ic__fsabo_mask	(ic__fsabo_mask[FSAB_MASK_HI:0]),
		      // Inputs
		      .clk		(clk),			 // Templated
		      .Nrst		(Ncorerst | Nrst),	 // Templated
		      .ic__rd_addr_0a	(ic__rd_addr_0a[31:0]),
		      .ic__rd_req_0a	(ic__rd_req_0a),
		      .ic__fsabo_credit	(ic__fsabo_credit),
		      .fsabi_valid	(fsabi_valid),
		      .fsabi_did	(fsabi_did[FSAB_DID_HI:0]),
		      .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
		      .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]));
	
	wire spami_busy_b = cio__spami_busy_b;
	wire [SPAM_DATA_HI:0] spami_data = cio__spami_data[SPAM_DATA_HI:0];
	/* DCache AUTO_TEMPLATE (
		.clk(clk),
		.Nrst(Ncorerst | Nrst),
		);
		*/
	DCache dcache(
		/*AUTOINST*/
		      // Outputs
		      .dc__rw_wait_3a	(dc__rw_wait_3a),
		      .dc__rd_data_3a	(dc__rd_data_3a[31:0]),
		      .dc__fsabo_valid	(dc__fsabo_valid),
		      .dc__fsabo_mode	(dc__fsabo_mode[FSAB_REQ_HI:0]),
		      .dc__fsabo_did	(dc__fsabo_did[FSAB_DID_HI:0]),
		      .dc__fsabo_subdid	(dc__fsabo_subdid[FSAB_DID_HI:0]),
		      .dc__fsabo_addr	(dc__fsabo_addr[FSAB_ADDR_HI:0]),
		      .dc__fsabo_len	(dc__fsabo_len[FSAB_LEN_HI:0]),
		      .dc__fsabo_data	(dc__fsabo_data[FSAB_DATA_HI:0]),
		      .dc__fsabo_mask	(dc__fsabo_mask[FSAB_MASK_HI:0]),
		      .spamo_valid	(spamo_valid),
		      .spamo_r_nw	(spamo_r_nw),
		      .spamo_did	(spamo_did[SPAM_DID_HI:0]),
		      .spamo_addr	(spamo_addr[SPAM_ADDR_HI:0]),
		      .spamo_data	(spamo_data[SPAM_DATA_HI:0]),
		      // Inputs
		      .clk		(clk),			 // Templated
		      .Nrst		(Ncorerst | Nrst),	 // Templated
		      .dc__addr_3a	(dc__addr_3a[31:0]),
		      .dc__rd_req_3a	(dc__rd_req_3a),
		      .dc__wr_req_3a	(dc__wr_req_3a),
		      .dc__wr_data_3a	(dc__wr_data_3a[31:0]),
		      .dc__fsabo_credit	(dc__fsabo_credit),
		      .fsabi_valid	(fsabi_valid),
		      .fsabi_did	(fsabi_did[FSAB_DID_HI:0]),
		      .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
		      .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]),
		      .spami_busy_b	(spami_busy_b),
		      .spami_data	(spami_data[SPAM_DATA_HI:0]));
	
`ifdef verilator
	wire [8:0] sys_odata;
	wire sys_tookdata;
	wire [8:0] sys_idata = 0;
`endif

	SPAM_ConsoleIO conio(
		/*AUTOINST*/
			     // Outputs
			     .cio__spami_busy_b	(cio__spami_busy_b),
			     .cio__spami_data	(cio__spami_data[SPAM_DATA_HI:0]),
			     .sys_odata		(sys_odata[8:0]),
			     .sys_tookdata	(sys_tookdata),
			     // Inputs
			     .clk		(clk),
			     .spamo_valid	(spamo_valid),
			     .spamo_r_nw	(spamo_r_nw),
			     .spamo_did		(spamo_did[SPAM_DID_HI:0]),
			     .spamo_addr	(spamo_addr[SPAM_ADDR_HI:0]),
			     .spamo_data	(spamo_data[SPAM_DATA_HI:0]),
			     .sys_idata		(sys_idata[8:0]));

	/* FSABArbiter AUTO_TEMPLATE (
		.fsabo_valids({pre__fsabo_valid,ic__fsabo_valid,dc__fsabo_valid}),
		.fsabo_modes({pre__fsabo_mode[FSAB_REQ_HI:0],ic__fsabo_mode[FSAB_REQ_HI:0],dc__fsabo_mode[FSAB_REQ_HI:0]}),
		.fsabo_dids({pre__fsabo_did[FSAB_DID_HI:0],ic__fsabo_did[FSAB_DID_HI:0],dc__fsabo_did[FSAB_DID_HI:0]}),
		.fsabo_subdids({pre__fsabo_subdid[FSAB_DID_HI:0],ic__fsabo_subdid[FSAB_DID_HI:0],dc__fsabo_subdid[FSAB_DID_HI:0]}),
		.fsabo_addrs({pre__fsabo_addr[FSAB_ADDR_HI:0],ic__fsabo_addr[FSAB_ADDR_HI:0],dc__fsabo_addr[FSAB_ADDR_HI:0]}),
		.fsabo_lens({pre__fsabo_len[FSAB_LEN_HI:0],ic__fsabo_len[FSAB_LEN_HI:0],dc__fsabo_len[FSAB_LEN_HI:0]}),
		.fsabo_datas({pre__fsabo_data[FSAB_DATA_HI:0],ic__fsabo_data[FSAB_DATA_HI:0],dc__fsabo_data[FSAB_DATA_HI:0]}),
		.fsabo_masks({pre__fsabo_mask[FSAB_MASK_HI:0],ic__fsabo_mask[FSAB_MASK_HI:0],dc__fsabo_mask[FSAB_MASK_HI:0]}),
		.fsabo_credits({pre__fsabo_credit,ic__fsabo_credit,dc__fsabo_credit}),
		); */
	FSABArbiter fsabarbiter(
		/*AUTOINST*/
				// Outputs
				.fsabo_credits	({pre__fsabo_credit,ic__fsabo_credit,dc__fsabo_credit}), // Templated
				.fsabo_valid	(fsabo_valid),
				.fsabo_mode	(fsabo_mode[FSAB_REQ_HI:0]),
				.fsabo_did	(fsabo_did[FSAB_DID_HI:0]),
				.fsabo_subdid	(fsabo_subdid[FSAB_DID_HI:0]),
				.fsabo_addr	(fsabo_addr[FSAB_ADDR_HI:0]),
				.fsabo_len	(fsabo_len[FSAB_LEN_HI:0]),
				.fsabo_data	(fsabo_data[FSAB_DATA_HI:0]),
				.fsabo_mask	(fsabo_mask[FSAB_MASK_HI:0]),
				// Inputs
				.clk		(clk),
				.Nrst		(Nrst),
				.fsabo_valids	({pre__fsabo_valid,ic__fsabo_valid,dc__fsabo_valid}), // Templated
				.fsabo_modes	({pre__fsabo_mode[FSAB_REQ_HI:0],ic__fsabo_mode[FSAB_REQ_HI:0],dc__fsabo_mode[FSAB_REQ_HI:0]}), // Templated
				.fsabo_dids	({pre__fsabo_did[FSAB_DID_HI:0],ic__fsabo_did[FSAB_DID_HI:0],dc__fsabo_did[FSAB_DID_HI:0]}), // Templated
				.fsabo_subdids	({pre__fsabo_subdid[FSAB_DID_HI:0],ic__fsabo_subdid[FSAB_DID_HI:0],dc__fsabo_subdid[FSAB_DID_HI:0]}), // Templated
				.fsabo_addrs	({pre__fsabo_addr[FSAB_ADDR_HI:0],ic__fsabo_addr[FSAB_ADDR_HI:0],dc__fsabo_addr[FSAB_ADDR_HI:0]}), // Templated
				.fsabo_lens	({pre__fsabo_len[FSAB_LEN_HI:0],ic__fsabo_len[FSAB_LEN_HI:0],dc__fsabo_len[FSAB_LEN_HI:0]}), // Templated
				.fsabo_datas	({pre__fsabo_data[FSAB_DATA_HI:0],ic__fsabo_data[FSAB_DATA_HI:0],dc__fsabo_data[FSAB_DATA_HI:0]}), // Templated
				.fsabo_masks	({pre__fsabo_mask[FSAB_MASK_HI:0],ic__fsabo_mask[FSAB_MASK_HI:0],dc__fsabo_mask[FSAB_MASK_HI:0]}), // Templated
				.fsabo_credit	(fsabo_credit));
	defparam fsabarbiter.FSAB_DEVICES = 3;

`ifdef verilator
	FSABSimMemory simmem(
		/*AUTOINST*/
			     // Outputs
			     .fsabo_credit	(fsabo_credit),
			     .fsabi_valid	(fsabi_valid),
			     .fsabi_did		(fsabi_did[FSAB_DID_HI:0]),
			     .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
			     .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]),
			     // Inputs
			     .clk		(clk),
			     .Nrst		(Nrst),
			     .fsabo_valid	(fsabo_valid),
			     .fsabo_mode	(fsabo_mode[FSAB_REQ_HI:0]),
			     .fsabo_did		(fsabo_did[FSAB_DID_HI:0]),
			     .fsabo_subdid	(fsabo_subdid[FSAB_DID_HI:0]),
			     .fsabo_addr	(fsabo_addr[FSAB_ADDR_HI:0]),
			     .fsabo_len		(fsabo_len[FSAB_LEN_HI:0]),
			     .fsabo_data	(fsabo_data[FSAB_DATA_HI:0]),
			     .fsabo_mask	(fsabo_mask[FSAB_MASK_HI:0]));
`endif

	FSABPreload preload(/*AUTOINST*/
			    // Outputs
			    .Ncorerst		(Ncorerst),
			    .pre__fsabo_valid	(pre__fsabo_valid),
			    .pre__fsabo_mode	(pre__fsabo_mode[FSAB_REQ_HI:0]),
			    .pre__fsabo_did	(pre__fsabo_did[FSAB_DID_HI:0]),
			    .pre__fsabo_subdid	(pre__fsabo_subdid[FSAB_DID_HI:0]),
			    .pre__fsabo_addr	(pre__fsabo_addr[FSAB_ADDR_HI:0]),
			    .pre__fsabo_len	(pre__fsabo_len[FSAB_LEN_HI:0]),
			    .pre__fsabo_data	(pre__fsabo_data[FSAB_DATA_HI:0]),
			    .pre__fsabo_mask	(pre__fsabo_mask[FSAB_MASK_HI:0]),
			    // Inputs
			    .clk		(clk),
			    .Nrst		(Nrst),
			    .pre__fsabo_credit	(pre__fsabo_credit),
			    .fsabi_valid	(fsabi_valid),
			    .fsabi_did		(fsabi_did[FSAB_DID_HI:0]),
			    .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
			    .fsabi_data		(fsabi_data[FSAB_DATA_HI:0]));

	/* Fetch AUTO_TEMPLATE (
		.jmp_0a(jmp),
		.jmppc_0a(jmppc),
		.Nrst(Ncorerst | Nrst),
		);
	*/
	Fetch fetch(
		/*AUTOINST*/
		    // Outputs
		    .ic__rd_addr_0a	(ic__rd_addr_0a[31:0]),
		    .ic__rd_req_0a	(ic__rd_req_0a),
		    .bubble_1a		(bubble_1a),
		    .insn_1a		(insn_1a[31:0]),
		    .pc_1a		(pc_1a[31:0]),
		    // Inputs
		    .clk		(clk),
		    .Nrst		(Ncorerst | Nrst),	 // Templated
		    .ic__rd_wait_0a	(ic__rd_wait_0a),
		    .ic__rd_data_1a	(ic__rd_data_1a[31:0]),
		    .stall_0a		(stall_0a),
		    .jmp_0a		(jmp),			 // Templated
		    .jmppc_0a		(jmppc));		 // Templated
	
	/* Issue AUTO_TEMPLATE (
		.stall_1a(stall_cause_execute),
		.flush_1a(execute_out_backflush | writeback_out_backflush),
		.cpsr_1a(writeback_out_cpsr),
		.Nrst(Ncorerst | Nrst),
		);
	*/
	Issue issue(
		/*AUTOINST*/
		    // Outputs
		    .stall_0a		(stall_0a),
		    .bubble_2a		(bubble_2a),
		    .pc_2a		(pc_2a[31:0]),
		    .insn_2a		(insn_2a[31:0]),
		    // Inputs
		    .clk		(clk),
		    .Nrst		(Ncorerst | Nrst),	 // Templated
		    .stall_1a		(stall_cause_execute),	 // Templated
		    .flush_1a		(execute_out_backflush | writeback_out_backflush), // Templated
		    .bubble_1a		(bubble_1a),
		    .insn_1a		(insn_1a[31:0]),
		    .pc_1a		(pc_1a[31:0]),
		    .cpsr_1a		(writeback_out_cpsr));	 // Templated
	
	/* RegFile AUTO_TEMPLATE (
		.spsr(regfile_spsr),
		.write(regfile_write),
		.write_reg(regfile_write_reg),
		.write_data(regfile_write_data),
		.Nrst(Ncorerst | Nrst),
		);
	*/
	wire [3:0] rf__read_3_4a;
	RegFile regfile(
		/*AUTOINST*/
			// Outputs
			.rf__rdata_0_1a	(rf__rdata_0_1a[31:0]),
			.rf__rdata_1_1a	(rf__rdata_1_1a[31:0]),
			.rf__rdata_2_1a	(rf__rdata_2_1a[31:0]),
			.rf__rdata_3_3a	(rf__rdata_3_3a[31:0]),
			.spsr		(regfile_spsr),		 // Templated
			// Inputs
			.clk		(clk),
			.Nrst		(Ncorerst | Nrst),	 // Templated
			.rf__read_0_1a	(rf__read_0_1a[3:0]),
			.rf__read_1_1a	(rf__read_1_1a[3:0]),
			.rf__read_2_1a	(rf__read_2_1a[3:0]),
			.rf__read_3_3a	(rf__read_3_3a[3:0]),
			.write		(regfile_write),	 // Templated
			.write_reg	(regfile_write_reg),	 // Templated
			.write_data	(regfile_write_data));	 // Templated
	
	/* Decode AUTO_TEMPLATE (
		.stall(stall_cause_execute),
		.cpsr_1a(writeback_out_cpsr),
		.spsr_1a(writeback_out_spsr),
		);
	*/
	Decode decode(
		/*AUTOINST*/
		      // Outputs
		      .op0_2a		(op0_2a[31:0]),
		      .op1_2a		(op1_2a[31:0]),
		      .op2_2a		(op2_2a[31:0]),
		      .carry_2a		(carry_2a),
		      .cpsr_2a		(cpsr_2a[31:0]),
		      .spsr_2a		(spsr_2a[31:0]),
		      .rf__read_0_1a	(rf__read_0_1a[3:0]),
		      .rf__read_1_1a	(rf__read_1_1a[3:0]),
		      .rf__read_2_1a	(rf__read_2_1a[3:0]),
		      // Inputs
		      .clk		(clk),
		      .stall		(stall_cause_execute),	 // Templated
		      .insn_1a		(insn_1a[31:0]),
		      .pc_1a		(pc_1a[31:0]),
		      .cpsr_1a		(writeback_out_cpsr),	 // Templated
		      .spsr_1a		(writeback_out_spsr),	 // Templated
		      .rf__rdata_0_1a	(rf__rdata_0_1a[31:0]),
		      .rf__rdata_1_1a	(rf__rdata_1_1a[31:0]),
		      .rf__rdata_2_1a	(rf__rdata_2_1a[31:0]));

	/* Execute AUTO_TEMPLATE (
		.stall_2a(stall_cause_memory),
		.flush_2a(writeback_out_backflush),
		.outstall_2a(stall_cause_execute),
		.jmp_2a(jmp_out_execute),
		.jmppc_2a(jmppc_out_execute),
		.Nrst(Nrst | Ncorerst),
		);
	*/	
	Execute execute(
		/*AUTOINST*/
			// Outputs
			.outstall_2a	(stall_cause_execute),	 // Templated
			.bubble_3a	(bubble_3a),
			.cpsr_3a	(cpsr_3a[31:0]),
			.spsr_3a	(spsr_3a[31:0]),
			.cpsrup_3a	(cpsrup_3a),
			.write_reg_3a	(write_reg_3a),
			.write_num_3a	(write_num_3a[3:0]),
			.write_data_3a	(write_data_3a[31:0]),
			.jmppc_2a	(jmppc_out_execute),	 // Templated
			.jmp_2a		(jmp_out_execute),	 // Templated
			.pc_3a		(pc_3a[31:0]),
			.insn_3a	(insn_3a[31:0]),
			.op0_3a		(op0_3a[31:0]),
			.op1_3a		(op1_3a[31:0]),
			.op2_3a		(op2_3a[31:0]),
			// Inputs
			.clk		(clk),
			.Nrst		(Nrst | Ncorerst),	 // Templated
			.stall_2a	(stall_cause_memory),	 // Templated
			.flush_2a	(writeback_out_backflush), // Templated
			.bubble_2a	(bubble_2a),
			.pc_2a		(pc_2a[31:0]),
			.insn_2a	(insn_2a[31:0]),
			.cpsr_2a	(cpsr_2a[31:0]),
			.spsr_2a	(spsr_2a[31:0]),
			.op0_2a		(op0_2a[31:0]),
			.op1_2a		(op1_2a[31:0]),
			.op2_2a		(op2_2a[31:0]),
			.carry_2a	(carry_2a));
	assign execute_out_backflush = jmp;
	
	assign cp_insn = insn_3a;
	/* stall? */
	/* Memory AUTO_TEMPLATE (
		.flush(writeback_out_backflush),
		.outstall(stall_cause_memory),
		.outbubble(bubble_out_memory), 
		.outpc(pc_out_memory),
		.outinsn(insn_out_memory),
		.out_write_reg(memory_out_write_reg),
		.out_write_num(memory_out_write_num), 
		.out_write_data(memory_out_write_data),
		.outcpsr(memory_out_cpsr),
		.outspsr(memory_out_spsr),
		.outcpsrup(memory_out_cpsrup),
		.Nrst(Nrst | Ncorerst),
		);
		*/
	Memory memory(
		/*AUTOINST*/
		      // Outputs
		      .dc__addr_3a	(dc__addr_3a[31:0]),
		      .dc__rd_req_3a	(dc__rd_req_3a),
		      .dc__wr_req_3a	(dc__wr_req_3a),
		      .dc__wr_data_3a	(dc__wr_data_3a[31:0]),
		      .dc__data_size_3a	(dc__data_size_3a[2:0]),
		      .rf__read_3_3a	(rf__read_3_3a[3:0]),
		      .cp_req		(cp_req),
		      .cp_rnw		(cp_rnw),
		      .cp_write		(cp_write[31:0]),
		      .outstall		(stall_cause_memory),	 // Templated
		      .outbubble	(bubble_out_memory),	 // Templated
		      .outpc		(pc_out_memory),	 // Templated
		      .outinsn		(insn_out_memory),	 // Templated
		      .out_write_reg	(memory_out_write_reg),	 // Templated
		      .out_write_num	(memory_out_write_num),	 // Templated
		      .out_write_data	(memory_out_write_data), // Templated
		      .outspsr		(memory_out_spsr),	 // Templated
		      .outcpsr		(memory_out_cpsr),	 // Templated
		      .outcpsrup	(memory_out_cpsrup),	 // Templated
		      // Inputs
		      .clk		(clk),
		      .Nrst		(Nrst | Ncorerst),	 // Templated
		      .flush		(writeback_out_backflush), // Templated
		      .dc__rw_wait_3a	(dc__rw_wait_3a),
		      .dc__rd_data_3a	(dc__rd_data_3a[31:0]),
		      .rf__rdata_3_3a	(rf__rdata_3_3a[31:0]),
		      .cp_ack		(cp_ack),
		      .cp_busy		(cp_busy),
		      .cp_read		(cp_read[31:0]),
		      .bubble_3a	(bubble_3a),
		      .pc_3a		(pc_3a[31:0]),
		      .insn_3a		(insn_3a[31:0]),
		      .op0_3a		(op0_3a[31:0]),
		      .op1_3a		(op1_3a[31:0]),
		      .op2_3a		(op2_3a[31:0]),
		      .spsr_3a		(spsr_3a[31:0]),
		      .cpsr_3a		(cpsr_3a[31:0]),
		      .cpsrup_3a	(cpsrup_3a),
		      .write_reg_3a	(write_reg_3a),
		      .write_num_3a	(write_num_3a[3:0]),
		      .write_data_3a	(write_data_3a[31:0]));
	
	
	Writeback writeback(
		.clk(clk),
		.inbubble(bubble_out_memory),
		.write_reg(memory_out_write_reg), .write_num(memory_out_write_num), .write_data(memory_out_write_data),
		.cpsr(memory_out_cpsr), .spsr(memory_out_spsr), .cpsrup(memory_out_cpsrup),
		.regfile_write(regfile_write), .regfile_write_reg(regfile_write_reg), .regfile_write_data(regfile_write_data),
		.outcpsr(writeback_out_cpsr), .outspsr(writeback_out_spsr), 
		.jmp(jmp_out_writeback), .jmppc(jmppc_out_writeback));
	assign writeback_out_backflush = jmp_out_writeback;

	reg [31:0] clockno = 0;
	always @(posedge clk)
	begin
		clockno <= clockno + 1;
		$display("------------------------------------------------------------------------------");
		$display("%3d: FETCH:            Bubble: %d, Instruction: %08x, PC: %08x", clockno, bubble_1a, insn_1a, pc_1a);
		$display("%3d: ISSUE:  Stall: %d, Bubble: %d, Instruction: %08x, PC: %08x", clockno, stall_0a, bubble_2a, insn_2a, pc_2a);
		$display("%3d: DECODE:                      op0 %08x, op1 %08x, op2 %08x, carry %d", clockno, op0_2a, op1_2a, op2_2a, carry_2a);
		$display("%3d: EXEC:   Stall: %d, Bubble: %d, Instruction: %08x, PC: %08x, Reg: %d, [%08x -> %d], Jmp: %d [%08x]", clockno, stall_cause_execute, bubble_3a, insn_3a, pc_3a, write_reg_3a, write_data_3a, write_num_3a, jmp_out_execute, jmppc_out_execute);
		$display("%3d: MEMORY: Stall: %d, Bubble: %d, Instruction: %08x, PC: %08x, Reg: %d, [%08x -> %d]", clockno, stall_cause_memory, bubble_out_memory, insn_out_memory, pc_out_memory, memory_out_write_reg, memory_out_write_data, memory_out_write_num);
		$display("%3d: WRITEB:                      CPSR %08x, SPSR %08x, Reg: %d [%08x -> %d], Jmp: %d [%08x]", clockno, writeback_out_cpsr, writeback_out_spsr, regfile_write, regfile_write_data, regfile_write_reg, jmp_out_writeback, jmppc_out_writeback);
	end
endmodule

// Local Variables:
// verilog-library-directories:("." "console" "core" "fsab" "spam" "fsab/sim")
// End:
