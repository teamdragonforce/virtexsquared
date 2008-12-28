module Execute(
	input clk,
	input Nrst,	/* XXX not used yet */
	
	input stall,
	input flush,
	
	input inbubble,
	input [31:0] pc,
	input [31:0] insn,
	input [31:0] cpsr,
	input [31:0] op0,
	input [31:0] op1,
	input [31:0] op2,
	input carry,
	
	output reg outstall = 0,
	output reg outbubble = 1
	);
	
endmodule

module Multiplier(
	input clk,
	input Nrst,	/* XXX not used yet */
	
	input start,
	input [31:0] acc0,
	input [31:0] in0,
	input [31:0] in1,
	
	output reg done = 0,
	output reg [31:0] result);
	
	reg [31:0] bitfield;
	reg [31:0] multiplicand;
	reg [31:0] acc;
	
	always @(posedge clk)
	begin
		if (start) begin
			bitfield <= in0;
			multiplicand <= in1;
			acc <= acc0;
			done <= 0;
		end else begin
			bitfield <= {2'b00, bitfield[31:2]};
			multiplicand <= {multiplicand[29:0], 2'b00};
			acc <= acc +
				(bitfield[0] ? multiplicand : 0) +
				(bitfield[1] ? {multiplicand[30:0], 1'b0} : 0);
			if (bitfield == 0) begin
				result <= acc;
				done <= 1;
			end
		end
	end
endmodule
