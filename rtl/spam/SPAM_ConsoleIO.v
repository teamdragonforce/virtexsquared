module SPAM_ConsoleIO(
	input clk,
	
	input                       spamo_valid,
	input                       spamo_r_nw,
	input      [SPAM_DID_HI:0]  spamo_did,
	input      [SPAM_ADDR_HI:0] spamo_addr,
	input      [SPAM_DATA_HI:0] spamo_data,
	
	output reg                  cio__spami_busy_b = 0,
	output reg [SPAM_DATA_HI:0] cio__spami_data = 'h0,
	
	output reg [8:0] sys_odata = 0,
	input [8:0] sys_idata,
	output reg sys_tookdata = 0
);

`include "spam_defines.vh"
	
	reg towrite = 0;
	reg [7:0] data = 0;
	reg [8:0] indata = 0;	/* High bit is if data is present. */
	reg didread = 0;
	
	reg                  cio__spami_busy_b_next = 0;
	reg [SPAM_DATA_HI:0] cio__spami_data_next = 'h0;
	
	always @(*)
	begin
		towrite = 0;
		data = 8'hxx;
		didread = 0;

		cio__spami_busy_b_next = 0;
		cio__spami_data_next = 'h0;
		
		if (spamo_valid && (spamo_did == SPAM_DID_CONSOLE) && !spamo_r_nw)
		begin
			cio__spami_busy_b_next = 1;
			cio__spami_data_next = 'hx;
			
			towrite = 1;
			data = spamo_data[7:0];
		end else if (spamo_valid && (spamo_did == SPAM_DID_CONSOLE) && spamo_r_nw)
		begin
			cio__spami_busy_b_next = 1;
			cio__spami_data_next = {23'h0, indata[8:0]};
			
			$display("CONSOLE: read: spamo_addr %x", spamo_addr);
			didread = (spamo_addr == 0);
		end
	end
	
	always @(posedge clk)
	begin
		cio__spami_busy_b <= cio__spami_busy_b_next;
		cio__spami_data <= cio__spami_data_next;
	end
	
`ifdef verilator	
	always @(posedge clk)
		if (towrite)
			$c("{extern void term_output(unsigned char d); term_output(",data,");}");
		else if (didread || !indata[8])
			indata <= $c("({extern unsigned int term_input(); term_input();})");
`else
	always @(posedge clk)
	begin
		sys_odata <= {towrite,data};
		if (didread || !indata[8])
		begin
			indata <= sys_idata;
			sys_tookdata <= 1;
		end else
			sys_tookdata <= 0;
	end
`endif
endmodule
