/* 16 cache entries, 64-byte long cache lines */

module DCache(
	input clk,
	
	/* ARM core interface */
	input [31:0] addr,
	input rd_req,
	input wr_req,
	output reg rw_wait,
	input [31:0] wr_data,
	output reg [31:0] rd_data,
	
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
	reg [31:0] cache_data [15:0 /* line */] [15:0 /* word */];
	
	reg [4:0] i;
	initial
		for (i = 0; i < 16; i = i + 1)
		begin
			cache_valid[i[3:0]] = 0;
			cache_tags[i[3:0]] = 0;
		end
	
	wire [5:0] didx = addr[5:0];
	wire [3:0] didx_word = didx[5:2];
	wire [3:0] idx = addr[9:6];
	wire [21:0] tag = addr[31:10];
	
	reg [31:0] prev_addr = 32'hFFFFFFFF;
	
	wire cache_hit = cache_valid[idx] && (cache_tags[idx] == tag);
	
	always @(*) begin
		rw_wait = (rd_req && !cache_hit) || (wr_req && (!bus_ack || !bus_ready));
		rd_data = cache_data[idx][didx_word];
		if (!rw_wait && rd_req)
			$display("DCACHE: READ COMPLETE: Addr %08x, data %08x", addr, rd_data);
	end
	
	reg [3:0] cache_fill_pos = 0;
	assign bus_req = (rd_req && !cache_hit) || wr_req;
	always @(*)
	begin
		bus_rd = 0;
		bus_wr = 0;
		bus_addr = 0;
		bus_wdata = 0;
		if (rd_req && !cache_hit && bus_ack) begin
			bus_addr = {addr[31:6], cache_fill_pos[3:0], 2'b00 /* reads are 32-bits */};
			bus_rd = 1;
		end else if (wr_req && bus_ack) begin
			$display("DCACHE: WRITE REQUEST: Addr %08x, data %08x, wait %d", addr, wr_data, rw_wait);
			bus_addr = addr;
			bus_wr = 1;
			bus_wdata = wr_data;
		end
	end
	
	always @(posedge clk) begin
		prev_addr <= {addr[31:6], 6'b0};
		if (rd_req && (cache_fill_pos != 0) && ((prev_addr != {addr[31:6], 6'b0}) || cache_hit))	/* If this wasn't from the same line, or we've moved on somehow, reset the fill circuitry. */
			cache_fill_pos <= 0;
		else if (rd_req && !cache_hit) begin
			if (bus_ready && bus_ack) begin	/* Started the fill, and we have data. */
				$display("DCACHE: FILL: rd addr %08x; bus addr %08x; bus data %08x, bus_req %d, bus_ack %d", addr, bus_addr, bus_rdata, bus_req, bus_ack);
				cache_data[idx][cache_fill_pos] <= bus_rdata;
				cache_fill_pos <= cache_fill_pos + 1;
				if (cache_fill_pos == 15) begin	/* Done? */
					cache_tags[idx] <= tag;
					cache_valid[idx] <= 1;
				end else
					cache_valid[idx] <= 0;
			end
		end else if (wr_req && cache_hit)
			cache_data[idx][addr[5:2]] = wr_data;
	end
endmodule
