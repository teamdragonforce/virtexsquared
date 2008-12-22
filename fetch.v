module Fetch(
	input clk,
	input Nrst,
	
	output wire [31:0] rd_addr,
	output wire rd_req,
	input rd_wait,
	input [31:0] rd_data,
	
	input stall,
	input jmp,
	input [31:0] jmppc;
	output wire bubble,
	output wire [31:0] insn,
	output reg [31:0] pc);

	reg [31:0] prevpc;
	initial
		prevpc <= 32'h0;
	always @(negedge Nrst)
		prevpc <= 32'h0;
	
	always @(*)
		if (!Nrst)
			pc <= 32'h0;
		else if (stall)	/* don't change any internal state */
			pc <= prevpc;
		else if (jmp)
			pc <= jmppc;
		else
			pc <= prevpc + 32'h4;
	
	assign bubble = stall | rd_wait;
	assign rd_addr = pc;
	assign rd_req = !stall;
	assign insn = rd_data;
			
	always @(posedge clk)
		prevpc <= pc;
endmodule
