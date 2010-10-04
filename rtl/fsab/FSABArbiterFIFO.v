module FSABArbiterFIFO(
	input clk,
	input Nrst,
	
	input                        inp_valid,
	input       [FSAB_REQ_HI:0]  inp_mode,
	input       [FSAB_DID_HI:0]  inp_did,
	input       [FSAB_DID_HI:0]  inp_subdid,
	input       [FSAB_ADDR_HI:0] inp_addr,
	input       [FSAB_LEN_HI:0]  inp_len,
	input       [FSAB_DATA_HI:0] inp_data,
	input       [FSAB_MASK_HI:0] inp_mask,
	output wire                  inp_credit,
	
	output wire                  out_valid,
	output wire [FSAB_REQ_HI:0]  out_mode,
	output wire [FSAB_DID_HI:0]  out_did,
	output wire [FSAB_DID_HI:0]  out_subdid,
	output wire [FSAB_ADDR_HI:0] out_addr,
	output wire [FSAB_LEN_HI:0]  out_len,
	output wire [FSAB_DATA_HI:0] out_data,
	output wire [FSAB_MASK_HI:0] out_mask,
	
	output wire                  empty_b,
	input                        start,
	output wire                  active
	);

`include "fsab_defines.vh"

	/*** Stubs ***/
	assign inp_credit = 0;
	assign out_valid = 0;
	assign out_mode = 0;
	assign out_did = 0;
	assign out_subdid = 0;
	assign out_addr = 0;
	assign out_len = 0;
	assign out_data = 0;
	assign out_mask = 0;
	assign empty_b = 0;
	assign active = 0;

	/*** Inbound request FIFO (RFIF) ***/
	reg [FSAB_CREDITS_HI:0] rfif_wpos_0a = 'h0;
	reg [FSAB_CREDITS_HI:0] rfif_rpos_0a = 'h0;
	reg [ARB_RFIF_HI:0] rfif_fifo [(FSAB_INITIAL_CREDITS-1):0];
	wire rfif_wr_0a;
	wire rfif_rd_0a;
	wire [ARB_RFIF_HI:0] rfif_wdat_0a;
	reg [ARB_RFIF_HI:0] rfif_rdat_1a;
	wire rfif_empty_0a = (rfif_rpos_0a == rfif_wpos_0a);
	wire rfif_full_0a = (rfif_wpos_0a == (rfif_rpos_0a + FSAB_INITIAL_CREDITS));
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			rfif_wpos_0a <= 'h0;
			rfif_rpos_0a <= 'h0;
		end else begin
			if (rfif_rd_0a) begin
				$display("ARB: %5d: reading from rfif", $time);
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				rfif_rdat_1a <= rfif_fifo[rfif_rpos_0a[1:0]];
				rfif_rpos_0a <= rfif_rpos_0a + 'h1;
			end
			
			if (rfif_wr_0a) begin
				$display("ARB: %5d: writing to rfif (%d word %s)", $time, inp_len, (inp_mode == FSAB_WRITE) ? "write" : "read");
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
	assign rfif_wdat_0a = {inp_mode, inp_did, inp_subdid,
	                       inp_addr, inp_len};
	reg [FSAB_LEN_HI:0] inp_cur_req_len_rem_1a = 0;
	wire inp_cur_req_done_1a = (inp_cur_req_len_rem_1a == 0 /* we were done long ago */ || 
	                            inp_cur_req_len_rem_1a == 1 /* last cycle (1a) was the last word;
								       this cycle (0a), len will be 0 */);
	assign rfif_wr_0a = inp_valid && inp_cur_req_done_1a;
	
	always @(posedge clk or negedge Nrst)
		if (Nrst) begin
			inp_cur_req_len_rem_1a <= 0;
		end else begin
			if (inp_valid && inp_cur_req_done_1a && (inp_mode == FSAB_WRITE))
				inp_cur_req_len_rem_1a <= inp_len;
			else if (inp_valid && inp_cur_req_len_rem_1a != 0)
				inp_cur_req_len_rem_1a <= inp_cur_req_len_rem_1a - 1;
		end
	
	/*** Inbound data FIFO (DFIF) ***/
`define ARB_DFIF_MAX ((FSAB_INITIAL_CREDITS * FSAB_LEN_MAX) - 1)
`define ARB_DFIF_HI ($clog2(`ARB_DFIF_MAX) - 1)
	reg [`ARB_DFIF_HI:0] dfif_wpos_0a = 'h0;
	reg [`ARB_DFIF_HI:0] dfif_rpos_0a = 'h0;
	reg [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_fifo [`ARB_DFIF_MAX:0];
	wire dfif_wr_0a;
	wire dfif_rd_0a;
	wire [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_wdat_0a;
	reg [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_rdat_1a;
	wire dfif_empty_0a = (dfif_rpos_0a == dfif_wpos_0a);
	wire dfif_full_0a = (dfif_wpos_0a == (dfif_rpos_0a + `ARB_DFIF_MAX));
	wire [`ARB_DFIF_HI:0] dfif_avail_0a = dfif_wpos_0a - dfif_rpos_0a;
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			dfif_wpos_0a <= 'h0;
			dfif_rpos_0a <= 'h0;
		end else begin
			if (dfif_rd_0a) begin
				$display("ARB: %5d: reading from dfif (ad %d, da %x)", $time, dfif_rpos_0a, dfif_fifo[dfif_rpos_0a]);
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				dfif_rdat_1a <= dfif_fifo[dfif_rpos_0a];
				dfif_rpos_0a <= dfif_rpos_0a + 'h1;
			end else begin
				dfif_rdat_1a <= {(FSAB_DATA_HI+1 + FSAB_MASK_HI+1){1'hx}};
			end
			
			if (dfif_wr_0a) begin
				$display("ARB: %5d: writing to dfif (ad %d, %08b mask, %08x data)", $time, dfif_wpos_0a, inp_mask, inp_data);
				dfif_fifo[dfif_wpos_0a] <= dfif_wdat_0a;
				dfif_wpos_0a <= dfif_wpos_0a + 'h1;
			end
		end
	
	always @(posedge clk) begin
		assert (!(dfif_empty_0a && dfif_rd_0a)) else $error("DFIF rd while empty");
		assert (!(dfif_full_0a  && dfif_wr_0a)) else $error("DFIF wr while full");
		// assert (`ARB_DFIF_MAX == (({1'b1, {`ARB_DFIF_HI{1'b0}}}) - 1)) else $error("DFIF size invalid");
		// Assertion removed due to Verilator bug in calculating $clog2 in non-size expressions
	end
	
	/*** DFIF demux & control */
	wire [FSAB_DATA_HI:0] dfif_data_1a;
	wire [FSAB_MASK_HI:0] dfif_mask_1a;
	
	/* dfif_rd is assigned later */
	assign {dfif_data_1a,dfif_mask_1a} = dfif_rdat_1a;
	assign dfif_wdat_0a = {inp_data,inp_mask};
	assign dfif_wr_0a = inp_valid;
	/* NOTE: this means that dfif_rd must ALWAYS be asserted along with
	 * rfif_rd...  even if len is 0, or even if the request was a read!
	 */
	
	assign rfif_rd_0a = 0;
	assign dfif_rd_0a = 0;
endmodule
