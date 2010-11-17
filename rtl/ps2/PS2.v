
module PS2(/*AUTOARG*/
   // Outputs
   ps2__spami_busy_b, ps2__spami_data,
   // Inouts
   control_vio,
   // Inputs
   ps2clk, cclk, cclk_rst_b, ps2data, spamo_valid, spamo_r_nw,
   spamo_did, spamo_addr, spamo_data
   );

	`include "spam_defines.vh"	
	input ps2clk;
	input cclk;
	input cclk_rst_b;
	input ps2data;
	input spamo_valid;
	input spamo_r_nw;
	input [SPAM_DID_HI:0] spamo_did;
	input [SPAM_ADDR_HI:0] spamo_addr;
	input [SPAM_DATA_HI:0] spamo_data;

	output ps2__spami_busy_b;
	output reg [SPAM_DATA_HI:0] ps2__spami_data;

	inout [35:0] control_vio;

	parameter SPAM_ADDRPFX = 24'h000000;
	parameter SPAM_ADDRMASK = 24'h000000;
	parameter DEBUG = "FALSE";

	reg [3:0] bitcount = 0;	
	reg [7:0] key = 0;
	reg parity = 0;
	wire empty;
	wire [7:0] rd_data;


	wire rd_decode_0a = spamo_valid && spamo_r_nw && 
	                    ((spamo_addr & SPAM_ADDRMASK) == SPAM_ADDRPFX) &&
	                    (spamo_did == SPAM_DID_KEYBOARD);
	reg rd_decode_1a;

	reg fifo_rd_en_0a;
	reg fifo_rd_en_1a = 0;
	reg fifo_wr_en;

	reg ps2clk_cclk_negedge = 0;

	reg ps2clk_cclk_s = 0;
	reg ps2clk_cclk = 0;
	reg ps2clk_cclk_1a = 0;

	always @ (posedge cclk or negedge cclk_rst_b) begin
		if (!cclk_rst_b) begin
			ps2clk_cclk_s <= 0;
			ps2clk_cclk <= 0;
		end else begin
			ps2clk_cclk_s <= ps2clk;
			ps2clk_cclk <= ps2clk_cclk_s;
		end
	end 

	always @(posedge cclk or negedge cclk_rst_b) begin
		if (!cclk_rst_b) begin
			bitcount <= 0;
			ps2clk_cclk_negedge <= 0;
			ps2clk_cclk_1a <= 0;
		end else begin
			ps2clk_cclk_negedge <= 0;
			if (ps2clk_cclk_1a == 1 && ps2clk_cclk == 0) begin
				ps2clk_cclk_negedge <= 1;
				if (bitcount == 10) begin
					bitcount <= 0;
				end else begin
					bitcount <= bitcount + 1;
				end
				case(bitcount)
					1: key[0] <= ps2data;
					2: key[1] <= ps2data;
					3: key[2] <= ps2data;
					4: key[3] <= ps2data;
					5: key[4] <= ps2data;
					6: key[5] <= ps2data;
					7: key[6] <= ps2data;
					8: key[7] <= ps2data;
					9: parity <= ps2data;
				endcase
			end
			ps2clk_cclk_1a <= ps2clk_cclk;
		end
	end

	always @(*) begin
		fifo_wr_en = 0;
		fifo_rd_en_0a = 0;
		ps2__spami_data = 0;
		if (bitcount == 10 && ps2clk_cclk_negedge == 1) begin
			if(parity != (^ key)) begin
				fifo_wr_en = 1;
			end
		end
		if (rd_decode_0a && !empty)
			fifo_rd_en_0a = 1;
		if (rd_decode_1a) begin
			if (fifo_rd_en_1a) begin
				ps2__spami_data = {24'h0, rd_data};
			end
			else begin
				ps2__spami_data = 32'hffffffff;
			end
		end 
	end

	always @(posedge cclk or negedge cclk_rst_b) begin
		if (!cclk_rst_b) begin
			rd_decode_1a <= 0;
			fifo_rd_en_1a <= 0;
		end
		else begin
			rd_decode_1a <= rd_decode_0a;
			fifo_rd_en_1a <= fifo_rd_en_0a;
		end
	end 

	Fifo keyfifo(/*NOT AUTOINST*/
		.clk(cclk),
		.rst_b(cclk_rst_b),
		.wr_en(fifo_wr_en),
		.rd_en(fifo_rd_en_0a),
		.wr_dat(key),
		.rd_dat(rd_data),
		.empty(empty),
		.full(),
		.available(),
		.afull(),
		.aempty()
	);
	defparam keyfifo.DEPTH = 24;
	defparam keyfifo.WIDTH = 8;

	assign ps2__spami_busy_b = rd_decode_1a;	


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
			.CLK(cclk),
			.TRIG0({0, rd_decode_0a, empty, rd_decode_1a, fifo_rd_en_0a, fifo_rd_en_1a, ps2__spami_data[31:0], rd_data[7:0], ps2clk_cclk, fifo_wr_en, key[7:0], parity, bitcount[3:0], ps2data})
		);

		chipscope_ila ila1 (
			.CONTROL(control1),
			.CLK(fixedclk),
			.TRIG0({0, ps2data, bitcount[3:0], fifo_wr_en, key[7:0], parity})
		);

		chipscope_ila ila2 (
			.CONTROL(control2),
			.CLK(cclk),
			.TRIG0(256'b0)
		);

	end else begin: debug_tieoff
		assign control_vio = {36{1'bz}};
	end
	endgenerate

endmodule
