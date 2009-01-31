`include "ARM_Constants.v"

module Memory(
	input clk,
	input Nrst,

	input flush,

	/* bus interface */
	output reg [31:0] busaddr,
	output reg rd_req,
	output reg wr_req,
	input rw_wait,
	output reg [31:0] wr_data,
	input [31:0] rd_data,
	output reg [2:0] data_size,

	/* regfile interface */
	output reg [3:0] st_read,
	input [31:0] st_data,
	
	/* Coprocessor interface */
	output reg cp_req,
	input cp_ack,
	input cp_busy,
	output reg cp_rnw,	/* 1 = read from CP, 0 = write to CP */
	input [31:0] cp_read,
	output reg [31:0] cp_write,
	
	/* stage inputs */
	input inbubble,
	input [31:0] pc,
	input [31:0] insn,
	input [31:0] op0,
	input [31:0] op1,
	input [31:0] op2,
	input [31:0] spsr,
	input [31:0] cpsr,
	input cpsrup,
	input write_reg,
	input [3:0] write_num,
	input [31:0] write_data,

	/* outputs */
	output reg outstall,
	output reg outbubble,
	output reg [31:0] outpc,
	output reg [31:0] outinsn,
	output reg out_write_reg = 1'b0,
	output reg [3:0] out_write_num = 4'bxxxx,
	output reg [31:0] out_write_data = 32'hxxxxxxxx,
	output reg [31:0] outspsr = 32'hxxxxxxxx,
	output reg [31:0] outcpsr = 32'hxxxxxxxx,
	output reg outcpsrup = 1'hx
	);

	reg [31:0] addr, raddr, prev_raddr, next_regdata, next_outcpsr;
	reg next_outcpsrup;
	reg [31:0] prevaddr;
	reg [3:0] next_regsel, cur_reg, prev_reg;
	reg next_writeback;

	reg next_outbubble;	
	reg next_write_reg;
	reg [3:0] next_write_num;
	reg [31:0] next_write_data;

	reg [3:0] lsr_state = 4'b0001, next_lsr_state;
	reg [31:0] align_s1, align_s2, align_rddata;

	reg [2:0] lsrh_state = 3'b001, next_lsrh_state;
	reg [31:0] lsrh_rddata;
	reg [15:0] lsrh_rddata_s1;
	reg [7:0] lsrh_rddata_s2;

	reg [15:0] regs, next_regs;
	reg [3:0] lsm_state = 4'b0001, next_lsm_state;
	reg [5:0] offset, prev_offset, offset_sel;

	reg [31:0] swp_oldval, next_swp_oldval;
	reg [1:0] swp_state = 2'b01, next_swp_state;
	
	reg do_rd_data_latch;
	reg [31:0] rd_data_latch = 32'hxxxxxxxx;

	always @(posedge clk)
	begin
		outpc <= pc;
		outinsn <= insn;
		outbubble <= next_outbubble;
		out_write_reg <= next_write_reg;
		out_write_num <= next_write_num;
		out_write_data <= next_write_data;
		regs <= next_regs;
		prev_reg <= cur_reg;
		if (!rw_wait)
			prev_offset <= offset;
		prev_raddr <= raddr;
		outcpsr <= next_outcpsr;
		outspsr <= spsr;
		outcpsrup <= next_outcpsrup;
		swp_state <= next_swp_state;
		lsm_state <= next_lsm_state;
		lsr_state <= next_lsr_state;
		lsrh_state <= next_lsrh_state;
		if (do_rd_data_latch)
			rd_data_latch <= rd_data;
		prevaddr <= addr;
	end
	
	reg delayedflush = 0;
	always @(posedge clk)
		if (flush && outstall /* halp! I can't do it now, maybe later? */)
			delayedflush <= 1;
		else if (!outstall /* anything has been handled this time around */)
			delayedflush <= 0;

	always @(*)
	begin
		addr = prevaddr;
		raddr = 32'hxxxxxxxx;
		rd_req = 1'b0;
		wr_req = 1'b0;
		wr_data = 32'hxxxxxxxx;
		busaddr = 32'hxxxxxxxx;
		data_size = 3'bxxx;
		outstall = 1'b0;
		st_read = 4'hx;
		do_rd_data_latch = 0;
		next_write_reg = write_reg;
		next_write_num = write_num;
		next_write_data = write_data;
		next_outbubble = inbubble;
		next_regs = regs;
		cp_req = 1'b0;
		cp_rnw = 1'bx;
		cp_write = 32'hxxxxxxxx;
		offset = prev_offset;
		next_outcpsr = lsm_state == 4'b0010 ? outcpsr : cpsr;
		next_outcpsrup = cpsrup;
		lsrh_rddata = 32'hxxxxxxxx;
		lsrh_rddata_s1 = 16'hxxxx;
		lsrh_rddata_s2 = 8'hxx;
		next_lsm_state = lsm_state;
		next_lsr_state = lsr_state;
		next_lsrh_state = lsrh_state;
		next_swp_oldval = swp_oldval;
		next_swp_state = swp_state;
		cur_reg = prev_reg;

`define SWP_READING 2'b01
`define SWP_WRITING 2'b10

`define LSRH_MEMIO	3'b001
`define LSRH_BASEWB	3'b010
`define LSRH_WBFLUSH	3'b100

