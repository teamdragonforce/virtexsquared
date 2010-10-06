module FSABMemory(/*AUTOARG*/
   // Outputs
   ddr2_a, ddr2_ba, ddr2_ras_n, ddr2_cas_n, ddr2_we_n, ddr2_cs_n,
   ddr2_odt, ddr2_cke, ddr2_dm, ddr2_ck, ddr2_ck_n, clk, fsabo_credit,
   fsabi_valid, fsabi_did, fsabi_subdid, fsabi_data,
   // Inouts
   ddr2_dq, ddr2_dqs, ddr2_dqs_n,
   // Inputs
   sys_clk_p, sys_clk_n, clk200_p, clk200_n, sys_rst_n, Nrst,
   fsabo_valid, fsabo_mode, fsabo_did, fsabo_subdid, fsabo_addr,
   fsabo_len, fsabo_data, fsabo_mask
   );
	`include "fsab_defines.vh"
	`include "memory_defines.vh"

	/* Out to pins */
	inout  [DQ_WIDTH-1:0]              ddr2_dq;
	output [ROW_WIDTH-1:0]             ddr2_a;
	output [BANK_WIDTH-1:0]            ddr2_ba;
	output                             ddr2_ras_n;
	output                             ddr2_cas_n;
	output                             ddr2_we_n;
	output [CS_WIDTH-1:0]              ddr2_cs_n;
	output [ODT_WIDTH-1:0]             ddr2_odt;
	output [CKE_WIDTH-1:0]             ddr2_cke;
	output [DM_WIDTH-1:0]              ddr2_dm;
	input                              sys_clk_p;
	input                              sys_clk_n;
	input                              clk200_p;
	input                              clk200_n;
	input                              sys_rst_n;
	inout  [DQS_WIDTH-1:0]             ddr2_dqs;
	inout  [DQS_WIDTH-1:0]             ddr2_dqs_n;
	output [CLK_WIDTH-1:0]             ddr2_ck;
	output [CLK_WIDTH-1:0]             ddr2_ck_n;

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

	parameter SIMMEM_SIZE = 8 * 1024 * 1024;

	/*** Inbound request FIFO (RFIF) ***/
`define SIMMEM_RFIF_HI (FSAB_REQ_HI+1 + FSAB_DID_HI+1 + FSAB_DID_HI+1 + FSAB_ADDR_HI+1 + FSAB_LEN_HI)
	reg [FSAB_CREDITS_HI:0] rfif_wpos_0a = 'h0;
	reg [FSAB_CREDITS_HI:0] rfif_rpos_0a = 'h0;
	reg [`SIMMEM_RFIF_HI:0] rfif_fifo [(FSAB_INITIAL_CREDITS-1):0];
	wire rfif_wr_0a;
	wire rfif_rd_0a;
	wire [`SIMMEM_RFIF_HI:0] rfif_wdat_0a;
	reg [`SIMMEM_RFIF_HI:0] rfif_rdat_1a;
	wire rfif_empty_0a = (rfif_rpos_0a == rfif_wpos_0a);
	wire rfif_full_0a = (rfif_wpos_0a == (rfif_rpos_0a + FSAB_INITIAL_CREDITS));
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			rfif_wpos_0a <= 'h0;
			rfif_rpos_0a <= 'h0;
		end else begin
			if (rfif_rd_0a) begin
				$display("SIMMEM: %5d: reading from rfif", $time);
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				/* TODO: ^ */
				rfif_rdat_1a <= rfif_fifo[rfif_rpos_0a[1:0]];
				rfif_rpos_0a <= rfif_rpos_0a + 'h1;
			end
			
			if (rfif_wr_0a) begin
				$display("SIMMEM: %5d: writing to rfif (%d word %s)", $time, fsabo_len, (fsabo_mode == FSAB_WRITE) ? "write" : "read");
				rfif_fifo[rfif_wpos_0a[1:0]] <= rfif_wdat_0a;
				rfif_wpos_0a <= rfif_wpos_0a + 'h1;
			end
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
	assign rfif_wdat_0a = {fsabo_mode, fsabo_did, fsabo_subdid,
	                       fsabo_addr, fsabo_len};
	reg [FSAB_LEN_HI:0] fsabo_cur_req_len_rem_1a = 0;
	wire fsabo_cur_req_done_1a = (fsabo_cur_req_len_rem_1a == 0 /* we were done long ago */ || 
	                              fsabo_cur_req_len_rem_1a == 1 /* last cycle (1a) was the last word;
								       this cycle (0a), len will be 0 */);
	assign rfif_wr_0a = fsabo_valid && fsabo_cur_req_done_1a;
	
	always @(posedge clk or negedge Nrst)
		if (Nrst) begin
			fsabo_cur_req_len_rem_1a <= 0;
		end else begin
			if (fsabo_valid && fsabo_cur_req_done_1a && (fsabo_mode == FSAB_WRITE))
				fsabo_cur_req_len_rem_1a <= fsabo_len;
			else if (fsabo_valid && fsabo_cur_req_len_rem_1a != 0)
				fsabo_cur_req_len_rem_1a <= fsabo_cur_req_len_rem_1a - 1;
		end
	
	/*** Inbound data FIFO (DFIF) ***/
