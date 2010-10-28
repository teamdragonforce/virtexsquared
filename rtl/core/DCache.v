/* 16 cache entries, 64-byte long cache lines */

module DCache(/*AUTOARG*/
   // Outputs
   dc__rw_wait_3a, dc__rd_data_4a, dc__fsabo_valid, dc__fsabo_mode,
   dc__fsabo_did, dc__fsabo_subdid, dc__fsabo_addr, dc__fsabo_len,
   dc__fsabo_data, dc__fsabo_mask, spamo_valid, spamo_r_nw, spamo_did,
   spamo_addr, spamo_data,
   // Inouts
   dc__control1,
   // Inputs
   clk, rst_b, dc__addr_3a, dc__rd_req_3a, dc__wr_req_3a,
   dc__wr_data_3a, dc__fsabo_credit, fsabi_valid, fsabi_did,
   fsabi_subdid, fsabi_data, fsabi_clk, fsabi_rst_b, spami_busy_b,
   spami_data
   );
	`include "fsab_defines.vh"
	`include "spam_defines.vh"

	input clk;
	input rst_b;

	/* ARM core interface */
	input      [31:0] dc__addr_3a;
	input             dc__rd_req_3a;
	input             dc__wr_req_3a;
	output reg        dc__rw_wait_3a;
	input      [31:0] dc__wr_data_3a;
	output reg [31:0] dc__rd_data_4a;

	/* FSAB interface */
	output reg                  dc__fsabo_valid;
	output reg [FSAB_REQ_HI:0]  dc__fsabo_mode;
	output reg [FSAB_DID_HI:0]  dc__fsabo_did;
	output reg [FSAB_DID_HI:0]  dc__fsabo_subdid;
	output reg [FSAB_ADDR_HI:0] dc__fsabo_addr;
	output reg [FSAB_LEN_HI:0]  dc__fsabo_len;
	output reg [FSAB_DATA_HI:0] dc__fsabo_data;
	output reg [FSAB_MASK_HI:0] dc__fsabo_mask;
	input                       dc__fsabo_credit;
	
	input                       fsabi_valid;
	input      [FSAB_DID_HI:0]  fsabi_did;
	input      [FSAB_DID_HI:0]  fsabi_subdid;
	input      [FSAB_DATA_HI:0] fsabi_data;
	input                       fsabi_clk;
	input                       fsabi_rst_b;
	
	/* SPAM sidechannel interface */
	output reg                  spamo_valid;
	output reg                  spamo_r_nw;
	output reg [SPAM_DID_HI:0]  spamo_did;
	output reg [SPAM_ADDR_HI:0] spamo_addr;
	output reg [SPAM_DATA_HI:0] spamo_data;
	
	input                       spami_busy_b;
	input      [SPAM_DATA_HI:0] spami_data;
	
	inout [35:0] dc__control1;
	
	parameter DEBUG = "FALSE";
	
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
	
	
	reg read_pending = 0;
	wire start_read = rst_b && dc__rd_req_3a && !dc__addr_3a[31] && !cache_hit_3a && !read_pending && fsab_credit_avail;
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
	
	reg [31:0] fill_addr = 0;
	wire [21:0] fill_tag = fill_addr[31:10];
	wire [3:0] fill_idx = fill_addr[9:6];
	
	reg [31:0] curdata_hi_4a = 0;
	reg [31:0] curdata_lo_4a = 0;

	/* For signaling between the clock domains, there exists a 'current
	 * read' signal that flops back and forth.  Since the FSABI clock
	 * domain wants to know when a read starts, and also wants to
	 * communicate back when it has finished a specific read without
	 * annoying flag synchronization, the easiest mechanism is to
	 * communicate which read the core domain is expecting, and have the
	 * FSABI domain communicate back which read has most recently
	 * completed.
	 */
	reg current_read = 0;
	reg current_read_fclk_s1 = 0;
	reg current_read_fclk = 0;
	reg completed_read_fclk = 0;
	reg completed_read_s1 = 0;
	reg completed_read = 0;
	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			for (i = 0; i < 16; i = i + 1)
				cache_valid[i] <= 1'b0;
			read_pending <= 0;
			fill_addr <= 0;
			completed_read <= 0;
			completed_read_s1 <= 0;
			current_read <= 0;
		end else begin
			completed_read_s1 <= completed_read_fclk;
			completed_read <= completed_read_s1;
		
			if (start_read) begin
				read_pending <= 1;
				current_read <= ~current_read;
				fill_addr <= {dc__addr_3a[31:6], 6'b0};
				cache_valid[fill_idx] <= 0;
			end else if ((completed_read == current_read) && read_pending) begin
				cache_tags[fill_idx] <= fill_tag;
				cache_valid[fill_idx] <= 1;
				read_pending <= 0;
			end
			
			/* This is written like this because XST is sort of silly about this sort of thing. */
			
			if ((dc__rd_req_3a || dc__wr_req_3a) && cache_hit_3a && dc__addr_3a[2]) begin
				if (dc__wr_req_3a)
					cache_data_hi[{idx_3a,dc__addr_3a[5:3]}] <= dc__wr_data_3a;
				curdata_hi_4a <= cache_data_hi[{idx_3a,dc__addr_3a[5:3]}];
			end
			
			if ((dc__rd_req_3a || dc__wr_req_3a) && cache_hit_3a && ~dc__addr_3a[2]) begin
				if (dc__wr_req_3a)
					cache_data_lo[{idx_3a,dc__addr_3a[5:3]}] <= dc__wr_data_3a;
				curdata_lo_4a <= cache_data_lo[{idx_3a,dc__addr_3a[5:3]}];
			end
		end
	end
	
	/* Once read_pending is high, fill_addr is frozen until
	 * read_complete is asserted.  By the time read_pending is
	 * synchronized into the fsabi domain (and hence any logic in fsabi
	 * can see it), fill_addr will have been stable for a long time, so
	 * we do not need to synchronize it in.
	 *
	 * This does mean that read_pending must get synchronized in before
	 * the FSAB begins returning data.  Luckily, there will be at least
	 * two cycles of latency in arbitration synchronizers (if not the
	 * rest of the arbitration and memory systems!), so we can be more
	 * or less guaranteed of that.
	 *
	 * If we decide to make the memory system ultra low latency for some
	 * reason later, then this will have to be revisited.
	 */
	reg [2:0] cache_fill_pos_fclk = 0;
	reg current_read_1a_fclk = 0;

	always @(posedge fsabi_clk or negedge fsabi_rst_b) begin
		if (!fsabi_rst_b) begin
			current_read_fclk_s1 <= 0;
			current_read_fclk <= 0;
			current_read_1a_fclk <= 0;
			completed_read_fclk <= 0;
			cache_fill_pos_fclk <= 0;
		end else begin
			current_read_fclk_s1 <= current_read;
			current_read_fclk <= current_read_fclk_s1;
			current_read_1a_fclk <= current_read_fclk;
			
			if (current_read_fclk ^ current_read_1a_fclk) begin
				cache_fill_pos_fclk <= 0;
			end else if (fsabi_valid && (fsabi_did == FSAB_DID_CPU) && (fsabi_subdid == FSAB_SUBDID_CPU_DCACHE)) begin
				$display("DCACHE: FILL: rd addr %08x; FSAB addr %08x; FSAB data %016x", dc__addr_3a, fill_addr, fsabi_data);
				
				if (cache_fill_pos_fclk == 7)	/* Done? */
					completed_read_fclk <= current_read_fclk;
				
				// Workaround for suspected Verilator bug. 
				// Hopefully it is possible to synthesize a block RAM with enough ports...
				`ifdef verilator
					cache_data_hi[{fill_idx,cache_fill_pos_fclk}] = fsabi_data[63:32];
					cache_data_lo[{fill_idx,cache_fill_pos_fclk}] = fsabi_data[31:0];
				`else
					cache_data_hi[{fill_idx,cache_fill_pos_fclk}] <= fsabi_data[63:32];
					cache_data_lo[{fill_idx,cache_fill_pos_fclk}] <= fsabi_data[31:0];
				`endif
				cache_fill_pos_fclk <= cache_fill_pos_fclk + 1;
			end
		end
	end
	
	/*** SPAM initiation logic ***/
	reg spam_intrans = 0;
	reg [7:0] spam_timeout_3a = 0;
	reg [7:0] spam_timeout_4a = 0;
	
	always @(*) begin
		spamo_valid = 1'b0;
		spamo_r_nw = 1'bx;
		spamo_did = 4'hx;
		spamo_addr = 24'hxxxxxx;
		spamo_data = 32'hxxxxxxxx;
		if ((dc__rd_req_3a || dc__wr_req_3a) && dc__addr_3a[31] && !spam_intrans && rst_b) begin
			spamo_valid = 1'b1;
			spamo_r_nw = dc__rd_req_3a;
			spamo_did = dc__addr_3a[27:24];
			spamo_addr = dc__addr_3a[23:0];
			spamo_data = dc__wr_req_3a ? dc__wr_data_3a : 'bx;
		end
	end
	
	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			spam_intrans <= 0;
			spam_timeout_3a <= 0;
			spam_timeout_4a <= 0;
		end else begin
			spam_timeout_4a <= spam_timeout_3a;
			
			if (spamo_valid) begin
				$display("SPAM: outbound valid");
				spam_intrans <= 1;
				spam_timeout_3a <= 8'hFF;
			end else if (spami_busy_b || (spam_timeout_3a == 0)) begin
				$display("SPAM: busy %d, timeout %d; done", spami_busy_b, spam_timeout_3a);
				spam_intrans <= 0;
			end else if (spam_intrans)
				spam_timeout_3a <= spam_timeout_3a - 1;
		end
	end
	
	reg [31:0] spami_data_4a = 32'h0;
	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			spami_data_4a <= 32'h0;
		end else begin
			spami_data_4a <= spami_data;
		end
	end
	
	/*** Overall processor databus multiplexing logic ***/
	reg [31:0] dc__addr_4a = 0;
	reg dc__rw_wait_4a = 0;
	reg dc__rd_req_4a = 0;
	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			dc__addr_4a <= 32'h0;
			dc__rw_wait_4a <= 0;
			dc__rd_req_4a <= 0;
		end else begin
			dc__addr_4a <= dc__addr_3a;
			dc__rw_wait_4a <= dc__rw_wait_3a;
			dc__rd_req_4a <= dc__rd_req_3a;
		end
	end
	
	always @(*) begin
		if (!dc__addr_3a[31]) /* FSAB */ begin
			dc__rw_wait_3a = (dc__rd_req_3a && !cache_hit_3a) || (dc__wr_req_3a && !fsab_credit_avail);
			if (dc__rd_req_3a && !cache_hit_3a)
				$display("DCACHE: Stalling due to cache miss (credits %d)", fsab_credits);
			if (dc__wr_req_3a && !fsab_credit_avail)
				$display("DCACHE: Stalling due to insufficient credits to write");
		end else /* SPAM */ begin
			dc__rw_wait_3a = !spami_busy_b && ((spam_intrans && (spam_timeout_3a != 0)) || spamo_valid);
		end
	end
	
	always @(*) begin
		if (!dc__addr_4a[31]) /* FSAB */ begin
			dc__rd_data_4a = dc__addr_4a[2] ? curdata_hi_4a : curdata_lo_4a;
			if (!dc__rw_wait_4a && dc__rd_req_4a)
				$display("DCACHE: READ COMPLETE: Addr %08x, data %08x", dc__addr_4a, dc__rd_data_4a);
		end else /* SPAM */ begin
			dc__rd_data_4a = (spam_timeout_4a == 0) ? 32'hDEADDEAD : spami_data_4a;
		end
	end
	
	/*** Chipscope visibility ***/
	generate
	if (DEBUG == "TRUE") begin: debug
		chipscope_ila ila1 (
			.CONTROL(dc__control1), // INOUT BUS [35:0]
			.CLK(clk), // IN
			.TRIG0({rst_b,
			        start_read, dc__wr_req_3a && fsab_credit_avail,
			        completed_read, current_read, read_pending, 
			        dc__wr_req_3a, dc__rd_req_3a, dc__rd_req_3a || dc__wr_req_3a, dc__rw_wait_3a, cache_hit_3a,
			        dc__addr_3a[31:0], dc__wr_data_3a[31:0],
			        curdata_hi_4a[31:0], curdata_lo_4a[31:0], dc__addr_4a[31:0]})
		);
	
	end else begin: debug_tieoff
	
		assign dc__control1 = {36{1'bz}};
		
	end
	endgenerate

endmodule
