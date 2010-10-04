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

	/* FSAB interface */
	output reg                  dc__fsabo_valid,
	output reg [FSAB_REQ_HI:0]  dc__fsabo_mode,
	output reg [FSAB_DID_HI:0]  dc__fsabo_did,
	output reg [FSAB_DID_HI:0]  dc__fsabo_subdid,
	output reg [FSAB_ADDR_HI:0] dc__fsabo_addr,
	output reg [FSAB_LEN_HI:0]  dc__fsabo_len,
	output reg [FSAB_DATA_HI:0] dc__fsabo_data,
	output reg [FSAB_MASK_HI:0] dc__fsabo_mask,
	input                       dc__fsabo_credit,
	
	input                       fsabi_valid,
	input      [FSAB_DID_HI:0]  fsabi_did,
	input      [FSAB_DID_HI:0]  fsabi_subdid,
	input      [FSAB_DATA_HI:0] fsabi_data,
	
	/* SPAM sidechannel interface */
	output reg                  spamo_valid,
	output reg                  spamo_r_nw,
	output reg [SPAM_DID_HI:0]  spamo_did,
	output reg [SPAM_ADDR_HI:0] spamo_addr,
	output reg [SPAM_DATA_HI:0] spamo_data,
	
	input                       spami_busy_b,
	input      [SPAM_DATA_HI:0] spami_data);

 `include "fsab_defines.vh"
 `include "spam_defines.vh"
	
	/*** FSAB credit availability logic ***/
	
	/* This makes the assumption that all outbound transactions will be
	 * exactly one cycle long.  This is correct now, but if we move to a
	 * writeback cache, it will no longer be correct!
	 */
	
	reg [FSAB_CREDITS_HI:0] fsab_credits = FSAB_INITIAL_CREDITS;	/* XXX needs resettability */
	wire fsab_credit_avail = (fsab_credits != 0);
	always @(posedge clk) begin
		if (dc__fsabo_credit | dc__fsabo_valid)
			$display("DCACHE: Credits: %d (+%d, -%d)", fsab_credits, dc__fsabo_credit, dc__fsabo_valid);
		fsab_credits <= fsab_credits + (dc__fsabo_credit ? 1 : 0) - (dc__fsabo_valid ? 1 : 0);
	end
	
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
	
	reg [2:0] cache_fill_pos = 0;
	reg read_pending = 0;
	reg [31:0] fill_addr = 0;
	wire [21:0] fill_tag = fill_addr[31:10];
	wire [3:0] fill_idx = fill_addr[9:6];
	wire start_read = dc__rd_req_3a && !dc__addr_3a[31] && !cache_hit_3a && !read_pending && fsab_credit_avail;
	always @(*)
	begin
		dc__fsabo_valid = 0;
		dc__fsabo_mode = {(FSAB_REQ_HI+1){1'bx}};
		dc__fsabo_did = {(FSAB_DID_HI+1){1'bx}};
		dc__fsabo_subdid = {(FSAB_DID_HI+1){1'bx}};
		dc__fsabo_addr = {(FSAB_ADDR_HI+1){1'bx}};
		dc__fsabo_len = {{FSAB_LEN_HI+1}{1'bx}};
		dc__fsabo_data = {{FSAB_DATA_HI+1}{1'bx}};
		dc__fsabo_mask = {{FSAB_MASK_HI+1}{1'bx}};
		
		/* At first glance, there can only be one request alive at a
		 * time, but that's not quite the case; there can
		 * potentially be multiple writes alive, since we don't
		 * block for the request to come back.  So, we do need to
		 * worry about credits.
		 */
		
		if (start_read) begin
			dc__fsabo_valid = 1;
			dc__fsabo_mode = FSAB_READ;
			dc__fsabo_did = FSAB_DID_CPU;
			dc__fsabo_subdid = FSAB_SUBDID_CPU_DCACHE;
			dc__fsabo_addr = {dc__addr_3a[30:6], 3'b000, 3'b000 /* 64-bit aligned */};
			dc__fsabo_len = 'h8; /* 64 byte cache lines, 8 byte reads */
			$display("DCACHE: Starting read: Addr %08x", dc__fsabo_addr);
		end else if (dc__wr_req_3a && fsab_credit_avail) begin
			dc__fsabo_valid = 1;
			dc__fsabo_mode = FSAB_WRITE;
			dc__fsabo_did = FSAB_DID_CPU;
			dc__fsabo_subdid = FSAB_SUBDID_CPU_DCACHE;
			dc__fsabo_addr = {dc__addr_3a[30:3], 3'b000 /* 64-bit aligned */};
			dc__fsabo_len = 'h1; /* one eight-byte write */
			dc__fsabo_data = {dc__wr_data_3a, dc__wr_data_3a};
			dc__fsabo_mask = dc__addr_3a[2] ? 8'hF0 : 8'h0F;
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
	
	/*** SPAM initiation logic ***/
	reg spam_intrans = 0;
	reg [7:0] spam_timeout = 0;
	
	always @(*) begin
		spamo_valid = 1'b0;
		spamo_r_nw = 1'bx;
		spamo_did = 4'hx;
		spamo_addr = 24'hxxxxxx;
		spamo_data = 32'hxxxxxxxx;
		if ((dc__rd_req_3a || dc__wr_req_3a) && dc__addr_3a[31] && !spam_intrans) begin
			spamo_valid = 1'b1;
			spamo_r_nw = dc__rd_req_3a;
			spamo_did = dc__addr_3a[27:24];
			spamo_addr = dc__addr_3a[23:0];
			spamo_data = dc__wr_req_3a ? dc__wr_data_3a : 'bx;
		end
	end
	
	always @(posedge clk) /* XXX reset */ begin
		if (spamo_valid) begin
			$display("SPAM: outbound valid");
			spam_intrans <= 1;
			spam_timeout <= 8'hFF;
		end else if (spami_busy_b || (spam_timeout == 0)) begin
			$display("SPAM: busy %d, timeout %d; done", spami_busy_b, spam_timeout);
			spam_intrans <= 0;
		end else if (spam_intrans)
			spam_timeout <= spam_timeout - 1;
	end
	
	/*** Overall processor databus multiplexing logic ***/
	always @(*) begin
		if (!dc__addr_3a[31]) /* FSAB */ begin
			dc__rw_wait_3a = (dc__rd_req_3a && !cache_hit_3a) || (dc__wr_req_3a && !fsab_credit_avail);
			dc__rd_data_3a = dc__addr_3a[2] ? curdata_hi_3a : curdata_lo_3a;
			if (!dc__rw_wait_3a && dc__rd_req_3a)
				$display("DCACHE: READ COMPLETE: Addr %08x, data %08x", dc__addr_3a, dc__rd_data_3a);
			if (dc__rd_req_3a && !cache_hit_3a)
				$display("DCACHE: Stalling due to cache miss (credits %d)", fsab_credits);
			if (dc__wr_req_3a && !fsab_credit_avail)
				$display("DCACHE: Stalling due to insufficient credits to write");
		end else /* SPAM */ begin
			dc__rw_wait_3a = !spami_busy_b && ((spam_intrans && (spam_timeout != 0)) || spamo_valid);
			dc__rd_data_3a = (spam_timeout == 0) ? 32'hDEADDEAD : spami_data;
		end
	end
endmodule
