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
	
	wire [7:0] bus_req;
	wire [7:0] bus_ack;
	wire [31:0] bus_addr;
	wire [31:0] bus_rdata;
	wire [31:0] bus_wdata;
	wire bus_rd, bus_wr;
	wire bus_ready;

	wire bus_req_icache;
	wire bus_req_dcache;
	assign bus_req = {6'b0, bus_req_icache, bus_req_dcache};
	wire bus_ack_icache = bus_ack[`BUS_ICACHE];
	wire bus_ack_dcache = bus_ack[`BUS_DCACHE];
	
	wire [31:0] bus_addr_icache;
	wire [31:0] bus_wdata_icache;
	wire bus_rd_icache;
	wire bus_wr_icache;
	
	wire [31:0] bus_addr_dcache;
	wire [31:0] bus_wdata_dcache;
	wire bus_rd_dcache;
	wire bus_wr_dcache;
	
	wire [31:0] bus_rdata_blockram, bus_rdata_cellularram;
	wire bus_ready_blockram, bus_ready_cellularram;
	
	assign bus_addr = bus_addr_icache | bus_addr_dcache;
	assign bus_rdata = bus_rdata_blockram | bus_rdata_cellularram;
	assign bus_wdata = bus_wdata_icache | bus_wdata_dcache;
	assign bus_rd = bus_rd_icache | bus_rd_dcache;
	assign bus_wr = bus_wr_icache | bus_wr_dcache;
	assign bus_ready = bus_ready_blockram | bus_ready_cellularram;

	wire [31:0] icache_rd_addr;
	wire icache_rd_req;
	wire icache_rd_wait;
	wire [31:0] icache_rd_data;
	
	wire [31:0] dcache_addr;
	wire dcache_rd_req, dcache_wr_req;
	wire dcache_rw_wait;
	wire [31:0] dcache_wr_data, dcache_rd_data;
	
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

	wire cp_ack_terminal;
	wire cp_busy_terminal;
	wire [31:0] cp_read_terminal;
	
	wire cp_req;
	wire [31:0] cp_insn;
	wire cp_ack = cp_ack_terminal;
	wire cp_busy = cp_busy_terminal;
	wire cp_rnw;
	wire [31:0] cp_read = cp_read_terminal;
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
	wire [31:0]	cpsr_2a;		// From decode of Decode.v
	wire [31:0]	cpsr_3a;		// From execute of Execute.v
	wire		cpsrup_3a;		// From execute of Execute.v
	wire [31:0]	dc__addr_3a;		// From memory of Memory.v
	wire [2:0]	dc__data_size_3a;	// From memory of Memory.v
	wire [31:0]	dc__rd_data_3a;		// From dcache of DCache.v
	wire		dc__rd_req_3a;		// From memory of Memory.v
	wire		dc__rw_wait_3a;		// From dcache of DCache.v
	wire [31:0]	dc__wr_data_3a;		// From memory of Memory.v
	wire		dc__wr_req_3a;		// From memory of Memory.v
	wire [FSAB_DATA_HI:0] fsabi_data;	// From simmem of FSABSimMemory.v
	wire [FSAB_DID_HI:0] fsabi_did;		// From simmem of FSABSimMemory.v
	wire [FSAB_DID_HI:0] fsabi_subdid;	// From simmem of FSABSimMemory.v
	wire [FSAB_DATA_HI:0] fsabi1_data;	// From simmem of FSABSimMemory.v
	wire [FSAB_DID_HI:0] fsabi1_did;		// From simmem of FSABSimMemory.v
	wire [FSAB_DID_HI:0] fsabi1_subdid;	// From simmem of FSABSimMemory.v
	wire		fsabi_valid;		// From simmem of FSABSimMemory.v
	wire		fsabi1_valid;		// From simmem of FSABSimMemory.v
	wire [FSAB_ADDR_HI:0] fsabo1_addr;	// From icache of ICache.v
	wire [FSAB_DATA_HI:0] fsabo1_data;	// From icache of ICache.v
	wire [FSAB_DID_HI:0] fsabo1_did;	// From icache of ICache.v
	wire [FSAB_LEN_HI:0] fsabo1_len;	// From icache of ICache.v
	wire [FSAB_MASK_HI:0] fsabo1_mask;	// From icache of ICache.v
	wire [FSAB_REQ_HI:0] fsabo1_mode;	// From icache of ICache.v
	wire [FSAB_DID_HI:0] fsabo1_subdid;	// From icache of ICache.v
	wire		fsabo1_valid;		// From icache of ICache.v
	wire [FSAB_ADDR_HI:0] fsabo_addr;	// From dcache of DCache.v
	wire		fsabo_credit;		// From simmem of FSABSimMemory.v
	wire		fsabo1_credit;		// From simmem of FSABSimMemory.v
	wire [FSAB_DATA_HI:0] fsabo_data;	// From dcache of DCache.v
	wire [FSAB_DID_HI:0] fsabo_did;		// From dcache of DCache.v
	wire [FSAB_LEN_HI:0] fsabo_len;		// From dcache of DCache.v
	wire [FSAB_MASK_HI:0] fsabo_mask;	// From dcache of DCache.v
	wire [FSAB_REQ_HI:0] fsabo_mode;	// From dcache of DCache.v
	wire [FSAB_DID_HI:0] fsabo_subdid;	// From dcache of DCache.v
	wire		fsabo_valid;		// From dcache of DCache.v
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
	wire [31:0]	spsr_2a;		// From decode of Decode.v
	wire [31:0]	spsr_3a;		// From execute of Execute.v
	wire		stall_0a;		// From issue of Issue.v
	wire [31:0]	write_data_3a;		// From execute of Execute.v
	wire [3:0]	write_num_3a;		// From execute of Execute.v
	wire		write_reg_3a;		// From execute of Execute.v
	// End of automatics

	wire execute_out_backflush;
	wire writeback_out_backflush;

	BusArbiter busarbiter(.bus_req(bus_req), .bus_ack(bus_ack));

	/* XXX reset? */
	/* ICache AUTO_TEMPLATE (
		.clk(clk),
		.fsabo_valid	(fsabo1_valid),
		.fsabo_mode	(fsabo1_mode[FSAB_REQ_HI:0]),
		.fsabo_did	(fsabo1_did[FSAB_DID_HI:0]),
		.fsabo_subdid	(fsabo1_subdid[FSAB_DID_HI:0]),
		.fsabo_addr	(fsabo1_addr[FSAB_ADDR_HI:0]),
		.fsabo_len	(fsabo1_len[FSAB_LEN_HI:0]),
		.fsabo_data	(fsabo1_data[FSAB_DATA_HI:0]),
		.fsabo_mask	(fsabo1_mask[FSAB_MASK_HI:0]),
		.fsabo_credit	(fsabo1_credit),
		.fsabi_valid	(fsabi1_valid),
		.fsabi_did	(fsabi1_did[FSAB_DID_HI:0]),
		.fsabi_subdid	(fsabi1_subdid[FSAB_DID_HI:0]),
		.fsabi_data	(fsabi1_data[FSAB_DATA_HI:0]),
		); */
	ICache icache(
		/*AUTOINST*/
		      // Outputs
		      .ic__rd_wait_0a	(ic__rd_wait_0a),
		      .ic__rd_data_1a	(ic__rd_data_1a[31:0]),
		      .fsabo_valid	(fsabo1_valid),		 // Templated
		      .fsabo_mode	(fsabo1_mode[FSAB_REQ_HI:0]), // Templated
		      .fsabo_did	(fsabo1_did[FSAB_DID_HI:0]), // Templated
		      .fsabo_subdid	(fsabo1_subdid[FSAB_DID_HI:0]), // Templated
		      .fsabo_addr	(fsabo1_addr[FSAB_ADDR_HI:0]), // Templated
		      .fsabo_len	(fsabo1_len[FSAB_LEN_HI:0]), // Templated
		      .fsabo_data	(fsabo1_data[FSAB_DATA_HI:0]), // Templated
		      .fsabo_mask	(fsabo1_mask[FSAB_MASK_HI:0]), // Templated
		      // Inputs
		      .clk		(clk),			 // Templated
		      .ic__rd_addr_0a	(ic__rd_addr_0a[31:0]),
		      .ic__rd_req_0a	(ic__rd_req_0a),
		      .fsabo_credit	(fsabo1_credit),	 // Templated
		      .fsabi_valid	(fsabi1_valid),		 // Templated
		      .fsabi_did	(fsabi1_did[FSAB_DID_HI:0]), // Templated
		      .fsabi_subdid	(fsabi1_subdid[FSAB_DID_HI:0]), // Templated
		      .fsabi_data	(fsabi1_data[FSAB_DATA_HI:0])); // Templated
	
	/* DCache AUTO_TEMPLATE (
		.clk(clk),
		);
		*/
	DCache dcache(
		/*AUTOINST*/
		      // Outputs
		      .dc__rw_wait_3a	(dc__rw_wait_3a),
		      .dc__rd_data_3a	(dc__rd_data_3a[31:0]),
		      .fsabo_valid	(fsabo_valid),
		      .fsabo_mode	(fsabo_mode[FSAB_REQ_HI:0]),
		      .fsabo_did	(fsabo_did[FSAB_DID_HI:0]),
		      .fsabo_subdid	(fsabo_subdid[FSAB_DID_HI:0]),
		      .fsabo_addr	(fsabo_addr[FSAB_ADDR_HI:0]),
		      .fsabo_len	(fsabo_len[FSAB_LEN_HI:0]),
		      .fsabo_data	(fsabo_data[FSAB_DATA_HI:0]),
		      .fsabo_mask	(fsabo_mask[FSAB_MASK_HI:0]),
		      // Inputs
		      .clk		(clk),			 // Templated
		      .dc__addr_3a	(dc__addr_3a[31:0]),
		      .dc__rd_req_3a	(dc__rd_req_3a),
		      .dc__wr_req_3a	(dc__wr_req_3a),
		      .dc__wr_data_3a	(dc__wr_data_3a[31:0]),
		      .fsabo_credit	(fsabo_credit),
		      .fsabi_valid	(fsabi_valid),
		      .fsabi_did	(fsabi_did[FSAB_DID_HI:0]),
		      .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
		      .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]));

