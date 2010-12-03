/* Register mapping:
 * 00000 = Read start address
 * 00100 = Read length (in 64-byte packets)
 * 01000 = Write start address
 * 01100 = Write row length (in 64-byte packets)
 * 10000 = Write row stride
 * 10100 = Write words written
 
        parameter DEFAULT_RDADDR = 31'h00000000;
	parameter DEFAULT_RDLEN  = 31'h00000000;
	parameter DEFAULT_WRADDR = 31'h00000000;
	parameter DEFAULT_WRROWL = 31'h00000000;
	parameter DEFAULT_WRROWS = 31'h00000000;
	parameter DEFAULT_WRDONE = 31'h00000000;

 */

module AccelBlit(/*AUTOARG*/
   // Outputs
   accel_blit__fsabo_valid, accel_blit__fsabo_mode,
   accel_blit__fsabo_did, accel_blit__fsabo_subdid,
   accel_blit__fsabo_addr, accel_blit__fsabo_len,
   accel_blit__fsabo_data, accel_blit__fsabo_mask,
   accel_blit__spami_busy_b, accel_blit__spami_data,
   // Inputs
   accel_blit__fsabo_credit, fsabi_clk, fsabi_rst_b, fsabi_valid,
   fsabi_did, fsabi_subdid, fsabi_data, cclk, cclk_rst_b, spamo_valid,
   spamo_r_nw, spamo_did, spamo_addr, spamo_data
   );

	`include "fsab_defines.vh"
	`include "spam_defines.vh"
	
	/* FSAB interface */
	output reg                  accel_blit__fsabo_valid = 0;
	output reg [FSAB_REQ_HI:0]  accel_blit__fsabo_mode = 0;
	output reg [FSAB_DID_HI:0]  accel_blit__fsabo_did = 0;
	output reg [FSAB_DID_HI:0]  accel_blit__fsabo_subdid = 0;
	output reg [FSAB_ADDR_HI:0] accel_blit__fsabo_addr = 0;
	output reg [FSAB_LEN_HI:0]  accel_blit__fsabo_len = 0;
	output reg [FSAB_DATA_HI:0] accel_blit__fsabo_data = 0;
	output reg [FSAB_MASK_HI:0] accel_blit__fsabo_mask = 0;
	input                       accel_blit__fsabo_credit;
	
	input                       fsabi_clk;
	input                       fsabi_rst_b;
	input                       fsabi_valid;
	input      [FSAB_DID_HI:0]  fsabi_did;
	input      [FSAB_DID_HI:0]  fsabi_subdid;
	input      [FSAB_DATA_HI:0] fsabi_data;
	
	/* SPAM interface */
	input cclk;
	input cclk_rst_b;
	
	input                       spamo_valid;
	input                       spamo_r_nw;
	input      [SPAM_DID_HI:0]  spamo_did;
	input      [SPAM_ADDR_HI:0] spamo_addr;
	input      [SPAM_DATA_HI:0] spamo_data;

	output                      accel_blit__spami_busy_b;
	output reg [SPAM_DATA_HI:0] accel_blit__spami_data;
	
	`include "clog2.vh"
	parameter FSAB_DID = FSAB_DID_ACCEL;
	parameter FSAB_SUBDID = FSAB_SUBDID_ACCEL_BLIT;
	
	parameter SPAM_DID = SPAM_DID_ACCEL;
	parameter SPAM_ADDRPFX = 24'h100000;
	parameter SPAM_ADDRMASK = 24'hF00000;

	parameter DEFAULT_RDADDR = 31'h00000000;
	parameter DEFAULT_RDLEN  = 31'h00000000;
	parameter DEFAULT_WRADDR = 31'h00000000;
	parameter DEFAULT_WRROWL = 31'h00000000;
	parameter DEFAULT_WRROWS = 31'h00000000;
	parameter DEFAULT_WRDONE = 31'h00000000;

	/* FSAB credit availability logic */
	wire trans_start;
	
	reg [FSAB_CREDITS_HI:0] fsab_credits = FSAB_INITIAL_CREDITS;
	wire fsab_credit_avail = (fsab_credits != 0);
	always @(posedge fsabi_clk or negedge fsabi_rst_b) begin
		if (!fsabi_rst_b) begin
			fsab_credits <= FSAB_INITIAL_CREDITS;
		end else begin
			if (accel_blit__fsabo_credit | trans_start) begin
			`ifdef verilator
				$display("ACCELBLIT: Credits: %d (+%d, -%d)", fsab_credits, accel_blit__fsabo_credit, trans_start);
			`endif
			end
			fsab_credits <= fsab_credits + (accel_blit__fsabo_credit ? 1 : 0) - (trans_start ? 1 : 0);
		end
	end

	/*** TRANSACTION CONTROL LOGIC ***/
	wire bus_strobe_rdaddr;
	wire [30:0] bus_rdaddr;
	
	wire bus_strobe_rdlen;
	wire [30:0] bus_rdlen;
	
	wire bus_strobe_wraddr;
	wire [30:0] bus_wraddr;
	
	wire bus_strobe_wrrowl;
	wire [30:0] bus_wrrowl;
	
	wire bus_strobe_wrrows;
	wire [30:0] bus_wrrows;
	
	wire bus_strobe_wrdone;
	wire [30:0] bus_wrdone;
	
	reg [30:0] wrdone = DEFAULT_WRDONE;
	
	reg [30:0] rdaddr;
	reg [30:0] rdlen;
	
	reg [30:0] wraddr_cur = DEFAULT_WRADDR;
	reg [30:0] wraddr_row = DEFAULT_WRADDR;
	reg [30:0] wrrowl_rem = DEFAULT_WRROWL;
	
	reg trans_is_read = 1;
	
	reg [FSAB_LEN_HI:0] trans_words_rem = 0;
	wire [FSAB_LEN_HI:0] trans_words = 8;
	reg [63:0] rddata [7:0];
	integer i;
	initial
		for (i = 0; i < 8; i = i + 1)
			rddata[i] = 64'h0;
	
	assign trans_start = !bus_strobe_rdaddr && !bus_strobe_rdlen &&
	                     fsab_credit_avail && (trans_words_rem == 0) &&
	                     ((trans_is_read == 1) ? (rdlen != 0)
	                                           : 1);
	
	wire fsabi_decode = fsabi_valid && fsabi_did == FSAB_DID && fsabi_subdid == FSAB_SUBDID;
	
	always @(posedge fsabi_clk or negedge fsabi_rst_b) begin
		if (!fsabi_rst_b) begin
			rdaddr <= DEFAULT_RDADDR;
			rdlen <= DEFAULT_RDLEN;
			trans_is_read <= 1;
			trans_words_rem <= 0;
			
			wraddr_cur <= DEFAULT_WRADDR;
			wraddr_row <= DEFAULT_WRADDR;
			wrrowl_rem <= DEFAULT_WRROWL;
			wrdone <= DEFAULT_WRDONE;
			
			accel_blit__fsabo_valid <= 0;
			accel_blit__fsabo_mode <= {(FSAB_REQ_HI+1){1'bx}};
			accel_blit__fsabo_did <= {(FSAB_DID_HI+1){1'bx}};
			accel_blit__fsabo_subdid <= {(FSAB_DID_HI+1){1'bx}};
			accel_blit__fsabo_addr <= {(FSAB_ADDR_HI+1){1'bx}};
			accel_blit__fsabo_len <= {{FSAB_LEN_HI+1}{1'bx}};
			accel_blit__fsabo_data <= {{FSAB_DATA_HI+1}{1'bx}};
			accel_blit__fsabo_mask <= {{FSAB_MASK_HI+1}{1'bx}};
		end else begin
			if (bus_strobe_rdaddr)
				rdaddr <= bus_rdaddr;
			else if (trans_start && trans_is_read)
				rdaddr <= rdaddr + {24'h0, trans_words,3'b000};
			
			if (bus_strobe_rdlen)
				rdlen <= bus_rdlen;
			else if (trans_start && trans_is_read)
				rdlen <= rdlen - 1;
			
			if (bus_strobe_wraddr || bus_strobe_wrrowl || bus_strobe_wrdone) begin
				wraddr_cur <= bus_wraddr;
				wraddr_row <= bus_wraddr;
				wrrowl_rem <= bus_wrrowl - 1;
				wrdone <= bus_wrdone;
			end else if ((trans_words_rem == 1) && !trans_is_read) begin
				if (wrrowl_rem == 0) begin
					wrrowl_rem <= bus_wrrowl - 1;
					wraddr_cur <= wraddr_row + bus_wrrows;
					wraddr_row <= wraddr_row + bus_wrrows;
				end else begin
					wraddr_cur <= wraddr_cur + 64;
					wrrowl_rem <= wrrowl_rem - 1;
				end
				wrdone <= wrdone + 1;
			end
			
			if (trans_start)
				trans_words_rem <= trans_words;
			else if (!trans_is_read && (trans_words_rem != 0))
				trans_words_rem <= trans_words_rem - 1;
			else if (trans_is_read && fsabi_decode)
				trans_words_rem <= trans_words_rem - 1;
			
			if (trans_is_read && fsabi_decode && (trans_words_rem == 1))
				trans_is_read <= 0;
			else if (!trans_is_read && (trans_words_rem == 1))
				trans_is_read <= 1;
			
			if (fsabi_decode)
				rddata[trans_words_rem - 1] <= fsabi_data;
			
			if (trans_start && trans_is_read) begin
				accel_blit__fsabo_valid <= 1;
				accel_blit__fsabo_mode <= FSAB_READ;
				accel_blit__fsabo_did <= FSAB_DID;
				accel_blit__fsabo_subdid <= FSAB_SUBDID;
				accel_blit__fsabo_addr <= rdaddr;
				accel_blit__fsabo_len <= trans_words;
				accel_blit__fsabo_data <= {{FSAB_DATA_HI+1}{1'bx}};
				accel_blit__fsabo_mask <= {{FSAB_MASK_HI+1}{1'bx}};
				$display("ACCELBLIT: read start: req %x words from %08x", trans_words, rdaddr);
			end else if ((trans_words_rem != 0) && !trans_is_read) begin
				accel_blit__fsabo_valid <= 1;
				accel_blit__fsabo_mode <= FSAB_WRITE;
				accel_blit__fsabo_did <= FSAB_DID;
				accel_blit__fsabo_subdid <= FSAB_SUBDID;
				accel_blit__fsabo_addr <= wraddr_cur;
				accel_blit__fsabo_len <= trans_words;
				accel_blit__fsabo_data <= rddata[trans_words_rem - 1];
				accel_blit__fsabo_mask <= {{4{rddata[trans_words_rem - 1][32]}},
				                           {4{rddata[trans_words_rem - 1][0]}}};
				$display("ACCELBLIT: write: %x words, wraddr_cur %x, data %x, mask %x", trans_words, wraddr_cur, rddata[trans_words_rem - 1],
					{{4{rddata[trans_words_rem - 1][32]}},{4{rddata[trans_words_rem - 1][0]}}});
			end else begin
				accel_blit__fsabo_valid <= 0;
				accel_blit__fsabo_mode <= {(FSAB_REQ_HI+1){1'bx}};
				accel_blit__fsabo_did <= {(FSAB_DID_HI+1){1'bx}};
				accel_blit__fsabo_subdid <= {(FSAB_DID_HI+1){1'bx}};
				accel_blit__fsabo_addr <= {(FSAB_ADDR_HI+1){1'bx}};
				accel_blit__fsabo_len <= {{FSAB_LEN_HI+1}{1'bx}};
				accel_blit__fsabo_data <= {{FSAB_DATA_HI+1}{1'bx}};
				accel_blit__fsabo_mask <= {{FSAB_MASK_HI+1}{1'bx}};
			end

		end
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
			$display("ACCELBLIT: CSR: wr_decode, rst %d", cclk_rst_b);
		`endif
		end
	end

	wire wr_done_strobe_RDADDR;
	CSRAsyncWrite #(.WIDTH       (31),
	                .RESET_VALUE (DEFAULT_RDADDR))
		CSR_RDADDR(/* NOT AUTOINST */
		           // Outputs
		           .wr_wait_cclk       (),
		           .wr_done_strobe_cclk(wr_done_strobe_RDADDR),
		           .wr_strobe_tclk     (bus_strobe_rdaddr),
		           .wr_data_tclk       (bus_rdaddr[30:0]),
		           // Inputs
		           .cclk               (cclk),
		           .tclk               (fsabi_clk),
		           .rst_b_cclk         (cclk_rst_b),
		           .rst_b_tclk         (fsabi_rst_b),
		           .wr_strobe_cclk     (wr_decode && (spamo_addr[4:0] == 5'b00000)),
		           .wr_data_cclk       (spamo_data[30:0]));
	
	wire wr_done_strobe_RDLEN;
	CSRAsyncWrite #(.WIDTH       (31),
	                .RESET_VALUE (DEFAULT_RDLEN))
		CSR_RDLEN (/* NOT AUTOINST */
		           // Outputs
		           .wr_wait_cclk       (),
		           .wr_done_strobe_cclk(wr_done_strobe_RDLEN),
		           .wr_strobe_tclk     (bus_strobe_rdlen),
		           .wr_data_tclk       (bus_rdlen[30:0]),
		           // Inputs
		           .cclk               (cclk),
		           .tclk               (fsabi_clk),
		           .rst_b_cclk         (cclk_rst_b),
		           .rst_b_tclk         (fsabi_rst_b),
		           .wr_strobe_cclk     (wr_decode && (spamo_addr[4:0] == 5'b00100)),
		           .wr_data_cclk       (spamo_data[30:0]));
	
	wire wr_done_strobe_WRADDR;
	CSRAsyncWrite #(.WIDTH       (31),
	                .RESET_VALUE (DEFAULT_WRADDR))
		CSR_WRADDR(/* NOT AUTOINST */
		           // Outputs
		           .wr_wait_cclk       (),
		           .wr_done_strobe_cclk(wr_done_strobe_WRADDR),
		           .wr_strobe_tclk     (bus_strobe_wraddr),
		           .wr_data_tclk       (bus_wraddr[30:0]),
		           // Inputs
		           .cclk               (cclk),
		           .tclk               (fsabi_clk),
		           .rst_b_cclk         (cclk_rst_b),
		           .rst_b_tclk         (fsabi_rst_b),
		           .wr_strobe_cclk     (wr_decode && (spamo_addr[4:0] == 5'b01000)),
		           .wr_data_cclk       (spamo_data[30:0]));
	
	wire wr_done_strobe_WRROWL;
	CSRAsyncWrite #(.WIDTH       (31),
	                .RESET_VALUE (DEFAULT_WRROWL))
		CSR_WRROWL(/* NOT AUTOINST */
		           // Outputs
		           .wr_wait_cclk       (),
		           .wr_done_strobe_cclk(wr_done_strobe_WRROWL),
		           .wr_strobe_tclk     (bus_strobe_wrrowl),
		           .wr_data_tclk       (bus_wrrowl[30:0]),
		           // Inputs
		           .cclk               (cclk),
		           .tclk               (fsabi_clk),
		           .rst_b_cclk         (cclk_rst_b),
		           .rst_b_tclk         (fsabi_rst_b),
		           .wr_strobe_cclk     (wr_decode && (spamo_addr[4:0] == 5'b01100)),
		           .wr_data_cclk       (spamo_data[30:0]));
	
	wire wr_done_strobe_WRROWS;
	CSRAsyncWrite #(.WIDTH       (31),
	                .RESET_VALUE (DEFAULT_WRROWS))
		CSR_WRROWS(/* NOT AUTOINST */
		           // Outputs
		           .wr_wait_cclk       (),
		           .wr_done_strobe_cclk(wr_done_strobe_WRROWS),
		           .wr_strobe_tclk     (bus_strobe_wrrows),
		           .wr_data_tclk       (bus_wrrows[30:0]),
		           // Inputs
		           .cclk               (cclk),
		           .tclk               (fsabi_clk),
		           .rst_b_cclk         (cclk_rst_b),
		           .rst_b_tclk         (fsabi_rst_b),
		           .wr_strobe_cclk     (wr_decode && (spamo_addr[4:0] == 5'b10000)),
		           .wr_data_cclk       (spamo_data[30:0]));
	
	wire wr_done_strobe_WRDONE;
	CSRAsyncWrite #(.WIDTH       (31),
	                .RESET_VALUE (DEFAULT_WRDONE))
		CSR_WRDONE(/* NOT AUTOINST */
		           // Outputs
		           .wr_wait_cclk       (),
		           .wr_done_strobe_cclk(wr_done_strobe_WRDONE),
		           .wr_strobe_tclk     (bus_strobe_wrdone),
		           .wr_data_tclk       (bus_wrdone[30:0]),
		           // Inputs
		           .cclk               (cclk),
		           .tclk               (fsabi_clk),
		           .rst_b_cclk         (cclk_rst_b),
		           .rst_b_tclk         (fsabi_rst_b),
		           .wr_strobe_cclk     (wr_decode && (spamo_addr[4:0] == 5'b10100)),
		           .wr_data_cclk       (spamo_data[30:0]));

	wire [30:0] rd_data_WRDONE;
	wire rd_done_strobe_WRDONE;
	CSRAsyncRead #(.WIDTH        (31))
		CSR_WRDONE_READ     (/* NOT AUTOINST */
				     // Outputs
				     .rd_data_cclk	(rd_data_WRDONE),
				     .rd_wait_cclk	(),
				     .rd_done_strobe_cclk(rd_done_strobe_WRDONE),
				     .rd_strobe_tclk	(),
				     // Inputs
				     .cclk		(cclk),
				     .tclk		(fsabi_clk),
				     .rst_b_cclk	(cclk_rst_b),
				     .rst_b_tclk	(fsabi_rst_b),
				     .rd_strobe_cclk	(rd_decode && (spamo_addr[4:0] == 5'b10100)),
				     .rd_data_tclk	(wrdone[30:0]));

	assign accel_blit__spami_busy_b = wr_done_strobe_RDADDR |
	                                  wr_done_strobe_RDLEN |
	                                  wr_done_strobe_WRADDR |
	                                  wr_done_strobe_WRROWL |
	                                  wr_done_strobe_WRROWS |
	                                  wr_done_strobe_WRDONE |
	                                  rd_done_strobe_WRDONE;
	assign accel_blit__spami_data = {32{rd_done_strobe_WRDONE}} & {1'b0, rd_data_WRDONE};
endmodule

// Local Variables:
// verilog-library-directories:("." "../console" "../core" "../fsab" "../spam" "../fsab/sim" "../util")
// End:
