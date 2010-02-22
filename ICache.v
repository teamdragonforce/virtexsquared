/* 16 cache entries, 64-byte long cache lines */

module ICache(
	input clk,
	
	/* ARM core interface */
	input       [31:0] ic__rd_addr_0a,
	input              ic__rd_req_0a,
	output wire        ic__rd_wait_0a,
	output wire [31:0] ic__rd_data_1a,
	
	/* bus interface */
	output wire        bus_req,
	input              bus_ack,
	output reg  [31:0] bus_addr,
	input       [31:0] bus_rdata,
	output wire [31:0] bus_wdata,
	output reg         bus_rd,
	output wire        bus_wr,
	input              bus_ready);
	
	assign bus_wr = 0;
	assign bus_wdata = 0;
	
	wire [31:0] rd_addr_0a;
	wire        rd_req_0a;
	reg         rd_wait_0a;
	reg  [31:0] rd_data_1a;
	assign ic__rd_wait_0a = rd_wait_0a;
	assign ic__rd_data_1a = rd_data_1a;
	assign rd_addr_0a = ic__rd_addr_0a;
	assign rd_req_0a = ic__rd_req_0a;
	
	/* [31 tag 10] [9 cache index 6] [5 data index 0]
	 * so the data index is 6 bits long
	 * so the cache index is 4 bits long
	 * so the tag is 22 bits long. c.c
	 */
	
	reg cache_valid [15:0];
	reg [21:0] cache_tags [15:0];
	reg [31:0] cache_data [255:0 /* {line, word} */];	//synthesis attribute ram_style of cache_data is distributed
	
	integer i;
	initial
		for (i = 0; i < 16; i = i + 1)
		begin
			cache_valid[i[3:0]] = 0;
			cache_tags[i[3:0]] = 0;
		end
	
	wire  [5:0] rd_didx_0a      = rd_addr_0a[5:0];
	wire  [3:0] rd_didx_word_0a = rd_didx_0a[5:2];
	wire  [3:0] rd_idx_0a       = rd_addr_0a[9:6];
	wire [21:0] rd_tag_0a       = rd_addr_0a[31:10];
	
	reg  [31:0] rd_addr_1a = 32'hFFFFFFFF;
	
	wire cache_hit_0a = cache_valid[rd_idx_0a] && (cache_tags[rd_idx_0a] == rd_tag_0a);
	
	reg [3:0] cache_fill_pos_0a = 0;
	assign bus_req = rd_req_0a && !cache_hit_0a; /* xxx, needed for Verilator */
	always @(*)
		if (rd_req_0a && !cache_hit_0a && bus_ack) begin
			bus_addr = {rd_addr_0a[31:6], cache_fill_pos_0a[3:0], 2'b00 /* reads are 32-bits */};
			bus_rd = 1;
		end else begin
			bus_addr = 0;
			bus_rd = 0;
		end

	always @(*) begin
		rd_wait_0a = rd_req_0a && !cache_hit_0a;
	end
	
	always @(posedge clk) begin
		// Do the actual read.
		rd_data_1a <= cache_data[{rd_idx_0a,rd_didx_word_0a}];
		
		rd_addr_1a <= {rd_addr_0a[31:6], 6'b0};
		if (cache_fill_pos_0a != 0 && ((rd_addr_1a != {rd_addr_0a[31:6], 6'b0}) || cache_hit_0a))	/* If this wasn't from the same line, or we've moved on somehow, reset the fill circuitry. */
			cache_fill_pos_0a <= 0;
		else if (rd_req_0a && !cache_hit_0a && bus_ack && bus_ready) begin
			$display("ICACHE: FILL: rd addr %08x; bus addr %08x; bus data %08x", rd_addr_0a, bus_addr, bus_rdata);
			cache_data[{rd_idx_0a,cache_fill_pos_0a}] <= bus_rdata;
			cache_fill_pos_0a <= cache_fill_pos_0a + 1;
			if (cache_fill_pos_0a == 15) begin	/* Done? */
				cache_tags[rd_idx_0a] <= rd_tag_0a;
				cache_valid[rd_idx_0a] <= 1;
				$display("ICACHE: Fill complete for line %x, tag %x", rd_idx_0a, rd_tag_0a);
			end else
				cache_valid[rd_idx_0a] <= 0;
		end
	end
endmodule
