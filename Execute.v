module Execute(
	input clk,
	input Nrst,	/* XXX not used yet */
	
	input stall,
	input flush,
	
	input inbubble,
	input [31:0] pc,
	input [31:0] insn,
	input [31:0] cpsr,
	input [31:0] op0,
	input [31:0] op1,
	input [31:0] op2,
	input carry,
	
	output reg outstall = 0,
	output reg outbubble = 1,
	output reg [31:0] outcpsr = 0,
	output reg write_reg = 1'bx,
	output reg [3:0] write_num = 4'bxxxx,
	output reg [31:0] write_data = 32'hxxxxxxxx
	);
	
	reg mult_start;
	reg [31:0] mult_acc0, mult_in0, mult_in1;
	wire mult_done;
	wire [31:0] mult_result;
	
	reg [31:0] alu_in0, alu_in1;
	reg [3:0] alu_op;
	reg alu_setflags;
	wire [31:0] alu_result, alu_outcpsr;
	wire alu_set;
	
	Multiplier multiplier(
		.clk(clk), .Nrst(Nrst),
		.start(mult_start), .acc0(mult_acc0), .in0(mult_in0),
		.in1(mult_in1), .done(mult_done), .result(mult_result));
	
	ALU alu(
		.clk(clk), .Nrst(Nrst),
		.in0(alu_in0), .in1(alu_in1), .cpsr(cpsr), .op(alu_op),
		.setflags(alu_setflags), .shifter_carry(carry),
		.result(alu_result), .cpsr_out(alu_outcpsr), .set(alu_set));

	always @(*)
		casez (insn)
		`DECODE_ALU_MULT,	/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
//		`DECODE_ALU_MUL_LONG,	/* Multiply long */
		`DECODE_ALU_MRS,	/* MRS (Transfer PSR to register) */
		`DECODE_ALU_MSR,	/* MSR (Transfer register to PSR) */
		`DECODE_ALU_MSR_FLAGS,	/* MSR (Transfer register or immediate to PSR, flag bits only) */
		`DECODE_ALU_SWP,	/* Atomic swap */
		`DECODE_ALU_BX,		/* Branch */
		`DECODE_ALU_HDATA_REG,	/* Halfword transfer - register offset */
		`DECODE_ALU_HDATA_IMM,	/* Halfword transfer - immediate offset */
		`DECODE_ALU,		/* ALU */
		`DECODE_LDRSTR_UNDEFINED,	/* Undefined. I hate ARM */
		`DECODE_LDRSTR,		/* Single data transfer */
		`DECODE_LDMSTM,		/* Block data transfer */
		`DECODE_BRANCH,		/* Branch */
		`DECODE_LDCSTC,		/* Coprocessor data transfer */
		`DECODE_CDP,		/* Coprocessor data op */
		`DECODE_MRCMCR,		/* Coprocessor register transfer */
		`DECODE_SWI:		/* SWI */
		begin end
		default:		/* X everything else out */
		begin end
		endcase
endmodule

module Multiplier(
	input clk,
	input Nrst,	/* XXX not used yet */
	
	input start,
	input [31:0] acc0,
	input [31:0] in0,
	input [31:0] in1,
	
	output reg done = 0,
	output reg [31:0] result);
	
	reg [31:0] bitfield;
	reg [31:0] multiplicand;
	reg [31:0] acc;
	
	always @(posedge clk)
	begin
		if (start) begin
			bitfield <= in0;
			multiplicand <= in1;
			acc <= acc0;
			done <= 0;
		end else begin
			bitfield <= {2'b00, bitfield[31:2]};
			multiplicand <= {multiplicand[29:0], 2'b00};
			acc <= acc +
				(bitfield[0] ? multiplicand : 0) +
				(bitfield[1] ? {multiplicand[30:0], 1'b0} : 0);
			if (bitfield == 0) begin
				result <= acc;
				done <= 1;
			end
		end
	end
endmodule

/* XXX is the interface correct? */
module ALU(
	input clk,
	input Nrst,	/* XXX not used yet */

	input [31:0] in0,
	input [31:0] in1,
	input [31:0] cpsr,
	input [3:0] op,
	input setflags,
	input shifter_carry,

	output reg [31:0] result,
	output reg [31:0] cpsr_out,
	output reg set
);
	wire [31:0] res;
	wire flag_n, flag_z, flag_c, flag_v, setres;
	wire [32:0] sum, diff, rdiff;

	assign sum = {1'b0, in0} + {1'b0, in1};
	assign diff = {1'b0, in0} - {1'b0, in1};
	assign rdiff = {1'b0, in1} + {1'b0, in0};

	/* TODO XXX flag_v not set correctly */
	always @(*) begin
		res = 32'hxxxxxxxx;
		setres = 1'bx;
		flag_c = cpsr[`CPSR_C];
		flag_v = cpsr[`CPSR_V];
		case(op)
		`ALU_AND: begin
			res = in0 & in1;
			flag_c = shifter_carry;
			setres = 1'b1;
		end
		`ALU_EOR: begin
			res = in0 ^ in1;
			flag_c = shifter_carry;
			setres = 1'b1;
		end
		`ALU_SUB: begin
			{flag_c, res} = diff;
			setres = 1'b1;
		end
		`ALU_RSB: begin
			{flag_c, res} = rdiff;
			setres = 1'b1;
		end
		`ALU_ADD: begin
			{flag_c, res} = sum;
			setres = 1'b1;
		end
		`ALU_ADC: begin
			{flag_c, res} = sum + {32'b0, cpsr[`CPSR_C]};
			setres = 1'b1;
		end
		`ALU_SBC: begin
			{flag_c, res} = diff - {32'b0, (~cpsr[`CPSR_C])};
			setres = 1'b1;
		end
		`ALU_RSC: begin
			{flag_c, res} = rdiff - {32'b0, (~cpsr[`CPSR_C])};
			setres = 1'b1;
		end
		`ALU_TST: begin
			res = in0 & in1;
			flag_c = shifter_carry;
			setres = 1'b0;
		end
		`ALU_TEQ: begin
			res = in0 ^ in1;
			flag_c = shifter_carry;
			setres = 1'b0;
		end
		`ALU_CMP: begin
			{flag_c, res} = diff;
			setres = 1'b0;
		end
		`ALU_CMN: begin
			{flag_c, res} = sum;
			setres = 1'b0;
		end
		`ALU_ORR: begin
			res = in0 | in1;
			flag_c = shifter_carry;
			setres = 1'b1;
		end
		`ALU_MOV: begin
			res = in1;
			flag_c = shifter_carry;
			setres = 1'b1;
		end
		`ALU_BIC: begin
			res = in0 & (~in1);
			flag_c = shifter_carry;
			setres = 1'b1;
		end
		`ALU_MVN: begin
			res = ~in1;
			flag_c = shifter_carry;
			setres = 1'b1;
		end
		endcase
	end

	always @(*) begin
		flag_z = (res == 0);
		flag_n = res[31];
	end

	always @(posedge clk) begin
		result <= res;
		cpsr_out <= setflags ? {flag_n, flag_z, flag_c, flag_v, cpsr[27:0]} : cpsr;
		set <= setres;
	end

endmodule
