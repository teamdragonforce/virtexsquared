/* slap this overtop of system.v to run fifo testbench */

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

`define DEPTH1 4
`define WIDTH1 8
`define ALMOST1 1

`define DEPTH2 5
`define WIDTH2 8
`define ALMOST2 7

	reg  [`WIDTH1-1:0] wr_dat1 = 0;
	wire [`WIDTH1-1:0] rd_dat1;
	reg                wr_en1 = 0;
	reg                rd_en1 = 0;
	wire               full1;
	wire               empty1;
	wire               afull1;
	wire               aempty1;
	wire [2:0] available1;

	reg  [`WIDTH2-1:0] wr_dat2 = 0;
	wire [`WIDTH2-1:0] rd_dat2;
	reg                wr_en2 = 0;
	reg                rd_en2 = 0;
	wire               full2;
	wire               empty2;
	wire               afull2;
	wire               aempty2;
	wire [4:0] available2;


	Fifo #(.DEPTH  (4),
	       .WIDTH  (8),
	       .ALMOST (1))
	one (.clk     (clk),
	     .rst_b   (rst_b),
	     .wr_en   (wr_en1),
	     .rd_en   (rd_en1),
	     .wr_dat  (wr_dat1),
	     .rd_dat  (rd_dat1),
	     .full    (full1),
	     .empty   (empty1),
	     .afull   (afull1),
	     .aempty  (aempty1),
	     .available (available1));

	Fifo #(.DEPTH  (16),
	       .WIDTH  (8),
	       .ALMOST (7))
	two (.clk     (clk),
	     .rst_b   (rst_b),
	     .wr_en   (wr_en2),
	     .rd_en   (rd_en2),
	     .wr_dat  (wr_dat2),
	     .rd_dat  (rd_dat2),
	     .full    (full2),
	     .empty   (empty2),
	     .afull   (afull2),
	     .aempty  (aempty2),
	     .available (available2));

	integer i = 0;
	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			i <= 0;
		end
		else begin
			if (i <= 17) $display("Fifo: i=%d\n", i+1);
			i <= i + 1;
		end
	end

	always @(*) begin
		if (rst_b) begin
			case (i)
				0: begin
					wr_dat1 = 0;
					wr_en1  = 0;
					rd_en1  = 0;
				end
				1: begin
					/* zro (bana) in fifo */
					assert(available1 == 0) else $error("Fifo: avail");
					assert(empty1) else $error("Fifo: empty");
					assert(aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(!afull1) else $error("Fifo: afull");

					wr_dat1 = 1;
					wr_en1  = 1;
					rd_en1  = 0;
				end
				2: begin
					/* one in fifo */
					assert(available1 == 1) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(!afull1) else $error("Fifo: afull");

					wr_dat1 = 2;
					wr_en1  = 1;
					rd_en1  = 0;
				end
				3: begin
					/* two in fifo */
					assert(available1 == 2) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(!aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(!afull1) else $error("Fifo: afull");

					wr_dat1 = 0;
					wr_en1  = 0;
					rd_en1  = 1;
				end
				4: begin
					/* one in fifo */
					assert(available1 == 1) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(!afull1) else $error("Fifo: afull");

					wr_dat1 = 0;
					wr_en1  = 0;
					rd_en1  = 1;
				end
				5: begin
					/* zero in fifo */
					assert(available1 == 0) else $error("Fifo: avail");
					assert(empty1) else $error("Fifo: empty");
					assert(aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(!afull1) else $error("Fifo: afull");

					wr_dat1 = 3;
					wr_en1  = 1;
					rd_en1  = 0;
				end
				6: begin
					/* one in fifo */
					assert(available1 == 1) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(!afull1) else $error("Fifo: afull");

					wr_dat1 = 4;
					wr_en1  = 1;
					rd_en1  = 0;
				end
				7: begin
					/* two in fifo */
					assert(available1 == 2) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(!aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(!afull1) else $error("Fifo: afull");

					wr_dat1 = 5;
					wr_en1  = 1;
					rd_en1  = 0;
				end
				8: begin
					/* three in fifo */
					assert(available1 == 3) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(!aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(afull1) else $error("Fifo: afull");

					wr_dat1 = 6;
					wr_en1  = 1;
					rd_en1  = 0;
				end
				9: begin
					/* four in fifo */
					assert(available1 == 4) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(!aempty1) else $error("Fifo: aempty");
					assert(full1) else $error("Fifo: full");
					assert(afull1) else $error("Fifo: afull");

					wr_dat1 = 0;
					wr_en1  = 0;
					rd_en1  = 0;
				end
				10: begin
					/* four in fifo */
					assert(available1 == 4) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(!aempty1) else $error("Fifo: aempty");
					assert(full1) else $error("Fifo: full");
					assert(afull1) else $error("Fifo: afull");

					wr_dat1 = 0;
					wr_en1  = 0;
					rd_en1  = 1;
				end
				11: begin
					/* three in fifo */
					assert(available1 == 3) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(!aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(afull1) else $error("Fifo: afull");

					wr_dat1 = 0;
					wr_en1  = 0;
					rd_en1  = 1;
				end
				12: begin
					/* two in fifo */
					assert(available1 == 2) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(!aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(!afull1) else $error("Fifo: afull");

					wr_dat1 = 7;
					wr_en1  = 1;
					rd_en1  = 0;
				end
				13: begin
					/* thre (aple) in fifo */
					assert(available1 == 3) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(!aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(afull1) else $error("Fifo: afull");

					wr_dat1 = 0;
					wr_en1  = 0;
					rd_en1  = 0;
				end
				14: begin
					/* three in fifo */
					assert(available1 == 3) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(!aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(afull1) else $error("Fifo: afull");

					wr_dat1 = 0;
					wr_en1  = 0;
					rd_en1  = 1;
				end
				15: begin
					/* two in fifo */
					assert(available1 == 2) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(!aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(!afull1) else $error("Fifo: afull");

					wr_dat1 = 0;
					wr_en1  = 0;
					rd_en1  = 1;
				end
				16: begin
					/* one in fifo */
					assert(available1 == 1) else $error("Fifo: avail");
					assert(!empty1) else $error("Fifo: empty");
					assert(aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(!afull1) else $error("Fifo: afull");

					wr_dat1 = 0;
					wr_en1  = 0;
					rd_en1  = 1;
				end
				17: begin
					/* zero in fifo */
					assert(available1 == 0) else $error("Fifo: avail");
					assert(empty1) else $error("Fifo: empty");
					assert(aempty1) else $error("Fifo: aempty");
					assert(!full1) else $error("Fifo: full");
					assert(!afull1) else $error("Fifo: afull");

					wr_dat1 = 0;
					wr_en1  = 0;
					rd_en1  = 0;
				end
				default: begin
					wr_dat1 = 0;
					wr_en1  = 0;
					rd_en1  = 0;
				end
			endcase
		end
	end

endmodule
