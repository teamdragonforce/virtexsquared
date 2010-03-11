/* 16 cache entries, 64-byte long cache lines */

module DCache(
	input clk,
	
	/* ARM core interface */
	input [31:0] dc__addr_3a,
	input dc__rd_req_3a,
	input dc__wr_req_3a,
	output reg dc__rw_wait_3a,
	input [31:0] dc__wr_data_3a,
	output reg [31:0] dc__rd_data_3a,
	
	/* bus interface */
	output wire bus_req,
	input bus_ack,
	output reg [31:0] bus_addr = 0,
	input [31:0] bus_rdata,
	output reg [31:0] bus_wdata,
	output reg bus_rd = 0,
	output reg bus_wr = 0,
	input bus_ready);
	
	/* [31 tag 10] [9 cache index 6] [5 data index 0]
	 * so the data index is 6 bits long
	 * so the cache index is 4 bits long
	 * so the tag is 22 bits long. c.c
	 */
	
	reg cache_valid [15:0];
	reg [21:0] cache_tags [15:0];
	reg [31:0] cache_data [255:0 /* {line,word} */];

	integer i;	
	initial
		for (i = 0; i < 16; i = i + 1)
		begin
			cache_valid[i[3:0]] = 0;
			cache_tags[i[3:0]] = 0;
		end
	
	wire [5:0] didx = dc__addr_3a[5:0];
	wire [3:0] didx_word = didx[5:2];
	wire [3:0] idx = dc__addr_3a[9:6];
	wire [21:0] tag = dc__addr_3a[31:10];
	
	reg [31:0] prev_addr = 32'hFFFFFFFF;
	
	wire cache_hit = cache_valid[idx] && (cache_tags[idx] == tag);
	
	wire [31:0] curdata = cache_data[{idx,didx_word}];
	always @(*) begin
		dc__rw_wait_3a = (dc__rd_req_3a && !cache_hit) || (dc__wr_req_3a && (!bus_ack || !bus_ready));
		dc__rd_data_3a = curdata;
		if (!dc__rw_wait_3a && dc__rd_req_3a)
			$display("DCACHE: READ COMPLETE: Addr %08x, data %08x", dc__addr_3a, dc__rd_data_3a);
	end
	
	reg [3:0] cache_fill_pos = 0;
	assign bus_req = (dc__rd_req_3a && !cache_hit) || dc__wr_req_3a;
	always @(*)
	begin
		bus_rd = 0;
		bus_wr = 0;
		bus_addr = 0;
		bus_wdata = 0;
		if (dc__rd_req_3a && !cache_hit && bus_ack) begin
			bus_addr = {dc__addr_3a[31:6], cache_fill_pos[3:0], 2'b00 /* reads are 32-bits */};
			bus_rd = 1;
		end else if (dc__wr_req_3a && bus_ack) begin
			$display("DCACHE: WRITE REQUEST: Addr %08x, data %08x", dc__addr_3a, dc__wr_data_3a);
			bus_addr = dc__addr_3a;
			bus_wr = 1;
			bus_wdata = dc__wr_data_3a;
		end
	end
	
	always @(posedge clk) begin
		prev_addr <= {dc__addr_3a[31:6], 6'b0};
		if (dc__rd_req_3a && (cache_fill_pos != 0) && ((prev_addr != {dc__addr_3a[31:6], 6'b0}) || cache_hit))	/* If this wasn't from the same line, or we've moved on somehow, reset the fill circuitry. */
			cache_fill_pos <= 0;
		else if (dc__rd_req_3a && !cache_hit && bus_ready && bus_ack) begin	/* Started the fill, and we have data. */
			$display("DCACHE: FILL: rd addr %08x; bus addr %08x; bus data %08x, bus_req %d, bus_ack %d", dc__addr_3a, bus_addr, bus_rdata, bus_req, bus_ack);
			cache_fill_pos <= cache_fill_pos + 1;
			if (cache_fill_pos == 15) begin	/* Done? */
				cache_tags[idx] <= tag;
				cache_valid[idx] <= 1;
			end else
				cache_valid[idx] <= 0;
		end
		
		/* Split this out because XST is kind of silly about this sort of thing. */
		if ((dc__rd_req_3a && !cache_hit && bus_ready && bus_ack) || (dc__wr_req_3a && cache_hit))
			cache_data[dc__wr_req_3a ? {idx,dc__addr_3a[5:2]} : {idx,cache_fill_pos}] <= dc__wr_req_3a ? dc__wr_data_3a : bus_rdata;
	end
endmodule
