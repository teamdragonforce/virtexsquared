/* 16 cache entries, 64-byte long cache lines */

module DCache(
	input clk,
	
	/* ARM core interface */
	input      [31:0] dc__addr_3a,
	input             dc__rd_req_3a,
	input             dc__wr_req_3a,
	output reg        dc__rw_wait_3a,
	input      [31:0] dc__wr_data_3a,
	output reg [31:0] dc__rd_data_3a,

	/* bus interface */
	output reg                  fsabo_valid,
	output reg [FSAB_REQ_HI:0]  fsabo_mode,
	output reg [FSAB_DID_HI:0]  fsabo_did,
	output reg [FSAB_DID_HI:0]  fsabo_subdid,
	output reg [FSAB_ADDR_HI:0] fsabo_addr,
	output reg [FSAB_LEN_HI:0]  fsabo_len,
	output reg [FSAB_DATA_HI:0] fsabo_data,
	output reg [FSAB_MASK_HI:0] fsabo_mask,
	input                       fsabo_credit,
	
	input                       fsabi_valid,
	input      [FSAB_DID_HI:0]  fsabi_did,
	input      [FSAB_DID_HI:0]  fsabi_subdid,
	input      [FSAB_DATA_HI:0] fsabi_data);

 `include "fsab_defines.vh"
	
	/*** FSAB credit availability logic ***/
	
	/* This makes the assumption that all outbound transactions will be
	 * exactly one cycle long.  This is correct now, but if we move to a
	 * writeback cache, it will no longer be correct!
	 */
	
	reg [FSAB_CREDITS_HI:0] fsab_credits = FSAB_INITIAL_CREDITS;	/* XXX needs resettability */
	wire fsab_credit_avail = (fsab_credits != 0);
	always @(posedge clk)
		fsab_credits <= fsab_credits + (fsabo_credit ? 1 : 0) - (fsabo_valid ? 1 : 0);
	
	/* [31 tag 10] [9 cache index 6] [5 data index 0]
	 * so the data index is 6 bits long
	 * so the cache index is 4 bits long
	 * so the tag is 22 bits long. c.c
	 */
	
	reg cache_valid [15:0];
	reg [21:0] cache_tags [15:0];
	reg [31:0] cache_data_hi [127:0 /* {line,word} */];
	reg [31:0] cache_data_lo [127:0 /* {line,word} */];

	integer i;	
	initial
		for (i = 0; i < 16; i = i + 1)
		begin
			cache_valid[i[3:0]] = 0;
			cache_tags[i[3:0]] = 0;
		end
	
	wire [5:0] didx_3a = dc__addr_3a[5:0];
	wire [2:0] didx_word_3a = didx_3a[5:3];	/* bit 2 goes to the hi/lo index */
	wire [3:0] idx_3a = dc__addr_3a[9:6];
	wire [21:0] tag_3a = dc__addr_3a[31:10];
	
	reg [31:0] prev_addr = 32'hFFFFFFFF;
	
	wire cache_hit_3a = cache_valid[idx_3a] && (cache_tags[idx_3a] == tag_3a);
	
	wire [31:0] curdata_hi_3a = cache_data_hi[{idx_3a,didx_word_3a}];
	wire [31:0] curdata_lo_3a = cache_data_lo[{idx_3a,didx_word_3a}];
	always @(*) begin
		dc__rw_wait_3a = (dc__rd_req_3a && !cache_hit_3a) || (dc__wr_req_3a && !fsab_credit_avail);
		dc__rd_data_3a = dc__addr_3a[2] ? cache_data_hi : cache_data_lo;
		if (!dc__rw_wait_3a && dc__rd_req_3a)
			$display("DCACHE: READ COMPLETE: Addr %08x, data %08x", dc__addr_3a, dc__rd_data_3a);
	end
	
	reg [2:0] cache_fill_pos = 0;
	reg read_pending = 0;
	reg [31:0] fill_addr = 0;
	wire [21:0] fill_tag = fill_addr[31:10];
	wire [3:0] fill_idx = fill_addr[9:6];
	wire start_read = dc__rd_req_3a && !cache_hit_3a && !read_pending && fsab_credit_avail;
	always @(*)
	begin
		fsabo_valid = 0;
		fsabo_mode = {(FSAB_REQ_HI+1){1'bx}};
		fsabo_did = {(FSAB_DID_HI+1){1'bx}};
		fsabo_subdid = {(FSAB_DID_HI+1){1'bx}};
		fsabo_addr = {(FSAB_ADDR_HI+1){1'bx}};
		fsabo_len = {{FSAB_LEN_HI+1}{1'bx}};
		fsabo_data = {{FSAB_DATA_HI+1}{1'bx}};
		fsabo_mask = {{FSAB_MASK_HI+1}{1'bx}};
		
		/* At first glance, there can only be one request alive at a
		 * time, but that's not quite the case; there can
		 * potentially be multiple writes alive, since we don't
		 * block for the request to come back.  So, we do need to
		 * worry about credits.
		 */
		
		if (start_read) begin
			fsabo_valid = 1;
			fsabo_mode = FSAB_READ;
			fsabo_did = FSAB_DID_CPU;
			fsabo_subdid = FSAB_SUBDID_CPU_DCACHE;
			fsabo_addr = {dc__addr_3a[30:6], 3'b000, 3'b000 /* 64-bit aligned */};
			fsabo_len = 'h8; /* 64 byte cache lines, 8 byte reads */
		end else if (dc__wr_req_3a && fsab_credit_avail) begin
			fsabo_valid = 1;
			fsabo_mode = FSAB_WRITE;
			fsabo_did = FSAB_DID_CPU;
			fsabo_subdid = FSAB_SUBDID_CPU_DCACHE;
			fsabo_addr = {dc__addr_3a[30:3], 3'b000 /* 64-bit aligned */};
			fsabo_len = 'h1; /* one eight-byte write */
			fsabo_data = {dc__wr_data_3a, dc__wr_data_3a};
			fsabo_mask = dc__addr_3a[2] ? 8'hF0 : 8'h0F;
			$display("DCACHE: WRITE REQUEST: Addr %08x, data %08x", dc__addr_3a, dc__wr_data_3a);
		end
	end
	
	always @(posedge clk) begin
		if (start_read) begin
			read_pending <= 1;
			cache_fill_pos <= 0;
			fill_addr <= {dc__addr_3a[31:6], 6'b0};
		end else if (fsabi_valid && (fsabi_did == FSAB_DID_CPU) && (fsabi_subdid == FSAB_SUBDID_CPU_DCACHE)) begin
			$display("DCACHE: FILL: rd addr %08x; FSAB addr %08x; FSAB data %016x", dc__addr_3a, fill_addr, fsabi_data);
			
			cache_fill_pos <= cache_fill_pos + 1;
			if (cache_fill_pos == 7) begin	/* Done? */
				cache_tags[fill_idx] <= fill_tag;
				cache_valid[fill_idx] <= 1;
				read_pending <= 0;
			end else
				cache_valid[fill_idx] <= 0;
		end
		
		/* Split this out because XST is kind of silly about this sort of thing. */
		if ((fsabi_valid && (fsabi_did == FSAB_DID_CPU) && (fsabi_subdid == FSAB_SUBDID_CPU_DCACHE)) || (dc__wr_req_3a && cache_hit_3a && dc__addr_3a[2]))
			cache_data_hi[dc__wr_req_3a ? {idx_3a,dc__addr_3a[5:3]} : {fill_idx,cache_fill_pos}] <= dc__wr_req_3a ? dc__wr_data_3a : fsabi_data[63:32];
		if ((fsabi_valid && (fsabi_did == FSAB_DID_CPU) && (fsabi_subdid == FSAB_SUBDID_CPU_DCACHE)) || (dc__wr_req_3a && cache_hit_3a && ~dc__addr_3a[2]))
			cache_data_lo[dc__wr_req_3a ? {idx_3a,dc__addr_3a[5:3]} : {fill_idx,cache_fill_pos}] <= dc__wr_req_3a ? dc__wr_data_3a : fsabi_data[31:0];
	end
endmodule