`define LSR_MEMIO	4'b0001
`define LSR_STRB_WR	4'b0010
`define LSR_BASEWB	4'b0100
`define LSR_WBFLUSH	4'b1000

`define LSM_SETUP	4'b0001
`define LSM_MEMIO	4'b0010
`define LSM_BASEWB	4'b0100
`define LSM_WBFLUSH	4'b1000

		/* XXX shit not given about endianness */
		casez(insn)
		`DECODE_ALU_SWP: if(!inbubble) begin
			outstall = rw_wait;
			next_outbubble = rw_wait;
			busaddr = {op0[31:2], 2'b0};
			data_size = insn[22] ? 3'b001 : 3'b100;
			case(swp_state)
			`SWP_READING: begin
				rd_req = 1'b1;
				outstall = 1'b1;
				if(!rw_wait) begin
					next_swp_state = `SWP_WRITING;
					next_swp_oldval = rd_data;
				end
				$display("SWP: read stage");
			end
			`SWP_WRITING: begin
				wr_req = 1'b1;
				wr_data = insn[22] ? {4{op1[7:0]}} : op1;
				next_write_reg = 1'b1;
				next_write_num = insn[15:12];
				next_write_data = insn[22] ? {24'b0, swp_oldval[7:0]} : swp_oldval;
				if(!rw_wait)
					next_swp_state = `SWP_READING;
				$display("SWP: write stage");
			end
			default: begin end
			endcase
		end
		`DECODE_ALU_MULT: begin end
		`DECODE_ALU_HDATA_REG,
		`DECODE_ALU_HDATA_IMM: if(!inbubble) begin
			next_outbubble = rw_wait;
			outstall = rw_wait;
			addr = insn[23] ? op0 + op1 : op0 - op1; /* up/down select */
			raddr = insn[24] ? op0 : addr; /* pre/post increment */
			busaddr = raddr;
			/* rotate to correct position */
			case(insn[6:5])
			2'b01: begin /* unsigned half */
				wr_data = {2{op2[15:0]}}; /* XXX need to store halfword */
				data_size = 3'b010;
				lsrh_rddata = {16'b0, raddr[1] ? rd_data[31:16] : rd_data[15:0]};
			end
			2'b10: begin /* signed byte */
				wr_data = {4{op2[7:0]}};
				data_size = 3'b001;
				lsrh_rddata_s1 = raddr[1] ? rd_data[31:16] : rd_data[15:0];
				lsrh_rddata_s2 = raddr[0] ? lsrh_rddata_s1[15:8] : lsrh_rddata_s1[7:0];
				lsrh_rddata = {{24{lsrh_rddata_s2[7]}}, lsrh_rddata_s2};
			end
			2'b11: begin /* signed half */
				wr_data = {2{op2[15:0]}};
				data_size = 3'b010;
				lsrh_rddata = raddr[1] ? {{16{rd_data[31]}}, rd_data[31:16]} : {{16{rd_data[15]}}, rd_data[15:0]};
			end
			default: begin
				wr_data = 32'hxxxxxxxx;
				data_size = 3'bxxx;
				lsrh_rddata = 32'hxxxxxxxx;
			end
			endcase

			case(lsrh_state)
			`LSRH_MEMIO: begin
				rd_req = insn[20];
				wr_req = ~insn[20];
				next_write_num = insn[15:12];
				next_write_data = lsrh_rddata;
				if(insn[20]) begin
					next_write_reg = 1'b1;
				end
				if(insn[21] | !insn[24]) begin
					outstall = 1'b1;
					if(!rw_wait)
						next_lsrh_state = `LSRH_BASEWB;
				end
				$display("ALU_LDRSTRH: rd_req %d, wr_req %d", rd_req, wr_req);
			end
			`LSRH_BASEWB: begin
				next_outbubble = 1'b0;
				next_write_reg = 1'b1;
				next_write_num = insn[19:16];
				next_write_data = addr;
				next_lsrh_state = `LSRH_WBFLUSH;
			end
			`LSRH_WBFLUSH: begin
				outstall = 0;
				next_lsrh_state = `LSRH_MEMIO;
			end
			default: begin end
			endcase
			
			if ((lsrh_state == `LSRH_MEMIO) && flush) begin	/* Reject it. */
				outstall = 1'b0;
				next_lsrh_state = `LSRH_MEMIO;
			end
		end
		`DECODE_LDRSTR_UNDEFINED: begin end
		`DECODE_LDRSTR: if(!inbubble) begin
			next_outbubble = rw_wait;
			outstall = rw_wait;
			addr = insn[23] ? op0 + op1 : op0 - op1; /* up/down select */
			raddr = insn[24] ? addr : op0; /* pre/post increment */
			busaddr = raddr;
			/* rotate to correct position */
			align_s1 = raddr[1] ? {rd_data[15:0], rd_data[31:16]} : rd_data;
			align_s2 = raddr[0] ? {align_s1[7:0], align_s1[31:8]} : align_s1;
			/* select byte or word */
			align_rddata = insn[22] ? {24'b0, align_s2[7:0]} : align_s2;
			wr_data = insn[22] ? {24'h0, {op2[7:0]}} : op2;
			data_size = insn[22] ? 3'b001 : 3'b100;
			case(lsr_state)

			`LSR_MEMIO: begin
				rd_req = insn[20] /* L */ || insn[22] /* B */;
				wr_req = !insn[20] /* L */ && !insn[22]/* B */;
				next_write_reg = insn[20] /* L */;
				next_write_num = insn[15:12];
				if(insn[20] /* L */) begin
					next_write_data = insn[22] /* B */ ? {24'h0, align_rddata[7:0]} : align_rddata;
				end
				if (insn[22] /* B */ && !insn[20] /* L */) begin
					do_rd_data_latch = 1;
					outstall = 1'b1;
					if (!rw_wait)
						next_lsr_state = `LSR_STRB_WR;
				end else if(insn[21] /* W */ | !insn[24] /* P */) begin
					outstall = 1'b1;
					if(!rw_wait)
						next_lsr_state = `LSR_BASEWB;
				end
				$display("LDRSTR: rd_req %d, wr_req %d, raddr %08x, wait %d", rd_req, wr_req, raddr, rw_wait);
			end
			`LSR_STRB_WR: begin
				$display("LDRSTR: Handling STRB");
				outstall = 1;
				rd_req = 0;
				wr_req = 1;
				next_write_reg = 0;
				case (busaddr[1:0])
				2'b00: wr_data = {rd_data_latch[31:8], op2[7:0]};
				2'b01: wr_data = {rd_data_latch[31:16], op2[7:0], rd_data_latch[7:0]};
				2'b10: wr_data = {rd_data_latch[31:24], op2[7:0], rd_data_latch[15:0]};
				2'b11: wr_data = {op2[7:0], rd_data_latch[23:0]};
				endcase
				if(insn[21] /* W */ | !insn[24] /* P */) begin
					if(!rw_wait)
						next_lsr_state = `LSR_BASEWB;
				end else if (!rw_wait)
					next_lsr_state = `LSR_WBFLUSH;
			end
			`LSR_BASEWB: begin
				outstall = 1;
				rd_req = 0;
				wr_req= 0;
				next_outbubble = 0;
				next_write_reg = 1'b1;
				next_write_num = insn[19:16];
				next_write_data = addr;
				next_lsr_state = `LSR_WBFLUSH;
			end
			`LSR_WBFLUSH: begin
				rd_req = 0;
				wr_req= 0;
				outstall = 0;
				next_lsr_state = `LSR_MEMIO;
			end
			default: begin end
			endcase
			
			if ((lsr_state == `LSR_MEMIO) && flush) begin	/* Reject it. */
				outstall = 1'b0;
				next_lsr_state = `LSR_MEMIO;
			end
		end
		/* XXX ldm/stm incorrect in that stupid case where one of the listed regs is the base reg */
		`DECODE_LDMSTM: if(!inbubble) begin
			outstall = rw_wait;
			next_outbubble = rw_wait;
			data_size = 3'b100;
			case(lsm_state)
			`LSM_SETUP: begin
//				next_regs = insn[23] ? op1[15:0] : op1[0:15];
				/** verilator can suck my dick */
				$display("LDMSTM: Round 1: base register: %08x, reg list %b", op0, op1[15:0]);
				next_regs = insn[23] /* U */ ? op1[15:0] : {op1[0], op1[1], op1[2], op1[3], op1[4], op1[5], op1[6], op1[7],
				                                            op1[8], op1[9], op1[10], op1[11], op1[12], op1[13], op1[14], op1[15]};
				offset = 6'b0;
				outstall = 1'b1;
				next_lsm_state = `LSM_MEMIO;
			end
			4'b0010: begin
				rd_req = insn[20];
				wr_req = ~insn[20];
				casez(regs)
				16'b???????????????1: begin
					cur_reg = 4'h0;
					next_regs = {regs[15:1], 1'b0};
				end
				16'b??????????????10: begin
					cur_reg = 4'h1;
					next_regs = {regs[15:2], 2'b0};
				end
				16'b?????????????100: begin
					cur_reg = 4'h2;
					next_regs = {regs[15:3], 3'b0};
				end
				16'b????????????1000: begin
					cur_reg = 4'h3;
					next_regs = {regs[15:4], 4'b0};
				end
				16'b???????????10000: begin
					cur_reg = 4'h4;
					next_regs = {regs[15:5], 5'b0};
				end
				16'b??????????100000: begin
					cur_reg = 4'h5;
					next_regs = {regs[15:6], 6'b0};
				end
				16'b?????????1000000: begin
					cur_reg = 4'h6;
					next_regs = {regs[15:7], 7'b0};
				end
				16'b????????10000000: begin
					cur_reg = 4'h7;
					next_regs = {regs[15:8], 8'b0};
				end
				16'b???????100000000: begin
					cur_reg = 4'h8;
					next_regs = {regs[15:9], 9'b0};
				end
				16'b??????1000000000: begin
					cur_reg = 4'h9;
					next_regs = {regs[15:10], 10'b0};
				end
				16'b?????10000000000: begin
					cur_reg = 4'hA;
					next_regs = {regs[15:11], 11'b0};
				end
				16'b????100000000000: begin
					cur_reg = 4'hB;
					next_regs = {regs[15:12], 12'b0};
				end
				16'b???1000000000000: begin
					cur_reg = 4'hC;
					next_regs = {regs[15:13], 13'b0};
				end
				16'b??10000000000000: begin
					cur_reg = 4'hD;
					next_regs = {regs[15:14], 14'b0};
				end
				16'b?100000000000000: begin
					cur_reg = 4'hE;
					next_regs = {regs[15], 15'b0};
				end
				16'b1000000000000000: begin
					cur_reg = 4'hF;
					next_regs = 16'b0;
				end
				default: begin
					cur_reg = 4'hx;
					next_regs = 16'b0;
				end
				endcase
				cur_reg = insn[23] ? cur_reg : 4'hF - cur_reg;
				if(cur_reg == 4'hF && insn[22]) begin
					next_outcpsr = spsr;
					next_outcpsrup = 1;
				end

				offset = prev_offset + 6'h4;
				offset_sel = insn[24] ? offset : prev_offset;
				raddr = insn[23] ? op0 + {26'b0, offset_sel} : op0 - {26'b0, offset_sel};
				if(insn[20]) begin
					next_write_reg = !rw_wait;
					next_write_num = cur_reg;
					next_write_data = rd_data;
				end
				if (rw_wait) begin
					next_regs = regs;
					cur_reg = prev_reg;	/* whoops, do this one again */
				end

				st_read = cur_reg;
				wr_data = (cur_reg == 4'hF) ? (pc + 12) : st_data;
				busaddr = raddr;
				
				$display("LDMSTM: Stage 2: Writing: regs %b, next_regs %b, reg %d, wr_data %08x, addr %08x", regs, next_regs, cur_reg, wr_data, busaddr);

				outstall = 1'b1;

				if(next_regs == 16'b0) begin
					next_lsm_state = `LSM_BASEWB;
				end
			end
			`LSM_BASEWB: begin
				outstall = 1;
				next_outbubble = 0;
				next_write_reg = insn[21] /* writeback */;
				next_write_num = insn[19:16];
				next_write_data = insn[23] ? op0 + {26'b0, prev_offset} : op0 - {26'b0, prev_offset};
				next_lsm_state = `LSM_WBFLUSH;
				$display("LDMSTM: Stage 3: Writing back");
			end
			`LSM_WBFLUSH: begin
				outstall = 0;
				next_lsm_state = `LSM_SETUP;
			end
			default: $stop;
			endcase
			if ((lsm_state == `LSM_SETUP) && flush) begin	/* Reject it. */
				outstall = 1'b0;
				next_lsm_state = `LSM_SETUP;
			end
			$display("LDMSTM: Decoded, bubble %d, insn %08x, lsm state %b -> %b, stall %d", inbubble, insn, lsm_state, next_lsm_state, outstall);
		end
		`DECODE_LDCSTC: if(!inbubble) begin
			$display("WARNING: Unimplemented LDCSTC");
		end
		`DECODE_CDP: if(!inbubble) begin
			cp_req = 1;
			if (cp_busy) begin
				outstall = 1;
				next_outbubble = 1;
			end
			if (!cp_ack) begin
				/* XXX undefined instruction trap */
				$display("WARNING: Possible CDP undefined instruction");
			end
		end
		`DECODE_MRCMCR: if(!inbubble) begin
			cp_req = 1;
			cp_rnw = insn[20] /* L */;
			if (insn[20] == 0 /* store to coprocessor */)
				cp_write = op0;
			else begin
				if (insn[15:12] != 4'hF /* Fuck you ARM */) begin
					next_write_reg = 1'b1;
					next_write_num = insn[15:12];
					next_write_data = cp_read;
				end else begin
					next_outcpsr = {cp_read[31:28], cpsr[27:0]};
					next_outcpsrup = 1;
				end
			end
			if (cp_busy) begin
				outstall = 1;
				next_outbubble = 1;
			end
			if (!cp_ack) begin
				$display("WARNING: Possible MRCMCR undefined instruction: cp_ack %d, cp_busy %d",cp_ack, cp_busy);
			end
			$display("MRCMCR: ack %d, busy %d", cp_ack, cp_busy);
		end
		default: begin end
		endcase
		
		if ((flush || delayedflush) && !outstall)
			next_outbubble = 1'b1;
	end
endmodule
