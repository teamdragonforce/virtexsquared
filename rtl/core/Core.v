module Core(/*AUTOARG*/
   // Outputs
   ic__fsabo_valid, ic__fsabo_mode, ic__fsabo_did, ic__fsabo_subdid,
   ic__fsabo_addr, ic__fsabo_len, ic__fsabo_data, ic__fsabo_mask,
   dc__fsabo_valid, dc__fsabo_mode, dc__fsabo_did, dc__fsabo_subdid,
   dc__fsabo_addr, dc__fsabo_len, dc__fsabo_data, dc__fsabo_mask,
   spamo_valid, spamo_r_nw, spamo_did, spamo_addr, spamo_data,
   // Inouts
   control_vio,
   // Inputs
   clk, rst_b, ic__fsabo_credit, dc__fsabo_credit, fsabi_valid,
   fsabi_did, fsabi_subdid, fsabi_data, fsabi_clk, fsabi_rst_b,
   spami_busy_b, spami_data
   );
	input clk;
	input rst_b;

	`include "fsab_defines.vh"
	`include "spam_defines.vh"

	output wire                  ic__fsabo_valid;
	output wire [FSAB_REQ_HI:0]  ic__fsabo_mode;
	output wire [FSAB_DID_HI:0]  ic__fsabo_did;
	output wire [FSAB_DID_HI:0]  ic__fsabo_subdid;
	output wire [FSAB_ADDR_HI:0] ic__fsabo_addr;
	output wire [FSAB_LEN_HI:0]  ic__fsabo_len;
	output wire [FSAB_DATA_HI:0] ic__fsabo_data;
	output wire [FSAB_MASK_HI:0] ic__fsabo_mask;
	input                        ic__fsabo_credit;

	output wire                  dc__fsabo_valid;
	output wire [FSAB_REQ_HI:0]  dc__fsabo_mode;
	output wire [FSAB_DID_HI:0]  dc__fsabo_did;
	output wire [FSAB_DID_HI:0]  dc__fsabo_subdid;
	output wire [FSAB_ADDR_HI:0] dc__fsabo_addr;
	output wire [FSAB_LEN_HI:0]  dc__fsabo_len;
	output wire [FSAB_DATA_HI:0] dc__fsabo_data;
	output wire [FSAB_MASK_HI:0] dc__fsabo_mask;
	input                        dc__fsabo_credit;

	input                        fsabi_valid;
	input [FSAB_DID_HI:0]        fsabi_did;
	input [FSAB_DID_HI:0]        fsabi_subdid;
	input [FSAB_DATA_HI:0]       fsabi_data;
	input                        fsabi_clk;
	input                        fsabi_rst_b;
	
	output wire                  spamo_valid;
	output wire                  spamo_r_nw;
	output wire [SPAM_DID_HI:0]  spamo_did;
	output wire [SPAM_ADDR_HI:0] spamo_addr;
	output wire [SPAM_DATA_HI:0] spamo_data;
	
	input                        spami_busy_b;
	input [SPAM_DATA_HI:0]       spami_data;
	
	inout [35:0] control_vio;
	
	parameter DEBUG = "FALSE";

	/*AUTOWIRE*/
	// Beginning of automatic wires (for undeclared instantiated-module outputs)
	wire		bubble_1a;		// From fetch of Fetch.v
	wire		bubble_2a;		// From issue of Issue.v
	wire		bubble_3a;		// From execute of Execute.v
	wire		bubble_4a;		// From memory of Memory.v
	wire		carry_2a;		// From decode of Decode.v
	wire		cp_req;			// From memory of Memory.v
	wire		cp_rnw;			// From memory of Memory.v
	wire [31:0]	cp_write;		// From memory of Memory.v
	wire [31:0]	cpsr_2a;		// From decode of Decode.v
	wire [31:0]	cpsr_3a;		// From execute of Execute.v
	wire [31:0]	cpsr_4a;		// From memory of Memory.v
	wire		cpsrup_3a;		// From execute of Execute.v
	wire		cpsrup_4a;		// From memory of Memory.v
	wire [31:0]	dc__addr_3a;		// From memory of Memory.v
	wire [35:0]	dc__control1;		// To/From dcache of DCache.v
	wire [2:0]	dc__data_size_3a;	// From memory of Memory.v
	wire [31:0]	dc__rd_data_4a;		// From dcache of DCache.v
	wire		dc__rd_req_3a;		// From memory of Memory.v
	wire		dc__rw_wait_3a;		// From dcache of DCache.v
	wire [31:0]	dc__wr_data_3a;		// From memory of Memory.v
	wire		dc__wr_req_3a;		// From memory of Memory.v
	wire [35:0]	ic__control2;		// To/From icache of ICache.v
	wire [31:0]	ic__rd_addr_0a;		// From fetch of Fetch.v
	wire [31:0]	ic__rd_data_1a;		// From icache of ICache.v
	wire		ic__rd_req_0a;		// From fetch of Fetch.v
	wire		ic__rd_wait_0a;		// From icache of ICache.v
	wire [31:0]	insn_1a;		// From fetch of Fetch.v
	wire [31:0]	insn_2a;		// From issue of Issue.v
	wire [31:0]	insn_3a;		// From execute of Execute.v
	wire [31:0]	insn_4a;		// From memory of Memory.v
	wire		jmp_out_execute;	// From execute of Execute.v
	wire [31:0]	op0_2a;			// From decode of Decode.v
	wire [31:0]	op0_3a;			// From execute of Execute.v
	wire [31:0]	op1_2a;			// From decode of Decode.v
	wire [31:0]	op1_3a;			// From execute of Execute.v
	wire [31:0]	op2_2a;			// From decode of Decode.v
	wire [31:0]	op2_3a;			// From execute of Execute.v
	wire [31:0]	pc_1a;			// From fetch of Fetch.v
	wire [31:0]	pc_2a;			// From issue of Issue.v
	wire [31:0]	pc_3a;			// From execute of Execute.v
	wire [31:0]	pc_4a;			// From memory of Memory.v
	wire		regfile_write;		// From writeback of Writeback.v
	wire [31:0]	regfile_write_data;	// From writeback of Writeback.v
	wire [3:0]	regfile_write_reg;	// From writeback of Writeback.v
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
	wire [31:0]	spsr_4a;		// From memory of Memory.v
	wire		stall_0a;		// From issue of Issue.v
	wire		stall_cause_execute;	// From execute of Execute.v
	wire [31:0]	write_data_3a;		// From execute of Execute.v
	wire [31:0]	write_data_4a;		// From memory of Memory.v
	wire [3:0]	write_num_3a;		// From execute of Execute.v
	wire [3:0]	write_num_4a;		// From memory of Memory.v
	wire		write_reg_3a;		// From execute of Execute.v
	wire		write_reg_4a;		// From memory of Memory.v
	wire [31:0]	writeback_out_spsr;	// From writeback of Writeback.v
	// End of automatics

	wire jmp_out_writeback;
	wire stall_cause_memory;
	wire [31:0] jmppc_out_execute;
	wire [31:0] jmppc_out_writeback;
	wire [31:0] memory_out_spsr;
	wire [31:0] memory_out_cpsr;
	wire [31:0] writeback_out_cpsr;
	wire [31:0] regfile_spsr;
	wire [31:0] pc_out_memory;
	wire [31:0] insn_out_memory;
	wire [31:0] memory_out_write_data;
	wire [3:0] memory_out_write_num;

	wire jmp = jmp_out_execute | jmp_out_writeback;
	wire [31:0] jmppc = jmppc_out_execute | jmppc_out_writeback;

	wire cp_ack = 0;
	wire cp_busy = 0;
	wire [31:0] cp_read = 0;

	wire execute_out_backflush = jmp;
	wire writeback_out_backflush = jmp_out_writeback;

	ICache icache(/*AUTOINST*/
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
		      // Inouts
		      .ic__control2	(ic__control2[35:0]),
		      // Inputs
		      .clk		(clk),
		      .rst_b		(rst_b),
		      .ic__rd_addr_0a	(ic__rd_addr_0a[31:0]),
		      .ic__rd_req_0a	(ic__rd_req_0a),
		      .ic__fsabo_credit	(ic__fsabo_credit),
		      .fsabi_valid	(fsabi_valid),
		      .fsabi_did	(fsabi_did[FSAB_DID_HI:0]),
		      .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
		      .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]),
		      .fsabi_clk	(fsabi_clk),
		      .fsabi_rst_b	(fsabi_rst_b));

	DCache dcache(/*AUTOINST*/
		      // Outputs
		      .dc__rw_wait_3a	(dc__rw_wait_3a),
		      .dc__rd_data_4a	(dc__rd_data_4a[31:0]),
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
		      // Inouts
		      .dc__control1	(dc__control1[35:0]),
		      // Inputs
		      .clk		(clk),
		      .rst_b		(rst_b),
		      .dc__addr_3a	(dc__addr_3a[31:0]),
		      .dc__rd_req_3a	(dc__rd_req_3a),
		      .dc__wr_req_3a	(dc__wr_req_3a),
		      .dc__wr_data_3a	(dc__wr_data_3a[31:0]),
		      .dc__fsabo_credit	(dc__fsabo_credit),
		      .fsabi_valid	(fsabi_valid),
		      .fsabi_did	(fsabi_did[FSAB_DID_HI:0]),
		      .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
		      .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]),
		      .fsabi_clk	(fsabi_clk),
		      .fsabi_rst_b	(fsabi_rst_b),
		      .spami_busy_b	(spami_busy_b),
		      .spami_data	(spami_data[SPAM_DATA_HI:0]));

	/* Fetch AUTO_TEMPLATE (
		.jmp_0a(jmp),
		.jmppc_0a(jmppc),
		);
	*/
	Fetch fetch(/*AUTOINST*/
		    // Outputs
		    .ic__rd_addr_0a	(ic__rd_addr_0a[31:0]),
		    .ic__rd_req_0a	(ic__rd_req_0a),
		    .bubble_1a		(bubble_1a),
		    .insn_1a		(insn_1a[31:0]),
		    .pc_1a		(pc_1a[31:0]),
		    // Inputs
		    .clk		(clk),
		    .rst_b		(rst_b),
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
	Issue issue(/*AUTOINST*/
		    // Outputs
		    .stall_0a		(stall_0a),
		    .bubble_2a		(bubble_2a),
		    .pc_2a		(pc_2a[31:0]),
		    .insn_2a		(insn_2a[31:0]),
		    // Inputs
		    .clk		(clk),
		    .rst_b		(rst_b),
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
			.rst_b		(rst_b),
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
			.rst_b		(rst_b),
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

	/* stall? */
	/* Memory AUTO_TEMPLATE (
		.stall_3a(stall_cause_memory),
		.flush(writeback_out_backflush),
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
		      .stall_3a		(stall_cause_memory),	 // Templated
		      .bubble_4a	(bubble_4a),
		      .pc_4a		(pc_4a[31:0]),
		      .insn_4a		(insn_4a[31:0]),
		      .write_reg_4a	(write_reg_4a),
		      .write_num_4a	(write_num_4a[3:0]),
		      .write_data_4a	(write_data_4a[31:0]),
		      .spsr_4a		(spsr_4a[31:0]),
		      .cpsr_4a		(cpsr_4a[31:0]),
		      .cpsrup_4a	(cpsrup_4a),
		      // Inputs
		      .clk		(clk),
		      .rst_b		(rst_b),
		      .flush		(writeback_out_backflush), // Templated
		      .dc__rw_wait_3a	(dc__rw_wait_3a),
		      .dc__rd_data_4a	(dc__rd_data_4a[31:0]),
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

	/* Writeback AUTO_TEMPLATE(
		.inbubble(bubble_4a),
		.write_reg(write_reg_4a),
		.write_num(write_num_4a[3:0]),
		.write_data(write_data_4a[31:0]),
		.cpsr(cpsr_4a[31:0]),
		.spsr(spsr_4a[31:0]),
		.cpsrup(cpsrup_4a),
		.regfile_write(regfile_write),
		.regfile_write_reg(regfile_write_reg[3:0]),
		.regfile_write_data(regfile_write_data[31:0]),
		.outcpsr(writeback_out_cpsr[31:0]),
		.outspsr(writeback_out_spsr[31:0]), 
		.jmp(jmp_out_writeback),
		.jmppc(jmppc_out_writeback[31:0]),
		);
	*/
	Writeback writeback(/*AUTOINST*/
			    // Outputs
			    .regfile_write	(regfile_write), // Templated
			    .regfile_write_reg	(regfile_write_reg[3:0]), // Templated
			    .regfile_write_data	(regfile_write_data[31:0]), // Templated
			    .outcpsr		(writeback_out_cpsr[31:0]), // Templated
			    .outspsr		(writeback_out_spsr[31:0]), // Templated
			    .jmp		(jmp_out_writeback), // Templated
			    .jmppc		(jmppc_out_writeback[31:0]), // Templated
			    // Inputs
			    .clk		(clk),
			    .inbubble		(bubble_4a),	 // Templated
			    .write_reg		(write_reg_4a),	 // Templated
			    .write_num		(write_num_4a[3:0]), // Templated
			    .write_data		(write_data_4a[31:0]), // Templated
			    .cpsr		(cpsr_4a[31:0]), // Templated
			    .spsr		(spsr_4a[31:0]), // Templated
			    .cpsrup		(cpsrup_4a));	 // Templated

	defparam icache.DEBUG = DEBUG;
	defparam dcache.DEBUG = DEBUG;

	generate
	if (DEBUG == "TRUE") begin: debug
		wire [35:0] control0, control1, control2;
		
		chipscope_icon icon (
			.CONTROL0(control0), // INOUT BUS [35:0]
			.CONTROL1(dc__control1), // INOUT BUS [35:0]
			.CONTROL2(ic__control2), // INOUT BUS [35:0]
			.CONTROL3(control_vio)  // INOUT BUS [35:0]
		);
		
		chipscope_ila ila0 (
			.CONTROL(control0), // INOUT BUS [35:0]
			.CLK(clk), // IN
			.TRIG0({rst_b, bubble_1a, bubble_2a, bubble_3a, bubble_4a,
			        stall_0a, stall_cause_execute, stall_cause_memory,
			        ic__rd_addr_0a, ic__rd_data_1a, ic__rd_req_0a, ic__rd_wait_0a,
			        dc__addr_3a, dc__rd_data_4a, dc__rd_req_3a, dc__rw_wait_3a, dc__wr_req_3a})
		);
		
	end else begin: debug_tieoff
	
		assign control_vio = {36{1'bz}};
		
	end
	endgenerate

`ifdef verilator
	reg [31:0] clockno = 0;
	always @(posedge clk)
	begin
		clockno <= clockno + 1;
		$display("------------------------------------------------------------------------------");
		$display("%3d: FETCH:            Bubble: %d, Instruction: %08x, PC: %08x", clockno, bubble_1a, insn_1a, pc_1a);
		$display("%3d: ISSUE:  Stall: %d, Bubble: %d, Instruction: %08x, PC: %08x", clockno, stall_0a, bubble_2a, insn_2a, pc_2a);
		$display("%3d: DECODE:                      op0 %08x, op1 %08x, op2 %08x, carry %d", clockno, op0_2a, op1_2a, op2_2a, carry_2a);
		$display("%3d: EXEC:   Stall: %d, Bubble: %d, Instruction: %08x, PC: %08x, Reg: %d, [%08x -> %d], Jmp: %d [%08x]", clockno, stall_cause_execute, bubble_3a, insn_3a, pc_3a, write_reg_3a, write_data_3a, write_num_3a, jmp_out_execute, jmppc_out_execute);
		$display("%3d: MEMORY: Stall: %d, Bubble: %d, Instruction: %08x, PC: %08x, Reg: %d, [%08x -> %d]", clockno, stall_cause_memory, bubble_4a, insn_4a, pc_4a, write_reg_4a, write_data_4a, write_num_4a);
		$display("%3d: WRITEB:                      CPSR %08x, SPSR %08x, Reg: %d [%08x -> %d], Jmp: %d [%08x]", clockno, writeback_out_cpsr, writeback_out_spsr, regfile_write, regfile_write_data, regfile_write_reg, jmp_out_writeback, jmppc_out_writeback);
	end

	integer issued = 0;
	integer cycles = 0;
	integer last = 0;
	always @(posedge clk) begin
		cycles = cycles + 1;
		if (!stall_cause_execute && !bubble_1a) begin
			issued = issued + 1;
			last = last + 1;
		end

		if (cycles % 10000 == 0) begin
			$display("PERF: time %5d, cycles %5d, issued %5d (last %5d/10000)", $time, cycles, issued, last);
			last = 0;
		end
	end
`endif
endmodule
