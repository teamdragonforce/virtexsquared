module Writeback(
	input clk,
	
	input inbubble,
	
	input write_reg,
	input [3:0] write_num,
	input [31:0] write_data,
	
	input [31:0] cpsr,
	input [31:0] spsr,
	input cpsrup,
	
	output reg regfile_write,
	output reg [3:0] regfile_write_reg,
	output reg [31:0] regfile_write_data,
	
	output reg [31:0] outcpsr,
	output reg [31:0] outspsr,
	
	output reg jmp,
	output reg [31:0] jmppc);
	
	reg [31:0] last_outcpsr = 0, last_outspsr = 0;
	
	always @(*)
		if (inbubble || !cpsrup)
			outcpsr = last_outcpsr;
		else
			outcpsr = cpsr;
	
	always @(*)
		if (inbubble || !cpsrup)
			outspsr = last_outspsr;
		else
			outspsr = spsr;
	
	always @(*)
	begin
		regfile_write = 0;
		regfile_write_reg = 4'hx;
		regfile_write_data = 32'hxxxxxxxx;
		jmp = 0;
		jmppc = 32'h00000000;
		if (!inbubble)
		begin
			if (write_reg && (write_num != 15))
			begin
				regfile_write = 1;
				regfile_write_reg = write_num;
				regfile_write_data = write_data;
			end else if (write_reg && (write_num == 15)) begin
				jmp = 1;
				jmppc = write_data;
			end
		end
	end
	
	always @(posedge clk)
	begin
		last_outspsr <= outspsr;
		last_outcpsr <= outcpsr;
	end
endmodule
