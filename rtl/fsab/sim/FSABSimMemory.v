module FSABSimMemory(
	input                        clk,
	input                        rst_b,
	
	input                        fsabo_valid,
	input       [FSAB_REQ_HI:0]  fsabo_mode,
	input       [FSAB_DID_HI:0]  fsabo_did,
	input       [FSAB_DID_HI:0]  fsabo_subdid,
	input       [FSAB_ADDR_HI:0] fsabo_addr,
	input       [FSAB_LEN_HI:0]  fsabo_len,
	input       [FSAB_DATA_HI:0] fsabo_data,
	input       [FSAB_MASK_HI:0] fsabo_mask,
	output wire                  fsabo_credit,
	
	output wire                  fsabi_valid,
	output wire [FSAB_DID_HI:0]  fsabi_did,
	output wire [FSAB_DID_HI:0]  fsabi_subdid,
	output wire [FSAB_DATA_HI:0] fsabi_data
	);

	parameter SIMMEM_SIZE = 8 * 1024 * 1024;

`include "fsab_defines.vh"

	/*** Inbound request FIFO (RFIF) ***/
`define SIMMEM_RFIF_HI (FSAB_REQ_HI+1 + FSAB_DID_HI+1 + FSAB_DID_HI+1 + FSAB_ADDR_HI+1 + FSAB_LEN_HI)
	reg [FSAB_CREDITS_HI:0] rfif_wpos_0a = 'h0;
	reg [FSAB_CREDITS_HI:0] rfif_rpos_0a = 'h0;
	reg [`SIMMEM_RFIF_HI:0] rfif_fifo [(FSAB_INITIAL_CREDITS-1):0];
	wire rfif_wr_0a;
	wire rfif_rd_0a;
	wire [`SIMMEM_RFIF_HI:0] rfif_wdat_0a;
	reg [`SIMMEM_RFIF_HI:0] rfif_rdat_1a;
	wire rfif_empty_0a = (rfif_rpos_0a == rfif_wpos_0a);
	wire rfif_full_0a = (rfif_wpos_0a == (rfif_rpos_0a + FSAB_INITIAL_CREDITS));
	
	always @(posedge clk or negedge rst_b)
		if (!rst_b) begin
			rfif_wpos_0a <= 'h0;
			rfif_rpos_0a <= 'h0;
		end else begin
			if (rfif_rd_0a) begin
				$display("SIMMEM: %5d: reading from rfif", $time);
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				rfif_rdat_1a <= rfif_fifo[rfif_rpos_0a[1:0]];
				rfif_rpos_0a <= rfif_rpos_0a + 'h1;
			end
			
			if (rfif_wr_0a) begin
				$display("SIMMEM: %5d: writing to rfif (%d word %s)", $time, fsabo_len, (fsabo_mode == FSAB_WRITE) ? "write" : "read");
				rfif_fifo[rfif_wpos_0a[1:0]] <= rfif_wdat_0a;
				rfif_wpos_0a <= rfif_wpos_0a + 'h1;
			end
		end
	
	always @(posedge clk) begin
		assert (!(rfif_empty_0a && rfif_rd_0a)) else $error("RFIF rd while empty");
		assert (!(rfif_full_0a  && rfif_wr_0a)) else $error("RFIF wr while full");
	end
	
	/*** RFIF demux & control ***/
	wire [FSAB_REQ_HI:0]  rfif_mode_1a;
	wire [FSAB_DID_HI:0]  rfif_did_1a;
	wire [FSAB_DID_HI:0]  rfif_subdid_1a;
	wire [FSAB_ADDR_HI:0] rfif_addr_1a;
	wire [FSAB_LEN_HI:0]  rfif_len_1a;
	
	/* rfif_rd is assigned later */
	
	assign {rfif_mode_1a, rfif_did_1a, rfif_subdid_1a, rfif_addr_1a,
	        rfif_len_1a} = rfif_rdat_1a;
	assign rfif_wdat_0a = {fsabo_mode, fsabo_did, fsabo_subdid,
	                       fsabo_addr, fsabo_len};
	reg [FSAB_LEN_HI:0] fsabo_cur_req_len_rem_1a = 0;
	wire fsabo_cur_req_done_1a = (fsabo_cur_req_len_rem_1a == 0 /* we were done long ago */ || 
	                              fsabo_cur_req_len_rem_1a == 1 /* last cycle (1a) was the last word;
								       this cycle (0a), len will be 0 */);
	assign rfif_wr_0a = fsabo_valid && fsabo_cur_req_done_1a;
	
	always @(posedge clk or negedge rst_b)
		if (!rst_b) begin
			fsabo_cur_req_len_rem_1a <= 0;
		end else begin
			if (fsabo_valid && fsabo_cur_req_done_1a && (fsabo_mode == FSAB_WRITE))
				fsabo_cur_req_len_rem_1a <= fsabo_len;
			else if (fsabo_valid && fsabo_cur_req_len_rem_1a != 0)
				fsabo_cur_req_len_rem_1a <= fsabo_cur_req_len_rem_1a - 1;
		end
	
	/*** Inbound data FIFO (DFIF) ***/
`define SIMMEM_DFIF_MAX ((FSAB_INITIAL_CREDITS * FSAB_LEN_MAX) - 1)
`define SIMMEM_DFIF_HI ($clog2(`SIMMEM_DFIF_MAX) - 1)
	reg [`SIMMEM_DFIF_HI:0] dfif_wpos_0a = 'h0;
	reg [`SIMMEM_DFIF_HI:0] dfif_rpos_0a = 'h0;
	reg [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_fifo [`SIMMEM_DFIF_MAX:0];
	wire dfif_wr_0a;
	wire dfif_rd_0a;
	wire [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_wdat_0a;
	reg [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_rdat_1a;
	wire dfif_empty_0a = (dfif_rpos_0a == dfif_wpos_0a);
	wire dfif_full_0a = (dfif_wpos_0a == (dfif_rpos_0a + `SIMMEM_DFIF_MAX));
	wire [`SIMMEM_DFIF_HI:0] dfif_avail_0a = dfif_wpos_0a - dfif_rpos_0a;
	
	always @(posedge clk or negedge rst_b)
		if (!rst_b) begin
			dfif_wpos_0a <= 'h0;
			dfif_rpos_0a <= 'h0;
		end else begin
			if (dfif_rd_0a) begin
				$display("SIMMEM: %5d: reading from dfif (ad %d, da %x)", $time, dfif_rpos_0a, dfif_fifo[dfif_rpos_0a]);
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				dfif_rdat_1a <= dfif_fifo[dfif_rpos_0a];
				dfif_rpos_0a <= dfif_rpos_0a + 'h1;
			end else begin
				dfif_rdat_1a <= {(FSAB_DATA_HI+1 + FSAB_MASK_HI+1){1'hx}};
			end
			
			if (dfif_wr_0a) begin
				$display("SIMMEM: %5d: writing to dfif (ad %d, %08b mask, %08x data)", $time, dfif_wpos_0a, fsabo_mask, fsabo_data);
				dfif_fifo[dfif_wpos_0a] <= dfif_wdat_0a;
				dfif_wpos_0a <= dfif_wpos_0a + 'h1;
			end
		end
	
	always @(posedge clk) begin
		assert (!(dfif_empty_0a && dfif_rd_0a)) else $error("DFIF rd while empty");
		assert (!(dfif_full_0a  && dfif_wr_0a)) else $error("DFIF wr while full");
		// assert (`SIMMEM_DFIF_MAX == (({1'b1, {`SIMMEM_DFIF_HI{1'b0}}}) - 1)) else $error("DFIF size invalid");
		// Assertion removed due to Verilator bug in calculating $clog2 in non-size expressions
	end
	
	/*** DFIF demux & control */
	wire [FSAB_DATA_HI:0] dfif_data_1a;
	wire [FSAB_MASK_HI:0] dfif_mask_1a;
	
	/* dfif_rd is assigned later */
	assign {dfif_data_1a,dfif_mask_1a} = dfif_rdat_1a;
	assign dfif_wdat_0a = {fsabo_data,fsabo_mask};
	assign dfif_wr_0a = fsabo_valid;
	/* NOTE: this means that dfif_rd must ALWAYS be asserted along with
	 * rfif_rd...  even if len is 0, or even if the request was a read!
	 */
	
	/*** Pipe-throughs ***/
	reg rfif_rd_1a = 0;
	reg dfif_rd_1a = 0;
	always @(posedge clk or negedge rst_b)
		if (!rst_b) begin
			rfif_rd_1a <= 0;
			dfif_rd_1a <= 0;
		end else begin
			rfif_rd_1a <= rfif_rd_0a;
			dfif_rd_1a <= dfif_rd_0a;
		end
	
	/*** Memory control logic ***/
	reg [63:0] simmem [(SIMMEM_SIZE / 8):0];
	reg [31:0] simmem32 [(SIMMEM_SIZE / 4):0];
	integer f;
	initial
	begin
		assert(FSAB_DATA_HI == 63) else $error("FSAB_DATA_HI unsupported");
		for (f = 0; f < SIMMEM_SIZE / 8; f++)
			simmem[f] = 64'h0000000000000000;
	end
	
	
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
	 * in the dfif yet.
	 */
	assign fsabo_credit = mem_cur_req_active_1a && !mem_cur_req_active_0a;
	
	/* TODO: This means that dfif does one read, then pauses one cycle,
	 * then continues doing the read until we run out of data.  Can the
	 * one-cycle pause be removed easily?
	 */
	assign rfif_rd_0a = !rfif_empty_0a && !mem_cur_req_active_0a && !rfif_rd_1a;
	assign dfif_rd_0a = rfif_rd_0a || /* We must always do a read from dfif on rfif. */
	                    (mem_cur_req_active_0a &&
	                     (rfif_mode_1a == FSAB_WRITE) &&
	                     (mem_cur_req_len_rem_0a != 'h1) &&
	                     (mem_cur_req_len_rem_0a != 'h0));
	
	assign mem_cur_req_addr_1a = rfif_rd_1a ?
	                                 rfif_addr_1a :
	                                 mem_cur_req_addr_1a_r;
	
	assign fsabi_valid = mem_cur_req_active_0a &&
	                     (rfif_mode_1a == FSAB_READ) &&
	                     (mem_cur_req_len_rem_0a != 'h0);
	assign fsabi_did = rfif_did_1a;
	assign fsabi_subdid = rfif_subdid_1a;
	/* verilator lint_off WIDTH */
	assign fsabi_data = simmem[mem_cur_req_addr_1a[FSAB_ADDR_HI:3]];
	/* verilator lint_on WIDTH */
	
	/* This reg is not actually a flop; it is storage for behavioral
	 * data masking.  */
	integer i;
	integer j;
	reg [FSAB_DATA_HI:0] masked_data;
	
	always @(posedge clk or negedge rst_b)
		if (!rst_b) begin
			mem_cur_req_len_rem_0a <= 'h0;
			mem_cur_req_active_0a <= 0;
			mem_cur_req_active_1a <= 0;
			mem_cur_req_addr_1a_r <= 0;
		end else begin
			mem_cur_req_active_1a <= mem_cur_req_active_0a;
		
			if (rfif_rd_1a) begin
				$display("SIMMEM: %5d: RFIF was just read; it was a %d word %s at %08x", $time, rfif_len_1a, (rfif_mode_1a == FSAB_WRITE) ? "WRITE" : "READ", rfif_addr_1a);
				mem_cur_req_active_0a <= 1;
				mem_cur_req_len_rem_0a <= rfif_len_1a;
			end else if (dfif_rd_0a || fsabi_valid)
				mem_cur_req_len_rem_0a <= mem_cur_req_len_rem_0a - 1;
			else if (mem_cur_req_len_rem_0a == 'h1 || mem_cur_req_len_rem_0a == 'h0) begin
				mem_cur_req_active_0a <= 0;
			end
			
			if (dfif_rd_1a && (rfif_mode_1a == FSAB_WRITE)) begin
				/* verilator lint_off WIDTH */ /* for memory neq FSAB_ADDR size */
				/* This is the wonderful thing about being a behavioral simulation. */
				for (i = 0; i <= FSAB_MASK_HI; i = i + 1)
					for (j = 0; j < 8; j = j + 1)
						masked_data[i*8 + j] =
							dfif_mask_1a[i] ?
								dfif_data_1a[i*8 + j] :
								simmem[mem_cur_req_addr_1a[FSAB_ADDR_HI:FSAB_ADDR_LO]][i*8 + j];
				$display("SIMMEM: %5d: writing %016x data (%08b mask) to %08x address (old value %016x)", $time, dfif_data_1a, dfif_mask_1a, {mem_cur_req_addr_1a[FSAB_ADDR_HI:FSAB_ADDR_LO], 3'b0}, simmem[mem_cur_req_addr_1a[FSAB_ADDR_HI:FSAB_ADDR_LO]]);
				simmem[mem_cur_req_addr_1a[FSAB_ADDR_HI:FSAB_ADDR_LO]] <= masked_data;
				/* verilator lint_on WIDTH */ /* for memory neq FSAB_ADDR size */
			end
			
			if (rfif_rd_1a)
				mem_cur_req_addr_1a_r <= rfif_addr_1a;
			else if (dfif_rd_0a || fsabi_valid)
				mem_cur_req_addr_1a_r <= mem_cur_req_addr_1a + (FSAB_DATA_HI + 1) / 8;
		end
	
endmodule
