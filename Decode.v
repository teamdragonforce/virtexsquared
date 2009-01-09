`include "ARM_Constants.v"

module Decode(
	input clk,
	input [31:0] insn,
	input [31:0] inpc,
	input [31:0] incpsr,
	input [31:0] inspsr,
	output reg [31:0] op0,
	output reg [31:0] op1,
	output reg [31:0] op2,
	output reg carry,
	output reg [31:0] outspsr,

	output reg [3:0] read_0,
	output reg [3:0] read_1,
	output reg [3:0] read_2,
	input [31:0] rdata_0,
	input [31:0] rdata_1,
	input [31:0] rdata_2
	);

	wire [31:0] regs0, regs1, regs2;
	reg [31:0] rpc;
	reg [31:0] op0_out, op1_out, op2_out;
	reg carry_out;

	/* shifter stuff */
	wire [31:0] shift_oper;
	wire [31:0] shift_res;
	wire shift_cflag_out;
	wire [31:0] rotate_res;

	assign regs0 = (read_0 == 4'b1111) ? rpc : rdata_0;
	assign regs1 = (read_1 == 4'b1111) ? rpc : rdata_1;
	assign regs2 = rdata_2; /* use regs2 for things that cannot be r15 */

	IREALLYHATEARMSHIFT shift(.insn(insn),
	                          .operand(regs1),
	                          .reg_amt(regs2),
	                          .cflag_in(incpsr[`CPSR_C]),
	                          .res(shift_res),
	                          .cflag_out(shift_cflag_out));

	SuckLessRotator whirr(.oper({24'b0, insn[7:0]}),
	                      .amt(insn[11:8]),
	                      .res(rotate_res));

	always @(*)
		casez (insn)
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
			rpc = inpc + 8;
		`DECODE_MRCMCR:			/* Coprocessor register transfer */
			rpc = inpc + 12;
		`DECODE_ALU:			/* ALU */
			rpc = inpc + (insn[25] ? 8 : (insn[4] ? 12 : 8));
		default:			/* X everything else out */
			rpc = 32'hxxxxxxxx;
		endcase
	
	always @(*) begin
		read_0 = 4'hx;
		read_1 = 4'hx;
		read_2 = 4'hx;
		
		op0_out = 32'hxxxxxxxx;
		op1_out = 32'hxxxxxxxx;
		op2_out = 32'hxxxxxxxx;
		carry_out = 1'bx;
		
		casez (insn)
		`DECODE_ALU_MULT:	/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
		begin
			read_0 = insn[15:12]; /* Rn */
			read_1 = insn[3:0];   /* Rm */
			read_2 = insn[11:8];  /* Rs */
			
			op0_out = regs0;
			op1_out = regs1;
			op2_out = regs2;
		end
//		`DECODE_ALU_MUL_LONG:	/* Multiply long */
//		begin
//			read_0 = insn[11:8]; /* Rn */
//			read_1 = insn[3:0];   /* Rm */
//			read_2 = 4'b0;       /* anyus */
//
//			op1_res = regs1;
//		end
		`DECODE_ALU_MRS:	/* MRS (Transfer PSR to register) */
		begin end
		`DECODE_ALU_MSR:	/* MSR (Transfer register to PSR) */
		begin
			read_0 = insn[3:0];	/* Rm */
			
			op0_out = regs0;
		end
		`DECODE_ALU_MSR_FLAGS:	/* MSR (Transfer register or immediate to PSR, flag bits only) */
		begin
			read_0 = insn[3:0];	/* Rm */
			
			if(insn[25]) begin     /* the constant case */
				op0_out = rotate_res;
			end else begin
				op0_out = regs0;
			end
		end
		`DECODE_ALU_SWP:	/* Atomic swap */
		begin
			read_0 = insn[19:16]; /* Rn */
			read_1 = insn[3:0];   /* Rm */
			
			op0_out = regs0;
			op1_out = regs1;
		end
		`DECODE_ALU_BX:		/* Branch and exchange */
		begin
			read_0 = insn[3:0];   /* Rn */
			
			op0_out = regs0;
		end
		`DECODE_ALU_HDATA_REG:	/* Halfword transfer - register offset */
		begin
			read_0 = insn[19:16];
			read_1 = insn[3:0];
			read_2 = insn[15:12];

			op0_out = regs0;
			op1_out = regs1;
			op2_out = regs2;
		end
		`DECODE_ALU_HDATA_IMM:	/* Halfword transfer - immediate offset */
		begin
			read_0 = insn[19:16];
			read_1 = insn[15:12];
			
			op0_out = regs0;
			op1_out = {24'b0, insn[11:8], insn[3:0]};
			op2_out = regs1;
		end
		`DECODE_ALU:		/* ALU */
		begin
			read_0 = insn[19:16]; /* Rn */
			read_1 = insn[3:0];   /* Rm */
			read_2 = insn[11:8];  /* Rs for shift */
			
			op0_out = regs0;
			if(insn[25]) begin     /* the constant case */
				carry_out = incpsr[`CPSR_C];
				op1_out = rotate_res;
			end else begin
				carry_out = shift_cflag_out;
				op1_out = shift_res;
			end
		end
		`DECODE_LDRSTR_UNDEFINED:	/* Undefined. I hate ARM */
		begin
			/* eat shit */
		end
		`DECODE_LDRSTR:		/* Single data transfer */
		begin
			read_0 = insn[19:16]; /* Rn */
			read_1 = insn[3:0];   /* Rm */
			read_2 = insn[15:12];
			
			op0_out = regs0;
			if(insn[25]) begin
				op1_out = {20'b0, insn[11:0]};
				carry_out = incpsr[`CPSR_C];
			end else begin
				op1_out = shift_res;
				carry_out = shift_cflag_out;
			end
			op2_out = regs2;
		end
		`DECODE_LDMSTM:		/* Block data transfer */
		begin
			read_0 = insn[19:16];
			
			op0_out = regs0;
			op1_out = {16'b0, insn[15:0]};
		end
		`DECODE_BRANCH:		/* Branch */
		begin
			op0_out = {{6{insn[23]}}, insn[23:0], 2'b0};
		end
		`DECODE_LDCSTC:		/* Coprocessor data transfer */
		begin
			read_0 = insn[19:16];
			
			op0_out = regs0;
			op1_out = {24'b0, insn[7:0]};
		end
		`DECODE_CDP:		/* Coprocessor data op */
		begin
		end
		`DECODE_MRCMCR:		/* Coprocessor register transfer */
		begin
			read_0 = insn[15:12];
			
			op0_out = regs0;
		end
		`DECODE_SWI:		/* SWI */
		begin
		end
		default:
			$display("Undecoded instruction");
		endcase
	end

	
	always @ (posedge clk) begin
		op0 <= op0_out;   /* Rn - always */
		op1 <= op1_out; /* 'operand 2' - Rm */
		op2 <= op2_out;   /* thirdedge - Rs */
		carry <= carry_out;
		outspsr <= inspsr;
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

