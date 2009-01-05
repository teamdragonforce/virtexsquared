`include "ARM_Constants.v"

module Issue(
	input clk,
	input Nrst,	/* XXX not used yet */
	
	input stall,	/* pipeline control */
	input flush,	/* XXX not used yet */
	
	input inbubble,	/* stage inputs */
	input [31:0] insn,
	input [31:0] inpc,
	input [31:0] cpsr,
	
	output reg outstall = 0,	/* stage outputs */
	output reg outbubble = 1,
	output reg [31:0] outpc = 0,
	output reg [31:0] outinsn = 0
	/* XXX other? */
	);
	
`ifdef COPY_PASTA_FODDER
	/* from page 2 of ARM7TDMIvE2.pdf */
	casex (insn)
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
	
	wire [3:0] rn = insn[19:16];
	wire [3:0] rd = insn[15:12];
	wire [3:0] rs = insn[11:8];
	wire [3:0] rm = insn[3:0];
	wire [3:0] cond = insn[31:28];
	
	wire [3:0] rd_mul = insn[19:16];
	wire [3:0] rn_mul = insn[15:12];
	wire [3:0] rs_mul = insn[11:8];
	
	wire [3:0] alu_opc = insn[24:21];
	
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
		casez (insn)
		`DECODE_ALU_MULT:	/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = (insn[21] /* accum */ ? idxbit(rn_mul) : 0) | idxbit(rs_mul) | idxbit(rm);
			def_cpsr = insn[20] /* setcc */;
			def_regs = idxbit(rd_mul);
		end
//		`DECODE_ALU_MUL_LONG:	/* Multiply long */
		`DECODE_ALU_MRS:	/* MRS (Transfer PSR to register) */
		begin
			use_cpsr = `COND_MATTERS(cond) || (insn[22] == 0) /* Source = CPSR */;
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
			use_regs = insn[25] ? 0 : idxbit(rm);
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
			use_regs = idxbit(rn) | idxbit(rm) | (insn[20] /* L */ ? 0 : idxbit(rd));
			def_cpsr = 0;
			def_regs = insn[20] /* L */ ? idxbit(rd) : 0;
		end
		`DECODE_ALU_HDATA_IMM:	/* Halfword transfer - immediate offset */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = idxbit(rn) | (insn[20] /* L */ ? 0 : idxbit(rd));
			def_cpsr = 0;
			def_regs = insn[20] /* L */ ? idxbit(rd) : 0;
		end
		`DECODE_ALU:	/* ALU */
		begin
			use_cpsr = `COND_MATTERS(cond) | (!insn[25] /* I */ && shift_requires_carry(insn[11:4]));
			use_regs =
				(insn[25] /* I */ ? 0 :
					(insn[4] /* shift by reg */ ?
						(idxbit(rs) | idxbit(rm)) :
						(idxbit(rm)))) |
				(((alu_opc != `ALU_MOV) && (alu_opc != `ALU_MVN)) ? idxbit(rn) : 0);
			def_cpsr = insn[20] /* S */;
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
			use_regs = idxbit(rn) | (insn[20] /* L */ ? 0 : idxbit(rd));
			def_cpsr = 0;
			def_regs = insn[20] /* L */ ? idxbit(rd) : 0;
		end
		`DECODE_LDMSTM:		/* Block data transfer */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = idxbit(rn) | (insn[20] /* L */ ? 0 : insn[15:0]);
			def_cpsr = insn[22];	/* This is a superset of all cases, anyway. */
			def_regs = (insn[21] /* W */ ? idxbit(rn) : 0) | (insn[20] /* L */ ? insn[15:0] : 0);
		end
		`DECODE_BRANCH:	/* Branch */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = 0;
			def_cpsr = 0;
			def_regs = 0;
		end
		`DECODE_LDCSTC:	/* Coprocessor data transfer */
		begin
			use_cpsr = `COND_MATTERS(cond);
			use_regs = idxbit(rn);
			def_cpsr = 0;
			def_regs = insn[21] /* W */ ? idxbit(rn) : 0;
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
			use_regs = insn[20] /* L */ ? 0 : idxbit(rd);
			def_cpsr = 0;
			def_regs = insn[20] /* L */ ? idxbit(rd) : 0;
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
	reg condition_met;
	always @(*)
		casez(insn[31:28])
		`COND_EQ:	condition_met = cpsr[`CPSR_Z];
		`COND_NE:	condition_met = !cpsr[`CPSR_Z];
		`COND_CS:	condition_met = cpsr[`CPSR_C];
		`COND_CC:	condition_met = !cpsr[`CPSR_C];
		`COND_MI:	condition_met = cpsr[`CPSR_N];
		`COND_PL:	condition_met = !cpsr[`CPSR_N];
		`COND_VS:	condition_met = cpsr[`CPSR_V];
		`COND_VC:	condition_met = !cpsr[`CPSR_V];
		`COND_HI:	condition_met = cpsr[`CPSR_C] && !cpsr[`CPSR_Z];
		`COND_LS:	condition_met = !cpsr[`CPSR_C] || cpsr[`CPSR_Z];
		`COND_GE:	condition_met = cpsr[`CPSR_N] == cpsr[`CPSR_V];
		`COND_LT:	condition_met = cpsr[`CPSR_N] != cpsr[`CPSR_V];
		`COND_GT:	condition_met = !cpsr[`CPSR_Z] && (cpsr[`CPSR_N] == cpsr[`CPSR_V]);
		`COND_LE:	condition_met = cpsr[`CPSR_Z] || (cpsr[`CPSR_N] != cpsr[`CPSR_V]);
		`COND_AL:	condition_met = 1;
		`COND_NV:	condition_met = 0;
		default:	condition_met = 1'bx;
		endcase
	
	/* Issue logic */
`define STAGE_EXECUTE   0
`define STAGE_MEMORY    1
/* Once it's hit writeback, it's essentially hit the regfile so you're done. */
	reg cpsr_inflight [1:0];
	reg [15:0] regs_inflight [1:0];
	
	reg waiting_cpsr;
	reg waiting_regs;
	wire waiting = waiting_cpsr | waiting_regs;
	
	initial
	begin
		cpsr_inflight[0] = 0;
		cpsr_inflight[1] = 0;
		regs_inflight[0] = 0;
		regs_inflight[1] = 0;
	end
		
	always @(*)
	begin
		waiting_cpsr = use_cpsr & (cpsr_inflight[0] | cpsr_inflight[1]);
		waiting_regs = |(use_regs & (regs_inflight[0] | regs_inflight[1]));
		
		outstall = (waiting && !inbubble) || stall;	/* Happens in an always @*, because it is an exception. */
	end
	
	/* Actually do the issue. */
	always @(posedge clk)
	begin
		if (waiting)
			$display("ISSUE: Stalling instruction %08x because %d/%d", insn, waiting_cpsr, waiting_regs);

		if(flush)
		begin
			cpsr_inflight[0] = 1'b0;
			cpsr_inflight[1] = 1'b0;
			regs_inflight[0] = 16'b0;
			regs_inflight[1] = 16'b0;
			outbubble <= 1'b1;
		end
		else if (!stall)
		begin
			cpsr_inflight[0] <= cpsr_inflight[1];	/* I'm not sure how well selects work with arrays, and that seems like a dumb thing to get anusulated by. */
			cpsr_inflight[1] <= (waiting || inbubble || !condition_met) ? 0 : def_cpsr;
			regs_inflight[0] <= regs_inflight[1];
			regs_inflight[1] <= (waiting || inbubble || !condition_met) ? 0 : def_regs;
			
			outbubble <= inbubble | waiting | !condition_met;
			outpc <= inpc;
			outinsn <= insn;
		end
	end
endmodule
