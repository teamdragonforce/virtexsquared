module System(/*AUTOARG*/
   // Outputs
   lcd_db, lcd_e, lcd_rnw, lcd_rs,
   // Inputs
   clk, rst, fsabi_clk
   );

	input clk; input rst; input fsabi_clk;
	
	output [3:0] lcd_db;
	output       lcd_e;
	output       lcd_rnw;
	output       lcd_rs;

`include "fsab_defines.vh"
`include "spam_defines.vh"
	
	/*AUTOWIRE*/
	// Beginning of automatic wires (for undeclared instantiated-module outputs)
	wire [FSAB_ADDR_HI:0] accel_clear__fsabo_addr;// From accelclear of AccelClear.v
	wire		accel_clear__fsabo_credit;// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DATA_HI:0] accel_clear__fsabo_data;// From accelclear of AccelClear.v
	wire [FSAB_DID_HI:0] accel_clear__fsabo_did;// From accelclear of AccelClear.v
	wire [FSAB_LEN_HI:0] accel_clear__fsabo_len;// From accelclear of AccelClear.v
	wire [FSAB_MASK_HI:0] accel_clear__fsabo_mask;// From accelclear of AccelClear.v
	wire [FSAB_REQ_HI:0] accel_clear__fsabo_mode;// From accelclear of AccelClear.v
	wire [FSAB_DID_HI:0] accel_clear__fsabo_subdid;// From accelclear of AccelClear.v
	wire		accel_clear__fsabo_valid;// From accelclear of AccelClear.v
	wire		accel_clear__spami_busy_b;// From accelclear of AccelClear.v
	wire [SPAM_DATA_HI:0] accel_clear__spami_data;// From accelclear of AccelClear.v
	wire		cio__spami_busy_b;	// From conio of SPAM_ConsoleIO.v
	wire [SPAM_DATA_HI:0] cio__spami_data;	// From conio of SPAM_ConsoleIO.v
	wire [35:0]	control_vio;		// To/From core of Core.v, ...
	wire [FSAB_ADDR_HI:0] dc__fsabo_addr;	// From core of Core.v
	wire		dc__fsabo_credit;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DATA_HI:0] dc__fsabo_data;	// From core of Core.v
	wire [FSAB_DID_HI:0] dc__fsabo_did;	// From core of Core.v
	wire [FSAB_LEN_HI:0] dc__fsabo_len;	// From core of Core.v
	wire [FSAB_MASK_HI:0] dc__fsabo_mask;	// From core of Core.v
	wire [FSAB_REQ_HI:0] dc__fsabo_mode;	// From core of Core.v
	wire [FSAB_DID_HI:0] dc__fsabo_subdid;	// From core of Core.v
	wire		dc__fsabo_valid;	// From core of Core.v
	wire [11:0]	dvi_d;			// From frame of Framebuffer.v
	wire		dvi_de;			// From frame of Framebuffer.v
	wire		dvi_hs;			// From frame of Framebuffer.v
	wire		dvi_reset_b;		// From frame of Framebuffer.v
	wire		dvi_scl;		// To/From frame of Framebuffer.v
	wire		dvi_sda;		// To/From frame of Framebuffer.v
	wire		dvi_vs;			// From frame of Framebuffer.v
	wire		dvi_xclk_n;		// From frame of Framebuffer.v
	wire		dvi_xclk_p;		// From frame of Framebuffer.v
	wire [FSAB_ADDR_HI:0] fb__fsabo_addr;	// From frame of Framebuffer.v
	wire		fb__fsabo_credit;	// From fsabarbiter of FSABArbiter.v
	wire [FSAB_DATA_HI:0] fb__fsabo_data;	// From frame of Framebuffer.v
	wire [FSAB_DID_HI:0] fb__fsabo_did;	// From frame of Framebuffer.v
	wire [FSAB_LEN_HI:0] fb__fsabo_len;	// From frame of Framebuffer.v
	wire [FSAB_MASK_HI:0] fb__fsabo_mask;	// From frame of Framebuffer.v
	wire [FSAB_REQ_HI:0] fb__fsabo_mode;	// From frame of Framebuffer.v
	wire [FSAB_DID_HI:0] fb__fsabo_subdid;	// From frame of Framebuffer.v
	wire		fb__fsabo_valid;	// From frame of Framebuffer.v
	wire		fb__spami_busy_b;	// From frame of Framebuffer.v
	wire [SPAM_DATA_HI:0] fb__spami_data;	// From frame of Framebuffer.v
	wire [FSAB_DATA_HI:0] fsabi_data;	// From simmem of FSABSimMemory.v
	wire [FSAB_DID_HI:0] fsabi_did;		// From simmem of FSABSimMemory.v
	wire [FSAB_DID_HI:0] fsabi_subdid;	// From simmem of FSABSimMemory.v
	wire		fsabi_valid;		// From simmem of FSABSimMemory.v
	wire [FSAB_ADDR_HI:0] fsabo_addr;	// From fsabarbiter of FSABArbiter.v
	wire		fsabo_credit;		// From simmem of FSABSimMemory.v
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
	wire fsabi_rst_b = ~rst; /* XXX? */

