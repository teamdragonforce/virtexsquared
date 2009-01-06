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
	
	/* stage inputs */
	input inbubble,
	input [31:0] pc,
	input [31:0] insn,
	input [31:0] op0,
	input [31:0] op1,
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
	output reg [31:0] out_write_data = 32'hxxxxxxxx
	);

	reg [31:0] addr, raddr, next_regdata;
	reg [3:0] next_regsel;
	reg next_writeback, next_notdone, next_inc_next;
	reg [31:0] align_s1, align_s2, align_rddata;
	
	wire next_write_reg;
	wire [3:0] next_write_num;
	wire [31:0] next_write_data;

	reg [15:0] regs, next_regs;

	reg notdone = 1'b0;
	reg inc_next = 1'b0;

	always @(posedge clk)
	begin
		outpc <= pc;
		outinsn <= insn;
		outbubble <= rw_wait;
		out_write_reg <= next_writeback;
		out_write_num <= next_regsel;
		out_write_data <= next_regdata;
		notdone <= next_notdone;
		inc_next <= next_inc_next;
		regs <= next_regs;
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
		outstall = 1'b0;
		next_regs = 16'b0;

		casez(insn)
		`DECODE_LDRSTR_UNDEFINED: begin end
		`DECODE_LDRSTR: begin
			if (!inbubble) begin
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
					st_read = insn[15:12];
					wr_data = insn[22] ? {4{st_data[7:0]}} : st_data; /* XXX need to actually store just a byte */
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
			busaddr = {op0[31:2], 2'b0};
			rd_req = insn[20];
			wr_req = ~insn[20];
			if(inc_next) begin
			end
			else if(rw_wait)
				next_regs = regs;
			else begin
				casez(regs)
				16'b???????????????1: begin
					next_regs = regs & 16'b1111111111111110;
				end
				16'b??????????????10: begin
					next_regs = regs & 16'b1111111111111100;
				end
				16'b?????????????100: begin
					next_regs = regs & 16'b1111111111111000;
				end
				16'b????????????1000: begin
					next_regs = regs & 16'b1111111111110000;
				end
				16'b???????????10000: begin
					next_regs = regs & 16'b1111111111100000;
				end
				16'b??????????100000: begin
					next_regs = regs & 16'b1111111111000000;
				end
				16'b?????????1000000: begin
					next_regs = regs & 16'b1111111110000000;
				end
				16'b????????10000000: begin
					next_regs = regs & 16'b1111111100000000;
				end
				16'b???????100000000: begin
					next_regs = regs & 16'b1111111000000000;
				end
				16'b??????1000000000: begin
					next_regs = regs & 16'b1111110000000000;
				end
				16'b?????10000000000: begin
					next_regs = regs & 16'b1111100000000000;
				end
				16'b????100000000000: begin
					next_regs = regs & 16'b1111000000000000;
				end
				16'b???1000000000000: begin
					next_regs = regs & 16'b1110000000000000;
				end
				16'b??10000000000000: begin
					next_regs = regs & 16'b1100000000000000;
				end
				16'b?100000000000000: begin
					next_regs = regs & 16'b1000000000000000;
				end
				16'b1000000000000000: begin
					next_regs = 16'b0;
				end
				default: begin
				end
				endcase
				next_inc_next = next_regs == 16'b0;
				next_notdone = ~next_inc_next;
			end
		end
		default: begin end
		endcase
	end
endmodule
