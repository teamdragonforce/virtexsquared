module FSABMemory(/*AUTOARG*/
   // Outputs
   ddr2_a, ddr2_ba, ddr2_cas_n, ddr2_ck, ddr2_ck_n, ddr2_cke,
   ddr2_cs_n, ddr2_dm, ddr2_odt, ddr2_ras_n, ddr2_we_n, phy_init_done,
   clk, fsabo_credit, fsabi_valid, fsabi_did, fsabi_subdid,
   fsabi_data,
   // Inouts
   ddr2_dq, ddr2_dqs, ddr2_dqs_n,
   // Inputs
   clk200_n, clk200_p, sys_clk_n, sys_clk_p, Nrst, fsabo_valid,
   fsabo_mode, fsabo_did, fsabo_subdid, fsabo_addr, fsabo_len,
   fsabo_data, fsabo_mask
   );
	`include "fsab_defines.vh"
	`include "memory_defines.vh"
	`include "clog2.vh"

	input		clk200_n;		// To the_mig of mig.v
	input		clk200_p;		// To the_mig of mig.v
	input		sys_clk_n;		// To the_mig of mig.v
	input		sys_clk_p;		// To the_mig of mig.v
	output [ROW_WIDTH-1:0] ddr2_a;		// From the_mig of mig.v
	output [BANK_WIDTH-1:0] ddr2_ba;	// From the_mig of mig.v
	output		ddr2_cas_n;		// From the_mig of mig.v
	output [CLK_WIDTH-1:0] ddr2_ck;		// From the_mig of mig.v
	output [CLK_WIDTH-1:0] ddr2_ck_n;	// From the_mig of mig.v
	output [CKE_WIDTH-1:0] ddr2_cke;	// From the_mig of mig.v
	output [CS_WIDTH-1:0] ddr2_cs_n;	// From the_mig of mig.v
	output [DM_WIDTH-1:0] ddr2_dm;		// From the_mig of mig.v
	output [ODT_WIDTH-1:0] ddr2_odt;	// From the_mig of mig.v
	output		ddr2_ras_n;		// From the_mig of mig.v
	output		ddr2_we_n;		// From the_mig of mig.v
	output		phy_init_done;		// From the_mig of mig.v
	inout [DQ_WIDTH-1:0] ddr2_dq;		// To/From the_mig of mig.v
	inout [DQS_WIDTH-1:0] ddr2_dqs;		// To/From the_mig of mig.v
	inout [DQS_WIDTH-1:0] ddr2_dqs_n;	// To/From the_mig of mig.v

	output                       clk;
	input                        Nrst;
	
	input                        fsabo_valid;
	input       [FSAB_REQ_HI:0]  fsabo_mode;
	input       [FSAB_DID_HI:0]  fsabo_did;
	input       [FSAB_DID_HI:0]  fsabo_subdid;
	input       [FSAB_ADDR_HI:0] fsabo_addr;
	input       [FSAB_LEN_HI:0]  fsabo_len;
	input       [FSAB_DATA_HI:0] fsabo_data;
	input       [FSAB_MASK_HI:0] fsabo_mask;
	
	output wire                  fsabo_credit;
	output wire                  fsabi_valid;
	output wire [FSAB_DID_HI:0]  fsabi_did;
	output wire [FSAB_DID_HI:0]  fsabi_subdid;
	output wire [FSAB_DATA_HI:0] fsabi_data;

	/*** Inbound request FIFO (IRFIF) ***/
`define SIMMEM_IRFIF_HI (FSAB_REQ_HI+1 + FSAB_DID_HI+1 + FSAB_DID_HI+1 + FSAB_ADDR_HI+1 + FSAB_LEN_HI)
	reg [FSAB_CREDITS_HI:0] irfif_wpos_0a = 'h0;
	reg [FSAB_CREDITS_HI:0] irfif_rpos_0a = 'h0;
	reg [`SIMMEM_IRFIF_HI:0] irfif_fifo [(FSAB_INITIAL_CREDITS-1):0];
	wire irfif_wr_0a;
	wire irfif_rd_0a;
	wire [`SIMMEM_IRFIF_HI:0] irfif_wdat_0a;
	reg [`SIMMEM_IRFIF_HI:0] irfif_rdat_1a;
	wire irfif_empty_0a = (irfif_rpos_0a == irfif_wpos_0a);
	wire irfif_full_0a = (irfif_wpos_0a == (irfif_rpos_0a + FSAB_INITIAL_CREDITS));
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			irfif_wpos_0a <= 'h0;
			irfif_rpos_0a <= 'h0;
		end else begin
			if (irfif_rd_0a) begin
				$display("SIMMEM: %5d: reading from irfif", $time);
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				/* TODO: ^ */
				irfif_rdat_1a <= irfif_fifo[irfif_rpos_0a[1:0]];
				irfif_rpos_0a <= irfif_rpos_0a + 'h1;
			end
			
			if (irfif_wr_0a) begin
				$display("SIMMEM: %5d: writing to irfif (%d word %s)", $time, fsabo_len, (fsabo_mode == FSAB_WRITE) ? "write" : "read");
				irfif_fifo[irfif_wpos_0a[1:0]] <= irfif_wdat_0a;
				irfif_wpos_0a <= irfif_wpos_0a + 'h1;
			end
		end
	
	/*** IRFIF demux & control ***/
	wire [FSAB_REQ_HI:0]  irfif_mode_1a;
	wire [FSAB_DID_HI:0]  irfif_did_1a;
	wire [FSAB_DID_HI:0]  irfif_subdid_1a;
	wire [FSAB_ADDR_HI:0] irfif_addr_1a;
	wire [FSAB_LEN_HI:0]  irfif_len_1a;
	wire [FSAB_LEN_HI:0]  irfif_ddr_len_1a;
	
	/* irfif_rd is assigned later */
	
	assign {irfif_mode_1a, irfif_did_1a, irfif_subdid_1a, irfif_addr_1a,
	        irfif_len_1a} = irfif_rdat_1a;
	assign irfif_ddr_len_1a = (irfif_len_1a + 1) / 2;
	assign irfif_wdat_0a = {fsabo_mode, fsabo_did, fsabo_subdid,
	                       fsabo_addr, fsabo_len};
	reg [FSAB_LEN_HI:0] fsabo_cur_req_len_rem_0a = 0;
	wire fsabo_cur_req_done_0a = (fsabo_cur_req_len_rem_0a==0);
	wire fsabo_new_req_0a = fsabo_valid && fsabo_cur_req_done_0a;
	assign irfif_wr_0a = fsabo_new_req_0a;
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			fsabo_cur_req_len_rem_0a <= 0;
		end else begin
			if (fsabo_valid && fsabo_cur_req_done_0a && (fsabo_mode == FSAB_WRITE))
				fsabo_cur_req_len_rem_0a <= fsabo_len - 1;
			else if (fsabo_valid && fsabo_cur_req_len_rem_0a != 0)
				fsabo_cur_req_len_rem_0a <= fsabo_cur_req_len_rem_0a - 1;
		end
	
	/*** Inbound data FIFO (IDFIF) ***/
`define MEM_IDFIF_MAX ((FSAB_INITIAL_CREDITS * FSAB_LEN_MAX / 2) - 1)
`define MEM_IDFIF_WIDTH (2*(FSAB_DATA_HI+1 + FSAB_MASK_HI+1))
`define MEM_IDFIF_HI (2*(clog2(`MEM_IDFIF_MAX) - 1)+1)
	reg [`MEM_IDFIF_HI:0] idfif_wpos_0a = 'h0;
	reg [`MEM_IDFIF_HI:0] idfif_rpos_0a = 'h0;
	reg [`MEM_IDFIF_WIDTH-1:0] idfif_fifo [`MEM_IDFIF_MAX:0];
	wire idfif_wr_0a;
	wire idfif_rd_0a;
	wire [`MEM_IDFIF_WIDTH-1:0] idfif_wdat_0a;
	reg [`MEM_IDFIF_WIDTH-1:0] idfif_rdat_1a;
	wire idfif_empty_0a = (idfif_rpos_0a == idfif_wpos_0a);
	wire idfif_full_0a = (idfif_wpos_0a == (idfif_rpos_0a + `MEM_IDFIF_MAX));
	wire [`MEM_IDFIF_HI:0] idfif_avail_0a = idfif_wpos_0a - idfif_rpos_0a;
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			idfif_wpos_0a <= 'h0;
			idfif_rpos_0a <= 'h0;
		end else begin
			if (idfif_rd_0a) begin
				$display("SIMMEM: %5d: reading from idfif (ad %d, da %x)", $time, idfif_rpos_0a, idfif_fifo[idfif_rpos_0a]);
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				idfif_rdat_1a <= idfif_fifo[idfif_rpos_0a];
				idfif_rpos_0a <= idfif_rpos_0a + 'h1;
			end else begin
				idfif_rdat_1a <= {(FSAB_DATA_HI+1 + FSAB_MASK_HI+1){1'hx}};
			end
			
			if (idfif_wr_0a) begin
				$display("SIMMEM: %5d: writing to idfif (ad %d, %08b mask, %08x data)", $time, idfif_wpos_0a, fsabo_mask, fsabo_data);
				idfif_fifo[idfif_wpos_0a] <= idfif_wdat_0a;
				idfif_wpos_0a <= idfif_wpos_0a + 'h1;
			end
		end
	
	/*** IDFIF demux & control */
	wire [FSAB_DATA_HI:0] idfif_data_1a;
	wire [FSAB_MASK_HI:0] idfif_mask_1a;
	wire [FSAB_DATA_HI:0] idfif_data2_1a;
	wire [FSAB_MASK_HI:0] idfif_mask2_1a;

	reg [FSAB_DATA_HI:0] fsabo_prev_data;
	reg [FSAB_MASK_HI:0] fsabo_prev_mask;

	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			fsabo_prev_data <= 0;
			fsabo_prev_mask <= {(FSAB_MASK_HI+1){1'h1}};
		end else if (fsabo_valid) begin
			fsabo_prev_data <= fsabo_data;
			fsabo_prev_mask <= fsabo_mask;
		end

	reg fsabo_want_prev = 0;
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			fsabo_want_prev <= 0;
		end else if (fsabo_valid && !fsabo_want_prev || fsabo_new_req_0a) begin
			fsabo_want_prev <= 1;
		end else if (idfif_wr_0a) begin
			fsabo_want_prev <= 0;
		end
	
	/* idfif_rd is assigned later */
	assign {idfif_data2_1a,idfif_mask2_1a,idfif_data_1a,idfif_mask_1a} = idfif_rdat_1a;
	assign idfif_wdat_0a = {fsabo_data, (fsabo_cur_req_done_0a ? {(FSAB_MASK_HI+1){1'h1}} : fsabo_mask),fsabo_prev_data,fsabo_prev_mask};
	assign idfif_wr_0a = fsabo_want_prev && (fsabo_valid || fsabo_cur_req_done_0a);
	wire idfif_req_queued_0a = idfif_wr_0a && (fsabo_cur_req_done_0a || fsabo_cur_req_len_rem_0a == 1);
	/* NOTE: this means that idfif_rd must ALWAYS be asserted along with
	 * irfif_rd...  even if len is 0, or even if the request was a read!
	 */

`define MEM_ICNT_WIDTH (clog2(FSAB_INITIAL_CREDITS)-1)
	reg [`MEM_ICNT_WIDTH:0] ifif_reqs_queued_0a = 0;
	wire ifif_have_req = ifif_reqs_queued_0a != 0;

	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			ifif_reqs_queued_0a <= 0;
		end else begin
			ifif_reqs_queued_0a <= ifif_reqs_queued_0a + (idfif_req_queued_0a ? 1 : 0)
			                                           + (irfif_rd_0a ? -1 : 0);
		end

	/*** Outbound data FIFO (ODFIF) ***/
//`define MEM_ODFIF_MAX ((FSAB_LEN_MAX)-1)
//`define MEM_ODFIF_WIDTH (2*(FSAB_DATA_HI+1 + FSAB_MASK_HI)+1)
//`define MEM_ODFIF_HI (2*(clog2(`MEM_ODFIF_MAX)-1)+1)
//	reg [`MEM_ODFIF_HI:0] odfif_wpos_0a = 'h0;
//	reg [`MEM_ODFIF_HI:0] odfif_rpos_0a = 'h0;
//	reg [`MEM_ODFIF_WIDTH:0] odfif_fifo [`MEM_ODFIF_MAX:0];
//	wire odfif_wr_0a;
//	wire odfif_rd_0a;
//	wire [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] odfif_wdat_0a;
//	reg [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] odfif_rdat_1a;
//	wire odfif_empty_0a = (odfif_rpos_0a == odfif_wpos_0a);
//	wire odfif_full_0a = (odfif_wpos_0a == (odfif_rpos_0a + `MEM_ODFIF_MAX));
//	wire [`MEM_ODFIF_HI:0] odfif_avail_0a = odfif_wpos_0a - odfif_rpos_0a;
//
//	always @(posedge clk or negedge Nrst)
//		if (!Nrst) begin
//			odfif_wpos_0a <= 'h0;
//			odfif_rpos_0a <= 'h0;
//		end else begin
//			if (odfif_rd_0a) begin
//				$display("SIMMEM: %5d: reading from odfif (ad %d, da %x)", $time, odfif_rpos_0a, odfif_fifo[odfif_rpos_0a]);
//				/* NOTE: this FIFO style will NOT port to Xilinx! */
//				odfif_rdat_1a <= odfif_fifo[odfif_rpos_0a];
//				odfif_rpos_0a <= odfif_rpos_0a + 'h1;
//			end else begin
//				odfif_rdat_1a <= {(FSAB_DATA_HI+1 + FSAB_MASK_HI+1){1'hx}};
//			end
//			
//			if (odfif_wr_0a) begin
//				$display("SIMMEM: %5d: writing to idfif (ad %d, %08b mask, %08x data)", $time, idfif_wpos_0a, fsabo_mask, fsabo_data);
//				odfif_fifo[odfif_wpos_0a] <= odfif_wdat_0a;
//				odfif_wpos_0a <= odfif_wpos_0a + 'h1;
//			end
//		end
	
	/*** Pipe-throughs ***/
	reg irfif_rd_1a = 0;
	reg idfif_rd_1a = 0;
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			irfif_rd_1a <= 0;
			idfif_rd_1a <= 0;
		end else begin
			irfif_rd_1a <= irfif_rd_0a;
			idfif_rd_1a <= idfif_rd_0a;
		end
	
	/*** Memory control logic ***/
	/* Active determines whether we have a request waiting (i.e., we did
	 * an IRFIF read).  It is high as long as we are serving it (which
	 * is exactly the number of cycles in 'len', since the MIG requires
	 * the data in a burst).
	 */

	reg  [FSAB_LEN_HI:0]  mem_cur_req_ddr_len_rem_0a = 'h0;
	wire                  mem_cur_req_active_0a = 0;
	reg                   mem_cur_req_active_1a = 0;
	wire [FSAB_ADDR_HI:0] mem_cur_req_addr_1a;
	reg  [FSAB_ADDR_HI:0] mem_cur_req_addr_1a_r = 0;

	wire [MIG_CMD_WIDTH-1:0] app_af_cmd;
	wire                     app_wdf_wren;
	wire                     app_af_afull;
	wire                     app_wdf_afull;

	wire [2*DQ_WIDTH-1:0]    rd_data_fifo_out;
	
	/* If we just finished reading from the idfif for the last time
	 * (i.e., we just went inactive), then we can release a credit. 
	 * This is as distinct from releasing a credit every time we read
	 * from irfif, which is incorrect because there may not yet be space
	 * in the idfif yet.
	 */
	assign fsabo_credit = mem_cur_req_active_1a && !mem_cur_req_active_0a;
	
	/* TODO: This means that idfif does one read, then pauses one cycle,
	 * then continues doing the read until we run out of data.  Can the
	 * one-cycle pause be removed easily?
	 */
	assign irfif_rd_0a = ifif_have_req && !mem_cur_req_active_0a
	                     && phy_init_done && !app_af_afull && !app_wdf_afull;
	assign idfif_rd_0a = irfif_rd_0a || /* We must always do a read from idfif on irfif. */
	                     mem_cur_req_active_0a;

	assign mem_cur_req_active_0a = irfif_mode_1a == FSAB_WRITE &&
	                               ((irfif_rd_1a && irfif_ddr_len_1a != 1) ||
	                                (mem_cur_req_ddr_len_rem_0a != 1 && mem_cur_req_ddr_len_rem_0a != 0));
	
	assign mem_cur_req_addr_1a = irfif_rd_1a ?
	                                 irfif_addr_1a :
	                                 mem_cur_req_addr_1a_r;

	assign app_af_cmd = irfif_mode_1a == FSAB_WRITE ? MIG_WRITE : MIG_READ;

	assign app_wdf_wren = irfif_mode_1a == FSAB_WRITE && idfif_rd_1a;
	
	/* TODO: totally false */
	/*
	assign fsabi_valid = mem_cur_req_active_0a &&
	                     (irfif_mode_1a == FSAB_READ) &&
	                     (mem_cur_req_len_rem_0a != 'h0);
	assign fsabi_did = irfif_did_1a;
	assign fsabi_subdid = irfif_subdid_1a;
	*/

	/* verilator lint_off WIDTH */
	/*
	assign fsabi_data = simmem[mem_cur_req_addr_1a[FSAB_ADDR_HI:3]];
	*?
	/* verilator lint_on WIDTH */
	
	/* This reg is not actually a flop; it is storage for behavioral
	 * data masking.  */
//	integer i;
//	integer j;
//	reg [FSAB_DATA_HI:0] masked_data;

	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			mem_cur_req_ddr_len_rem_0a <= 'h0;
			mem_cur_req_active_1a <= 0;
			mem_cur_req_addr_1a_r <= 0;
		end else begin
			mem_cur_req_active_1a <= mem_cur_req_active_0a;
		
			if (irfif_rd_1a) begin
				$display("SIMMEM: %5d: IRFIF was just read; it was a %d word %s at %08x", $time, irfif_len_1a, (irfif_mode_1a == FSAB_WRITE) ? "WRITE" : "READ", irfif_addr_1a);
				mem_cur_req_ddr_len_rem_0a <= irfif_ddr_len_1a;
			end else if (idfif_rd_0a)
				mem_cur_req_ddr_len_rem_0a <= mem_cur_req_ddr_len_rem_0a - 1;
			
			if (irfif_rd_1a)
				mem_cur_req_addr_1a_r <= irfif_addr_1a;
			else if (idfif_rd_0a)
				mem_cur_req_addr_1a_r <= mem_cur_req_addr_1a + (FSAB_DATA_HI + 1) / 8;
		end

	/* mig AUTO_TEMPLATE (
		.sys_rst_n(Nrst),
		.app_af_addr(mem_cur_req_addr_1a),
		.app_af_wren(irfif_rd_1a),
		.app_wdf_data({idfif_data2_1a, idfif_data_1a}),
		.app_wdf_mask_data({idfif_mask2_1a, idfif_mask_1a}),
		);
	*/
	mig #(/*AUTOINSTPARAM*/
	      // Parameters
	      .BANK_WIDTH		(BANK_WIDTH),
	      .CKE_WIDTH		(CKE_WIDTH),
	      .CLK_WIDTH		(CLK_WIDTH),
	      .COL_WIDTH		(COL_WIDTH),
	      .CS_NUM			(CS_NUM),
	      .CS_WIDTH			(CS_WIDTH),
	      .CS_BITS			(CS_BITS),
	      .DM_WIDTH			(DM_WIDTH),
	      .DQ_WIDTH			(DQ_WIDTH),
	      .DQ_PER_DQS		(DQ_PER_DQS),
	      .DQS_WIDTH		(DQS_WIDTH),
	      .DQ_BITS			(DQ_BITS),
	      .DQS_BITS			(DQS_BITS),
	      .ODT_WIDTH		(ODT_WIDTH),
	      .ROW_WIDTH		(ROW_WIDTH),
	      .ADDITIVE_LAT		(ADDITIVE_LAT),
	      .BURST_LEN		(BURST_LEN),
	      .BURST_TYPE		(BURST_TYPE),
	      .CAS_LAT			(CAS_LAT),
	      .ECC_ENABLE		(ECC_ENABLE),
	      .APPDATA_WIDTH		(APPDATA_WIDTH),
	      .MULTI_BANK_EN		(MULTI_BANK_EN),
	      .TWO_T_TIME_EN		(TWO_T_TIME_EN),
	      .ODT_TYPE			(ODT_TYPE),
	      .REDUCE_DRV		(REDUCE_DRV),
	      .REG_ENABLE		(REG_ENABLE),
	      .TREFI_NS			(TREFI_NS),
	      .TRAS			(TRAS),
	      .TRCD			(TRCD),
	      .TRFC			(TRFC),
	      .TRP			(TRP),
	      .TRTP			(TRTP),
	      .TWR			(TWR),
	      .TWTR			(TWTR),
	      .HIGH_PERFORMANCE_MODE	(HIGH_PERFORMANCE_MODE),
	      .SIM_ONLY			(SIM_ONLY),
	      .DEBUG_EN			(DEBUG_EN),
	      .CLK_PERIOD		(CLK_PERIOD),
	      .DLL_FREQ_MODE		(DLL_FREQ_MODE),
	      .CLK_TYPE			(CLK_TYPE),
	      .NOCLK200			(NOCLK200),
	      .RST_ACT_LOW		(RST_ACT_LOW))
	the_mig (/*AUTOINST*/
		 // Outputs
		 .ddr2_a		(ddr2_a[ROW_WIDTH-1:0]),
		 .ddr2_ba		(ddr2_ba[BANK_WIDTH-1:0]),
		 .ddr2_ras_n		(ddr2_ras_n),
		 .ddr2_cas_n		(ddr2_cas_n),
		 .ddr2_we_n		(ddr2_we_n),
		 .ddr2_cs_n		(ddr2_cs_n[CS_WIDTH-1:0]),
		 .ddr2_odt		(ddr2_odt[ODT_WIDTH-1:0]),
		 .ddr2_cke		(ddr2_cke[CKE_WIDTH-1:0]),
		 .ddr2_dm		(ddr2_dm[DM_WIDTH-1:0]),
		 .phy_init_done		(phy_init_done),
		 .rst0_tb		(rst0_tb),
		 .clk0_tb		(clk0_tb),
		 .app_wdf_afull		(app_wdf_afull),
		 .app_af_afull		(app_af_afull),
		 .rd_data_valid		(rd_data_valid),
		 .rd_data_fifo_out	(rd_data_fifo_out[(APPDATA_WIDTH)-1:0]),
		 .ddr2_ck		(ddr2_ck[CLK_WIDTH-1:0]),
		 .ddr2_ck_n		(ddr2_ck_n[CLK_WIDTH-1:0]),
		 // Inouts
		 .ddr2_dq		(ddr2_dq[DQ_WIDTH-1:0]),
		 .ddr2_dqs		(ddr2_dqs[DQS_WIDTH-1:0]),
		 .ddr2_dqs_n		(ddr2_dqs_n[DQS_WIDTH-1:0]),
		 // Inputs
		 .sys_clk_p		(sys_clk_p),
		 .sys_clk_n		(sys_clk_n),
		 .clk200_p		(clk200_p),
		 .clk200_n		(clk200_n),
		 .sys_rst_n		(Nrst),			 // Templated
		 .app_wdf_wren		(app_wdf_wren),
		 .app_af_wren		(irfif_rd_1a),		 // Templated
		 .app_af_addr		(mem_cur_req_addr_1a),	 // Templated
		 .app_af_cmd		(app_af_cmd[2:0]),
		 .app_wdf_data		({idfif_data2_1a, idfif_data_1a}), // Templated
		 .app_wdf_mask_data	({idfif_mask2_1a, idfif_mask_1a})); // Templated
endmodule

// Local Variables:
// verilog-library-directories:("." "mig")
// End:
