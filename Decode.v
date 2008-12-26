`include "ARM_Constants.v"

module Decode(
	input clk,
	input [31:0] insn,
	input [31:0] inpc,
	input [31:0] incpsr,
	output reg [31:0] op0,
	output reg [31:0] op1,
	output reg [31:0] op2,
	output reg [31:0] outcpsr,

	output [3:0] read_0,
	output [3:0] read_1,
	output [3:0] read_2,
	input [31:0] rdata_0,
	input [31:0] rdata_1,
	input [31:0] rdata_2
	);

	wire [31:0] regs0, regs1, regs2, rpc;
	wire [31:0] op1_res, cpsr;

	/* shifter stuff */
	wire [31:0] shift_oper;
	wire [31:0] shift_res;
	wire shift_cflag_out;

	assign regs0 = (read_0 == 4'b1111) ? rpc : rdata_0;
	assign regs1 = (read_1 == 4'b1111) ? rpc : rdata_1;
	assign regs2 = rdata_2; /* use regs2 for things that cannot be r15 */

	IHATEARMSHIFT blowme(.insn(insn),
	                     .operand(regs1),
	                     .reg_amt(regs2),
	                     .cflag_in(incpsr[`CPSR_C]),
	                     .res(shift_res),
	                     .cflag_out(shift_cflag_out));
	
	always @(*)
		casez (insn)
		32'b????000000??????????????1001????,	/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
//		32'b????00001???????????????1001????,	/* Multiply long */
		32'b????00010?001111????000000000000,	/* MRS (Transfer PSR to register) */
		32'b????00010?101001111100000000????,	/* MSR (Transfer register to PSR) */
		32'b????00?10?1010001111????????????,	/* MSR (Transfer register or immediate to PSR, flag bits only) */
		32'b????00010?00????????00001001????,	/* Atomic swap */
		32'b????000100101111111111110001????,	/* Branch */
		32'b????000??0??????????00001??1????,	/* Halfword transfer - register offset */
		32'b????000??1??????????00001??1????,	/* Halfword transfer - register offset */
		32'b????011????????????????????1????,	/* Undefined. I hate ARM */
		32'b????01??????????????????????????,	/* Single data transfer */
		32'b????100?????????????????????????,	/* Block data transfer */
		32'b????101?????????????????????????,	/* Branch */
		32'b????110?????????????????????????,	/* Coprocessor data transfer */
		32'b????1110???????????????????0????,	/* Coprocessor data op */
		32'b????1110???????????????????1????,	/* Coprocessor register transfer */
		32'b????1111????????????????????????:	/* SWI */
			rpc = inpc - 8;
		32'b????00??????????????????????????:	/* ALU */
			rpc = inpc - (insn[25] ? 8 : (insn[4] ? 12 : 8));
		default:				/* X everything else out */
			rpc = 32'hxxxxxxxx;
		endcase

	always @ (*) begin
		casez (insn)
		32'b????000000??????????????1001????: begin /* Multiply */
			read_0 = insn[15:12]; /* Rn */
			read_1 = insn[3:0];   /* Rm */
			read_2 = insn[11:8];  /* Rs */
			op1_res = regs1;
			cpsr = incpsr;
		end
/*
		32'b????00001???????????????1001????: begin * Multiply long *
			read_0 = insn[11:8]; * Rn *
			read_1 = insn[3:0];  * Rm *
			read_2 = 4'b0;       * anyus *
			op1_res = regs1;
		end
*/
		32'b????00010?001111????000000000000: begin /* MRS (Transfer PSR to register) */
			cpsr = incpsr;
		end
        	32'b????00010?101001111100000000????: begin /* MSR (Transfer register to PSR) */
			cpsr = incpsr;
        	end
                32'b????00?10?1010001111????????????: begin /* MSR (Transfer register or immediate to PSR, flag bits onry) */
			cpsr = incpsr;
                end
		32'b????00??????????????????????????: begin /* ALU */
			read_0 = insn[19:16]; /* Rn */
			read_1 = insn[3:0];   /* Rm */
			read_2 = insn[11:8];  /* Rs for shift */
			if(insn[25]) begin     /* the constant case */
				cpsr = incpsr;
				op1_res = ({24'b0, insn[7:0]} >> {insn[11:8], 1'b0}) | ({24'b0, insn[7:0]} << (5'b0 - {insn[11:8], 1'b0}));
			end else begin
				cpsr = {incpsr[31:30], shift_cflag_out, incpsr[28:0]};
				op1_res = shift_res;
			end
		end
		32'b????00010?00????????00001001????: begin /* Atomic swap */
			read_0 = insn[19:16]; /* Rn */
			read_1 = insn[3:0];   /* Rm */
			read_2 = 4'b0;        /* anyus */
			op1_res = regs1;
		end
		32'b????000100101111111111110001????: begin /* Branch and exchange */
			read_0 = insn[3:0];   /* Rn */
			cpsr = incpsr;
		end
		32'b????000??0??????????00001??1????: begin /* Halfword transfer - register offset */
			read_0 = insn[19:16];
			read_1 = insn[3:0];
			read_2 = 4'b0;
			op1_res = regs1;
			cpsr = incpsr;
		end
		32'b????000??1??????????00001??1????: begin /* Halfword transfer - immediate offset */
			read_0 = insn[19:16];
			read_1 = insn[3:0];
			op1_res = {24'b0, insn[11:8], insn[3:0]};
			cpsr = incpsr;
		end
		32'b????011????????????????????1????: begin /* Undefined. I hate ARM */
			/* eat shit */
		end
		32'b????01??????????????????????????: begin /* Single data transfer */
			read_0 = insn[19:16]; /* Rn */
			read_1 = insn[3:0];   /* Rm */
			if(insn[25]) begin
				op1_res = {20'b0, insn[11:0]};
				cpsr = incpsr;
			end else begin
				op1_res = shift_res;
				cpsr = {incpsr[31:30], shift_cflag_out, incpsr[28:0]};
			end
		end
		32'b????100?????????????????????????: begin /* Block data transfer */
			read_0 = insn[19:16];
			op1_res = {16'b0, insn[15:0]};
			cpsr = incpsr;
		end
		32'b????101?????????????????????????: begin /* Branch */
			op1_res = {{6{insn[23]}}, insn[23:0], 2'b0};
			cpsr = incpsr;
		end
		32'b????110?????????????????????????: begin /* Coprocessor data transfer */
			read_0 = insn[19:16];
			op1_res = {24'b0, insn[7:0]};
			cpsr = incpsr;
		end
		32'b????1110???????????????????0????: begin /* Coprocessor data op */
			cpsr = incpsr;
		end
		32'b????1110???????????????????1????: begin /* Coprocessor register transfer */
			cpsr = incpsr;
		end
		32'b????1111????????????????????????: begin /* SWI */
			cpsr = incpsr;
		end
		default: begin end
		endcase
	end

	always @ (posedge clk) begin
		op0 <= regs0;   /* Rn - always */
		op1 <= op1_res; /* 'operand 2' - Rm */
		op2 <= regs2;   /* thirdedge - Rs */
		outcpsr <= cpsr;
	end

endmodule

module IHATEARMSHIFT(
	input [31:0] insn,
	input [31:0] operand,
	input [31:0] reg_amt,
	input cflag_in,
	output [31:0] res,
	output cflag_out
);
	wire [5:0] shift_amt;
	wire elanus;


	/* might want to write our own damn shifter that does arithmetic/logical efficiently and stuff */
	always @(*)
		if(insn[4]) begin
			shift_amt = {|reg_amt[7:5], reg_amt[4:0]};
			elanus = 1'b1;
		end else begin
			shift_amt = {insn[11:7] == 5'b0, insn[11:7]};
			elanus = 1'b0;
		end
	
	always @(*)
		case (insn[6:5]) /* shift type */
		`SHIFT_LSL: begin
			{cflag_out, res} = {cflag_in, operand} << {elanus & shift_amt[5], shift_amt[4:0]};
		end
		`SHIFT_LSR: begin
			{res, cflag_out} = {operand, cflag_in} >> shift_amt;
		end
		`SHIFT_ASR: begin
			{res, cflag_out} = {operand, cflag_in} >> shift_amt | (operand[31] ? ~(33'h1FFFFFFFF >> shift_amt) : 33'b0);
		end
		`SHIFT_ROR: begin
			if(!elanus && shift_amt[4:0] == 5'b0) begin /* RRX x.x */
				res = {cflag_in, operand[31:1]};
				cflag_out = operand[0];
			end else if(shift_amt == 6'b0) begin
				res = operand;
				cflag_out = cflag_in;
			end else begin
				res = operand >> shift_amt[4:0] | operand << (5'b0 - shift_amt[4:0]);
				cflag_out = operand[shift_amt[4:0] - 5'b1];
			end
		end
		endcase
endmodule
