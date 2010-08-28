module CellularRAM(
	input clk,
	input [31:0] bus_addr,
	output wire [31:0] bus_rdata,
	input [31:0] bus_wdata,
	input bus_rd,
	input bus_wr,
	output wire bus_ready,
	
	output wire cr_nADV, cr_nCE, cr_nOE, cr_nWE, cr_CRE, cr_nLB, cr_nUB, cr_CLK,
	inout wire [15:0] cr_DQ,
	output wire [22:0] cr_A,
	output wire st_nCE
	);
	
	/* This module is mapped in physical memory from 0x80000000 to
	 * 0x80FFFFFF.  rdata and ready must be driven to zero if the
	 * address is not within the range of this module.
	 */
	wire decode = bus_addr[31:24] == 8'h80;
	assign cr_A = bus_addr[23:1];
	reg [22:0] cr_A_1a = 23'h7FFFFF;
	reg [22:0] cr_A_2a = 23'h7FFFFF;
	wire active = (decode && (bus_rd || bus_wr));
	reg active_1a = 0;
	reg active_2a = 0;
	
	always @(posedge clk)
	begin
		cr_A_1a <= cr_A;
		cr_A_2a <= cr_A_1a;
		active_1a <= active;
		active_2a <= active_1a;
	end
	
	assign bus_rdata = (bus_rd && decode) ? {16'h0000, cr_DQ} : 32'h0;
	assign cr_DQ = (bus_wr && decode) ? bus_wdata : 16'hzzzz;
	
	assign bus_ready = active && active_1a && active_2a && (cr_A_1a == cr_A) && (cr_A_2a == cr_A);
	
	assign st_nCE = 0;
	assign cr_nADV = ~decode;
	assign cr_nCE = ~active;
	assign cr_nOE = ~bus_rd;
	assign cr_nWE = ~bus_wr;
	assign cr_CRE = 0;
	assign cr_nLB = 0;
	assign cr_nUB = 0;
	assign cr_CLK = 0;
endmodule
