`include "ARM_Constants.v"

module Issue(
	input clk,
	input rst_b,	/* XXX not used yet */
	
	input stall_1a,	/* pipeline control */
	input flush_1a,
	
	input bubble_1a,	/* stage inputs */
	input [31:0] insn_1a,
	input [31:0] pc_1a,
	input [31:0] cpsr_1a,
	
	output wire stall_0a,	/* stage outputs */
	output reg bubble_2a = 1,
	output reg [31:0] pc_2a = 0,
	output reg [31:0] insn_2a = 0
	/* XXX other? */
	);
	
`ifdef COPY_PASTA_FODDER
	/* from page 2 of ARM7TDMIvE2.pdf */
	casex (insn_1a)
	`DECODE_ALU_MULT:	/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
//	`DECODE_ALU_MUL_LONG:	/* Multiply long */
	`DECODE_ALU_MRS:	/* MRS (Transfer PSR to register) */
	`DECODE_ALU_MSR:	/* MSR (Transfer register to PSR) */
	`DECODE_ALU_MSR_FLAGS:	/* MSR (Transfer register or immediate to PSR, flag bits only) */
	`DECODE_ALU_SWP:	/* Atomic swap */
	`DECODE_ALU_BX:		/* Branch */
	`DECODE_ALU_HDATA_REG:	/* Halfword transfer - register offset */
	`DECODE_ALU_HDATA_IMM:	/* Halfword transfer - immediate offset */
	`DECODE_ALU:		/* ALU */
	`DECODE_LDRSTR_UNDEFINED:	/* Undefined. I hate ARM */
	`DECODE_LDRSTR:		/* Single data transfer */
	`DECODE_LDMSTM:		/* Block data transfer */
	`DECODE_BRANCH:		/* Branch */
	`DECODE_LDCSTC:		/* Coprocessor data transfer */
	`DECODE_CDP:		/* Coprocessor data op */
	`DECODE_MRCMCR:		/* Coprocessor register transfer */
	`DECODE_SWI:		/* SWI */
	default:		/* X everything else out */
	endcase
`endif

	/* Flag setting */
	reg use_cpsr;
	reg [15:0] use_regs;
	reg def_cpsr;
	reg [15:0] def_regs;
	
	function [15:0] idxbit;
		input [3:0] r;
		if (r == 15)
			idxbit = 0;
		else
			idxbit = (16'b1) << r;
	endfunction
	
	wire [3:0] rn = insn_1a[19:16];
	wire [3:0] rd = insn_1a[15:12];
	wire [3:0] rs = insn_1a[11:8];
	wire [3:0] rm = insn_1a[3:0];
	wire [3:0] cond = insn_1a[31:28];
	
	wire [3:0] rd_mul = insn_1a[19:16];
	wire [3:0] rn_mul = insn_1a[15:12];
	wire [3:0] rs_mul = insn_1a[11:8];
	
	wire [3:0] alu_opc = insn_1a[24:21];
	
	function alu_is_logical;
		input [3:0] op;
		
		case (op)
		`ALU_AND,`ALU_EOR,`ALU_TST,`ALU_TEQ,`ALU_ORR,`ALU_MOV,`ALU_BIC,`ALU_MVN: alu_is_logical = 1;
		default: alu_is_logical = 0;
		endcase
	endfunction
	
	function alu_flags_only;
		input [3:0] op;
		
		case (op)
		`ALU_TST,`ALU_TEQ,`ALU_CMP,`ALU_CMN: alu_flags_only = 1;
		default: alu_flags_only = 0;
		endcase
	endfunction
	
	function shift_requires_carry;
		input [7:0] shift;
		
		case(shift[1:0])
		`SHIFT_LSL: shift_requires_carry = (shift[7:2] == 0);
		`SHIFT_LSR: shift_requires_carry = 0;
		`SHIFT_ASR: shift_requires_carry = 0;
		`SHIFT_ROR: shift_requires_carry = (shift[7:2] == 0);
		endcase
	endfunction
	
	always @(*)
		casez (insn_1a)
		`DECODE_ALU_MULT:	/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = (insn_1a[21] /* accum */ ? idxbit(rn_mul) : 0) | idxbit(rs_mul) | idxbit(rm);
			def_cpsr = insn_1a[20] /* setcc */;
			def_regs = idxbit(rd_mul);
		end
