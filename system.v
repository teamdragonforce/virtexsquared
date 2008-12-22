`define BUS_ICACHE 0

module System();
	wire [7:0] bus_req;
	wire [7:0] bus_ack;
	wire [31:0] bus_addr;
	wire [31:0] bus_data;
	wire bus_rd, bus_wr;
	wire bus_ready;
	
	wire bus_req_icache = bus_req[`BUS_ICACHE];
	wire bus_ack_icache = bus_ack[`BUS_ICACHE];
	wire [31:0] bus_addr_icache;
	wire [31:0] bus_wdata_icache;
	wire bus_rd_icache;
	wire bus_wr_icache;
	
	assign bus_addr = bus_addr_icache;
	assign bus_data = bus_wdata_icache;
	assign bus_rd = bus_rd_icache;
	assign bus_wr = bus_wr_icache;

	BusArbiter busarbiter(.bus_req(bus_req), .bus_ack(bus_ack));
	ICache(
		.rd_addr(), .rd_req(), .rd_wait(), .rd_data(),
		.bus_req(bus_req_icache), .bus_ack(bus_ack_icache),
		.bus_addr(bus_addr_icache), .bus_rdata(bus_data),
		.bus_wdata(bus_wdata_icache), .bus_rd(bus_rd_icache),
		.bus_wr(bus_wr_icache), .bus_ready(bus_ready));
endmodule
