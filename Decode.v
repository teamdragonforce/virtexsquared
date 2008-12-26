`include "ARM_Constants.v"

module Decode(
	input clk,
	input [31:0] ansn,
	input [31:0] inpc,
	input [31:0] cps_in,
	output reg [31:0] op0,
	output reg [31:0] op1,
	output reg [31:0] op2,
	output reg [31:0] cps_out,

	output [3:0] regsel0,
	output [3:0] regsel1,
	output [3:0] regsel2,
	input [31:0] iregs0,
	input [31:0] iregs1,
	input [31:0] iregs2
	);

	wire [31:0] regs0, regs1, regs2, rpc;
	wire [31:0] op1_res, new_cps;

	/* shifter stuff */
	wire [31:0] shift_oper;
	wire [31:0] shift_res;
	wire shift_cflag_out;

	assign regs0 = (regsel0 == 4'b1111) ? rpc : iregs0;
	assign regs1 = (regsel1 == 4'b1111) ? rpc : iregs1;
	assign regs2 = iregs2; /* use regs2 for things that cannot be r15 */

	IHATEARMSHIFT blowme(.insn(ansn),
	                     .operand(regs1),
	                     .reg_amt(regs2),
	                     .cflag_in(cps_in[`CPSR_C]),
	                     .res(shift_res),
	                     .cflag_out(shift_cflag_out));

	always @ (*) begin
		casez (ansn)
		32'b????000000??????????????1001????: begin /* Multiply */
			rpc = inpc - 8;
			regsel0 = ansn[15:12]; /* Rn */
			regsel1 = ansn[3:0];   /* Rm */
			regsel2 = ansn[11:8];  /* Rs */
			op1_res = regs1;
			new_cps = cps_in;
		end
/*
		32'b????00001???????????????1001????: begin * Multiply long *
			regsel0 = ansn[11:8]; * Rn *
			regsel1 = ansn[3:0];  * Rm *
			regsel2 = 4'b0;       * anyus *
			op1_res = regs1;
		end
*/
		32'b????00010?001111????000000000000: begin /* MRS (Transfer PSR to register) */
			rpc = inpc - 8;
			new_cps = cps_in;
		end
        	32'b????00010?101001111100000000????: begin /* MSR (Transfer register to PSR) */
			rpc = inpc - 8;
			new_cps = cps_in;
        	end
                32'b????00?10?1010001111????????????: begin /* MSR (Transfer register or immediate to PSR, flag bits onry) */
			rpc = inpc - 8;
			new_cps = cps_in;
                end
		32'b????00??????????????????????????: begin /* ALU */
			rpc = inpc - (ansn[25] ? 8 : (ansn[4] ? 12 : 8));
			regsel0 = ansn[19:16]; /* Rn */
			regsel1 = ansn[3:0];   /* Rm */
			regsel2 = ansn[11:8];  /* Rs for shift */
			if(ansn[25]) begin     /* the constant case */
				new_cps = cps_in;
				op1_res = ({24'b0, ansn[7:0]} >> {ansn[11:8], 1'b0}) | ({24'b0, ansn[7:0]} << (5'b0 - {ansn[11:8], 1'b0}));
			end else begin
				new_cps = {cps_in[31:30], shift_cflag_out, cps_in[28:0]};
				op1_res = shift_res;
			end
		end
		32'b????00010?00????????00001001????: begin /* Atomic swap */
			rpc = inpc - 8;
			regsel0 = ansn[19:16]; /* Rn */
			regsel1 = ansn[3:0];   /* Rm */
			regsel2 = 4'b0;        /* anyus */
			op1_res = regs1;
		end
		32'b????000100101111111111110001????: begin /* Branch and exchange */
			rpc = inpc - 8;
			regsel0 = ansn[3:0];   /* Rn */
			new_cps = cps_in;
		end
		32'b????000??0??????????00001??1????: begin /* Halfword transfer - register offset */
			rpc = inpc - 8;
			regsel0 = ansn[19:16];
			regsel1 = ansn[3:0];
			regsel2 = 4'b0;
			op1_res = regs1;
			new_cps = cps_in;
		end
		32'b????000??1??????????00001??1????: begin /* Halfword transfer - immediate offset */
			rpc = inpc - 8;
			regsel0 = ansn[19:16];
			regsel1 = ansn[3:0];
			op1_res = {24'b0, ansn[11:8], ansn[3:0]};
			new_cps = cps_in;
		end
		32'b????011????????????????????1????: begin /* Undefined. I hate ARM */
			/* eat shit */
		end
		32'b????01??????????????????????????: begin /* Single data transfer */
			rpc = inpc - 8;
			regsel0 = ansn[19:16]; /* Rn */
			regsel1 = ansn[3:0];   /* Rm */
			if(ansn[25]) begin
				op1_res = {20'b0, ansn[11:0]};
				new_cps = cps_in;
			end else begin
				op1_res = shift_res;
				new_cps = {cps_in[31:30], shift_cflag_out, cps_in[28:0]};
			end
		end
		32'b????100?????????????????????????: begin /* Block data transfer */
			rpc = inpc - 8;
			regsel0 = ansn[19:16];
			op1_res = {16'b0, ansn[15:0]};
			new_cps = cps_in;
		end
		32'b????101?????????????????????????: begin /* Branch */
			rpc = inpc - 8;
			op1_res = {{6{ansn[23]}}, ansn[23:0], 2'b0};
			new_cps = cps_in;
		end
		32'b????110?????????????????????????: begin /* Coprocessor data transfer */
			rpc = inpc - 8;
			regsel0 = ansn[19:16];
			op1_res = {24'b0, ansn[7:0]};
			new_cps = cps_in;
		end
		32'b????1110???????????????????0????: begin /* Coprocessor data op */
			rpc = inpc - 8;
			new_cps = cps_in;
		end
		32'b????1110???????????????????1????: begin /* Coprocessor register transfer */
			rpc = inpc - 8;
			new_cps = cps_in;
		end
		32'b????1111????????????????????????: begin /* SWI */
			rpc = inpc - 8;
			new_cps = cps_in;
		end
		default: begin end
		endcase
	end

	always @ (posedge clk) begin
		op0 <= regs0;   /* Rn - always */
		op1 <= op1_res; /* 'operand 2' - Rm */
		op2 <= regs2;   /* thirdedge - Rs */
		cps_out <= new_cps;
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
	always @ (*) begin
		if(insn[4]) begin
			shift_amt = {|reg_amt[7:5], reg_amt[4:0]};
			elanus = 1'b1;
		end else begin
			shift_amt = {insn[11:7] == 5'b0, insn[11:7]};
			elanus = 1'b0;
		end

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
	end
endmodule
