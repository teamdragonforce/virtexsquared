
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
	`include "dma_config_defines.vh"

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
	wire [63:0]	data;			// From dmacontroller of SimpleDMAReadController.v
	wire		data_ready;		// From dmacontroller of SimpleDMAReadController.v
	wire		dmac__spami_busy_b;	// From dmacontroller of SimpleDMAReadController.v
	wire [SPAM_DATA_HI:0] dmac__spami_data;	// From dmacontroller of SimpleDMAReadController.v
	// End of automatics

	wire                  spamo_valid;
	wire                  spamo_r_nw;
	wire [SPAM_DID_HI:0]  spamo_did;
	wire [SPAM_ADDR_HI:0] spamo_addr;
	wire [SPAM_DATA_HI:0] spamo_data;

	assign spamo_r_nw = 0;
	assign spamo_did = SPAM_DID_DMAC;

	reg request;

	/* SimpleDMAReadController AUTO_TEMPLATE (
                                   .core_rst_b(rst_b),
	                           .core_clk(clk),
	                           .frame_clk(clk),
	                           .frame_rst_b(rst_b),
	                           );
	*/
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
					      .data		(data[63:0]),
					      .data_ready	(data_ready),
					      .dmac__spami_busy_b(dmac__spami_busy_b),
					      .dmac__spami_data	(dmac__spami_data[SPAM_DATA_HI:0]),
					      // Inputs
					      .core_clk		(clk),		 // Templated
					      .core_rst_b	(rst_b),	 // Templated
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
					      .spamo_data	(spamo_data[SPAM_DATA_HI:0]),
					      .frame_clk	(clk),		 // Templated
					      .frame_rst_b	(rst_b),	 // Templated
					      .request		(request));
	defparam dmacontroller.FSAB_DID = FSAB_DID_CPU;
	defparam dmacontroller.FSAB_SUBDID = FSAB_SUBDID_CPU_DMAC;
	defparam dmacontroller.SPAM_DID = SPAM_DID_DMAC;
	defparam dmacontroller.FIFO_DEPTH = 16;
	defparam dmacontroller.SPAM_ADDRPFX = 24'h000000;
	defparam dmacontroller.SPAM_ADDRMASK = 24'h000000;
	defparam dmacontroller.DEFAULT_LEN = 31'h0000100;

	integer i = 0;
	reg start_reading = 0;

	always @(*) begin
		spamo_valid = 0;
		request = 0;
		spamo_addr = 24'h000000;
		case (i)
			'd0: begin
				spamo_valid = 1;
				spamo_addr = 24'h00000c;
				spamo_data = 32'h000002; 
			end
		endcase
		if (i > 10000 & (i % 100 == 0)) begin
			request = 1;
		end
	end

	always @ (posedge clk) begin
		i <= i+1;
		if (data_ready)
			$display("DMA_INTERFACE Data: %x", data);
	end

endmodule
