module FSABArbiter(
	input                                       clk,
	input                                       Nrst,
	
	input [FSAB_DEVICES-1:0]                    fsabo_valids,
	input [(FSAB_DEVICES*(FSAB_REQ_HI+1))-1:0]  fsabo_modes,
	input [(FSAB_DEVICES*(FSAB_DID_HI+1))-1:0]  fsabo_dids,
	input [(FSAB_DEVICES*(FSAB_DID_HI+1))-1:0]  fsabo_subdids,
	input [(FSAB_DEVICES*(FSAB_ADDR_HI+1))-1:0] fsabo_addrs,
	input [(FSAB_DEVICES*(FSAB_LEN_HI+1))-1:0]  fsabo_lens,
	input [(FSAB_DEVICES*(FSAB_DATA_HI+1))-1:0] fsabo_datas,
	input [(FSAB_DEVICES*(FSAB_MASK_HI+1))-1:0] fsabo_masks,
	output wire [FSAB_DEVICES-1:0]              fsabo_credits,
	
	output wire                                 fsabo_valid,
	output wire [FSAB_REQ_HI:0]                 fsabo_mode,
	output wire [FSAB_DID_HI:0]                 fsabo_did,
	output wire [FSAB_DID_HI:0]                 fsabo_subdid,
	output wire [FSAB_ADDR_HI:0]                fsabo_addr,
	output wire [FSAB_LEN_HI:0]                 fsabo_len,
	output wire [FSAB_DATA_HI:0]                fsabo_data,
	output wire [FSAB_MASK_HI:0]                fsabo_mask,
	input                                       fsabo_credit
	);