`ifdef verilator
	BigBlockRAM
`else
	BlockRAM
`endif
	blockram(
		.clk(clk),
		.bus_addr(bus_addr), .bus_rdata(bus_rdata_blockram),
		.bus_wdata(bus_wdata), .bus_rd(bus_rd), .bus_wr(bus_wr),
		.bus_ready(bus_ready_blockram));

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

	FSABSimMemory simmem1(
			     // Outputs
			     .fsabo_credit	(fsabo1_credit),
			     .fsabi_valid	(fsabi1_valid),
			     .fsabi_did		(fsabi1_did[FSAB_DID_HI:0]),
			     .fsabi_subdid	(fsabi1_subdid[FSAB_DID_HI:0]),
			     .fsabi_data	(fsabi1_data[FSAB_DATA_HI:0]),
			     // Inputs
			     .clk		(clk),
			     .Nrst		(Nrst),
			     .fsabo_valid	(fsabo1_valid),
			     .fsabo_mode	(fsabo1_mode[FSAB_REQ_HI:0]),
			     .fsabo_did		(fsabo1_did[FSAB_DID_HI:0]),
			     .fsabo_subdid	(fsabo1_subdid[FSAB_DID_HI:0]),
			     .fsabo_addr	(fsabo1_addr[FSAB_ADDR_HI:0]),
			     .fsabo_len		(fsabo1_len[FSAB_LEN_HI:0]),
			     .fsabo_data	(fsabo1_data[FSAB_DATA_HI:0]),
			     .fsabo_mask	(fsabo1_mask[FSAB_MASK_HI:0]));
`endif

	assign bus_rdata_cellularram = 32'h00000000;
	assign bus_ready_cellularram = 0;

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
		.flush(writeback_out_backflush),
		.outstall(stall_cause_memory),
		.outbubble(bubble_out_memory), 
		.outpc(pc_out_memory),
		.outinsn(insn_out_memory),
		.out_write_reg(memory_out_write_reg),
		.out_write_num(memory_out_write_num), 
		.out_write_data(memory_out_write_data),
		.cp_req(cp_req),
		.cp_ack(cp_ack),
		.cp_busy(cp_busy),
		.cp_rnw(cp_rnw),
		.cp_read(cp_read),
		.cp_write(cp_write),
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
		      .cp_req		(cp_req),		 // Templated
		      .cp_rnw		(cp_rnw),		 // Templated
		      .cp_write		(cp_write),		 // Templated
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
		      .flush		(writeback_out_backflush), // Templated
		      .dc__rw_wait_3a	(dc__rw_wait_3a),
		      .dc__rd_data_3a	(dc__rd_data_3a[31:0]),
		      .rf__rdata_3_3a	(rf__rdata_3_3a[31:0]),
		      .cp_ack		(cp_ack),		 // Templated
		      .cp_busy		(cp_busy),		 // Templated
		      .cp_read		(cp_read),		 // Templated
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
	
	Terminal terminal(	
		.clk(clk),
		.cp_req(cp_req), .cp_insn(cp_insn), .cp_ack(cp_ack_terminal), .cp_busy(cp_busy_terminal), .cp_rnw(cp_rnw),
		.cp_read(cp_read_terminal), .cp_write(cp_write)
`ifdef verilator
`else
		, .sys_odata(sys_odata), .sys_tookdata(sys_tookdata), .sys_idata(sys_idata)
`endif
		);
	
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
