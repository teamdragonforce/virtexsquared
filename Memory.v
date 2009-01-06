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
	output reg outbubble,
	output reg flush
);

	reg [31:0] addr, raddr;
	reg notdone = 1'b0;
	reg inc_next = 1'b0;
	wire [31:0] align_s1, align_s2, align_rddata;
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
		casez(insn)
		`DECODE_LDRSTR_UNDEFINED: begin end
		`DECODE_LDRSTR: begin
			addr = insn[23] ? base + offset : base - offset; /* up/down select */
			raddr = insn[24] ? base : addr;
			busaddr = {raddr[31:2], 2'b0}; /* pre/post increment */
			rd_req = insn[20];
			wr_req = ~insn[20];
			if(!insn[20]) begin /* store */
				st_read = insn[15:12];
				wr_data = insn[22] ? {4{st_data[7:0]}} : st_data;
			end
			else if(insn[15:12] == 4'hF)
				flush = 1'b1;
		end
		`DECODE_LDMSTM: begin
		end
		default: begin end
		endcase
	end

	assign align_s1 = raddr[1] ? {rd_data[15:0], rd_data[31:16]} : rd_data;
	assign align_s2 = raddr[0] ? {align_s1[7:0], align_s1[31:8]} : align_s1;
	assign align_rddata = insn[22] ? {24'b0, align_s2[7:0]} : align_s2;

	always @(posedge clk)
	begin
		outpc <= pc;
		outbubble <= rw_wait;
		casez(insn)
		`DECODE_LDRSTR_UNDEFINED: begin
			writeback <= 1'b0;
			regsel <= 4'hx;
			regdata <= 32'hxxxxxxxx;
			notdone <= 1'b0;
		end
		`DECODE_LDRSTR: begin
			if(insn[20] && !inc_next) begin /* load - delegate regfile write to writeback stage */
				if(insn[15:12] == 4'hF) begin
					newpc <= align_rddata;
				end
				else begin
					writeback <= 1'b1;
					regsel <= insn[15:12];
					regdata <= align_rddata;
				end
				inc_next <= 1'b1;
			end
			else if(insn[21]) begin /* write back */
				writeback <= 1'b1;
				regsel <= insn[19:16];
				regdata <= addr;
				inc_next <= 1'b0;
			end else begin
				writeback <= 1'b0;
				inc_next <= 1'b0;
				regsel <= 4'hx;
				regdata <= 32'hxxxxxxxx;
			end
			notdone <= rw_wait & insn[20] & insn[21];
		end
		`DECODE_LDMSTM: begin
		end
		default: begin
			writeback <= 1'b0;
			regsel <= 4'hx;
			regdata <= 32'hxxxxxxxx;
			notdone <= 1'b0;
		end
		endcase
	end

endmodule
