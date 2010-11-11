module AC97Conf(/*AUTOARG*/
   // Outputs
   ac97_out_slot1, ac97_out_slot1_valid, ac97_out_slot2,
   ac97_out_slot2_valid,
   // Inputs
   ac97_bitclk, rst_b, ac97_strobe, actrl_master_volume,
   actrl_mic_volume, actrl_line_in_volume, actrl_cd_volume,
   actrl_pcm_volume, actrl_record_select, actrl_record_gain
   );

	/* AC97 */
	input              ac97_bitclk;
	input              rst_b;
	input              ac97_strobe;
	output wire [19:0] ac97_out_slot1;
	output wire        ac97_out_slot1_valid;
	output wire [19:0] ac97_out_slot2;
	output wire        ac97_out_slot2_valid;

	/* Configuration Input */
	input [15:0] actrl_master_volume;
	input [15:0] actrl_mic_volume;
	input [15:0] actrl_line_in_volume;
	input [15:0] actrl_cd_volume;
	input [15:0] actrl_pcm_volume;
	input [15:0] actrl_record_select;
	input [15:0] actrl_record_gain;
	
	reg        ac97_out_slot1_valid_r;
	reg [19:0] ac97_out_slot1_r;
	reg        ac97_out_slot2_valid_r;
	reg [19:0] ac97_out_slot2_r;
	
	assign ac97_out_slot1 = ac97_out_slot1_r;
	assign ac97_out_slot1_valid = ac97_out_slot1_valid_r;
	assign ac97_out_slot2 = ac97_out_slot2_r;
	assign ac97_out_slot2_valid = ac97_out_slot2_valid_r;

	reg [3:0] state = 4'h0;
	reg [3:0] nextstate = 4'h0;
	always @(*) begin
		ac97_out_slot1_valid_r = 0;
		ac97_out_slot1_r = 20'hxxxxx;
		ac97_out_slot2_valid_r = 0;
		ac97_out_slot2_r = 20'hxxxxx;
		nextstate = state;
		case (state)
		4'h0: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b0 /* write */, 7'h00 /* reset */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {16'h0, 4'h0};
			nextstate = 4'h1;
		end
		4'h1: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b0 /* write */, 7'h02 /* master volume */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {actrl_master_volume, 4'b0};
			nextstate = 4'h2;
		end
		4'h2: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b0 /* write */, 7'h0E /* mic volume */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {actrl_mic_volume, 4'b0};
			nextstate = 4'h3;
		end
		4'h3: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b0 /* write */, 7'h10 /* line in volume */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {actrl_line_in_volume, 4'b0};
			nextstate = 4'h4;
		end
		4'h4: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b0 /* write */, 7'h12 /* cd volume */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {actrl_cd_volume, 4'b0};
			nextstate = 4'h5;
		end
		4'h5: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b0 /* write */, 7'h18 /* pcm volume */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {actrl_pcm_volume, 4'b0};
			nextstate = 4'h6;
		end
		4'h6: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b0 /* write */, 7'h1A /* record select */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {actrl_record_select, 4'b0};
			nextstate = 4'h7;
		end
		4'h7: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b0 /* write */, 7'h1C /* record gain */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {actrl_record_gain, 4'b0};
			nextstate = 4'h8;
		end
		4'h8: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b1 /* read */, 7'h7C /* vendor id 1 */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = 20'h00000;
			nextstate = 4'h9;
		end
		4'h9: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b1 /* read */, 7'h7C /* vendor id 2 */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = 20'h00000;
			nextstate = 4'h1;
		end
		endcase
	end
	
	always @(posedge ac97_bitclk or negedge rst_b) begin
		if (!rst_b) begin
			state <= 0;
		end
		else if (ac97_strobe) begin
			state <= nextstate;
		end
	end
endmodule
