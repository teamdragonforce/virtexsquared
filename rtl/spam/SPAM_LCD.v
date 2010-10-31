module SPAM_LCD(/*AUTOARG*/
   // Outputs
   lcd__spami_busy_b, lcd__spami_data, lcd_e, lcd_rnw, lcd_rs,
   // Inouts
   lcd_db, control_vio,
   // Inputs
   clk, rst_b, spamo_valid, spamo_r_nw, spamo_did, spamo_addr,
   spamo_data
   );
	`include "spam_defines.vh"

	input clk, rst_b;
	
	input                       spamo_valid;
	input                       spamo_r_nw;
	input      [SPAM_DID_HI:0]  spamo_did;
	input      [SPAM_ADDR_HI:0] spamo_addr;
	input      [SPAM_DATA_HI:0] spamo_data;
	
	output reg                  lcd__spami_busy_b = 0;
	output reg [SPAM_DATA_HI:0] lcd__spami_data = 'h0;
	
	output wire [3:0] lcd_db;
	output reg lcd_e = 0;
	output wire lcd_rnw;
	output wire lcd_rs;
	
	inout [35:0] control_vio;

	parameter DEBUG = "FALSE";
	
	reg                  lcd__spami_busy_b_next = 0;
	reg [SPAM_DATA_HI:0] lcd__spami_data_next = 'h0;
	
	reg [2:0] state = 0;
	reg [2:0] state_next = 0;
	
	reg [7:0] counter = 0;
	reg [7:0] counter_next = 0;
	reg [3:0] sample = 0;
	reg do_sample;
	
	wire decode = spamo_valid && (spamo_did == SPAM_DID_LCD);
	
	reg lcd_rs_l = 0;
	reg lcd_rnw_l = 0;
	reg [3:0] lcd_db_l = 0;

`ifdef verilator
	wire [3:0] lcd_db_in = 4'b0000;
	assign lcd_db[3:0] = lcd_rnw_l ? 4'bzzzz : lcd_db_l[3:0];
`else
//	wire [3:0] lcd_db_in;	/* i.e., in from the module */
//	IOBUF db_buf_7 (
//		.I(lcd_db_l[3]),
//		.O(lcd_db_in[3]),
//		.IO(lcd_db[3]),
//		.T(lcd_rnw_l)); /* OE_n */
//
//	IOBUF db_buf_6 (
//		.I(lcd_db_l[2]),
//		.O(lcd_db_in[2]),
//		.IO(lcd_db[2]),
//		.T(lcd_rnw_l)); /* OE_n */
//	
//	IOBUF db_buf_5 (
//		.I(lcd_db_l[1]),
//		.O(lcd_db_in[1]),
//		.IO(lcd_db[1]),
//		.T(lcd_rnw_l)); /* OE_n */
//	
//	IOBUF db_buf_4 (
//		.I(lcd_db_l[0]),
//		.O(lcd_db_in[0]),
//		.IO(lcd_db[0]),
//		.T(lcd_rnw_l)); /* OE_n */

	wire [3:0] lcd_db_in = 0;
	assign lcd_db[3:0] = lcd_db_l[3:0];
`endif

	
	always @(posedge clk or negedge rst_b)
	begin
		if (!rst_b) begin
			lcd__spami_busy_b <= 0;
			lcd__spami_data <= 0;
			state <= 0;
			counter <= 0;
			lcd_rs_l <= 0;
			lcd_rnw_l <= 0;
			lcd_db_l <= 0;
		end else begin
			lcd__spami_busy_b <= lcd__spami_busy_b_next;
			lcd__spami_data <= lcd__spami_data_next;
			state <= state_next;
			counter <= counter_next;
			
			if (decode) begin
				lcd_rs_l <= spamo_addr[2];
				lcd_rnw_l <= spamo_r_nw;
				lcd_db_l[3:0] <= spamo_data[3:0];
			end
			
			if (do_sample)
				sample <= lcd_db_in[3:0];
		end
	end
	
	assign lcd_rs = lcd_rs_l;
	assign lcd_rnw = lcd_rnw_l;

	always @(*)
	begin
		lcd__spami_busy_b_next = 0;
		lcd__spami_data_next = 'h0;
		
		lcd_e = 0;
		
		do_sample = 0;
		
		counter_next = counter;
		state_next = state;
		
		case (state)
		'd0: begin
			if (decode) begin
			`ifdef verilator
				$display("LCD: time %05d, decode, rnw %d, rs %d", $time, lcd_rnw, lcd_rs);
			`endif
				counter_next = 'd60;
				state_next = 'd1;
			end
		end
		'd1: begin /* setup time */
			if (counter == 'd0) begin
				counter_next = 'd90;
				state_next = 'd2;
			`ifdef verilator
				$display("LCD: time %05d, setup done", $time);
			`endif
			end else begin
				counter_next = counter_next - 1;
			end
		end
		'd2: begin /* enable time */
			lcd_e = 1;
			if (counter == 'd5)
				do_sample = 1;
			
			if (counter == 'd0) begin
				counter_next = 'd40;
				state_next = 'd3;
			`ifdef verilator
				$display("LCD: time %05d, enab done, da %x", $time, lcd_db);
			`endif
			end else begin
				counter_next = counter_next - 1;
			end
		end
		'd3: begin /* disable time */
			if (counter == 'd0) begin
				lcd__spami_busy_b_next = 1;
				lcd__spami_data_next = {28'h0, sample};
				state_next = 'd0;
			`ifdef verilator
				$display("LCD: time %05d, disab done", $time);
			`endif
			end else begin
				counter_next = counter_next - 1;
			end
		end
		endcase
	end
	
	generate
	if (DEBUG == "TRUE") begin: debug
		wire [35:0] control0, control1, control2;
		
		chipscope_icon icon (
			.CONTROL0(control0), // INOUT BUS [35:0]
			.CONTROL1(control1), // INOUT BUS [35:0]
			.CONTROL2(control2), // INOUT BUS [35:0]
			.CONTROL3(control_vio)  // INOUT BUS [35:0]
		);
		
		chipscope_ila ila0 (
			.CONTROL(control0), // INOUT BUS [35:0]
			.CLK(clk), // IN
			.TRIG0({rst_b, spamo_valid, spamo_r_nw, spamo_did[3:0],
			        spamo_addr[23:0], spamo_data[31:0],
			        lcd__spami_busy_b, lcd__spami_data[31:0],
			        lcd_db_in[3:0], lcd_e, lcd_rnw, lcd_rs, state[2:0],
			        counter[7:0], do_sample, sample[3:0], decode, lcd_rs_l,
			        lcd_rnw_l, lcd_db_l[3:0]})
		);
		
		chipscope_ila ila1 (
			.CONTROL(control1), // INOUT BUS [35:0]
			.CLK(clk), // IN
			.TRIG0(256'b0)
		);
		
		chipscope_ila ila2 (
			.CONTROL(control2), // INOUT BUS [35:0]
			.CLK(clk), // IN
			.TRIG0(256'b0)
		);
		
	end else begin: debug_tieoff
	
		assign control_vio = {36{1'bz}};
		
	end
	endgenerate

endmodule
