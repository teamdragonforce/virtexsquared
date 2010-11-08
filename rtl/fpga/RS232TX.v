module RS232TX(/*AUTOARG*/
   // Outputs
   serial_tx,
   // Inputs
   cclk, cclk_rst_b, sys_odata
   );

	input cclk;
	input cclk_rst_b;
	
	output reg serial_tx = 0;
	
	input [8:0] sys_odata;
	
	parameter CCLK_SPEED = 62500000;
	parameter BAUD_RATE = 57600;
	parameter DIV = (CCLK_SPEED / BAUD_RATE);
	
	reg [15:0] serial_div = 1;
	reg [3:0] tx_state = 4'b0000;
	
	wire sfif_full;
	wire sfif_empty;
	
	reg sfif_rd_en = 0;
	
	wire [7:0] curchar;
	
	Fifo sfif (.clk(cclk),
	           .rst_b(cclk_rst_b),
	           
	           .wr_en(sys_odata[8] & ~sfif_full),
	           .wr_dat(sys_odata[7:0]),
	           
	           .rd_en(sfif_rd_en),
	           .rd_dat(curchar),
	           
	           .full(sfif_full),
	           .empty(sfif_empty));
        defparam sfif.WIDTH = 8;
        defparam sfif.DEPTH = 256;
	
	always @(posedge cclk or negedge cclk_rst_b) begin
		if (!cclk_rst_b) begin
			serial_div <= 0;
			serial_tx <= 1;
			sfif_rd_en <= 0;
			tx_state <= 4'b0000;
		end else begin
			if (serial_div != DIV) begin
				serial_div <= serial_div + 1;
				sfif_rd_en <= 0;
			end else begin
				serial_div <= 0;
				case (tx_state)
				4'b0000: begin serial_tx <= sfif_empty;
				               sfif_rd_en <= ~sfif_empty;
				               tx_state <= sfif_empty ? 4'b0000 : 4'b0001;
				         end
				4'b0001: begin serial_tx <= curchar[0]; tx_state <= tx_state + 1; end
				4'b0010: begin serial_tx <= curchar[1]; tx_state <= tx_state + 1; end
				4'b0011: begin serial_tx <= curchar[2]; tx_state <= tx_state + 1; end
				4'b0100: begin serial_tx <= curchar[3]; tx_state <= tx_state + 1; end
				4'b0101: begin serial_tx <= curchar[4]; tx_state <= tx_state + 1; end
				4'b0110: begin serial_tx <= curchar[5]; tx_state <= tx_state + 1; end
				4'b0111: begin serial_tx <= curchar[6]; tx_state <= tx_state + 1; end
				4'b1000: begin serial_tx <= curchar[7]; tx_state <= tx_state + 1; end
				4'b1001: begin serial_tx <= 1'b1; tx_state <= 4'b0000; end
				endcase
			end
		end
	end
endmodule
