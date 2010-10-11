module FSABPreload(/*AUTOARG*/
   // Outputs
   rst_core_b, pre__fsabo_valid, pre__fsabo_mode, pre__fsabo_did,
   pre__fsabo_subdid, pre__fsabo_addr, pre__fsabo_len,
   pre__fsabo_data, pre__fsabo_mask,
   // Inputs
   clk, rst_b, pre__fsabo_credit, fsabi_valid, fsabi_did, fsabi_subdid,
   fsabi_data
   );

	`include "fsab_defines.vh"
	
	input clk;
	input rst_b;
	output wire rst_core_b;
	
	/* FSAB interface */
	output reg                  pre__fsabo_valid = 0;
	output reg [FSAB_REQ_HI:0]  pre__fsabo_mode = 0;
	output reg [FSAB_DID_HI:0]  pre__fsabo_did = 0;
	output reg [FSAB_DID_HI:0]  pre__fsabo_subdid = 0;
	output reg [FSAB_ADDR_HI:0] pre__fsabo_addr = 0;
	output reg [FSAB_LEN_HI:0]  pre__fsabo_len = 0;
	output reg [FSAB_DATA_HI:0] pre__fsabo_data = 0;
	output reg [FSAB_MASK_HI:0] pre__fsabo_mask = 0;
	input                       pre__fsabo_credit;
	
	input                       fsabi_valid;
	input      [FSAB_DID_HI:0]  fsabi_did;
	input      [FSAB_DID_HI:0]  fsabi_subdid;
	input      [FSAB_DATA_HI:0] fsabi_data;
	
	`include "clog2.vh"
	
	parameter BOOTMEM_SIZE = 16*1024 / 8;
	parameter BOOTMEM_HI = clog2(BOOTMEM_SIZE) - 2;

	/*** FSAB credit availability logic ***/
	
	wire start_trans;
	
	reg [FSAB_CREDITS_HI:0] fsab_credits = FSAB_INITIAL_CREDITS;	/* XXX needs resettability */
	wire fsab_credit_avail = (fsab_credits != 0);
	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			fsab_credits <= FSAB_INITIAL_CREDITS;
		end else begin
			if (pre__fsabo_credit | start_trans)
				$display("PRELOAD: Credits: %d (+%d, -%d)", fsab_credits, pre__fsabo_credit, start_trans);
			fsab_credits <= fsab_credits + (pre__fsabo_credit ? 1 : 0) - (start_trans ? 1 : 0);
		end
	end

	/*** FSAB preload state machine ***/
	reg [63:0] bootmem [(BOOTMEM_SIZE-1):0];
	initial begin
		assert(FSAB_DATA_HI == 63) else $error("FSAB_DATA_HI unsupported");
		$readmemh("ram.hex64", bootmem);
	end
	
	reg [(BOOTMEM_HI+1):0] curaddr = {(BOOTMEM_HI+2){1'b0}};
	reg intrans = 0;
	/* verilator lint_off WIDTH */ /* BOOTMEM_SIZE comparison */
	assign start_trans = fsab_credit_avail && (curaddr != BOOTMEM_SIZE) && !intrans;
	assign rst_core_b = ~(curaddr != BOOTMEM_SIZE);
	/* verilator lint_on WIDTH */
	
	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			curaddr <= {(BOOTMEM_HI+2){1'b0}};
			intrans <= 0;
			pre__fsabo_valid <= 0;
		end else begin
			if (start_trans) begin
				$display("PRELOAD: %5d: Starting transaction: curaddr %x", $time, curaddr);
				intrans <= 1;
			end else if (intrans && (curaddr[2:0] == 7)) begin
				intrans <= 0;
			end
			
			if (intrans || start_trans) begin
				$display("PRELOAD: %5d: asserting valid: curaddr %x", $time, curaddr);
				pre__fsabo_valid <= 1;
				pre__fsabo_mode <= FSAB_WRITE;
				pre__fsabo_did <= {(FSAB_DID_HI+1){1'b1}};
				pre__fsabo_subdid <= {(FSAB_DID_HI+1){1'b0}};
				pre__fsabo_addr <= {{(FSAB_ADDR_HI - (BOOTMEM_HI+1) - 3){1'b0}}, curaddr, 3'b000};
				pre__fsabo_len <= 8;
				pre__fsabo_data <= bootmem[curaddr[BOOTMEM_HI:0]];
				pre__fsabo_mask <= 8'hFF;
				
				curaddr <= curaddr + 1;
			end else begin
				pre__fsabo_valid <= 0;
			end
		end
	end
endmodule
