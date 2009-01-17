/* 16 cache entries, 64-byte long cache lines */

module ICache(
	input clk,
	
	/* ARM core interface */
	input [31:0] rd_addr,
	input rd_req,
	output reg rd_wait,
	output reg [31:0] rd_data,
	
	/* bus interface */
	output wire bus_req,
	input bus_ack,
	output reg [31:0] bus_addr,
	input [31:0] bus_rdata,
	output wire [31:0] bus_wdata,
	output reg bus_rd,
	output wire bus_wr,
	input bus_ready);
	
	assign bus_wr = 0;
	assign bus_wdata = 0;
	
	/* [31 tag 10] [9 cache index 6] [5 data index 0]
	 * so the data index is 6 bits long
	 * so the cache index is 4 bits long
	 * so the tag is 22 bits long. c.c
	 */
	
	reg cache_valid [15:0];
	reg [21:0] cache_tags [15:0];
	reg [31:0] cache_data [15:0 /* line */] [15:0 /* word */];
	
	reg [4:0] i;
	initial
		for (i = 0; i < 16; i = i + 1)
		begin
			cache_valid[i[3:0]] = 0;
			cache_tags[i[3:0]] = 0;
		end
	
	wire [5:0] rd_didx = rd_addr[5:0];
	wire [3:0] rd_didx_word = rd_didx[5:2];
	wire [3:0] rd_idx = rd_addr[9:6];
	wire [21:0] rd_tag = rd_addr[31:10];
	
	reg [31:0] prev_rd_addr = 32'hFFFFFFFF;
	
	wire cache_hit = cache_valid[rd_idx] && (cache_tags[rd_idx] == rd_tag);
	
	always @(*) begin	/* XXX does this work nowadays? */
		rd_wait = rd_req && !cache_hit;
		rd_data = cache_data[rd_idx][rd_didx_word];
	end
	
	reg [3:0] cache_fill_pos = 0;
	assign bus_req = rd_req && !cache_hit; /* xxx, needed for Verilator */
	always @(*)
		if (rd_req && !cache_hit && bus_ack) begin
			bus_addr = {rd_addr[31:6], cache_fill_pos[3:0], 2'b00 /* reads are 32-bits */};
			bus_rd = 1;
		end else begin
			bus_addr = 0;
			bus_rd = 0;
		end
	
	always @(posedge clk) begin
		prev_rd_addr <= {rd_addr[31:6], 6'b0};
		if (cache_fill_pos != 0 && ((prev_rd_addr != {rd_addr[31:6], 6'b0}) || cache_hit))	/* If this wasn't from the same line, or we've moved on somehow, reset the fill circuitry. */
			cache_fill_pos <= 0;
		else if (rd_req && !cache_hit) begin
			if (bus_ack && bus_ready) begin	/* Started the fill, and we have data. */
				$display("ICACHE: FILL: rd addr %08x; bus addr %08x; bus data %08x", rd_addr, bus_addr, bus_rdata);
				cache_data[rd_idx][cache_fill_pos] <= bus_rdata;
				cache_fill_pos <= cache_fill_pos + 1;
				if (cache_fill_pos == 15) begin	/* Done? */
					cache_tags[rd_idx] <= rd_tag;
					cache_valid[rd_idx] <= 1;
					$display("ICACHE: Fill complete for line %x, tag %x", rd_idx, rd_tag);
				end else
					cache_valid[rd_idx] <= 0;
			end
		end
	end
endmodule
