module Audio(/*AUTOARG*/
   // Outputs
   ac97_sdata_out, ac97_sync, ac97_reset_b, audio__fsabo_valid,
   audio__fsabo_mode, audio__fsabo_did, audio__fsabo_subdid,
   audio__fsabo_addr, audio__fsabo_len, audio__fsabo_data,
   audio__fsabo_mask, audio__spami_busy_b, audio__spami_data,
   // Inouts
   control_vio,
   // Inputs
   ac97_bitclk, ac97_sdata_in, fsabi_clk, fsabi_rst_b, fsabi_valid,
   fsabi_did, fsabi_subdid, fsabi_data, audio__fsabo_credit, cclk,
   cclk_rst_b, spamo_valid, spamo_r_nw, spamo_did, spamo_addr,
   spamo_data
   );
	`include "fsab_defines.vh"
	`include "spam_defines.vh"
	/* AC'97 */
	input              ac97_bitclk;
	input              ac97_sdata_in;
	output wire        ac97_sdata_out;
	output wire        ac97_sync;
	output reg         ac97_reset_b = 1;

	/* FSAB */
	input fsabi_clk;
	input fsabi_rst_b;
	input fsabi_valid;
	input [FSAB_DID_HI:0] fsabi_did;
	input [FSAB_DID_HI:0] fsabi_subdid;
	input [FSAB_DATA_HI:0] fsabi_data;

	output audio__fsabo_valid;
	output [FSAB_REQ_HI:0] audio__fsabo_mode;
	output [FSAB_DID_HI:0] audio__fsabo_did;
	output [FSAB_DID_HI:0] audio__fsabo_subdid;
	output [FSAB_ADDR_HI:0] audio__fsabo_addr;
	output [FSAB_LEN_HI:0] audio__fsabo_len;
	output [FSAB_DATA_HI:0] audio__fsabo_data;
	output [FSAB_MASK_HI:0] audio__fsabo_mask;
	input audio__fsabo_credit;

	/* SPAM */
	input cclk;
	input cclk_rst_b;
	input spamo_valid;
	input spamo_r_nw;
	input [SPAM_DID_HI:0] spamo_did;
	input [SPAM_ADDR_HI:0] spamo_addr;
	input [SPAM_DATA_HI:0] spamo_data;
	output audio__spami_busy_b;
	output [SPAM_DATA_HI:0] audio__spami_data;

	inout [35:0] control_vio;

	wire        ac97_out_slot5_valid = 0;
	wire [19:0] ac97_out_slot5 = 'h0;
	wire        ac97_out_slot6_valid = 0;
	wire [19:0] ac97_out_slot6 = 'h0;
	wire        ac97_out_slot7_valid = 0;
	wire [19:0] ac97_out_slot7 = 'h0;
	wire        ac97_out_slot8_valid = 0;
	wire [19:0] ac97_out_slot8 = 'h0;
	wire        ac97_out_slot9_valid = 0;
	wire [19:0] ac97_out_slot9 = 'h0;
	wire        ac97_out_slot10_valid = 0;
	wire [19:0] ac97_out_slot10 = 'h0;
	wire        ac97_out_slot11_valid = 0;
	wire [19:0] ac97_out_slot11 = 'h0;
	wire        ac97_out_slot12_valid = 0;
	wire [19:0] ac97_out_slot12 = 'h0;

	/*AUTOWIRE*/
	// Beginning of automatic wires (for undeclared instantiated-module outputs)
	wire [19:0]	ac97_out_slot1;		// From conf of AC97Conf.v
	wire		ac97_out_slot1_valid;	// From conf of AC97Conf.v
	wire [19:0]	ac97_out_slot2;		// From conf of AC97Conf.v
	wire		ac97_out_slot2_valid;	// From conf of AC97Conf.v
	wire		ac97_strobe;		// From link of ACLink.v
	wire [63:0]	data;			// From audio_dma of SimpleDMAReadController.v
	wire		data_ready;		// From audio_dma of SimpleDMAReadController.v
	wire		fifo_empty;		// From audio_dma of SimpleDMAReadController.v
	// End of automatics

	reg         ac97_out_slot3_valid = 0;
	reg         ac97_out_slot4_valid = 0;
	reg         secondhalf = 1;
	wire        request = secondhalf && !fifo_empty && ac97_strobe;

	wire [15:0] actrl_master_volume   = 16'h0000;
	wire [15:0] actrl_mic_volume      = 16'h8808;
	wire [15:0] actrl_line_in_volume  = 16'h8808;
	wire [15:0] actrl_cd_volume       = 16'h8808;
	wire [15:0] actrl_pcm_volume      = 16'h0808;
	wire [15:0] actrl_record_select   = 16'h0000;
	wire [15:0] actrl_record_gain     = 16'h8000;

	wire [19:0] ac97_out_slot3 = {secondhalf ? data[47:32] : data[15:0], 4'b0};
	wire [19:0] ac97_out_slot4 = {secondhalf ? data[63:48] : data[31:16], 4'b0};

	reg core_aclk_rst_b_1 = 1;
	reg audio_rst_b = 1;
	always @(posedge ac97_bitclk) begin
		core_aclk_rst_b_1 <= cclk_rst_b;
		audio_rst_b <= core_aclk_rst_b_1;
	end

	always @(posedge ac97_bitclk or negedge audio_rst_b) begin
		if (!audio_rst_b) begin
			ac97_out_slot3_valid <= 0;
			ac97_out_slot4_valid <= 0;
			secondhalf <= 1;
		end
		else if (ac97_strobe) begin
			if (!secondhalf) begin
				ac97_out_slot3_valid <= ac97_out_slot3_valid;
				ac97_out_slot4_valid <= ac97_out_slot4_valid;
			end
			else begin
				if (!fifo_empty) begin
					ac97_out_slot3_valid <= 1;
					ac97_out_slot4_valid <= 1;
				end
				else begin
					ac97_out_slot3_valid <= 0;
					ac97_out_slot4_valid <= 0;
				end
			end
			secondhalf <= !secondhalf;
		end
	end

	/* SimpleDMAReadController AUTO_TEMPLATE(
	                        .target_clk(ac97_bitclk),
	                        .target_rst_b(audio_rst_b),
	                        .dmac__fsabo_valid(audio__fsabo_valid),
	                        .dmac__fsabo_mode(audio__fsabo_mode),
	                        .dmac__fsabo_did(audio__fsabo_did),
	                        .dmac__fsabo_subdid(audio__fsabo_subdid),
	                        .dmac__fsabo_addr(audio__fsabo_addr),
	                        .dmac__fsabo_len(audio__fsabo_len),
	                        .dmac__fsabo_data(audio__fsabo_data),
	                        .dmac__fsabo_mask(audio__fsabo_mask),
	                        .dmac__spami_busy_b(audio__spami_busy_b),
	                        .dmac__spami_data(audio__spami_data),
	                        .dmac__fsabo_credit(audio__fsabo_credit),
	                        .fifo_empty(fifo_empty),
                                );
         */	
	SimpleDMAReadController audio_dma(/*AUTOINST*/
					  // Outputs
					  .dmac__fsabo_valid	(audio__fsabo_valid), // Templated
					  .dmac__fsabo_mode	(audio__fsabo_mode), // Templated
					  .dmac__fsabo_did	(audio__fsabo_did), // Templated
					  .dmac__fsabo_subdid	(audio__fsabo_subdid), // Templated
					  .dmac__fsabo_addr	(audio__fsabo_addr), // Templated
					  .dmac__fsabo_len	(audio__fsabo_len), // Templated
					  .dmac__fsabo_data	(audio__fsabo_data), // Templated
					  .dmac__fsabo_mask	(audio__fsabo_mask), // Templated
					  .data			(data[63:0]),
					  .data_ready		(data_ready),
					  .fifo_empty		(fifo_empty),	 // Templated
					  .dmac__spami_busy_b	(audio__spami_busy_b), // Templated
					  .dmac__spami_data	(audio__spami_data), // Templated
					  // Inputs
					  .cclk			(cclk),
					  .cclk_rst_b		(cclk_rst_b),
					  .dmac__fsabo_credit	(audio__fsabo_credit), // Templated
					  .fsabi_clk		(fsabi_clk),
					  .fsabi_rst_b		(fsabi_rst_b),
					  .fsabi_valid		(fsabi_valid),
					  .fsabi_did		(fsabi_did[FSAB_DID_HI:0]),
					  .fsabi_subdid		(fsabi_subdid[FSAB_DID_HI:0]),
					  .fsabi_data		(fsabi_data[FSAB_DATA_HI:0]),
					  .spamo_valid		(spamo_valid),
					  .spamo_r_nw		(spamo_r_nw),
					  .spamo_did		(spamo_did[SPAM_DID_HI:0]),
					  .spamo_addr		(spamo_addr[SPAM_ADDR_HI:0]),
					  .spamo_data		(spamo_data[SPAM_DATA_HI:0]),
					  .target_clk		(ac97_bitclk),	 // Templated
					  .target_rst_b		(audio_rst_b),	 // Templated
					  .request		(request));
	defparam audio_dma.FIFO_DEPTH = 512;
	defparam audio_dma.FSAB_DID = FSAB_DID_AUDIO;
	defparam audio_dma.FSAB_SUBDID = FSAB_SUBDID_AUDIO;
	defparam audio_dma.DEFAULT_ADDR = 31'h00000000;
	defparam audio_dma.DEFAULT_LEN = 31'h00000000;
	defparam audio_dma.SPAM_DID = SPAM_DID_AUDIO;

	ACLink link(/*AUTOINST*/
		    // Outputs
		    .ac97_sdata_out	(ac97_sdata_out),
		    .ac97_sync		(ac97_sync),
		    .ac97_strobe	(ac97_strobe),
		    // Inputs
		    .ac97_bitclk	(ac97_bitclk),
		    .ac97_sdata_in	(ac97_sdata_in),
		    .ac97_out_slot1	(ac97_out_slot1[19:0]),
		    .ac97_out_slot1_valid(ac97_out_slot1_valid),
		    .ac97_out_slot2	(ac97_out_slot2[19:0]),
		    .ac97_out_slot2_valid(ac97_out_slot2_valid),
		    .ac97_out_slot3	(ac97_out_slot3[19:0]),
		    .ac97_out_slot3_valid(ac97_out_slot3_valid),
		    .ac97_out_slot4	(ac97_out_slot4[19:0]),
		    .ac97_out_slot4_valid(ac97_out_slot4_valid),
		    .ac97_out_slot5	(ac97_out_slot5[19:0]),
		    .ac97_out_slot5_valid(ac97_out_slot5_valid),
		    .ac97_out_slot6	(ac97_out_slot6[19:0]),
		    .ac97_out_slot6_valid(ac97_out_slot6_valid),
		    .ac97_out_slot7	(ac97_out_slot7[19:0]),
		    .ac97_out_slot7_valid(ac97_out_slot7_valid),
		    .ac97_out_slot8	(ac97_out_slot8[19:0]),
		    .ac97_out_slot8_valid(ac97_out_slot8_valid),
		    .ac97_out_slot9	(ac97_out_slot9[19:0]),
		    .ac97_out_slot9_valid(ac97_out_slot9_valid),
		    .ac97_out_slot10	(ac97_out_slot10[19:0]),
		    .ac97_out_slot10_valid(ac97_out_slot10_valid),
		    .ac97_out_slot11	(ac97_out_slot11[19:0]),
		    .ac97_out_slot11_valid(ac97_out_slot11_valid),
		    .ac97_out_slot12	(ac97_out_slot12[19:0]),
		    .ac97_out_slot12_valid(ac97_out_slot12_valid));

	AC97Conf conf(/*AUTOINST*/
		      // Outputs
		      .ac97_out_slot1	(ac97_out_slot1[19:0]),
		      .ac97_out_slot1_valid(ac97_out_slot1_valid),
		      .ac97_out_slot2	(ac97_out_slot2[19:0]),
		      .ac97_out_slot2_valid(ac97_out_slot2_valid),
		      // Inputs
		      .ac97_bitclk	(ac97_bitclk),
		      .rst_b		(rst_b),
		      .ac97_strobe	(ac97_strobe),
		      .actrl_master_volume(actrl_master_volume[15:0]),
		      .actrl_mic_volume	(actrl_mic_volume[15:0]),
		      .actrl_line_in_volume(actrl_line_in_volume[15:0]),
		      .actrl_cd_volume	(actrl_cd_volume[15:0]),
		      .actrl_pcm_volume	(actrl_pcm_volume[15:0]),
		      .actrl_record_select(actrl_record_select[15:0]),
		      .actrl_record_gain(actrl_record_gain[15:0]));

	parameter DEBUG = "FALSE";

	generate
	if (DEBUG == "TRUE") begin: debug
		wire [35:0] control0, control1, control2;
		chipscope_icon icon (
			.CONTROL0(control0), 
			.CONTROL1(control1),
			.CONTROL2(control2),
			.CONTROL3(control_vio)
		);

		chipscope_ila ila0 (
			.CONTROL(control0),	
			.CLK(ac97_bitclk), // IN
			.TRIG0({0, ac97_sdata_out, ac97_sync, ac97_reset_b, ac97_strobe, ac97_sdata_in,
			        ac97_out_slot1[19:0], ac97_out_slot1_valid, ac97_out_slot2[19:0], ac97_out_slot2_valid,
			        ac97_out_slot3[19:0], ac97_out_slot3_valid, ac97_out_slot4[19:0], ac97_out_slot4_valid,
			        secondhalf, request, data[63:0], data_ready, fifo_empty})
		);

		chipscope_ila ila1 (
			.CONTROL(control1),	
			.CLK(cclk), // IN
			.TRIG0(256'b0)
		);

		chipscope_ila ila2 (
			.CONTROL(control2),	
			.CLK(fbclk), // IN
			.TRIG0(256'b0)
		);

	end else begin: debug_tieoff
		assign control_vio = {36{1'bz}};
	end
	endgenerate
endmodule
//
// Local Variables:
// verilog-library-directories:("." "../core" "../fsab" "../spam" "../fsab/sim" "../util")
// End:
