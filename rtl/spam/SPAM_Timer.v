module SPAM_Timer(/*AUTOARG*/
   // Outputs
   timer__spami_busy_b, timer__spami_data,
   // Inputs
   cclk, cclk_rst_b, spamo_valid, spamo_r_nw, spamo_did, spamo_addr,
   spamo_data
   );

	`include "spam_defines.vh"

	input cclk, cclk_rst_b;

	input                       spamo_valid;
	input                       spamo_r_nw;
	input [SPAM_DID_HI:0]       spamo_did;
	input [SPAM_ADDR_HI:0]      spamo_addr;
	input [SPAM_DATA_HI:0]      spamo_data;

	output reg                  timer__spami_busy_b = 0;
	output reg [SPAM_DATA_HI:0] timer__spami_data = 'h0;


	reg [SPAM_DATA_HI:0] cclk_counter = 0;

	always @(posedge cclk or negedge cclk_rst_b)
	begin
		if (!cclk_rst_b) begin
			cclk_counter <= 0;
		end
		else begin
			if (spamo_valid && spamo_r_nw && spamo_did == SPAM_DID_TIMER) begin
				timer__spami_busy_b <= 1;
				timer__spami_data <= cclk_counter;	
			end 
			else begin
				timer__spami_busy_b <= 0;
				timer__spami_data <= 0;
			end
			cclk_counter <= cclk_counter + 1;
		end
	end
endmodule




