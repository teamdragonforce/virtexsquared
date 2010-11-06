module AsyncFifo #(
	parameter DEPTH = 1,
	parameter WIDTH = 1,
	parameter ALMOST = 1
) (/*AUTOARG*/
   // Outputs
   rd_dat, empty, full,
   // Inputs
   iclk, oclk, iclk_rst_b, oclk_rst_b, wr_en, rd_en, wr_dat
   );
`include "clog2.vh"
`define ADDR_WIDTH (clog2(DEPTH)-1)
`define FULL_G_INIT (DEPTH ^ (DEPTH >> 1))

	input iclk;
	input oclk;
	input iclk_rst_b;
	input oclk_rst_b;
	input wr_en;
	input rd_en;
	input [WIDTH-1:0] wr_dat;
	output reg [WIDTH-1:0] rd_dat;
	output wire empty;
	output wire full;

	reg [WIDTH-1:0] fifo [DEPTH-1:0];

	reg [`ADDR_WIDTH:0] wpos_iclk = 0;
	wire [`ADDR_WIDTH:0] wpos_iclk_next = wr_en ? (wpos_iclk + 1) : wpos_iclk;
	reg [`ADDR_WIDTH:0] rpos_oclk = 0;
	wire [`ADDR_WIDTH:0] rpos_oclk_next = rd_en ? (rpos_oclk + 1) : rpos_oclk;

	reg [`ADDR_WIDTH:0] wpos_empty_g_iclk = 0;
	reg [`ADDR_WIDTH:0] wpos_empty_g_oclk_1 = 0;
	reg [`ADDR_WIDTH:0] wpos_empty_g_oclk_2 = 0;
	wire [`ADDR_WIDTH:0] rpos_empty_g_oclk = rpos_oclk ^ (rpos_oclk >> 1);

	/* verilator lint_off WIDTH */
	wire [`ADDR_WIDTH:0] rpos_full_oclk = rpos_oclk_next + DEPTH;
	reg [`ADDR_WIDTH:0] rpos_full_g_oclk = `FULL_G_INIT;
	reg [`ADDR_WIDTH:0] rpos_full_g_iclk_1 = `FULL_G_INIT;
	reg [`ADDR_WIDTH:0] rpos_full_g_iclk_2 = `FULL_G_INIT;
	/* verilator lint_on WIDTH */
	wire [`ADDR_WIDTH:0] wpos_full_g_iclk = wpos_iclk ^ (wpos_iclk >> 1);

	/* There is no issue here with empty showing up too late, because
	 * only the write pointer is delayed; the read pointer remains
	 * synchronous with the read operation.  So, 'empty' might return
	 * empty for too long, but never for too short.
	 */
	assign empty = (rpos_empty_g_oclk == wpos_empty_g_oclk_2);
	/* Same deal the other way around for full. */
	assign full = (rpos_full_g_iclk_2 == wpos_full_g_iclk);

	always @(posedge iclk or negedge iclk_rst_b) begin
		if (~iclk_rst_b) begin
			wpos_iclk <= 0;
			wpos_empty_g_iclk <= 0;
			/* verilator lint_off WIDTH */
			rpos_full_g_iclk_1 <= `FULL_G_INIT;
			rpos_full_g_iclk_2 <= `FULL_G_INIT;
			/* verilator lint_on WIDTH */
		end else begin
			if (wr_en) begin
				fifo[wpos_iclk[`ADDR_WIDTH-1:0]] <= wr_dat;
			end
			wpos_iclk <= wpos_iclk_next;
			wpos_empty_g_iclk <= wpos_iclk_next ^ (wpos_iclk_next >> 1);
			rpos_full_g_iclk_1 <= rpos_full_g_oclk;
			rpos_full_g_iclk_2 <= rpos_full_g_iclk_1;
		end
	end
	always @(posedge oclk or negedge oclk_rst_b) begin
		if (~oclk_rst_b) begin
			rpos_oclk <= 0;
			/* verilator lint_off WIDTH */
			rpos_full_g_oclk <= `FULL_G_INIT;
			/* verilator lint_on WIDTH */
			wpos_empty_g_oclk_1 <= 0;
			wpos_empty_g_oclk_2 <= 0;
		end else begin
			if (rd_en) begin
				rd_dat <= fifo[rpos_oclk[`ADDR_WIDTH-1:0]];
			end
			rpos_oclk <= rpos_oclk_next;
			rpos_full_g_oclk <= rpos_full_oclk ^ (rpos_full_oclk >> 1);
			wpos_empty_g_oclk_1 <= wpos_empty_g_iclk;
			wpos_empty_g_oclk_2 <= wpos_empty_g_oclk_1;
		end
	end
endmodule