`define SIMMEM_DFIF_MAX ((FSAB_INITIAL_CREDITS * FSAB_LEN_MAX) - 1)
`define SIMMEM_DFIF_HI ($clog2(`SIMMEM_DFIF_MAX) - 1)
	reg [`SIMMEM_DFIF_HI:0] dfif_wpos_0a = 'h0;
	reg [`SIMMEM_DFIF_HI:0] dfif_rpos_0a = 'h0;
	reg [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_fifo [`SIMMEM_DFIF_MAX:0];
	wire dfif_wr_0a;
	wire dfif_rd_0a;
	wire [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_wdat_0a;
	reg [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_rdat_1a;
	wire dfif_empty_0a = (dfif_rpos_0a == dfif_wpos_0a);
	wire dfif_full_0a = (dfif_wpos_0a == (dfif_rpos_0a + `SIMMEM_DFIF_MAX));
	wire [`SIMMEM_DFIF_HI:0] dfif_avail_0a = dfif_wpos_0a - dfif_rpos_0a;
	
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			dfif_wpos_0a <= 'h0;
			dfif_rpos_0a <= 'h0;
		end else begin
			if (dfif_rd_0a) begin
				$display("SIMMEM: %5d: reading from dfif (ad %d, da %x)", $time, dfif_rpos_0a, dfif_fifo[dfif_rpos_0a]);
				/* NOTE: this FIFO style will NOT port to Xilinx! */
				dfif_rdat_1a <= dfif_fifo[dfif_rpos_0a];
				dfif_rpos_0a <= dfif_rpos_0a + 'h1;
			end else begin
				dfif_rdat_1a <= {(FSAB_DATA_HI+1 + FSAB_MASK_HI+1){1'hx}};
			end
			
			if (dfif_wr_0a) begin
				$display("SIMMEM: %5d: writing to dfif (ad %d, %08b mask, %08x data)", $time, dfif_wpos_0a, fsabo_mask, fsabo_data);
				dfif_fifo[dfif_wpos_0a] <= dfif_wdat_0a;
				dfif_wpos_0a <= dfif_wpos_0a + 'h1;
			end
		end
	
	/*** DFIF demux & control */
	wire [FSAB_DATA_HI:0] dfif_data_1a;
	wire [FSAB_MASK_HI:0] dfif_mask_1a;
	
	/* dfif_rd is assigned later */
	assign {dfif_data_1a,dfif_mask_1a} = dfif_rdat_1a;
	assign dfif_wdat_0a = {fsabo_data,fsabo_mask};
	assign dfif_wr_0a = fsabo_valid;
	/* NOTE: this means that dfif_rd must ALWAYS be asserted along with
	 * rfif_rd...  even if len is 0, or even if the request was a read!
	 */
	
	/*** Pipe-throughs ***/
	reg rfif_rd_1a = 0;
	reg dfif_rd_1a = 0;
	always @(posedge clk or negedge Nrst)
		if (!Nrst) begin
			rfif_rd_1a <= 0;
			dfif_rd_1a <= 0;
		end else begin
			rfif_rd_1a <= rfif_rd_0a;
			dfif_rd_1a <= dfif_rd_0a;
		end
	
	/*** Memory control logic ***/
	mig #(
		.BANK_WIDTH             (BANK_WIDTH),
		.CKE_WIDTH              (CKE_WIDTH),
		.CLK_WIDTH              (CLK_WIDTH),
		.COL_WIDTH              (COL_WIDTH),
		.CS_NUM                 (CS_NUM),
		.CS_WIDTH               (CS_WIDTH),
		.CS_BITS                (CS_BITS),
		.DM_WIDTH               (DM_WIDTH),
		.DQ_WIDTH               (DQ_WIDTH),
		.DQ_PER_DQS             (DQ_PER_DQS),
		.DQS_WIDTH              (DQS_WIDTH),
		.DQ_BITS                (DQ_BITS),
		.DQS_BITS               (DQS_BITS),
		.ODT_WIDTH              (ODT_WIDTH),
		.ROW_WIDTH              (ROW_WIDTH),
		.ADDITIVE_LAT           (ADDITIVE_LAT),
		.BURST_LEN              (BURST_LEN),
		.BURST_TYPE             (BURST_TYPE),
		.CAS_LAT                (CAS_LAT),
		.ECC_ENABLE             (ECC_ENABLE),
		.APPDATA_WIDTH          (APPDATA_WIDTH),
		.MULTI_BANK_EN          (MULTI_BANK_EN),
		.TWO_T_TIME_EN          (TWO_T_TIME_EN),
		.ODT_TYPE               (ODT_TYPE),
		.REDUCE_DRV             (REDUCE_DRV),
		.REG_ENABLE             (REG_ENABLE),
		.TREFI_NS               (TREFI_NS),
		.TRAS                   (TRAS),
		.TRCD                   (TRCD),
		.TRFC                   (TRFC),
		.TRP                    (TRP),
		.TRTP                   (TRTP),
		.TWR                    (TWR),
		.TWTR                   (TWTR),
		.HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),
		.IODELAY_GRP            (IODELAY_GRP),
		.SIM_ONLY               (SIM_ONLY),
		.DEBUG_EN               (DEBUG_EN),
		.FPGA_SPEED_GRADE       (2),
		.USE_DM_PORT            (1),
		.CLK_PERIOD             (CLK_PERIOD)
	)
	the_mig (
		.ddr2_dq(ddr2_dq),
		.ddr2_a(ddr2_a),
		.ddr2_ba(ddr2_ba),
		.ddr2_ras_n(ddr2_ras_n),
		.ddr2_cas_n(ddr2_cas_n),
		.ddr2_we_n(ddr2_we_n),
		.ddr2_cs_n(ddr2_cs_n),
		.ddr2_odt(ddr2_odt),
		.ddr2_cke(ddr2_cke),
		.ddr2_dm(ddr2_dm),
		.sys_clk_p(sys_clk_p),
		.sys_clk_n(sys_clk_n),
		.clk200_p(clk200_p),
		.clk200_n(clk200_n),
		.sys_rst_n(sys_rst_n),
		.phy_init_done(phy_init_done),
		.rst0_tb(rst0_tb),
		.clk0_tb(clk0_tb),
		.app_wdf_afull(app_wdf_afull),
		.app_af_afull(app_af_afull),
		.rd_data_valid(rd_data_valid),
		.app_wdf_wren(app_wdf_wren),
		.app_af_wren(app_af_wren),
		.app_af_addr(app_af_addr),
		.app_af_cmd(app_af_cmd),
		.rd_data_fifo_out(rd_data_fifo_out),
		.app_wfdf_data(app_wfdf_data),
		.app_wdf_mask_data(app_wdf_mask_data),
		.ddr2_dqs(ddr2_dqs),
		.ddr2_dqs_n(ddr2_dqs_n),
		.ddr2_ck(ddr2_ck),
		.ddr2_ck_n(ddr2_ck_n)
	);
endmodule
