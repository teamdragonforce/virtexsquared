/* 16 cache entries, 64-byte long cache lines */

module ICache(/*AUTOARG*/
   // Outputs
   ic__rd_wait_0a, ic__rd_data_1a, ic__fsabo_valid, ic__fsabo_mode,
   ic__fsabo_did, ic__fsabo_subdid, ic__fsabo_addr, ic__fsabo_len,
   ic__fsabo_data, ic__fsabo_mask,
   // Inputs
   clk, rst_b, ic__rd_addr_0a, ic__rd_req_0a, ic__fsabo_credit,
   fsabi_valid, fsabi_did, fsabi_subdid, fsabi_data
   );
	`include "fsab_defines.vh"

	input clk;
	input rst_b;
	
	/* arm core interface */
	input       [31:0] ic__rd_addr_0a;
	input              ic__rd_req_0a;
	output reg         ic__rd_wait_0a;
	output reg  [31:0] ic__rd_data_1a;
	
	/* bus interface */
	output reg                  ic__fsabo_valid;
	output reg [FSAB_REQ_HI:0]  ic__fsabo_mode;
	output reg [FSAB_DID_HI:0]  ic__fsabo_did;
	output reg [FSAB_DID_HI:0]  ic__fsabo_subdid;
	output reg [FSAB_ADDR_HI:0] ic__fsabo_addr;
	output reg [FSAB_LEN_HI:0]  ic__fsabo_len;
	output reg [FSAB_DATA_HI:0] ic__fsabo_data;
	output reg [FSAB_MASK_HI:0] ic__fsabo_mask;
	input                       ic__fsabo_credit;
	
	input                       fsabi_valid;
	input      [FSAB_DID_HI:0]  fsabi_did;
	input      [FSAB_DID_HI:0]  fsabi_subdid;
	input      [FSAB_DATA_HI:0] fsabi_data;

	/*** FSAB credit availability logic ***/
	
	/* This makes the assumption that all outbound transactions will be
	 * exactly one cycle long.  This is correct now, but if we move to a
	 * writeback cache, it will no longer be correct!
	 */
	
	reg [FSAB_CREDITS_HI:0] fsab_credits = FSAB_INITIAL_CREDITS;
	wire fsab_credit_avail = (fsab_credits != 0);
	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			fsab_credits <= FSAB_INITIAL_CREDITS;
		end else begin
			if (ic__fsabo_credit | ic__fsabo_valid)
				$display("ICACHE: Credits: %d (+%d, -%d)", fsab_credits, ic__fsabo_credit, ic__fsabo_valid);
			fsab_credits <= fsab_credits + (ic__fsabo_credit ? 1 : 0) - (ic__fsabo_valid ? 1 : 0);
		end
	end

	
	/* [31 tag 10] [9 cache index 6] [5 data index 0]
	 * so the data index is 6 bits long
	 * so the cache index is 4 bits long
	 * so the tag is 22 bits long. c.c
	 */
	
	reg cache_valid [15:0];
	reg [21:0] cache_tags [15:0];
	reg [31:0] cache_data_hi [127:0 /* {line,word} */];	//synthesis attribute ram_style of cache_data_hi is block
	reg [31:0] cache_data_lo [127:0 /* {line,word} */];	//synthesis attribute ram_style of cache_data_lo is block
	
	integer i;
	initial
		for (i = 0; i < 16; i = i + 1)
		begin
			cache_valid[i[3:0]] = 0;
			cache_tags[i[3:0]] = 0;
		end
	
	wire  [5:0] rd_didx_0a      = ic__rd_addr_0a[5:0];
	wire  [2:0] rd_didx_word_0a = rd_didx_0a[5:3]; /* bit 2 goes to the hi/lo index */
	wire  [3:0] rd_idx_0a       = ic__rd_addr_0a[9:6];
	wire [21:0] rd_tag_0a       = ic__rd_addr_0a[31:10];
	
	reg  [31:0] rd_addr_1a = 32'hFFFFFFFF;
	
	wire cache_hit_0a = cache_valid[rd_idx_0a] && (cache_tags[rd_idx_0a] == rd_tag_0a);
	
	wire [31:0] curdata_hi_0a = cache_data_hi[{rd_idx_0a,rd_didx_word_0a}];
	wire [31:0] curdata_lo_0a = cache_data_lo[{rd_idx_0a,rd_didx_word_0a}];

	/*** Processor control bus logic ***/
	always @(*) begin
		ic__rd_wait_0a = ic__rd_req_0a && !cache_hit_0a;
	end
	always @(posedge clk) begin
		// Do the actual read.
		ic__rd_data_1a <= ic__rd_addr_0a[2] ? curdata_hi_0a : curdata_lo_0a;
	end
	
	reg [2:0] cache_fill_pos = 0;
	reg read_pending = 0;
	reg [31:0] fill_addr = 0;
	wire [21:0] fill_tag = fill_addr[31:10];
	wire [3:0] fill_idx = fill_addr[9:6];
	wire start_read = ic__rd_req_0a && !cache_hit_0a && !read_pending && fsab_credit_avail;
	always @(*)
	begin
		ic__fsabo_valid = 0;
		ic__fsabo_mode = {(FSAB_REQ_HI+1){1'bx}};
		ic__fsabo_did = {(FSAB_DID_HI+1){1'bx}};
		ic__fsabo_subdid = {(FSAB_DID_HI+1){1'bx}};
		ic__fsabo_addr = {(FSAB_ADDR_HI+1){1'bx}};
		ic__fsabo_len = {{FSAB_LEN_HI+1}{1'bx}};
		ic__fsabo_data = {{FSAB_DATA_HI+1}{1'bx}};
		ic__fsabo_mask = {{FSAB_MASK_HI+1}{1'bx}};
		
		/* At first glance, there can only be one request alive at a
		 * time, but that's not quite the case; there can
		 * potentially be multiple writes alive, since we don't
		 * block for the request to come back.  So, we do need to
		 * worry about credits.
		 */
		
		if (start_read && rst_b) begin
			ic__fsabo_valid = 1;
			ic__fsabo_mode = FSAB_READ;
			ic__fsabo_did = FSAB_DID_CPU;
			ic__fsabo_subdid = FSAB_SUBDID_CPU_ICACHE;
			ic__fsabo_addr = {ic__rd_addr_0a[30:6], 3'b000, 3'b000 /* 64-bit aligned */};
			ic__fsabo_len = 'h8; /* 64 byte cache lines, 8 byte reads */
			$display("ICACHE: Starting read: Addr %08x", ic__fsabo_addr);
		end
	end

	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			read_pending <= 0;
			cache_fill_pos <= 0;
			fill_addr <= 0;
			for (i = 0; i < 16; i = i + 1)
				cache_valid[i] <= 0;
		end else begin
			if (start_read) begin
				read_pending <= 1;
				cache_fill_pos <= 0;
				fill_addr <= {ic__rd_addr_0a[31:6], 6'b0};
			end else if (fsabi_valid && (fsabi_did == FSAB_DID_CPU) && (fsabi_subdid == FSAB_SUBDID_CPU_ICACHE)) begin
				$display("DCACHE: FILL: rd addr %08x; FSAB addr %08x; FSAB data %016x", ic__rd_addr_0a, fill_addr, fsabi_data);
				
				cache_fill_pos <= cache_fill_pos + 1;
				if (cache_fill_pos == 7) begin	/* Done? */
					cache_tags[fill_idx] <= fill_tag;
					cache_valid[fill_idx] <= 1;
					read_pending <= 0;
				end else
					cache_valid[fill_idx] <= 0;
			end
			
			/* Split this out because XST is kind of silly about this sort of thing. */
			if (fsabi_valid && (fsabi_did == FSAB_DID_CPU) && (fsabi_subdid == FSAB_SUBDID_CPU_ICACHE))
				cache_data_hi[{fill_idx,cache_fill_pos}] <= fsabi_data[63:32];
			if (fsabi_valid && (fsabi_did == FSAB_DID_CPU) && (fsabi_subdid == FSAB_SUBDID_CPU_ICACHE))
				cache_data_lo[{fill_idx,cache_fill_pos}] <= fsabi_data[31:0];
		end
	end
endmodule
