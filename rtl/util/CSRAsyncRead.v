/* CSRASyncWrite synchronizes a read-only configuration space register from
 * one clock domain that will be doing the read (typically the SPAM clock
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

module CSRAsyncRead #(
	parameter WIDTH = 32
) (/*AUTOARG*/
   // Outputs
   rd_data_cclk, rd_wait_cclk, rd_done_strobe_cclk, rd_strobe_tclk,
   // Inputs
   cclk, tclk, rst_b_cclk, rst_b_tclk, rd_strobe_cclk, rd_data_tclk
   );

	input                    cclk;
	input                    tclk;
	
	input                    rst_b_cclk;
	input                    rst_b_tclk;
	
	input                    rd_strobe_cclk;
	output reg [(WIDTH-1):0] rd_data_cclk = {WIDTH{1'b0}};
	output reg               rd_wait_cclk = 0;
	output reg               rd_done_strobe_cclk = 0;
	
	output reg               rd_strobe_tclk = 0;
	input [(WIDTH-1):0]      rd_data_tclk;

	reg               rd_current_cclk = 0;
	reg               rd_current_tclk_s1 = 0;
	reg               rd_current_tclk_cclk = 0;
	reg               rd_current_tclk_1a_cclk = 0;
	
	reg               rd_current_tclk = 0;
	reg               rd_current_cclk_s1 = 0;
	reg               rd_current_cclk_tclk = 0;
	
	reg [(WIDTH-1):0] rd_data_l_tclk = {WIDTH{1'b0}};
	reg [(WIDTH-1):0] rd_data_l_tclk_s1 = {WIDTH{1'b0}};
	reg [(WIDTH-1):0] rd_data_l_tclk_cclk = {WIDTH{1'b0}};
	
	reg               rd_wait_cclk_1a = 0;
	
	always @(posedge cclk)
		if (~rst_b_cclk) begin
			rd_data_l_tclk_s1 <= {WIDTH{1'b0}};
			rd_data_l_tclk_cclk <= {WIDTH{1'b0}};
			
			rd_current_cclk <= 0;
			rd_current_tclk_s1 <= 0;
			rd_current_tclk_cclk <= 0;
			rd_current_tclk_1a_cclk <= 0;
			
			rd_wait_cclk_1a <= 0;
		end else begin
			rd_data_l_tclk_s1 <= rd_data_l_tclk;
			rd_data_l_tclk_cclk <= rd_data_l_tclk_s1;

			rd_current_tclk_s1 <= rd_current_tclk;
			rd_current_tclk_cclk <= rd_current_tclk_s1;
			rd_current_tclk_1a_cclk <= rd_current_tclk_cclk;
			
			rd_wait_cclk_1a <= rd_wait_cclk;
		
			if (rd_strobe_cclk) begin
				rd_current_cclk <= ~rd_current_cclk;
			end
		end
	
	always @(*) begin
		/* We use the delayed version of the current signal,
		 * because it may have arrived before the data
		 * signals.  If we wait a clock, the data signals
		 * are guaranteed to have arrived by now.
		 */
		rd_wait_cclk = rd_strobe_cclk || (rd_current_cclk != rd_current_tclk_1a_cclk);
		rd_done_strobe_cclk = !rd_wait_cclk && rd_wait_cclk_1a;
		rd_data_cclk = rd_data_l_tclk_cclk;
	end
	
	always @(posedge tclk)
		if (~rst_b_tclk) begin
			rd_current_tclk <= 0;
			rd_current_cclk_s1 <= 0;
			rd_current_cclk_tclk <= 0;
			rd_data_l_tclk <= {WIDTH{1'b0}};
			rd_strobe_tclk <= 0;
		end else begin
			rd_current_cclk_s1 <= rd_current_cclk;
			rd_current_cclk_tclk <= rd_current_cclk_s1;
			
			if (rd_current_cclk_tclk != rd_current_tclk) begin
				rd_current_tclk <= rd_current_cclk_tclk;
				rd_strobe_tclk <= 1;
				rd_data_l_tclk <= rd_data_tclk;
			end else
				rd_strobe_tclk <= 0;
		end

endmodule
