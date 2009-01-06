`include "ARM_Constants.v"

module Memory(
	input clk,
	input Nrst,
	input [31:0] pc,
	input [31:0] insn,
	input [31:0] base,
	input [31:0] offset,

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

	/* writeback to base */
	output reg writeback,
	output reg [3:0] regsel,
	output reg [31:0] regdata,

	/* pc stuff */
	output reg [31:0] outpc,
	output reg [31:0] newpc,

	/* stall */
	output outstall,
	output reg outbubble
);

	reg [31:0] addr, raddr, next_regdata, next_newpc;
	reg [3:0] next_regsel;
	reg next_writeback, next_notdone, next_inc_next;
	reg [31:0] align_s1, align_s2, align_rddata;

	reg notdone = 1'b0;
	reg inc_next = 1'b0;
	assign outstall = rw_wait | notdone;

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
		next_regsel = 4'hx;
		next_regdata = 32'hxxxxxxxx;
		next_inc_next = 1'b0;
		next_newpc = 32'hxxxxxxxx;
		casez(insn)
		`DECODE_LDRSTR_UNDEFINED: begin end
		`DECODE_LDRSTR: begin
			addr = insn[23] ? base + offset : base - offset; /* up/down select */
			raddr = insn[24] ? base : addr;
			busaddr = {raddr[31:2], 2'b0}; /* pre/post increment */
			rd_req = insn[20];
			wr_req = ~insn[20];

			align_s1 = raddr[1] ? {rd_data[15:0], rd_data[31:16]} : rd_data;
			align_s2 = raddr[0] ? {align_s1[7:0], align_s1[31:8]} : align_s1;
			align_rddata = insn[22] ? {24'b0, align_s2[7:0]} : align_s2;

			if(!insn[20]) begin
				st_read = insn[15:12];
				wr_data = insn[22] ? {4{st_data[7:0]}} : st_data;
			end
			else if(!inc_next) begin /* store */
				next_writeback = 1'b1;
				next_regsel = insn[15:12];
				next_regdata = align_rddata;
				next_inc_next = 1'b1;
			end
			else if(insn[21]) begin
				next_writeback = 1'b1;
				next_regsel = insn[19:16];
				next_regdata = addr;
			end
			next_notdone = rw_wait & insn[20] & insn[21];
		end
		`DECODE_LDMSTM: begin
		end
		default: begin end
		endcase
	end


	always @(posedge clk)
	begin
		outpc <= pc;
		outbubble <= rw_wait;
		writeback <= next_writeback;
		regsel <= next_regsel;
		regdata <= next_regdata;
		notdone <= next_notdone;
		newpc <= next_newpc;
		inc_next <= next_inc_next;
	end

endmodule
