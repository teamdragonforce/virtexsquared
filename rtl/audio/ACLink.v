module ACLink(
	input        ac97_bitclk,
	input        ac97_sdata_in,
	output wire  ac97_sdata_out,
	output wire  ac97_sync,
	
	output wire  ac97_strobe,
	
	input [19:0] ac97_out_slot1,
	input        ac97_out_slot1_valid,
	input [19:0] ac97_out_slot2,
	input        ac97_out_slot2_valid,
	input [19:0] ac97_out_slot3,
	input        ac97_out_slot3_valid,
	input [19:0] ac97_out_slot4,
	input        ac97_out_slot4_valid,
	input [19:0] ac97_out_slot5,
	input        ac97_out_slot5_valid,
	input [19:0] ac97_out_slot6,
	input        ac97_out_slot6_valid,
	input [19:0] ac97_out_slot7,
	input        ac97_out_slot7_valid,
	input [19:0] ac97_out_slot8,
	input        ac97_out_slot8_valid,
	input [19:0] ac97_out_slot9,
	input        ac97_out_slot9_valid,
	input [19:0] ac97_out_slot10,
	input        ac97_out_slot10_valid,
	input [19:0] ac97_out_slot11,
	input        ac97_out_slot11_valid,
	input [19:0] ac97_out_slot12,
	input        ac97_out_slot12_valid
	);
	
	// We may want to make this into a state machine eventually.
	reg [7:0] curbit = 8'h0;	// Contains the bit currently on the bus.
	
	reg [255:0] inbits = 256'h0;
	reg [255:0] latched_inbits;
	
	/* Spec sez: rising edge should be in the middle of the final bit of
	 * the last slot, and the falling edge should be in the middle of
	 * the final bit of the TAG slot.
	 */
	assign ac97_sync = (curbit == 255) || (curbit < 15); 
	
	/* The outside world is permitted to read our latched data on the
	 * rising edge after bit 0 is transmitted.  Bit FF will have been
	 * latched on its falling edge, which means that on the rising edge
	 * that still contains bit FF, the "us to outside world" flipflops
	 * will have been triggered.  Given that, by the rising edge that
	 * contains bit 0, those flip-flops will have data.  So, the outside
	 * world strobe will be high on the rising edge that contains bit 0.
	 *
	 * Additionally, this strobe controls when the outside world will
	 * strobe new data into us.  The rising edge will latch new data
	 * into our inputs.  This data, in theory, will show up in time for
	 * the falling edge of the bit clock for big 01.
	 *
	 * NOTE: We need UCF timing constraints with setup times to make
	 * sure this happens!
	 */	 
	assign ac97_strobe = (curbit == 8'h00);
	
	/* The internal strobe for the output flip-flops needs to happen on
	 * the rising edge that still contains bit FF.
	 */
	always @(posedge ac97_bitclk) begin
		if (curbit == 8'hFF) begin
			latched_inbits <= inbits;
		end
		curbit <= curbit + 1;
	end
	
	always @(negedge ac97_bitclk)
		inbits[curbit] <= ac97_sdata_in;
	
	/* Bit order is reversed; msb of tag sent first. */
	wire [0:255] outbits = { /* TAG */
	                         1'b1,
	                         ac97_out_slot1_valid,
	                         ac97_out_slot2_valid,
	                         ac97_out_slot3_valid,
	                         ac97_out_slot4_valid,
	                         ac97_out_slot5_valid,
	                         ac97_out_slot6_valid,
	                         ac97_out_slot7_valid,
	                         ac97_out_slot8_valid,
	                         ac97_out_slot9_valid,
	                         ac97_out_slot10_valid,
	                         ac97_out_slot11_valid,
	                         ac97_out_slot12_valid,
	                         3'b000,
	                         /* and then time slots */
	                         ac97_out_slot1_valid ? ac97_out_slot1 : 20'h0,
	                         ac97_out_slot2_valid ? ac97_out_slot2 : 20'h0,
	                         ac97_out_slot3_valid ? ac97_out_slot3 : 20'h0,
	                         ac97_out_slot4_valid ? ac97_out_slot4 : 20'h0,
	                         ac97_out_slot5_valid ? ac97_out_slot5 : 20'h0,
	                         ac97_out_slot6_valid ? ac97_out_slot6 : 20'h0,
	                         ac97_out_slot7_valid ? ac97_out_slot7 : 20'h0,
	                         ac97_out_slot8_valid ? ac97_out_slot8 : 20'h0,
	                         ac97_out_slot9_valid ? ac97_out_slot9 : 20'h0,
	                         ac97_out_slot10_valid ? ac97_out_slot10 : 20'h0,
	                         ac97_out_slot11_valid ? ac97_out_slot11 : 20'h0,
	                         ac97_out_slot12_valid ? ac97_out_slot12 : 20'h0
	                         };
	
	/* Spec sez: should transition shortly after the rising edge.  In
	 * the end, we probably want to flop this to guarantee that (or set
	 * up UCF constraints as mentioned above).
	 */
	assign ac97_sdata_out = outbits[curbit];
endmodule
