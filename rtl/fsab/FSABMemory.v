module FSABMemory(/*AUTOARG*/
   // Outputs
   clk0_tb, ddr2_a, ddr2_ba, ddr2_cas_n, ddr2_ck, ddr2_ck_n, ddr2_cke,
   ddr2_cs_n, ddr2_dm, ddr2_odt, ddr2_ras_n, ddr2_we_n, phy_init_done,
   clk, fsabo_credit, fsabi_valid, fsabi_did, fsabi_subdid,
   fsabi_data,
   // Inouts
   ddr2_dq, ddr2_dqs, ddr2_dqs_n,
   // Inputs
   clk200_n, clk200_p, sys_clk_n, sys_clk_p, sys_rst_n, rst_b,
   fsabo_valid, fsabo_mode, fsabo_did, fsabo_subdid, fsabo_addr,
   fsabo_len, fsabo_data, fsabo_mask
   );
	`include "fsab_defines.vh"
	`include "memory_defines.vh"
	`include "clog2.vh"

	input		clk200_n;		// To the_mig of mig.v
	input		clk200_p;		// To the_mig of mig.v
	input		sys_clk_n;		// To the_mig of mig.v
	input		sys_clk_p;		// To the_mig of mig.v
	input		sys_rst_n;		// To the_mig of mig.v
	output		clk0_tb;		// From the_mig of mig.v
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
	input                        rst_b;
	
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
	
	always @(posedge clk or negedge rst_b)
		if (!rst_b) begin
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
	
	always @(posedge clk or negedge rst_b)
		if (rst_b) begin
			fsabo_cur_req_len_rem_1a <= 0;
		end else begin
			if (fsabo_valid && fsabo_cur_req_done_1a && (fsabo_mode == FSAB_WRITE))
				fsabo_cur_req_len_rem_1a <= fsabo_len;
			else if (fsabo_valid && fsabo_cur_req_len_rem_1a != 0)
				fsabo_cur_req_len_rem_1a <= fsabo_cur_req_len_rem_1a - 1;
		end
	
	/*** Inbound data FIFO (DFIF) ***/
`define SIMMEM_DFIF_MAX ((FSAB_INITIAL_CREDITS * FSAB_LEN_MAX) - 1)
`define SIMMEM_DFIF_HI (clog2(`SIMMEM_DFIF_MAX) - 1)
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
	
	always @(posedge clk or negedge rst_b)
		if (!rst_b) begin
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
	always @(posedge clk or negedge rst_b)
		if (!rst_b) begin
			rfif_rd_1a <= 0;
			dfif_rd_1a <= 0;
		end else begin
			rfif_rd_1a <= rfif_rd_0a;
			dfif_rd_1a <= dfif_rd_0a;
		end
	
	/*** Memory control logic ***/
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
endmodule

// Local Variables:
// verilog-library-directories:("." "mig")
// End:
