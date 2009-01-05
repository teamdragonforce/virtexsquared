module Execute(
	input clk,
	input Nrst,	/* XXX not used yet */
	
	input stall,
	input flush,
	
	input inbubble,
	input [31:0] pc,
	input [31:0] insn,
	input [31:0] cpsr,
	input [31:0] spsr,
	input [31:0] op0,
	input [31:0] op1,
	input [31:0] op2,
	input carry,
	
	output reg outstall = 0,
	output reg outbubble = 1,
	output reg [31:0] outcpsr = 0,
	output reg [31:0] outspsr = 0,
	output reg write_reg = 1'bx,
	output reg [3:0] write_num = 4'bxxxx,
	output reg [31:0] write_data = 32'hxxxxxxxx,
	output reg [31:0] jmppc,
	output reg jmp
	);
	
	reg mult_start;
	reg [31:0] mult_acc0, mult_in0, mult_in1;
	wire mult_done;
	wire [31:0] mult_result;
	
	reg [31:0] alu_in0, alu_in1;
	reg [3:0] alu_op;
	reg alu_setflags;
	wire [31:0] alu_result, alu_outcpsr;
	wire alu_setres;
	
	reg next_outbubble;
	reg [31:0] next_outcpsr, next_outspsr;
	reg next_write_reg;
	reg [3:0] next_write_num;

	reg [31:0] next_write_data;

	Multiplier multiplier(
		.clk(clk), .Nrst(Nrst),
		.start(mult_start), .acc0(mult_acc0), .in0(mult_in0),
		.in1(mult_in1), .done(mult_done), .result(mult_result));
	
	ALU alu(
		.clk(clk), .Nrst(Nrst),
		.in0(alu_in0), .in1(alu_in1), .cpsr(cpsr), .op(alu_op),
		.setflags(alu_setflags), .shifter_carry(carry),
		.result(alu_result), .cpsr_out(alu_outcpsr), .setres(alu_setres));
	
	always @(posedge clk)
	begin
		if (!stall)
		begin
			outbubble <= next_outbubble;
			outcpsr <= next_outcpsr;
			outspsr <= next_outspsr;
			write_reg <= next_write_reg;
			write_num <= next_write_num;
			write_data <= next_write_data;
		end
	end

	reg prevstall = 0;
	always @(posedge clk)
		prevstall <= outstall;

	always @(*)
	begin
		outstall = stall;
		next_outbubble = inbubble | flush;
		next_outcpsr = cpsr;
		next_outspsr = spsr;
		next_write_reg = 0;
		next_write_num = 4'hx;
		next_write_data = 32'hxxxxxxxx;

		mult_start = 0;
		mult_acc0 = 32'hxxxxxxxx;
		mult_in0 = 32'hxxxxxxxx;
		mult_in1 = 32'hxxxxxxxx;

		alu_in0 = 32'hxxxxxxxx;
		alu_in1 = 32'hxxxxxxxx;
		alu_op = 4'hx;	/* hax! */
		alu_setflags = 1'bx;

		jmp = 1'b0;
		jmppc = 32'hxxxxxxxx;

		casez (insn)
		`DECODE_ALU_MULT:	/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
		begin
			if (!prevstall && !inbubble)
			begin
				mult_start = 1;
				mult_acc0 = insn[21] /* A */ ? op0 /* Rn */ : 32'h0;
				mult_in0 = op1 /* Rm */;
				mult_in1 = op2 /* Rs */;
				$display("New MUL instruction");
			end
			outstall = stall | ((!prevstall | !mult_done) && !inbubble);
			next_outbubble = inbubble | !mult_done | !prevstall;
			next_outcpsr = insn[20] /* S */ ? {mult_result[31] /* N */, mult_result == 0 /* Z */, 1'b0 /* C */, cpsr[28] /* V */, cpsr[27:0]} : cpsr;
			next_write_reg = 1;
			next_write_num = insn[19:16] /* Rd -- why the fuck isn't this the same place as ALU */;
			next_write_data = mult_result;
		end
//		`DECODE_ALU_MUL_LONG,	/* Multiply long */
		`DECODE_ALU_MRS:	/* MRS (Transfer PSR to register) */
		begin
			next_write_reg = 1;
			next_write_num = insn[15:12];
			if (insn[22] /* Ps */)
				next_write_data = spsr;
			else
				next_write_data = cpsr;
		end
		`DECODE_ALU_MSR,	/* MSR (Transfer register to PSR) */
		`DECODE_ALU_MSR_FLAGS:	/* MSR (Transfer register or immediate to PSR, flag bits only) */
			if ((cpsr[4:0] == `MODE_USR) || (insn[16] /* that random bit */ == 1'b0))	/* flags only */
			begin
				if (insn[22] /* Ps */)
					next_outspsr = {op0[31:29], spsr[28:0]};
				else
					next_outcpsr = {op0[31:29], cpsr[28:0]};
			end else begin
				if (insn[22] /* Ps */)
					next_outspsr = op0;
				else
					next_outcpsr = op0;
			end
		`DECODE_ALU_SWP,	/* Atomic swap */
		`DECODE_ALU_BX,		/* Branch */
		`DECODE_ALU_HDATA_REG,	/* Halfword transfer - register offset */
		`DECODE_ALU_HDATA_IMM:	/* Halfword transfer - immediate offset */
		begin end
		`DECODE_ALU:		/* ALU */
		begin
			alu_in0 = op0;
			alu_in1 = op1;
			alu_op = insn[24:21];
			alu_setflags = insn[20] /* S */;
			
			if (alu_setres) begin
				next_write_reg = 1;
				next_write_num = insn[15:12] /* Rd */;
				next_write_data = alu_result;
			end
			
			next_outcpsr = ((insn[15:12] == 4'b1111) && insn[20]) ? spsr : alu_outcpsr;
		end
		`DECODE_LDRSTR_UNDEFINED,	/* Undefined. I hate ARM */
		`DECODE_LDRSTR,		/* Single data transfer */
		`DECODE_LDMSTM:		/* Block data transfer */
		begin end
		`DECODE_BRANCH:
		begin
			if(!inbubble) begin
				jmppc = pc + op0 + 32'h8;
				if(insn[24]) begin
					next_write_reg = 1;
					next_write_num = 4'hE; /* link register */
					next_write_data = pc - 32'h4;
				end
				jmp = 1'b1;
			end
		end                     /* Branch */
		`DECODE_LDCSTC,		/* Coprocessor data transfer */
		`DECODE_CDP,		/* Coprocessor data op */
		`DECODE_MRCMCR,		/* Coprocessor register transfer */
		`DECODE_SWI:		/* SWI */
		begin end
		default:		/* X everything else out */
		begin end
		endcase
	end
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
	output reg setres
);
	reg [31:0] res;
	reg flag_n, flag_z, flag_c, flag_v;
	wire [32:0] sum, diff, rdiff;
	wire sum_v, diff_v, rdiff_v;

	assign sum = {1'b0, in0} + {1'b0, in1};
	assign diff = {1'b0, in0} - {1'b0, in1};
	assign rdiff = {1'b0, in1} + {1'b0, in0};
	assign sum_v = (in0[31] ^~ in1[31]) & (sum[31] ^ in0[31]);
	assign diff_v = (in0[31] ^ in1[31]) & (diff[31] ^ in0[31]);
	assign rdiff_v = (in0[31] ^ in1[31]) & (rdiff[31] ^ in1[31]);

	always @(*) begin
		res = 32'hxxxxxxxx;
		setres = 1'bx;
		flag_c = cpsr[`CPSR_C];
		flag_v = cpsr[`CPSR_V];
		case(op)
		`ALU_AND: begin
			result = in0 & in1;
			flag_c = shifter_carry;
			setres = 1'b1;
		end
		`ALU_EOR: begin
			result = in0 ^ in1;
			flag_c = shifter_carry;
			setres = 1'b1;
		end
		`ALU_SUB: begin
			{flag_c, result} = diff;
			flag_v = diff_v;
			setres = 1'b1;
		end
		`ALU_RSB: begin
			{flag_c, result} = rdiff;
			flag_v = rdiff_v;
			setres = 1'b1;
		end
		`ALU_ADD: begin
			{flag_c, result} = sum;
			flag_v = sum_v;
			setres = 1'b1;
		end
		`ALU_ADC: begin
			{flag_c, result} = sum + {32'b0, cpsr[`CPSR_C]};
			flag_v = sum_v | (~sum[31] & result[31]);
			setres = 1'b1;
		end
		`ALU_SBC: begin
			{flag_c, result} = diff - {32'b0, (~cpsr[`CPSR_C])};
			flag_v = diff_v | (diff[31] & ~result[31]);
			setres = 1'b1;
		end
		`ALU_RSC: begin
			{flag_c, result} = rdiff - {32'b0, (~cpsr[`CPSR_C])};
			flag_v = rdiff_v | (rdiff[31] & ~result[31]);
			setres = 1'b1;
		end
		`ALU_TST: begin
			result = in0 & in1;
			flag_c = shifter_carry;
			setres = 1'b0;
		end
		`ALU_TEQ: begin
			result = in0 ^ in1;
			flag_c = shifter_carry;
			setres = 1'b0;
		end
		`ALU_CMP: begin
			{flag_c, result} = diff;
			flag_v = diff_v;
			setres = 1'b0;
		end
		`ALU_CMN: begin
			{flag_c, result} = sum;
			flag_v = sum_v;
			setres = 1'b0;
		end
		`ALU_ORR: begin
			result = in0 | in1;
			flag_c = shifter_carry;
			setres = 1'b1;
		end
		`ALU_MOV: begin
			result = in1;
			flag_c = shifter_carry;
			setres = 1'b1;
		end
		`ALU_BIC: begin
			result = in0 & (~in1);
			flag_c = shifter_carry;
			setres = 1'b1;
		end
		`ALU_MVN: begin
			result = ~in1;
			flag_c = shifter_carry;
			setres = 1'b1;
		end
		endcase
		
		flag_z = (result == 0);
		flag_n = result[31];
		
		cpsr_out = setflags ? {flag_n, flag_z, flag_c, flag_v, cpsr[27:0]} : cpsr;
	end
endmodule
