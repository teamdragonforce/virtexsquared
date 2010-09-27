`define FSAB_DEVICES_MAX (16)
`define FSAB_RFIF_HI (FSAB_REQ_HI+1 + FSAB_DID_HI+1 + FSAB_DID_HI+1 + FSAB_ADDR_HI+1 + FSAB_LEN_HI)

module RFIFO (
	input write,
	input clk,
	input Nrst,
	input [FSAB_RFIF_HI:0] request, 
	output [FSAB_RFIF_HI:0] req_out
	);
	
	reg [FSAB_CREDITS_HI:0] rfif_wpos_0a = 'h0;
	reg [FSAB_CREDITS_HI:0] rfif_rpos_0a = 'h0;
	reg [`FSAB_RFIF_HI:0] rfif_fifo [(FSAB_INITIAL_CREDITS-1):0];
	wire rfif_wr_0a;
	wire rfif_rd_0a;
	wire [`FSAB_RFIF_HI:0] rfif_wdat_0a;
	reg [`FSAB_RFIF_HI:0] rfif_rdat_1a;
	wire rfif_empty_0a = (rfif_rpos_0a == rfif_wpos_0a);
	wire rfif_full_0a = (rfif_wpos_0a == (rfif_rpos_0a + FSAB_INITIAL_CREDITS));
	
	assign rfif_rd_0a = write;
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
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
		assert (rfif_empty_0a && rfif_rd_0a) else $error("RFIF rd while empty");
		assert (rfif_full_0a  && rfif_wr_0a) else $error("RFIF wr while full");
	end
	
		/*** RFIF demux & control ***/
	wire [FSAB_REQ_HI:0]  rfif_mode_1a;
	wire [FSAB_DID_HI:0]  rfif_did_1a;
	wire [FSAB_DID_HI:0]  rfif_subdid_1a;
	wire [FSAB_ADDR_HI:0] rfif_addr_1a;
	wire [FSAB_LEN_HI:0]  rfif_len_1a;
	
	/* rfif_rd is assigned later */
	assign req_out = rfif_rdat_1a;
	assign rfif_wdat_0a = request;
	reg [FSAB_LEN_HI:0] fsabo_cur_req_len_rem_1a = 0;
	wire fsabo_cur_req_done_1a = (fsabo_cur_req_len_rem_1a == 0 /* we were done long ago */ || 
	                              fsabo_cur_req_len_rem_1a == 1 /* last cycle (1a) was the last word;
								       this cycle (0a), len will be 0 */);
	assign rfif_wr_0a = write && fsabo_cur_req_done_1a;
	
	always @(posedge clk or negedge Nrst)
		if (Nrst) begin
			fsabo_cur_req_len_rem_1a <= 0;
		end else begin
			if (fsabo_valid && fsabo_cur_req_done_1a && (request[FSAB_RFIF_HI] == FSAB_WRITE))
				fsabo_cur_req_len_rem_1a <= request[FSAB_LEN_HI:0];
			else if (fsabo_valid && fsabo_cur_req_len_rem_1a != 0)
				fsabo_cur_req_len_rem_1a <= fsabo_cur_req_len_rem_1a - 1;
		end
		
endmodule

module BusArbiter(
	input clk,
	input Nrst,
	input fsabo_valids[FSAB_DEVICES_MAX],
	input [FSAB_REQ_HI:0] fsabo_modes [FSAB_DEVICES_MAX],
	input [FSAB_DID_HI:0] fsabo_dids [FSAB_DEVICES_MAX],
	input [FSAB_DID_HI:0] fsabo_subdids [FSAB_DEVICES_MAX],
	input [FSAB_ADDR_HI:0] fsabo_addrs [FSAB_DEVICES_MAX],
	input [FSAB_LEN_HI:0] fsabo_lens [FSAB_DEVICES_MAX],
	input [FSAB_DATA_HI:0] fsabo_datas [FSAB_DEVICES_MAX],
	input [FSAB_MASK_HI:0] fsabo_masks [FSAB_DEVICES_MAX],
	
	output reg                  fsabo_valid,
	output reg [FSAB_REQ_HI:0]  fsabo_mode,
	output reg [FSAB_DID_HI:0]  fsabo_did,
	output reg [FSAB_DID_HI:0]  fsabo_subdid,
	output reg [FSAB_ADDR_HI:0] fsabo_addr,
	output reg [FSAB_LEN_HI:0]  fsabo_len,
	output reg [FSAB_DATA_HI:0] fsabo_data,
	output reg [FSAB_MASK_HI:0] fsabo_mask,
	input                       fsabo_credit,
	input clk
	);
	
	wire [FSAB_RFIF_HI:0] req_out [FSAB_DEVICES_MAX];

	RFIF rfifs[FSAB_DEVICES_MAX](.write(fsabo_valids,
				     .clk(clk),
				     .Nrst(Nrst),
		.request({fsabo_modes,fsabo_dids,fsabo_subdids,
			fsabo_addrs,fsabo_lens}),
				      .req_out(req_out),
				       );
	
	
	
endmodule
