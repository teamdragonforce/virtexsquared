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
   wr_wait_cclk, wr_strobe_tclk, wr_data_tclk,
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
	
	output reg               wr_strobe_tclk = 0;
	output reg [(WIDTH-1):0] wr_data_tclk = RESET_VALUE;

`ifdef verilator
	always @(*) begin
		wr_strobe_tclk = wr_strobe_cclk;
	end
	
	always @(posedge cclk) begin
		if (rst_b_cclk)
			wr_data_tclk <= RESET_VALUE;
		else begin
			if (wr_strobe_cclk)
				wr_data_tclk <= wr_data_cclk;
		end
	end
`else
	always @(*)
		$error("CSRSyncWrite not synthesizable yet");
`endif

endmodule
