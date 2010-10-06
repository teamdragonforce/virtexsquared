`define BUS_ICACHE 1
`define BUS_DCACHE 0

module System(/*AUTOARG*/
   // Outputs
   regfile_spsr, phy_init_done, pc_out_memory, memory_out_write_reg,
   memory_out_write_num, memory_out_write_data, memory_out_spsr,
   memory_out_cpsrup, memory_out_cpsr, jmppc_out_execute,
   jmp_out_execute, insn_out_memory, ddr2_we_n, ddr2_ras_n, ddr2_odt,
   ddr2_dm, ddr2_cs_n, ddr2_cke, ddr2_ck_n, ddr2_ck, ddr2_cas_n,
   ddr2_ba, ddr2_a, dc__data_size_3a, cp_write, cp_rnw, cp_req,
   clk0_tb, bubble_out_memory, sys_odata, sys_tookdata, cr_nADV,
   cr_nCE, cr_nOE, cr_nWE, cr_CRE, cr_nLB, cr_nUB, cr_CLK, cr_A,
   st_nCE,
   // Inouts
   ddr2_dqs_n, ddr2_dqs, ddr2_dq, cr_DQ,
   // Inputs
   sys_rst_n, sys_clk_p, sys_clk_n, flush, clk200_p, clk200_n, clk,
   rst, sys_idata
   );

	`include "memory_defines.vh"

	input clk; input rst;
`ifdef verilator
`else
	output wire [8:0] sys_odata;
	input [8:0] sys_idata;
	output wire sys_tookdata;

	output wire cr_nADV, cr_nCE, cr_nOE, cr_nWE, cr_CRE, cr_nLB, cr_nUB, cr_CLK;
	inout wire [15:0] cr_DQ;
	output wire [22:0] cr_A;
	output wire st_nCE;
	/*AUTOINOUT*/
	// Beginning of automatic inouts (from unused autoinst inouts)
	inout [DQ_WIDTH-1:0] ddr2_dq;		// To/From mem of FSABMemory.v
	inout [DQS_WIDTH-1:0] ddr2_dqs;		// To/From mem of FSABMemory.v
	inout [DQS_WIDTH-1:0] ddr2_dqs_n;	// To/From mem of FSABMemory.v
	// End of automatics
	/*AUTOINPUT*/
	// Beginning of automatic inputs (from unused autoinst inputs)
	input		clk200_n;		// To mem of FSABMemory.v
	input		clk200_p;		// To mem of FSABMemory.v
	input		flush;			// To memory of Memory.v
	input		sys_clk_n;		// To mem of FSABMemory.v
	input		sys_clk_p;		// To mem of FSABMemory.v
	input		sys_rst_n;		// To mem of FSABMemory.v
	// End of automatics
	/*AUTOOUTPUT*/
	// Beginning of automatic outputs (from unused autoinst outputs)
	output		bubble_out_memory;	// From memory of Memory.v
	output		clk0_tb;		// From mem of FSABMemory.v
	output		cp_req;			// From memory of Memory.v
	output		cp_rnw;			// From memory of Memory.v
	output [31:0]	cp_write;		// From memory of Memory.v
	output [2:0]	dc__data_size_3a;	// From memory of Memory.v
	output [ROW_WIDTH-1:0] ddr2_a;		// From mem of FSABMemory.v
	output [BANK_WIDTH-1:0] ddr2_ba;	// From mem of FSABMemory.v
	output		ddr2_cas_n;		// From mem of FSABMemory.v
	output [CLK_WIDTH-1:0] ddr2_ck;		// From mem of FSABMemory.v
	output [CLK_WIDTH-1:0] ddr2_ck_n;	// From mem of FSABMemory.v
	output [CKE_WIDTH-1:0] ddr2_cke;	// From mem of FSABMemory.v
	output [CS_WIDTH-1:0] ddr2_cs_n;	// From mem of FSABMemory.v
	output [DM_WIDTH-1:0] ddr2_dm;		// From mem of FSABMemory.v
	output [ODT_WIDTH-1:0] ddr2_odt;	// From mem of FSABMemory.v
	output		ddr2_ras_n;		// From mem of FSABMemory.v
	output		ddr2_we_n;		// From mem of FSABMemory.v
	output		insn_out_memory;	// From memory of Memory.v
	output		jmp_out_execute;	// From execute of Execute.v
	output		jmppc_out_execute;	// From execute of Execute.v
	output		memory_out_cpsr;	// From memory of Memory.v
	output		memory_out_cpsrup;	// From memory of Memory.v
	output		memory_out_spsr;	// From memory of Memory.v
	output		memory_out_write_data;	// From memory of Memory.v
	output		memory_out_write_num;	// From memory of Memory.v
	output		memory_out_write_reg;	// From memory of Memory.v
	output		pc_out_memory;		// From memory of Memory.v
	output		phy_init_done;		// From mem of FSABMemory.v
	output		regfile_spsr;		// From regfile of RegFile.v
	// End of automatics
`endif

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
	wire [FSAB_DATA_HI:0] fsabi_data;	// From simmem of FSABSimMemory.v, ...
	wire [FSAB_DID_HI:0] fsabi_did;		// From simmem of FSABSimMemory.v, ...
	wire [FSAB_DID_HI:0] fsabi_subdid;	// From simmem of FSABSimMemory.v, ...
	wire		fsabi_valid;		// From simmem of FSABSimMemory.v, ...
	wire [FSAB_ADDR_HI:0] fsabo_addr;	// From fsabarbiter of FSABArbiter.v
	wire		fsabo_credit;		// From simmem of FSABSimMemory.v, ...
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

	stfu_verilog_mode and_i_mean_it(/*AUTOINST*/
					// Inputs
					.cio__spami_busy_b(cio__spami_busy_b),
					.cio__spami_data(cio__spami_data[SPAM_DATA_HI:0]));

	/* XXX reset? */
	/* ICache AUTO_TEMPLATE (
		.clk(clk),
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
		.fsabo_valids({ic__fsabo_valid,dc__fsabo_valid}),
		.fsabo_modes({ic__fsabo_mode[FSAB_REQ_HI:0],dc__fsabo_mode[FSAB_REQ_HI:0]}),
		.fsabo_dids({ic__fsabo_did[FSAB_DID_HI:0],dc__fsabo_did[FSAB_DID_HI:0]}),
		.fsabo_subdids({ic__fsabo_subdid[FSAB_DID_HI:0],dc__fsabo_subdid[FSAB_DID_HI:0]}),
		.fsabo_addrs({ic__fsabo_addr[FSAB_ADDR_HI:0],dc__fsabo_addr[FSAB_ADDR_HI:0]}),
		.fsabo_lens({ic__fsabo_len[FSAB_LEN_HI:0],dc__fsabo_len[FSAB_LEN_HI:0]}),
		.fsabo_datas({ic__fsabo_data[FSAB_DATA_HI:0],dc__fsabo_data[FSAB_DATA_HI:0]}),
		.fsabo_masks({ic__fsabo_mask[FSAB_MASK_HI:0],dc__fsabo_mask[FSAB_MASK_HI:0]}),
		.fsabo_credits({ic__fsabo_credit,dc__fsabo_credit}),
		); */
	FSABArbiter fsabarbiter(
		/*AUTOINST*/
				// Outputs
				.fsabo_credits	({ic__fsabo_credit,dc__fsabo_credit}), // Templated
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
				.fsabo_valids	({ic__fsabo_valid,dc__fsabo_valid}), // Templated
				.fsabo_modes	({ic__fsabo_mode[FSAB_REQ_HI:0],dc__fsabo_mode[FSAB_REQ_HI:0]}), // Templated
				.fsabo_dids	({ic__fsabo_did[FSAB_DID_HI:0],dc__fsabo_did[FSAB_DID_HI:0]}), // Templated
				.fsabo_subdids	({ic__fsabo_subdid[FSAB_DID_HI:0],dc__fsabo_subdid[FSAB_DID_HI:0]}), // Templated
				.fsabo_addrs	({ic__fsabo_addr[FSAB_ADDR_HI:0],dc__fsabo_addr[FSAB_ADDR_HI:0]}), // Templated
				.fsabo_lens	({ic__fsabo_len[FSAB_LEN_HI:0],dc__fsabo_len[FSAB_LEN_HI:0]}), // Templated
				.fsabo_datas	({ic__fsabo_data[FSAB_DATA_HI:0],dc__fsabo_data[FSAB_DATA_HI:0]}), // Templated
				.fsabo_masks	({ic__fsabo_mask[FSAB_MASK_HI:0],dc__fsabo_mask[FSAB_MASK_HI:0]}), // Templated
				.fsabo_credit	(fsabo_credit));
	defparam fsabarbiter.FSAB_DEVICES = 2;

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
`else
	FSABMemory mem(
		/*AUTOINST*/
		       // Outputs
		       .clk0_tb		(clk0_tb),
		       .ddr2_a		(ddr2_a[ROW_WIDTH-1:0]),
		       .ddr2_ba		(ddr2_ba[BANK_WIDTH-1:0]),
		       .ddr2_cas_n	(ddr2_cas_n),
		       .ddr2_ck		(ddr2_ck[CLK_WIDTH-1:0]),
		       .ddr2_ck_n	(ddr2_ck_n[CLK_WIDTH-1:0]),
		       .ddr2_cke	(ddr2_cke[CKE_WIDTH-1:0]),
		       .ddr2_cs_n	(ddr2_cs_n[CS_WIDTH-1:0]),
		       .ddr2_dm		(ddr2_dm[DM_WIDTH-1:0]),
		       .ddr2_odt	(ddr2_odt[ODT_WIDTH-1:0]),
		       .ddr2_ras_n	(ddr2_ras_n),
		       .ddr2_we_n	(ddr2_we_n),
		       .phy_init_done	(phy_init_done),
		       .clk		(clk),
		       .fsabo_credit	(fsabo_credit),
		       .fsabi_valid	(fsabi_valid),
		       .fsabi_did	(fsabi_did[FSAB_DID_HI:0]),
		       .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
		       .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]),
		       // Inouts
		       .ddr2_dq		(ddr2_dq[DQ_WIDTH-1:0]),
		       .ddr2_dqs	(ddr2_dqs[DQS_WIDTH-1:0]),
		       .ddr2_dqs_n	(ddr2_dqs_n[DQS_WIDTH-1:0]),
		       // Inputs
		       .clk200_n	(clk200_n),
		       .clk200_p	(clk200_p),
		       .sys_clk_n	(sys_clk_n),
		       .sys_clk_p	(sys_clk_p),
		       .sys_rst_n	(sys_rst_n),
		       .Nrst		(Nrst),
		       .fsabo_valid	(fsabo_valid),
		       .fsabo_mode	(fsabo_mode[FSAB_REQ_HI:0]),
		       .fsabo_did	(fsabo_did[FSAB_DID_HI:0]),
		       .fsabo_subdid	(fsabo_subdid[FSAB_DID_HI:0]),
		       .fsabo_addr	(fsabo_addr[FSAB_ADDR_HI:0]),
		       .fsabo_len	(fsabo_len[FSAB_LEN_HI:0]),
		       .fsabo_data	(fsabo_data[FSAB_DATA_HI:0]),
		       .fsabo_mask	(fsabo_mask[FSAB_MASK_HI:0]));
`endif

	/* Fetch AUTO_TEMPLATE (
		.jmp_0a(jmp),
		.jmppc_0a(jmppc),
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
		    .Nrst		(Nrst),
		    .ic__rd_wait_0a	(ic__rd_wait_0a),
		    .ic__rd_data_1a	(ic__rd_data_1a[31:0]),
		    .stall_0a		(stall_0a),
		    .jmp_0a		(jmp),			 // Templated
		    .jmppc_0a		(jmppc));		 // Templated
	
	/* Issue AUTO_TEMPLATE (
		.stall_1a(stall_cause_execute),
		.flush_1a(execute_out_backflush | writeback_out_backflush),
		.cpsr_1a(writeback_out_cpsr),
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
		    .Nrst		(Nrst),
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
			.Nrst		(Nrst),
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
			.Nrst		(Nrst),
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
		      .Nrst		(Nrst),
		      .flush		(flush),
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

module stfu_verilog_mode (/*AUTOARG*/
   // Inputs
   cio__spami_busy_b, cio__spami_data
   );
	`include "spam_defines.vh"
	input                  cio__spami_busy_b;  // From conio of SPAM_ConsoleIO.v
	input [SPAM_DATA_HI:0] cio__spami_data;    // From conio of SPAM_ConsoleIO.v
endmodule

// Local Variables:
// verilog-library-directories:("." "console" "core" "fsab" "spam" "fsab/sim")
// End:
