`include "ARM_Constants.v"

module Decode(
	input clk,
	input stall,
	input [31:0] insn_1a,
	input [31:0] pc_1a,
	input [31:0] cpsr_1a,
	input [31:0] spsr_1a,
	output reg [31:0] op0_2a,
	output reg [31:0] op1_2a,
	output reg [31:0] op2_2a,
	output reg carry_2a,
	output reg [31:0] cpsr_2a,
	output reg [31:0] spsr_2a,

	output reg [3:0] rf__read_0_1a,
	output reg [3:0] rf__read_1_1a,
	output reg [3:0] rf__read_2_1a,
	input [31:0] rf__rdata_0_1a,
	input [31:0] rf__rdata_1_1a,
	input [31:0] rf__rdata_2_1a
	);

	wire [31:0] regs0, regs1, regs2;
	reg [31:0] rpc;
	reg [31:0] op0_1a, op1_1a, op2_1a;
	reg carry_1a;

	/* shifter stuff */
	wire [31:0] shift_oper;
	wire [31:0] shift_res;
	wire shift_cflag_out;
	wire [31:0] rotate_res;

	assign regs0 = (rf__read_0_1a == 4'b1111) ? rpc : rf__rdata_0_1a;
	assign regs1 = (rf__read_1_1a == 4'b1111) ? rpc : rf__rdata_1_1a;
	assign regs2 = rf__rdata_2_1a; /* use regs2 for things that cannot be r15 */

	IREALLYHATEARMSHIFT shift(.insn(insn_1a),
	                          .operand(regs1),
	                          .reg_amt(regs2),
	                          .cflag_in(cpsr_1a[`CPSR_C]),
	                          .res(shift_res),
	                          .cflag_out(shift_cflag_out));

	SuckLessRotator whirr(.oper({24'b0, insn_1a[7:0]}),
	                      .amt(insn_1a[11:8]),
	                      .res(rotate_res));

	always @(*)
		casez (insn_1a)
		`DECODE_ALU_MULT,		/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
//		`DECODE_ALU_MUL_LONG,		/* Multiply long */
		`DECODE_ALU_MRS,		/* MRS (Transfer PSR to register) */
		`DECODE_ALU_MSR,		/* MSR (Transfer register to PSR) */
		`DECODE_ALU_MSR_FLAGS,		/* MSR (Transfer register or immediate to PSR, flag bits only) */
		`DECODE_ALU_SWP,		/* Atomic swap */
		`DECODE_ALU_BX,			/* Branch and exchange */
		`DECODE_ALU_HDATA_REG,		/* Halfword transfer - register offset */
		`DECODE_ALU_HDATA_IMM,		/* Halfword transfer - register offset */
		`DECODE_LDRSTR_UNDEFINED,	/* Undefined. I hate ARM */
		`DECODE_LDRSTR,			/* Single data transfer */
		`DECODE_LDMSTM,			/* Block data transfer */
		`DECODE_BRANCH,			/* Branch */
		`DECODE_LDCSTC,			/* Coprocessor data transfer */
		`DECODE_CDP,			/* Coprocessor data op */
		`DECODE_SWI:			/* SWI */
			rpc = pc_1a + 8;
		`DECODE_MRCMCR:			/* Coprocessor register transfer */
			rpc = pc_1a + 12;
		`DECODE_ALU:			/* ALU */
			rpc = pc_1a + (insn_1a[25] ? 8 : (insn_1a[4] ? 12 : 8));
		default:			/* X everything else out */
			rpc = 32'hxxxxxxxx;
		endcase
	
	always @(*) begin
		rf__read_0_1a = 4'hx;
		rf__read_1_1a = 4'hx;
		rf__read_2_1a = 4'hx;
		
		casez (insn_1a)
		`DECODE_ALU_MULT:	/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
		begin
			rf__read_0_1a = insn_1a[15:12]; /* Rn */
			rf__read_1_1a = insn_1a[3:0];   /* Rm */
			rf__read_2_1a = insn_1a[11:8];  /* Rs */
		end
		`DECODE_ALU_MRS:	/* MRS (Transfer PSR to register) */
		begin end
		`DECODE_ALU_MSR:	/* MSR (Transfer register to PSR) */
			rf__read_0_1a = insn_1a[3:0];	/* Rm */
		`DECODE_ALU_MSR_FLAGS:	/* MSR (Transfer register or immediate to PSR, flag bits only) */
			rf__read_0_1a = insn_1a[3:0];	/* Rm */
		`DECODE_ALU_SWP:	/* Atomic swap */
		begin
			rf__read_0_1a = insn_1a[19:16]; /* Rn */
			rf__read_1_1a = insn_1a[3:0];   /* Rm */
		end
		`DECODE_ALU_BX:		/* Branch and exchange */
			rf__read_0_1a = insn_1a[3:0];   /* Rn */
		`DECODE_ALU_HDATA_REG:	/* Halfword transfer - register offset */
		begin
			rf__read_0_1a = insn_1a[19:16];
			rf__read_1_1a = insn_1a[3:0];
			rf__read_2_1a = insn_1a[15:12];
		end
		`DECODE_ALU_HDATA_IMM:	/* Halfword transfer - immediate offset */
		begin
			rf__read_0_1a = insn_1a[19:16];
			rf__read_1_1a = insn_1a[15:12];
		end
		`DECODE_ALU:		/* ALU */
		begin
			rf__read_0_1a = insn_1a[19:16]; /* Rn */
			rf__read_1_1a = insn_1a[3:0];   /* Rm */
			rf__read_2_1a = insn_1a[11:8];  /* Rs for shift */
		end
		`DECODE_LDRSTR_UNDEFINED:	/* Undefined. I hate ARM */
		begin end
		`DECODE_LDRSTR:		/* Single data transfer */
		begin
			rf__read_0_1a = insn_1a[19:16]; /* Rn */
			rf__read_1_1a = insn_1a[3:0];   /* Rm */
			rf__read_2_1a = insn_1a[15:12];
		end
		`DECODE_LDMSTM:		/* Block data transfer */
			rf__read_0_1a = insn_1a[19:16];
		`DECODE_BRANCH:		/* Branch */
		begin end
		`DECODE_LDCSTC:		/* Coprocessor data transfer */
			rf__read_0_1a = insn_1a[19:16];
		`DECODE_CDP:		/* Coprocessor data op */
		begin end
		`DECODE_MRCMCR:		/* Coprocessor register transfer */
			rf__read_0_1a = insn_1a[15:12];
		`DECODE_SWI:		/* SWI */
		begin end
		default:
			$display("Undecoded instruction");
		endcase
	end
	
	always @(*) begin
		op0_1a = 32'hxxxxxxxx;
		op1_1a = 32'hxxxxxxxx;
		op2_1a = 32'hxxxxxxxx;
		carry_1a = 1'bx;
		
		casez (insn_1a)
		`DECODE_ALU_MULT:	/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
		begin
			op0_1a = regs0;
			op1_1a = regs1;
			op2_1a = regs2;
		end
		`DECODE_ALU_MRS:	/* MRS (Transfer PSR to register) */
		begin end
		`DECODE_ALU_MSR:	/* MSR (Transfer register to PSR) */
			op0_1a = regs0;
		`DECODE_ALU_MSR_FLAGS:	/* MSR (Transfer register or immediate to PSR, flag bits only) */
			if(insn_1a[25]) begin     /* the constant case */
				op0_1a = rotate_res;
			end else begin
				op0_1a = regs0;
			end
		`DECODE_ALU_SWP:	/* Atomic swap */
		begin
			op0_1a = regs0;
			op1_1a = regs1;
		end
		`DECODE_ALU_BX:		/* Branch and exchange */
			op0_1a = regs0;
		`DECODE_ALU_HDATA_REG:	/* Halfword transfer - register offset */
		begin
			op0_1a = regs0;
			op1_1a = regs1;
			op2_1a = regs2;
		end
		`DECODE_ALU_HDATA_IMM:	/* Halfword transfer - immediate offset */
		begin
			op0_1a = regs0;
			op1_1a = {24'b0, insn_1a[11:8], insn_1a[3:0]};
			op2_1a = regs1;
		end
		`DECODE_ALU:		/* ALU */
		begin
			op0_1a = regs0;
			if(insn_1a[25]) begin     /* the constant case */
				carry_1a = cpsr_1a[`CPSR_C];
				op1_1a = rotate_res;
			end else begin
				carry_1a = shift_cflag_out;
				op1_1a = shift_res;
			end
		end
		`DECODE_LDRSTR:		/* Single data transfer */
		begin
			op0_1a = regs0;
			if(!insn_1a[25] /* immediate */) begin
				op1_1a = {20'b0, insn_1a[11:0]};
				carry_1a = cpsr_1a[`CPSR_C];
			end else begin
				op1_1a = shift_res;
				carry_1a = shift_cflag_out;
			end
			op2_1a = regs2;
		end
		`DECODE_LDMSTM:		/* Block data transfer */
		begin
			op0_1a = regs0;
			op1_1a = {16'b0, insn_1a[15:0]};
		end
		`DECODE_BRANCH:		/* Branch */
			op0_1a = {{6{insn_1a[23]}}, insn_1a[23:0], 2'b0};
		`DECODE_LDCSTC:		/* Coprocessor data transfer */
		begin
			op0_1a = regs0;
			op1_1a = {24'b0, insn_1a[7:0]};
		end
		`DECODE_CDP:		/* Coprocessor data op */
		begin end
		`DECODE_MRCMCR:		/* Coprocessor register transfer */
			op0_1a = regs0;
		`DECODE_SWI:		/* SWI */
		begin end
		endcase
	end
	
	always @ (posedge clk) begin
		if (!stall)
		begin
			op0_2a <= op0_1a;   /* Rn - always */
			op1_2a <= op1_1a; /* 'operand 2' - Rm */
			op2_2a <= op2_1a;   /* thirdedge - Rs */
			carry_2a <= carry_1a;
			cpsr_2a <= cpsr_1a;
			spsr_2a <= spsr_1a;
		end
	end

endmodule

module IREALLYHATEARMSHIFT(
	input [31:0] insn,
	input [31:0] operand,
	input [31:0] reg_amt,
	input cflag_in,
	output reg [31:0] res,
	output reg cflag_out
);
	wire [5:0] shift_amt;
	reg is_arith, is_rot;
	wire rshift_cout;
	wire [31:0] rshift_res;

	assign shift_amt = insn[4] ? {|reg_amt[7:5], reg_amt[4:0]}     /* reg-specified shift */
	                           : {insn[11:7] == 5'b0, insn[11:7]}; /* immediate shift */

	SuckLessShifter barrel(.oper(operand),
	                       .carryin(cflag_in),
	                       .amt(shift_amt),
	                       .is_arith(is_arith),
	                       .is_rot(is_rot),
	                       .res(rshift_res),
	                       .carryout(rshift_cout));

	always @(*)
		case (insn[6:5])
		`SHIFT_LSL: begin
			/* meaningless */
			is_rot = 1'b0;
			is_arith = 1'b0;
		end
		`SHIFT_LSR: begin
			is_rot = 1'b0;
			is_arith = 1'b0;
		end
		`SHIFT_ASR: begin
			is_rot = 1'b0;
			is_arith = 1'b1;
		end
		`SHIFT_ROR: begin
			is_rot = 1'b1;
			is_arith = 1'b0;
		end
		endcase

	always @(*)
		case (insn[6:5]) /* shift type */
		`SHIFT_LSL:
			{cflag_out, res} = {cflag_in, operand} << {insn[4] & shift_amt[5], shift_amt[4:0]};
		`SHIFT_LSR: begin
			res = rshift_res;
			cflag_out = rshift_cout;
		end
		`SHIFT_ASR: begin
			res = rshift_res;
			cflag_out = rshift_cout;
		end
		`SHIFT_ROR: begin
			if(!insn[4] && shift_amt[4:0] == 5'b0) begin /* RRX x.x */
				res = {cflag_in, operand[31:1]};
				cflag_out = operand[0];
			end else begin
				res = rshift_res;
				cflag_out = rshift_cout;
			end
		end
		endcase
endmodule

module SuckLessShifter(
	input [31:0] oper,
	input carryin,
	input [5:0] amt,
	input is_arith,
	input is_rot,
	output wire [31:0] res,
	output wire carryout
);

	wire [32:0] stage1, stage2, stage3, stage4, stage5;

	wire pushbits = is_arith & oper[31];

	/* do a barrel shift */
	assign stage1 = amt[5] ? {is_rot ? oper : {32{pushbits}}, oper[31]} : {oper, carryin};
	assign stage2 = amt[4] ? {is_rot ? stage1[16:1] : {16{pushbits}}, stage1[32:17], stage1[16]} : stage1;
	assign stage3 = amt[3] ? {is_rot ? stage2[8:1] : {8{pushbits}}, stage2[32:9], stage2[8]} : stage2;
	assign stage4 = amt[2] ? {is_rot ? stage3[4:1] : {4{pushbits}}, stage3[32:5], stage3[4]} : stage3;
	assign stage5 = amt[1] ? {is_rot ? stage4[2:1] : {2{pushbits}}, stage4[32:3], stage4[2]} : stage4;
	assign {res, carryout} = amt[0] ? {is_rot ? stage5[1] : pushbits, stage5[32:2], stage5[1]} : stage5;

endmodule

module SuckLessRotator(
	input [31:0] oper,
	input [3:0] amt,
	output wire [31:0] res
);

	wire [31:0] stage1, stage2, stage3;
	assign stage1 = amt[3] ? {oper[15:0], oper[31:16]} : oper;
	assign stage2 = amt[2] ? {stage1[7:0], stage1[31:8]} : stage1;
	assign stage3 = amt[1] ? {stage2[3:0], stage2[31:4]} : stage2;
	assign res    = amt[0] ? {stage3[1:0], stage3[31:2]} : stage3;

endmodule

