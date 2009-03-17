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
	output reg [31:0] pc = 32'hFFFFFFFC);
	
	reg qjmp = 0;	/* A jump has been queued up while we were waiting. */
	reg [31:0] qjmppc;
	always @(posedge clk or negedge Nrst)
		if (!Nrst)
			qjmp <= 0;
		else if ((rd_wait || stall) && jmp)
			{qjmp,qjmppc} <= {jmp, jmppc};
		else if (!rd_wait && !stall && qjmp)	/* It has already been intoed. */
			{qjmp,qjmppc} <= {1'b0, 32'hxxxxxxxx};
	
	reg [31:0] reqpc;
	
	/* Output latch logic */
	assign rd_addr = reqpc;
	assign rd_req = 1;
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			bubble <= 1;
			insn <= 0;
			pc <= 32'h00000000;
		end else if (!stall) begin
			bubble <= (jmp || qjmp || rd_wait);
			insn <= rd_data;
			pc <= reqpc;
		end
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst)
			reqpc <= 0;
		else if (!stall && !rd_wait) begin
			if (qjmp)
				reqpc <= qjmppc;
			else if (jmp)
				reqpc <= jmppc;
			else
				reqpc <= reqpc + 4;
		end
endmodule
