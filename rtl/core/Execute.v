module Execute(
	input clk,
	input Nrst,	/* XXX not used yet */
	
	input stall_2a,
	input flush_2a,
	
	input bubble_2a,
	input [31:0] pc_2a,
	input [31:0] insn_2a,
	input [31:0] cpsr_2a,
	input [31:0] spsr_2a,
	input [31:0] op0_2a,
	input [31:0] op1_2a,
	input [31:0] op2_2a,
	input carry_2a,
	
	output reg outstall_2a = 0,
	output reg bubble_3a = 1,
	output reg [31:0] cpsr_3a = 0,
	output reg [31:0] spsr_3a = 0,
	output reg cpsrup_3a = 0,
	output reg write_reg_3a = 1'bx,
	output reg [3:0] write_num_3a = 4'bxxxx,
	output reg [31:0] write_data_3a = 32'hxxxxxxxx,
	output reg [31:0] jmppc_2a,
	output reg jmp_2a,
	output reg [31:0] pc_3a,
	output reg [31:0] insn_3a,
	output reg [31:0] op0_3a, op1_3a, op2_3a
	);
	
	reg mult_start;
	reg [31:0] mult_acc0, mult_in0, mult_in1;
	wire mult_done;
	wire [31:0] mult_result;
	
	reg [31:0] alu_in0_2a, alu_in1_2a;
	reg [3:0] alu_op_2a;
	reg alu_setflags_2a;
	wire [31:0] alu_result_2a, alu_outcpsr_2a;
	wire alu_setres_2a;
	
	reg next_bubble_3a;
	reg [31:0] next_cpsr_3a, next_spsr_3a;
	reg next_cpsrup_3a;
	
	reg next_write_reg_3a;
	reg [3:0] next_write_num_3a;
	reg [31:0] next_write_data_3a;

	Multiplier multiplier(
		.clk(clk), .Nrst(Nrst),
		.start(mult_start), .acc0(mult_acc0), .in0(mult_in0),
		.in1(mult_in1), .done(mult_done), .result(mult_result));
	
	ALU alu(
		.clk(clk), .Nrst(Nrst),
		.in0(alu_in0_2a), .in1(alu_in1_2a), .cpsr(cpsr_2a), .op(alu_op_2a),
		.setflags(alu_setflags_2a), .shifter_carry(carry_2a),
		.result(alu_result_2a), .cpsr_out(alu_outcpsr_2a), .setres(alu_setres_2a));

	always @(posedge clk)
	begin
		if (!stall_2a)
		begin
			bubble_3a <= next_bubble_3a;
			cpsr_3a <= next_cpsr_3a;
			spsr_3a <= next_spsr_3a;
			cpsrup_3a <= next_cpsrup_3a;
			write_reg_3a <= next_write_reg_3a;
			write_num_3a <= next_write_num_3a;
			write_data_3a <= next_write_data_3a;
			pc_3a <= pc_2a;
			insn_3a <= insn_2a;
			op0_3a <= op0_2a;
			op1_3a <= op1_2a;
			op2_3a <= op2_2a;
		end
	end
	
	reg delayedflush_2a = 0;
	always @(posedge clk)
		if (flush_2a && outstall_2a /* halp! I can't do it now, maybe later? */)
			delayedflush_2a <= 1;
		else if (!outstall_2a /* anything has been handled this time around */)
			delayedflush_2a <= 0;

	reg outstall_3a = 0;
	always @(posedge clk)
		outstall_3a <= outstall_2a;
	
	always @(*)
	begin
		outstall_2a = stall_2a;
		
		casez (insn_2a)
		`DECODE_ALU_MULT:	/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
			outstall_2a = outstall_2a | ((!outstall_3a | !mult_done) && !bubble_2a);
		endcase
	end
	
	/* ALU inputs */
	always @(*)
	begin
		alu_in0_2a = op0_2a;
		alu_in1_2a = op1_2a;
		alu_op_2a = insn_2a[24:21];
		alu_setflags_2a = insn_2a[20] /* S */;
	end
	
	/* Register outputs */
	always @(*)
	begin
		next_cpsr_3a = cpsr_2a;
		next_spsr_3a = spsr_2a;
		next_cpsrup_3a = 0;
		next_write_reg_3a = 0;
		next_write_num_3a = 4'hx;
		next_write_data_3a = 32'hxxxxxxxx;
		
		casez(insn_2a)
		`DECODE_ALU_MULT:	/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
		begin
			next_cpsr_3a = insn_2a[20] /* S */ ? {mult_result[31] /* N */, mult_result == 0 /* Z */, 1'b0 /* C */, cpsr_2a[28] /* V */, cpsr_2a[27:0]} : cpsr_2a;
			next_cpsrup_3a = insn_2a[20] /* S */;
			next_write_reg_3a = 1;
			next_write_num_3a = insn_2a[19:16] /* Rd -- why the fuck isn't this the same place as ALU */;
			next_write_data_3a = mult_result;
		end
		`DECODE_ALU_MRS:	/* MRS (Transfer PSR to register) */
		begin
			next_write_reg_3a = 1;
			next_write_num_3a = insn_2a[15:12];
			if (insn_2a[22] /* Ps */)
				next_write_data_3a = spsr_2a;
			else
				next_write_data_3a = cpsr_2a;
		end
		`DECODE_ALU_MSR,	/* MSR (Transfer register to PSR) */
		`DECODE_ALU_MSR_FLAGS:	/* MSR (Transfer register or immediate to PSR, flag bits only) */
		begin
			if ((cpsr_2a[4:0] == `MODE_USR) || (insn_2a[16] /* that random bit */ == 1'b0))	/* flags only */
			begin
				if (insn_2a[22] /* Ps */)
					next_spsr_3a = {op0_2a[31:29], spsr_2a[28:0]};
				else
					next_cpsr_3a = {op0_2a[31:29], cpsr_2a[28:0]};
			end else begin
				if (insn_2a[22] /* Ps */)
					next_spsr_3a = op0_2a;
				else
					next_cpsr_3a = op0_2a;
			end
			next_cpsrup_3a = 1;
		end
		`DECODE_ALU_SWP,	/* Atomic swap */
		`DECODE_ALU_BX,		/* Branch */
		`DECODE_ALU_HDATA_REG,	/* Halfword transfer - register offset */
		`DECODE_ALU_HDATA_IMM:	/* Halfword transfer - immediate offset */
		begin end
		`DECODE_ALU:		/* ALU */
		begin
			if (alu_setres_2a) begin
				next_write_reg_3a = 1;
				next_write_num_3a = insn_2a[15:12] /* Rd */;
				next_write_data_3a = alu_result_2a;
			end
			
			if (insn_2a[20] /* S */) begin
				next_cpsrup_3a = 1;
				next_cpsr_3a = ((insn_2a[15:12] == 4'b1111) && insn_2a[20]) ? spsr_2a : alu_outcpsr_2a;
			end
		end
		`DECODE_LDRSTR_UNDEFINED,	/* Undefined. I hate ARM */
		`DECODE_LDRSTR,		/* Single data transfer */
		`DECODE_LDMSTM:		/* Block data transfer */
		begin end
		`DECODE_BRANCH:		/* Branch */
		begin
			if(insn_2a[24] /* L */) begin
				next_write_reg_3a = 1;
				next_write_num_3a = 4'hE; /* link register */
				next_write_data_3a = pc_2a + 32'h4;
			end
		end
		endcase
	end
	
	/* Multiplier inputs */
	always @(*)
	begin
		mult_start = 0;
		mult_acc0 = 32'hxxxxxxxx;
		mult_in0 = 32'hxxxxxxxx;
		mult_in1 = 32'hxxxxxxxx;
		
		casez(insn_2a)
		`DECODE_ALU_MULT:
		begin
			if (!outstall_3a /* i.e., this is a new one */ && !bubble_2a /* i.e., this is a real one */)
			begin
				mult_start = 1;
				mult_acc0 = insn_2a[21] /* A */ ? op0_2a /* Rn */ : 32'h0;
				mult_in0 = op1_2a /* Rm */;
				mult_in1 = op2_2a /* Rs */;
				$display("New MUL instruction");
			end
		end
		endcase
	end

	/* Miscellaneous cleanup. */
	always @(*)
	begin
		next_bubble_3a = bubble_2a | flush_2a | delayedflush_2a;

		jmp_2a = 1'b0;
		jmppc_2a = 32'h00000000;

		casez (insn_2a)
		`DECODE_ALU_MULT:	/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
			next_bubble_3a = next_bubble_3a | !mult_done | !outstall_3a;
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
		`DECODE_LDMSTM:		/* Block data transfer */
		begin end
		`DECODE_BRANCH:
		begin
			if(!bubble_2a && !flush_2a && !delayedflush_2a && !outstall_2a /* Let someone else take precedence. */) begin
				jmppc_2a = pc_2a + op0_2a + 32'h8;
				jmp_2a = 1'b1;
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
	assign rdiff = {1'b0, in1} - {1'b0, in0};
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
			flag_c = !flag_c;
			flag_v = diff_v;
			setres = 1'b1;
		end
		`ALU_RSB: begin
			{flag_c, result} = rdiff;
			flag_c = !flag_c;
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
			flag_c = !flag_c;
			flag_v = diff_v | (diff[31] & ~result[31]);
			setres = 1'b1;
		end
		`ALU_RSC: begin
			{flag_c, result} = rdiff - {32'b0, (~cpsr[`CPSR_C])};
			flag_c = !flag_c;
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
			flag_c = !flag_c;
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
