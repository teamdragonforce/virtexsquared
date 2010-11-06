module SPAM_SysACE(/*AUTOARG*/
   // Outputs
   sace__spami_busy_b, sace__spami_data, sace_mpa, sace_mpce_n,
   sace_mpwe_n, sace_mpoe_n,
   // Inouts
   sace_mpd, control_vio,
   // Inputs
   clk, rst_b, spamo_valid, spamo_r_nw, spamo_did, spamo_addr,
   spamo_data, sace_clk
   );

	`include "spam_defines.vh"

	input clk, rst_b;
	
	input                       spamo_valid;
	input                       spamo_r_nw;
	input      [SPAM_DID_HI:0]  spamo_did;
	input      [SPAM_ADDR_HI:0] spamo_addr;
	input      [SPAM_DATA_HI:0] spamo_data;
	
	output reg                  sace__spami_busy_b = 0;
	output reg [SPAM_DATA_HI:0] sace__spami_data = 'h0;
	
	input                       sace_clk;
	output wire [6:0]           sace_mpa;
	inout wire  [15:0]          sace_mpd;
	output wire                 sace_mpce_n;
	output reg                  sace_mpwe_n = 1;
	output reg                  sace_mpoe_n = 1;
	
	inout [35:0] control_vio;
	
	parameter DEBUG = "FALSE";
	
	wire [15:0] sace_mpd_rd;
	wire [15:0] sace_mpd_wr;
	
	IOBUF sace_mpd_buf [15:0] (
		.I(sace_mpd_wr),
		.O(sace_mpd_rd),
		.IO(sace_mpd),
		.T(sace_mpwe_n));

	/*** SPAM command queueing and clock domain transitioning ***/
	
	reg                  cur_request_cclk = 0;
	reg                  cur_r_nw_cclk = 0;
	reg [SPAM_DID_HI:0]  cur_did_cclk = 0;
	reg [SPAM_ADDR_HI:0] cur_addr_cclk = 0;
	reg [SPAM_DATA_HI:0] cur_wrdata_cclk = 0;
	
	reg                  completed_request_sclk = 0;
	reg                  completed_request_sclk_s = 0;
	reg                  completed_request_sclk_cclk = 0;
	reg                  completed_request_sclk_1a_cclk = 0;
	reg                  completed_request_sclk_2a_cclk = 0;
	
	reg [15:0]           sace_mpd_rd_l_sclk = 0;
	reg [15:0]           sace_mpd_rd_l_sclk_s = 0;
	reg [15:0]           sace_mpd_rd_l_sclk_cclk = 0;
	
	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			cur_request_cclk <= 0;
			cur_r_nw_cclk <= 0;
			cur_did_cclk <= 0;
			cur_addr_cclk <= 0;
			cur_wrdata_cclk <= 0;
			
			completed_request_sclk_s <= 0;
			completed_request_sclk_cclk <= 0;
			completed_request_sclk_1a_cclk <= 0;
			completed_request_sclk_2a_cclk <= 0;
			
			sace_mpd_rd_l_sclk_s <= 0;
			sace_mpd_rd_l_sclk_cclk <= 0;
			
			sace__spami_data <= 32'h0;
			sace__spami_busy_b <= 0;
		end else begin
			if (spamo_valid && (spamo_did == SPAM_DID_SACE)) begin
				cur_request_cclk <= ~cur_request_cclk;
				cur_r_nw_cclk <= spamo_r_nw;
				cur_did_cclk <= spamo_did;
				cur_addr_cclk <= spamo_addr;
				cur_wrdata_cclk <= spamo_data;
			end
			
			completed_request_sclk_s <= completed_request_sclk;
			completed_request_sclk_cclk <= completed_request_sclk_s;
			completed_request_sclk_1a_cclk <= completed_request_sclk_cclk;
			completed_request_sclk_2a_cclk <= completed_request_sclk_1a_cclk;
			
			sace_mpd_rd_l_sclk_s <= sace_mpd_rd_l_sclk;
			sace_mpd_rd_l_sclk_cclk <= sace_mpd_rd_l_sclk_s;
			
			if (completed_request_sclk_1a_cclk ^ completed_request_sclk_2a_cclk) begin
				sace__spami_data <= {16'h0000, sace_mpd_rd_l_sclk_cclk};
				sace__spami_busy_b <= 1;
			end else begin
				sace__spami_data <= 32'h0;
				sace__spami_busy_b <= 0;
			end
		end
	end
	
	reg [2:0] sace_clk_rst_b_sync = 0;
	wire sace_rst_b = sace_clk_rst_b_sync[2];
	always @(posedge sace_clk)
		sace_clk_rst_b_sync = {sace_clk_rst_b_sync[1:0], rst_b};
	
	reg                  cur_request_cclk_s = 0;
	reg                  cur_r_nw_cclk_s = 0;
	reg [SPAM_DID_HI:0]  cur_did_cclk_s = 0;
	reg [SPAM_ADDR_HI:0] cur_addr_cclk_s = 0;
	reg [SPAM_DATA_HI:0] cur_wrdata_cclk_s = 0;
	
	reg                  cur_request_cclk_sclk = 0;
	reg                  cur_r_nw_cclk_sclk = 0;
	reg [SPAM_DID_HI:0]  cur_did_cclk_sclk = 0;
	reg [SPAM_ADDR_HI:0] cur_addr_cclk_sclk = 0;
	reg [SPAM_DATA_HI:0] cur_wrdata_cclk_sclk = 0;
	
	reg                  cur_request_cclk_1a_sclk = 0;
	
	always @(posedge sace_clk or negedge sace_rst_b) begin
		if (!sace_rst_b) begin
			cur_request_cclk_s <= 0;
			cur_r_nw_cclk_s <= 0;
			cur_did_cclk_s <= 0;
			cur_addr_cclk_s <= 0;
			cur_wrdata_cclk_s <= 0;
			
			cur_request_cclk_sclk <= 0;
			cur_r_nw_cclk_sclk <= 0;
			cur_did_cclk_sclk <= 0;
			cur_addr_cclk_sclk <= 0;
			cur_wrdata_cclk_sclk <= 0;
			
			cur_request_cclk_1a_sclk <= 0;
		end else begin
			cur_request_cclk_s <= cur_request_cclk;
			cur_r_nw_cclk_s <= cur_r_nw_cclk;
			cur_did_cclk_s <= cur_did_cclk;
			cur_addr_cclk_s <= cur_addr_cclk;
			cur_wrdata_cclk_s <= cur_wrdata_cclk;
			
			cur_request_cclk_sclk <= cur_request_cclk_s;
			cur_r_nw_cclk_sclk <= cur_r_nw_cclk_s;
			cur_did_cclk_sclk <= cur_did_cclk_s;
			cur_addr_cclk_sclk <= cur_addr_cclk_s;
			cur_wrdata_cclk_sclk <= cur_wrdata_cclk_s;
			
			cur_request_cclk_1a_sclk <= cur_request_cclk_sclk;
		end
	end
	

	/*** SystemACE I/O control ***/
	
	assign sace_mpa = cur_addr_cclk_sclk[8:2];
	assign sace_mpd_wr = cur_wrdata_cclk_sclk[15:0];
	assign sace_mpce_n = completed_request_sclk != cur_request_cclk_1a_sclk;
	
	reg [1:0] state = 2'b00;
	
	always @(posedge sace_clk or negedge sace_rst_b)
		if (!sace_rst_b) begin
			completed_request_sclk <= 0;
			sace_mpd_rd_l_sclk <= 16'h0000;
			sace_mpoe_n <= 1;
			sace_mpoe_n <= 1;
			state <= 2'b00;
		end else begin
			if (completed_request_sclk != cur_request_cclk_1a_sclk) begin
				case ({cur_r_nw_cclk_sclk, state})
				3'b000: begin
					sace_mpwe_n <= 0;
					state <= 2'b01;
				end
				3'b001: begin
					sace_mpwe_n <= 1;
					state <= 2'b00;
					completed_request_sclk <= cur_request_cclk_1a_sclk;
				end
				3'b100: begin
					sace_mpoe_n <= 0;
					state <= 2'b01;
				end
				3'b101: begin
					sace_mpoe_n <= 1;
					state <= 2'b10;
				end
				3'b110: begin
					sace_mpd_rd_l_sclk <= sace_mpd_rd;
					state <= 2'b00;
					completed_request_sclk <= cur_request_cclk_1a_sclk;
				end
				endcase
			end
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
			.CLK(sace_clk), // IN
			.TRIG0({state[1:0], sace_mpce_n, sace_mpoe_n, sace_mpwe_n, sace_mpd_wr[15:0],
			        sace_mpa[6:0], sace_mpd_rd[15:0], completed_request_sclk, cur_request_cclk_1a_sclk,
			        cur_r_nw_cclk_sclk, sace_mpd_rd_l_sclk[15:0], cur_addr_cclk_sclk[9:0], cur_request_cclk_sclk,
			        sace_clk_rst_b_sync})
		);
		
		chipscope_ila ila1 (
			.CONTROL(control1), // INOUT BUS [35:0]
			.CLK(clk), // IN
			.TRIG0({spamo_valid, spamo_did[3:0], spamo_r_nw, cur_request_cclk, spamo_addr[15:0],
			        spamo_data[15:0], completed_request_sclk_1a_cclk, completed_request_sclk_2a_cclk,
			        sace_mpd_rd_l_sclk_cclk[15:0], sace__spami_data[15:0], sace__spami_busy_b,
			        rst_b})
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
