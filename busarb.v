module BusArbiter(
	input [7:0] bus_req,
	output reg [7:0] bus_ack);

	always @(*)
		casex (bus_req)
		8'b00000000: bus_ack <= 8'b00000000;
		8'bxxxxxxx1: bus_ack <= 8'b00000001;
		8'bxxxxxx10: bus_ack <= 8'b00000010;
		8'bxxxxx100: bus_ack <= 8'b00000100;
		8'bxxxx1000: bus_ack <= 8'b00001000;
		8'bxxx10000: bus_ack <= 8'b00010000;
		8'bxx100000: bus_ack <= 8'b00100000;
		8'bx1000000: bus_ack <= 8'b01000000;
		8'b10000000: bus_ack <= 8'b10000000;
		endcase
endmodule