//		`DECODE_ALU_MUL_LONG:	/* Multiply long */
		`DECODE_ALU_MRS:	/* MRS (Transfer PSR to register) */
		begin
			use_cpsr = `COND_MATTERS(cond) || (insn_1a[22] == 0) /* Source = CPSR */;
			use_regs = 0;
			def_cpsr = 0;
			def_regs = idxbit(rd);
		end
		`DECODE_ALU_MSR:	/* MSR (Transfer register to PSR) */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = idxbit(rm);
			def_cpsr = 1;
			def_regs = 0;
		end
		`DECODE_ALU_MSR_FLAGS:	/* MSR (Transfer register or immediate to PSR, flag bits only) */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = insn_1a[25] ? 0 : idxbit(rm);
			def_cpsr = 1;
			def_regs = 0;
		end
		`DECODE_ALU_SWP:	/* Atomic swap */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = idxbit(rn) | idxbit(rm);
			def_cpsr = 0;
			def_regs = idxbit(rd);
		end
		`DECODE_ALU_BX:	/* Branch */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = idxbit(rm);
			def_cpsr = 0;	// don't care, we'll never get there
			def_regs = 0;
		end
		`DECODE_ALU_HDATA_REG:	/* Halfword transfer - register offset */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = idxbit(rn) | idxbit(rm) | (insn_1a[20] /* L */ ? 0 : idxbit(rd));
			def_cpsr = 0;
			def_regs = insn_1a[20] /* L */ ? idxbit(rd) : 0;
		end
		`DECODE_ALU_HDATA_IMM:	/* Halfword transfer - immediate offset */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = idxbit(rn) | (insn_1a[20] /* L */ ? 0 : idxbit(rd));
			def_cpsr = 0;
			def_regs = insn_1a[20] /* L */ ? idxbit(rd) : 0;
		end
		`DECODE_ALU:	/* ALU */
		begin
			use_cpsr = `COND_MATTERS(cond) | (!insn_1a[25] /* I */ && shift_requires_carry(insn_1a[11:4]));
			use_regs =
				(insn_1a[25] /* I */ ? 0 :
					(insn_1a[4] /* shift by reg */ ?
						(idxbit(rs) | idxbit(rm)) :
						(idxbit(rm)))) |
				(((alu_opc != `ALU_MOV) && (alu_opc != `ALU_MVN)) ? idxbit(rn) : 0);
			def_cpsr = insn_1a[20] /* S */;
			def_regs = alu_flags_only(alu_opc) ? 0 : idxbit(rd);
		end
		`DECODE_LDRSTR_UNDEFINED:	/* Undefined. I hate ARM */
		begin	
			use_cpsr = 0;
			use_regs = 0;
			def_cpsr = 0;
			def_regs = 0;
		end
		`DECODE_LDRSTR:
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = idxbit(rn) | (insn_1a[25] /* I */ ? idxbit(rm) : 0) | (insn_1a[20] /* L */ ? 0 : idxbit(rd));
			def_cpsr = 0;
			def_regs = insn_1a[20] /* L */ ? idxbit(rd) : 0;
		end
		`DECODE_LDMSTM:		/* Block data transfer */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = idxbit(rn) | (insn_1a[20] /* L */ ? 0 : insn_1a[15:0]);
			def_cpsr = insn_1a[22];	/* This is a superset of all cases, anyway. */
			def_regs = (insn_1a[21] /* W */ ? idxbit(rn) : 0) | (insn_1a[20] /* L */ ? insn_1a[15:0] : 0);
		end
		`DECODE_BRANCH:	/* Branch */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = 0;
			def_cpsr = 0;
			def_regs = insn_1a[24] /* L */ ? (16'b1 << 14) : 0;
		end
		`DECODE_LDCSTC:	/* Coprocessor data transfer */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = idxbit(rn);
			def_cpsr = 0;
			def_regs = insn_1a[21] /* W */ ? idxbit(rn) : 0;
		end
		`DECODE_CDP:	/* Coprocessor data op */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = 0;
			def_cpsr = 0;
			def_regs = 0;
		end
		`DECODE_MRCMCR:		/* Coprocessor register transfer */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = insn_1a[20] /* L */ ? 0 : idxbit(rd);
			def_cpsr = 0;
			def_regs = insn_1a[20] /* L */ ? idxbit(rd) : 0;
		end
		`DECODE_SWI:	/* SWI */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = 0;
			def_cpsr = 0;
			def_regs = 0;
		end
		default:				/* X everything else out */
		begin
			use_cpsr = 1'bx;
			use_regs = 16'bxxxxxxxxxxxxxxxx;
			def_cpsr = 1'bx;
			def_regs = 16'bxxxxxxxxxxxxxxxx;
		end
		endcase
	
	/* Condition checking logic */
	reg condition_met_1a;
	always @(*)
		casez(insn_1a[31:28])
		`COND_EQ:	condition_met_1a = cpsr_1a[`CPSR_Z];
		`COND_NE:	condition_met_1a = !cpsr_1a[`CPSR_Z];
		`COND_CS:	condition_met_1a = cpsr_1a[`CPSR_C];
		`COND_CC:	condition_met_1a = !cpsr_1a[`CPSR_C];
		`COND_MI:	condition_met_1a = cpsr_1a[`CPSR_N];
		`COND_PL:	condition_met_1a = !cpsr_1a[`CPSR_N];
		`COND_VS:	condition_met_1a = cpsr_1a[`CPSR_V];
		`COND_VC:	condition_met_1a = !cpsr_1a[`CPSR_V];
		`COND_HI:	condition_met_1a = cpsr_1a[`CPSR_C] && !cpsr_1a[`CPSR_Z];
		`COND_LS:	condition_met_1a = !cpsr_1a[`CPSR_C] || cpsr_1a[`CPSR_Z];
		`COND_GE:	condition_met_1a = cpsr_1a[`CPSR_N] == cpsr_1a[`CPSR_V];
		`COND_LT:	condition_met_1a = cpsr_1a[`CPSR_N] != cpsr_1a[`CPSR_V];
		`COND_GT:	condition_met_1a = !cpsr_1a[`CPSR_Z] && (cpsr_1a[`CPSR_N] == cpsr_1a[`CPSR_V]);
		`COND_LE:	condition_met_1a = cpsr_1a[`CPSR_Z] || (cpsr_1a[`CPSR_N] != cpsr_1a[`CPSR_V]);
		`COND_AL:	condition_met_1a = 1;
		`COND_NV:	condition_met_1a = 0;
		default:	condition_met_1a = 1'bx;
		endcase
	
	/* Issue logic */
	/* Once it's hit writeback, it's hit the regfile via forwarding so you're done. */
	reg        cpsr_inflight_2a = 0, cpsr_inflight_3a = 0;
	reg [15:0] regs_inflight_2a = 0, regs_inflight_3a = 0;
	
	wire waiting_cpsr_1a = use_cpsr & (cpsr_inflight_2a | cpsr_inflight_3a);
	wire waiting_regs_1a = |(use_regs & (regs_inflight_2a | regs_inflight_3a));
	wire waiting_1a = waiting_cpsr_1a | waiting_regs_1a;
	assign stall_0a = (waiting_1a && !bubble_1a && !flush_1a) || stall_1a;

	reg delayedflush_1a = 0;
	always @(posedge clk or negedge rst_b)
		if (!rst_b)
			delayedflush_1a <= 0;
		else if (flush_1a && stall_0a /* halp! I can't do it now, maybe later? */)
			delayedflush_1a <= 1;
		else if (!stall_0a /* anything has been handled this time around */)
			delayedflush_1a <= 0;

	/* Actually do the issue. */
	always @(posedge clk or negedge rst_b)
	begin
		if (waiting_1a)
			$display("ISSUE: Stalling instruction %08x because %d/%d", insn_1a, waiting_cpsr_1a, waiting_regs_1a);

		if (!rst_b) begin
			bubble_2a <= 1;
			/*AUTORESET*/
			// Beginning of autoreset for uninitialized flops
			cpsr_inflight_2a <= 1'h0;
			cpsr_inflight_3a <= 1'h0;
			insn_2a <= 32'h0;
			pc_2a <= 32'h0;
			regs_inflight_2a <= 16'h0;
			regs_inflight_3a <= 16'h0;
			// End of automatics
		end else if (!stall_1a)
		begin
			cpsr_inflight_3a <= cpsr_inflight_2a;	/* I'm not sure how well selects work with arrays, and that seems like a dumb thing to get anusulated by. */
			cpsr_inflight_2a <= (waiting_1a || bubble_1a || !condition_met_1a) ? 0 : def_cpsr;
			regs_inflight_3a <= regs_inflight_2a;
			regs_inflight_2a <= (waiting_1a || bubble_1a || !condition_met_1a) ? 0 : def_regs;
			
			bubble_2a <= bubble_1a | waiting_1a | !condition_met_1a | flush_1a | delayedflush_1a;
			pc_2a <= pc_1a;
			insn_2a <= insn_1a;
		end
	end
endmodule
