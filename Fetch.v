module Fetch(
	input clk,
	input Nrst,
	
	output wire [31:0] rd_addr,
	output wire rd_req,
	input rd_wait,
	input [31:0] rd_data,
	
	input stall,
	input jmp,
	input [31:0] jmppc,
	output reg bubble = 1,
	output reg [31:0] insn = 0,
	output reg [31:0] pc = 0);

	reg [31:0] prevpc;
	reg [31:0] nextpc;
	initial
		prevpc = 32'hFFFFFFFC;	/* ugh... the first pc we request will be this +4 */
	always @(negedge Nrst)
		prevpc <= 32'hFFFFFFFC;

	always @(*)	
		if (!Nrst)
			nextpc = 32'hFFFFFFFC;
		else if (stall)	/* don't change any internal state */
			nextpc = prevpc;
		else if (jmp)
			nextpc = jmppc;
		else
			nextpc = prevpc + 32'h4;
	
	assign rd_addr = nextpc;
	assign rd_req = !stall;
			
	always @(posedge clk)
	begin
		if (!rd_wait || !Nrst)
			prevpc <= nextpc;
		if (!stall)
		begin
			bubble <= rd_wait;
			insn <= rd_data;
			pc <= nextpc;
		end
	end
endmodule
