/* 16 cache entries, 64-byte long cache lines */

module ICache(/*AUTOARG*/
   // Outputs
   ic__rd_wait_0a, ic__rd_data_1a, ic__fsabo_valid, ic__fsabo_mode,
   ic__fsabo_did, ic__fsabo_subdid, ic__fsabo_addr, ic__fsabo_len,
   ic__fsabo_data, ic__fsabo_mask,
   // Inouts
   ic__control2,
   // Inputs
   clk, rst_b, ic__rd_addr_0a, ic__rd_req_0a, ic__fsabo_credit,
   fsabi_valid, fsabi_did, fsabi_subdid, fsabi_data, fsabi_clk,
   fsabi_rst_b
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
	input                       fsabi_clk;
	input                       fsabi_rst_b;

	inout [35:0] ic__control2;
	
	parameter DEBUG = "FALSE";

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
	reg [63:0] cache_data [127:0 /* {line,word} */];	//synthesis attribute ram_style of cache_data is block
	
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

	/*** Processor control bus logic ***/
	reg [31:0] ic__rd_addr_1a = 0;
	reg [63:0] curdata_1a = 0;
	
	always @(*) begin
		ic__rd_wait_0a = ic__rd_req_0a && !cache_hit_0a;
		ic__rd_data_1a = ic__rd_addr_1a[2] ? curdata_1a[63:32] : curdata_1a[31:0];
	end
	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			curdata_1a <= {64{1'b0}};
			ic__rd_addr_1a <= 0;
		end else begin
			// Do the actual read.
			curdata_1a <= cache_data[{rd_idx_0a,rd_didx_word_0a}];
			ic__rd_addr_1a <= ic__rd_addr_0a;
		end
	end
	
	reg read_pending = 0;
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

	reg [31:0] fill_addr = 0;
	wire [21:0] fill_tag = fill_addr[31:10];
	wire [3:0] fill_idx = fill_addr[9:6];

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
				fill_addr <= {ic__rd_addr_0a[31:6], 6'b0};
				cache_valid[fill_idx] <= 0;
			end else if ((completed_read == current_read) && read_pending) begin
				cache_tags[fill_idx] <= fill_tag;
				cache_valid[fill_idx] <= 1;
				read_pending <= 0;
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
			end else if (fsabi_valid && (fsabi_did == FSAB_DID_CPU) && (fsabi_subdid == FSAB_SUBDID_CPU_ICACHE)) begin
				$display("ICACHE: FILL: rd addr %08x; FSAB addr %08x; FSAB data %016x", ic__rd_addr_0a, fill_addr, fsabi_data);
				
				if (cache_fill_pos_fclk == 7)	/* Done? */
					completed_read_fclk <= current_read_fclk;
				cache_data[{fill_idx,cache_fill_pos_fclk}] <= fsabi_data[63:0];
				cache_fill_pos_fclk <= cache_fill_pos_fclk + 1;
			end
		end
	end
	
	/*** Chipscope visibility ***/
	generate
	if (DEBUG == "TRUE") begin: debug
		chipscope_ila ila2 (
			.CONTROL(ic__control2), // INOUT BUS [35:0]
			.CLK(fsabi_clk), // IN
			.TRIG0({fsabi_rst_b, current_read_fclk, completed_read_fclk, cache_fill_pos_fclk[2:0],
			        fsabi_valid, fsabi_did[3:0], fsabi_subdid[3:0],
			        ic__fsabo_credit, ic__fsabo_valid, fsab_credits[2:0], fill_addr[31:0]})
		);
	
	end else begin: debug_tieoff
	
		assign ic__control2 = {36{1'bz}};
		
	end
	endgenerate

endmodule
