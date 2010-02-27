module RegFile(
	input              clk,
	input              Nrst,
	input        [3:0] rf__read_0_1a,
	output wire [31:0] rf__rdata_0_1a,
	input        [3:0] rf__read_1_1a,
	output wire [31:0] rf__rdata_1_1a,
	input        [3:0] rf__read_2_1a,
	output wire [31:0] rf__rdata_2_1a,
	input        [3:0] rf__read_3_4a,
	output wire [31:0] rf__rdata_3_4a,
	output wire [31:0] spsr,
	input              write,
	input        [3:0] write_reg,
	input       [31:0] write_data
	);
	
	reg [31:0] regfile [0:15];
	integer i;
	
	initial begin
		for (i = 0; i < 16; i = i + 1)
			regfile[i] = 0;
	end
	
	assign rf__rdata_0_1a = ((rf__read_0_1a == write_reg) && write) ? write_data : regfile[rf__read_0_1a];
	assign rf__rdata_1_1a = ((rf__read_1_1a == write_reg) && write) ? write_data : regfile[rf__read_1_1a];
	assign rf__rdata_2_1a = ((rf__read_2_1a == write_reg) && write) ? write_data : regfile[rf__read_2_1a];
	assign rf__rdata_3_4a = ((rf__read_3_4a == write_reg) && write) ? write_data : regfile[rf__read_3_4a];
	assign spsr = regfile[4'hF];
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			for (i = 0; i < 16; i = i + 1)
				regfile[i] <= 0;
		end else if (write)
			regfile[write_reg] <= write_data;
endmodule
