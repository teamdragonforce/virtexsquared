`define BUS_ICACHE 1
`define BUS_DCACHE 0

module System(input clk, input rst
`ifdef verilator
`else
	, output wire [8:0] sys_odata,
	input [8:0] sys_idata,
	output wire sys_tookdata
`endif
	);
	
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
	
	wire [31:0] bus_rdata_blockram;
	wire bus_ready_blockram;
	
	assign bus_addr = bus_addr_icache | bus_addr_dcache;
	assign bus_rdata = bus_rdata_blockram;
	assign bus_wdata = bus_wdata_icache | bus_wdata_dcache;
	assign bus_rd = bus_rd_icache | bus_rd_dcache;
	assign bus_wr = bus_wr_icache | bus_wr_dcache;
	assign bus_ready = bus_ready_blockram;

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
	wire		carry_2a;		// From decode of Decode.v
	wire [31:0]	cpsr_2a;		// From decode of Decode.v
	wire [31:0]	ic__rd_addr_0a;		// From fetch of Fetch.v
	wire [31:0]	ic__rd_data_1a;		// From icache of ICache.v
	wire		ic__rd_req_0a;		// From fetch of Fetch.v
	wire		ic__rd_wait_0a;		// From icache of ICache.v
	wire [31:0]	insn_1a;		// From fetch of Fetch.v
	wire [31:0]	insn_2a;		// From issue of Issue.v
	wire [31:0]	op0_2a;			// From decode of Decode.v
	wire [31:0]	op1_2a;			// From decode of Decode.v
	wire [31:0]	op2_2a;			// From decode of Decode.v
	wire [31:0]	pc_1a;			// From fetch of Fetch.v
	wire [31:0]	pc_2a;			// From issue of Issue.v
	wire [31:0]	rf__rdata_0_1a;		// From regfile of RegFile.v
	wire [31:0]	rf__rdata_1_1a;		// From regfile of RegFile.v
	wire [31:0]	rf__rdata_2_1a;		// From regfile of RegFile.v
	wire [31:0]	rf__rdata_3_4a;		// From regfile of RegFile.v
	wire [3:0]	rf__read_0_1a;		// From decode of Decode.v
	wire [3:0]	rf__read_1_1a;		// From decode of Decode.v
	wire [3:0]	rf__read_2_1a;		// From decode of Decode.v
	wire [31:0]	spsr_2a;		// From decode of Decode.v
	wire		stall_0a;		// From issue of Issue.v
	// End of automatics

	wire execute_out_backflush;
	wire writeback_out_backflush;

	BusArbiter busarbiter(.bus_req(bus_req), .bus_ack(bus_ack));

	/* XXX reset? */
	/* ICache AUTO_TEMPLATE (
		.clk(clk),
		.bus_req(bus_req_icache),
		.bus_ack(bus_ack_icache),
		.bus_addr(bus_addr_icache),
		.bus_rdata(bus_rdata),
		.bus_wdata(bus_wdata_icache),
		.bus_rd(bus_rd_icache),
		.bus_wr(bus_wr_icache),
		.bus_ready(bus_ready),
		); */
	ICache icache(/*AUTOINST*/
		      // Outputs
		      .ic__rd_wait_0a	(ic__rd_wait_0a),
		      .ic__rd_data_1a	(ic__rd_data_1a[31:0]),
		      .bus_req		(bus_req_icache),	 // Templated
		      .bus_addr		(bus_addr_icache),	 // Templated
		      .bus_wdata	(bus_wdata_icache),	 // Templated
		      .bus_rd		(bus_rd_icache),	 // Templated
		      .bus_wr		(bus_wr_icache),	 // Templated
		      // Inputs
		      .clk		(clk),			 // Templated
		      .ic__rd_addr_0a	(ic__rd_addr_0a[31:0]),
		      .ic__rd_req_0a	(ic__rd_req_0a),
		      .bus_ack		(bus_ack_icache),	 // Templated
		      .bus_rdata	(bus_rdata),		 // Templated
		      .bus_ready	(bus_ready));		 // Templated
	
	DCache dcache(
		.clk(clk),
		.addr(dcache_addr), .rd_req(dcache_rd_req), .wr_req(dcache_wr_req),
		.rw_wait(dcache_rw_wait), .wr_data(dcache_wr_data), .rd_data(dcache_rd_data),
		.bus_req(bus_req_dcache), .bus_ack(bus_ack_dcache),
		.bus_addr(bus_addr_dcache), .bus_rdata(bus_rdata),
		.bus_wdata(bus_wdata_dcache), .bus_rd(bus_rd_dcache),
		.bus_wr(bus_wr_dcache), .bus_ready(bus_ready));

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
			.rf__rdata_3_4a	(rf__rdata_3_4a[31:0]),
			.spsr		(regfile_spsr),		 // Templated
			// Inputs
			.clk		(clk),
			.Nrst		(Nrst),
			.rf__read_0_1a	(rf__read_0_1a[3:0]),
			.rf__read_1_1a	(rf__read_1_1a[3:0]),
			.rf__read_2_1a	(rf__read_2_1a[3:0]),
			.rf__read_3_4a	(rf__read_3_4a[3:0]),
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
		.bubble_3a(bubble_out_execute),
		.write_reg_3a(execute_out_write_reg),
		.write_num_3a(execute_out_write_num),
		.write_data_3a(execute_out_write_data),
		.jmp_2a(jmp_out_execute),
		.jmppc_2a(jmppc_out_execute),
		.pc_3a(pc_out_execute),
		.insn_3a(insn_out_execute),
		.op0_3a(execute_out_op0),
		.op1_3a(execute_out_op1),
		.op2_3a(execute_out_op2),
		.cpsr_3a(execute_out_cpsr),
		.spsr_3a(execute_out_spsr),
		.cpsrup_3a(execute_out_cpsrup),
		);
	*/	
	Execute execute(
		/*AUTOINST*/
			// Outputs
			.outstall_2a	(stall_cause_execute),	 // Templated
			.bubble_3a	(bubble_out_execute),	 // Templated
			.cpsr_3a	(execute_out_cpsr),	 // Templated
			.spsr_3a	(execute_out_spsr),	 // Templated
			.cpsrup_3a	(execute_out_cpsrup),	 // Templated
			.write_reg_3a	(execute_out_write_reg), // Templated
			.write_num_3a	(execute_out_write_num), // Templated
			.write_data_3a	(execute_out_write_data), // Templated
			.jmppc_2a	(jmppc_out_execute),	 // Templated
			.jmp_2a		(jmp_out_execute),	 // Templated
			.pc_3a		(pc_out_execute),	 // Templated
			.insn_3a	(insn_out_execute),	 // Templated
			.op0_3a		(execute_out_op0),	 // Templated
			.op1_3a		(execute_out_op1),	 // Templated
			.op2_3a		(execute_out_op2),	 // Templated
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
	
	assign cp_insn = insn_out_execute;
	Memory memory(
		.clk(clk), .Nrst(~rst),
		/* stall? */ .flush(writeback_out_backflush),
		.busaddr(dcache_addr), .rd_req(dcache_rd_req), .wr_req(dcache_wr_req),
		.rw_wait(dcache_rw_wait), .wr_data(dcache_wr_data), .rd_data(dcache_rd_data),
		.st_read(rf__read_3_4a), .st_data(rf__rdata_3_4a),
		.inbubble(bubble_out_execute), .pc(pc_out_execute), .insn(insn_out_execute),
		.op0(execute_out_op0), .op1(execute_out_op1), .op2(execute_out_op2),
		.spsr(execute_out_spsr), .cpsr(execute_out_cpsr), .cpsrup(execute_out_cpsrup),
		.write_reg(execute_out_write_reg), .write_num(execute_out_write_num), .write_data(execute_out_write_data),
		.outstall(stall_cause_memory), .outbubble(bubble_out_memory), 
		.outpc(pc_out_memory), .outinsn(insn_out_memory),
		.out_write_reg(memory_out_write_reg), .out_write_num(memory_out_write_num), 
		.out_write_data(memory_out_write_data),
		.cp_req(cp_req), .cp_ack(cp_ack), .cp_busy(cp_busy), .cp_rnw(cp_rnw), .cp_read(cp_read), .cp_write(cp_write),
		.outcpsr(memory_out_cpsr), .outspsr(memory_out_spsr), .outcpsrup(memory_out_cpsrup) /* XXX data_size */);
	
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
		$display("%3d: EXEC:   Stall: %d, Bubble: %d, Instruction: %08x, PC: %08x, Reg: %d, [%08x -> %d], Jmp: %d [%08x]", clockno, stall_cause_execute, bubble_out_execute, insn_out_execute, pc_out_execute, execute_out_write_reg, execute_out_write_data, execute_out_write_num, jmp_out_execute, jmppc_out_execute);
		$display("%3d: MEMORY: Stall: %d, Bubble: %d, Instruction: %08x, PC: %08x, Reg: %d, [%08x -> %d]", clockno, stall_cause_memory, bubble_out_memory, insn_out_memory, pc_out_memory, memory_out_write_reg, memory_out_write_data, memory_out_write_num);
		$display("%3d: WRITEB:                      CPSR %08x, SPSR %08x, Reg: %d [%08x -> %d], Jmp: %d [%08x]", clockno, writeback_out_cpsr, writeback_out_spsr, regfile_write, regfile_write_data, regfile_write_reg, jmp_out_writeback, jmppc_out_writeback);
	end
endmodule
