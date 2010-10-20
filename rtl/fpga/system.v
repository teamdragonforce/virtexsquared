module System(
   // Outputs
   ddr2_a, ddr2_ba, ddr2_cas_n, ddr2_ck, ddr2_ck_n, ddr2_cke, ddr2_cs_n,
   ddr2_dm, ddr2_odt, ddr2_ras_n, ddr2_we_n, phy_init_done,
   // Inouts
   ddr2_dq, ddr2_dqs, ddr2_dqs_n,
   // Inputs
   clk200_n, clk200_p, sys_clk_n, sys_clk_p, sys_rst_n,
   clk, rst
   );

	`include "memory_defines.vh"

	input clk; input rst;
	/* Ok, this autoinout thing has to go. */
	
	// Beginning of automatic inouts (from unused autoinst inouts)
	inout [DQ_WIDTH-1:0] ddr2_dq;		// To/From mem of FSABMemory.v
	inout [DQS_WIDTH-1:0] ddr2_dqs;		// To/From mem of FSABMemory.v
	inout [DQS_WIDTH-1:0] ddr2_dqs_n;	// To/From mem of FSABMemory.v
	// End of automatics
	// Beginning of automatic inputs (from unused autoinst inputs)
	input		clk200_n;		// To mem of FSABMemory.v
	input		clk200_p;		// To mem of FSABMemory.v
	input		sys_clk_n;		// To mem of FSABMemory.v
	input		sys_clk_p;		// To mem of FSABMemory.v
	input		sys_rst_n;		// To mem of FSABMemory.v
	// End of automatics
	// Beginning of automatic outputs (from unused autoinst outputs)
	output [ROW_WIDTH-1:0] ddr2_a;		// From mem of FSABMemory.v
	output [BANK_WIDTH-1:0] ddr2_ba;	// From mem of FSABMemory.v
	output		ddr2_cas_n;		// From mem of FSABMemory.v
	output [CLK_WIDTH-1:0] ddr2_ck;		// From mem of FSABMemory.v
	output [CLK_WIDTH-1:0] ddr2_ck_n;	// From mem of FSABMemory.v
	output [CKE_WIDTH-1:0] ddr2_cke;	// From mem of FSABMemory.v
	output [CS_WIDTH-1:0] ddr2_cs_n;	// From mem of FSABMemory.v
	output [DM_WIDTH-1:0] ddr2_dm;		// From mem of FSABMemory.v
	output [ODT_WIDTH-1:0] ddr2_odt;	// From mem of FSABMemory.v
	output		ddr2_ras_n;		// From mem of FSABMemory.v
	output		ddr2_we_n;		// From mem of FSABMemory.v
	output		phy_init_done;		// From mem of FSABMemory.v
	// End of automatics

`include "fsab_defines.vh"
`include "spam_defines.vh"
	
	/*AUTOWIRE*/
	// Beginning of automatic wires (for undeclared instantiated-module outputs)
	wire		cio__spami_busy_b;	// From conio of SPAM_ConsoleIO.v
	wire [SPAM_DATA_HI:0] cio__spami_data;	// From conio of SPAM_ConsoleIO.v
	wire [FSAB_ADDR_HI:0] dc__fsabo_addr;	// From core of Core.v
	wire		dc__fsabo_credit;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DATA_HI:0] dc__fsabo_data;	// From core of Core.v
	wire [FSAB_DID_HI:0] dc__fsabo_did;	// From core of Core.v
	wire [FSAB_LEN_HI:0] dc__fsabo_len;	// From core of Core.v
	wire [FSAB_MASK_HI:0] dc__fsabo_mask;	// From core of Core.v
	wire [FSAB_REQ_HI:0] dc__fsabo_mode;	// From core of Core.v
	wire [FSAB_DID_HI:0] dc__fsabo_subdid;	// From core of Core.v
	wire		dc__fsabo_valid;	// From core of Core.v
	wire		fsabi_clk;		// From mem of FSABMemory.v
	wire [FSAB_DATA_HI:0] fsabi_data;	// From mem of FSABMemory.v
	wire [FSAB_DID_HI:0] fsabi_did;		// From mem of FSABMemory.v
	wire [FSAB_DID_HI:0] fsabi_subdid;	// From mem of FSABMemory.v
	wire		fsabi_valid;		// From mem of FSABMemory.v
	wire [FSAB_ADDR_HI:0] fsabo_addr;	// From fsabarbiter of FSABArbiter.v
	wire		fsabo_credit;		// From mem of FSABMemory.v
	wire [FSAB_DATA_HI:0] fsabo_data;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DID_HI:0] fsabo_did;		// From fsabarbiter of FSABArbiter.v
	wire [FSAB_LEN_HI:0] fsabo_len;		// From fsabarbiter of FSABArbiter.v
	wire [FSAB_MASK_HI:0] fsabo_mask;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_REQ_HI:0] fsabo_mode;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DID_HI:0] fsabo_subdid;	// From fsabarbiter of FSABArbiter.v
	wire		fsabo_valid;		// From fsabarbiter of FSABArbiter.v
	wire [FSAB_ADDR_HI:0] ic__fsabo_addr;	// From core of Core.v
	wire		ic__fsabo_credit;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DATA_HI:0] ic__fsabo_data;	// From core of Core.v
	wire [FSAB_DID_HI:0] ic__fsabo_did;	// From core of Core.v
	wire [FSAB_LEN_HI:0] ic__fsabo_len;	// From core of Core.v
	wire [FSAB_MASK_HI:0] ic__fsabo_mask;	// From core of Core.v
	wire [FSAB_REQ_HI:0] ic__fsabo_mode;	// From core of Core.v
	wire [FSAB_DID_HI:0] ic__fsabo_subdid;	// From core of Core.v
	wire		ic__fsabo_valid;	// From core of Core.v
	wire [FSAB_ADDR_HI:0] pre__fsabo_addr;	// From preload of FSABPreload.v
	wire		pre__fsabo_credit;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DATA_HI:0] pre__fsabo_data;	// From preload of FSABPreload.v
	wire [FSAB_DID_HI:0] pre__fsabo_did;	// From preload of FSABPreload.v
	wire [FSAB_LEN_HI:0] pre__fsabo_len;	// From preload of FSABPreload.v
	wire [FSAB_MASK_HI:0] pre__fsabo_mask;	// From preload of FSABPreload.v
	wire [FSAB_REQ_HI:0] pre__fsabo_mode;	// From preload of FSABPreload.v
	wire [FSAB_DID_HI:0] pre__fsabo_subdid;	// From preload of FSABPreload.v
	wire		pre__fsabo_valid;	// From preload of FSABPreload.v
	wire		rst_core_b;		// From preload of FSABPreload.v
	wire [SPAM_ADDR_HI:0] spamo_addr;	// From core of Core.v
	wire [SPAM_DATA_HI:0] spamo_data;	// From core of Core.v
	wire [SPAM_DID_HI:0] spamo_did;		// From core of Core.v
	wire		spamo_r_nw;		// From core of Core.v
	wire		spamo_valid;		// From core of Core.v
	// End of automatics

	wire rst_b = ~rst;

`ifdef DUMMY
	stfu_verilog_mode and_i_mean_it(
					// Inputs
					.cio__spami_busy_b(cio__spami_busy_b),
					.cio__spami_data(cio__spami_data[SPAM_DATA_HI:0]));
`endif
	
	wire spami_busy_b = cio__spami_busy_b;
	wire [SPAM_DATA_HI:0] spami_data = cio__spami_data[SPAM_DATA_HI:0];

	parameter FSAB_DEVICES = 3;
	wire [FSAB_DEVICES-1:0] fsabo_clks = {clk, clk, clk};
	wire [FSAB_DEVICES-1:0] fsabo_rst_bs = {rst_b, rst_b, rst_b};

	/* Core AUTO_TEMPLATE (
		.rst_b(rst_core_b & rst_b),
		);
	*/
	Core core(/*AUTOINST*/
		  // Outputs
		  .ic__fsabo_valid	(ic__fsabo_valid),
		  .ic__fsabo_mode	(ic__fsabo_mode[FSAB_REQ_HI:0]),
		  .ic__fsabo_did	(ic__fsabo_did[FSAB_DID_HI:0]),
		  .ic__fsabo_subdid	(ic__fsabo_subdid[FSAB_DID_HI:0]),
		  .ic__fsabo_addr	(ic__fsabo_addr[FSAB_ADDR_HI:0]),
		  .ic__fsabo_len	(ic__fsabo_len[FSAB_LEN_HI:0]),
		  .ic__fsabo_data	(ic__fsabo_data[FSAB_DATA_HI:0]),
		  .ic__fsabo_mask	(ic__fsabo_mask[FSAB_MASK_HI:0]),
		  .dc__fsabo_valid	(dc__fsabo_valid),
		  .dc__fsabo_mode	(dc__fsabo_mode[FSAB_REQ_HI:0]),
		  .dc__fsabo_did	(dc__fsabo_did[FSAB_DID_HI:0]),
		  .dc__fsabo_subdid	(dc__fsabo_subdid[FSAB_DID_HI:0]),
		  .dc__fsabo_addr	(dc__fsabo_addr[FSAB_ADDR_HI:0]),
		  .dc__fsabo_len	(dc__fsabo_len[FSAB_LEN_HI:0]),
		  .dc__fsabo_data	(dc__fsabo_data[FSAB_DATA_HI:0]),
		  .dc__fsabo_mask	(dc__fsabo_mask[FSAB_MASK_HI:0]),
		  .spamo_valid		(spamo_valid),
		  .spamo_r_nw		(spamo_r_nw),
		  .spamo_did		(spamo_did[SPAM_DID_HI:0]),
		  .spamo_addr		(spamo_addr[SPAM_ADDR_HI:0]),
		  .spamo_data		(spamo_data[SPAM_DATA_HI:0]),
		  // Inputs
		  .clk			(clk),
		  .rst_b		(rst_core_b & rst_b),	 // Templated
		  .ic__fsabo_credit	(ic__fsabo_credit),
		  .dc__fsabo_credit	(dc__fsabo_credit),
		  .fsabi_valid		(fsabi_valid),
		  .fsabi_did		(fsabi_did[FSAB_DID_HI:0]),
		  .fsabi_subdid		(fsabi_subdid[FSAB_DID_HI:0]),
		  .fsabi_data		(fsabi_data[FSAB_DATA_HI:0]),
		  .fsabi_clk		(fsabi_clk),
		  .fsabi_rst_b		(fsabi_rst_b),
		  .spami_busy_b		(spami_busy_b),
		  .spami_data		(spami_data[SPAM_DATA_HI:0]));
	
	wire [8:0] sys_odata;
	wire sys_tookdata;
	wire [8:0] sys_idata = 0;

	SPAM_ConsoleIO conio(
		/*AUTOINST*/
			     // Outputs
			     .cio__spami_busy_b	(cio__spami_busy_b),
			     .cio__spami_data	(cio__spami_data[SPAM_DATA_HI:0]),
			     .sys_odata		(sys_odata[8:0]),
			     .sys_tookdata	(sys_tookdata),
			     // Inputs
			     .clk		(clk),
			     .spamo_valid	(spamo_valid),
			     .spamo_r_nw	(spamo_r_nw),
			     .spamo_did		(spamo_did[SPAM_DID_HI:0]),
			     .spamo_addr	(spamo_addr[SPAM_ADDR_HI:0]),
			     .spamo_data	(spamo_data[SPAM_DATA_HI:0]),
			     .sys_idata		(sys_idata[8:0]));

	/* FSABArbiter AUTO_TEMPLATE (
		.clk(fsabi_clk),
		.fsabo_valids({pre__fsabo_valid,ic__fsabo_valid,dc__fsabo_valid}),
		.fsabo_modes({pre__fsabo_mode[FSAB_REQ_HI:0],ic__fsabo_mode[FSAB_REQ_HI:0],dc__fsabo_mode[FSAB_REQ_HI:0]}),
		.fsabo_dids({pre__fsabo_did[FSAB_DID_HI:0],ic__fsabo_did[FSAB_DID_HI:0],dc__fsabo_did[FSAB_DID_HI:0]}),
		.fsabo_subdids({pre__fsabo_subdid[FSAB_DID_HI:0],ic__fsabo_subdid[FSAB_DID_HI:0],dc__fsabo_subdid[FSAB_DID_HI:0]}),
		.fsabo_addrs({pre__fsabo_addr[FSAB_ADDR_HI:0],ic__fsabo_addr[FSAB_ADDR_HI:0],dc__fsabo_addr[FSAB_ADDR_HI:0]}),
		.fsabo_lens({pre__fsabo_len[FSAB_LEN_HI:0],ic__fsabo_len[FSAB_LEN_HI:0],dc__fsabo_len[FSAB_LEN_HI:0]}),
		.fsabo_datas({pre__fsabo_data[FSAB_DATA_HI:0],ic__fsabo_data[FSAB_DATA_HI:0],dc__fsabo_data[FSAB_DATA_HI:0]}),
		.fsabo_masks({pre__fsabo_mask[FSAB_MASK_HI:0],ic__fsabo_mask[FSAB_MASK_HI:0],dc__fsabo_mask[FSAB_MASK_HI:0]}),
		.fsabo_credits({pre__fsabo_credit,ic__fsabo_credit,dc__fsabo_credit}),
		); */
	FSABArbiter fsabarbiter(
		/*AUTOINST*/
				// Outputs
				.fsabo_credits	({pre__fsabo_credit,ic__fsabo_credit,dc__fsabo_credit}), // Templated
				.fsabo_valid	(fsabo_valid),
				.fsabo_mode	(fsabo_mode[FSAB_REQ_HI:0]),
				.fsabo_did	(fsabo_did[FSAB_DID_HI:0]),
				.fsabo_subdid	(fsabo_subdid[FSAB_DID_HI:0]),
				.fsabo_addr	(fsabo_addr[FSAB_ADDR_HI:0]),
				.fsabo_len	(fsabo_len[FSAB_LEN_HI:0]),
				.fsabo_data	(fsabo_data[FSAB_DATA_HI:0]),
				.fsabo_mask	(fsabo_mask[FSAB_MASK_HI:0]),
				// Inputs
				.clk		(fsabi_clk),	 // Templated
				.rst_b		(rst_b),
				.fsabo_valids	({pre__fsabo_valid,ic__fsabo_valid,dc__fsabo_valid}), // Templated
				.fsabo_modes	({pre__fsabo_mode[FSAB_REQ_HI:0],ic__fsabo_mode[FSAB_REQ_HI:0],dc__fsabo_mode[FSAB_REQ_HI:0]}), // Templated
				.fsabo_dids	({pre__fsabo_did[FSAB_DID_HI:0],ic__fsabo_did[FSAB_DID_HI:0],dc__fsabo_did[FSAB_DID_HI:0]}), // Templated
				.fsabo_subdids	({pre__fsabo_subdid[FSAB_DID_HI:0],ic__fsabo_subdid[FSAB_DID_HI:0],dc__fsabo_subdid[FSAB_DID_HI:0]}), // Templated
				.fsabo_addrs	({pre__fsabo_addr[FSAB_ADDR_HI:0],ic__fsabo_addr[FSAB_ADDR_HI:0],dc__fsabo_addr[FSAB_ADDR_HI:0]}), // Templated
				.fsabo_lens	({pre__fsabo_len[FSAB_LEN_HI:0],ic__fsabo_len[FSAB_LEN_HI:0],dc__fsabo_len[FSAB_LEN_HI:0]}), // Templated
				.fsabo_datas	({pre__fsabo_data[FSAB_DATA_HI:0],ic__fsabo_data[FSAB_DATA_HI:0],dc__fsabo_data[FSAB_DATA_HI:0]}), // Templated
				.fsabo_masks	({pre__fsabo_mask[FSAB_MASK_HI:0],ic__fsabo_mask[FSAB_MASK_HI:0],dc__fsabo_mask[FSAB_MASK_HI:0]}), // Templated
				.fsabo_clks	(fsabo_clks[FSAB_DEVICES-1:0]),
				.fsabo_rst_bs	(fsabo_rst_bs[FSAB_DEVICES-1:0]),
				.fsabo_credit	(fsabo_credit));
	defparam fsabarbiter.FSAB_DEVICES = FSAB_DEVICES;

	/* FSABMemory AUTO_TEMPLATE (
		.clk(fsabi_clk),
	); */
	FSABMemory mem(
		/*AUTOINST*/
		       // Outputs
		       .ddr2_a		(ddr2_a[ROW_WIDTH-1:0]),
		       .ddr2_ba		(ddr2_ba[BANK_WIDTH-1:0]),
		       .ddr2_cas_n	(ddr2_cas_n),
		       .ddr2_ck		(ddr2_ck[CLK_WIDTH-1:0]),
		       .ddr2_ck_n	(ddr2_ck_n[CLK_WIDTH-1:0]),
		       .ddr2_cke	(ddr2_cke[CKE_WIDTH-1:0]),
		       .ddr2_cs_n	(ddr2_cs_n[CS_WIDTH-1:0]),
		       .ddr2_dm		(ddr2_dm[DM_WIDTH-1:0]),
		       .ddr2_odt	(ddr2_odt[ODT_WIDTH-1:0]),
		       .ddr2_ras_n	(ddr2_ras_n),
		       .ddr2_we_n	(ddr2_we_n),
		       .phy_init_done	(phy_init_done),
		       .clk		(fsabi_clk),		 // Templated
		       .fsabo_credit	(fsabo_credit),
		       .fsabi_valid	(fsabi_valid),
		       .fsabi_did	(fsabi_did[FSAB_DID_HI:0]),
		       .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
		       .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]),
		       // Inouts
		       .ddr2_dq		(ddr2_dq[DQ_WIDTH-1:0]),
		       .ddr2_dqs	(ddr2_dqs[DQS_WIDTH-1:0]),
		       .ddr2_dqs_n	(ddr2_dqs_n[DQS_WIDTH-1:0]),
		       // Inputs
		       .clk200_n	(clk200_n),
		       .clk200_p	(clk200_p),
		       .sys_clk_n	(sys_clk_n),
		       .sys_clk_p	(sys_clk_p),
		       .rst_b		(rst_b),
		       .fsabo_valid	(fsabo_valid),
		       .fsabo_mode	(fsabo_mode[FSAB_REQ_HI:0]),
		       .fsabo_did	(fsabo_did[FSAB_DID_HI:0]),
		       .fsabo_subdid	(fsabo_subdid[FSAB_DID_HI:0]),
		       .fsabo_addr	(fsabo_addr[FSAB_ADDR_HI:0]),
		       .fsabo_len	(fsabo_len[FSAB_LEN_HI:0]),
		       .fsabo_data	(fsabo_data[FSAB_DATA_HI:0]),
		       .fsabo_mask	(fsabo_mask[FSAB_MASK_HI:0]));

	FSABPreload preload(/*AUTOINST*/
			    // Outputs
			    .rst_core_b		(rst_core_b),
			    .pre__fsabo_valid	(pre__fsabo_valid),
			    .pre__fsabo_mode	(pre__fsabo_mode[FSAB_REQ_HI:0]),
			    .pre__fsabo_did	(pre__fsabo_did[FSAB_DID_HI:0]),
			    .pre__fsabo_subdid	(pre__fsabo_subdid[FSAB_DID_HI:0]),
			    .pre__fsabo_addr	(pre__fsabo_addr[FSAB_ADDR_HI:0]),
			    .pre__fsabo_len	(pre__fsabo_len[FSAB_LEN_HI:0]),
			    .pre__fsabo_data	(pre__fsabo_data[FSAB_DATA_HI:0]),
			    .pre__fsabo_mask	(pre__fsabo_mask[FSAB_MASK_HI:0]),
			    // Inputs
			    .clk		(clk),
			    .rst_b		(rst_b),
			    .pre__fsabo_credit	(pre__fsabo_credit),
			    .fsabi_valid	(fsabi_valid),
			    .fsabi_did		(fsabi_did[FSAB_DID_HI:0]),
			    .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
			    .fsabi_data		(fsabi_data[FSAB_DATA_HI:0]));

endmodule

// Local Variables:
// verilog-library-directories:("." "../console" "../core" "../fsab" "../spam" "../fsab/sim")
// End:
