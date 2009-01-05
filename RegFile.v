module RegFile(
	input clk,
	input [3:0] read_0,
	output reg [31:0] rdata_0,
	input [3:0] read_1,
	output reg [31:0] rdata_1,
	input [3:0] read_2,
	output reg [31:0] rdata_2,
	output reg [31:0] spsr,
	input [3:0] write,
	input write_req,
	input [31:0] write_data
	);
	
	reg [31:0] regfile [0:15];
	
	initial begin
		regfile[4'h0] = 32'h00000005;
		regfile[4'h1] = 32'h00000050;
		regfile[4'h2] = 32'h00000500;
		regfile[4'h3] = 32'h00005000;
		regfile[4'h4] = 32'h00050000;
		regfile[4'h5] = 32'h00500000;
		regfile[4'h6] = 32'h05000000;
		regfile[4'h7] = 32'h50000000;
		regfile[4'h8] = 32'hA0000000;
		regfile[4'h9] = 32'h0A000000;
		regfile[4'hA] = 32'h00A00000;
		regfile[4'hB] = 32'h000A0000;
		regfile[4'hC] = 32'h0000A000;
		regfile[4'hD] = 32'h00000A00;
		regfile[4'hE] = 32'h000000A0;
		regfile[4'hF] = 32'h00000000;	/* Start off claiming we are in user mode. */
	end
	
	always @(*)
	begin
		if ((read_0 == write) && write_req)
			rdata_0 = write_data;
		else
			rdata_0 = regfile[read_0];
		
		if ((read_1 == write) && write_req)
			rdata_1 = write_data;
		else
			rdata_1 = regfile[read_1];
		
		if ((read_2 == write) && write_req)
			rdata_2 = write_data;
		else
			rdata_2 = regfile[read_2];
		
		spsr = regfile[4'hF];
	end
	
	always @(posedge clk)
		if (write_req)
			regfile[write] <= write_data;
endmodule
