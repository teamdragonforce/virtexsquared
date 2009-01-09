module Terminal(
	input clk,
	
	input cp_req,
	input [31:0] cp_insn,
	output reg cp_ack,
	output reg cp_busy,
	input cp_rnw,
	output reg [31:0] cp_read = 0,
	input [31:0] cp_write);
	
	/* Terminal pretends to be cp5. */
	reg towrite = 0;
	reg [7:0] data = 0;
	
	always @(*)
	begin
		towrite = 0;
		data = 8'hxx;
		cp_ack = 0;
		cp_busy = 0;
		if (cp_req && (cp_rnw == 0) && (cp_insn[27:24] == 4'b1110) && (cp_insn[19:16] == 4'b0000) && (cp_insn[11:8] == 4'h5))
		begin
			towrite = 1;
			data = cp_write[7:0];
			cp_ack = 1;
		end
	end
	
	always @(posedge clk)
		if (towrite)
			$c("{extern void term_output(unsigned char d); term_output(",data,");}");
endmodule
