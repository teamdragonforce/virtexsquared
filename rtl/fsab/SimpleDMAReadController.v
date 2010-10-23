module SimpleDMAReadController(/*AUTOARG*/
   // Outputs
   dmac__fsabo_valid, dmac__fsabo_mode, dmac__fsabo_did,
   dmac__fsabo_subdid, dmac__fsabo_addr, dmac__fsabo_len,
   dmac__fsabo_data, dmac__fsabo_mask, dmac__spami_busy_b,
   dmac__spami_data, data,
   // Inputs
   clk, rst_b, dmac__fsabo_credit, fsabi_clk, fsabi_rst_b,
   fsabi_valid, fsabi_did, fsabi_subdid, fsabi_data, spamo_valid,
   spamo_r_nw, spamo_did, spamo_addr, spamo_data, request
   );

	`include "fsab_defines.vh"
	`include "spam_defines.vh"
	
	input clk;
	input rst_b;

	/* FSAB interface */
	output reg                  dmac__fsabo_valid = 0;
	output reg [FSAB_REQ_HI:0]  dmac__fsabo_mode = 0;
	output reg [FSAB_DID_HI:0]  dmac__fsabo_did = 0;
	output reg [FSAB_DID_HI:0]  dmac__fsabo_subdid = 0;
	output reg [FSAB_ADDR_HI:0] dmac__fsabo_addr = 0;
	output reg [FSAB_LEN_HI:0]  dmac__fsabo_len = 0;
	output reg [FSAB_DATA_HI:0] dmac__fsabo_data = 0;
	output reg [FSAB_MASK_HI:0] dmac__fsabo_mask = 0;
	input                       dmac__fsabo_credit;
	input                       request;
	
	input                       fsabi_clk;
	input                       fsabi_rst_b;
	input                       fsabi_valid;
	input      [FSAB_DID_HI:0]  fsabi_did;
	input      [FSAB_DID_HI:0]  fsabi_subdid;
	input      [FSAB_DATA_HI:0] fsabi_data;
	
	input                       spamo_valid;
	input                       spamo_r_nw;
	input      [SPAM_DID_HI:0]  spamo_did;
	input      [SPAM_ADDR_HI:0] spamo_addr;
	input      [SPAM_DATA_HI:0] spamo_data;

	output reg [FSAB_DATA_HI:0] data;
	output reg                  ready = 0; 
	output reg                  dmac__spami_busy_b = 0;
	output reg [SPAM_DATA_HI:0] dmac__spami_data = 'h0;
	
	`include "clog2.vh"
	parameter FIFO_DEPTH = 128;
	parameter FIFO_HI = clog2(FIFO_DEPTH) - 2;
	
	parameter FSAB_DID = 4'hF;
	parameter FSAB_SUBDID = 4'hF;
	
	parameter SPAM_DID = 4'hx;
	parameter SPAM_ADDRPFX = 24'h000000;
	parameter SPAM_ADDRMASK = 24'h000000;

	parameter DEFAULT_ADDR = 31'h00000000;
	parameter DEFAULT_LEN = 31'h00000000;

`ifdef verilator	
	initial begin
		assert(FSAB_DID != 4'hF && FSAB_SUBDID != 4'hF && SPAM_DID != 4'hF) else $error("Unconfigured DID and SUBDID in SimpleDMAReadController");
	end
`endif

	/*** Queue of all the things read so far. ***/
	reg [FSAB_DATA_HI:0] fifo [(FIFO_DEPTH-1):0];
	reg [FIFO_HI:0] curr_fifo_length = 0;
	reg [FSAB_ADDR_HI:0] next_fsab_addr = DEFAULT_ADDR;

	wire start_read;	
	wire fifo_full;
	reg read_pending = 0;

	reg [FSAB_DATA_HI:0] fsabi_old_data;

        
	/*** FSAB credit availability logic ***/
	reg [FSAB_CREDITS_HI:0] fsab_credits = FSAB_INITIAL_CREDITS;
	wire fsab_credit_avail = (fsab_credits != 0);
	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			fsab_credits <= FSAB_INITIAL_CREDITS;
		end else begin
			if (dmac__fsabo_credit | start_trans)
				$display("PRELOAD: Credits: %d (+%d, -%d)", fsab_credits, dmac__fsabo_credit, start_trans);
			fsab_credits <= fsab_credits + (dmac__fsabo_credit ? 1 : 0) - (start_trans ? 1 : 0);
		end
	end


	/* TODO: This is only reading 8 bytes from FSAB at a time.
	   Needs to do a batch read. (Possibly reading 64 bytes at a time like a cache?) */
	assign fifo_full = (FIFO_DEPTH == curr_fifo_length);
	assign start_read = !fifo_full && !read_pending && fsab_credit_avail;

	always @(*)
	begin
		dmac__fsabo_valid = 0;
		dmac__fsabo_mode = {(FSAB_REQ_HI+1){1'bx}};
		dmac__fsabo_did = {(FSAB_DID_HI+1){1'bx}};
		dmac__fsabo_subdid = {(FSAB_DID_HI+1){1'bx}};
		dmac__fsabo_addr = {(FSAB_ADDR_HI+1){1'bx}};
		dmac__fsabo_len = {{FSAB_LEN_HI+1}{1'bx}};
		dmac__fsabo_data = {{FSAB_DATA_HI+1}{1'bx}};
		dmac__fsabo_mask = {{FSAB_MASK_HI+1}{1'bx}}
		if (start_read && rst_b)
		begin
			dmac__fsabo_valid = 1;
			dmac__fsabo_mode = FSAB_READ;
			dmac__fsabo_did = FSAB_DID;
			dmac__fsabo_subdid = FSAB_SUBDID;
			dmac__fsabo_addr = next_fsab_addr;
			dmac__fsabo_len = 'h1; 
		end	
	end

	reg current_read = 0;
	reg current_read_fclk_s1 = 0;
	reg current_read_fclk = 0;
	reg completed_read_fclk = 0;
	reg completed_read_s1 = 0;
	reg completed_read = 0;

	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			read_pending <= 0;
			current_read <= 0;
			completed_read <= 0;
			completed_read_s1 <= 0;
			curr_fifo_length <= 0;
			next_fsab_addr <= DEFAULT_ADDR;
		end else begin
			completed_read_s1 <= completed_read_fclk;
			completed_read <= completed_read_s1;

			if (start_read) begin
				read_pending <= 1;
				current_read <= ~current_read;
			end else if ((completed_read == current_read) && read_pending) begin
				read_pending <= 0;
				fifo[curr_fifo_length] <= fsabi_data;
				curr_fifo_length <= curr_fifo_length + 1;
				next_fsab_addr <= next_fsab_addr + 8;		
			end
		end
	end

	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin

		end else begin
			if (request && (curr_fifo_length > 0)) begin
				data <= fifo[0]; 	
				for (i = 1; i < curr_fifo_length; i = i+1) begin
					fifo[i] <= fifo[i-1];	
				end
				curr_fifo_length <= curr_fifo_length - 1;
				ready <= 1;
			end else if (request) begin
				ready <= 0;
			end
		end
	end
				
	always @(posedge fsabi_clk or negedge fsabi_rst_b) begin
		if (!fsabi_rst_b) begin
			current_read_fclk_s1 <= 0;
			current_read_fclk <= 0;
			completed_read_fclk <= 0;
		end else begin
			if (current_read_fclk ^ current_read_1a_fclk) begin

			end if (fsabi_valid && (fsabi_did == FSAB_DID) && (fsabi_subdid = FSAB_SUBDID)) begin
				completed_read_fclk <= current_read_fclk;
				fsabi_old_data <= fsabi_data;
			end
		end
	end

endmodule
