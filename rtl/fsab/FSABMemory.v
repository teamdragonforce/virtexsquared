module FSABMemory(/*AUTOARG*/
   // Outputs
   ddr2_a, ddr2_ba, ddr2_cas_n, ddr2_ck, ddr2_ck_n, ddr2_cke,
   ddr2_cs_n, ddr2_dm, ddr2_odt, ddr2_ras_n, ddr2_we_n, phy_init_done,
   clk0_tb, rst0_tb, fsabo_credit, fsabi_valid, fsabi_did,
   fsabi_subdid, fsabi_data,
   // Inouts
   ddr2_dq, ddr2_dqs, ddr2_dqs_n,
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

`define OFIF_INITIAL_CREDITS FSAB_INITIAL_CREDITS
`define OFIF_CREDIT_WIDTH (clog2(`OFIF_INITIAL_CREDITS))
	reg [`OFIF_CREDIT_WIDTH-1:0] ofif_credits = `OFIF_INITIAL_CREDITS;
	wire ofif_credit;
	wire ofif_debit;
	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			ofif_credits <= `OFIF_INITIAL_CREDITS;
		end else begin
			ofif_credits <= ofif_credits
			                + (ofif_debit ? -1 : 0)
			                + (ofif_credit ? 1 : 0);
		end

	/*** INBOUND ***/

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
	
	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			irfif_wpos_0a <= 'h0;
			irfif_rpos_0a <= 'h0;
		end else begin
			if (irfif_rd_0a) begin
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				/* TODO: ^ */
				irfif_rdat_1a <= irfif_fifo[irfif_rpos_0a[1:0]];
				irfif_rpos_0a <= irfif_rpos_0a + 'h1;
			end
			
			if (irfif_wr_0a) begin
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
	
	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
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
	
	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			idfif_wpos_0a <= 'h0;
			idfif_rpos_0a <= 'h0;
		end else begin
			if (idfif_rd_0a) begin
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				idfif_rdat_1a <= idfif_fifo[idfif_rpos_0a];
				idfif_rpos_0a <= idfif_rpos_0a + 'h1;
			end else begin
				idfif_rdat_1a <= {(FSAB_DATA_HI+1 + FSAB_MASK_HI+1){1'hx}};
			end
			
			if (idfif_wr_0a) begin
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

	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			fsabo_prev_data <= 0;
			fsabo_prev_mask <= {(FSAB_MASK_HI+1){1'h1}};
		end else if (fsabo_valid) begin
			fsabo_prev_data <= fsabo_data;
			fsabo_prev_mask <= fsabo_mask;
		end

	reg fsabo_want_prev = 0;
	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
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

	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			ifif_reqs_queued_0a <= 0;
		end else begin
			ifif_reqs_queued_0a <= ifif_reqs_queued_0a + (idfif_req_queued_0a ? 1 : 0)
			                                           + (irfif_rd_0a ? -1 : 0);
		end
	
	/*** Pipe-throughs ***/
	wire mem_stall_0a;
	reg irfif_rd_1a = 0;
	reg idfif_rd_1a = 0;
	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			irfif_rd_1a <= 0;
			idfif_rd_1a <= 0;
		end else begin
			if (! mem_stall_0a) begin
				irfif_rd_1a <= irfif_rd_0a;
				idfif_rd_1a <= idfif_rd_0a;
			end
		end
	
	/*** Memory control logic ***/
	/* Active determines whether we have a request waiting (i.e., we did
	 * an IRFIF read).  It is high as long as we are serving it (which
	 * is exactly the number of cycles in 'len', since the MIG requires
	 * the data in a burst).
	 */

	reg  [FSAB_LEN_HI:0]  mem_cur_req_ddr_len_rem_0a = 'h0;
	wire                  mem_cur_req_active_0a;
	reg                   mem_cur_req_active_1a = 0;
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

	/* If we just finished reading from the idfif for the last time
	 * (i.e., we just went inactive), then we can release a credit. 
	 * This is as distinct from releasing a credit every time we read
	 * from irfif, which is incorrect because there may not yet be space
	 * in the idfif yet.
	 */
	assign fsabo_credit = mem_cur_req_active_1a && !mem_cur_req_active_0a;
	
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


	assign mem_cur_req_active_0a = irfif_mode_1a == FSAB_WRITE &&
	                               ((irfif_rd_1a && irfif_ddr_len_1a != 1) ||
	                                (mem_cur_req_ddr_len_rem_0a != 1 && mem_cur_req_ddr_len_rem_0a != 0));
	
	assign mem_cur_req_addr_1a = irfif_rd_1a ?
	                                 irfif_addr_1a :
	                                 mem_cur_req_addr_1a_r;

	assign app_af_cmd = irfif_mode_1a == FSAB_WRITE ? MIG_WRITE : MIG_READ;
	assign app_af_addr = mem_cur_req_addr_1a;
	assign app_af_wren = irfif_rd_1a && !mem_stall_0a;

	assign app_wdf_wren = irfif_mode_1a == FSAB_WRITE && idfif_rd_1a && !mem_stall_0a;
	assign app_wdf_data = {idfif_data2_1a, idfif_data_1a};
	assign app_wdf_mask_data = {idfif_mask2_1a, idfif_mask_1a};

	assign ofif_debit = irfif_rd_1a && irfif_mode_1a == FSAB_READ;

	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			mem_cur_req_ddr_len_rem_0a <= 'h0;
			mem_cur_req_active_1a <= 0;
			mem_cur_req_addr_1a_r <= 0;
		end else begin
			mem_cur_req_active_1a <= mem_cur_req_active_0a;
		
			if (irfif_rd_1a && ! mem_stall_0a) begin
				mem_cur_req_ddr_len_rem_0a <= irfif_ddr_len_1a - 1;
			end else if (irfif_rd_1a && mem_stall_0a) begin
				mem_cur_req_ddr_len_rem_0a <= irfif_ddr_len_1a;
			end else if (app_wdf_wren)
				mem_cur_req_ddr_len_rem_0a <= mem_cur_req_ddr_len_rem_0a - 1;
			
			if (irfif_rd_1a)
				mem_cur_req_addr_1a_r <= irfif_addr_1a;
			else if (idfif_rd_0a)
				mem_cur_req_addr_1a_r <= mem_cur_req_addr_1a + (FSAB_DATA_HI + 1) / 8;
		end

	/*** OUTBOUND ***/

	wire [2*DQ_WIDTH-1:0]    rd_data_fifo_out; 
	wire                     rd_data_valid;
	reg [FSAB_LEN_HI:0]      ofif_resp_len_rem_0a = 0;
	wire                     ofif_resp_active_0a;

	/*** Outbound request FIFO (ORFIF) ***/
`define MEM_ORFIF_MAX ((FSAB_LEN_MAX)-1)
`define MEM_ORFIF_WIDTH (FSAB_DID_HI+1 + FSAB_DID_HI+1 + FSAB_LEN_HI+1)
`define MEM_ORFIF_IND_WIDTH (clog2(`MEM_ORFIF_MAX))
	reg [`MEM_ORFIF_IND_WIDTH-1:0] orfif_wpos_0a = 'h0;
	reg [`MEM_ORFIF_IND_WIDTH-1:0] orfif_rpos_0a = 'h0;
	reg [`MEM_ORFIF_WIDTH-1:0] orfif_fifo [`MEM_ORFIF_MAX:0];
	wire orfif_wr_0a;
	wire orfif_rd_0a;
	wire [`MEM_ORFIF_WIDTH-1:0] orfif_wdat_0a;
	reg [`MEM_ORFIF_WIDTH-1:0] orfif_rdat_1a;
	wire orfif_empty_0a = (orfif_rpos_0a == orfif_wpos_0a);
	wire orfif_full_0a = (orfif_wpos_0a == (orfif_rpos_0a + `MEM_ORFIF_MAX));
	wire [`MEM_ORFIF_IND_WIDTH-1:0] orfif_avail_0a = orfif_wpos_0a - orfif_rpos_0a;

	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			orfif_wpos_0a <= 'h0;
			orfif_rpos_0a <= 'h0;
		end else begin
			if (orfif_rd_0a) begin
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				orfif_rdat_1a <= orfif_fifo[orfif_rpos_0a];
				orfif_rpos_0a <= orfif_rpos_0a + 'h1;
			end else begin
				orfif_rdat_1a <= {(FSAB_DATA_HI+1 + FSAB_MASK_HI+1){1'hx}};
			end
			
			if (orfif_wr_0a) begin
				orfif_fifo[orfif_wpos_0a] <= orfif_wdat_0a;
				orfif_wpos_0a <= orfif_wpos_0a + 'h1;
			end
		end

	/*** ORFIF demux & control ***/
	wire [FSAB_DID_HI:0]  orfif_did_1a;
	wire [FSAB_DID_HI:0]  orfif_subdid_1a;
	wire [FSAB_LEN_HI:0]  orfif_len_1a;

	assign orfif_wr_0a = irfif_rd_1a && irfif_mode_1a == FSAB_READ;
	assign orfif_wdat_0a = {irfif_did_1a, irfif_subdid_1a, irfif_len_1a};
	assign {orfif_did_1a, orfif_subdid_1a, orfif_len_1a} = orfif_rdat_1a;

	/*** Outbound data FIFO (ODFIF) ***/
`define MEM_ODFIF_MAX ((FSAB_LEN_MAX)-1)
`define MEM_ODFIF_WIDTH (2*FSAB_DATA_HI+1)
`define MEM_ODFIF_HI (2*(clog2(`MEM_ODFIF_MAX)-1)+1)
	reg [`MEM_ODFIF_HI:0] odfif_wpos_0a = 'h0;
	reg [`MEM_ODFIF_HI:0] odfif_rpos_0a = 'h0;
	reg [`MEM_ODFIF_WIDTH:0] odfif_fifo [`MEM_ODFIF_MAX:0];
	wire odfif_wr_0a;
	wire odfif_rd_0a;
	wire [`MEM_ODFIF_WIDTH:0] odfif_wdat_0a;
	reg [`MEM_ODFIF_WIDTH:0] odfif_rdat_1a;
	wire odfif_empty_0a = (odfif_rpos_0a == odfif_wpos_0a);
	wire odfif_full_0a = (odfif_wpos_0a == (odfif_rpos_0a + `MEM_ODFIF_MAX));
	wire [`MEM_ODFIF_HI:0] odfif_avail_0a = odfif_wpos_0a - odfif_rpos_0a;

	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			odfif_wpos_0a <= 'h0;
			odfif_rpos_0a <= 'h0;
		end else begin
			if (odfif_rd_0a) begin
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				odfif_rdat_1a <= odfif_fifo[odfif_rpos_0a];
				odfif_rpos_0a <= odfif_rpos_0a + 'h1;
			end else begin
				odfif_rdat_1a <= {(2*FSAB_DATA_HI-1){1'hx}};
			end
			
			if (odfif_wr_0a) begin
				odfif_fifo[odfif_wpos_0a] <= odfif_wdat_0a;
				odfif_wpos_0a <= odfif_wpos_0a + 'h1;
			end
		end

	/*** ORFIF demux & control ***/
	assign odfif_wdat_0a = rd_data_fifo_out;
	assign odfif_wr_0a = rd_data_valid;
	wire [FSAB_DATA_HI:0] odfif_data_1a, odfif_data2_1a;
	assign {odfif_data2_1a, odfif_data_1a} = odfif_rdat_1a;
	
	/*** Pipe-throughs ***/
	reg orfif_rd_1a = 0;
	reg odfif_rd_1a = 0;
	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			orfif_rd_1a <= 0;
			odfif_rd_1a <= 0;
		end else begin
			orfif_rd_1a <= orfif_rd_0a;
			odfif_rd_1a <= odfif_rd_0a;
		end

	always @(posedge clk0_tb or posedge rst0_tb)
		if (rst0_tb) begin
			ofif_resp_len_rem_0a <= 0;
		end else begin
			if (orfif_rd_1a)
				ofif_resp_len_rem_0a <= orfif_len_1a - 1;
			else if (ofif_resp_len_rem_0a != 0)
				ofif_resp_len_rem_0a <= ofif_resp_len_rem_0a - 1;
		end

	assign orfif_rd_0a = !orfif_empty_0a && !ofif_resp_active_0a;
	assign odfif_rd_0a = orfif_rd_0a || (ofif_resp_active_0a && !odfif_rd_1a);

	assign ofif_resp_active_0a = (orfif_rd_1a && orfif_len_1a != 1) ||
	                             (ofif_resp_len_rem_0a != 1 && ofif_resp_len_rem_0a != 0);

	assign ofif_credit = fsabi_valid && !ofif_resp_active_0a;

	assign fsabi_data = (!odfif_rd_1a) ? odfif_data2_1a : odfif_data_1a;
	assign fsabi_valid = orfif_rd_1a || ofif_resp_len_rem_0a != 0;
	assign fsabi_did = orfif_did_1a;
	assign fsabi_subdid = orfif_subdid_1a;

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

	wire [35:0] control0, control1, control2, control3;

	chipscope_icon icon (
		.CONTROL0(control0), // INOUT BUS [35:0]
		.CONTROL1(control1), // INOUT BUS [35:0]
		.CONTROL2(control2), // INOUT BUS [35:0]
		.CONTROL3(control3)  // INOUT BUS [35:0]
	);

	chipscope_ila ila0 (
		.CONTROL(control0), // INOUT BUS [35:0]
		.CLK(clk0_tb), // IN
		.TRIG0({0, rst0_tb, fsabo_mode[0], fsabo_did[3:0], fsabo_subdid[3:0], fsabo_addr[30:0], fsabo_len[3:0], fsabo_data[63:0], fsabo_mask[7:0], fsabo_credit, fsabo_valid}) // IN BUS [255:0]
	);

	chipscope_ila ila1 (
		.CONTROL(control1), // INOUT BUS [35:0]
		.CLK(clk0_tb), // IN
		.TRIG0({0, rst0_tb, fsabi_did[3:0], fsabi_subdid[3:0], fsabi_data[63:0], fsabi_valid}) // IN BUS [255:0]
	);

	chipscope_ila ila2 (
		.CONTROL(control2), // INOUT BUS [35:0]
		.CLK(clk0_tb), // IN
		.TRIG0({0, rst0_tb, phy_init_done, app_af_wren, app_af_cmd, app_af_addr, app_af_afull, app_wdf_wren, app_wdf_data, app_wdf_mask_data, app_wdf_afull}) // IN BUS [255:0]
	);

	chipscope_ila ila3 (
		.CONTROL(control3), // INOUT BUS [35:0]
		.CLK(clk0_tb), // IN
		.TRIG0({0, rst0_tb, rd_data_valid, rd_data_fifo_out}) // IN BUS [255:0]
	);

endmodule

// Local Variables:
// verilog-library-directories:("." "mig")
// End:
