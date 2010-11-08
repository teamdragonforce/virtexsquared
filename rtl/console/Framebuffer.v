module Framebuffer(/*AUTOARG*/
   // Outputs
   dvi_vs, dvi_hs, dvi_d, dvi_xclk_p, dvi_xclk_n, dvi_de, dvi_reset_b,
   fb__fsabo_valid, fb__fsabo_mode, fb__fsabo_did, fb__fsabo_subdid,
   fb__fsabo_addr, fb__fsabo_len, fb__fsabo_data, fb__fsabo_mask,
   fb__spami_busy_b, fb__spami_data,
   // Inouts
   dvi_sda, dvi_scl, control_vio,
   // Inputs
   fbclk, fbclk_rst_b, cclk, cclk_rst_b, fsabi_clk, fsabi_rst_b,
   fsabi_valid, fsabi_did, fsabi_subdid, fsabi_data, fb__fsabo_credit,
   spamo_valid, spamo_r_nw, spamo_did, spamo_addr, spamo_data
   );

	`include "fsab_defines.vh"
	`include "spam_defines.vh"

	input fbclk;
	input fbclk_rst_b;
	
	output wire dvi_vs, dvi_hs;
	output wire [11:0] dvi_d;
	output wire dvi_xclk_p, dvi_xclk_n;
	output wire dvi_de;
	output wire dvi_reset_b;
	inout wire dvi_sda;
	inout wire dvi_scl;

	input cclk;
	input cclk_rst_b;
	
	input fsabi_clk;
	input fsabi_rst_b;
	input fsabi_valid;
	input [FSAB_DID_HI:0] fsabi_did;
	input [FSAB_DID_HI:0] fsabi_subdid;
	input [FSAB_DATA_HI:0] fsabi_data;

	output fb__fsabo_valid;
	output [FSAB_REQ_HI:0] fb__fsabo_mode;
	output [FSAB_DID_HI:0] fb__fsabo_did;
	output [FSAB_DID_HI:0] fb__fsabo_subdid;
	output [FSAB_ADDR_HI:0] fb__fsabo_addr;
	output [FSAB_LEN_HI:0] fb__fsabo_len;
	output [FSAB_DATA_HI:0] fb__fsabo_data;
	output [FSAB_MASK_HI:0] fb__fsabo_mask;
	input fb__fsabo_credit;

	input spamo_valid;
	input spamo_r_nw;
	input [SPAM_DID_HI:0] spamo_did;
	input [SPAM_ADDR_HI:0] spamo_addr;
	input [SPAM_DATA_HI:0] spamo_data;

	output fb__spami_busy_b;
	output [SPAM_DATA_HI:0] fb__spami_data;

	inout [35:0] control_vio;

	parameter DEBUG = "FALSE";

	assign dvi_reset_b = 1'b1;

	/*AUTOWIRE*/
	// Beginning of automatic wires (for undeclared instantiated-module outputs)
	wire [63:0]	data;			// From frame_dma of SimpleDMAReadController.v
	wire		data_ready;		// From frame_dma of SimpleDMAReadController.v
	wire		fifo_empty_0a;		// From frame_dma of SimpleDMAReadController.v
	wire		iic_done;		// From init of iic_init.v
	// End of automatics
	
	wire [11:0] x, y;
	wire border;

	wire vs, hs;

	reg fifo_empty_1a = 1;

	/* SyncGen AUTO_TEMPLATE (
		.rst_b(~fifo_empty_1a),
		);
	*/
	SyncGen sync(/*AUTOINST*/
		     // Outputs
		     .vs		(vs),
		     .hs		(hs),
		     .x			(x[11:0]),
		     .y			(y[11:0]),
		     .border		(border),
		     // Inputs
		     .fbclk		(fbclk),
		     .rst_b		(~fifo_empty_1a));	 // Templated

	reg offset = 0; /* 0 if reading the first half of the 8 bytes for colors
	                   1 if reading the second half of the 8 bytes for colors */
	reg next_offset = 0;

	reg request = 0;



