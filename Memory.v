`include "ARM_Constants.v"

module Memory(
	input clk,
	input Nrst,

	/* bus interface */
	output reg [31:0] busaddr,
	output reg rd_req,
	output reg wr_req,
	input rw_wait,
	output reg [31:0] wr_data,
	input [31:0] rd_data,

	/* regfile interface */
	output reg [3:0] st_read,
	input [31:0] st_data,
	
	/* Coprocessor interface */
	output reg cp_req,
	input cp_ack,
	input cp_busy,
	
	/* stage inputs */
	input inbubble,
	input [31:0] pc,
	input [31:0] insn,
	input [31:0] op0,
	input [31:0] op1,
	input [31:0] op2,
	input [31:0] spsr,
	input [31:0] cpsr,
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
	output reg [31:0] out_spsr = 32'hxxxxxxxx,
	output reg [31:0] out_cpsr = 32'hxxxxxxxx
	);

	reg [31:0] addr, raddr, prev_raddr, next_regdata, next_outcpsr;
	reg [3:0] next_regsel, cur_reg, prev_reg;
	reg next_writeback, next_notdone, next_inc_next;
	reg [31:0] align_s1, align_s2, align_rddata;

	wire next_outbubble;	
	wire next_write_reg;
	wire [3:0] next_write_num;
	wire [31:0] next_write_data;

	reg [15:0] regs, next_regs;
	reg started = 1'b0, next_started;
	reg [5:0] offset, prev_offset, offset_sel;

	reg notdone = 1'b0;
	reg inc_next = 1'b0;

	always @(posedge clk)
	begin
		outpc <= pc;
		outinsn <= insn;
		outbubble <= next_outbubble;
		out_write_reg <= next_write_reg;
		out_write_num <= next_write_num;
		out_write_data <= next_write_data;
		notdone <= next_notdone;
		inc_next <= next_inc_next;
		regs <= next_regs;
		prev_reg <= cur_reg;
		started <= next_started;
		prev_offset <= offset;
		prev_raddr <= raddr;
		out_cpsr <= next_outcpsr;
		out_spsr <= spsr;
	end

	always @(*)
	begin
		addr = 32'hxxxxxxxx;
		raddr = 32'hxxxxxxxx;
		rd_req = 1'b0;
		wr_req = 1'b0;
		wr_data = 32'hxxxxxxxx;
		busaddr = 32'hxxxxxxxx;
		outstall = 1'b0;
		next_notdone = 1'b0;
		next_write_reg = write_reg;
		next_write_num = write_num;
		next_write_data = write_data;
		next_inc_next = 1'b0;
		next_outbubble = inbubble;
		outstall = 1'b0;
		next_regs = 16'b0;
		next_started = started;
		cp_req = 1'b0;
		offset = prev_offset;
		next_outcpsr = started ? out_cpsr : cpsr;

		casez(insn)
		`DECODE_LDRSTR_UNDEFINED: begin end
		`DECODE_LDRSTR: begin
			if (!inbubble) begin
				next_outbubble = rw_wait;
				outstall = rw_wait | notdone;
			
				addr = insn[23] ? op0 + op1 : op0 - op1; /* up/down select */
				raddr = insn[24] ? op0 : addr; /* pre/post increment */
				busaddr = {raddr[31:2], 2'b0};
				rd_req = insn[20];
				wr_req = ~insn[20];
				
				/* rotate to correct position */
				align_s1 = raddr[1] ? {rd_data[15:0], rd_data[31:16]} : rd_data;
				align_s2 = raddr[0] ? {align_s1[7:0], align_s1[31:8]} : align_s1;
				/* select byte or word */
				align_rddata = insn[22] ? {24'b0, align_s2[7:0]} : align_s2;
				
				if(!insn[20]) begin
					wr_data = insn[22] ? {4{op2[7:0]}} : op2; /* XXX need to actually store just a byte */
				end
				else if(!inc_next) begin
					next_write_reg = 1'b1;
					next_write_num = insn[15:12];
					next_write_data = align_rddata;
					next_inc_next = 1'b1;
				end
				else if(insn[21]) begin
					next_write_reg = 1'b1;
					next_write_num = insn[19:16];
					next_write_data = addr;
				end
				next_notdone = rw_wait & insn[20] & insn[21];
			end
		end
		`DECODE_LDMSTM: begin
			rd_req = insn[20];
			wr_req = ~insn[20];
			if(!started) begin
//				next_regs = insn[23] ? op1[15:0] : op1[0:15];
				/** verilator can suck my dick */
				next_regs = insn[23] ? op1[15:0] : {op1[0], op1[1], op1[2], op1[3], op1[4], op1[5], op1[6], op1[7],
				                                    op1[8], op1[9], op1[10], op1[11], op1[12], op1[13], op1[14], op1[15]};
				offset = 6'b0;
				next_started = 1'b1;
			end
			else if(inc_next) begin
				if(insn[21]) begin
					next_write_reg = 1'b1;
					next_write_num = insn[19:16];
					next_write_data = insn[23] ? op0 + {26'b0, prev_offset} : op0 - {26'b0, prev_offset};
				end
				next_started = 1'b0;
			end
			else if(rw_wait) begin
				next_regs = regs;
				cur_reg = prev_reg;
				raddr = prev_raddr;
			end
			else begin
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
				cur_reg = insn[23] ? 4'hF - cur_reg : cur_reg;
				if(cur_reg == 4'hF && insn[22]) begin
					next_outcpsr = spsr;
				end
				offset = prev_offset + 6'h4;
				offset_sel = insn[24] ? offset : prev_offset;
				raddr = insn[23] ? op0 + {26'b0, offset_sel} : op0 - {26'b0, offset_sel};

				if(insn[20]) begin
					next_write_reg = 1'b1;
					next_write_num = cur_reg;
					next_write_data = rd_data;
				end

				st_read = cur_reg;
				wr_data = st_data;

				next_inc_next = next_regs == 16'b0;
				next_notdone = ~next_inc_next | rw_wait;
				busaddr = {raddr[31:2], 2'b0};
			end
		end
		default: begin end
		endcase
	end
endmodule
