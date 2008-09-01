/* 16 cache entries, 64-byte long cache lines */

module ICache(
	input clk,
	input [31:0] rd_addr,
	input rd_req,
	output reg rd_wait,
	output reg [31:0] rd_data);
	
	/* [31 tag 11] [10 cache index 7] [5 data index 0]
	 * so the data index is 6 bits long
	 * so the cache index is 4 bits long
	 * so the tag is 21 bits long. c.c
	 */
	
	reg cache_valid [15:0];
	reg [20:0] cache_tags [15:0];
	reg [31:0] cache_data [15:0] [7:0];
	
	initial
		for (i = 0; i < 16; i = i + 1)
			cache_valid[i] <= 0;
	
	wire [5:0] rd_didx = rd_addr[5:0];
	wire [3:0] rd_didx_word = rd_didx[5:2];
	wire [3:0] rd_idx = rd_addr[10:7];
	wire [20:0] rd_tag = rd_addr[31:11];
	
	always @(*) begin	/* XXX does this work nowadays? */
		rd_wait = !(cache_valid[rd_idx] && (cache_tags[rd_idx] == rd_tag));
		rd_data = cache_data[rd_idx][rd_didx_word];
	end
endmodule