`define MAKE_DDR(n,q,d1,d2) ODDR n (.C(fbclk), .Q(q), .D1(d1), .D2(d2), .R(0), .S(0), .CE(1))
	
	wire [7:0] red, green, blue;

	wire first_pixel = (offset == 0);
	wire second_pixel = (offset == 1);	

	assign red   = (border) ? 8'h00 : (second_pixel) ? data[63:56] : (first_pixel) ? data[31:24] : 8'hff;
	assign green = (border) ? 8'h00 : (second_pixel) ? data[55:48] : (first_pixel) ? data[23:16] : 8'h00;
	assign blue  = (border) ? 8'hff : (second_pixel) ? data[47:40] : (first_pixel) ? data[15:8] : 8'h00;


`ifdef verilator
	always @ (posedge fbclk) begin
		$display("Framebuffer: Read %x for x: %x, y: %x data_ready: %x, border: %x, request: %x, offset: %x", data, x, y, data_ready, border, request, offset);
	end
`endif
	
`ifdef verilator
	assign dvi_xclk_p = 0;
	assign dvi_xclk_n = 0;
	assign dvi_de = 0;
	assign dvi_vs = 0;
	assign dvi_hs = 0;
	assign dvi_d = 0;
`else
	`MAKE_DDR(ODDR_dvi_xclk_p, dvi_xclk_p, 1'b0, 1'b1);
	`MAKE_DDR(ODDR_dvi_xclk_n, dvi_xclk_n, 1'b1, 1'b0);
	`MAKE_DDR(ODDR_dvi_de, dvi_de, ~border, ~border);
	`MAKE_DDR(ODDR_dvi_vs, dvi_vs, vs, vs);
	`MAKE_DDR(ODDR_dvi_hs, dvi_hs, hs, hs);
	`MAKE_DDR(ODDR_dvi_d_0, dvi_d[0], blue[0], green[4]);
	`MAKE_DDR(ODDR_dvi_d_1, dvi_d[1], blue[1], green[5]);
	`MAKE_DDR(ODDR_dvi_d_2, dvi_d[2], blue[2], green[6]);
	`MAKE_DDR(ODDR_dvi_d_3, dvi_d[3], blue[3], green[7]);
	`MAKE_DDR(ODDR_dvi_d_4, dvi_d[4], blue[4], red[0]);
	`MAKE_DDR(ODDR_dvi_d_5, dvi_d[5], blue[5], red[1]);
	`MAKE_DDR(ODDR_dvi_d_6, dvi_d[6], blue[6], red[2]);
	`MAKE_DDR(ODDR_dvi_d_7, dvi_d[7], blue[7], red[3]);
	`MAKE_DDR(ODDR_dvi_d_8, dvi_d[8], green[0], red[4]);
	`MAKE_DDR(ODDR_dvi_d_9, dvi_d[9], green[1], red[5]);
	`MAKE_DDR(ODDR_dvi_d_10, dvi_d[10], green[2], red[6]);
	`MAKE_DDR(ODDR_dvi_d_11, dvi_d[11], green[3], red[7]);
`endif

	/* SimpleDMAReadController AUTO_TEMPLATE(
	                        .target_clk(fbclk),
	                        .target_rst_b(fbclk_rst_b),
	                        .dmac__fsabo_valid(fb__fsabo_valid),
	                        .dmac__fsabo_mode(fb__fsabo_mode),
	                        .dmac__fsabo_did(fb__fsabo_did),
	                        .dmac__fsabo_subdid(fb__fsabo_subdid),
	                        .dmac__fsabo_addr(fb__fsabo_addr),
	                        .dmac__fsabo_len(fb__fsabo_len),
	                        .dmac__fsabo_data(fb__fsabo_data),
	                        .dmac__fsabo_mask(fb__fsabo_mask),
	                        .dmac__spami_busy_b(fb__spami_busy_b),
				.dmac__spami_data(fb__spami_data),
	                        .dmac__fsabo_credit(fb__fsabo_credit),
	                        .fifo_empty(fifo_empty_0a),
                                );
         */	
	SimpleDMAReadController frame_dma(/*AUTOINST*/
					  // Outputs
					  .dmac__fsabo_valid	(fb__fsabo_valid), // Templated
					  .dmac__fsabo_mode	(fb__fsabo_mode), // Templated
					  .dmac__fsabo_did	(fb__fsabo_did), // Templated
					  .dmac__fsabo_subdid	(fb__fsabo_subdid), // Templated
					  .dmac__fsabo_addr	(fb__fsabo_addr), // Templated
					  .dmac__fsabo_len	(fb__fsabo_len), // Templated
					  .dmac__fsabo_data	(fb__fsabo_data), // Templated
					  .dmac__fsabo_mask	(fb__fsabo_mask), // Templated
					  .data			(data[63:0]),
					  .data_ready		(data_ready),
					  .fifo_empty		(fifo_empty_0a), // Templated
					  .dmac__spami_busy_b	(fb__spami_busy_b), // Templated
					  .dmac__spami_data	(fb__spami_data), // Templated
					  // Inputs
					  .cclk			(cclk),
					  .cclk_rst_b		(cclk_rst_b),
					  .dmac__fsabo_credit	(fb__fsabo_credit), // Templated
					  .fsabi_clk		(fsabi_clk),
					  .fsabi_rst_b		(fsabi_rst_b),
					  .fsabi_valid		(fsabi_valid),
					  .fsabi_did		(fsabi_did[FSAB_DID_HI:0]),
					  .fsabi_subdid		(fsabi_subdid[FSAB_DID_HI:0]),
					  .fsabi_data		(fsabi_data[FSAB_DATA_HI:0]),
					  .spamo_valid		(spamo_valid),
					  .spamo_r_nw		(spamo_r_nw),
					  .spamo_did		(spamo_did[SPAM_DID_HI:0]),
					  .spamo_addr		(spamo_addr[SPAM_ADDR_HI:0]),
					  .spamo_data		(spamo_data[SPAM_DATA_HI:0]),
					  .target_clk		(fbclk),	 // Templated
					  .target_rst_b		(fbclk_rst_b),	 // Templated
					  .request		(request));
	defparam frame_dma.FIFO_DEPTH = 512;
	defparam frame_dma.FSAB_DID = FSAB_DID_FRAME;
	defparam frame_dma.FSAB_SUBDID = FSAB_SUBDID_FRAME_0;
	defparam frame_dma.DEFAULT_ADDR = 31'h00000000;
	defparam frame_dma.DEFAULT_LEN = 31'h0012c000; /* 640*480*4 in hex */
	defparam frame_dma.SPAM_DID = SPAM_DID_FRAMEBUFFER;

	wire wee;
	/* iic_init AUTO_TEMPLATE(
	  	.Clk(fbclk),
	  	.Reset_n(1'b1),
	  	.Pixel_clk_greater_than_65Mhz(1'b0),
	  	.SDA(dvi_sda),
	  	.SCL(dvi_scl),
	  	.Done(iic_done),
	  	);
	*/
	iic_init #(.CLK_RATE_MHZ(25))
	         init (/*AUTOINST*/
		       // Outputs
		       .Done		(iic_done),		 // Templated
		       // Inouts
		       .SDA		(dvi_sda),		 // Templated
		       .SCL		(dvi_scl),		 // Templated
		       // Inputs
		       .Clk		(fbclk),		 // Templated
		       .Reset_n		(1'b1),			 // Templated
		       .Pixel_clk_greater_than_65Mhz(1'b0));	 // Templated

	always @(*) begin
		if (offset == 1) begin
			next_offset = 0;
			request = 1;
		end
		else begin
			request = 0;
			next_offset = 1;
		end
		if (border) begin
			request = 0;
			next_offset = offset;
		end	
	end

	always @ (posedge fbclk or negedge fbclk_rst_b) begin
		if (!fbclk_rst_b) begin
			offset <= 0;
			fifo_empty_1a <= 1;
		end
		else begin
			offset <= next_offset;
			fifo_empty_1a <= fifo_empty_0a;
		end
	end


	generate
	if (DEBUG == "TRUE") begin: debug
		wire [35:0] control0, control1, control2;
		chipscope_icon icon (
			.CONTROL0(control0), 
			.CONTROL1(control1),
			.CONTROL2(control2),
			.CONTROL3(control_vio)
		);

		chipscope_ila ila0 (
			.CONTROL(control0),	
			.CLK(fbclk), // IN
			.TRIG0({0, request, offset, fbclk_rst_b, next_offset, border, data_ready, data[63:0], red[7:0], green[7:0], blue[7:0], x[11:0], y[11:0], vs, hs})
		);

		chipscope_ila ila1 (
			.CONTROL(control1),	
			.CLK(cclk), // IN
			.TRIG0({0, spamo_valid, spamo_r_nw, spamo_did[SPAM_DID_HI:0], spamo_addr[SPAM_ADDR_HI:0], spamo_data[SPAM_DATA_HI:0]})
		);

		chipscope_ila ila2 (
			.CONTROL(control2),	
			.CLK(fbclk), // IN
			.TRIG0(256'b0)
		);

	end else begin: debug_tieoff
		assign control_vio = {36{1'bz}};
	end
	endgenerate

endmodule

// Local Variables:
// verilog-library-directories:("." "../core" "../fsab" "../spam" "../fsab/sim" "../util")
// End:

