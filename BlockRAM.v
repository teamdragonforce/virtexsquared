module BlockRAM(
	input clk,
	input [31:0] bus_addr,
	output wire [31:0] bus_rdata,
	input [31:0] bus_wdata,
	input bus_rd,
	input bus_wr,
	output wire bus_ready
	);
	
	/* This module is mapped in physical memory from 0x00000000 to
	 * 0x00004000.  rdata and ready must be driven to zero if the
	 * address is not within the range of this module.
	 */
	wire decode = (bus_addr & ~32'h00003FFF) == 32'h00000000;
	/* verilator lint_off WIDTH */
	wire [13:2] ramaddr = bus_addr & 32'h3FFC;	/* mask off lower two bits
							 * for word alignment */
	/* verilator lint_on WIDTH */
	
	reg [31:0] data [0:(16384 / 4 - 1)];
	
	reg [31:0] temprdata;
	reg [13:2] lastread;
	assign bus_rdata = (bus_rd && decode) ? temprdata : 32'h0;
	
	assign bus_ready = decode &&
		(bus_wr || (bus_rd && (lastread == ramaddr)));
	
	always @(posedge clk)
	begin
		if (bus_wr && decode)
			data[ramaddr] <= bus_wdata;
		
		/* This is not allowed to be conditional -- stupid Xilinx
		 * blockram. */
		temprdata <= data[ramaddr];
		lastread <= ramaddr;
	end
endmodule
