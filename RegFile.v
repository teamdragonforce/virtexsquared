module RegFile(
	input clk,
	input Nrst,
	input [3:0] read_0,
	output wire [31:0] rdata_0,
	input [3:0] read_1,
	output wire [31:0] rdata_1,
	input [3:0] read_2,
	output wire [31:0] rdata_2,
	input [3:0] read_3,
	output wire [31:0] rdata_3,
	output wire [31:0] spsr,
	input write,
	input [3:0] write_reg,
	input [31:0] write_data
	);
	
	reg [31:0] regfile [0:15];
	integer i;
	
	initial begin
		for (i = 0; i < 16; i = i + 1)
			regfile[i] = 0;
	end
	
	assign rdata_0 = ((read_0 == write_reg) && write) ? write_data : regfile[read_0];
	assign rdata_1 = ((read_1 == write_reg) && write) ? write_data : regfile[read_1];
	assign rdata_2 = ((read_2 == write_reg) && write) ? write_data : regfile[read_2];
	assign rdata_3 = ((read_3 == write_reg) && write) ? write_data : regfile[read_3];
	assign spsr = regfile[4'hF];
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			for (i = 0; i < 16; i = i + 1)
				regfile[i] <= 0;
		end else if (write)
			regfile[write_reg] <= write_data;
endmodule
