module Framebuffer(/*AUTOARG*/
   // Outputs
   dvi_vs, dvi_hs, dvi_d, dvi_xclk_p, dvi_xclk_n, dvi_de, dvi_reset_b,
   // Inouts
   dvi_sda, dvi_scl,
   // Inputs
   fbclk, fbclk_rst_b
   );

	input fbclk;
	input fbclk_rst_b;
	
	output wire dvi_vs, dvi_hs;
	output wire [11:0] dvi_d;
	output wire dvi_xclk_p, dvi_xclk_n;
	output wire dvi_de;
	output wire dvi_reset_b;
	inout wire dvi_sda;
	inout wire dvi_scl;

	assign dvi_reset_b = 1'b1;
	
	wire [11:0] x, y;
	wire border;
	
	wire vs, hs;
	SyncGen sync(/*AUTOINST*/
		     // Outputs
		     .vs		(vs),
		     .hs		(hs),
		     .x			(x[11:0]),
		     .y			(y[11:0]),
		     .border		(border),
		     // Inputs
		     .fbclk		(fbclk));
	
`define MAKE_DDR(n,q,d1,d2) ODDR n (.C(fbclk), .Q(q), .D1(d1), .D2(d2), .R(0), .S(0), .CE(1))
	
	wire [7:0] red, green, blue;
	assign red   = (x[8:2] ^ y[7:1]);
	assign green = (x[7:1] ^ y[8:2]);
	assign blue  = (x[8:2] ^ y[8:2]);
	
	`MAKE_DDR(ODDR_dvi_xclk_p, dvi_xclk_p, 1'b1, 1'b0);
	`MAKE_DDR(ODDR_dvi_xclk_n, dvi_xclk_n, 1'b0, 1'b1);
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
	
	wire wee;
	/* iic_init AUTO_TEMPLATE(
	  	.Clk(pixclk),
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
		       .Clk		(pixclk),		 // Templated
		       .Reset_n		(1'b1),			 // Templated
		       .Pixel_clk_greater_than_65Mhz(1'b0));	 // Templated
endmodule
