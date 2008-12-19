/* 16 cache entries, 64-byte long cache lines */

module ICache(
	input clk,
	
	/* ARM core interface */
	input [31:0] rd_addr,
	input rd_req,
	output reg rd_wait,
	output reg [31:0] rd_data,
	
	/* bus interface */
	output reg bus_req,
	input bus_ack,
	output reg [31:0] bus_addr,
	input [31:0] bus_data
	output reg bus_rd,
	output wire bus_wr,
	input bus_ready);
	
	assign bus_wr = 0;
	
	/* [31 tag 10] [9 cache index 6] [5 data index 0]
	 * so the data index is 6 bits long
	 * so the cache index is 4 bits long
	 * so the tag is 22 bits long. c.c
	 */
	
	reg cache_valid [15:0];
	reg [21:0] cache_tags [15:0];
	reg [31:0] cache_data [15:0] [7:0];
	
	initial
		for (i = 0; i < 16; i = i + 1)
			cache_valid[i] <= 0;
	
	wire [5:0] rd_didx = rd_addr[5:0];
	wire [3:0] rd_didx_word = rd_didx[5:2];
	wire [3:0] rd_idx = rd_addr[9:6];
	wire [21:0] rd_tag = rd_addr[31:10];
	
	wire cache_hit = cache_valid[rd_idx] && (cache_tags[rd_idx] == rd_tag);
	
	always @(*) begin	/* XXX does this work nowadays? */
		rd_wait = !cache_hit;
		rd_data = cache_data[rd_idx][rd_didx_word];
	end
	
	reg [3:0] cache_fill_pos = 0;
	reg cache_filling = 0;
	always @(*) begin
		if (!cache_hit) begin
			bus_req = 1;
			if (bus_ack) begin
				bus_addr = {rd_addr[31:6], cache_fill_pos[3:0], 2'b00 /* reads are 32-bits */};
				bus_rd = 1;
			end
		end
endmodule
