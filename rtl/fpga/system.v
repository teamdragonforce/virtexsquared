module System(/*AUTOARG*/
   // Outputs
   ddr2_a, ddr2_ba, ddr2_cas_n, ddr2_ck, ddr2_ck_n, ddr2_cke,
   ddr2_cs_n, ddr2_dm, ddr2_odt, ddr2_ras_n, ddr2_we_n, leds, lcd_db,
   lcd_e, lcd_rnw, lcd_rs, dvi_vs, dvi_hs, dvi_d, dvi_xclk_p,
   dvi_xclk_n, dvi_de, dvi_reset_b, sace_mpa, sace_mpce_n,
   sace_mpoe_n, sace_mpwe_n, usb_cs_n,
   // Inouts
   ddr2_dq, ddr2_dqs, ddr2_dqs_n, dvi_sda, dvi_scl, sace_mpd,
   // Inputs
   clk200_n, clk200_p, sys_clk_n, sys_clk_p, sys_rst_n, corerst_btn,
   sace_clk
   );

	`include "memory_defines.vh"

	/* Ok, this autoinout thing has to go. */

	input		clk200_n;		// To mem of FSABMemory.v
	input		clk200_p;		// To mem of FSABMemory.v
	input		sys_clk_n;		// To mem of FSABMemory.v
	input		sys_clk_p;		// To mem of FSABMemory.v
	input		sys_rst_n;		// To mem of FSABMemory.v
	input           corerst_btn;

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
	inout [DQ_WIDTH-1:0] ddr2_dq;		// To/From mem of FSABMemory.v
	inout [DQS_WIDTH-1:0] ddr2_dqs;		// To/From mem of FSABMemory.v
	inout [DQS_WIDTH-1:0] ddr2_dqs_n;	// To/From mem of FSABMemory.v

	output [7:0] leds;
	
	output [3:0]	lcd_db;			// To/From lcd of SPAM_LCD.v
	output		lcd_e;			// From lcd of SPAM_LCD.v
	output		lcd_rnw;		// From lcd of SPAM_LCD.v
	output		lcd_rs;			// From lcd of SPAM_LCD.v
	
	output dvi_vs, dvi_hs;
	output [11:0] dvi_d;
	output dvi_xclk_p, dvi_xclk_n;
	output dvi_de;
	output dvi_reset_b;
	inout  dvi_sda;
	inout  dvi_scl;
	
	input		sace_clk;
	output [6:0]	sace_mpa;
	output		sace_mpce_n;
	inout [15:0]	sace_mpd;
	output		sace_mpoe_n;
	output		sace_mpwe_n;
	output wire     usb_cs_n;
	
	assign usb_cs_n = 1;

`include "fsab_defines.vh"
`include "spam_defines.vh"

	/*AUTO_LISP(defvar list-of-prefixes '("pre" "ic" "dc" "fb"))*/

	/*AUTOWIRE*/
	// Beginning of automatic wires (for undeclared instantiated-module outputs)
	wire		cclk_preload_ready_b;	// From preload of FSABPreload.v
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
	wire [FSAB_ADDR_HI:0] fb__fsabo_addr;	// From fb of Framebuffer.v
	wire		fb__fsabo_credit;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DATA_HI:0] fb__fsabo_data;	// From fb of Framebuffer.v
	wire [FSAB_DID_HI:0] fb__fsabo_did;	// From fb of Framebuffer.v
	wire [FSAB_LEN_HI:0] fb__fsabo_len;	// From fb of Framebuffer.v
	wire [FSAB_MASK_HI:0] fb__fsabo_mask;	// From fb of Framebuffer.v
	wire [FSAB_REQ_HI:0] fb__fsabo_mode;	// From fb of Framebuffer.v
	wire [FSAB_DID_HI:0] fb__fsabo_subdid;	// From fb of Framebuffer.v
	wire		fb__fsabo_valid;	// From fb of Framebuffer.v
	wire		fb__spami_busy_b;	// From fb of Framebuffer.v
	wire [SPAM_DATA_HI:0] fb__spami_data;	// From fb of Framebuffer.v
	wire		fclk_mem_rst;		// From mem of FSABMemory.v
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
	wire		lcd__spami_busy_b;	// From lcd of SPAM_LCD.v
	wire [SPAM_DATA_HI:0] lcd__spami_data;	// From lcd of SPAM_LCD.v
	wire		phy_init_done;		// From mem of FSABMemory.v
	wire [FSAB_ADDR_HI:0] pre__fsabo_addr;	// From preload of FSABPreload.v
	wire		pre__fsabo_credit;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DATA_HI:0] pre__fsabo_data;	// From preload of FSABPreload.v
	wire [FSAB_DID_HI:0] pre__fsabo_did;	// From preload of FSABPreload.v
	wire [FSAB_LEN_HI:0] pre__fsabo_len;	// From preload of FSABPreload.v
	wire [FSAB_MASK_HI:0] pre__fsabo_mask;	// From preload of FSABPreload.v
	wire [FSAB_REQ_HI:0] pre__fsabo_mode;	// From preload of FSABPreload.v
	wire [FSAB_DID_HI:0] pre__fsabo_subdid;	// From preload of FSABPreload.v
	wire		pre__fsabo_valid;	// From preload of FSABPreload.v
	wire		sace__spami_busy_b;	// From sysace of SPAM_SysACE.v
	wire [SPAM_DATA_HI:0] sace__spami_data;	// From sysace of SPAM_SysACE.v
	wire [SPAM_ADDR_HI:0] spamo_addr;	// From core of Core.v
	wire [SPAM_DATA_HI:0] spamo_data;	// From core of Core.v
	wire [SPAM_DID_HI:0] spamo_did;		// From core of Core.v
	wire		spamo_r_nw;		// From core of Core.v
	wire		spamo_valid;		// From core of Core.v
	// End of automatics

	wire [35:0] control_vio;
	
	/*** Clock and reset synchronization ***/
	
	wire fclk, cclk, fbclk;
	wire fclk_rst_b;
	wire cclk_ready, fbclk_ready;
	
	DCM dcm(.fclk(fclk),
	        .cclk(cclk),
	        .rst(~fclk_rst_b),
	        .ready(cclk_ready));
	
	FBDCM fbdcm(.fclk(fclk),
	            .fbclk(fbclk),
	            .rst(~fclk_rst_b),
	            .ready(fbclk_ready));
	
	reg [26:0] fclk_counter = 0;
	wire fclk_div = fclk_counter[26];
	always @(posedge fclk)
		fclk_counter <= fclk_counter + 1;

	reg [26:0] cclk_counter = 0;
	wire cclk_div = cclk_counter[26];
	always @(posedge cclk)
		cclk_counter <= cclk_counter + 1;
	
	reg [2:0] corerstbtn_ext = 0;
	always @(posedge cclk)
		corerstbtn_ext <= {corerstbtn_ext[1:0], corerst_btn};
	wire cclk_rstbtn_b = ~corerstbtn_ext[2];
	
	assign fclk_rst_b = (~fclk_mem_rst) & (phy_init_done);
	
	wire cclk_rst_cause_b = (cclk_ready) & cclk_rstbtn_b & fclk_rst_b;
	reg [15:0] cclk_rst_b_seq = 16'h0000;
	wire cclk_rst_b = cclk_rst_b_seq[15];
	always @(posedge cclk or negedge cclk_rst_cause_b)
		if (!cclk_rst_cause_b)
			cclk_rst_b_seq <= 16'h0000;
		else
			cclk_rst_b_seq <= {cclk_rst_b_seq[14:0], 1'b1};
	
	wire fbclk_rst_cause_b = (fbclk_ready) & fclk_rst_b;
	reg [15:0] fbclk_rst_b_seq = 16'h0000;
	wire fbclk_rst_b = fbclk_rst_b_seq[15];
	always @(posedge fbclk or negedge fbclk_rst_cause_b)
		if (!fbclk_rst_cause_b)
			fbclk_rst_b_seq <= 16'h0000;
		else
			fbclk_rst_b_seq <= {fbclk_rst_b_seq[14:0], 1'b1};
	
	/*** Rest of the system (c.c) ***/
	
	wire spami_busy_b = cio__spami_busy_b | lcd__spami_busy_b | fb__spami_busy_b | sace__spami_busy_b;
	wire [SPAM_DATA_HI:0] spami_data = cio__spami_data[SPAM_DATA_HI:0] | lcd__spami_data[SPAM_DATA_HI:0] | fb__spami_data[SPAM_DATA_HI:0] | sace__spami_data[SPAM_DATA_HI:0];

	parameter FSAB_DEVICES = 4;
	wire [FSAB_DEVICES-1:0] fsabo_clks = {cclk, cclk, cclk, fbclk};
	wire [FSAB_DEVICES-1:0] fsabo_rst_bs = {cclk_rst_b, cclk_rst_b, cclk_rst_b, fbclk_rst_b};
	

	/* XXX: fsabi_rst_b synch? */
	/* Core AUTO_TEMPLATE (
		.rst_b(cclk_rst_b & cclk_preload_ready_b),
		.fsabi_rst_b(fclk_rst_b),
		.fsabi_clk(fclk),
		.clk(cclk),
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
		  // Inouts
		  .control_vio		(control_vio[35:0]),
		  // Inputs
		  .clk			(cclk),			 // Templated
		  .rst_b		(cclk_rst_b & cclk_preload_ready_b), // Templated
		  .ic__fsabo_credit	(ic__fsabo_credit),
		  .dc__fsabo_credit	(dc__fsabo_credit),
		  .fsabi_valid		(fsabi_valid),
		  .fsabi_did		(fsabi_did[FSAB_DID_HI:0]),
		  .fsabi_subdid		(fsabi_subdid[FSAB_DID_HI:0]),
		  .fsabi_data		(fsabi_data[FSAB_DATA_HI:0]),
		  .fsabi_clk		(fclk),			 // Templated
		  .fsabi_rst_b		(fclk_rst_b),		 // Templated
		  .spami_busy_b		(spami_busy_b),
		  .spami_data		(spami_data[SPAM_DATA_HI:0]));
	defparam core.DEBUG = "FALSE";
	
	wire [8:0] sys_odata;
	wire sys_tookdata;
	wire [8:0] sys_idata = 0;

	/* SPAM_ConsoleIO AUTO_TEMPLATE (
		.clk(cclk),
		);
	*/
	SPAM_ConsoleIO conio(
		/*AUTOINST*/
			     // Outputs
			     .cio__spami_busy_b	(cio__spami_busy_b),
			     .cio__spami_data	(cio__spami_data[SPAM_DATA_HI:0]),
			     .sys_odata		(sys_odata[8:0]),
			     .sys_tookdata	(sys_tookdata),
			     // Inputs
			     .clk		(cclk),		 // Templated
			     .spamo_valid	(spamo_valid),
			     .spamo_r_nw	(spamo_r_nw),
			     .spamo_did		(spamo_did[SPAM_DID_HI:0]),
			     .spamo_addr	(spamo_addr[SPAM_ADDR_HI:0]),
			     .spamo_data	(spamo_data[SPAM_DATA_HI:0]),
			     .sys_idata		(sys_idata[8:0]));
	
	chipscope_ila vio (
		.CONTROL(control_vio), // INOUT BUS [35:0]
		.CLK(cclk), // IN
		.TRIG0({0, sys_odata[8:0]}) // IN BUS [255:0]
	);
	
	/* SPAM_LCD AUTO_TEMPLATE (
		.clk(cclk),
		.rst_b(cclk_rst_b),
		);
	*/
	SPAM_LCD lcd(/*AUTOINST*/
		     // Outputs
		     .lcd__spami_busy_b	(lcd__spami_busy_b),
		     .lcd__spami_data	(lcd__spami_data[SPAM_DATA_HI:0]),
		     .lcd_db		(lcd_db[3:0]),
		     .lcd_e		(lcd_e),
		     .lcd_rnw		(lcd_rnw),
		     .lcd_rs		(lcd_rs),
		     // Inouts
		     .control_vio	(control_vio[35:0]),
		     // Inputs
		     .clk		(cclk),			 // Templated
		     .rst_b		(cclk_rst_b),		 // Templated
		     .spamo_valid	(spamo_valid),
		     .spamo_r_nw	(spamo_r_nw),
		     .spamo_did		(spamo_did[SPAM_DID_HI:0]),
		     .spamo_addr	(spamo_addr[SPAM_ADDR_HI:0]),
		     .spamo_data	(spamo_data[SPAM_DATA_HI:0]));
	defparam lcd.DEBUG = "FALSE";
	
	/* SPAM_SysACE AUTO_TEMPLATE (
		.clk(cclk),
		.rst_b(cclk_rst_b),
		);
	*/
	SPAM_SysACE sysace(/*AUTOINST*/
			   // Outputs
			   .sace__spami_busy_b	(sace__spami_busy_b),
			   .sace__spami_data	(sace__spami_data[SPAM_DATA_HI:0]),
			   .sace_mpa		(sace_mpa[6:0]),
			   .sace_mpce_n		(sace_mpce_n),
			   .sace_mpwe_n		(sace_mpwe_n),
			   .sace_mpoe_n		(sace_mpoe_n),
			   // Inouts
			   .sace_mpd		(sace_mpd[15:0]),
			   .control_vio		(control_vio[35:0]),
			   // Inputs
			   .clk			(cclk),		 // Templated
			   .rst_b		(cclk_rst_b),	 // Templated
			   .spamo_valid		(spamo_valid),
			   .spamo_r_nw		(spamo_r_nw),
			   .spamo_did		(spamo_did[SPAM_DID_HI:0]),
			   .spamo_addr		(spamo_addr[SPAM_ADDR_HI:0]),
			   .spamo_data		(spamo_data[SPAM_DATA_HI:0]),
			   .sace_clk		(sace_clk));
	defparam sysace.DEBUG = "TRUE";

	
	/* FSABArbiter AUTO_TEMPLATE (
		.clk(fclk),
		.rst_b(fclk_rst_b),
		.fsabo_valids(@"(template \"__fsabo_valid\")"),
		.fsabo_modes(@"(template \"__fsabo_mode[FSAB_REQ_HI:0]\")"),
		.fsabo_dids(@"(template \"__fsabo_did[FSAB_DID_HI:0]\")"),
		.fsabo_subdids(@"(template \"__fsabo_subdid[FSAB_DID_HI:0]\")"),
		.fsabo_addrs(@"(template \"__fsabo_addr[FSAB_ADDR_HI:0]\")"),
		.fsabo_lens(@"(template \"__fsabo_len[FSAB_LEN_HI:0]\")"),
		.fsabo_datas(@"(template \"__fsabo_data[FSAB_DATA_HI:0]\")"),
		.fsabo_masks(@"(template \"__fsabo_mask[FSAB_MASK_HI:0]\")"),
		.fsabo_credits(@"(template \"__fsabo_credit\")"),
		); */
	FSABArbiter fsabarbiter(
		/*AUTOINST*/
				// Outputs
				.fsabo_credits	({pre__fsabo_credit,ic__fsabo_credit,dc__fsabo_credit,fb__fsabo_credit}), // Templated
				.fsabo_valid	(fsabo_valid),
				.fsabo_mode	(fsabo_mode[FSAB_REQ_HI:0]),
				.fsabo_did	(fsabo_did[FSAB_DID_HI:0]),
				.fsabo_subdid	(fsabo_subdid[FSAB_DID_HI:0]),
				.fsabo_addr	(fsabo_addr[FSAB_ADDR_HI:0]),
				.fsabo_len	(fsabo_len[FSAB_LEN_HI:0]),
				.fsabo_data	(fsabo_data[FSAB_DATA_HI:0]),
				.fsabo_mask	(fsabo_mask[FSAB_MASK_HI:0]),
				// Inputs
				.clk		(fclk),		 // Templated
				.rst_b		(fclk_rst_b),	 // Templated
				.fsabo_valids	({pre__fsabo_valid,ic__fsabo_valid,dc__fsabo_valid,fb__fsabo_valid}), // Templated
				.fsabo_modes	({pre__fsabo_mode[FSAB_REQ_HI:0],ic__fsabo_mode[FSAB_REQ_HI:0],dc__fsabo_mode[FSAB_REQ_HI:0],fb__fsabo_mode[FSAB_REQ_HI:0]}), // Templated
				.fsabo_dids	({pre__fsabo_did[FSAB_DID_HI:0],ic__fsabo_did[FSAB_DID_HI:0],dc__fsabo_did[FSAB_DID_HI:0],fb__fsabo_did[FSAB_DID_HI:0]}), // Templated
				.fsabo_subdids	({pre__fsabo_subdid[FSAB_DID_HI:0],ic__fsabo_subdid[FSAB_DID_HI:0],dc__fsabo_subdid[FSAB_DID_HI:0],fb__fsabo_subdid[FSAB_DID_HI:0]}), // Templated
				.fsabo_addrs	({pre__fsabo_addr[FSAB_ADDR_HI:0],ic__fsabo_addr[FSAB_ADDR_HI:0],dc__fsabo_addr[FSAB_ADDR_HI:0],fb__fsabo_addr[FSAB_ADDR_HI:0]}), // Templated
				.fsabo_lens	({pre__fsabo_len[FSAB_LEN_HI:0],ic__fsabo_len[FSAB_LEN_HI:0],dc__fsabo_len[FSAB_LEN_HI:0],fb__fsabo_len[FSAB_LEN_HI:0]}), // Templated
				.fsabo_datas	({pre__fsabo_data[FSAB_DATA_HI:0],ic__fsabo_data[FSAB_DATA_HI:0],dc__fsabo_data[FSAB_DATA_HI:0],fb__fsabo_data[FSAB_DATA_HI:0]}), // Templated
				.fsabo_masks	({pre__fsabo_mask[FSAB_MASK_HI:0],ic__fsabo_mask[FSAB_MASK_HI:0],dc__fsabo_mask[FSAB_MASK_HI:0],fb__fsabo_mask[FSAB_MASK_HI:0]}), // Templated
				.fsabo_clks	(fsabo_clks[FSAB_DEVICES-1:0]),
				.fsabo_rst_bs	(fsabo_rst_bs[FSAB_DEVICES-1:0]),
				.fsabo_credit	(fsabo_credit));
	defparam fsabarbiter.FSAB_DEVICES = FSAB_DEVICES;

	/* FSABMemory AUTO_TEMPLATE (
		.clk0_tb(fclk),
		.rst0_tb(fclk_mem_rst),
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
		       .clk0_tb		(fclk),			 // Templated
		       .rst0_tb		(fclk_mem_rst),		 // Templated
		       .fsabo_credit	(fsabo_credit),
		       .fsabi_valid	(fsabi_valid),
		       .fsabi_did	(fsabi_did[FSAB_DID_HI:0]),
		       .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
		       .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]),
		       // Inouts
		       .ddr2_dq		(ddr2_dq[DQ_WIDTH-1:0]),
		       .ddr2_dqs	(ddr2_dqs[DQS_WIDTH-1:0]),
		       .ddr2_dqs_n	(ddr2_dqs_n[DQS_WIDTH-1:0]),
		       .control_vio	(control_vio[35:0]),
		       // Inputs
		       .clk200_n	(clk200_n),
		       .clk200_p	(clk200_p),
		       .sys_clk_n	(sys_clk_n),
		       .sys_clk_p	(sys_clk_p),
		       .sys_rst_n	(sys_rst_n),
		       .fsabo_valid	(fsabo_valid),
		       .fsabo_mode	(fsabo_mode[FSAB_REQ_HI:0]),
		       .fsabo_did	(fsabo_did[FSAB_DID_HI:0]),
		       .fsabo_subdid	(fsabo_subdid[FSAB_DID_HI:0]),
		       .fsabo_addr	(fsabo_addr[FSAB_ADDR_HI:0]),
		       .fsabo_len	(fsabo_len[FSAB_LEN_HI:0]),
		       .fsabo_data	(fsabo_data[FSAB_DATA_HI:0]),
		       .fsabo_mask	(fsabo_mask[FSAB_MASK_HI:0]));
	defparam mem.DEBUG = "FALSE";
	
	reg fsabo_triggered = 0;
	reg [21:0] fsabo_recent = 0;
	always @(posedge fclk or negedge fclk_rst_b)
		if (!fclk_rst_b) begin
			fsabo_recent <= 0;
			fsabo_triggered <= 0;
		end else begin
			if (fsabo_valid && (fsabo_mode == FSAB_READ)) begin
				fsabo_recent <= 1;
				fsabo_triggered <= 1;
			end else if (fsabo_recent == 22'd5000000)	/* 100msec -- a nice flash on the LED */
				fsabo_recent <= 0;
			else if (fsabo_recent != 22'd0)
				fsabo_recent <= fsabo_recent + 1;
		end
		
	assign leds = {1'b0, fclk_rst_b, cclk_rst_b, fsabo_triggered, fsabo_recent != 0, cclk_div, fclk_div, phy_init_done};

	/* FSABPreload AUTO_TEMPLATE (
		.rst_b(cclk_rst_b),
		.rst_core_b(cclk_preload_ready_b),
		.clk(cclk),
		);
	*/
	FSABPreload preload(/*AUTOINST*/
			    // Outputs
			    .rst_core_b		(cclk_preload_ready_b), // Templated
			    .pre__fsabo_valid	(pre__fsabo_valid),
			    .pre__fsabo_mode	(pre__fsabo_mode[FSAB_REQ_HI:0]),
			    .pre__fsabo_did	(pre__fsabo_did[FSAB_DID_HI:0]),
			    .pre__fsabo_subdid	(pre__fsabo_subdid[FSAB_DID_HI:0]),
			    .pre__fsabo_addr	(pre__fsabo_addr[FSAB_ADDR_HI:0]),
			    .pre__fsabo_len	(pre__fsabo_len[FSAB_LEN_HI:0]),
			    .pre__fsabo_data	(pre__fsabo_data[FSAB_DATA_HI:0]),
			    .pre__fsabo_mask	(pre__fsabo_mask[FSAB_MASK_HI:0]),
			    // Inputs
			    .clk		(cclk),		 // Templated
			    .rst_b		(cclk_rst_b),	 // Templated
			    .pre__fsabo_credit	(pre__fsabo_credit),
			    .fsabi_valid	(fsabi_valid),
			    .fsabi_did		(fsabi_did[FSAB_DID_HI:0]),
			    .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
			    .fsabi_data		(fsabi_data[FSAB_DATA_HI:0]));
	
	/* Framebuffer AUTO_TEMPLATE (
		.fsabi_rst_b(fclk_rst_b),
		.fsabi_clk(fclk),
		);
	*/
	Framebuffer fb(/*AUTOINST*/
		       // Outputs
		       .dvi_vs		(dvi_vs),
		       .dvi_hs		(dvi_hs),
		       .dvi_d		(dvi_d[11:0]),
		       .dvi_xclk_p	(dvi_xclk_p),
		       .dvi_xclk_n	(dvi_xclk_n),
		       .dvi_de		(dvi_de),
		       .dvi_reset_b	(dvi_reset_b),
		       .fb__fsabo_valid	(fb__fsabo_valid),
		       .fb__fsabo_mode	(fb__fsabo_mode[FSAB_REQ_HI:0]),
		       .fb__fsabo_did	(fb__fsabo_did[FSAB_DID_HI:0]),
		       .fb__fsabo_subdid(fb__fsabo_subdid[FSAB_DID_HI:0]),
		       .fb__fsabo_addr	(fb__fsabo_addr[FSAB_ADDR_HI:0]),
		       .fb__fsabo_len	(fb__fsabo_len[FSAB_LEN_HI:0]),
		       .fb__fsabo_data	(fb__fsabo_data[FSAB_DATA_HI:0]),
		       .fb__fsabo_mask	(fb__fsabo_mask[FSAB_MASK_HI:0]),
		       .fb__spami_busy_b(fb__spami_busy_b),
		       .fb__spami_data	(fb__spami_data[SPAM_DATA_HI:0]),
		       // Inouts
		       .dvi_sda		(dvi_sda),
		       .dvi_scl		(dvi_scl),
		       .control_vio	(control_vio[35:0]),
		       // Inputs
		       .fbclk		(fbclk),
		       .fbclk_rst_b	(fbclk_rst_b),
		       .cclk		(cclk),
		       .cclk_rst_b	(cclk_rst_b),
		       .fsabi_clk	(fclk),			 // Templated
		       .fsabi_rst_b	(fclk_rst_b),		 // Templated
		       .fsabi_valid	(fsabi_valid),
		       .fsabi_did	(fsabi_did[FSAB_DID_HI:0]),
		       .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
		       .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]),
		       .fb__fsabo_credit(fb__fsabo_credit),
		       .spamo_valid	(spamo_valid),
		       .spamo_r_nw	(spamo_r_nw),
		       .spamo_did	(spamo_did[SPAM_DID_HI:0]),
		       .spamo_addr	(spamo_addr[SPAM_ADDR_HI:0]),
		       .spamo_data	(spamo_data[SPAM_DATA_HI:0]));
	defparam fb.DEBUG = "TRUE";
endmodule

module DCM(input fclk, output cclk, input rst, output ready);
	wire locked, fb, clkdv_buf;
	assign ready = locked;

	BUFG CLKDV_BUFG_INST (.I(clkdv_buf),
	                      .O(cclk));
	DCM_BASE DCM_SP_INST (.CLKIN(fclk), 
	                      .CLKFB(fb),
	                      .CLK0(fb),
	                      .RST(rst), 
	                      .CLKDV(clkdv_buf),
	                      .LOCKED(locked));
	defparam DCM_SP_INST.CLK_FEEDBACK = "1X";
	defparam DCM_SP_INST.CLKDV_DIVIDE = 2.0;
	defparam DCM_SP_INST.CLKIN_DIVIDE_BY_2 = "FALSE";
	defparam DCM_SP_INST.CLKIN_PERIOD = 8.000;
	defparam DCM_SP_INST.CLKOUT_PHASE_SHIFT = "NONE";
	defparam DCM_SP_INST.DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS";
	defparam DCM_SP_INST.DFS_FREQUENCY_MODE = "LOW";
	defparam DCM_SP_INST.DLL_FREQUENCY_MODE = "LOW";
	defparam DCM_SP_INST.DUTY_CYCLE_CORRECTION = "TRUE";
	defparam DCM_SP_INST.FACTORY_JF = 16'hF0F0;
	defparam DCM_SP_INST.PHASE_SHIFT = 0;
	defparam DCM_SP_INST.STARTUP_WAIT = "TRUE";
endmodule

module FBDCM(input fclk, output fbclk, input rst, output ready);
	wire locked, clk0, clkdv;
	assign ready = locked;

	BUFG CLKDV_BUFG_INST (.I(clkdv),
	                      .O(fbclk));
	DCM_BASE DCM_SP_INST (.CLKIN(fclk), 
	                      .CLKFB(clk0),
	                      .CLK0(clk0),
	                      .RST(rst), 
	                      .CLKDV(clkdv),
	                      .LOCKED(locked));
	defparam DCM_SP_INST.CLK_FEEDBACK = "1X";
	defparam DCM_SP_INST.CLKDV_DIVIDE = 5;
	defparam DCM_SP_INST.CLKIN_DIVIDE_BY_2 = "FALSE";
	defparam DCM_SP_INST.CLKIN_PERIOD = 8.000;
	defparam DCM_SP_INST.CLKOUT_PHASE_SHIFT = "NONE";
	defparam DCM_SP_INST.DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS";
	defparam DCM_SP_INST.DFS_FREQUENCY_MODE = "LOW";
	defparam DCM_SP_INST.DLL_FREQUENCY_MODE = "LOW";
	defparam DCM_SP_INST.DUTY_CYCLE_CORRECTION = "TRUE";
	defparam DCM_SP_INST.FACTORY_JF = 16'hF0F0;
	defparam DCM_SP_INST.PHASE_SHIFT = 0;
	defparam DCM_SP_INST.STARTUP_WAIT = "TRUE";
endmodule


/*
Local Variables:
eval:
  (require 'cl)
eval:
  (defun prefixer (prefixes suffix)
    (mapcar #'(lambda (prefix) (concatenate 'string prefix suffix))
            prefixes))
eval:  
  (defun concat-with (separator strings)
    (reduce #'(lambda (&rest args)
                (if (null args) ""
                    (concatenate 'string (car args) separator (cadr args))))
               strings))
eval:
  (defun template (suffix)
    (concatenate 'string
      "{"
      (concat-with "," (prefixer list-of-prefixes suffix))
      "}"))
verilog-library-directories:("." "../console" "../core" "../fsab" "../spam" "../util/" "../fsab/sim")
End:
*/
