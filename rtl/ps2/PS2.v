
module PS2(/*AUTOARG*/
   // Outputs
   ps2__spami_busy_b, ps2__spami_data,
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

	parameter SPAM_ADDRPFX = 24'h000000;
	parameter SPAM_ADDRMASK = 24'h000000;

	reg [3:0] bitcount = 0;	
	reg [7:0] key = 0;
	reg parity = 0;
	wire empty;
	wire [7:0] rd_data;

	/* Clock debouncing */
	reg lastinclk = 0;
	reg [6:0] debounce = 0;
	reg fixedclk = 0;
	reg [11:0] resetcountdown = 0;
	
	reg nd = 0;
	reg lastnd = 0;
	
	always @(posedge cclk) begin
		if (ps2clk != lastinclk) begin
			lastinclk <= ps2clk;
			debounce <= 1;
			resetcountdown <= 12'b111111111111;
		end else if (debounce == 0) begin
			fixedclk <= ps2clk;
			resetcountdown <= resetcountdown - 1;
		end else
			debounce <= debounce + 1;
		
		if (nd ^ lastnd) begin
			lastnd <= nd;
		end
	end

	wire rd_decode_0a = spamo_valid && spamo_r_nw && 
	                    ((spamo_addr & SPAM_ADDRMASK) == SPAM_ADDRPFX) &&
	                    (spamo_did == SPAM_DID_KEYBOARD);
	reg rd_decode_1a;

	reg fifo_rd_en_0a;
	reg fifo_rd_en_1a = 0;
	reg fifo_wr_en;

	always @(*) begin
		fifo_wr_en = 0;
		fifo_rd_en_0a = 0;
		ps2__spami_data = 0;
		if (bitcount == 10) begin
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
				ps2__spami_data = 32'hdeadbeef;
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

	always @(negedge fixedclk) begin
		if (resetcountdown == 0)
			bitcount <= 0;
		else if (bitcount == 10) begin
			bitcount <= 0;
		end else
			bitcount <= bitcount + 1;

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

	AsyncFifo keyfifo(/*NOT AUTOINST*/
		.iclk(~fixedclk),
		.oclk(cclk),
		.iclk_rst_b(1'b1),
		.oclk_rst_b(cclk_rst_b),
		.wr_en(fifo_wr_en),
		.rd_en(fifo_rd_en_0a),
		.wr_dat(key),
		.rd_dat(rd_data),
		.empty(empty),
		.full()
	);
	defparam keyfifo.DEPTH = 24;
	defparam keyfifo.WIDTH = 8;

	assign ps2__spami_busy_b = rd_decode_1a;	

endmodule