`ifdef DUMMY
	stfu_verilog_mode and_i_mean_it(
					// Inputs
					.cio__spami_busy_b(cio__spami_busy_b),
					.cio__spami_data(cio__spami_data[SPAM_DATA_HI:0]));
`endif
	
	wire spami_busy_b = cio__spami_busy_b | lcd__spami_busy_b | fb__spami_busy_b | accel_clear__spami_busy_b;
	wire [SPAM_DATA_HI:0] spami_data = cio__spami_data[SPAM_DATA_HI:0] | lcd__spami_data[SPAM_DATA_HI:0] | fb__spami_data[SPAM_DATA_HI:0] | accel_clear__spami_data[SPAM_DATA_HI:0];

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
		  // Inouts
		  .control_vio		(control_vio[35:0]),
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
		     .clk		(clk),
		     .rst_b		(rst_b),
		     .spamo_valid	(spamo_valid),
		     .spamo_r_nw	(spamo_r_nw),
		     .spamo_did		(spamo_did[SPAM_DID_HI:0]),
		     .spamo_addr	(spamo_addr[SPAM_ADDR_HI:0]),
		     .spamo_data	(spamo_data[SPAM_DATA_HI:0]));

	wire request;
	/* Framebuffer AUTO_TEMPLATE (
		.cclk(clk),
		.cclk_rst_b(rst_b),
		.fbclk(clk),
		.fbclk_rst_b(rst_b),
		);
	*/
	Framebuffer frame(/*AUTOINST*/
			  // Outputs
			  .dvi_vs		(dvi_vs),
			  .dvi_hs		(dvi_hs),
			  .dvi_d		(dvi_d[11:0]),
			  .dvi_xclk_p		(dvi_xclk_p),
			  .dvi_xclk_n		(dvi_xclk_n),
			  .dvi_de		(dvi_de),
			  .dvi_reset_b		(dvi_reset_b),
			  .fb__fsabo_valid	(fb__fsabo_valid),
			  .fb__fsabo_mode	(fb__fsabo_mode[FSAB_REQ_HI:0]),
			  .fb__fsabo_did	(fb__fsabo_did[FSAB_DID_HI:0]),
			  .fb__fsabo_subdid	(fb__fsabo_subdid[FSAB_DID_HI:0]),
			  .fb__fsabo_addr	(fb__fsabo_addr[FSAB_ADDR_HI:0]),
			  .fb__fsabo_len	(fb__fsabo_len[FSAB_LEN_HI:0]),
			  .fb__fsabo_data	(fb__fsabo_data[FSAB_DATA_HI:0]),
			  .fb__fsabo_mask	(fb__fsabo_mask[FSAB_MASK_HI:0]),
			  .fb__spami_busy_b	(fb__spami_busy_b),
			  .fb__spami_data	(fb__spami_data[SPAM_DATA_HI:0]),
			  // Inouts
			  .dvi_sda		(dvi_sda),
			  .dvi_scl		(dvi_scl),
			  .control_vio		(control_vio[35:0]),
			  // Inputs
			  .fbclk		(clk),		 // Templated
			  .fbclk_rst_b		(rst_b),	 // Templated
			  .cclk			(clk),		 // Templated
			  .cclk_rst_b		(rst_b),	 // Templated
			  .fsabi_clk		(fsabi_clk),
			  .fsabi_rst_b		(fsabi_rst_b),
			  .fsabi_valid		(fsabi_valid),
			  .fsabi_did		(fsabi_did[FSAB_DID_HI:0]),
			  .fsabi_subdid		(fsabi_subdid[FSAB_DID_HI:0]),
			  .fsabi_data		(fsabi_data[FSAB_DATA_HI:0]),
			  .fb__fsabo_credit	(fb__fsabo_credit),
			  .spamo_valid		(spamo_valid),
			  .spamo_r_nw		(spamo_r_nw),
			  .spamo_did		(spamo_did[SPAM_DID_HI:0]),
			  .spamo_addr		(spamo_addr[SPAM_ADDR_HI:0]),
			  .spamo_data		(spamo_data[SPAM_DATA_HI:0]));

	/*AUTO_LISP(defvar list-of-prefixes '("pre" "fb" "ic" "dc" "accel_clear" ))*/
	parameter FSAB_DEVICES = 5;
	wire [FSAB_DEVICES-1:0] fsabo_clks = {clk, clk, clk, clk, fsabi_clk};
	wire [FSAB_DEVICES-1:0] fsabo_rst_bs = {rst_b, rst_b, rst_b, rst_b, fsabi_rst_b};

	/* FSABArbiter AUTO_TEMPLATE (
		.fsabo_valids(@"(template \"__fsabo_valid\")"),
		.fsabo_modes(@"(template \"__fsabo_mode[FSAB_REQ_HI:0]\")"),
		.fsabo_dids(@"(template \"__fsabo_did[FSAB_DID_HI:0]\")"),
		.fsabo_subdids(@"(template \"__fsabo_subdid[FSAB_DID_HI:0]\")"),
		.fsabo_addrs(@"(template \"__fsabo_addr[FSAB_ADDR_HI:0]\")"),
		.fsabo_lens(@"(template \"__fsabo_len[FSAB_LEN_HI:0]\")"),
		.fsabo_datas(@"(template \"__fsabo_data[FSAB_DATA_HI:0]\")"),
		.fsabo_masks(@"(template \"__fsabo_mask[FSAB_MASK_HI:0]\")"),
		.fsabo_credits(@"(template \"__fsabo_credit\")"),
		.clk(fsabi_clk),
		.rst_b(fsabi_rst_b),
		); */
	FSABArbiter fsabarbiter(
		/*AUTOINST*/
				// Outputs
				.fsabo_credits	({pre__fsabo_credit,fb__fsabo_credit,ic__fsabo_credit,dc__fsabo_credit,accel_clear__fsabo_credit}), // Templated
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
				.rst_b		(fsabi_rst_b),	 // Templated
				.fsabo_valids	({pre__fsabo_valid,fb__fsabo_valid,ic__fsabo_valid,dc__fsabo_valid,accel_clear__fsabo_valid}), // Templated
				.fsabo_modes	({pre__fsabo_mode[FSAB_REQ_HI:0],fb__fsabo_mode[FSAB_REQ_HI:0],ic__fsabo_mode[FSAB_REQ_HI:0],dc__fsabo_mode[FSAB_REQ_HI:0],accel_clear__fsabo_mode[FSAB_REQ_HI:0]}), // Templated
				.fsabo_dids	({pre__fsabo_did[FSAB_DID_HI:0],fb__fsabo_did[FSAB_DID_HI:0],ic__fsabo_did[FSAB_DID_HI:0],dc__fsabo_did[FSAB_DID_HI:0],accel_clear__fsabo_did[FSAB_DID_HI:0]}), // Templated
				.fsabo_subdids	({pre__fsabo_subdid[FSAB_DID_HI:0],fb__fsabo_subdid[FSAB_DID_HI:0],ic__fsabo_subdid[FSAB_DID_HI:0],dc__fsabo_subdid[FSAB_DID_HI:0],accel_clear__fsabo_subdid[FSAB_DID_HI:0]}), // Templated
				.fsabo_addrs	({pre__fsabo_addr[FSAB_ADDR_HI:0],fb__fsabo_addr[FSAB_ADDR_HI:0],ic__fsabo_addr[FSAB_ADDR_HI:0],dc__fsabo_addr[FSAB_ADDR_HI:0],accel_clear__fsabo_addr[FSAB_ADDR_HI:0]}), // Templated
				.fsabo_lens	({pre__fsabo_len[FSAB_LEN_HI:0],fb__fsabo_len[FSAB_LEN_HI:0],ic__fsabo_len[FSAB_LEN_HI:0],dc__fsabo_len[FSAB_LEN_HI:0],accel_clear__fsabo_len[FSAB_LEN_HI:0]}), // Templated
				.fsabo_datas	({pre__fsabo_data[FSAB_DATA_HI:0],fb__fsabo_data[FSAB_DATA_HI:0],ic__fsabo_data[FSAB_DATA_HI:0],dc__fsabo_data[FSAB_DATA_HI:0],accel_clear__fsabo_data[FSAB_DATA_HI:0]}), // Templated
				.fsabo_masks	({pre__fsabo_mask[FSAB_MASK_HI:0],fb__fsabo_mask[FSAB_MASK_HI:0],ic__fsabo_mask[FSAB_MASK_HI:0],dc__fsabo_mask[FSAB_MASK_HI:0],accel_clear__fsabo_mask[FSAB_MASK_HI:0]}), // Templated
				.fsabo_clks	(fsabo_clks[FSAB_DEVICES-1:0]),
				.fsabo_rst_bs	(fsabo_rst_bs[FSAB_DEVICES-1:0]),
				.fsabo_credit	(fsabo_credit));
	defparam fsabarbiter.FSAB_DEVICES = 5;
	defparam fsabarbiter.FSAB_DEVICES_HI = 2;

	/* FSABSimMemory AUTO_TEMPLATE (
		.clk(fsabi_clk),
		.rst_b(fsabi_rst_b),
		); */
	FSABSimMemory simmem(
		/*AUTOINST*/
			     // Outputs
			     .fsabo_credit	(fsabo_credit),
			     .fsabi_valid	(fsabi_valid),
			     .fsabi_did		(fsabi_did[FSAB_DID_HI:0]),
			     .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
			     .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]),
			     // Inputs
			     .clk		(fsabi_clk),	 // Templated
			     .rst_b		(fsabi_rst_b),	 // Templated
			     .fsabo_valid	(fsabo_valid),
			     .fsabo_mode	(fsabo_mode[FSAB_REQ_HI:0]),
			     .fsabo_did		(fsabo_did[FSAB_DID_HI:0]),
			     .fsabo_subdid	(fsabo_subdid[FSAB_DID_HI:0]),
			     .fsabo_addr	(fsabo_addr[FSAB_ADDR_HI:0]),
			     .fsabo_len		(fsabo_len[FSAB_LEN_HI:0]),
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

	/* AccelClear AUTO_TEMPLATE (
		.cclk(clk),
		.cclk_rst_b(rst_b),
		); */
	AccelClear accelclear(/*AUTOINST*/
			      // Outputs
			      .accel_clear__fsabo_valid(accel_clear__fsabo_valid),
			      .accel_clear__fsabo_mode(accel_clear__fsabo_mode[FSAB_REQ_HI:0]),
			      .accel_clear__fsabo_did(accel_clear__fsabo_did[FSAB_DID_HI:0]),
			      .accel_clear__fsabo_subdid(accel_clear__fsabo_subdid[FSAB_DID_HI:0]),
			      .accel_clear__fsabo_addr(accel_clear__fsabo_addr[FSAB_ADDR_HI:0]),
			      .accel_clear__fsabo_len(accel_clear__fsabo_len[FSAB_LEN_HI:0]),
			      .accel_clear__fsabo_data(accel_clear__fsabo_data[FSAB_DATA_HI:0]),
			      .accel_clear__fsabo_mask(accel_clear__fsabo_mask[FSAB_MASK_HI:0]),
			      .accel_clear__spami_busy_b(accel_clear__spami_busy_b),
			      .accel_clear__spami_data(accel_clear__spami_data[SPAM_DATA_HI:0]),
			      // Inputs
			      .accel_clear__fsabo_credit(accel_clear__fsabo_credit),
			      .fsabi_clk	(fsabi_clk),
			      .fsabi_rst_b	(fsabi_rst_b),
			      .fsabi_valid	(fsabi_valid),
			      .fsabi_did	(fsabi_did[FSAB_DID_HI:0]),
			      .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
			      .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]),
			      .cclk		(clk),		 // Templated
			      .cclk_rst_b	(rst_b),	 // Templated
			      .spamo_valid	(spamo_valid),
			      .spamo_r_nw	(spamo_r_nw),
			      .spamo_did	(spamo_did[SPAM_DID_HI:0]),
			      .spamo_addr	(spamo_addr[SPAM_ADDR_HI:0]),
			      .spamo_data	(spamo_data[SPAM_DATA_HI:0]));

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
verilog-library-directories:("." "../console" "../core" "../fsab" "../spam" "../fsab/sim" "../util" "../accel")
End:
*/
