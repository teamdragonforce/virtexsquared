module MulDivDCM(input xtal, output clk, output clk90);
	parameter div = 8;
	parameter mul = 2;
	
	wire CLKFX_BUF;
	wire CLK0_BUF;
	wire CLK90_BUF;
	wire clkfx;
	wire GND_BIT = 0;
	BUFG CLK0_BUFG_INST (.I(CLK0_BUF),
				.O(clk));
	BUFG CLK90_BUFG_INST (.I(CLK90_BUF),
				.O(clk90));
	BUFG CLKFX_BUFG_INST (.I(CLKFX_BUF),
				.O(clkfx));
	
	DCM_BASE DCM_INST2(.CLKFB(clk), 
			.CLKIN(clkfx),
			.RST(GND_BIT),
			.CLK0(CLK0_BUF),
			.CLK90(CLK90_BUF));
	
	DCM_BASE DCM_INST (.CLKFB(GND_BIT), 
			.CLKIN(xtal), 
			.RST(GND_BIT),
			.CLKFX(CLKFX_BUF));
	defparam DCM_INST.CLK_FEEDBACK = "NONE";
	defparam DCM_INST.CLKDV_DIVIDE = 2.0;
	defparam DCM_INST.CLKFX_DIVIDE = div;
	defparam DCM_INST.CLKFX_MULTIPLY = mul;
	defparam DCM_INST.CLKIN_DIVIDE_BY_2 = "FALSE";
	defparam DCM_INST.CLKIN_PERIOD = 10.000;
	defparam DCM_INST.CLKOUT_PHASE_SHIFT = "NONE";
	defparam DCM_INST.DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS";
	defparam DCM_INST.DFS_FREQUENCY_MODE = "LOW";
	defparam DCM_INST.DLL_FREQUENCY_MODE = "LOW";
	defparam DCM_INST.DUTY_CYCLE_CORRECTION = "TRUE";
	defparam DCM_INST.FACTORY_JF = 16'hC080;
	defparam DCM_INST.PHASE_SHIFT = 0;
	defparam DCM_INST.STARTUP_WAIT = "TRUE";
endmodule

