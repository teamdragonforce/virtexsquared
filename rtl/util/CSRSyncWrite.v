/* CSRSyncWrite synchronizes a write-only configuration space register from
 * one clock domain that will be doing the write (typically the SPAM clock
 * domain) -- referred to within as cclk -- into a different clock domain
 * that some module is running on -- referred to within as tclk ("target
 * clock").
 * 
 * No guarantees are required about the phase relationship of the two
 * clocks.  It is required that the cclk domain's clock has little enough
 * skew internally that the data flip-flops will all transition within one
 * cycle of tclk; if strange behavior results, consider setting an OFFSET
 * timing relationship in the xcf.
 */

module CSRSyncWrite #(
	parameter WIDTH = 32,
	parameter RESET_VALUE = {WIDTH{1'b0}}
) (/*AUTOARG*/
   // Outputs
   wr_wait_cclk, wr_done_strobe_cclk, wr_strobe_tclk, wr_data_tclk,
   // Inputs
   cclk, tclk, rst_b_cclk, rst_b_tclk, wr_strobe_cclk, wr_data_cclk
   );

	input                    cclk;
	input                    tclk;
	
	input                    rst_b_cclk;
	input                    rst_b_tclk;
	
	input                    wr_strobe_cclk;
	input      [(WIDTH-1):0] wr_data_cclk;
	output reg               wr_wait_cclk = 0;
	output reg               wr_done_strobe_cclk = 0;
	
	output reg               wr_strobe_tclk = 0;
	output reg [(WIDTH-1):0] wr_data_tclk = RESET_VALUE;

	reg [(WIDTH-1):0] wr_data_l_cclk = {WIDTH{1'b0}};
	reg               wr_current_cclk = 0;
	reg               wr_current_tclk_s1 = 0;
	reg               wr_current_tclk_cclk = 0;
	
	reg               wr_current_tclk = 0;
	reg               wr_current_cclk_s1 = 0;
	reg               wr_current_cclk_tclk = 0;
	reg               wr_current_cclk_1a_tclk = 0;
	
	reg [(WIDTH-1):0] wr_data_l_cclk_s1 = {WIDTH{1'b0}};
	reg [(WIDTH-1):0] wr_data_l_cclk_tclk = {WIDTH{1'b0}};
	
	reg               wr_wait_cclk_1a = 0;
	
	always @(posedge cclk)
		if (~rst_b_cclk) begin
			wr_data_l_cclk <= {WIDTH{1'b0}};
			wr_current_cclk <= 0;
			wr_current_tclk_s1 <= 0;
			wr_current_tclk_cclk <= 0;
			wr_wait_cclk_1a <= 0;
		end else begin
			wr_current_tclk_s1 <= wr_current_tclk;
			wr_current_tclk_cclk <= wr_current_tclk_s1;
			wr_wait_cclk_1a <= wr_wait_cclk;
		
			if (wr_strobe_cclk) begin
				wr_current_cclk <= ~wr_current_cclk;
				wr_data_l_cclk <= wr_data_cclk;
			end
		end
	
	always @(*) begin
		wr_wait_cclk = wr_strobe_cclk || (wr_current_cclk != wr_current_tclk_cclk);
		wr_done_strobe_cclk = !wr_wait_cclk && wr_wait_cclk_1a;
	end
	
	always @(posedge tclk)
		if (~rst_b_tclk) begin
			wr_current_tclk <= 0;
			wr_current_cclk_s1 <= 0;
			wr_current_cclk_tclk <= 0;
			wr_current_cclk_1a_tclk <= 0;
			wr_data_l_cclk_s1 <= {WIDTH{1'b0}};
			wr_data_l_cclk_tclk <= {WIDTH{1'b0}};
			wr_data_tclk <= RESET_VALUE;
			wr_strobe_tclk <= 0;
		end else begin
			wr_current_cclk_s1 <= wr_current_cclk;
			wr_current_cclk_tclk <= wr_current_cclk_s1;
			wr_current_cclk_1a_tclk <= wr_current_cclk_tclk;
			
			wr_data_l_cclk_s1 <= wr_data_l_cclk;
			wr_data_l_cclk_tclk <= wr_data_l_cclk_s1;
			
			/* We use the delayed version of the current signal,
			 * because it may have arrived before the data
			 * signals.  If we wait a clock, the data signals
			 * are guaranteed to have arrived by now.
			 */
			if (wr_current_cclk_1a_tclk != wr_current_tclk) begin
				wr_current_tclk <= wr_current_cclk_1a_tclk;
				wr_strobe_tclk <= 1;
				wr_data_tclk <= wr_data_l_cclk_s1;
			end else
				wr_strobe_tclk <= 0;
		end

endmodule
