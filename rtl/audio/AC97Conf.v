module AC97Conf(
	input              ac97_bitclk,
	input              ac97_strobe,
	output wire [19:0] ac97_out_slot1,
	output wire        ac97_out_slot1_valid,
	output wire [19:0] ac97_out_slot2,
	output wire        ac97_out_slot2_valid
	);
	
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
			ac97_out_slot2_r = {16'h0 /* unmuted, full volume */, 4'h0};
			nextstate = 4'h2;
		end
		4'h2: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b0 /* write */, 7'h18 /* pcm volume */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {16'h0808 /* unmuted, 0dB */, 4'h0};
			nextstate = 4'h3;
		end
		4'h3: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b1 /* read */, 7'h26 /* power status */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {20'h00000};
			nextstate = 4'h4;
		end
		4'h4: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b1 /* read */, 7'h7c /* vid0 */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {20'h00000};
			nextstate = 4'h5;
		end
		4'h5: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b1 /* read */, 7'h7e /* vid1 */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {20'h00000};
			nextstate = 4'h3;
		end
		endcase
	end
	
	always @(posedge ac97_bitclk)
		if (ac97_strobe)
			state <= nextstate;
endmodule