`include "iic_init.v"

module Console(
	input xtal,
	input rst,
	output wire rstact,
	output wire dvi_vs, dvi_hs,
	output wire [11:0] dvi_d,
	output wire dvi_xclk_p, dvi_xclk_n,
	output wire dvi_de,
	output wire dvi_reset_b,
	inout wire dvi_sda,
	inout wire dvi_scl,
	input ps2c, ps2d);
	
	assign dvi_reset_b = 1'b1;
	
	wire pixclk, pixclk_90, coreclk, coreclk_90;

	wire [11:0] x, y;
	wire border;

	MulDivDCM dcm31_25(xtal, pixclk, pixclk_90);
	defparam dcm31_25.div = 16;
	defparam dcm31_25.mul = 5;
	
	MulDivDCM dcmcore(xtal, coreclk, coreclk_90);	/* 50MHz */
	defparam dcmcore.div = 4;
	defparam dcmcore.mul = 2;
	
	wire vs, hs;
	SyncGen sync(pixclk, vs, hs, x, y, border);
	
	wire [7:0] cschar;
	wire [2:0] csrow;
	wire [7:0] csdata;
	
	wire [10:0] vraddr;
	wire [7:0] vrdata;
	
	wire [10:0] vwaddr;
	wire [7:0] vwdata;
	wire [7:0] serdata;
	wire vwr, serwr;
	wire [10:0] vscroll;
	
	wire odata;
	
	wire [6:0] vcursx;
	wire [4:0] vcursy;
	
	reg [16:0] rsttimer = 17'h3FFFF;
	always @(posedge coreclk)
		if (~rst)
			rsttimer <= 17'h3FFFF;
		else if (rsttimer)
			rsttimer <= rsttimer - 1;
	assign rstact = rsttimer != 17'h0;
	
	wire tookdata;
	reg ps2_hasd = 0;
	reg [7:0] ps2_d = 0;
	wire sertxwr;
	wire [7:0] sertxdata;
	
	CharSet cs(cschar, csrow, csdata);
	VideoRAM vram(pixclk, vraddr + vscroll, vrdata, coreclk, vwaddr, vwdata, vwr);
	VDisplay dpy(pixclk, x, y, vraddr, vrdata, cschar, csrow, csdata, vcursx, vcursy, odata);
	RXState rxsm(coreclk, vwr, vwaddr, vwdata, vscroll, vcursx, vcursy, serwr, serdata);
	PS2 ps2(coreclk, ps2c, ps2d, sertxwr, sertxdata);
	System sys(.clk(coreclk), .rst(rstact), .sys_odata({serwr, serdata}), .sys_idata({ps2_hasd, ps2_d}), .sys_tookdata(tookdata));
	
	always @(posedge coreclk)
		if (sertxwr)
			{ps2_hasd, ps2_d} <= {1'b1, sertxdata};
		else if (tookdata)
			{ps2_hasd, ps2_d} <= {1'b0, 8'hxxxxxxxx};
	
	/* FUCK! ASS! BALLS! EAT MY SHORT DICK! FUCKING XST */
	/* EMSD stands for Eat My Short Dick.  Because XST should. */
`define MAKE_DDR(n,q,d1,d2) ODDR n (.C(pixclk), .Q(q), .D1(d1), .D2(d2), .R(0), .S(0), .CE(1))
`define MAKE_DDR90(n,q,d1,d2) ODDR n (.C(pixclk_90), .Q(q), .D1(d1), .D2(d2), .R(0), .S(0), .CE(1))
	
	wire [7:0] red, green, blue;
	assign red   = (odata ? 8'hFF : 0) | (x[8:2] ^ y[7:1]);
	assign green = (odata ? 8'hFF : 0) | (x[7:1] ^ y[8:2]);
	assign blue  = (odata ? 8'hFF : 0) | (x[8:2] ^ y[8:2]);
	
	`MAKE_DDR90(EMSD_dvi_xclk_p, dvi_xclk_p, 1'b1, 1'b0);
	`MAKE_DDR90(EMSD_dvi_xclk_n, dvi_xclk_n, 1'b0, 1'b1);
	`MAKE_DDR(EMSD_dvi_de, dvi_de, ~border, ~border);
	`MAKE_DDR(EMSD_dvi_vs, dvi_vs, vs, vs);
	`MAKE_DDR(EMSD_dvi_hs, dvi_hs, hs, hs);
	`MAKE_DDR(EMSD_dvi_d_0, dvi_d[0], blue[0], green[4]);
	`MAKE_DDR(EMSD_dvi_d_1, dvi_d[1], blue[1], green[5]);
	`MAKE_DDR(EMSD_dvi_d_2, dvi_d[2], blue[2], green[6]);
	`MAKE_DDR(EMSD_dvi_d_3, dvi_d[3], blue[3], green[7]);
	`MAKE_DDR(EMSD_dvi_d_4, dvi_d[4], blue[4], red[0]);
	`MAKE_DDR(EMSD_dvi_d_5, dvi_d[5], blue[5], red[1]);
	`MAKE_DDR(EMSD_dvi_d_6, dvi_d[6], blue[6], red[2]);
	`MAKE_DDR(EMSD_dvi_d_7, dvi_d[7], blue[7], red[3]);
	`MAKE_DDR(EMSD_dvi_d_8, dvi_d[8], green[0], red[4]);
	`MAKE_DDR(EMSD_dvi_d_9, dvi_d[9], green[1], red[5]);
	`MAKE_DDR(EMSD_dvi_d_10, dvi_d[10], green[2], red[6]);
	`MAKE_DDR(EMSD_dvi_d_11, dvi_d[11], green[3], red[7]);
	
	wire wee;
	iic_init #(.CLK_RATE_MHZ(31)) init (pixclk, 1'b1, 1'b0, dvi_sda, dvi_scl, wee);

endmodule

