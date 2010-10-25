module FSABMemory(/*AUTOARG*/
   // Outputs
   ddr2_a, ddr2_ba, ddr2_cas_n, ddr2_ck, ddr2_ck_n, ddr2_cke,
   ddr2_cs_n, ddr2_dm, ddr2_odt, ddr2_ras_n, ddr2_we_n, phy_init_done,
   clk0_tb, rst0_tb, fsabo_credit, fsabi_valid, fsabi_did,
   fsabi_subdid, fsabi_data,
   // Inouts
   ddr2_dq, ddr2_dqs, ddr2_dqs_n, control_vio,
   // Inputs
   clk200_n, clk200_p, sys_clk_n, sys_clk_p, sys_rst_n, fsabo_valid,
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
	input		sys_rst_n;		// To the_mig of mig.v
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
	
	inout [35:0] control_vio;

	output                       clk0_tb;
	output                       rst0_tb;
	
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
	
	parameter DEBUG = "FALSE";

	/***********************************/
	/*** Fifo interface declarations ***/
	/***********************************/

`define IRFIF_DEPTH (FSAB_INITIAL_CREDITS)
`define IRFIF_WIDTH (FSAB_REQ_HI+1 + FSAB_DID_HI+1 + FSAB_DID_HI+1 + FSAB_ADDR_HI+1 + FSAB_LEN_HI+1)
	wire irfif_wr_0a;
	wire irfif_rd_0a;
	wire [`IRFIF_WIDTH-1:0] irfif_wdat_0a;
	wire [`IRFIF_WIDTH-1:0] irfif_rdat_1a;

	/* DDR: double wide, half as deep */
`define IDFIF_DEPTH (FSAB_INITIAL_CREDITS * FSAB_LEN_MAX / 2)
`define IDFIF_WIDTH (2*(FSAB_DATA_HI+1 + FSAB_MASK_HI+1))
	wire idfif_wr_0a;
	wire idfif_rd_0a;
	wire [`IDFIF_WIDTH-1:0] idfif_wdat_0a;
	wire [`IDFIF_WIDTH-1:0] idfif_rdat_1a;

	/* XXX TODO: Is this what we want? */
`define OFIF_DEPTH (FSAB_INITIAL_CREDITS)

`define ORFIF_DEPTH (OFIF_DEPTH)
`define ORFIF_WIDTH (FSAB_DID_HI+1 + FSAB_DID_HI+1 + FSAB_LEN_HI+1)
	wire orfif_wr_0a;
	wire orfif_rd_0a;
	wire [`ORFIF_WIDTH-1:0] orfif_wdat_0a;
	wire [`ORFIF_WIDTH-1:0] orfif_rdat_1a;

`define ODFIF_WIDTH (2*(FSAB_DATA_HI+1))
`define ODFIF_DEPTH (OFIF_DEPTH * FSAB_LEN_MAX / 2)
	wire odfif_wr_0a;
	wire odfif_rd_0a;
	wire [`ODFIF_WIDTH-1:0] odfif_wdat_0a;
	wire [`ODFIF_WIDTH-1:0] odfif_rdat_1a;

	/************************************/
	/*** Demux & control declarations ***/
	/************************************/

	/* OxFIF credits */
`define OFIF_INITIAL_CREDITS FSAB_INITIAL_CREDITS
`define OFIF_CREDIT_WIDTH (clog2(`OFIF_INITIAL_CREDITS))
	reg [`OFIF_CREDIT_WIDTH-1:0] ofif_credits = `OFIF_INITIAL_CREDITS;
	wire ofif_credit;
	wire ofif_debit;

	/* FSAB -> IFIF */
	reg [FSAB_LEN_HI:0] fsabo_cur_req_len_rem_0a = 0;
	wire fsabo_cur_req_done_0a;
	wire fsabo_new_req_0a;

	wire [FSAB_REQ_HI:0]  irfif_mode_1a;
	wire [FSAB_DID_HI:0]  irfif_did_1a;
	wire [FSAB_DID_HI:0]  irfif_subdid_1a;
	wire [FSAB_ADDR_HI:0] irfif_addr_1a;
	wire [FSAB_LEN_HI:0]  irfif_len_1a;
	wire [FSAB_LEN_HI:0]  irfif_ddr_len_1a;

	wire [FSAB_DATA_HI:0] idfif_data_1a;
	wire [FSAB_MASK_HI:0] idfif_mask_1a;
	wire [FSAB_DATA_HI:0] idfif_data2_1a;
	wire [FSAB_MASK_HI:0] idfif_mask2_1a;

	reg [FSAB_DATA_HI:0] fsabo_prev_data;
	reg [FSAB_MASK_HI:0] fsabo_prev_mask;
	
	/* IFIF -> MIG */
	wire mem_stall_0a;
	reg irfif_rd_1a = 0;
	reg idfif_rd_1a = 0;

	reg fsabo_want_prev = 0;

	reg  [FSAB_LEN_HI:0]  mem_cur_req_ddr_len_rem_0a = 'h0;
	wire                  mem_cur_req_active_0a;
	reg                   mem_cur_req_active_1a = 0;
	wire                  reading_req_0a;
	reg                   reading_req_1a = 0;
	wire [FSAB_ADDR_HI:0] mem_cur_req_addr_1a;
	reg  [FSAB_ADDR_HI:0] mem_cur_req_addr_1a_r = 0;

	wire [MIG_CMD_WIDTH-1:0] app_af_cmd;
	wire [30:0]              app_af_addr;
	wire                     app_af_wren;
	wire                     app_wdf_wren;
	wire                     app_af_afull;
	wire                     app_wdf_afull;
	wire [2*DQ_WIDTH-1:0]    app_wdf_data;
	wire [2*DM_WIDTH-1:0]    app_wdf_mask_data;

	/* XXX TODO: GTFO */
`define ICNT_WIDTH (clog2(FSAB_INITIAL_CREDITS)-1)
	reg [`ICNT_WIDTH:0] ifif_reqs_queued_0a = 0;
	wire ifif_have_req = ifif_reqs_queued_0a != 0;

	wire idfif_req_queued_0a;

	/* MIG -> OFIF */

	/* OFIF -> FSAB */
	wire [2*DQ_WIDTH-1:0]    rd_data_fifo_out; 
	wire                     rd_data_valid;
	reg [FSAB_LEN_HI:0]      ofif_resp_len_rem_0a = 0;
	wire                     ofif_resp_active_0a;

	wire [FSAB_DID_HI:0]  orfif_did_1a;
	wire [FSAB_DID_HI:0]  orfif_subdid_1a;
	wire [FSAB_LEN_HI:0]  orfif_len_1a;
	reg orfif_rd_1a = 0;
	reg odfif_rd_1a = 0;
	wire orfif_empty_0a;
	wire odfif_empty_0a;

	wire [FSAB_DATA_HI:0] odfif_data_1a, odfif_data2_1a;

	/*****************************/
	/*** Demux & control logic ***/
	/*****************************/

	/*** OFIF credits ***/

	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			ofif_credits <= `OFIF_INITIAL_CREDITS;
		end else begin
			ofif_credits <= ofif_credits
			                + (ofif_debit ? -1 : 0)
			                + (ofif_credit ? 1 : 0);
		end

	/*** FSAB -> IFIF ***/

	assign irfif_wdat_0a = {fsabo_mode, fsabo_did, fsabo_subdid,
	                       fsabo_addr, fsabo_len};
	assign irfif_wr_0a = fsabo_new_req_0a;
	assign fsabo_cur_req_done_0a = (fsabo_cur_req_len_rem_0a==0);
	assign fsabo_new_req_0a = fsabo_valid && fsabo_cur_req_done_0a;
	wire   idfif_align_mess_0a = (fsabo_new_req_0a && fsabo_addr[3]);
	assign idfif_wdat_0a = idfif_align_mess_0a ? { fsabo_data, fsabo_mask, {(FSAB_DATA_HI+1){1'h0}},  {(FSAB_MASK_HI+1){1'h0}} }
	                                           : { fsabo_data, (fsabo_cur_req_done_0a ? {(FSAB_MASK_HI+1){1'h0}} : fsabo_mask), fsabo_prev_data, fsabo_prev_mask};
	assign idfif_wr_0a = (fsabo_valid && idfif_align_mess_0a) ||
		             (fsabo_want_prev && (fsabo_valid || fsabo_cur_req_done_0a));
	
	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			fsabo_cur_req_len_rem_0a <= 0;
		end else begin
			if (fsabo_valid && fsabo_cur_req_done_0a && (fsabo_mode == FSAB_WRITE))
				fsabo_cur_req_len_rem_0a <= fsabo_len - 1;
			else if (fsabo_valid && fsabo_cur_req_len_rem_0a != 0)
				fsabo_cur_req_len_rem_0a <= fsabo_cur_req_len_rem_0a - 1;
		end

	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			fsabo_prev_data <= 0;
			fsabo_prev_mask <= {(FSAB_MASK_HI+1){1'h0}};
		end else if (fsabo_valid) begin
			fsabo_prev_data <= fsabo_data;
			fsabo_prev_mask <= fsabo_mask;
		end

	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			fsabo_want_prev <= 0;
		end else if (fsabo_valid && !fsabo_want_prev || (fsabo_new_req_0a && !idfif_align_mess_0a)) begin
			fsabo_want_prev <= 1;
		end else if (idfif_wr_0a) begin
			fsabo_want_prev <= 0;
		end

	/* XXX TODO: GTFO */
	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			ifif_reqs_queued_0a <= 0;
		end else begin
			ifif_reqs_queued_0a <= ifif_reqs_queued_0a + (idfif_req_queued_0a ? 1 : 0)
			                                           + (irfif_rd_0a ? -1 : 0);
		end

	/*** IFIF -> MIG ***/

	/* irfif_rd is assigned later */
	
	assign {irfif_mode_1a, irfif_did_1a, irfif_subdid_1a, irfif_addr_1a,
	        irfif_len_1a} = irfif_rdat_1a;
	assign irfif_ddr_len_1a = (irfif_len_1a + 1) / 2;
	assign {idfif_data2_1a,idfif_mask2_1a,idfif_data_1a,idfif_mask_1a} = idfif_rdat_1a;
	assign idfif_req_queued_0a = idfif_wr_0a && (fsabo_cur_req_done_0a || fsabo_cur_req_len_rem_0a == 1);

	
	/* idfif_rd is assigned later */
	/* NOTE: this means that idfif_rd must ALWAYS be asserted along with
	 * irfif_rd...  even if len is 0, or even if the request was a read!
	 */
	
	/*** Memory control logic ***/
	/* Active determines whether we have a request waiting (i.e., we did
	 * an IRFIF read).  It is high as long as we are serving it (which
	 * is exactly the number of cycles in 'len', since the MIG requires
	 * the data in a burst).
	 */

	/* If we just finished reading from the idfif for the last time
	 * (i.e., we just went inactive), then we can release a credit. 
	 * This is as distinct from releasing a credit every time we read
	 * from irfif, which is incorrect because there may not yet be space
	 * in the idfif yet.
	 */
	assign fsabo_credit = reading_req_1a &&
	                      (!reading_req_0a || irfif_rd_0a);
	
	assign irfif_rd_0a = !mem_stall_0a
	                     && ifif_have_req && !mem_cur_req_active_0a
	                     && phy_init_done && !app_af_afull && !app_wdf_afull;
	assign idfif_rd_0a = !mem_stall_0a &&
	                     (irfif_rd_0a || /* We must always do a read from idfif on irfif. */
	                      mem_cur_req_active_0a);

	/* Stall when:
	*   - it is the beginning of a request
	*   - we need to avoid overflowing one of:
	*     - the ODFIF
	*     - the MIG write data FIFO
	*     - the MIG read data FIFO
	*/
	assign mem_stall_0a = irfif_rd_1a &&
	                      ((ofif_credits == 0 && irfif_mode_1a == FSAB_READ) ||
	                       (app_wdf_afull && irfif_mode_1a == FSAB_WRITE) ||
	                       app_af_afull);


	assign reading_req_0a = idfif_rd_0a || mem_stall_0a;
	assign mem_cur_req_active_0a = irfif_mode_1a == FSAB_WRITE &&
	                               ((irfif_rd_1a && irfif_ddr_len_1a != 1) ||
	                                (!irfif_rd_1a && mem_cur_req_ddr_len_rem_0a != 1 && mem_cur_req_ddr_len_rem_0a != 0));
	
	assign mem_cur_req_addr_1a = irfif_rd_1a ?
	                                 irfif_addr_1a :
	                                 mem_cur_req_addr_1a_r;

	assign app_af_cmd = irfif_mode_1a == FSAB_WRITE ? MIG_WRITE : MIG_READ;
	assign app_af_addr = mem_cur_req_addr_1a;
	assign app_af_wren = irfif_rd_1a && !mem_stall_0a;

	assign app_wdf_wren = irfif_mode_1a == FSAB_WRITE && idfif_rd_1a && !mem_stall_0a;
	assign app_wdf_data = {idfif_data2_1a, idfif_data_1a};
	assign app_wdf_mask_data = ~{idfif_mask2_1a, idfif_mask_1a};

	assign ofif_debit = irfif_rd_1a && irfif_mode_1a == FSAB_READ;

	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			mem_cur_req_ddr_len_rem_0a <= 'h0;
			mem_cur_req_active_1a <= 0;
			mem_cur_req_addr_1a_r <= 0;
			reading_req_1a <= 0;
		end else begin
			mem_cur_req_active_1a <= mem_cur_req_active_0a;
			reading_req_1a <= reading_req_0a;
		
			if (irfif_rd_1a && !mem_stall_0a && (irfif_mode_1a == FSAB_WRITE)) begin
				mem_cur_req_ddr_len_rem_0a <= irfif_ddr_len_1a - 1;
			end else if (irfif_rd_1a && mem_stall_0a && (irfif_mode_1a == FSAB_WRITE)) begin
				mem_cur_req_ddr_len_rem_0a <= irfif_ddr_len_1a;
			end else if (app_wdf_wren)
				mem_cur_req_ddr_len_rem_0a <= mem_cur_req_ddr_len_rem_0a - 1;
			
			if (irfif_rd_1a)
				mem_cur_req_addr_1a_r <= irfif_addr_1a;
			else if (idfif_rd_0a)
				mem_cur_req_addr_1a_r <= mem_cur_req_addr_1a + (FSAB_DATA_HI + 1) / 8;
		end

	/*** MIG -> OFIF ***/

	assign orfif_wdat_0a = {irfif_did_1a, irfif_subdid_1a, irfif_len_1a};
	assign orfif_wr_0a = irfif_rd_1a && irfif_mode_1a == FSAB_READ;
	assign odfif_wdat_0a = rd_data_fifo_out;
	assign odfif_wr_0a = rd_data_valid;

	/*** OFIF -> FSAB ***/

	assign {orfif_did_1a, orfif_subdid_1a, orfif_len_1a} = orfif_rdat_1a;
	assign {odfif_data2_1a, odfif_data_1a} = odfif_rdat_1a;

	assign orfif_rd_0a = !orfif_empty_0a && !odfif_empty_0a && !ofif_resp_active_0a;
	assign odfif_rd_0a = orfif_rd_0a || (ofif_resp_active_0a && !odfif_rd_1a);

	assign ofif_resp_active_0a = (orfif_rd_1a && orfif_len_1a != 1) ||
	                             (ofif_resp_len_rem_0a != 1 && ofif_resp_len_rem_0a != 0);

	assign ofif_credit = fsabi_valid && !ofif_resp_active_0a;

	assign fsabi_data = (!odfif_rd_1a) ? odfif_data2_1a : odfif_data_1a;
	assign fsabi_valid = orfif_rd_1a || ofif_resp_len_rem_0a != 0;
	assign fsabi_did = orfif_did_1a;
	assign fsabi_subdid = orfif_subdid_1a;

	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			ofif_resp_len_rem_0a <= 0;
		end else begin
			if (orfif_rd_1a)
				ofif_resp_len_rem_0a <= orfif_len_1a - 1;
			else if (ofif_resp_len_rem_0a != 0)
				ofif_resp_len_rem_0a <= ofif_resp_len_rem_0a - 1;
		end

	/*********************/
	/*** Pipe-throughs ***/
	/*********************/

	always @(posedge clk0_tb or posedge rst0_tb) begin
		if (rst0_tb) begin
			irfif_rd_1a <= 0;
			idfif_rd_1a <= 0;
			orfif_rd_1a <= 0;
			odfif_rd_1a <= 0;
		end else begin
			if (! mem_stall_0a) begin
				irfif_rd_1a <= irfif_rd_0a;
				idfif_rd_1a <= idfif_rd_0a;
			end
			orfif_rd_1a <= orfif_rd_0a;
			odfif_rd_1a <= odfif_rd_0a;
		end
	end

	/**************/
	/*** Blocks ***/
	/**************/

	Fifo #(.DEPTH   (`IRFIF_DEPTH),
	       .WIDTH   (`IRFIF_WIDTH))
	irfif 
	      (.clk     (clk0_tb),
	       .rst_b   (~rst0_tb),
	       .wr_en   (irfif_wr_0a),
	       .rd_en   (irfif_rd_0a),
	       .wr_dat  (irfif_wdat_0a),
	       .rd_dat  (irfif_rdat_1a));

	Fifo  #(.DEPTH   (FSAB_INITIAL_CREDITS * FSAB_LEN_MAX / 2),
	        .WIDTH   (`IDFIF_WIDTH))
	idfif
	       (.clk     (clk0_tb),
	        .rst_b   (~rst0_tb),
	        .wr_en   (idfif_wr_0a),
	        .rd_en   (idfif_rd_0a),
	        .wr_dat  (idfif_wdat_0a),
	        .rd_dat  (idfif_rdat_1a));

	Fifo  #(.DEPTH   (FSAB_INITIAL_CREDITS),
	        .WIDTH   (`ORFIF_WIDTH))
	orfif
	       (.clk     (clk0_tb),
	        .rst_b   (~rst0_tb),
	        .wr_en   (orfif_wr_0a),
	        .rd_en   (orfif_rd_0a),
	        .wr_dat  (orfif_wdat_0a),
	        .rd_dat  (orfif_rdat_1a),
	        .empty   (orfif_empty_0a));

	Fifo  #(.DEPTH   (FSAB_INITIAL_CREDITS * FSAB_LEN_MAX / 2),
	        .WIDTH   (`ODFIF_WIDTH))
	odfif
	       (.clk     (clk0_tb),
	        .rst_b   (~rst0_tb),
	        .wr_en   (odfif_wr_0a),
	        .rd_en   (odfif_rd_0a),
	        .wr_dat  (odfif_wdat_0a),
	        .rd_dat  (odfif_rdat_1a),
	        .empty   (odfif_empty_0a));

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
		 .sys_rst_n		(sys_rst_n),
		 .app_wdf_wren		(app_wdf_wren),
		 .app_af_wren		(app_af_wren),
		 .app_af_addr		(app_af_addr[30:0]),
		 .app_af_cmd		(app_af_cmd[2:0]),
		 .app_wdf_data		(app_wdf_data[(APPDATA_WIDTH)-1:0]),
		 .app_wdf_mask_data	(app_wdf_mask_data[(APPDATA_WIDTH/8)-1:0]));

	generate
	
	if (DEBUG == "TRUE") begin: debug

	wire [35:0] control0, control1, control2;

	chipscope_icon icon (
		.CONTROL0(control0), // INOUT BUS [35:0]
		.CONTROL1(control1), // INOUT BUS [35:0]
		.CONTROL2(control2), // INOUT BUS [35:0]
		.CONTROL3(control_vio)  // INOUT BUS [35:0]
	);

	chipscope_ila ila0 (
		.CONTROL(control0), // INOUT BUS [35:0]
		.CLK(clk0_tb), // IN
		.TRIG0({fsabo_want_prev, idfif_align_mess_0a, fsabo_cur_req_done_0a, app_af_wren, app_wdf_wren,
		        app_af_afull, app_wdf_afull, mem_cur_req_active_0a, ifif_reqs_queued_0a[2:0],
		        mem_cur_req_ddr_len_rem_0a[3:0], irfif_ddr_len_1a[3:0], ifif_have_req, reading_req_0a,
		        reading_req_1a, irfif_wr_0a, irfif_rd_0a, idfif_wr_0a,
		        idfif_rd_0a, rst0_tb, fsabo_mode[0], fsabo_did[3:0],
		        fsabo_subdid[3:0], fsabo_addr[30:0], fsabo_len[3:0], fsabo_data[63:0],
		        fsabo_mask[7:0], fsabo_credit, fsabo_valid}) // IN BUS [255:0]
	);

	chipscope_ila ila1 (
		.CONTROL(control1), // INOUT BUS [35:0]
		.CLK(clk0_tb), // IN
		.TRIG0({app_af_wren, app_wdf_wren, app_af_cmd[2:0],
		        orfif_wr_0a, irfif_did_1a[3:0], irfif_subdid_1a[3:0], ofif_debit,
		        rd_data_valid, odfif_wr_0a,
		        orfif_rd_0a, odfif_rd_0a, orfif_rd_1a, odfif_rd_1a, orfif_empty_0a,
		        orfif_did_1a[3:0], orfif_subdid_1a[3:0], orfif_len_1a[3:0],
		        ofif_resp_len_rem_0a[3:0], ofif_resp_active_0a, ofif_credit,
		        fsabi_valid, fsabi_did[3:0], fsabi_subdid[3:0], fsabi_data[63:0]})
	);

	chipscope_ila ila2 (
		.CONTROL(control2), // INOUT BUS [35:0]
		.CLK(clk0_tb), // IN
		.TRIG0({0, rst0_tb, phy_init_done,
		        app_af_wren, app_af_cmd[2:0], app_af_addr[30:0], app_af_afull,
		        app_wdf_wren, app_wdf_data[31:0], app_wdf_mask_data[15:0], app_wdf_afull,
		        rd_data_valid, rd_data_fifo_out[31:0]}) // IN BUS [255:0]
	);
	
	end else begin: debug_tieoff
	
	assign control_vio = {36{1'bz}};
	
	end
	endgenerate

endmodule

// Local Variables:
// verilog-library-directories:("." "mig")
// End:
