/* Register mapping:
 * 0000 = datum
 * 0100 = start address
 * 1000 = number of FSAB packets (x8 bytes)
 */

module AccelClear(/*AUTOARG*/
   // Outputs
   accel_clear__fsabo_valid, accel_clear__fsabo_mode,
   accel_clear__fsabo_did, accel_clear__fsabo_subdid,
   accel_clear__fsabo_addr, accel_clear__fsabo_len,
   accel_clear__fsabo_data, accel_clear__fsabo_mask,
   accel_clear__spami_busy_b, accel_clear__spami_data,
   // Inputs
   accel_clear__fsabo_credit, fsabi_clk, fsabi_rst_b, fsabi_valid,
   fsabi_did, fsabi_subdid, fsabi_data, cclk, cclk_rst_b, spamo_valid,
   spamo_r_nw, spamo_did, spamo_addr, spamo_data
   );

	`include "fsab_defines.vh"
	`include "spam_defines.vh"
	
	/* FSAB interface */
	output reg                   accel_clear__fsabo_valid = 0;
	output reg  [FSAB_REQ_HI:0]  accel_clear__fsabo_mode = 0;
	output reg  [FSAB_DID_HI:0]  accel_clear__fsabo_did = 0;
	output reg  [FSAB_DID_HI:0]  accel_clear__fsabo_subdid = 0;
	output reg  [FSAB_ADDR_HI:0] accel_clear__fsabo_addr = 0;
	output reg  [FSAB_LEN_HI:0]  accel_clear__fsabo_len = 0;
	output reg  [FSAB_DATA_HI:0] accel_clear__fsabo_data = 0;
	output reg  [FSAB_MASK_HI:0] accel_clear__fsabo_mask = 0;
	input                        accel_clear__fsabo_credit;
	
	input                        fsabi_clk;
	input                        fsabi_rst_b;
	input                        fsabi_valid;
	input       [FSAB_DID_HI:0]  fsabi_did;
	input       [FSAB_DID_HI:0]  fsabi_subdid;
	input       [FSAB_DATA_HI:0] fsabi_data;
	
	/* SPAM interface */
	input cclk;
	input cclk_rst_b;
	
	input                        spamo_valid;
	input                        spamo_r_nw;
	input       [SPAM_DID_HI:0]  spamo_did;
	input       [SPAM_ADDR_HI:0] spamo_addr;
	input       [SPAM_DATA_HI:0] spamo_data;

	output wire                  accel_clear__spami_busy_b;
	output wire [SPAM_DATA_HI:0] accel_clear__spami_data;
	
	`include "clog2.vh"
	parameter FSAB_DID = FSAB_DID_ACCEL;
	parameter FSAB_SUBDID = FSAB_SUBDID_ACCEL_CLEAR;
	
	parameter SPAM_DID = SPAM_DID_ACCEL;
	parameter SPAM_ADDRPFX = 24'h000000;
	parameter SPAM_ADDRMASK = 24'hF00000;

	parameter DEFAULT_VALUE = 32'h00000000;
	parameter DEFAULT_ADDR = 31'h00000000;
	parameter DEFAULT_LENREM = 31'h00000000;

	/* FSAB credit availability logic */
	wire trans_start;
	
	reg [FSAB_CREDITS_HI:0] fsab_credits = FSAB_INITIAL_CREDITS;
	wire fsab_credit_avail = (fsab_credits != 0);
	always @(posedge fsabi_clk or negedge fsabi_rst_b) begin
		if (!fsabi_rst_b) begin
			fsab_credits <= FSAB_INITIAL_CREDITS;
		end else begin
			if (accel_clear__fsabo_credit | trans_start) begin
			`ifdef verilator
				$display("ACCELCLEAR: Credits: %d (+%d, -%d)", fsab_credits, accel_clear__fsabo_credit, trans_start);
			`endif
			end
			fsab_credits <= fsab_credits + (accel_clear__fsabo_credit ? 1 : 0) - (trans_start ? 1 : 0);
		end
	end

	/* Transaction initiation and data state control logic */
	wire [31:0] bus_value;
	
	wire bus_addr_wr_strobe;
	wire [30:0] bus_addr;
	
	wire bus_lenrem_wr_strobe;
	wire [30:0] bus_lenrem;
	
	reg [30:0] addr = DEFAULT_ADDR;
	reg [30:0] lenrem = DEFAULT_LENREM;

	reg trans_start_1a = 0;
	reg [FSAB_LEN_HI:0] trans_words_rem = 0;
	wire [FSAB_LEN_HI:0] trans_words = (lenrem > FSAB_LEN_MAX) ? FSAB_LEN_MAX : lenrem[FSAB_LEN_HI:0];
	assign trans_start = fsab_credit_avail && (trans_words_rem == 0) && (lenrem != 0) && !bus_addr_wr_strobe && !bus_lenrem_wr_strobe && !trans_start_1a;
	
	always @(posedge fsabi_clk or negedge fsabi_rst_b) begin
		if (!fsabi_rst_b) begin
			addr <= DEFAULT_ADDR;
			lenrem <= DEFAULT_LENREM;
			trans_words_rem <= 0;
			trans_start_1a <= 0;
		end else begin
			if (bus_addr_wr_strobe)
				addr <= bus_addr;
			else if (trans_start)
				addr <= addr + {24'h0, trans_words,3'b000};
			
			if (bus_lenrem_wr_strobe)
				lenrem <= bus_lenrem;
			else if (trans_start)
				lenrem <= lenrem - {27'h0, trans_words};
			
			if (trans_start)
				trans_words_rem <= trans_words - 1;
			else if (trans_words_rem != 0)
				trans_words_rem <= trans_words_rem - 1;
			
			trans_start_1a <= trans_start;
		end
	end
	

	always @(posedge fsabi_clk or negedge fsabi_rst_b)
	begin
		if (!fsabi_rst_b) begin
			accel_clear__fsabo_valid <= 0;
			accel_clear__fsabo_mode <= {(FSAB_REQ_HI+1){1'bx}};
			accel_clear__fsabo_did <= {(FSAB_DID_HI+1){1'bx}};
			accel_clear__fsabo_subdid <= {(FSAB_DID_HI+1){1'bx}};
			accel_clear__fsabo_addr <= {(FSAB_ADDR_HI+1){1'bx}};
			accel_clear__fsabo_len <= {{FSAB_LEN_HI+1}{1'bx}};
			accel_clear__fsabo_data <= {{FSAB_DATA_HI+1}{1'bx}};
			accel_clear__fsabo_mask <= {{FSAB_MASK_HI+1}{1'bx}};
		end else if ((trans_start || (trans_words_rem != 0)) && fsabi_rst_b) begin
			accel_clear__fsabo_valid <= 1;
			accel_clear__fsabo_mode <= FSAB_WRITE;
			accel_clear__fsabo_did <= FSAB_DID;
			accel_clear__fsabo_subdid <= FSAB_SUBDID;
			accel_clear__fsabo_addr <= addr;
			accel_clear__fsabo_len <= trans_words;
			accel_clear__fsabo_data <= {bus_value, bus_value};
			accel_clear__fsabo_mask <= 8'hFF;
		end else
			accel_clear__fsabo_valid <= 0;
	end

	/* Config */
	wire wr_decode = spamo_valid && !spamo_r_nw && 
	                 ((spamo_addr & SPAM_ADDRMASK) == SPAM_ADDRPFX) &&
	                 (spamo_did == SPAM_DID);
	wire rd_decode = spamo_valid && spamo_r_nw &&
	                 ((spamo_addr & SPAM_ADDRMASK) == SPAM_ADDRPFX) &&
	                 (spamo_did == SPAM_DID);
	
	always @(*) begin
		if (wr_decode) begin
		`ifdef verilator
			$display("ACCELCLEAR: CSR: wr_decode, rst %d", cclk_rst_b);
		`endif
		end
	end

	wire wr_done_strobe_VALUE;
	CSRAsyncWrite #(.WIDTH       (32),
	                .RESET_VALUE (DEFAULT_VALUE))
		CSR_VALUE (/* NOT AUTOINST */
		           // Outputs
		           .wr_wait_cclk       (),
		           .wr_done_strobe_cclk(wr_done_strobe_VALUE),
		           .wr_strobe_tclk     (),
		           .wr_data_tclk       (bus_value[31:0]),
		           // Inputs
		           .cclk               (cclk),
		           .tclk               (fsabi_clk),
		           .rst_b_cclk         (cclk_rst_b),
		           .rst_b_tclk         (fsabi_rst_b),
		           .wr_strobe_cclk     (wr_decode && (spamo_addr[3:0] == 4'b0000)),
		           .wr_data_cclk       (spamo_data[31:0]));
	
	wire wr_done_strobe_ADDR;
	CSRAsyncWrite #(.WIDTH       (31),
	                .RESET_VALUE (DEFAULT_ADDR))
		CSR_ADDR  (/* NOT AUTOINST */
		           // Outputs
		           .wr_wait_cclk       (),
		           .wr_done_strobe_cclk(wr_done_strobe_ADDR),
		           .wr_strobe_tclk     (bus_addr_wr_strobe),
		           .wr_data_tclk       (bus_addr[30:0]),
		           // Inputs
		           .cclk               (cclk),
		           .tclk               (fsabi_clk),
		           .rst_b_cclk         (cclk_rst_b),
		           .rst_b_tclk         (fsabi_rst_b),
		           .wr_strobe_cclk     (wr_decode && (spamo_addr[3:0] == 4'b0100)),
		           .wr_data_cclk       (spamo_data[30:0]));
	
	wire wr_done_strobe_LENREM;
	CSRAsyncWrite #(.WIDTH       (31),
	                .RESET_VALUE (DEFAULT_ADDR))
		CSR_LENREM(/* NOT AUTOINST */
		           // Outputs
		           .wr_wait_cclk       (),
		           .wr_done_strobe_cclk(wr_done_strobe_LENREM),
		           .wr_strobe_tclk     (bus_lenrem_wr_strobe),
		           .wr_data_tclk       (bus_lenrem[30:0]),
		           // Inputs
		           .cclk               (cclk),
		           .tclk               (fsabi_clk),
		           .rst_b_cclk         (cclk_rst_b),
		           .rst_b_tclk         (fsabi_rst_b),
		           .wr_strobe_cclk     (wr_decode && (spamo_addr[3:0] == 4'b1000)),
		           .wr_data_cclk       (spamo_data[30:0]));

	wire [30:0] rd_data_LENREM;
	wire rd_done_strobe_LENREM;
	CSRAsyncRead #(.WIDTH        (31))
		CSR_LENREM_READ     (/* NOT AUTOINST */
				     // Outputs
				     .rd_data_cclk	(rd_data_LENREM),
				     .rd_wait_cclk	(),
				     .rd_done_strobe_cclk(rd_done_strobe_LENREM),
				     .rd_strobe_tclk	(),
				     // Inputs
				     .cclk		(cclk),
				     .tclk		(fsabi_clk),
				     .rst_b_cclk	(cclk_rst_b),
				     .rst_b_tclk	(fsabi_rst_b),
				     .rd_strobe_cclk	(rd_decode && (spamo_addr[3:0] == 4'b1000)),
				     .rd_data_tclk	(lenrem[30:0]));

	assign accel_clear__spami_busy_b = wr_done_strobe_VALUE | wr_done_strobe_ADDR | wr_done_strobe_LENREM | rd_done_strobe_LENREM;
	assign accel_clear__spami_data = {32{rd_done_strobe_LENREM}} & {1'b0, rd_data_LENREM};
endmodule

// Local Variables:
// verilog-library-directories:("." "../console" "../core" "../fsab" "../spam" "../fsab/sim" "../util")
// End:
