module FSABFifo(
	input clk,
	input Nrst,
	
	input                        fifo_read,
	input                        fsabo_valid,
	input       [FSAB_REQ_HI:0]  fsabo_mode,
	input       [FSAB_DID_HI:0]  fsabo_did,
	input       [FSAB_DID_HI:0]  fsabo_subdid,
	input       [FSAB_ADDR_HI:0] fsabo_addr,
	input       [FSAB_LEN_HI:0]  fsabo_len,
	input       [FSAB_DATA_HI:0] fsabo_data,
	input       [FSAB_MASK_HI:0] fsabo_mask,
	
	output wire [FSAB_RFIF_HI:0] fsab_req_out,
	output wire [FSAB_DATA_HI:0] fsabi_data,
	output wire [FSAB_MASK_HI:0] fsabi_mask
	);
`include "fsab_defines.vh"


	/*** Inbound request FIFO (RFIF) ***/
	reg [FSAB_CREDITS_HI:0] rfif_wpos_0a = 'h0;
	reg [FSAB_CREDITS_HI:0] rfif_rpos_0a = 'h0;
	reg [FSAB_RFIF_HI:0] rfif_fifo [(FSAB_INITIAL_CREDITS-1):0];
	wire rfif_wr_0a;
	wire rfif_rd_0a;
	wire [FSAB_RFIF_HI:0] rfif_wdat_0a;
	reg [FSAB_RFIF_HI:0] rfif_rdat_1a;
	wire rfif_empty_0a = (rfif_rpos_0a == rfif_wpos_0a);
	wire rfif_full_0a = (rfif_wpos_0a == (rfif_rpos_0a + FSAB_INITIAL_CREDITS));
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			rfif_wpos_0a <= 'h0;
			rfif_rpos_0a <= 'h0;
		end else begin
			if (rfif_rd_0a) begin
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				rfif_rdat_1a <= rfif_fifo[rfif_rpos_0a[1:0]];
				rfif_rpos_0a <= rfif_rpos_0a + 'h1;
			end
			
			if (rfif_wr_0a) begin
				rfif_fifo[rfif_wpos_0a[1:0]] <= rfif_wdat_0a;
				rfif_wpos_0a <= rfif_wpos_0a + 'h1;
			end
		end
	
	always @(posedge clk) begin
		assert (rfif_empty_0a && rfif_rd_0a) else $error("RFIF rd while empty");
		assert (rfif_full_0a  && rfif_wr_0a) else $error("RFIF wr while full");
	end
	

	
	/* rfif_rd is assigned later */
	assign fsab_req_out = rfif_rdat_1a;
	assign rfif_wdat_0a = {fsabo_valid, fsabo_mode, fsabo_did, fsabo_subdid,
	                       fsabo_addr, fsabo_len};
	reg [FSAB_LEN_HI:0] fsabo_cur_req_len_rem_1a = 0;
	wire fsabo_cur_req_done_1a = (fsabo_cur_req_len_rem_1a == 0 /* we were done long ago */ || 
	                              fsabo_cur_req_len_rem_1a == 1 /* last cycle (1a) was the last word;
								       this cycle (0a), len will be 0 */);
	assign rfif_wr_0a = fsabo_valid && fsabo_cur_req_done_1a;
	
	always @(posedge clk or negedge Nrst)
		if (Nrst) begin
			fsabo_cur_req_len_rem_1a <= 0;
		end else begin
			if (fsabo_valid && fsabo_cur_req_done_1a && (fsabo_mode == FSAB_WRITE))
				fsabo_cur_req_len_rem_1a <= fsabo_len;
			else if (fsabo_valid && fsabo_cur_req_len_rem_1a != 0)
				fsabo_cur_req_len_rem_1a <= fsabo_cur_req_len_rem_1a - 1;
		end
	
	/*** Inbound data FIFO (DFIF) ***/
/*
 * Should be as follows, but that's not a power of 2:
 * `define FSAB_DFIF_MAX (((FSAB_CREDITS_HI+1) * FSAB_LEN_MAX) - 1)
 * `define FSAB_DFIF_HI ($clog2(`SIMMEM_DFIF_MAX) - 1)
 */
	reg [FSAB_DFIF_HI:0] dfif_wpos_0a = 'h0;
	reg [FSAB_DFIF_HI:0] dfif_rpos_0a = 'h0;
	reg [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_fifo [FSAB_DFIF_MAX:0];
	wire dfif_wr_0a;
	wire dfif_rd_0a;
	wire [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_wdat_0a;
	reg [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_rdat_1a;
	wire dfif_empty_0a = (dfif_rpos_0a == dfif_wpos_0a);
	wire dfif_full_0a = (dfif_wpos_0a == (dfif_rpos_0a + FSAB_DFIF_MAX));
	wire [FSAB_DFIF_HI:0] dfif_avail_0a = dfif_wpos_0a - dfif_rpos_0a;
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			dfif_wpos_0a <= 'h0;
			dfif_rpos_0a <= 'h0;
		end else begin
			if (dfif_rd_0a) begin
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				dfif_rdat_1a <= dfif_fifo[dfif_rpos_0a];
				dfif_rpos_0a <= dfif_rpos_0a + 'h1;
			end else begin
				dfif_rdat_1a <= {(FSAB_DATA_HI+1 + FSAB_MASK_HI+1){1'hx}};
			end
			
			if (dfif_wr_0a) begin
				dfif_fifo[dfif_wpos_0a] <= dfif_wdat_0a;
				dfif_wpos_0a <= dfif_wpos_0a + 'h1;
			end
		end
	
	always @(posedge clk) begin
		assert (dfif_empty_0a && dfif_rd_0a) else $error("DFIF rd while empty");
		assert (dfif_full_0a  && dfif_wr_0a) else $error("DFIF wr while full");
	end
	
	
	/* dfif_rd is assigned later */
	assign {fsabi_data,fsabi_mask} = dfif_rdat_1a;
	assign dfif_wdat_0a = {fsabo_data,fsabo_mask};
	assign dfif_wr_0a = fsabo_valid;
	/* NOTE: this means that dfif_rd must ALWAYS be asserted along with
	 * rfif_rd...  even if len is 0, and even if the request was a read!
	 */
	
	/*** Pipe-throughs ***/
	reg rfif_rd_1a = 0;
	reg dfif_rd_1a = 0;
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			rfif_rd_1a <= 0;
			dfif_rd_1a <= 0;
		end else begin
			rfif_rd_1a <= rfif_rd_0a;
			dfif_rd_1a <= dfif_rd_0a;
		end
	
	
	/* TODO: This means that dfif does one read, then pauses one cycle,
	 * then continues doing the read until we run out of data.  Can the
	 * one-cycle pause be removed easily?
	 */
	assign rfif_rd_0a = !rfif_empty_0a && !rfif_rd_1a && fifo_read;
	assign dfif_rd_0a = rfif_rd_0a;  /* We must always do a read from dfif on rfif. */
	
	
endmodule
