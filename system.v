`define BUS_ICACHE 0
`define BUS_DCACHE 1

module System(input clk);
	wire [7:0] bus_req;
	wire [7:0] bus_ack;
	wire [31:0] bus_addr;
	wire [31:0] bus_rdata;
	wire [31:0] bus_wdata;
	wire bus_rd, bus_wr;
	wire bus_ready;

	wire bus_req_icache;
	wire bus_req_dcache;
	assign bus_req = {6'b0, bus_req_dcache, bus_req_icache};
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
	
	wire jmp_out_execute, jmp_out_writeback;
	wire [31:0] jmppc_out_execute, jmppc_out_writeback;
	wire jmp = jmp_out_execute | jmp_out_writeback;
	wire [31:0] jmppc = jmppc_out_execute | jmppc_out_writeback;
	
	wire memory_out_write_reg;
	wire [3:0] memory_out_write_num;
	wire [31:0] memory_out_write_data;
	wire [31:0] memory_out_cpsr, memory_out_spsr;
	
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

	wire execute_out_backflush;
	wire writeback_out_backflush;

	BusArbiter busarbiter(.bus_req(bus_req), .bus_ack(bus_ack));

	ICache icache(
		.clk(clk),
		/* XXX reset? */
		.rd_addr(icache_rd_addr), .rd_req(icache_rd_req),
		.rd_wait(icache_rd_wait), .rd_data(icache_rd_data),
		.bus_req(bus_req_icache), .bus_ack(bus_ack_icache),
		.bus_addr(bus_addr_icache), .bus_rdata(bus_rdata),
		.bus_wdata(bus_wdata_icache), .bus_rd(bus_rd_icache),
		.bus_wr(bus_wr_icache), .bus_ready(bus_ready));
	
	DCache dcache(
		.clk(clk),
		.addr(dcache_addr), .rd_req(dcache_rd_req), .wr_req(dcache_wr_req),
		.rw_wait(dcache_rw_wait), .wr_data(dcache_wr_data), .rd_data(dcache_rd_data),
		.bus_req(bus_req_dcache), .bus_ack(bus_ack_dcache),
		.bus_addr(bus_addr_dcache), .bus_rdata(bus_rdata),
		.bus_wdata(bus_wdata_dcache), .bus_rd(bus_rd_dcache),
		.bus_wr(bus_wr_dcache), .bus_ready(bus_ready));

	BlockRAM blockram(
		.clk(clk),
		.bus_addr(bus_addr), .bus_rdata(bus_rdata_blockram),
		.bus_wdata(bus_wdata), .bus_rd(bus_rd), .bus_wr(bus_wr),
		.bus_ready(bus_ready_blockram));

	Fetch fetch(
		.clk(clk),
		.Nrst(1'b1 /* XXX */),
		.rd_addr(icache_rd_addr), .rd_req(icache_rd_req),
		.rd_wait(icache_rd_wait), .rd_data(icache_rd_data),
		.stall(stall_cause_issue), .jmp(jmp), .jmppc(jmppc),
		.bubble(bubble_out_fetch), .insn(insn_out_fetch),
		.pc(pc_out_fetch));
	
	Issue issue(
		.clk(clk),
		.Nrst(1'b1 /* XXX */),
		.stall(stall_cause_execute), .flush(execute_out_backflush | writeback_out_backflush),
		.inbubble(bubble_out_fetch), .insn(insn_out_fetch),
		.inpc(pc_out_fetch), .cpsr(writeback_out_cpsr),
		.outstall(stall_cause_issue), .outbubble(bubble_out_issue),
		.outpc(pc_out_issue), .outinsn(insn_out_issue));
	
	RegFile regfile(
		.clk(clk),
		.read_0(regfile_read_0), .read_1(regfile_read_1), .read_2(regfile_read_2), .read_3(regfile_read_3),
		.rdata_0(regfile_rdata_0), .rdata_1(regfile_rdata_1), .rdata_2(regfile_rdata_2), .rdata_3(regfile_rdata_3),
		.spsr(regfile_spsr),
		.write(regfile_write), .write_reg(regfile_write_reg), .write_data(regfile_write_data));
	
	Decode decode(
		.clk(clk),
		.stall(stall_cause_execute),
		.insn(insn_out_fetch), .inpc(pc_out_fetch), .incpsr(writeback_out_cpsr), .inspsr(writeback_out_spsr),
		.op0(decode_out_op0), .op1(decode_out_op1), .op2(decode_out_op2),
		.carry(decode_out_carry), .outcpsr(decode_out_cpsr), .outspsr(decode_out_spsr),
		.read_0(regfile_read_0), .read_1(regfile_read_1), .read_2(regfile_read_2), 
		.rdata_0(regfile_rdata_0), .rdata_1(regfile_rdata_1), .rdata_2(regfile_rdata_2));
	
	Execute execute(
		.clk(clk), .Nrst(1'b0),
		.stall(stall_cause_memory), .flush(writeback_out_backflush),
		.inbubble(bubble_out_issue), .pc(pc_out_issue), .insn(insn_out_issue),
		.cpsr(decode_out_cpsr), .spsr(decode_out_spsr), .op0(decode_out_op0), .op1(decode_out_op1),
		.op2(decode_out_op2), .carry(decode_out_carry),
		.outstall(stall_cause_execute), .outbubble(bubble_out_execute),
		.write_reg(execute_out_write_reg), .write_num(execute_out_write_num),
		.write_data(execute_out_write_data),
		.jmp(jmp_out_execute), .jmppc(jmppc_out_execute),
		.outpc(pc_out_execute), .outinsn(insn_out_execute),
		.outop0(execute_out_op0), .outop1(execute_out_op1), .outop2(execute_out_op2),
		.outcpsr(execute_out_cpsr), .outspsr(execute_out_spsr));
	assign execute_out_backflush = jmp;
	
	assign cp_insn = insn_out_execute;
	Memory memory(
		.clk(clk), .Nrst(1'b0),
		/* stall? */ .flush(writeback_out_backflush),
		.busaddr(dcache_addr), .rd_req(dcache_rd_req), .wr_req(dcache_wr_req),
		.rw_wait(dcache_rw_wait), .wr_data(dcache_wr_data), .rd_data(dcache_rd_data),
		.st_read(regfile_read_3), .st_data(regfile_rdata_3),
		.inbubble(bubble_out_execute), .pc(pc_out_execute), .insn(insn_out_execute),
		.op0(execute_out_op0), .op1(execute_out_op1), .op2(execute_out_op2),
		.spsr(execute_out_spsr), .cpsr(execute_out_cpsr),
		.write_reg(execute_out_write_reg), .write_num(execute_out_write_num), .write_data(execute_out_write_data),
		.outstall(stall_cause_memory), .outbubble(bubble_out_memory), 
		.outpc(pc_out_memory), .outinsn(insn_out_memory),
		.out_write_reg(memory_out_write_reg), .out_write_num(memory_out_write_num), 
		.out_write_data(memory_out_write_data),
		.cp_req(cp_req), .cp_ack(cp_ack), .cp_busy(cp_busy), .cp_rnw(cp_rnw), .cp_read(cp_read), .cp_write(cp_write),
		.outcpsr(memory_out_cpsr), .outspsr(memory_out_spsr) /* XXX data_size */);
	
	Terminal terminal(	
		.clk(clk),
		.cp_req(cp_req), .cp_insn(cp_insn), .cp_ack(cp_ack_terminal), .cp_busy(cp_busy_terminal), .cp_rnw(cp_rnw),
		.cp_read(cp_read_terminal), .cp_write(cp_write));
	
	Writeback writeback(
		.clk(clk),
		.inbubble(bubble_out_memory),
		.write_reg(memory_out_write_reg), .write_num(memory_out_write_num), .write_data(memory_out_write_data),
		.cpsr(memory_out_cpsr), .spsr(memory_out_spsr),
		.regfile_write(regfile_write), .regfile_write_reg(regfile_write_reg), .regfile_write_data(regfile_write_data),
		.outcpsr(writeback_out_cpsr), .outspsr(writeback_out_spsr), 
		.jmp(jmp_out_writeback), .jmppc(jmppc_out_writeback));
	assign writeback_out_backflush = jmp_out_writeback;

	reg [31:0] clockno = 0;
	always @(posedge clk)
	begin
		clockno <= clockno + 1;
		$display("------------------------------------------------------------------------------");
		$display("%3d: FETCH:            Bubble: %d, Instruction: %08x, PC: %08x", clockno, bubble_out_fetch, insn_out_fetch, pc_out_fetch);
		$display("%3d: ISSUE:  Stall: %d, Bubble: %d, Instruction: %08x, PC: %08x", clockno, stall_cause_issue, bubble_out_issue, insn_out_issue, pc_out_issue);
		$display("%3d: DECODE:                      op1 %08x, op2 %08x, op3 %08x, carry %d", clockno, decode_out_op0, decode_out_op1, decode_out_op2, decode_out_carry);
		$display("%3d: EXEC:   Stall: %d, Bubble: %d, Instruction: %08x, PC: %08x, Reg: %d, [%08x -> %d], Jmp: %d [%08x]", clockno, stall_cause_execute, bubble_out_execute, insn_out_execute, pc_out_execute, execute_out_write_reg, execute_out_write_data, execute_out_write_num, jmp_out_execute, jmppc_out_execute);
		$display("%3d: MEMORY: Stall: %d, Bubble: %d, Instruction: %08x, PC: %08x, Reg: %d, [%08x -> %d]", clockno, stall_cause_memory, bubble_out_memory, insn_out_memory, pc_out_memory, memory_out_write_reg, memory_out_write_data, memory_out_write_num);
		$display("%3d: WRITEB:                      CPSR %08x, SPSR %08x, Reg: %d [%08x -> %d], Jmp: %d [%08x]", clockno, writeback_out_cpsr, writeback_out_spsr, regfile_write, regfile_write_data, regfile_write_reg, jmp_out_writeback, jmppc_out_writeback);
	end
endmodule
