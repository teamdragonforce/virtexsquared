
module SimpleDMAReadControllerTester(/*AUTOARG*/
   // Outputs
   dmac__fsabo_valid, dmac__fsabo_mode, dmac__fsabo_did,
   dmac__fsabo_subdid, dmac__fsabo_addr, dmac__fsabo_len,
   dmac__fsabo_data, dmac__fsabo_mask,
   // Inputs
   dmac__fsabo_credit, fsabi_clk, fsabi_rst_b, fsabi_valid, fsabi_did,
   fsabi_subdid, fsabi_data, clk, rst_b
   );

	`include "fsab_defines.vh"
	`include "spam_defines.vh"

	output reg                  dmac__fsabo_valid = 0;
	output reg [FSAB_REQ_HI:0]  dmac__fsabo_mode = 0;
	output reg [FSAB_DID_HI:0]  dmac__fsabo_did = 0;
	output reg [FSAB_DID_HI:0]  dmac__fsabo_subdid = 0;
	output reg [FSAB_ADDR_HI:0] dmac__fsabo_addr = 0;
	output reg [FSAB_LEN_HI:0]  dmac__fsabo_len = 0;
	output reg [FSAB_DATA_HI:0] dmac__fsabo_data = 0;
	output reg [FSAB_MASK_HI:0] dmac__fsabo_mask = 0;
	input                       dmac__fsabo_credit;
	input                       fsabi_clk;
	input                       fsabi_rst_b;
	input                       fsabi_valid;
	input      [FSAB_DID_HI:0]  fsabi_did;
	input      [FSAB_DID_HI:0]  fsabi_subdid;
	input      [FSAB_DATA_HI:0] fsabi_data;
	input                       clk;
	input                       rst_b;

	/*AUTOWIRE*/
	// Beginning of automatic wires (for undeclared instantiated-module outputs)
	wire		dmac__spami_busy_b;	// From dmacontroller of SimpleDMAReadController.v
	wire [63:0]	dmac__spami_data;	// From dmacontroller of SimpleDMAReadController.v
	// End of automatics

	wire                  spamo_valid;
	wire                  spamo_r_nw;
	wire [SPAM_DID_HI:0]  spamo_did;
	wire [SPAM_ADDR_HI:0] spamo_addr;
	wire [SPAM_DATA_HI:0] spamo_data;

	assign spamo_r_nw = 1;
	assign spamo_did = SPAM_DID_DMAC;
	assign spamo_addr = 0;

	SimpleDMAReadController dmacontroller(/*AUTOINST*/
					      // Outputs
					      .dmac__fsabo_valid(dmac__fsabo_valid),
					      .dmac__fsabo_mode	(dmac__fsabo_mode[FSAB_REQ_HI:0]),
					      .dmac__fsabo_did	(dmac__fsabo_did[FSAB_DID_HI:0]),
					      .dmac__fsabo_subdid(dmac__fsabo_subdid[FSAB_DID_HI:0]),
					      .dmac__fsabo_addr	(dmac__fsabo_addr[FSAB_ADDR_HI:0]),
					      .dmac__fsabo_len	(dmac__fsabo_len[FSAB_LEN_HI:0]),
					      .dmac__fsabo_data	(dmac__fsabo_data[FSAB_DATA_HI:0]),
					      .dmac__fsabo_mask	(dmac__fsabo_mask[FSAB_MASK_HI:0]),
					      .dmac__spami_busy_b(dmac__spami_busy_b),
					      .dmac__spami_data	(dmac__spami_data[63:0]),
					      // Inputs
					      .clk		(clk),
					      .rst_b		(rst_b),
					      .dmac__fsabo_credit(dmac__fsabo_credit),
					      .fsabi_clk	(fsabi_clk),
					      .fsabi_rst_b	(fsabi_rst_b),
					      .fsabi_valid	(fsabi_valid),
					      .fsabi_did	(fsabi_did[FSAB_DID_HI:0]),
					      .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
					      .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]),
					      .spamo_valid	(spamo_valid),
					      .spamo_r_nw	(spamo_r_nw),
					      .spamo_did	(spamo_did[SPAM_DID_HI:0]),
					      .spamo_addr	(spamo_addr[SPAM_ADDR_HI:0]),
					      .spamo_data	(spamo_data[SPAM_DATA_HI:0]));
	defparam dmacontroller.FSAB_DID = FSAB_DID_CPU;
	defparam dmacontroller.FSAB_SUBDID = FSAB_SUBDID_CPU_DMAC;
	defparam dmacontroller.SPAM_DID = SPAM_DID_DMAC;
	defparam dmacontroller.FIFO_DEPTH = 16;

	integer i = 0;
	reg start_reading = 0;
	always @ (posedge clk)
	begin
		i <= i + 1;
		if (i == 10000)
			start_reading <= 1;
		if (start_reading)
		begin
			if ((i & 'hFFFF) == 0)
				spamo_valid = 1;
			else
				spamo_valid = 0;
		end
	end
		

endmodule
