module Execute(
	input clk,
	input Nrst,	/* XXX not used yet */
	
	input stall,
	input flush,
	
	input inbubble,
	input [31:0] pc,
	input [31:0] insn,
	input [31:0] cpsr,
	input reg [31:0] op0,
	input reg [31:0] op1,
	input reg [31:0] op2,
	input reg carry,
	
	output reg outstall = 0,
	output reg outbubble = 1,
	);

	
	
endmodule
