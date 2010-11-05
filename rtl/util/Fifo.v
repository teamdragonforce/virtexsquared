module Fifo #(
	parameter DEPTH = 1,
	parameter WIDTH = 1,
	parameter ALMOST = 1
) (/*AUTOARG*/
   // Outputs
   rd_dat, empty, full, available, afull, aempty,
   // Inputs
   clk, rst_b, wr_en, rd_en, wr_dat
   );
`include "clog2.vh"
`define ADDR_WIDTH (clog2(DEPTH)-1)

	input clk;
	input rst_b;
	input wr_en;
	input rd_en;
	input [WIDTH-1:0] wr_dat;
	output reg [WIDTH-1:0] rd_dat;
	output wire empty;
	output wire full;
	output wire [`ADDR_WIDTH:0] available;
	output reg afull = 0;
	output reg aempty = 1;

	reg [WIDTH-1:0] fifo [DEPTH-1:0];
	reg [`ADDR_WIDTH:0] wpos;
	reg [`ADDR_WIDTH:0] rpos;

	always @(posedge clk or negedge rst_b) begin
		if (~rst_b) begin
			wpos <= 'h0;
			rpos <= 'h0;
			afull <= 'h0;
			aempty <= 'h1;
		end else begin
			if (rd_en) begin
				rd_dat <= fifo[rpos[`ADDR_WIDTH-1:0]];
				rpos <= rpos + 'h1;
			end
			if (wr_en) begin
				fifo[wpos[`ADDR_WIDTH-1:0]] <= wr_dat;
				wpos <= wpos + 'h1;
			end
			if ((wpos == rpos + DEPTH - ALMOST - 1) && wr_en && !rd_en) begin
				afull <= 1;
			end
			else if ((wpos == rpos + DEPTH - ALMOST) && !wr_en && rd_en) begin
				afull <= 0;
			end
			else if ((wpos == rpos + ALMOST) && wr_en && !rd_en) begin
				aempty <= 0;
			end
			else if ((wpos == rpos + ALMOST + 1) && !wr_en && rd_en) begin
				aempty <= 1;
			end
		end
	end

	assign empty = (wpos == rpos);
	assign full = (wpos == rpos + DEPTH);
	assign available = wpos - rpos;
endmodule
