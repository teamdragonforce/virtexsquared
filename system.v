`define BUS_ICACHE 0

module System(input clk);
	wire [7:0] bus_req;
	wire [7:0] bus_ack;
	wire [31:0] bus_addr;
	wire [31:0] bus_rdata;
	wire [31:0] bus_wdata;
	wire bus_rd, bus_wr;
	wire bus_ready;

	wire bus_req_icache;	
	assign bus_req = {7'b0, bus_req_icache};
	wire bus_ack_icache = bus_ack[`BUS_ICACHE];
	
	wire [31:0] bus_addr_icache;
	wire [31:0] bus_wdata_icache;
	wire bus_rd_icache;
	wire bus_wr_icache;
	
	wire [31:0] bus_rdata_blockram;
	wire bus_ready_blockram;
	
	assign bus_addr = bus_addr_icache;
	assign bus_rdata = bus_rdata_blockram;
	assign bus_wdata = bus_wdata_icache;
	assign bus_rd = bus_rd_icache;
	assign bus_wr = bus_wr_icache;
	assign bus_ready = bus_ready_blockram;

	wire [31:0] icache_rd_addr;
	wire icache_rd_req;
	wire icache_rd_wait;
	wire [31:0] icache_rd_data;
	
	wire stall_cause_issue;
	wire stall_cause_execute;
	
	wire [31:0] decode_out_op0, decode_out_op1, decode_out_op2, decode_out_spsr;
	wire decode_out_carry;
	wire [3:0] regfile_read_0, regfile_read_1, regfile_read_2;
	wire [31:0] regfile_rdata_0, regfile_rdata_1, regfile_rdata_2, regfile_spsr;
	wire execute_out_stall, execute_out_bubble;
	wire execute_out_write_reg;
	wire [3:0] execute_out_write_num;
	wire [31:0] execute_out_write_data;
	wire [31:0] jmppc;
	wire jmp;
	
	wire bubble_out_fetch;
	wire bubble_out_issue;
	wire [31:0] insn_out_fetch;
	wire [31:0] insn_out_issue;
	wire [31:0] pc_out_fetch;
	wire [31:0] pc_out_issue;

	wire execute_outflush = jmp;
	wire issue_flush = execute_outflush;
	wire execute_flush = 1'b0;

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
		.stall(stall_cause_execute), .flush(issue_flush),
		.inbubble(bubble_out_fetch), .insn(insn_out_fetch),
		.inpc(pc_out_fetch), .cpsr(32'b0 /* XXX */),
		.outstall(stall_cause_issue), .outbubble(bubble_out_issue),
		.outpc(pc_out_issue), .outinsn(insn_out_issue));
	
	RegFile regfile(
		.clk(clk),
		.read_0(regfile_read_0), .read_1(regfile_read_1), .read_2(regfile_read_2),
		.rdata_0(regfile_rdata_0), .rdata_1(regfile_rdata_1), .rdata_2(regfile_rdata_2),
		.spsr(regfile_spsr), .write(4'b0), .write_req(1'b0), .write_data(10 /* XXX */));
	
	Decode decode(
		.clk(clk),
		.insn(insn_out_fetch), .inpc(pc_out_fetch), .incpsr(32'b0 /* XXX */), .inspsr(regfile_spsr),
		.op0(decode_out_op0), .op1(decode_out_op1), .op2(decode_out_op2),
		.carry(decode_out_carry), .outspsr(decode_out_spsr),
		.read_0(regfile_read_0), .read_1(regfile_read_1), .read_2(regfile_read_2), 
		.rdata_0(regfile_rdata_0), .rdata_1(regfile_rdata_1), .rdata_2(regfile_rdata_2));
	
	Execute execute(
		.clk(clk), .Nrst(1'b0),
		.stall(1'b0 /* XXX */), .flush(execute_flush),
		.inbubble(bubble_out_issue), .pc(pc_out_issue), .insn(insn_out_issue),
		.cpsr(32'b0 /* XXX */), .spsr(decode_out_spsr), .op0(decode_out_op0), .op1(decode_out_op1),
		.op2(decode_out_op2), .carry(decode_out_carry),
		.outstall(stall_cause_execute), .outbubble(execute_out_bubble),
		.write_reg(execute_out_write_reg), .write_num(execute_out_write_num),
		.write_data(execute_out_write_data),
		.jmppc(jmppc),
		.jmp(jmp));

	reg [31:0] clockno = 0;
	always @(posedge clk)
	begin
		clockno <= clockno + 1;
		$display("------------------------------------------------------------------------------");
		$display("%3d: FETCH:            Bubble: %d, Instruction: %08x, PC: %08x", clockno, bubble_out_fetch, insn_out_fetch, pc_out_fetch);
		$display("%3d: ISSUE:  Stall: %d, Bubble: %d, Instruction: %08x, PC: %08x", clockno, stall_cause_issue, bubble_out_issue, insn_out_issue, pc_out_issue);
		$display("%3d: DECODE:                      op1 %08x, op2 %08x, op3 %08x, carry %d", clockno, decode_out_op0, decode_out_op1, decode_out_op2, decode_out_carry);
		$display("%3d: EXEC:   Stall: %d, Bubble: %d, Reg: %d, [%08x -> %d], Jmp: %d [%08x]", clockno, stall_cause_execute, execute_out_bubble, execute_out_write_reg, execute_out_write_data, execute_out_write_num, jmp, jmppc);
	end
endmodule
