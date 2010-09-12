module Fetch(
	input              clk,
	input              Nrst,
	
	output wire [31:0] ic__rd_addr_0a,
	output wire        ic__rd_req_0a,
	input              ic__rd_wait_0a,
	input       [31:0] ic__rd_data_1a,
	
	input              stall_0a,
	input              jmp_0a,
	input       [31:0] jmppc_0a,
	output reg         bubble_1a = 1,
	output reg  [31:0] insn_1a = 0,
	output reg  [31:0] pc_1a = 32'hFFFFFFFC);
	
	reg qjmp = 0;	/* A jump has been queued up while we were waiting. */
	reg [31:0] qjmppc;
	always @(posedge clk or negedge Nrst)
		if (!Nrst)
			qjmp <= 0;
		else if ((ic__rd_wait_0a || stall_0a) && jmp_0a)
			{qjmp,qjmppc} <= {jmp_0a, jmppc_0a};
		else if (!ic__rd_wait_0a && !stall_0a && qjmp)	/* It has already been intoed. */
			{qjmp,qjmppc} <= {1'b0, 32'hxxxxxxxx};
	
	reg [31:0] reqpc_0a;
	
	/* Output latch logic */
	reg [31:0] insn_2a;
	reg stall_1a;
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			insn_2a <= 32'h00000000;
			stall_1a <= 0;
		end else begin
			insn_2a <= insn_1a;
			stall_1a <= stall_0a;
		end
	
	always @(*)
		if (stall_1a)
			insn_1a = insn_2a;
		else
			insn_1a = ic__rd_data_1a;
	
	assign ic__rd_addr_0a = reqpc_0a;
	assign ic__rd_req_0a = 1;
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			bubble_1a <= 1;
			pc_1a <= 32'h00000000;
		end else if (!stall_0a) begin
			bubble_1a <= (jmp_0a || qjmp || ic__rd_wait_0a);
			pc_1a <= reqpc_0a;
		end
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst)
			reqpc_0a <= 0;
		else if (!stall_0a && !ic__rd_wait_0a) begin
			if (qjmp)
				reqpc_0a <= qjmppc;
			else if (jmp_0a)
				reqpc_0a <= jmppc_0a;
			else
				reqpc_0a <= reqpc_0a + 4;
		end
endmodule
