module System(/*AUTOARG*/
   // Outputs
   ddr2_a, ddr2_ba, ddr2_cas_n, ddr2_ck, ddr2_ck_n, ddr2_cke,
   ddr2_cs_n, ddr2_dm, ddr2_odt, ddr2_ras_n, ddr2_we_n, leds,
   // Inouts
   ddr2_dq, ddr2_dqs, ddr2_dqs_n,
   // Inputs
   clk200_n, clk200_p, sys_clk_n, sys_clk_p, sys_rst_n, corerst_btn
   );

	`include "memory_defines.vh"

	/* Ok, this autoinout thing has to go. */
	
	// Beginning of automatic inouts (from unused autoinst inouts)
	inout [DQ_WIDTH-1:0] ddr2_dq;		// To/From mem of FSABMemory.v
	inout [DQS_WIDTH-1:0] ddr2_dqs;		// To/From mem of FSABMemory.v
	inout [DQS_WIDTH-1:0] ddr2_dqs_n;	// To/From mem of FSABMemory.v
	// End of automatics
	// Beginning of automatic inputs (from unused autoinst inputs)
	input		clk200_n;		// To mem of FSABMemory.v
	input		clk200_p;		// To mem of FSABMemory.v
	input		sys_clk_n;		// To mem of FSABMemory.v
	input		sys_clk_p;		// To mem of FSABMemory.v
	input		sys_rst_n;		// To mem of FSABMemory.v
	input           corerst_btn;
	// End of automatics
	// Beginning of automatic outputs (from unused autoinst outputs)
	output [ROW_WIDTH-1:0] ddr2_a;		// From mem of FSABMemory.v
	output [BANK_WIDTH-1:0] ddr2_ba;	// From mem of FSABMemory.v
	output		ddr2_cas_n;		// From mem of FSABMemory.v
	output [CLK_WIDTH-1:0] ddr2_ck;		// From mem of FSABMemory.v
	output [CLK_WIDTH-1:0] ddr2_ck_n;	// From mem of FSABMemory.v
	output [CKE_WIDTH-1:0] ddr2_cke;	// From mem of FSABMemory.v
	output [CS_WIDTH-1:0] ddr2_cs_n;	// From mem of FSABMemory.v
	output [DM_WIDTH-1:0] ddr2_dm;		// From mem of FSABMemory.v
	output [ODT_WIDTH-1:0] ddr2_odt;	// From mem of FSABMemory.v
	output		ddr2_ras_n;		// From mem of FSABMemory.v
	output		ddr2_we_n;		// From mem of FSABMemory.v
	output [7:0] leds;
	// End of automatics

`include "fsab_defines.vh"
`include "spam_defines.vh"

	/*AUTOWIRE*/
	// Beginning of automatic wires (for undeclared instantiated-module outputs)
	wire		fclk_mem_rst;		// From mem of FSABMemory.v
	wire [FSAB_DATA_HI:0] fsabi_data;	// From mem of FSABMemory.v
	wire [FSAB_DID_HI:0] fsabi_did;		// From mem of FSABMemory.v
	wire [FSAB_DID_HI:0] fsabi_subdid;	// From mem of FSABMemory.v
	wire		fsabi_valid;		// From mem of FSABMemory.v
	wire [FSAB_ADDR_HI:0] fsabo_addr;	// From tb of tb_state_machine.v
	wire		fsabo_credit;		// From mem of FSABMemory.v
	wire [FSAB_DATA_HI:0] fsabo_data;	// From tb of tb_state_machine.v
	wire [FSAB_DID_HI:0] fsabo_did;		// From tb of tb_state_machine.v
	wire [FSAB_LEN_HI:0] fsabo_len;		// From tb of tb_state_machine.v
	wire [FSAB_MASK_HI:0] fsabo_mask;	// From tb of tb_state_machine.v
	wire [FSAB_REQ_HI:0] fsabo_mode;	// From tb of tb_state_machine.v
	wire [FSAB_DID_HI:0] fsabo_subdid;	// From tb of tb_state_machine.v
	wire		fsabo_valid;		// From tb of tb_state_machine.v
	wire		phy_init_done;		// From mem of FSABMemory.v
	wire		tb_done;		// From tb of tb_state_machine.v
	// End of automatics

	wire [35:0] control_vio;
	
	/*** Clock and reset synchronization ***/
	
	wire fclk;
	wire fclk_rst_b;

	reg [26:0] fclk_counter = 0;
	wire fclk_div = fclk_counter[26];
	always @(posedge fclk)
		fclk_counter <= fclk_counter + 1;

	assign fclk_rst_b = (~fclk_mem_rst) & (phy_init_done);
	
	/*** Rest of the system (c.c) ***/
	
	chipscope_ila vio (
		.CONTROL(control_vio), // INOUT BUS [35:0]
		.CLK(cclk), // IN
		.TRIG0({0}) // IN BUS [255:0]
	);
	
	/* State machine lives on fclk and fclk_rst_b */
	/* generates fsabo_valid, fsabo_mode, fsabo_subdid, fsabo_did, fsabo_addr, fsabo_len, fsabo_data, fsabo_mask */
	tb_state_machine tb(/*AUTOINST*/
			    // Outputs
			    .fsabo_valid	(fsabo_valid),
			    .fsabo_mode		(fsabo_mode[FSAB_REQ_HI:0]),
			    .fsabo_did		(fsabo_did[FSAB_DID_HI:0]),
			    .fsabo_subdid	(fsabo_subdid[FSAB_DID_HI:0]),
			    .fsabo_addr		(fsabo_addr[FSAB_ADDR_HI:0]),
			    .fsabo_len		(fsabo_len[FSAB_LEN_HI:0]),
			    .fsabo_data		(fsabo_data[FSAB_DATA_HI:0]),
			    .fsabo_mask		(fsabo_mask[FSAB_MASK_HI:0]),
			    .tb_done		(tb_done),
			    // Inputs
			    .fclk		(fclk),
			    .fclk_rst_b		(fclk_rst_b),
			    .corerst_btn	(corerst_btn),
			    .fsabo_credit	(fsabo_credit));
	
	/* FSABMemory AUTO_TEMPLATE (
		.clk0_tb(fclk),
		.rst0_tb(fclk_mem_rst),
	); */
	FSABMemory mem(
		/*AUTOINST*/
		       // Outputs
		       .ddr2_a		(ddr2_a[ROW_WIDTH-1:0]),
		       .ddr2_ba		(ddr2_ba[BANK_WIDTH-1:0]),
		       .ddr2_cas_n	(ddr2_cas_n),
		       .ddr2_ck		(ddr2_ck[CLK_WIDTH-1:0]),
		       .ddr2_ck_n	(ddr2_ck_n[CLK_WIDTH-1:0]),
		       .ddr2_cke	(ddr2_cke[CKE_WIDTH-1:0]),
		       .ddr2_cs_n	(ddr2_cs_n[CS_WIDTH-1:0]),
		       .ddr2_dm		(ddr2_dm[DM_WIDTH-1:0]),
		       .ddr2_odt	(ddr2_odt[ODT_WIDTH-1:0]),
		       .ddr2_ras_n	(ddr2_ras_n),
		       .ddr2_we_n	(ddr2_we_n),
		       .phy_init_done	(phy_init_done),
		       .clk0_tb		(fclk),			 // Templated
		       .rst0_tb		(fclk_mem_rst),		 // Templated
		       .fsabo_credit	(fsabo_credit),
		       .fsabi_valid	(fsabi_valid),
		       .fsabi_did	(fsabi_did[FSAB_DID_HI:0]),
		       .fsabi_subdid	(fsabi_subdid[FSAB_DID_HI:0]),
		       .fsabi_data	(fsabi_data[FSAB_DATA_HI:0]),
		       // Inouts
		       .ddr2_dq		(ddr2_dq[DQ_WIDTH-1:0]),
		       .ddr2_dqs	(ddr2_dqs[DQS_WIDTH-1:0]),
		       .ddr2_dqs_n	(ddr2_dqs_n[DQS_WIDTH-1:0]),
		       .control_vio	(control_vio[35:0]),
		       // Inputs
		       .clk200_n	(clk200_n),
		       .clk200_p	(clk200_p),
		       .sys_clk_n	(sys_clk_n),
		       .sys_clk_p	(sys_clk_p),
		       .sys_rst_n	(sys_rst_n),
		       .fsabo_valid	(fsabo_valid),
		       .fsabo_mode	(fsabo_mode[FSAB_REQ_HI:0]),
		       .fsabo_did	(fsabo_did[FSAB_DID_HI:0]),
		       .fsabo_subdid	(fsabo_subdid[FSAB_DID_HI:0]),
		       .fsabo_addr	(fsabo_addr[FSAB_ADDR_HI:0]),
		       .fsabo_len	(fsabo_len[FSAB_LEN_HI:0]),
		       .fsabo_data	(fsabo_data[FSAB_DATA_HI:0]),
		       .fsabo_mask	(fsabo_mask[FSAB_MASK_HI:0]));
	defparam mem.DEBUG = "TRUE";
	
	assign leds = {1'b0, fclk_rst_b, 1'b0, 1'b1, 1'b1, tb_done, fclk_div, phy_init_done};
endmodule

module tb_state_machine(/*AUTOARG*/
   // Outputs
   fsabo_valid, fsabo_mode, fsabo_did, fsabo_subdid, fsabo_addr,
   fsabo_len, fsabo_data, fsabo_mask, tb_done,
   // Inputs
   fclk, fclk_rst_b, corerst_btn, fsabo_credit
   );

`include "fsab_defines.vh"

	input fclk;
	input fclk_rst_b;
	
	input corerst_btn;
	
	output reg                  fsabo_valid;
	output reg [FSAB_REQ_HI:0]  fsabo_mode;
	output reg [FSAB_DID_HI:0]  fsabo_did;
	output reg [FSAB_DID_HI:0]  fsabo_subdid;
	output reg [FSAB_ADDR_HI:0] fsabo_addr;
	output reg [FSAB_LEN_HI:0]  fsabo_len;
	output reg [FSAB_DATA_HI:0] fsabo_data;
	output reg [FSAB_MASK_HI:0] fsabo_mask;
	
	input                       fsabo_credit;

	output reg                  tb_done;

	reg [4:0] state = 0, nextstate = 0;
	reg [3:0] wordsleft = 0, nextwordsleft = 0;
	
	always @(posedge fclk or negedge fclk_rst_b)
		if (!fclk_rst_b) begin
			state <= 0;
			wordsleft <= 0;
		end else begin
			state <= nextstate;
			wordsleft <= nextwordsleft;
		end
	
	always @(*) begin
		fsabo_valid = 0;
		fsabo_mode = 'hx;
		fsabo_did = 4'hx;
		fsabo_subdid = 4'hx;
		fsabo_addr = 31'hxxxxxxxx;
		fsabo_len = 3'hx;
		fsabo_data = 64'hxxxxxxxxxxxxxxxx;
		fsabo_mask = 8'hxx;
		tb_done = 0;
		nextstate = state;
		nextwordsleft = wordsleft;
		case (state)
		'd0: begin
			if (corerst_btn) begin
				nextstate = nextstate + 1;
				nextwordsleft = 8;
			end
		end
		'd1: begin	/* 8 word write to 0x0 */
			fsabo_valid = 1;
			fsabo_mode = FSAB_WRITE;
			fsabo_did = 0;
			fsabo_subdid = 0;
			fsabo_addr = 0;
			fsabo_len = 8;
			fsabo_data = {16{wordsleft}};
			fsabo_mask = 8'hFF;
			nextwordsleft = wordsleft - 1;
			if (wordsleft == 1) begin
				nextstate = nextstate + 1;
				nextwordsleft = 0;
			end
		end
		'd2: begin	/* Wait for credit */
			if (fsabo_credit) begin
				nextstate = nextstate + 1;
			end
		end
		'd3: begin	/* 8 word read from 0x0 */
			fsabo_valid = 1;
			fsabo_mode = FSAB_READ;
			fsabo_did = 0;
			fsabo_subdid = 0;
			fsabo_addr = 0;
			fsabo_len = 8;
			fsabo_data = 64'hDEADBEEFDEADBEEF;
			fsabo_mask = 8'hFF;
			nextstate = nextstate + 1;
		end
		'd4: begin	/* Wait for credit */
			if (fsabo_credit) begin
				nextstate = nextstate + 1;
			end
		end 
		'd5: begin	/* 1 word write to 0x8 */
			fsabo_valid = 1;
			fsabo_mode = FSAB_WRITE;
			fsabo_did = 0;
			fsabo_subdid = 0;
			fsabo_addr = 'h8;
			fsabo_len = 1;
			fsabo_data = 64'h1EA754171EA75417;
			fsabo_mask = 8'hF0;
			nextstate = nextstate + 1;
		end
		'd6: begin	/* Wait for credit */
			if (fsabo_credit) begin
				nextstate = nextstate + 1;
			end
		end 
		'd7: begin	/* 8 word read from 0x0 */
			fsabo_valid = 1;
			fsabo_mode = FSAB_READ;
			fsabo_did = 0;
			fsabo_subdid = 0;
			fsabo_addr = 0;
			fsabo_len = 8;
			fsabo_data = 64'hDEADBEEFDEADBEEF;
			fsabo_mask = 8'hFF;
			nextstate = nextstate + 1;
		end
		'd8: begin	/* Wait for credit */
			if (fsabo_credit) begin
				nextstate = nextstate + 1;
			end
		end 
		'd9: begin	/* 1 word write to 0x4 */
			fsabo_valid = 1;
			fsabo_mode = FSAB_WRITE;
			fsabo_did = 0;
			fsabo_subdid = 0;
			fsabo_addr = 'h4;
			fsabo_len = 1;
			fsabo_data = 64'h1337133713371337;
			fsabo_mask = 8'h0F;
			nextstate = nextstate + 1;
		end
		'd10: begin	/* Wait for credit */
			if (fsabo_credit) begin
				nextstate = nextstate + 1;
			end
		end 
		'd11: begin	/* 8 word read from 0x0 */
			fsabo_valid = 1;
			fsabo_mode = FSAB_READ;
			fsabo_did = 0;
			fsabo_subdid = 0;
			fsabo_addr = 0;
			fsabo_len = 8;
			fsabo_data = 64'hDEADBEEFDEADBEEF;
			fsabo_mask = 8'hFF;
			nextstate = nextstate + 1;
		end
		'd12: begin	/* Wait for credit */
			if (fsabo_credit) begin
				nextstate = nextstate + 1;
			end
		end 
		'd13: begin
			tb_done = 1;
		end
		endcase
	end
endmodule	


// Local Variables:
// verilog-library-directories:("." "../console" "../core" "../fsab" "../spam" "../fsab/sim")
// End:
