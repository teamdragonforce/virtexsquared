module BigBlockRAM(
	input clk,
	input [31:0] bus_addr,
	output wire [31:0] bus_rdata,
	input [31:0] bus_wdata,
	input bus_rd,
	input bus_wr,
	output wire bus_ready
	);
	
	/* This module is mapped in physical memory from 0x00000000 to
	 * 0x00800000.  rdata and ready must be driven to zero if the
	 * address is not within the range of this module.  There also
	 * exists a shadow up at 0x80000000.
	 */
	wire decode = bus_addr[30:23] == 8'b0;
	wire [22:0] ramaddr = {bus_addr[22:2], 2'b0};	/* mask off lower two bits
							 * for word alignment */

	reg [31:0] data [((8*1024*1024) / 4 - 1):0];
	
	reg [31:0] temprdata = 0;
	reg [22:0] lastread = 23'h7FFFFF;
	assign bus_rdata = (bus_rd && decode) ? temprdata : 32'h0;
	
	assign bus_ready = decode &&
		(bus_wr || (bus_rd && (lastread == ramaddr)));
	
	initial
		$readmemh("ram.hex", data);
	
	always @(posedge clk)
	begin
		if (bus_wr && decode)
			data[ramaddr[22:2]] = bus_wdata;
		
		/* This is not allowed to be conditional -- stupid Xilinx
		 * blockram. */
		temprdata <= data[ramaddr[22:2]];
		lastread <= ramaddr;
	end
endmodule
