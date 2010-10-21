module FSABArbiterFIFO(/*AUTOARG*/
   // Outputs
   inp_credit, out_valid, out_mode, out_did, out_subdid, out_addr,
   out_len, out_data, out_mask, empty_b, active,
   // Inputs
   iclk, oclk, iclk_rst_b, oclk_rst_b, inp_valid, inp_mode, inp_did,
   inp_subdid, inp_addr, inp_len, inp_data, inp_mask, start_trans
   );
	`include "fsab_defines.vh"

	input iclk;
	input oclk;
	input iclk_rst_b;
	input oclk_rst_b;
	
	input                        inp_valid;
	input       [FSAB_REQ_HI:0]  inp_mode;
	input       [FSAB_DID_HI:0]  inp_did;
	input       [FSAB_DID_HI:0]  inp_subdid;
	input       [FSAB_ADDR_HI:0] inp_addr;
	input       [FSAB_LEN_HI:0]  inp_len;
	input       [FSAB_DATA_HI:0] inp_data;
	input       [FSAB_MASK_HI:0] inp_mask;
	output wire                  inp_credit;
	
	output wire                  out_valid;
	output wire [FSAB_REQ_HI:0]  out_mode;
	output wire [FSAB_DID_HI:0]  out_did;
	output wire [FSAB_DID_HI:0]  out_subdid;
	output wire [FSAB_ADDR_HI:0] out_addr;
	output wire [FSAB_LEN_HI:0]  out_len;
	output wire [FSAB_DATA_HI:0] out_data;
	output wire [FSAB_MASK_HI:0] out_mask;
	
	/* All of these controls are on the oclk domain. */
	output wire                  empty_b;
	input                        start_trans;
	output wire                  active;

	parameter myindex = 0;
	parameter ARB_RFIF_HI = FSAB_REQ_HI+1 + FSAB_DID_HI+1 + FSAB_DID_HI+1 + FSAB_ADDR_HI+1 + FSAB_LEN_HI;

	/*** Inbound credit synchronization ***/
	wire inp_credit_oclk;
	reg [FSAB_CREDITS_HI:0] inp_credits_iclk = 'h0;
	reg [FSAB_CREDITS_HI:0] inp_credits_oclk = 'h0;
	wire [FSAB_CREDITS_HI:0] inp_credits_oclk_next = inp_credit_oclk ? (inp_credits_oclk + 1) : inp_credits_oclk;
	
	reg [FSAB_CREDITS_HI:0] inp_credits_g_oclk = 'h0;
	reg [FSAB_CREDITS_HI:0] inp_credits_oclk_g_iclk_s1 = 'h0;
	reg [FSAB_CREDITS_HI:0] inp_credits_oclk_g_iclk = 'h0;
	
	wire [FSAB_CREDITS_HI:0] inp_credits_g_iclk = (inp_credits_iclk >> 1) ^ inp_credits_iclk;
	
	assign inp_credit = inp_credits_oclk_g_iclk != inp_credits_g_iclk;
	
	/* The grey code must be flopped on both the oclk and the iclk
	 * side:
	 *
	 *    inp_credits_oclk_next ->
	 *    grey code ->
	 *    FLOP OCLK -> (avoid glitches)
	 *    FLOP ICLK -> 
	 *    FLOP ICLK -> (avoid metastability)
	 *    compare against iclk_g
	 *
	 * THIS MUST NOT BE REORDERED!
	 */
	
	always @(posedge oclk or negedge oclk_rst_b)
		if (!oclk_rst_b) begin
			inp_credits_oclk <= 'h0;
			inp_credits_g_oclk <= 'h0;
		end else begin
			inp_credits_oclk <= inp_credits_oclk_next;
			inp_credits_g_oclk <= (inp_credits_oclk_next >> 1) ^ inp_credits_oclk_next;
		end
	
	always @(posedge iclk or negedge iclk_rst_b)
		if (!iclk_rst_b) begin
			inp_credits_iclk <= 'h0;
			inp_credits_oclk_g_iclk_s1 <= 'h0;
			inp_credits_oclk_g_iclk <= 'h0;
		end else begin
			inp_credits_oclk_g_iclk_s1 <= inp_credits_g_oclk;
			inp_credits_oclk_g_iclk <= inp_credits_oclk_g_iclk_s1;
			if (inp_credit)
				inp_credits_iclk <= inp_credits_iclk + 1;
		end
	
	/*** Inbound request FIFO (RFIF) ***/
	wire rfif_wr_0a_iclk;
	wire rfif_rd_0a_oclk;
	reg [FSAB_CREDITS_HI:0] rfif_wpos_0a_iclk = 'h0;
	wire [FSAB_CREDITS_HI:0] rfif_wpos_0a_iclk_next = rfif_wr_0a_iclk ? (rfif_wpos_0a_iclk + 'h1) : rfif_wpos_0a_iclk;
	reg [FSAB_CREDITS_HI:0] rfif_rpos_0a_oclk = 'h0;
	reg [ARB_RFIF_HI:0] rfif_fifo [(FSAB_INITIAL_CREDITS-1):0];
	reg [ARB_RFIF_HI:0] rfif_wdat_0a_iclk = 'h0;
	reg [ARB_RFIF_HI:0] rfif_rdat_1a_oclk = 'h0;
	
	reg [FSAB_CREDITS_HI:0] rfif_wpos_0a_g_iclk = 'h0;
	reg [FSAB_CREDITS_HI:0] rfif_wpos_0a_iclk_g_oclk_s1 = 'h0;
	reg [FSAB_CREDITS_HI:0] rfif_wpos_0a_iclk_g_oclk = 'h0;
	
	wire [FSAB_CREDITS_HI:0] rfif_rpos_0a_g_oclk = rfif_rpos_0a_oclk ^ (rfif_rpos_0a_oclk << 1);
	
	/* There is no issue here with empty showing up too late, because
	 * only the write pointer is delayed; the read pointer remains
	 * synchronous with the read operation.  So, 'empty' might return
	 * empty for too long, but never for too short.
	 */
	wire rfif_empty_0a_oclk = (rfif_rpos_0a_g_oclk == rfif_wpos_0a_iclk_g_oclk);
`ifdef verilator
	/* This is ONLY valid in Verilator (not clock domain correct). */
	wire rfif_full_0a_iclk = (rfif_wpos_0a_iclk == (rfif_rpos_0a_oclk + FSAB_INITIAL_CREDITS));
`endif
	
	always @(posedge iclk or negedge iclk_rst_b)
		if (!iclk_rst_b) begin
			rfif_wpos_0a_iclk <= 'h0;
			rfif_wpos_0a_g_iclk <= 0;
		end else begin
			if (rfif_wr_0a_iclk) begin
				`ifdef verilator
				$display("ARB[%2d]: %5d: writing to rfif (%d word %s to %08x)", myindex, $time, inp_len, (inp_mode == FSAB_WRITE) ? "write" : "read", inp_addr);
				`endif
				rfif_fifo[rfif_wpos_0a_iclk[1:0]] <= rfif_wdat_0a_iclk;
				rfif_wpos_0a_iclk <= rfif_wpos_0a_iclk + 'h1;
			end
			rfif_wpos_0a_iclk <= rfif_wpos_0a_iclk_next;
			rfif_wpos_0a_g_iclk <= rfif_wpos_0a_iclk_next ^ (rfif_wpos_0a_iclk_next << 1);
		end
	
	always @(posedge oclk or negedge oclk_rst_b)
		if (!oclk_rst_b) begin
			rfif_rpos_0a_oclk <= 'h0;
			rfif_wpos_0a_iclk_g_oclk_s1 <= 'h0;
			rfif_wpos_0a_iclk_g_oclk <= 'h0;
		end else begin
			if (rfif_rd_0a_oclk) begin
				`ifdef verilator
				$display("ARB[%2d]: %5d: reading from rfif", myindex, $time);
				`endif
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				rfif_rdat_1a_oclk <= rfif_fifo[rfif_rpos_0a_oclk[1:0]];
				rfif_rpos_0a_oclk <= rfif_rpos_0a_oclk + 'h1;
			end
			rfif_wpos_0a_iclk_g_oclk_s1 <= rfif_wpos_0a_g_iclk;
			rfif_wpos_0a_iclk_g_oclk <= rfif_wpos_0a_iclk_g_oclk_s1;
		end
	
	`ifdef verilator
	always @(posedge oclk)
		assert (!(rfif_empty_0a_oclk && rfif_rd_0a_oclk)) else $error("RFIF rd while empty");
	always @(posedge iclk)
		assert (!(rfif_full_0a_iclk  && rfif_wr_0a_iclk)) else $error("RFIF wr while full");
	`endif
	
	/*** RFIF demux & control ***/
	wire [FSAB_REQ_HI:0]  rfif_mode_1a;
	wire [FSAB_DID_HI:0]  rfif_did_1a;
	wire [FSAB_DID_HI:0]  rfif_subdid_1a;
	wire [FSAB_ADDR_HI:0] rfif_addr_1a;
	wire [FSAB_LEN_HI:0]  rfif_len_1a;
	
	/* rfif_rd is assigned later */
	
	assign {rfif_mode_1a, rfif_did_1a, rfif_subdid_1a, rfif_addr_1a, rfif_len_1a} = rfif_rdat_1a_oclk;
	always @(*)
		rfif_wdat_0a_iclk = {inp_mode, inp_did, inp_subdid, inp_addr, inp_len};
	reg [FSAB_LEN_HI:0] inp_cur_req_len_rem_1a = 0;
	wire inp_cur_req_done_1a = (inp_cur_req_len_rem_1a == 0 /* we were done long ago */ || 
	                            inp_cur_req_len_rem_1a == 1 /* last cycle (1a) was the last word;
								       this cycle (0a), len will be 0 */);
	assign rfif_wr_0a_iclk = inp_valid && inp_cur_req_done_1a;
	
	always @(posedge iclk or negedge iclk_rst_b)
		if (!iclk_rst_b) begin
			inp_cur_req_len_rem_1a <= 0;
		end else begin
			`ifdef verilator
			if (inp_valid) 
				$display("ARB[%2d]: %5d: RFIF control: valid %d, done %d, rem %d, inp len %d", myindex, $time, inp_valid, inp_cur_req_done_1a, inp_cur_req_len_rem_1a, inp_len);
			`endif
			if (inp_valid && inp_cur_req_done_1a && (inp_mode == FSAB_WRITE)) begin
				`ifdef verilator
				$display("ARB[%2d]: %5d: RFIF control: inp len %d", myindex, $time, inp_len);
				`endif
				inp_cur_req_len_rem_1a <= inp_len;
			end else if (inp_valid && inp_cur_req_len_rem_1a != 0)
				inp_cur_req_len_rem_1a <= inp_cur_req_len_rem_1a - 1;
		end
	
	/*** Inbound data FIFO (DFIF) ***/
`include "clog2.vh"
`define ARB_DFIF_MAX ((FSAB_INITIAL_CREDITS * FSAB_LEN_MAX) - 1)
`define ARB_DFIF_HI (clog2(`ARB_DFIF_MAX) - 1)
	wire dfif_wr_0a_iclk;
	wire dfif_rd_0a_oclk;
	reg [`ARB_DFIF_HI:0] dfif_wpos_0a_iclk = 'h0;
	wire [`ARB_DFIF_HI:0] dfif_wpos_0a_iclk_next = dfif_wr_0a_iclk ? (dfif_wpos_0a_iclk + 'h1) : dfif_wpos_0a_iclk;
	reg [`ARB_DFIF_HI:0] dfif_rpos_0a_oclk = 'h0;
	reg [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_fifo [`ARB_DFIF_MAX:0];
	wire [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_wdat_0a_iclk;
	reg [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_rdat_1a_oclk;

	reg [`ARB_DFIF_HI:0] dfif_wpos_0a_g_iclk = 'h0;
	reg [`ARB_DFIF_HI:0] dfif_wpos_0a_iclk_g_oclk_s1 = 'h0;
	reg [`ARB_DFIF_HI:0] dfif_wpos_0a_iclk_g_oclk = 'h0;
	
	wire [`ARB_DFIF_HI:0] dfif_rpos_0a_g_oclk = dfif_rpos_0a_oclk ^ (dfif_rpos_0a_oclk << 1);
	
	wire dfif_empty_0a_oclk = (dfif_rpos_0a_g_oclk == dfif_wpos_0a_iclk_g_oclk);
`ifdef verilator
	/* This is ONLY valid in Verilator (not clock domain correct). */
	wire dfif_full_0a_iclk = (dfif_wpos_0a_iclk == (dfif_rpos_0a_oclk + `ARB_DFIF_MAX));
`endif
	
	always @(posedge iclk or negedge iclk_rst_b)
		if (!iclk_rst_b) begin
			dfif_wpos_0a_iclk <= 'h0;
			dfif_wpos_0a_g_iclk <= 0;
		end else begin
			if (dfif_wr_0a_iclk) begin
				`ifdef verilator
				$display("ARB[%2d]: %5d: writing to dfif (ad %d, %08b mask, %08x data)", myindex, $time, dfif_wpos_0a_iclk, inp_mask, inp_data);
				`endif
				dfif_fifo[dfif_wpos_0a_iclk] <= dfif_wdat_0a_iclk;
			end
			dfif_wpos_0a_iclk <= dfif_wpos_0a_iclk_next;
			dfif_wpos_0a_g_iclk <= dfif_wpos_0a_iclk_next ^ (dfif_wpos_0a_iclk_next << 1);
		end

	always @(posedge oclk or negedge oclk_rst_b)
		if (!oclk_rst_b) begin
			dfif_rpos_0a_oclk <= 'h0;
			dfif_wpos_0a_iclk_g_oclk_s1 <= 'h0;
			dfif_wpos_0a_iclk_g_oclk <= 'h0;
		end else begin
			if (dfif_rd_0a_oclk) begin
				`ifdef verilator
				$display("ARB[%2d]: %5d: reading from dfif (ad %d, da %x)", myindex, $time, dfif_rpos_0a_oclk, dfif_fifo[dfif_rpos_0a_oclk]);
				`endif
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				dfif_rdat_1a_oclk <= dfif_fifo[dfif_rpos_0a_oclk];
				dfif_rpos_0a_oclk <= dfif_rpos_0a_oclk + 'h1;
			end else begin
				dfif_rdat_1a_oclk <= {(FSAB_DATA_HI+1 + FSAB_MASK_HI+1){1'hx}};
			end
			dfif_wpos_0a_iclk_g_oclk_s1 <= dfif_wpos_0a_g_iclk;
			dfif_wpos_0a_iclk_g_oclk <= dfif_wpos_0a_iclk_g_oclk_s1;
		end
	
	`ifdef verilator
	always @(posedge oclk)
		assert (!(dfif_empty_0a_oclk && dfif_rd_0a_oclk)) else $error("DFIF rd while empty");
	always @(posedge iclk)
		assert (!(dfif_full_0a_iclk  && dfif_wr_0a_iclk)) else $error("DFIF wr while full");
	// assert (`ARB_DFIF_MAX == (({1'b1, {`ARB_DFIF_HI{1'b0}}}) - 1)) else $error("DFIF size invalid");
	// Assertion removed due to Verilator bug in calculating $clog2 in non-size expressions
	`endif
	
	/*** DFIF demux & control */
	wire [FSAB_DATA_HI:0] dfif_data_1a;
	wire [FSAB_MASK_HI:0] dfif_mask_1a;
	
	/* dfif_rd is assigned later */
	assign {dfif_data_1a,dfif_mask_1a} = dfif_rdat_1a_oclk;
	assign dfif_wdat_0a_iclk = {inp_data,inp_mask};
	assign dfif_wr_0a_iclk = inp_valid;
	/* NOTE: this means that dfif_rd must ALWAYS be asserted along with
	 * rfif_rd...  even if len is 0, or even if the request was a read!
	 */
	
	/*** Pipe-throughs ***/
	reg rfif_rd_1a = 0;
	reg dfif_rd_1a = 0;
	always @(posedge oclk or negedge oclk_rst_b)
		if (!oclk_rst_b) begin
			rfif_rd_1a <= 0;
			dfif_rd_1a <= 0;
		end else begin
			rfif_rd_1a <= rfif_rd_0a_oclk;
			dfif_rd_1a <= dfif_rd_0a_oclk;
		end
	
	/*** Readout logic ***/
	/* When start_trans is asserted, we can *always* kick off an rfif read. 
	 * Why?  Well, it may result in rfif getting out of sync...  but
	 * it's a protocol violation on the input for start_trans to be asserted
	 * while we're in a transaction ("active").  It will get caught by
	 * an assertion checker -- but no special action is needed to slow
	 * down the RTL to check for it.
	 */
	
	/* XXX: This isn't really true.  It may light up before we actually
	 * have a full packet buffered in.  It won't cause any correctness
	 * issues, but if a master has lots of intra-packet delays, then
	 * this will cause the arbited interface to back up.
	 */
	assign empty_b = !rfif_empty_0a_oclk;
	
	/* Active determines whether we have a request waiting (i.e., we did
	 * an RFIF read).  It is high as long as we are serving it (which
	 * might be more than the number of cycles in 'len', since we might
	 * not have all of the data in the dfif yet).
	 */
	reg  [FSAB_LEN_HI:0]  mem_cur_req_len_rem_0a = 'h0;
	reg                   mem_cur_req_active_0a = 0;
	reg                   mem_cur_req_active_1a = 0;
	wire [FSAB_ADDR_HI:0] mem_cur_req_addr_1a;
	reg  [FSAB_ADDR_HI:0] mem_cur_req_addr_1a_r = 0;
	
	/* If we just finished reading from the dfif for the last time
	 * (i.e., we just went inactive), then we can release a credit. 
	 * This is as distinct from releasing a credit every time we read
	 * from rfif, which is incorrect because there may not yet be space
	 * in the dfif yet.  (Compare this to the empty_b issue, which is
	 * the opposite.)
	 *
	 * Alternatively, if we were doing no dfif reading at all (we just
	 * ate a READ packet), then we're done, too.
	 */
	assign inp_credit_oclk = (mem_cur_req_active_1a && !mem_cur_req_active_0a) ||
	                         (rfif_rd_1a && (rfif_mode_1a == FSAB_READ));
	
	/* Similarly, we're active as long as something is showing up on the
	 * output bus (mem_cur_req_active_1a), or we just did a read and
	 * we're thinking about it.
	 */
	assign active = mem_cur_req_active_1a || mem_cur_req_active_0a || rfif_rd_1a;
	
	/* TODO: This means that dfif does one read, then pauses one cycle,
	 * then continues doing the read until we run out of data.  Can the
	 * one-cycle pause be removed easily?
	 *
	 * This is the same problem as in FSABSimMemory.
	 */
	assign rfif_rd_0a_oclk = !rfif_empty_0a_oclk && !mem_cur_req_active_0a && !rfif_rd_1a && start_trans;
	assign dfif_rd_0a_oclk = rfif_rd_0a_oclk || /* We must always do a read from dfif on rfif. */
  	                         (mem_cur_req_active_0a &&
	                          (rfif_mode_1a == FSAB_WRITE) &&
	                          (mem_cur_req_len_rem_0a != 'h1) &&
	                          (mem_cur_req_len_rem_0a != 'h0) &&
	                          !dfif_empty_0a_oclk);
	
	always @(posedge oclk or negedge oclk_rst_b)
		if (!oclk_rst_b) begin
			mem_cur_req_len_rem_0a <= 'h0;
			mem_cur_req_active_0a <= 0;
			mem_cur_req_active_1a <= 0;
			mem_cur_req_addr_1a_r <= 0;
		end else begin
			mem_cur_req_active_1a <= mem_cur_req_active_0a;
		
			if (rfif_rd_1a && (rfif_mode_1a == FSAB_WRITE)) begin
				`ifdef verilator
				$display("ARB[%2d]: %5d: RFIF was just read; it was a %d word %s at %08x", myindex, $time, rfif_len_1a, (rfif_mode_1a == FSAB_WRITE) ? "WRITE" : "READ", rfif_addr_1a);
				`endif
				mem_cur_req_active_0a <= 1;
				mem_cur_req_len_rem_0a <= rfif_len_1a;
			end else if (dfif_rd_0a_oclk)
				mem_cur_req_len_rem_0a <= mem_cur_req_len_rem_0a - 1;
			else if (mem_cur_req_len_rem_0a == 'h1 || mem_cur_req_len_rem_0a == 'h0) begin
				mem_cur_req_active_0a <= 0;
			end
		end
	
	/*** External interface assignments ***/
	assign out_valid = dfif_rd_1a;
	assign out_mode = rfif_mode_1a;
	assign out_did = rfif_did_1a;
	assign out_subdid = rfif_subdid_1a;
	assign out_addr = rfif_addr_1a;
	assign out_len = rfif_len_1a;
	assign out_data = dfif_data_1a;
	assign out_mask = dfif_mask_1a;
endmodule