`include "fsab_defines.vh"
	parameter FSAB_DEVICES = 1;	/* Can be changed externally. */

	parameter FSAB_DEVICES_HI = $clog2(FSAB_DEVICES+1)-1;

	/* The theory internal to these state machines (generated with a
	 * genvar, so that we can split out the input bit vectors) is that
	 * they will deassert empty (by raising empty_b to 1) when they have
	 * an entry in the FIFO ready to be delivered.
	 *
	 * Once a FIFO has something ready, it is activated with a one-clock
	 * pulse on fifo_start.  It then has control of the bus until it
	 * deasserts fifo_active, during which time it should deliver
	 * exactly one transaction.
	 */

	/*** Input request buffering state machines ***/
	wire                  fifo_valid [FSAB_DEVICES-1:0];
	wire [FSAB_REQ_HI:0]  fifo_mode [FSAB_DEVICES-1:0];
	wire [FSAB_DID_HI:0]  fifo_did [FSAB_DEVICES-1:0];
	wire [FSAB_DID_HI:0]  fifo_subdid [FSAB_DEVICES-1:0];
	wire [FSAB_ADDR_HI:0] fifo_addr [FSAB_DEVICES-1:0];
	wire [FSAB_LEN_HI:0]  fifo_len [FSAB_DEVICES-1:0];
	wire [FSAB_DATA_HI:0] fifo_data [FSAB_DEVICES-1:0];
	wire [FSAB_MASK_HI:0] fifo_mask [FSAB_DEVICES-1:0];
	wire                  fifo_credit [FSAB_DEVICES-1:0];
	wire [FSAB_DEVICES-1:0] fifo_empty_b;
	wire [FSAB_DEVICES-1:0] fifo_active;
	reg  [FSAB_DEVICES-1:0] fifo_start = {FSAB_DEVICES{1'b0}}; /* combinatorial */

	generate
	genvar i;
	for (i = 0; i < FSAB_DEVICES; i = i + 1) begin: fifos

`define ARB_BITS(HI) (i+1)*(HI+1)-1:i*(HI+1)
		
		FSABArbiterFIFO fifo(/*NOT AUTOINST: too much custom*/
				     // Outputs
				     .out_valid		(fifo_valid[i]),
				     .out_mode		(fifo_mode[i]),
				     .out_did		(fifo_did[i]),
				     .out_subdid	(fifo_subdid[i]),
				     .out_addr		(fifo_addr[i]),
				     .out_len		(fifo_len[i]),
				     .out_data		(fifo_data[i]),
				     .out_mask		(fifo_mask[i]),
				     .inp_credit        (fsabo_credits[i]),
				     .empty_b		(fifo_empty_b[i]),
				     .active		(fifo_active[i]),
				     // Inputs
				     .clk		(clk),
				     .Nrst		(Nrst),
				     .inp_valid		(fsabo_valids[i]),
				     .inp_mode		(fsabo_modes[`ARB_BITS(FSAB_REQ_HI)]),
				     .inp_did		(fsabo_dids[`ARB_BITS(FSAB_DID_HI)]),
				     .inp_subdid	(fsabo_subdids[`ARB_BITS(FSAB_DID_HI)]),
				     .inp_addr		(fsabo_addrs[`ARB_BITS(FSAB_ADDR_HI)]),
				     .inp_len		(fsabo_lens[`ARB_BITS(FSAB_LEN_HI)]),
				     .inp_data		(fsabo_data[`ARB_BITS(FSAB_DATA_HI)]),
				     .inp_mask		(fsabo_masks[`ARB_BITS(FSAB_MASK_HI)]),
				     .start		(fifo_start[i]));
	end
	endgenerate
	
	/*** Outbound credit availability ***/
	reg [FSAB_CREDITS_HI:0] fsab_credits = FSAB_INITIAL_CREDITS;
	wire fsab_credit_avail = (fsab_credits != 0);
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			fsab_credits <= FSAB_INITIAL_CREDITS;
		end else begin
			if (fsabo_credit | (|fifo_start))
				$display("DCACHE: Credits: %d (+%d, -%d)", fsab_credits, fsabo_credit, fsabo_valid);
			fsab_credits <= fsab_credits + (fsabo_credit ? 1 : 0) - ((|fifo_start) ? 1 : 0);
		end
	
	/*** Device selection ***/
	reg [FSAB_DEVICES_HI:0] current_device_next = {(FSAB_DEVICES_HI+1){1'b0}};
	reg [FSAB_DEVICES_HI:0] current_device = {(FSAB_DEVICES_HI+1){1'b0}};
	wire new_selection = !fifo_active[current_device];

	/* XXX: Currently, selection is unfair (the largest numbered device
	 * gets to go the most often).  It would be nice to make this fair.
	 */

	integer ii;	/* must be distinct from 'i', due to genvar i */
	/* verilator lint_off WIDTH */ /* assigning an int to a reg */
	always @(*) begin
		current_device_next = {(FSAB_DEVICES_HI+1){1'b0}};
		for (ii = 0; ii < FSAB_DEVICES; ii = ii + 1)
			if (fifo_empty_b[ii])
				current_device_next = ii;
	end
	/* verilator lint_on WIDTH */ /* assigning an int to a reg */
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			current_device <= {(FSAB_DEVICES_HI+1){1'b0}};
		end else begin
			if (new_selection)
				current_device <= current_device_next;
		end
	
	/* verilator lint_off WIDTH */ /* comparing an int to a reg */
	always @(*)
		for (ii = 0; ii < FSAB_DEVICES; ii = ii + 1)
			fifo_start[ii] = new_selection && (current_device_next == ii) && fsab_credit_avail;
	/* verilator lint_on WIDTH */ /* comparing an int to a reg */
	
	/*** Output routing ***/
	assign fsabo_valid = fifo_valid[current_device] & fifo_active[current_device];	/* Mask off bogons that might be left over. */
	assign fsabo_mode = fifo_mode[current_device];
	assign fsabo_did = fifo_did[current_device];
	assign fsabo_subdid = fifo_subdid[current_device];
	assign fsabo_addr = fifo_addr[current_device];
	assign fsabo_len = fifo_len[current_device];
	assign fsabo_data = fifo_data[current_device];
	assign fsabo_mask = fifo_mask[current_device];
	
endmodule
