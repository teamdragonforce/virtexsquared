module BusArbiter(
	input [7:0] bus_req,
	output reg [7:0] bus_ack);

	always @(*)
		casez (bus_req)
		8'b00000000: bus_ack = 8'b00000000;
		8'b???????1: bus_ack = 8'b00000001;
		8'b??????10: bus_ack = 8'b00000010;
		8'b?????100: bus_ack = 8'b00000100;
		8'b????1000: bus_ack = 8'b00001000;
		8'b???10000: bus_ack = 8'b00010000;
		8'b??100000: bus_ack = 8'b00100000;
		8'b?1000000: bus_ack = 8'b01000000;
		8'b10000000: bus_ack = 8'b10000000;
		endcase
endmodule