module SyncGen(
	input pixclk,
	output reg vs, hs,
	output reg [11:0] x, y,
	output reg border);
	
	parameter XRES = 640;
	parameter XFPORCH = 24;
	parameter XSYNC = 40;
	parameter XBPORCH = 128;
	
	parameter YRES = 480;
	parameter YFPORCH = 9;
	parameter YSYNC = 3;
	parameter YBPORCH = 28;
	
	always @(posedge pixclk)
	begin
		if (x >= (XRES + XFPORCH + XSYNC + XBPORCH))
		begin
			if (y >= (YRES + YFPORCH + YSYNC + YBPORCH))
				y = 0;
			else
				y = y + 1;
			x = 0;
		end else
			x = x + 1;
		hs <= (x >= (XRES + XFPORCH)) && (x < (XRES + XFPORCH + XSYNC));
		vs <= (y >= (YRES + YFPORCH)) && (y < (YRES + YFPORCH + YSYNC));
		border <= (x > XRES) || (y > YRES);
	end
endmodule

module CharSet(
	input [7:0] char,
	input [2:0] row,
	output wire [7:0] data);

	reg [7:0] rom [(256 * 8 - 1):0];
	
	initial
		$readmemb("ibmpc1.mem", rom);

	assign data = rom[{char, row}];
endmodule

module VideoRAM(
	input pixclk,
	input [10:0] raddr,
	output reg [7:0] rdata,
	input wclk,
	input [10:0] waddr,
	input [7:0] wdata,
	input wr);
	
	reg [7:0] ram [2047 : 0];
	
	always @(posedge pixclk)
		rdata <= ram[raddr];
	
	always @(posedge wclk)
		if (wr)
			ram[waddr] <= wdata;
endmodule

module VDisplay(
	input pixclk,
	input [11:0] x,
	input [11:0] y,
	output wire [10:0] raddr,
	input [7:0] rchar,
	output wire [7:0] cschar,
	output wire [2:0] csrow,
	input [7:0] csdata,
	input [6:0] cursx,
	input [4:0] cursy,
	output reg data);

	wire [7:0] col = x[11:3];
	wire [5:0] row = y[10:4];
	reg [7:0] ch;
	reg [11:0] xdly;

	assign raddr = ({row,4'b0} + {row,6'b0} + {4'h0,col});
	assign cschar = rchar;
	assign csrow = y[3:1];
	
	reg [23:0] blinktime = 0;
	
	always @(posedge pixclk) blinktime <= blinktime + 1;
	
	wire curssel = (cursx == col) && (cursy == row) && blinktime[23];
	
	always @(posedge pixclk)
		xdly <= x;
	
	always @(posedge pixclk)
		data = ((xdly < 80 * 8) && (y < 25 * 16)) ? (csdata[7 - xdly[2:0]] ^ curssel) : 0;
endmodule

module RXState(
	input clk25,
	output reg vwr = 0,
	output reg [10:0] vwaddr = 0,
	output reg [7:0] vwdata = 0,
	output reg [10:0] vscroll = 0,
	output wire [6:0] vcursx,
	output wire [4:0] vcursy,
	input serwr,
	input [7:0] serdata);

	parameter STATE_IDLE = 4'b0000;
	parameter STATE_NEWLINE = 4'b0001;
	parameter STATE_CLEAR = 4'b0010;

	reg [3:0] state = STATE_CLEAR;
	
	reg [6:0] x = 0;
	reg [4:0] y = 0;
	
	assign vcursx = x;
	assign vcursy = y;
	
	reg [10:0] clearstart = 0;
	reg [10:0] clearend = 11'b11111111111;
	
	always @(posedge clk25)
		case (state)
		STATE_IDLE:	if (serwr) begin
					if (serdata == 8'h0A) begin
						state <= STATE_NEWLINE;
						x <= 0;
						vwr <= 0;
					end else if (serdata == 8'h0D) begin
						x <= 0;
						vwr <= 0;
					end else if (serdata == 8'h0C) begin
						clearstart <= 0;
						clearend <= 11'b11111111111;
						x <= 0;
						y <= 0;
						vscroll <= 0;
						state <= STATE_CLEAR;
					end else if (serdata == 8'h08) begin
						if (x != 0)
							x <= x - 1;
						vwr <= 0;
					end else begin
						vwr <= 1;
						vwaddr <= ({y,4'b0} + {y,6'b0} + {4'h0,x}) + vscroll;
						vwdata <= serdata;
						if (x == 79) begin
							x <= 0;
							state <= STATE_NEWLINE;
						end else 
							x <= x + 1;
					end
				end
		STATE_NEWLINE:
			begin
				vwr <= 0;
				if (y == 24) begin
					vscroll <= vscroll + 80;
					clearstart <= (25 * 80) + vscroll;
					clearend <= (26*80) + vscroll;
					state <= STATE_CLEAR;
				end else begin
					y <= y + 1;
					state <= STATE_IDLE;
				end
			end
		STATE_CLEAR:
			begin
				vwr <= 1;
				vwaddr <= clearstart;
				vwdata <= 8'h20;
				clearstart <= clearstart + 1;
				if (clearstart == clearend)
					state <= STATE_IDLE;
			end
		endcase
endmodule

module PS2(
	input pixclk,
	input inclk,
	input indata,
	output reg wr,
	output reg [7:0] data
	);

	reg [3:0] bitcount = 0;
	reg [7:0] key = 0;
	reg keyarrow = 0, keyup = 0, parity = 0;

	
	/* Clock debouncing */
	reg lastinclk = 0;
	reg [6:0] debounce = 0;
	reg fixedclk = 0;
	reg [11:0] resetcountdown = 0;
	
	reg [6:0] unshiftedrom [127:0];	initial $readmemh("scancodes.unshifted.hex", unshiftedrom);
	reg [6:0] shiftedrom [127:0];	initial $readmemh("scancodes.shifted.hex", shiftedrom);
	
	reg mod_lshift = 0;
	reg mod_rshift = 0;
	reg mod_capslock = 0;
	wire mod_shifted = (mod_lshift | mod_rshift) ^ mod_capslock;
	
	reg nd = 0;
	reg lastnd = 0;
	
	always @(posedge pixclk) begin
		if (inclk != lastinclk) begin
			lastinclk <= inclk;
			debounce <= 1;
			resetcountdown <= 12'b111111111111;
		end else if (debounce == 0) begin
			fixedclk <= inclk;
			resetcountdown <= resetcountdown - 1;
		end else
			debounce <= debounce + 1;
		
		if (nd ^ lastnd) begin
			lastnd <= nd;
			wr <= 1;
		end else
			wr <= 0;
	end

	always @(negedge fixedclk) begin
		if (resetcountdown == 0)
			bitcount <= 0;
		else if (bitcount == 10) begin
			bitcount <= 0;
			if(parity != (^ key)) begin
				if(keyarrow) begin
					casex(key)
						8'hF0: keyup <= 1;
						8'hxx: keyarrow <= 0;
					endcase
				end
				else begin
					if(keyup) begin
						keyup <= 0;
						keyarrow <= 0;
						casex (key)
						8'h12: mod_lshift <= 0;
						8'h59: mod_rshift <= 0;
						endcase
						// handle this? I don't fucking know
					end
					else begin
						casex(key)
							8'hE0: keyarrow <= 1;	// handle these? I don't fucking know
							8'hF0: keyup <= 1;
							8'h12: mod_lshift <= 1;
							8'h59: mod_rshift <= 1;
							8'h14: mod_capslock <= ~mod_capslock;
							8'b0xxxxxxx: begin nd <= ~nd; data <= mod_shifted ? shiftedrom[key] : unshiftedrom[key]; end
							8'b1xxxxxxx: begin /* AAAAAAASSSSSSSS */ end
						endcase
					end
				end
			end
			else begin
				keyarrow <= 0;
				keyup <= 0;
			end
		end else
			bitcount <= bitcount + 1;

		case(bitcount)
			1: key[0] <= indata;
			2: key[1] <= indata;
			3: key[2] <= indata;
			4: key[3] <= indata;
			5: key[4] <= indata;
			6: key[5] <= indata;
			7: key[6] <= indata;
			8: key[7] <= indata;
			9: parity <= indata;
		endcase
	end

endmodule
