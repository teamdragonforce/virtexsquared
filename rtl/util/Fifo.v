module Fifo #(
	parameter DEPTH = 1,
	parameter WIDTH = 1
) (/*AUTOARG*/
   // Outputs
   rd_dat, empty, full, available,
   // Inputs
   clk, rst_b, wr_en, rd_en, wr_dat
   );
`define ADDR_WIDTH (clog2(DEPTH)+1)

	input clk;
	input rst_b;
	input wr_en;
	input rd_en;
	input [WIDTH-1:0] wr_dat;
	output reg [WIDTH-1:0] rd_dat;
	output wire empty;
	output wire full;
	output wire [`ADDR_WIDTH-1:0] available;

`include "clog2.vh"

	reg [WIDTH-1:0] fifo [DEPTH-1:0];
	reg [`ADDR_WIDTH:0] wpos;
	reg [`ADDR_WIDTH:0] rpos;

	always @(posedge clk or negedge rst_b) begin
		if (~rst_b) begin
			wpos <= 'h0;
			rpos <= 'h0;
		end else begin
			if (rd_en) begin
				rd_dat <= fifo[rpos[`ADDR_WIDTH-1:0]];
				rpos <= rpos + 'h1;
			end
			if (wr_en) begin
				fifo[wpos[`ADDR_WIDTH-1:0]] <= wr_dat;
				wpos <= wpos + 'h1;
			end
		end
	end

	assign empty = (wpos == rpos);
	assign full = (wpos == rpos + DEPTH);
	assign available = wpos - rpos;
endmodule
